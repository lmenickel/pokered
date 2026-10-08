	object_const_def
	const_export CERULEANFORESTGATE_GUARD

CeruleanForestGate_Object:
	db $a ; border block

	def_warp_events
	warp_event  3,  5, CERULEAN_FOREST, 1
	warp_event  4,  5, CERULEAN_FOREST, 2
	warp_event  3,  0, ROUTE_5, 2
	warp_event  4,  0, ROUTE_5, 1

	def_bg_events

	def_object_events
	object_event  1,  3, SPRITE_GUARD, STAY, RIGHT, TEXT_CERULEANFORESTGATE_GUARD

	def_warps_to CERULEAN_FOREST_GATE
