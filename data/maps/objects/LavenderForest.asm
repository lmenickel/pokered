	object_const_def

LavenderForest_Object:
	db 2 ; border block

	def_warp_events
	warp_event 39, 22, LAVENDER_FOREST_GATE, 1
	warp_event 39, 23, LAVENDER_FOREST_GATE, 2
	warp_event  0, 22, ROUTE_8_GATE, 3
	warp_event  0, 23, ROUTE_8_GATE, 4

	def_bg_events

	def_object_events

	def_warps_to LAVENDER_FOREST
