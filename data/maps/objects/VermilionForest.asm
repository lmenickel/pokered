	object_const_def

VermilionForest_Object:
	db 2 ; border block

	def_warp_events
	warp_event 18, 45, VERMILION_FOREST_GATE, 3
	warp_event 19, 45, VERMILION_FOREST_GATE, 4
	warp_event 18,  0, ROUTE_6_GATE, 1
	warp_event 19,  0, ROUTE_6_GATE, 2

	def_bg_events

	def_object_events

	def_warps_to VERMILION_FOREST
