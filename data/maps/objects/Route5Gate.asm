	object_const_def
	const_export ROUTE5GATE_GUARD

Route5Gate_Object:
	db $a ; border block

	def_warp_events
	warp_event  3,  5, SAFFRON_CITY, 9
	warp_event  4,  5, SAFFRON_CITY, 9
	warp_event  3,  0, CERULEAN_FOREST, 3
	warp_event  4,  0, CERULEAN_FOREST, 4

	def_bg_events

	def_object_events
	object_event  1,  3, SPRITE_GUARD, STAY, RIGHT, TEXT_ROUTE5GATE_GUARD

	def_warps_to ROUTE_5_GATE
