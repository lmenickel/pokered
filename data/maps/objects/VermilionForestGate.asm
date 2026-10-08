	object_const_def
	const_export VERMILIONFORESTGATE_GUARD

VermilionForestGate_Object:
	db $a ; border block

	def_warp_events
	warp_event  3,  5, ROUTE_6, 3
	warp_event  4,  5, ROUTE_6, 3
	warp_event  3,  0, VERMILION_FOREST, 1
	warp_event  4,  0, VERMILION_FOREST, 2

	def_bg_events

	def_object_events
	object_event  6,  2, SPRITE_GUARD, STAY, LEFT, TEXT_VERMILIONFORESTGATE_GUARD

	def_warps_to VERMILION_FOREST_GATE
