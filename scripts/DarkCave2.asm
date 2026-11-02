DarkCave2_Script:
	call EnableAutoTextBoxDrawing
	ld hl, DarkCave2TrainerHeaders
	ld de, DarkCave2_ScriptPointers
	ld a, [wDarkCave2CurScript]
	call ExecuteCurMapScriptInTable
	ld [wDarkCave2CurScript], a
	ret

DarkCave2_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_DARKCAVE2_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_DARKCAVE2_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_DARKCAVE2_END_BATTLE

DarkCave2_TextPointers:
	def_text_pointers
	dw_const DarkCave2SuperNerd1Text, TEXT_DARKCAVE2_SUPER_NERD1
	dw_const DarkCave2SuperNerd2Text, TEXT_DARKCAVE2_SUPER_NERD2
	dw_const DarkCave2HikerText,      TEXT_DARKCAVE2_HIKER
	dw_const DarkCave2PokemaniacText, TEXT_DARKCAVE2_POKEMANIAC

DarkCave2TrainerHeaders:
	def_trainers
DarkCave2TrainerHeader0:
	trainer EVENT_BEAT_DARK_CAVE_2_TRAINER_0, 3, DarkCave2SuperNerd1BattleText, DarkCave2SuperNerd1EndBattleText, DarkCave2SuperNerd1AfterBattleText
DarkCave2TrainerHeader1:
	trainer EVENT_BEAT_DARK_CAVE_2_TRAINER_1, 3, DarkCave2SuperNerd2BattleText, DarkCave2SuperNerd2EndBattleText, DarkCave2SuperNerd2AfterBattleText
DarkCave2TrainerHeader2:
	trainer EVENT_BEAT_DARK_CAVE_2_TRAINER_2, 3, DarkCave2HikerBattleText, DarkCave2HikerEndBattleText, DarkCave2HikerAfterBattleText
DarkCave2TrainerHeader3:
	trainer EVENT_BEAT_DARK_CAVE_2_TRAINER_3, 3, DarkCave2PokemaniacBattleText, DarkCave2PokemaniacEndBattleText, DarkCave2PokemaniacAfterBattleText
	db -1 ; end

DarkCave2SuperNerd1Text:
	text_asm
	ld hl, DarkCave2TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

DarkCave2SuperNerd2Text:
	text_asm
	ld hl, DarkCave2TrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

DarkCave2HikerText:
	text_asm
	ld hl, DarkCave2TrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

DarkCave2PokemaniacText:
	text_asm
	ld hl, DarkCave2TrainerHeader3
	call TalkToTrainer
	jp TextScriptEnd

DarkCave2SuperNerd1BattleText:
	text_far _DarkCave2SuperNerd1BattleText
	text_end

DarkCave2SuperNerd1EndBattleText:
	text_far _DarkCave2SuperNerd1EndBattleText
	text_end

DarkCave2SuperNerd1AfterBattleText:
	text_far _DarkCave2SuperNerd1AfterBattleText
	text_end

DarkCave2SuperNerd2BattleText:
	text_far _DarkCave2SuperNerd2BattleText
	text_end

DarkCave2SuperNerd2EndBattleText:
	text_far _DarkCave2SuperNerd2EndBattleText
	text_end

DarkCave2SuperNerd2AfterBattleText:
	text_far _DarkCave2SuperNerd2AfterBattleText
	text_end

DarkCave2HikerBattleText:
	text_far _DarkCave2HikerBattleText
	text_end

DarkCave2HikerEndBattleText:
	text_far _DarkCave2HikerEndBattleText
	text_end

DarkCave2HikerAfterBattleText:
	text_far _DarkCave2HikerAfterBattleText
	text_end

DarkCave2PokemaniacBattleText:
	text_far _DarkCave2PokemaniacBattleText
	text_end

DarkCave2PokemaniacEndBattleText:
	text_far _DarkCave2PokemaniacEndBattleText
	text_end

DarkCave2PokemaniacAfterBattleText:
	text_far _DarkCave2PokemaniacAfterBattleText
	text_end
