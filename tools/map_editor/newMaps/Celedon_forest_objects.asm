	object_const_def
	; add const_export lines here for any NPCs/signs you wire up by hand

Celedon_forest_Object:
	db 1 ; border block

	def_warp_events
	warp_event 1, 23, SAFFRON_CITY, 2
	warp_event 39, 23, ROUTE_7_GATE, 1

	def_bg_events

	def_object_events

	def_warps_to Cel_FOR
