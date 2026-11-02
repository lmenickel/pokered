Route26_Script:
	call EnableAutoTextBoxDrawing
	ld hl, Route26TrainerHeaders
	ld de, Route26_ScriptPointers
	ld a, [wRoute26CurScript]
	call ExecuteCurMapScriptInTable
	ld [wRoute26CurScript], a
	ret

Route26_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_ROUTE26_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_ROUTE26_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_ROUTE26_END_BATTLE

Route26_TextPointers:
	def_text_pointers
	dw_const Route26HikerText,      TEXT_ROUTE26_HIKER
	dw_const Route26FisherText,     TEXT_ROUTE26_FISHER
	dw_const Route26BirdKeeperText, TEXT_ROUTE26_BIRD_KEEPER

Route26TrainerHeaders:
	def_trainers
Route26TrainerHeader0:
	trainer EVENT_BEAT_ROUTE_26_TRAINER_0, 4, Route26HikerBattleText, Route26HikerEndBattleText, Route26HikerAfterBattleText
Route26TrainerHeader1:
	trainer EVENT_BEAT_ROUTE_26_TRAINER_1, 4, Route26FisherBattleText, Route26FisherEndBattleText, Route26FisherAfterBattleText
Route26TrainerHeader2:
	trainer EVENT_BEAT_ROUTE_26_TRAINER_2, 4, Route26BirdKeeperBattleText, Route26BirdKeeperEndBattleText, Route26BirdKeeperAfterBattleText
	db -1 ; end

Route26HikerText:
	text_asm
	ld hl, Route26TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

Route26FisherText:
	text_asm
	ld hl, Route26TrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

Route26BirdKeeperText:
	text_asm
	ld hl, Route26TrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

Route26HikerBattleText:
	text_far _Route26HikerBattleText
	text_end

Route26HikerEndBattleText:
	text_far _Route26HikerEndBattleText
	text_end

Route26HikerAfterBattleText:
	text_far _Route26HikerAfterBattleText
	text_end

Route26FisherBattleText:
	text_far _Route26FisherBattleText
	text_end

Route26FisherEndBattleText:
	text_far _Route26FisherEndBattleText
	text_end

Route26FisherAfterBattleText:
	text_far _Route26FisherAfterBattleText
	text_end

Route26BirdKeeperBattleText:
	text_far _Route26BirdKeeperBattleText
	text_end

Route26BirdKeeperEndBattleText:
	text_far _Route26BirdKeeperEndBattleText
	text_end

Route26BirdKeeperAfterBattleText:
	text_far _Route26BirdKeeperAfterBattleText
	text_end
