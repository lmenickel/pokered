Route26EastHouse2F_Script:
	jp EnableAutoTextBoxDrawing

Route26EastHouse2F_TextPointers:
	def_text_pointers
	dw_const Route26EastHouse2FGirlText, TEXT_ROUTE26EASTHOUSE2F_GIRL
	dw_const Route26EastHouse2FDollText, TEXT_ROUTE26EASTHOUSE2F_MONSTER_DOLL
	dw_const Route26EastHouse2FDollText, TEXT_ROUTE26EASTHOUSE2F_BIRD_DOLL
	dw_const Route26EastHouse2FDollText, TEXT_ROUTE26EASTHOUSE2F_FAIRY_DOLL
	dw_const Route26EastHouse2FSNESText, TEXT_ROUTE26EASTHOUSE2F_SNES
	dw_const Route26EastHouse2FPCText,   TEXT_ROUTE26EASTHOUSE2F_PC

Route26EastHouse2FGirlText:
	text_far _Route26EastHouse2FGirlText
	text_end

Route26EastHouse2FDollText:
	text_far _CopycatsHouse2FRareDollText
	text_end

Route26EastHouse2FSNESText:
	text_far _CopycatsHouse2FSNESText
	text_end

Route26EastHouse2FPCText:
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
