	object_const_def
	const_export BILLSLIGHTHOUSE4F_BILL

BillsLighthouse4F_Object:
	db 1 ; border block

	def_warp_events
	warp_event  7,  1, BILLS_LIGHTHOUSE_3F, 1

	def_bg_events
	bg_event  3,  5, TEXT_BILLSLIGHTHOUSE4F_TELESCOPE

	def_object_events
	object_event  2,  6, SPRITE_SUPER_NERD, STAY, UP, TEXT_BILLSLIGHTHOUSE4F_BILL

	def_warps_to BILLS_LIGHTHOUSE_4F
