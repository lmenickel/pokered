	object_const_def
	const_export DARKCAVE2_SUPER_NERD1
	const_export DARKCAVE2_SUPER_NERD2
	const_export DARKCAVE2_HIKER
	const_export DARKCAVE2_POKEMANIAC

DarkCave2_Object:
	db $3 ; border block

	def_warp_events
	warp_event 12, 19, ROUTE_22, 2 ; bottom exit to the Route 22 cave entrance
	warp_event 13, 19, ROUTE_22, 2
	warp_event 12,  2, ROUTE_26, 1 ; ladder up to Route 26

	def_bg_events

	def_object_events
	object_event  5,  7, SPRITE_SUPER_NERD, STAY, LEFT, TEXT_DARKCAVE2_SUPER_NERD1, OPP_SUPER_NERD, 13
	object_event 16,  5, SPRITE_SUPER_NERD, STAY, UP, TEXT_DARKCAVE2_SUPER_NERD2, OPP_SUPER_NERD, 14
	object_event  6, 14, SPRITE_HIKER, STAY, DOWN, TEXT_DARKCAVE2_HIKER, OPP_HIKER, 15
	object_event 18, 14, SPRITE_SUPER_NERD, STAY, DOWN, TEXT_DARKCAVE2_POKEMANIAC, OPP_POKEMANIAC, 8

	def_warps_to DARK_CAVE_2
