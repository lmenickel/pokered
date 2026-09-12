	object_const_def
	; add const_export lines here for any NPCs/signs you wire up by hand

Vermilion_forest_Object:
	db 1 ; border block

	def_warp_events
	warp_event 18, 1, ROUTE_5_GATE, 1
	warp_event 18, 44, SAFFRON_CITY, 1

	def_bg_events

	def_object_events

	def_warps_to Ver_for
