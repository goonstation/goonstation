//------------ Directional Offsets Datum Paths ------------//
#define STANDARD_OFFSETS(_PATH) /datum/directional_offsets/standard/##_PATH
#define JEN_WALL_OFFSETS(_PATH) /datum/directional_offsets/jen_walls/##_PATH





//------------ Flags ------------//
#define FORBID_INITIAL_OFFSETS (1 << 0)
#define DOES_NOT_REQUIRE_WALL (1 << 1)





//------------ Macros ------------//
/// Set up a tuple containing directional offsets. These offsets will also be provided to the corresponding standard directional offsets datum.
#define SET_UP_STANDARD_DIRECTIONAL_OFFSETS(_NAME, _NX, _NY, _EX, _EY, _SX, _SY, _WX, _WY) \
	STANDARD_OFFSETS(_NAME) { \
		id = #_NAME; \
		nx = _NX; \
		ny = _NY; \
		ex = _EX; \
		ey = _EY; \
		sx = _SX; \
		sy = _SY; \
		wx = _WX; \
		wy = _WY; \
	} \
	DEFINE _NAME(x) x(_NX, _NY, _EX, _EY, _SX, _SY, _WX, _WY, #_NAME)

/// Set up another directional offsets datum that should be used under certain circumstances.
#define SET_UP_OTHER_DIRECTIONAL_OFFSETS(_NAME, _PATH, _NX, _NY, _EX, _EY, _SX, _SY, _WX, _WY) \
	_PATH(_NAME) { \
		id = #_NAME; \
		nx = _NX; \
		ny = _NY; \
		ex = _EX; \
		ey = _EY; \
		sx = _SX; \
		sy = _SY; \
		wx = _WX; \
		wy = _WY; \
	}

/// Set up directional paths for an object, with offsets provided by an offsets tuple.
#define SET_UP_DIRECTIONALS(_PATH, _OFFSETS, _ARGS...) \
	##_PATH/directional/New() { \
		. = ..(); \
		src.AddComponent(/datum/component/directional, TUPLE_GET_9(_OFFSETS), _ARGS); \
	} \
	##_PATH/directional/north { \
		dir = NORTH; \
		pixel_x = TUPLE_GET_1(_OFFSETS); \
		pixel_y = TUPLE_GET_2(_OFFSETS); \
	} \
	##_PATH/directional/east { \
		dir = EAST; \
		pixel_x = TUPLE_GET_3(_OFFSETS); \
		pixel_y = TUPLE_GET_4(_OFFSETS); \
	} \
	##_PATH/directional/south { \
		dir = SOUTH; \
		pixel_x = TUPLE_GET_5(_OFFSETS); \
		pixel_y = TUPLE_GET_6(_OFFSETS); \
	} \
	##_PATH/directional/west { \
		dir = WEST; \
		pixel_x = TUPLE_GET_7(_OFFSETS); \
		pixel_y = TUPLE_GET_8(_OFFSETS); \
	}





//------------ Directional Offsets ------------//
SET_UP_STANDARD_DIRECTIONAL_OFFSETS(OFFSETS_CAMERA, 0, 20, 10, 0, 0, 0, -10, 0)
SET_UP_OTHER_DIRECTIONAL_OFFSETS(OFFSETS_CAMERA, JEN_WALL_OFFSETS, 0, 24, 12, 0, 0, 0, -12, 0)

SET_UP_STANDARD_DIRECTIONAL_OFFSETS(OFFSETS_FIREALARM, 0, 30, 24, 0, 0, -22, -24, 0)

SET_UP_STANDARD_DIRECTIONAL_OFFSETS(OFFSETS_NOTICEBOARD, 0, 32, 32, 0, 0, 0, -32, 0)
