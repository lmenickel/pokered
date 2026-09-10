"use strict";

const DATA = window.MAP_EDITOR_DATA;
const TILESETS = DATA.tilesets; // dense array, index === id
const MAP_CONSTANTS = DATA.mapConstants; // [{const,width,height}]
const CATEGORY_LABELS = DATA.categoryLabels; // {water:'Water', ledge:'Ledges', ...}
const STORAGE_KEY = "pokered_map_editor_state_v1";

const GFX_BASE = "../../"; // tools/map_editor/index.html -> repo root

// ---------- image cache ----------
const imageCache = new Map();
function getTilesetImage(tileset) {
  let img = imageCache.get(tileset.pngFile);
  if (!img) {
    img = new Image();
    img.src = GFX_BASE + tileset.pngFile;
    img.onload = () => renderAll();
    imageCache.set(tileset.pngFile, img);
  }
  return img;
}

function tilesetById(id) {
  return TILESETS[id] || TILESETS[0];
}

function drawBlock(ctx, tileset, blockId, dx, dy, size) {
  const img = getTilesetImage(tileset);
  const block = tileset.blocks[blockId];
  if (!block) {
    ctx.fillStyle = "#402020";
    ctx.fillRect(dx, dy, size, size);
    return;
  }
  const t = size / 4;
  if (!img.complete || img.naturalWidth === 0) {
    ctx.fillStyle = "#333";
    ctx.fillRect(dx, dy, size, size);
    return;
  }
  for (let ty = 0; ty < 4; ty++) {
    for (let tx = 0; tx < 4; tx++) {
      const tileIndex = block[ty * 4 + tx];
      const sx = (tileIndex % tileset.tileCols) * 8;
      const sy = Math.floor(tileIndex / tileset.tileCols) * 8;
      ctx.drawImage(img, sx, sy, 8, 8, dx + tx * t, dy + ty * t, t, t);
    }
  }
}

function makeBlockThumb(tileset, blockId, size) {
  const c = document.createElement("canvas");
  c.width = size;
  c.height = size;
  const ctx = c.getContext("2d");
  drawBlock(ctx, tileset, blockId, 0, 0, size);
  return c;
}

// ---------- default project ----------
function defaultState() {
  const overworld = TILESETS.find((t) => t.const === "OVERWORLD") || TILESETS[0];
  const width = 10, height = 9;
  return {
    mapName: "NewTown",
    mapConst: "NEW_TOWN",
    tilesetId: overworld.id,
    width,
    height,
    borderBlock: 0,
    zoom: 32,
    grid: new Array(width * height).fill(0),
    warps: [],
    connections: {
      north: { enabled: false, targetConst: MAP_CONSTANTS[0].const, offset: 0 },
      south: { enabled: false, targetConst: MAP_CONSTANTS[0].const, offset: 0 },
      east: { enabled: false, targetConst: MAP_CONSTANTS[0].const, offset: 0 },
      west: { enabled: false, targetConst: MAP_CONSTANTS[0].const, offset: 0 },
    },
    stamps: [defaultHouseStamp(overworld.id)],
  };
}

function defaultHouseStamp(overworldId) {
  // Verified against maps/PalletTown.blk: the classic small red-roofed
  // house (Red's House / Blue's House exterior) is a 2x3 block footprint
  // in the Overworld tileset's blockset.
  return {
    id: "builtin-small-house",
    name: "Small House (built-in)",
    tilesetId: overworldId,
    w: 2,
    h: 3,
    blocks: [0x52, 0x52, 0x38, 0x39, 0x3c, 0x3d],
  };
}

let state = loadState() || defaultState();
let selectedBlockId = 0;
let mode = "paint"; // paint | warp | erase | select
let painting = false;
let activeCategory = "all";

// Multi-cell selection (Select mode): a persisted Set of "x,y" cell keys,
// plus in-progress drag state that previews on top of it without mutating
// it until mouseup.
let selectionSet = new Set();
let dragRect = null; // {x0,y0,x1,y1} while dragging
let dragMode = null; // 'replace' | 'add' | 'remove'

// ---------- selection helpers ----------
function cellKey(x, y) {
  return x + "," + y;
}

function rectCellKeys(rect) {
  const x0 = Math.min(rect.x0, rect.x1);
  const x1 = Math.max(rect.x0, rect.x1);
  const y0 = Math.min(rect.y0, rect.y1);
  const y1 = Math.max(rect.y0, rect.y1);
  const keys = [];
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) keys.push(cellKey(x, y));
  }
  return keys;
}

function effectiveSelection() {
  if (!dragRect) return selectionSet;
  const rectKeys = rectCellKeys(dragRect);
  if (dragMode === "replace") return new Set(rectKeys);
  const out = new Set(selectionSet);
  if (dragMode === "add") {
    for (const k of rectKeys) out.add(k);
  } else if (dragMode === "remove") {
    for (const k of rectKeys) out.delete(k);
  }
  return out;
}

function selectionBounds(set) {
  if (set.size === 0) return null;
  let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
  for (const k of set) {
    const [x, y] = k.split(",").map(Number);
    if (x < x0) x0 = x;
    if (y < y0) y0 = y;
    if (x > x1) x1 = x;
    if (y > y1) y1 = y;
  }
  return { x0, y0, x1, y1 };
}

function selectionIsSolidRect(set) {
  const b = selectionBounds(set);
  if (!b) return false;
  const area = (b.x1 - b.x0 + 1) * (b.y1 - b.y0 + 1);
  return area === set.size;
}

function updateSelectionButtons() {
  const set = effectiveSelection();
  fillSelectionBtn.disabled = set.size === 0;
  eraseSelectionBtn.disabled = set.size === 0;
  saveSelectionStampBtn.disabled = !selectionIsSolidRect(set);
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const s = JSON.parse(raw);
    if (!s || !Array.isArray(s.grid)) return null;
    return s;
  } catch (e) {
    return null;
  }
}

let saveTimer = null;
function persist() {
  clearTimeout(saveTimer);
  saveTimer = setTimeout(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    const hint = document.getElementById("autosaveHint");
    hint.textContent = "Autosaved " + new Date().toLocaleTimeString();
  }, 300);
}

// ---------- DOM refs ----------
const el = (id) => document.getElementById(id);
const mapNameInput = el("mapName");
const mapConstInput = el("mapConst");
const tilesetSelect = el("tilesetSelect");
const mapWidthInput = el("mapWidth");
const mapHeightInput = el("mapHeight");
const resizeBtn = el("resizeBtn");
const borderBlockInput = el("borderBlock");
const zoomSelect = el("zoomSelect");
const canvas = el("mapCanvas");
const ctx = canvas.getContext("2d");
const statusbar = el("statusbar");
const blockGrid = el("blockGrid");
const categoryTabs = el("categoryTabs");
const stampList = el("stampList");
const fillSelectionBtn = el("fillSelectionBtn");
const eraseSelectionBtn = el("eraseSelectionBtn");
const saveSelectionStampBtn = el("saveSelectionStampBtn");
const warpTableBody = el("warpTableBody");
const connTableBody = el("connTableBody");

// ---------- init form values ----------
function populateTilesetSelect() {
  tilesetSelect.innerHTML = "";
  for (const ts of TILESETS) {
    const opt = document.createElement("option");
    opt.value = ts.id;
    opt.textContent = `${ts.label} (${ts.const})`;
    tilesetSelect.appendChild(opt);
  }
  tilesetSelect.value = state.tilesetId;
}

function mapConstOptionsHtml(selected) {
  return MAP_CONSTANTS.map(
    (m) => `<option value="${m.const}" ${m.const === selected ? "selected" : ""}>${m.const}</option>`
  ).join("");
}

function syncFormFromState() {
  mapNameInput.value = state.mapName;
  mapConstInput.value = state.mapConst;
  tilesetSelect.value = state.tilesetId;
  mapWidthInput.value = state.width;
  mapHeightInput.value = state.height;
  borderBlockInput.value = state.borderBlock;
  zoomSelect.value = state.zoom;
}

// ---------- category tabs ----------
function renderCategoryTabs() {
  const tileset = tilesetById(state.tilesetId);
  const counts = new Map();
  for (const cat of tileset.categories) counts.set(cat, (counts.get(cat) || 0) + 1);
  if (!counts.has(activeCategory) && activeCategory !== "all") activeCategory = "all";

  categoryTabs.innerHTML = "";
  const makeTab = (key, label, count) => {
    const btn = document.createElement("button");
    btn.className = "toggle" + (activeCategory === key ? " active" : "");
    btn.innerHTML = `${label}<span class="count">${count}</span>`;
    btn.addEventListener("click", () => {
      activeCategory = key;
      renderCategoryTabs();
      renderPalette();
    });
    categoryTabs.appendChild(btn);
  };
  makeTab("all", "All", tileset.numBlocks);
  for (const [key, label] of Object.entries(CATEGORY_LABELS)) {
    if (counts.has(key)) makeTab(key, label, counts.get(key));
  }
}

// ---------- palette ----------
function renderPalette() {
  blockGrid.innerHTML = "";
  const tileset = tilesetById(state.tilesetId);
  for (let b = 0; b < tileset.numBlocks; b++) {
    if (activeCategory !== "all" && tileset.categories[b] !== activeCategory) continue;
    const c = makeBlockThumb(tileset, b, 32);
    c.className = "block-thumb" + (b === selectedBlockId ? " selected" : "");
    c.title = "Block " + b;
    c.draggable = true;
    c.addEventListener("click", () => {
      selectedBlockId = b;
      renderPalette();
    });
    c.addEventListener("dragstart", (e) => {
      e.dataTransfer.setData("application/json", JSON.stringify({ type: "block", blockId: b }));
    });
    blockGrid.appendChild(c);
  }
}

function renderStampList() {
  stampList.innerHTML = "";
  for (const stamp of state.stamps) {
    const row = document.createElement("div");
    row.className = "stamp-item";
    row.draggable = true;
    row.title = `${stamp.w}x${stamp.h} blocks (${tilesetById(stamp.tilesetId).label})`;

    const c = document.createElement("canvas");
    c.width = stamp.w * 16;
    c.height = stamp.h * 16;
    const cctx = c.getContext("2d");
    const ts = tilesetById(stamp.tilesetId);
    for (let y = 0; y < stamp.h; y++) {
      for (let x = 0; x < stamp.w; x++) {
        drawBlock(cctx, ts, stamp.blocks[y * stamp.w + x], x * 16, y * 16, 16);
      }
    }
    row.appendChild(c);

    const name = document.createElement("span");
    name.className = "name";
    name.textContent = stamp.name;
    row.appendChild(name);

    const del = document.createElement("button");
    del.textContent = "x";
    del.title = "Delete stamp";
    del.addEventListener("click", () => {
      state.stamps = state.stamps.filter((s) => s.id !== stamp.id);
      renderStampList();
      persist();
    });
    row.appendChild(del);

    row.addEventListener("dragstart", (e) => {
      e.dataTransfer.setData("application/json", JSON.stringify({ type: "stamp", stampId: stamp.id }));
    });

    stampList.appendChild(row);
  }
}

// ---------- map rendering ----------
function renderMap() {
  const zoom = state.zoom;
  canvas.width = state.width * zoom;
  canvas.height = state.height * zoom;
  const tileset = tilesetById(state.tilesetId);

  for (let y = 0; y < state.height; y++) {
    for (let x = 0; x < state.width; x++) {
      const blockId = state.grid[y * state.width + x];
      drawBlock(ctx, tileset, blockId, x * zoom, y * zoom, zoom);
    }
  }

  // grid lines
  ctx.strokeStyle = "rgba(255,255,255,0.08)";
  ctx.lineWidth = 1;
  for (let x = 0; x <= state.width; x++) {
    ctx.beginPath();
    ctx.moveTo(x * zoom + 0.5, 0);
    ctx.lineTo(x * zoom + 0.5, canvas.height);
    ctx.stroke();
  }
  for (let y = 0; y <= state.height; y++) {
    ctx.beginPath();
    ctx.moveTo(0, y * zoom + 0.5);
    ctx.lineTo(canvas.width, y * zoom + 0.5);
    ctx.stroke();
  }

  // connections: highlight edges
  const dirs = {
    north: { edge: "top" },
    south: { edge: "bottom" },
    east: { edge: "right" },
    west: { edge: "left" },
  };
  ctx.fillStyle = "rgba(90,169,255,0.55)";
  for (const [dir, conn] of Object.entries(state.connections)) {
    if (!conn.enabled) continue;
    const e = dirs[dir].edge;
    const thick = 4;
    if (e === "top") ctx.fillRect(0, 0, canvas.width, thick);
    if (e === "bottom") ctx.fillRect(0, canvas.height - thick, canvas.width, thick);
    if (e === "left") ctx.fillRect(0, 0, thick, canvas.height);
    if (e === "right") ctx.fillRect(canvas.width - thick, 0, thick, canvas.height);
  }

  // warps
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  state.warps.forEach((w, i) => {
    const bx = Math.floor(w.x / 2) * zoom;
    const by = Math.floor(w.y / 2) * zoom;
    ctx.fillStyle = "rgba(255,90,122,0.75)";
    ctx.fillRect(bx + zoom * 0.15, by + zoom * 0.15, zoom * 0.7, zoom * 0.7);
    ctx.fillStyle = "#fff";
    ctx.font = `${Math.max(9, zoom * 0.35)}px sans-serif`;
    ctx.fillText(String(i + 1), bx + zoom / 2, by + zoom / 2);
  });

  // multi-cell selection
  const sel = effectiveSelection();
  if (sel.size) {
    ctx.fillStyle = "rgba(90,169,255,0.35)";
    ctx.strokeStyle = "#5aa9ff";
    ctx.lineWidth = 1;
    for (const k of sel) {
      const [x, y] = k.split(",").map(Number);
      ctx.fillRect(x * zoom, y * zoom, zoom, zoom);
      ctx.strokeRect(x * zoom + 0.5, y * zoom + 0.5, zoom - 1, zoom - 1);
    }
  }
}

function renderAll() {
  syncFormFromState();
  renderCategoryTabs();
  renderPalette();
  renderStampList();
  renderMap();
  renderWarpTable();
  renderConnTable();
  updateSelectionButtons();
}

// ---------- editing ----------
function setBlockAt(x, y, blockId) {
  if (x < 0 || y < 0 || x >= state.width || y >= state.height) return;
  state.grid[y * state.width + x] = blockId;
}

function cellFromEvent(e) {
  const rect = canvas.getBoundingClientRect();
  const px = e.clientX - rect.left;
  const py = e.clientY - rect.top;
  const x = Math.floor(px / state.zoom);
  const y = Math.floor(py / state.zoom);
  return { x: Math.max(0, Math.min(state.width - 1, x)), y: Math.max(0, Math.min(state.height - 1, y)) };
}

function addOrEditWarpAt(x, y) {
  const existing = state.warps.find((w) => Math.floor(w.x / 2) === x && Math.floor(w.y / 2) === y);
  if (existing) return;
  const defaultConst = MAP_CONSTANTS[0].const;
  state.warps.push({ x: x * 2 + 1, y: y * 2 + 1, dest: defaultConst, warpId: 1 });
  renderWarpTable();
  renderMap();
  persist();
}

function stampMatchesTileset(stamp) {
  return stamp.tilesetId === state.tilesetId;
}

function placeStamp(stamp, cellX, cellY) {
  if (!stampMatchesTileset(stamp)) {
    alert(
      `"${stamp.name}" was captured with the ${tilesetById(stamp.tilesetId).label} tileset, ` +
        `but this map uses ${tilesetById(state.tilesetId).label}. Switch tileset to place it.`
    );
    return;
  }
  let ox = Math.min(cellX, state.width - stamp.w);
  let oy = Math.min(cellY, state.height - stamp.h);
  ox = Math.max(0, ox);
  oy = Math.max(0, oy);
  for (let y = 0; y < stamp.h; y++) {
    for (let x = 0; x < stamp.w; x++) {
      if (ox + x >= state.width || oy + y >= state.height) continue;
      setBlockAt(ox + x, oy + y, stamp.blocks[y * stamp.w + x]);
    }
  }
  renderMap();
  persist();
}

canvas.addEventListener("mousedown", (e) => {
  const { x, y } = cellFromEvent(e);
  if (mode === "paint") {
    painting = true;
    setBlockAt(x, y, selectedBlockId);
    renderMap();
  } else if (mode === "erase") {
    painting = true;
    setBlockAt(x, y, 0);
    renderMap();
  } else if (mode === "warp") {
    addOrEditWarpAt(x, y);
  } else if (mode === "select") {
    dragMode = e.altKey ? "remove" : e.shiftKey ? "add" : "replace";
    dragRect = { x0: x, y0: y, x1: x, y1: y };
    renderMap();
    updateSelectionButtons();
  }
});

canvas.addEventListener("mousemove", (e) => {
  const { x, y } = cellFromEvent(e);
  statusbar.textContent = `(${x}, ${y}) block=${state.grid[y * state.width + x]} tileset=${tilesetById(state.tilesetId).label}`;
  if (painting && (mode === "paint" || mode === "erase")) {
    setBlockAt(x, y, mode === "paint" ? selectedBlockId : 0);
    renderMap();
  } else if (dragRect) {
    dragRect.x1 = x;
    dragRect.y1 = y;
    renderMap();
    updateSelectionButtons();
  }
});

window.addEventListener("mouseup", () => {
  if (painting) persist();
  painting = false;
  if (dragRect) {
    selectionSet = effectiveSelection();
    dragRect = null;
    dragMode = null;
    renderMap();
    updateSelectionButtons();
  }
});

canvas.addEventListener("dragover", (e) => e.preventDefault());
canvas.addEventListener("drop", (e) => {
  e.preventDefault();
  const { x, y } = cellFromEvent(e);
  let payload;
  try {
    payload = JSON.parse(e.dataTransfer.getData("application/json"));
  } catch (err) {
    return;
  }
  if (payload.type === "block") {
    setBlockAt(x, y, payload.blockId);
    renderMap();
    persist();
  } else if (payload.type === "stamp") {
    const stamp = state.stamps.find((s) => s.id === payload.stampId);
    if (stamp) placeStamp(stamp, x, y);
  }
});

saveSelectionStampBtn.addEventListener("click", () => {
  const set = selectionSet;
  const bounds = selectionBounds(set);
  if (!bounds || !selectionIsSolidRect(set)) return;
  const name = prompt("Name this stamp:", "My Building");
  if (!name) return;
  const w = bounds.x1 - bounds.x0 + 1;
  const h = bounds.y1 - bounds.y0 + 1;
  const blocks = [];
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      blocks.push(state.grid[(bounds.y0 + y) * state.width + (bounds.x0 + x)]);
    }
  }
  state.stamps.push({ id: "stamp-" + Date.now(), name, tilesetId: state.tilesetId, w, h, blocks });
  renderStampList();
  persist();
});

fillSelectionBtn.addEventListener("click", () => {
  for (const k of selectionSet) {
    const [x, y] = k.split(",").map(Number);
    setBlockAt(x, y, selectedBlockId);
  }
  renderMap();
  persist();
});

eraseSelectionBtn.addEventListener("click", () => {
  for (const k of selectionSet) {
    const [x, y] = k.split(",").map(Number);
    setBlockAt(x, y, 0);
  }
  renderMap();
  persist();
});

// ---------- mode buttons ----------
function setMode(newMode) {
  mode = newMode;
  for (const id of ["modePaint", "modeWarp", "modeErase", "modeSelect"]) {
    el(id).classList.toggle("active", id.toLowerCase().includes(newMode));
  }
}
el("modePaint").addEventListener("click", () => setMode("paint"));
el("modeWarp").addEventListener("click", () => setMode("warp"));
el("modeErase").addEventListener("click", () => setMode("erase"));
el("modeSelect").addEventListener("click", () => setMode("select"));

// ---------- warp table ----------
function renderWarpTable() {
  warpTableBody.innerHTML = "";
  state.warps.forEach((w, i) => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td><input type="number" min="0" data-f="x" value="${w.x}"></td>
      <td><input type="number" min="0" data-f="y" value="${w.y}"></td>
      <td><select data-f="dest">${mapConstOptionsHtml(w.dest)}</select></td>
      <td><input type="number" min="1" data-f="warpId" value="${w.warpId}"></td>
      <td><button data-act="del">x</button></td>
    `;
    tr.querySelector('[data-f="x"]').addEventListener("input", (e) => {
      w.x = parseInt(e.target.value, 10) || 0;
      renderMap();
      persist();
    });
    tr.querySelector('[data-f="y"]').addEventListener("input", (e) => {
      w.y = parseInt(e.target.value, 10) || 0;
      renderMap();
      persist();
    });
    tr.querySelector('[data-f="dest"]').addEventListener("change", (e) => {
      w.dest = e.target.value;
      persist();
    });
    tr.querySelector('[data-f="warpId"]').addEventListener("input", (e) => {
      w.warpId = parseInt(e.target.value, 10) || 1;
      persist();
    });
    tr.querySelector('[data-act="del"]').addEventListener("click", () => {
      state.warps.splice(i, 1);
      renderWarpTable();
      renderMap();
      persist();
    });
    warpTableBody.appendChild(tr);
  });
}

// ---------- connections table ----------
function renderConnTable() {
  connTableBody.innerHTML = "";
  for (const dir of ["north", "south", "east", "west"]) {
    const conn = state.connections[dir];
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${dir}</td>
      <td><input type="checkbox" data-f="enabled" ${conn.enabled ? "checked" : ""}></td>
      <td><select data-f="targetConst">${mapConstOptionsHtml(conn.targetConst)}</select></td>
      <td><input type="number" data-f="offset" value="${conn.offset}"></td>
    `;
    tr.querySelector('[data-f="enabled"]').addEventListener("change", (e) => {
      conn.enabled = e.target.checked;
      renderMap();
      persist();
    });
    tr.querySelector('[data-f="targetConst"]').addEventListener("change", (e) => {
      conn.targetConst = e.target.value;
      persist();
    });
    tr.querySelector('[data-f="offset"]').addEventListener("input", (e) => {
      conn.offset = parseInt(e.target.value, 10) || 0;
      persist();
    });
    connTableBody.appendChild(tr);
  }
}

// ---------- toolbar handlers ----------
mapNameInput.addEventListener("input", () => {
  state.mapName = mapNameInput.value;
  persist();
});
mapConstInput.addEventListener("input", () => {
  state.mapConst = mapConstInput.value;
  persist();
});
tilesetSelect.addEventListener("change", () => {
  const newId = parseInt(tilesetSelect.value, 10);
  if (newId === state.tilesetId) return;
  const hasContent = state.grid.some((b) => b !== 0);
  if (hasContent) {
    const ok = confirm(
      "Changing tileset makes existing block ids reference different graphics. Reset all blocks to 0?"
    );
    if (!ok) {
      tilesetSelect.value = state.tilesetId;
      return;
    }
    state.grid.fill(0);
  }
  state.tilesetId = newId;
  selectedBlockId = 0;
  activeCategory = "all";
  selectionSet = new Set();
  renderAll();
  persist();
});
resizeBtn.addEventListener("click", () => {
  const w = Math.max(1, parseInt(mapWidthInput.value, 10) || state.width);
  const h = Math.max(1, parseInt(mapHeightInput.value, 10) || state.height);
  const newGrid = new Array(w * h).fill(0);
  for (let y = 0; y < Math.min(h, state.height); y++) {
    for (let x = 0; x < Math.min(w, state.width); x++) {
      newGrid[y * w + x] = state.grid[y * state.width + x];
    }
  }
  state.width = w;
  state.height = h;
  state.grid = newGrid;
  state.warps = state.warps.filter((warp) => Math.floor(warp.x / 2) < w && Math.floor(warp.y / 2) < h);
  selectionSet = new Set(
    [...selectionSet].filter((k) => {
      const [x, y] = k.split(",").map(Number);
      return x < w && y < h;
    })
  );
  renderAll();
  persist();
});
borderBlockInput.addEventListener("input", () => {
  state.borderBlock = parseInt(borderBlockInput.value, 10) || 0;
  persist();
});
zoomSelect.addEventListener("change", () => {
  state.zoom = parseInt(zoomSelect.value, 10);
  renderMap();
  persist();
});

// ---------- project save/load ----------
function downloadBlob(filename, blob) {
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 1000);
}

el("saveProjectBtn").addEventListener("click", () => {
  const blob = new Blob([JSON.stringify(state, null, 2)], { type: "application/json" });
  downloadBlob(`${state.mapName || "map"}.mapproject.json`, blob);
});

el("loadProjectBtn").addEventListener("click", () => el("loadProjectFile").click());
el("loadProjectFile").addEventListener("change", (e) => {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    try {
      const loaded = JSON.parse(reader.result);
      if (!Array.isArray(loaded.grid)) throw new Error("not a map project file");
      state = loaded;
      activeCategory = "all";
      selectionSet = new Set();
      renderAll();
      persist();
    } catch (err) {
      alert("Couldn't load project: " + err.message);
    }
  };
  reader.readAsText(file);
  e.target.value = "";
});

el("loadBlkBtn").addEventListener("click", () => el("loadBlkFile").click());
el("loadBlkFile").addEventListener("change", (e) => {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    const bytes = new Uint8Array(reader.result);
    if (bytes.length !== state.width * state.height) {
      alert(
        `${file.name} is ${bytes.length} bytes, but the current map is ${state.width}x${state.height} ` +
          `(${state.width * state.height} blocks). Set W/H to match first (check constants/map_constants.asm), then retry.`
      );
      return;
    }
    state.grid = Array.from(bytes);
    renderMap();
    persist();
  };
  reader.readAsArrayBuffer(file);
  e.target.value = "";
});

// ---------- export ----------
function pascalCase(constName) {
  return constName
    .toLowerCase()
    .split("_")
    .map((w) => w[0].toUpperCase() + w.slice(1))
    .join("");
}

el("exportBlkBtn").addEventListener("click", () => {
  const bytes = new Uint8Array(state.grid);
  downloadBlob(`${state.mapName}.blk`, new Blob([bytes], { type: "application/octet-stream" }));
});

el("exportHeaderBtn").addEventListener("click", () => {
  const tileset = tilesetById(state.tilesetId);
  const dirFlags = [];
  const lines = [];
  for (const dir of ["north", "south", "west", "east"]) {
    const conn = state.connections[dir];
    if (!conn.enabled) continue;
    dirFlags.push(dir.toUpperCase());
    lines.push(`\tconnection ${dir}, ${pascalCase(conn.targetConst)}, ${conn.targetConst}, ${conn.offset}`);
  }
  const flags = dirFlags.length ? dirFlags.join(" | ") : "0";
  const text =
    `\tmap_header ${state.mapName}, ${state.mapConst}, ${tileset.const}, ${flags}\n` +
    lines.join("\n") +
    (lines.length ? "\n" : "") +
    `\tend_map_header\n`;
  downloadBlob(`${state.mapName}_header.asm`, new Blob([text], { type: "text/plain" }));
});

el("exportObjectsBtn").addEventListener("click", () => {
  const warpLines = state.warps
    .map((w) => `\twarp_event ${w.x}, ${w.y}, ${w.dest}, ${w.warpId}`)
    .join("\n");
  const text =
    `\tobject_const_def\n` +
    `\t; add const_export lines here for any NPCs/signs you wire up by hand\n\n` +
    `${state.mapName}_Object:\n` +
    `\tdb ${state.borderBlock} ; border block\n\n` +
    `\tdef_warp_events\n` +
    (warpLines ? warpLines + "\n" : "") +
    `\n\tdef_bg_events\n\n` +
    `\tdef_object_events\n\n` +
    `\tdef_warps_to ${state.mapConst}\n`;
  downloadBlob(`${state.mapName}_objects.asm`, new Blob([text], { type: "text/plain" }));
});

// ---------- boot ----------
populateTilesetSelect();
renderAll();
