//------------ Directional Offsets Datum Paths ------------//
#define STANDARD_OFFSETS(_PATH) /datum/directional_offsets/standard/##_PATH
#define JEN_WALL_OFFSETS(_PATH) /datum/directional_offsets/jen_walls/##_PATH





//------------ Flags ------------//
#define FORBID_INITIAL_OFFSETS (1 << 0)
#define DOES_NOT_REQUIRE_WALL (1 << 1)





//------------ Macros ------------//
/// Set up a tuple containing directional offsets. These offsets will also be provided to the corresponding standard directional offsets datum.
#define SET_UP_DIRECTIONAL_OFFSETS(_NAME, _N, _E, _S, _W) \
	STANDARD_OFFSETS(_NAME) { \
		id = #_NAME; \
		nx = _GETTER_1 _N; \
		ny = _GETTER_2 _N; \
		ex = _GETTER_1 _E; \
		ey = _GETTER_2 _E; \
		sx = _GETTER_1 _S; \
		sy = _GETTER_2 _S; \
		wx = _GETTER_1 _W; \
		wy = _GETTER_2 _W; \
	} \
	DEFINE _NAME(x) x(_GETTER_1 _N, _GETTER_2 _N, _GETTER_1 _E, _GETTER_2 _E, _GETTER_1 _S, _GETTER_2 _S, _GETTER_1 _W, _GETTER_2 _W, #_NAME)

/// Set up another directional offsets datum that should be used under certain circumstances.
#define SET_UP_DIRECTIONAL_OFFSETS_OTHER(_PATH, _NAME, _N, _E, _S, _W) \
	_PATH(_NAME) { \
		id = #_NAME; \
		nx = _GETTER_1 _N; \
		ny = _GETTER_2 _N; \
		ex = _GETTER_1 _E; \
		ey = _GETTER_2 _E; \
		sx = _GETTER_1 _S; \
		sy = _GETTER_2 _S; \
		wx = _GETTER_1 _W; \
		wy = _GETTER_2 _W; \
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
SET_UP_DIRECTIONAL_OFFSETS(OFFSETS_CAMERA, \
	(0, 20),	\
	(10, 0),	\
	(0, 0),		\
	(-10, 0)	\
)
SET_UP_DIRECTIONAL_OFFSETS_OTHER(JEN_WALL_OFFSETS, OFFSETS_CAMERA, \
	(0, 24),	\
	(12, 0),	\
	(0, 0),		\
	(-12, 0)	\
)

SET_UP_DIRECTIONAL_OFFSETS(OFFSETS_FIREALARM, \
	(0, 30),	\
	(24, 0),	\
	(0, -22),	\
	(-24, 0)	\
)

SET_UP_DIRECTIONAL_OFFSETS(OFFSETS_NOTICEBOARD, \
	(0, 32),	\
	(32, 0),	\
	(0, 0),		\
	(-32, 0)	\
)

SET_UP_DIRECTIONAL_OFFSETS(OFFSETS_AIRALARM, \
	(0, 27),	\
	(21, 0),	\
	(0, -13),	\
	(-21, 0)	\
)

SET_UP_DIRECTIONAL_OFFSETS(OFFSETS_LIGHTSWITCH, \
	(0, 24),	\
	(24, 0),	\
	(0, -24),	\
	(-24, 0)	\
)
