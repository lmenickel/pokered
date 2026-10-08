	object_const_def
	const_export ROUTE6GATE_GUARD

Route6Gate_Object:
	db $a ; border block

	def_warp_events
	warp_event  3,  5, VERMILION_FOREST, 3
	warp_event  4,  5, VERMILION_FOREST, 4
	warp_event  3,  0, SAFFRON_CITY, 10
	warp_event  4,  0, SAFFRON_CITY, 11

	def_bg_events

	def_object_events
	object_event  6,  2, SPRITE_GUARD, STAY, LEFT, TEXT_ROUTE6GATE_GUARD

	def_warps_to ROUTE_6_GATE
