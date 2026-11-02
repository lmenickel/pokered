Route26House_Script:
	jp EnableAutoTextBoxDrawing

Route26House_TextPointers:
	def_text_pointers
	dw_const Route26HouseGrampsText,    TEXT_ROUTE26HOUSE_GRAMPS
	dw_const Route26HouseSkarmoryText,  TEXT_ROUTE26HOUSE_SKARMORY
	dw_const Route26HouseClipboardText, TEXT_ROUTE26HOUSE_CLIPBOARD

Route26HouseGrampsText:
	text_far _Route26HouseGrampsText
	text_end

Route26HouseSkarmoryText:
	text_asm
	ld hl, .Text
	call PrintText
	ld a, SKARMORY
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd

.Text:
	text_far _Route26HouseSkarmoryText
	text_end

Route26HouseClipboardText:
	text_far _Route26HouseClipboardText
	text_end
