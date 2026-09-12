	db DEX_SUDOWOODO ; pokedex id

	db  70, 100, 115,  30,  55
	;   hp  atk  def  spd  spc

	db ROCK, ROCK ; type
	db 65 ; catch rate
	db 88 ; base exp

	INCBIN "gfx/pokemon/front/sudowoodo.pic", 0, 1 ; sprite dimensions
	dw SudowoodoPicFront, SudowoodoPicBack

	db TACKLE, SAND_ATTACK, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  RAGE,         \
	     EARTHQUAKE,   DIG,          MIMIC,        DOUBLE_TEAM,                \
	     BIDE,         SKULL_BASH,   REST,         ROCK_SLIDE,   SUBSTITUTE,   \
	     STRENGTH
	; end

	db 0 ; padding
