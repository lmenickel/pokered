	object_const_def
	const_export LAVENDERFORESTGATE_GUARD

LavenderForestGate_Object:
	db $a ; border block

	def_warp_events
	warp_event  0,  3, LAVENDER_FOREST, 1
	warp_event  0,  4, LAVENDER_FOREST, 2
	warp_event  5,  3, ROUTE_8, 3
	warp_event  5,  4, ROUTE_8, 4

	def_bg_events

	def_object_events
	object_event  2,  1, SPRITE_GUARD, STAY, DOWN, TEXT_LAVENDERFORESTGATE_GUARD

	def_warps_to LAVENDER_FOREST_GATE
