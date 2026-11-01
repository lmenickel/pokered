	object_const_def

Route26_Object:
	db $2c ; border block

	def_warp_events
	warp_event  4,  3, DARK_CAVE_2, 3 ; cave entrance down to the Dark Cave 2 ladder

	def_bg_events

	def_object_events

	def_warps_to ROUTE_26
