	object_const_def
	const_export ROUTE8GATE_GUARD

Route8Gate_Object:
	db $a ; border block

	def_warp_events
	warp_event  0,  3, SAFFRON_CITY, 14
	warp_event  0,  4, SAFFRON_CITY, 15
	warp_event  5,  3, LAVENDER_FOREST, 3
	warp_event  5,  4, LAVENDER_FOREST, 4

	def_bg_events

	def_object_events
	object_event  2,  1, SPRITE_GUARD, STAY, DOWN, TEXT_ROUTE8GATE_GUARD

	def_warps_to ROUTE_8_GATE
