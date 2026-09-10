	db DEX_MARILL ; pokedex id

	db  70,  20,  50,  40,  50
	;   hp  atk  def  spd  spc

	db WATER, FAIRY ; type
	db 190 ; catch rate
	db 66 ; base exp

	INCBIN "gfx/pokemon/front/marill.pic", 0, 1 ; sprite dimensions
	dw MarillPicFront, MarillPicBack

	db TACKLE, TAIL_WHIP, WATER_GUN, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  BUBBLEBEAM,   \
	     WATER_GUN,    ICE_BEAM,     BLIZZARD,     RAGE,         MIMIC,        \
	     DOUBLE_TEAM,  BIDE,         REST,         SUBSTITUTE,   SURF
	; end

	db 0 ; padding
