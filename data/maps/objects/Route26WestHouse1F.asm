	object_const_def
	const_export ROUTE26WESTHOUSE1F_MOM
	const_export ROUTE26WESTHOUSE1F_DAD
	const_export ROUTE26WESTHOUSE1F_CLEFABLE

Route26WestHouse1F_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, ROUTE_26, 4
	warp_event  3,  7, ROUTE_26, 4
	warp_event  7,  1, ROUTE_26_WEST_HOUSE_2F, 1

	def_bg_events
	bg_event  3,  1, TEXT_ROUTE26WESTHOUSE1F_TV

	def_object_events
	object_event  2,  2, SPRITE_MIDDLE_AGED_WOMAN, STAY, DOWN, TEXT_ROUTE26WESTHOUSE1F_MOM
	object_event  5,  4, SPRITE_MIDDLE_AGED_MAN, STAY, LEFT, TEXT_ROUTE26WESTHOUSE1F_DAD
	object_event  1,  4, SPRITE_FAIRY, WALK, UP_DOWN, TEXT_ROUTE26WESTHOUSE1F_CLEFABLE

	def_warps_to ROUTE_26_WEST_HOUSE_1F
