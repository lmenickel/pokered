	object_const_def

CeruleanForest_Object:
	db 2 ; border block

	def_warp_events
	warp_event 18,  0, CERULEAN_FOREST_GATE, 1
	warp_event 19,  0, CERULEAN_FOREST_GATE, 2
	warp_event 18, 45, ROUTE_5_GATE, 3
	warp_event 19, 45, ROUTE_5_GATE, 4

	def_bg_events

	def_object_events

	def_warps_to CERULEAN_FOREST
