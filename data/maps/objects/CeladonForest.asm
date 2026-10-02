	object_const_def

CeladonForest_Object:
	db 2 ; border block

	def_warp_events
	warp_event  0, 22, CELADON_FOREST_GATE, 3
	warp_event  0, 23, CELADON_FOREST_GATE, 4
	warp_event 39, 22, ROUTE_7_GATE, 1
	warp_event 39, 23, ROUTE_7_GATE, 2

	def_bg_events

	def_object_events

	def_warps_to CELADON_FOREST
