Route26Pokecenter_Script:
	; Route 26 has an "indoor" map ID, so entering it never updates wLastMap.
	; Set it here so healing makes Route 26 the blackout point.
	ld a, ROUTE_26
	ld [wLastMap], a
	call Serial_TryEstablishingExternallyClockedConnection
	jp EnableAutoTextBoxDrawing

Route26Pokecenter_TextPointers:
	def_text_pointers
	dw_const Route26PokecenterNurseText,            TEXT_ROUTE26POKECENTER_NURSE
	dw_const Route26PokecenterGentlemanText,        TEXT_ROUTE26POKECENTER_GENTLEMAN
	dw_const Route26PokecenterGirlText,             TEXT_ROUTE26POKECENTER_GIRL
	dw_const Route26PokecenterYoungsterText,        TEXT_ROUTE26POKECENTER_YOUNGSTER
	dw_const Route26PokecenterLinkReceptionistText, TEXT_ROUTE26POKECENTER_LINK_RECEPTIONIST

Route26PokecenterNurseText:
	script_pokecenter_nurse

Route26PokecenterGentlemanText:
	text_far _Route26PokecenterGentlemanText
	text_end

Route26PokecenterGirlText:
	text_far _Route26PokecenterGirlText
	text_end

Route26PokecenterYoungsterText:
	text_far _Route26PokecenterYoungsterText
	text_end

Route26PokecenterLinkReceptionistText:
	script_cable_club_receptionist
