	object_const_def
	const_export BILLSHOUSE_BILL_POKEMON
	const_export BILLSHOUSE_BILL1
	const_export BILLSHOUSE_BILL2

BillsHouse_Object:
	db $d ; border block

	def_warp_events
	warp_event  2,  7, ROUTE_25, 1
	warp_event  3,  7, ROUTE_25, 1
	warp_event  9,  0, BILLS_LIGHTHOUSE_ROUTE, 2 ; back door (top right)
	warp_event  8,  1, BILLS_LIGHTHOUSE_ROUTE, 2 ; arrival from the route, beside the back door (not on the map edge)

	def_bg_events

	def_object_events
	object_event  6,  5, SPRITE_MONSTER, STAY, NONE, TEXT_BILLSHOUSE_BILL_POKEMON
	object_event  4,  4, SPRITE_SUPER_NERD, STAY, NONE, TEXT_BILLSHOUSE_BILL_SS_TICKET
	object_event  6,  5, SPRITE_SUPER_NERD, STAY, NONE, TEXT_BILLSHOUSE_BILL_CHECK_OUT_MY_RARE_POKEMON

	def_warps_to BILLS_HOUSE
