	object_const_def

BillsLighthouse1F_Object:
	db 1 ; border block

	def_warp_events
	warp_event  4, 11, LAST_MAP, 1
	warp_event  5, 11, LAST_MAP, 1
	warp_event  7,  1, BILLS_LIGHTHOUSE_2F, 2

	def_bg_events

	def_object_events

	def_warps_to BILLS_LIGHTHOUSE_1F
