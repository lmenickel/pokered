	object_const_def

BillsLighthouse3F_Object:
	db 1 ; border block

	def_warp_events
	warp_event  6,  1, BILLS_LIGHTHOUSE_4F, 1
	warp_event  7,  1, BILLS_LIGHTHOUSE_2F, 1

	def_bg_events

	def_object_events

	def_warps_to BILLS_LIGHTHOUSE_3F
