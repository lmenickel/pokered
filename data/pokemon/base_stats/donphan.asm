	db DEX_DONPHAN ; pokedex id

	db  90, 120, 120,  50,  60
	;   hp  atk  def  spd  spc

	db GROUND, GROUND ; type
	db 60 ; catch rate
	db 148 ; base exp

	INCBIN "gfx/pokemon/front/donphan.pic", 0, 1 ; sprite dimensions
	dw DonphanPicFront, DonphanPicBack

	db TACKLE, SAND_ATTACK, GROWL, TAKE_DOWN ; level 1 learnset
	db GROWTH_FAST ; growth rate

	; tm/hm learnset
	tmhm SWORDS_DANCE, TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  \
	     SUBMISSION,   SEISMIC_TOSS, RAGE,         EARTHQUAKE,   FISSURE,      \
	     DIG,          MIMIC,        DOUBLE_TEAM,  BIDE,         SWIFT,        \
	     SKULL_BASH,   REST,         ROCK_SLIDE,   SUBSTITUTE,   CUT,          \
	     STRENGTH
	; end

	db 0 ; padding
