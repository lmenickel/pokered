	object_const_def

DarkCave2_Object:
	db $3 ; border block

	def_warp_events
	warp_event 12, 19, ROUTE_22, 2 ; bottom exit to the Route 22 cave entrance
	warp_event 13, 19, ROUTE_22, 2
	warp_event 12,  2, ROUTE_26, 1 ; ladder up to Route 26

	def_bg_events

	def_object_events

	def_warps_to DARK_CAVE_2
