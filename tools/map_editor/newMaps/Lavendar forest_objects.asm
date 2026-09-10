	object_const_def
	; add const_export lines here for any NPCs/signs you wire up by hand

Lavendar forest_Object:
	db 1 ; border block

	def_warp_events
	warp_event 1, 23, SAFFRON_CITY, 1
	warp_event 39, 23, ROUTE_8_GATE, 1

	def_bg_events

	def_object_events

	def_warps_to LAV_FOR
