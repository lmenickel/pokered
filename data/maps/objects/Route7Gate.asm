	object_const_def
	const_export ROUTE7GATE_GUARD

Route7Gate_Object:
	db $a ; border block

	def_warp_events
	warp_event  0,  3, CELADON_FOREST, 3
	warp_event  0,  4, CELADON_FOREST, 4
	warp_event  5,  3, SAFFRON_CITY, 12
	warp_event  5,  4, SAFFRON_CITY, 13

	def_bg_events

	def_object_events
	object_event  3,  1, SPRITE_GUARD, STAY, DOWN, TEXT_ROUTE7GATE_GUARD

	def_warps_to ROUTE_7_GATE
