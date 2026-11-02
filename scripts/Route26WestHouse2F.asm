Route26WestHouse2F_Script:
	jp EnableAutoTextBoxDrawing

Route26WestHouse2F_TextPointers:
	def_text_pointers
	dw_const Route26WestHouse2FGirlText, TEXT_ROUTE26WESTHOUSE2F_GIRL
	dw_const Route26WestHouse2FDollText, TEXT_ROUTE26WESTHOUSE2F_MONSTER_DOLL
	dw_const Route26WestHouse2FDollText, TEXT_ROUTE26WESTHOUSE2F_BIRD_DOLL
	dw_const Route26WestHouse2FDollText, TEXT_ROUTE26WESTHOUSE2F_FAIRY_DOLL
	dw_const Route26WestHouse2FSNESText, TEXT_ROUTE26WESTHOUSE2F_SNES
	dw_const Route26WestHouse2FPCText,   TEXT_ROUTE26WESTHOUSE2F_PC

Route26WestHouse2FGirlText:
	text_far _Route26WestHouse2FGirlText
	text_end

Route26WestHouse2FDollText:
	text_far _CopycatsHouse2FRareDollText
	text_end

Route26WestHouse2FSNESText:
	text_far _CopycatsHouse2FSNESText
	text_end

Route26WestHouse2FPCText:
	text_asm
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ld hl, .CantSeeText
	jr nz, .notUp
	ld hl, .MySecretsText
.notUp
	call PrintText
	jp TextScriptEnd

.MySecretsText:
	text_far _CopycatsHouse2FPCMySecretsText
	text_end

.CantSeeText:
	text_far _CopycatsHouse2FPCCantSeeText
	text_end
