Route26RestHouse_Script:
	jp EnableAutoTextBoxDrawing

Route26RestHouse_TextPointers:
	def_text_pointers
	dw_const Route26RestHouseBrunetteGirlText, TEXT_ROUTE26RESTHOUSE_BRUNETTE_GIRL
	dw_const Route26RestHouseBookcaseText,     TEXT_ROUTE26RESTHOUSE_BOOKCASE

Route26RestHouseBrunetteGirlText:
	text_asm
	ld hl, .TakeARestText
	call PrintText
	call GBFadeOutToWhite
	call ReloadMapData
	predef HealParty
	ld a, MUSIC_PKMN_HEALED
	ld [wNewSoundID], a
	call PlaySound
.wait
	ld a, [wChannelSoundIDs]
	cp MUSIC_PKMN_HEALED
	jr z, .wait
	ld a, [wMapMusicSoundID]
	ld [wNewSoundID], a
	call PlaySound
	call GBFadeInFromWhite
	jp TextScriptEnd

.TakeARestText:
	text_far _Route26RestHouseBrunetteGirlText
	text_end

Route26RestHouseBookcaseText:
	text_far _Route26RestHouseBookcaseText
	text_end
