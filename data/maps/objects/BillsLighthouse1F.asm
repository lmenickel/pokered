	object_const_def

BillsLighthouse1F_Object:
	db $f ; border block

	def_warp_events
	warp_event  4, 11, BILLS_LIGHTHOUSE_ROUTE, 1
	warp_event  5, 11, BILLS_LIGHTHOUSE_ROUTE, 1
	warp_event  7,  1, BILLS_LIGHTHOUSE_2F, 2
	warp_event  4, 10, BILLS_LIGHTHOUSE_ROUTE, 1 ; arrival from the route, one tile inside so the exit step works

	def_bg_events

	def_object_events

	def_warps_to BILLS_LIGHTHOUSE_1F
