	object_const_def
	const_export ROUTE26HOUSE_GRAMPS
	const_export ROUTE26HOUSE_SKARMORY
	const_export ROUTE26HOUSE_CLIPBOARD

Route26House_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, ROUTE_26, 2
	warp_event  3,  7, ROUTE_26, 2

	def_bg_events

	def_object_events
	object_event  5,  3, SPRITE_GRAMPS, STAY, DOWN, TEXT_ROUTE26HOUSE_GRAMPS
	object_event  3,  5, SPRITE_BIRD, WALK, LEFT_RIGHT, TEXT_ROUTE26HOUSE_SKARMORY
	object_event  4,  0, SPRITE_CLIPBOARD, STAY, NONE, TEXT_ROUTE26HOUSE_CLIPBOARD

	def_warps_to ROUTE_26_HOUSE
