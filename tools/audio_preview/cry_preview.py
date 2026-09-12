#!/usr/bin/env python3
"""
Render a pokered Game Boy cry (base waveform + pitch/length modifiers) to a WAV
file, without building the ROM, so pitch/length tweaks can be A/B'd by ear.

This reimplements the exact fixed-point timing/pitch math from
audio/engine_3.asm (Audio3_note_length, Audio3_SetSfxTempo,
Audio3_ApplyFrequencyModifier) and the standard Game Boy APU square/noise
channel formulas, reading directly from the project's own audio/sfx/*.asm and
data/pokemon/cries.asm sources, so it always reflects your current edits.

Usage:
    python3 tools/audio_preview/cry_preview.py --species ESPEON
    python3 tools/audio_preview/cry_preview.py --base 1A --pitch 0x40 --length 0x60 --out out.wav
    python3 tools/audio_preview/cry_preview.py --species ESPEON --species UMBREON  (renders both)
"""
import argparse
import math
import re
import struct
import wave
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SFX_DIR = REPO_ROOT / "audio" / "sfx"
CRIES_ASM = REPO_ROOT / "data" / "pokemon" / "cries.asm"

VBLANK_HZ = 59.7275         # audio engine ticks once per VBlank
SAMPLE_RATE = 44100
CH_PEAK = 9000               # per-channel amplitude ceiling before mixing

NOTE_RE = re.compile(r"(square_note|noise_note)\s+(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)")
DUTY_RE = re.compile(r"duty_cycle_pattern\s+(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)")
MON_CRY_RE = re.compile(
    r"mon_cry\s+SFX_CRY_(\w+)\s*,\s*\$([0-9A-Fa-f]+)\s*,\s*\$([0-9A-Fa-f]+)\s*;\s*(.+)"
)


class Note:
    __slots__ = ("length", "volume", "fade", "freq")

    def __init__(self, length, volume, fade, freq):
        self.length = length   # raw macro arg, 0-15 -> actual units = length+1
        self.volume = volume   # 0-15
        self.fade = fade       # signed envelope period, -7..7 (0 = constant)
        self.freq = freq       # square: 11-bit period; noise: raw NR43 byte


def parse_base_cry(base_hex):
    """Parse audio/sfx/cry{base}_2.asm into duty pattern + note lists per channel."""
    path = SFX_DIR / f"cry{base_hex.lower()}_2.asm"
    if not path.exists():
        raise SystemExit(f"no such base cry file: {path}")
    text = path.read_text()

    blocks = re.split(r"(?=SFX_Cry\w+_2_Ch\d:)", text)
    channels = {}
    for block in blocks:
        m = re.match(r"SFX_Cry\w+_2_Ch(\d):", block)
        if not m:
            continue
        chan = int(m.group(1))
        duty = DUTY_RE.search(block)
        duty_pattern = [int(x) for x in duty.groups()] if duty else None
        notes = [
            Note(int(l), int(v), int(f), int(fr))
            for (kind, l, v, f, fr) in NOTE_RE.findall(block)
        ]
        channels[chan] = (duty_pattern, notes)
    return channels


def lookup_species(name):
    """Find a mon_cry line by its trailing comment, e.g. '; Espeon'."""
    text = CRIES_ASM.read_text()
    for base, pitch, length, comment in MON_CRY_RE.findall(text):
        if comment.strip().lower() == name.strip().lower():
            return base, int(pitch, 16), int(length, 16)
    raise SystemExit(f"no mon_cry entry commented '; {name}' found in {CRIES_ASM}")


def note_ticks(note, tempo16, note_speed_state):
    """Reproduce Audio3_note_length's fixed-point tick calc for one note.
    note_speed_state is a 1-element list holding the running fractional
    accumulator (wChannelNoteDelayCountersFractionalPart) between calls."""
    actual_length = (note.length & 0xF) + 1          # 1..16
    stage1 = (1 * actual_length) & 0xFF               # wChannelNoteSpeeds defaults to 1
    total = note_speed_state[0] + stage1 * tempo16
    ticks = (total >> 8) & 0xFF                       # high byte -> whole ticks
    note_speed_state[0] = total & 0xFF                # low byte -> carried fraction
    return ticks


def envelope_volume(t, note):
    """GB volume envelope: fade encodes a signed-magnitude period in 1/64s units.
    magnitude 0 = constant volume; sign: positive = decrease, negative = increase."""
    if note.fade == 0:
        return note.volume
    period = abs(note.fade) / 64.0
    steps = int(t / period)
    vol = note.volume - steps if note.fade > 0 else note.volume + steps
    return max(0, min(15, vol))


def synth_square(duty_pattern, notes, pitch_mod, length_mod, out, warn):
    tempo16 = 128 + (length_mod & 0xFF)
    frac = [0]
    t_cursor = 0.0
    for i, note in enumerate(notes):
        ticks = note_ticks(note, tempo16, frac)
        duration = ticks / VBLANK_HZ
        period = note.freq + pitch_mod
        if period >= 2048:
            warn(f"pitch modifier overflows period ({note.freq}+{pitch_mod}={period}); clamped")
            period = 2047
        freq_hz = 131072 / (2048 - period) if period < 2048 else 0
        duty = [0.125, 0.25, 0.5, 0.75][duty_pattern[i % 4]] if duty_pattern else 0.5

        n_samples = int(duration * SAMPLE_RATE)
        base_idx = int(t_cursor * SAMPLE_RATE)
        for s in range(n_samples):
            t = s / SAMPLE_RATE
            idx = base_idx + s
            if idx >= len(out):
                break
            vol = envelope_volume(t, note)
            if vol == 0 or freq_hz == 0:
                continue
            phase = (t * freq_hz) % 1.0
            level = 1.0 if phase < duty else -1.0
            out[idx] += level * (vol / 15.0) * CH_PEAK
        t_cursor += duration


def synth_noise(notes, out, warn):
    # noise channel ignores the mon_cry pitch/length modifiers entirely
    # (Audio3 hardcodes its tempo to $0100 and never applies the frequency
    # modifier to channel 8), so it always plays at its authored speed/pitch.
    tempo16 = 256
    frac = [0]
    t_cursor = 0.0
    for note in notes:
        ticks = note_ticks(note, tempo16, frac)
        duration = ticks / VBLANK_HZ

        reg = note.freq & 0xFF
        shift = (reg >> 4) & 0xF
        width7 = bool(reg & 0x8)
        ratio = reg & 0x7
        divisor = 8 if ratio == 0 else ratio * 16
        clock_hz = 4194304 / (divisor << (shift + 1)) if (divisor << (shift + 1)) else 0

        lfsr = 0x7FFF
        n_samples = int(duration * SAMPLE_RATE)
        samples_per_clock = SAMPLE_RATE / clock_hz if clock_hz else n_samples + 1
        next_clock = 0.0
        bit = 1
        for s in range(n_samples):
            if s >= next_clock:
                xor = (lfsr & 1) ^ ((lfsr >> 1) & 1)
                lfsr >>= 1
                lfsr |= xor << (6 if width7 else 14)
                bit = ~lfsr & 1
                next_clock += samples_per_clock
            idx = int(t_cursor * SAMPLE_RATE) + s
            if idx >= len(out):
                break
            t = s / SAMPLE_RATE
            vol = envelope_volume(t, note)
            if vol:
                out[idx] += (1.0 if bit else -1.0) * (vol / 15.0) * (CH_PEAK * 0.6)
        t_cursor += duration


def render(base_hex, pitch_mod, length_mod, out_path):
    channels = parse_base_cry(base_hex)
    warnings = []

    def warn(msg):
        warnings.append(msg)

    # figure total duration up front by simulating tick counts (cheap, no audio)
    def total_seconds(chan_id, tempo16_fixed=None):
        if chan_id not in channels:
            return 0.0
        _, notes = channels[chan_id]
        tempo16 = tempo16_fixed if tempo16_fixed is not None else 128 + (length_mod & 0xFF)
        frac = [0]
        secs = 0.0
        for note in notes:
            secs += note_ticks(note, tempo16, frac) / VBLANK_HZ
        return secs

    duration = max(total_seconds(5), total_seconds(6), total_seconds(8, tempo16_fixed=256))
    n_total = int(duration * SAMPLE_RATE) + SAMPLE_RATE // 20  # small tail pad
    buf = [0.0] * n_total

    if 5 in channels:
        duty, notes = channels[5]
        synth_square(duty, notes, pitch_mod, length_mod, buf, warn)
    if 6 in channels:
        duty, notes = channels[6]
        synth_square(duty, notes, pitch_mod, length_mod, buf, warn)
    if 8 in channels:
        _, notes = channels[8]
        synth_noise(notes, buf, warn)

    peak = max((abs(x) for x in buf), default=0)
    scale = (32000 / peak) if peak > 32000 else 1.0
    pcm = bytearray()
    for x in buf:
        v = int(max(-32768, min(32767, x * scale)))
        pcm += struct.pack("<h", v)

    with wave.open(str(out_path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(bytes(pcm))

    return duration, warnings


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--species", action="append", default=[], help="mon_cry comment name in cries.asm, e.g. Espeon (repeatable)")
    ap.add_argument("--base", help="base cry hex id, e.g. 1A (matches SFX_CRY_1A)")
    ap.add_argument("--pitch", help="pitch modifier byte, e.g. 0x40")
    ap.add_argument("--length", help="length/tempo modifier byte, e.g. 0x60")
    ap.add_argument("--out", help="output wav path (default: <name>_cry.wav next to this script)")
    args = ap.parse_args()

    jobs = []
    for name in args.species:
        base, pitch, length = lookup_species(name)
        jobs.append((name, base, pitch, length))
    if args.base:
        if args.pitch is None or args.length is None:
            raise SystemExit("--base requires --pitch and --length")
        jobs.append((args.out or "custom", args.base, int(args.pitch, 16), int(args.length, 16)))

    if not jobs:
        raise SystemExit("give --species NAME (repeatable) or --base/--pitch/--length")

    out_dir = Path(__file__).parent
    for name, base, pitch, length in jobs:
        out_path = Path(args.out) if (args.out and len(jobs) == 1) else out_dir / f"{name.lower()}_cry.wav"
        duration, warnings = render(base, pitch, length, out_path)
        print(f"{name}: base={base} pitch=${pitch:02X} length=${length:02X} "
              f"-> {out_path}  ({duration*1000:.0f} ms)")
        for w in warnings:
            print(f"  warning: {w}")


if __name__ == "__main__":
    main()
