	object_const_def
	const_export ROUTE26RESTHOUSE_BRUNETTE_GIRL

Route26RestHouse_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, ROUTE_26, 3
	warp_event  3,  7, ROUTE_26, 3

	def_bg_events
	bg_event  5,  1, TEXT_ROUTE26RESTHOUSE_BOOKCASE
	bg_event  6,  1, TEXT_ROUTE26RESTHOUSE_BOOKCASE
	bg_event  7,  1, TEXT_ROUTE26RESTHOUSE_BOOKCASE

	def_object_events
	object_event  3,  5, SPRITE_BRUNETTE_GIRL, STAY, UP, TEXT_ROUTE26RESTHOUSE_BRUNETTE_GIRL

	def_warps_to ROUTE_26_REST_HOUSE
