	object_const_def
	const_export CELADONFORESTGATE_GUARD

CeladonForestGate_Object:
	db $a ; border block

	def_warp_events
	warp_event  0,  3, ROUTE_7, 4
	warp_event  0,  4, ROUTE_7, 4
	warp_event  5,  3, CELADON_FOREST, 1
	warp_event  5,  4, CELADON_FOREST, 2

	def_bg_events

	def_object_events
	object_event  3,  1, SPRITE_GUARD, STAY, DOWN, TEXT_CELADONFORESTGATE_GUARD

	def_warps_to CELADON_FOREST_GATE
