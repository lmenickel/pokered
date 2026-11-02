	object_const_def
	const_export ROUTE26_HIKER
	const_export ROUTE26_FISHER
	const_export ROUTE26_BIRD_KEEPER

Route26_Object:
	db $2c ; border block

	def_warp_events
	warp_event  4,  3, DARK_CAVE_2, 3 ; cave entrance down to the Dark Cave 2 ladder
	warp_event 83,  3, ROUTE_26_HOUSE, 1 ; small house across the water
	warp_event 39,  3, ROUTE_26_REST_HOUSE, 1 ; small house where you can rest
	warp_event 51,  5, ROUTE_26_WEST_HOUSE_1F, 1 ; left two-story house
	warp_event 77, 11, ROUTE_26_EAST_HOUSE_1F, 1 ; right two-story house
	warp_event 66, 11, TRAINER_FACTORY, 1
	warp_event 11,  5, ROUTE_26_POKECENTER, 1

	def_bg_events

	def_object_events
	object_event 28, 11, SPRITE_HIKER, STAY, LEFT, TEXT_ROUTE26_HIKER, OPP_HIKER, 16
	object_event 53,  6, SPRITE_FISHER, STAY, LEFT, TEXT_ROUTE26_FISHER, OPP_FISHER, 12
	object_event 48, 15, SPRITE_COOLTRAINER_M, STAY, LEFT, TEXT_ROUTE26_BIRD_KEEPER, OPP_BIRD_KEEPER, 18

	def_warps_to ROUTE_26
