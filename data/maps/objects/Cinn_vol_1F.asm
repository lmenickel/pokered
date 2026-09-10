	object_const_def

Cinn_vol_1F_Object:
	db 1 ; border block

	def_warp_events
	warp_event 19,  1, CINN_VOL_TF, 1 ; ladder up to the crater (top-middle)
	warp_event 31, 29, CINN_VOL_BF, 1 ; ladder down to the basement (bottom-right)
	warp_event  3, 31, ROUTE_20, 3 ; entrance from Route 20 (bottom-left nook)

	def_bg_events

	def_object_events

	def_warps_to CINN_VOL_1F
