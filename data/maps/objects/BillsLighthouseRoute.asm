	object_const_def

BillsLighthouseRoute_Object:
	db $f ; border block (trees)

	def_warp_events
	warp_event 23,  9, BILLS_LIGHTHOUSE_1F, 4 ; lighthouse door
	warp_event  3, 16, BILLS_HOUSE, 4 ; behind the little house: arrive here from Bill's back door, walk down into the roof to go back in

	def_bg_events

	def_object_events

	def_warps_to BILLS_LIGHTHOUSE_ROUTE
