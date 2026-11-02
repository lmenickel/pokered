TrainerFactory_Script:
	call EnableAutoTextBoxDrawing
	ld hl, TrainerFactoryTrainerHeaders
	ld de, TrainerFactory_ScriptPointers
	ld a, [wTrainerFactoryCurScript]
	call ExecuteCurMapScriptInTable
	ld [wTrainerFactoryCurScript], a
	ret

TrainerFactory_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_TRAINERFACTORY_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_TRAINERFACTORY_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_TRAINERFACTORY_END_BATTLE

TrainerFactory_TextPointers:
	def_text_pointers
	dw_const TrainerFactoryProfOakText, TEXT_TRAINERFACTORY_PROF_OAK
	dw_const TrainerFactoryAryaText,    TEXT_TRAINERFACTORY_ARYA
	dw_const TrainerFactoryBranText,    TEXT_TRAINERFACTORY_BRAN
	dw_const TrainerFactoryRobbText,    TEXT_TRAINERFACTORY_ROBB
	dw_const TrainerFactorySansaText,   TEXT_TRAINERFACTORY_SANSA

TrainerFactoryTrainerHeaders:
	def_trainers
TrainerFactoryTrainerHeader0:
	trainer EVENT_BEAT_TRAINER_FACTORY_TRAINER_0, 4, TrainerFactoryAryaBattleText, TrainerFactoryAryaEndBattleText, TrainerFactoryAryaAfterBattleText
TrainerFactoryTrainerHeader1:
	trainer EVENT_BEAT_TRAINER_FACTORY_TRAINER_1, 4, TrainerFactoryBranBattleText, TrainerFactoryBranEndBattleText, TrainerFactoryBranAfterBattleText
TrainerFactoryTrainerHeader2:
	trainer EVENT_BEAT_TRAINER_FACTORY_TRAINER_2, 3, TrainerFactoryRobbBattleText, TrainerFactoryRobbEndBattleText, TrainerFactoryRobbAfterBattleText
TrainerFactoryTrainerHeader3:
	trainer EVENT_BEAT_TRAINER_FACTORY_TRAINER_3, 3, TrainerFactorySansaBattleText, TrainerFactorySansaEndBattleText, TrainerFactorySansaAfterBattleText
TrainerFactoryTrainerHeader4:
	trainer EVENT_BEAT_TRAINER_FACTORY_PROF_OAK, 0, TrainerFactoryProfOakBattleText, TrainerFactoryProfOakEndBattleText, TrainerFactoryProfOakAfterBattleText
	db -1 ; end

TrainerFactoryAryaText:
	text_asm
	ld hl, TrainerFactoryTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

TrainerFactoryBranText:
	text_asm
	ld hl, TrainerFactoryTrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

TrainerFactoryRobbText:
	text_asm
	ld hl, TrainerFactoryTrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

TrainerFactorySansaText:
	text_asm
	ld hl, TrainerFactoryTrainerHeader3
	call TalkToTrainer
	jp TextScriptEnd

TrainerFactoryProfOakText:
	text_asm
	ld hl, TrainerFactoryTrainerHeader4
	call TalkToTrainer
	jp TextScriptEnd

TrainerFactoryAryaBattleText:
	text_far _TrainerFactoryAryaBattleText
	text_end

TrainerFactoryAryaEndBattleText:
	text_far _TrainerFactoryAryaEndBattleText
	text_end

TrainerFactoryAryaAfterBattleText:
	text_far _TrainerFactoryAryaAfterBattleText
	text_end

TrainerFactoryBranBattleText:
	text_far _TrainerFactoryBranBattleText
	text_end

TrainerFactoryBranEndBattleText:
	text_far _TrainerFactoryBranEndBattleText
	text_end

TrainerFactoryBranAfterBattleText:
	text_far _TrainerFactoryBranAfterBattleText
	text_end

TrainerFactoryRobbBattleText:
	text_far _TrainerFactoryRobbBattleText
	text_end

TrainerFactoryRobbEndBattleText:
	text_far _TrainerFactoryRobbEndBattleText
	text_end

TrainerFactoryRobbAfterBattleText:
	text_far _TrainerFactoryRobbAfterBattleText
	text_end

TrainerFactorySansaBattleText:
	text_far _TrainerFactorySansaBattleText
	text_end

TrainerFactorySansaEndBattleText:
	text_far _TrainerFactorySansaEndBattleText
	text_end

TrainerFactorySansaAfterBattleText:
	text_far _TrainerFactorySansaAfterBattleText
	text_end

TrainerFactoryProfOakBattleText:
	text_far _TrainerFactoryProfOakBattleText
	text_end

TrainerFactoryProfOakEndBattleText:
	text_far _TrainerFactoryProfOakEndBattleText
	text_end

TrainerFactoryProfOakAfterBattleText:
	text_far _TrainerFactoryProfOakAfterBattleText
	text_end
