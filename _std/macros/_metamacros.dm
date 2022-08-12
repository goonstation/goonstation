
// zero overhead tuple macros
// useful when you want to store multiple values in one macro
// Note that you can use other macros inside a tuple definition, see atom_properties.dm for an example
/*
Example:
#define RADIO_MEDICAL(x) x(1356, "#461B7E", "medical")

#define RADIO_GET_FREQ TUPLE_GET_1
#define RADIO_GET_COLOR TUPLE_GET_2
#define RADIO_GET_NAME TUPLE_GET_3

#define TALK_OVER_RADIO(r, msg) radio_thing.send(RADIO_GET_FREQ(r), "<span style='color:[RADIO_GET_COLOR(r)]'>[msg]</span>")
*/

#define  _GETTER_1(a, ...) a
#define  _GETTER_2(_, a, ...) a
#define  _GETTER_3(_, _, a, ...) a
#define  _GETTER_4(_, _, _, a, ...) a
#define  _GETTER_5(_, _, _, _, a, ...) a
#define  _GETTER_6(_, _, _, _, _, a, ...) a
#define  _GETTER_7(_, _, _, _, _, _, a, ...) a
#define  _GETTER_8(_, _, _, _, _, _, _, a, ...) a
#define  _GETTER_9(_, _, _, _, _, _, _, _, a, ...) a
#define _GETTER_10(_, _, _, _, _, _, _, _, _, a, ...) a

#define TUPLE_GET_1(x) x(_GETTER_1)
#define TUPLE_GET_2(x) x(_GETTER_2)
#define TUPLE_GET_3(x) x(_GETTER_3)
#define TUPLE_GET_4(x) x(_GETTER_4)
#define TUPLE_GET_5(x) x(_GETTER_5)
#define TUPLE_GET_6(x) x(_GETTER_6)
#define TUPLE_GET_7(x) x(_GETTER_7)
#define TUPLE_GET_8(x) x(_GETTER_8)
#define TUPLE_GET_9(x) x(_GETTER_9)
#define TUPLE_GET_10(x) x(_GETTER_10)

/// Useful for when you need to include in a macro, can't use #include directly due to # being interpreted as stringification
#define INCLUDE #include

/// Given x, evaluates to x.
#define IDENTITY(x) x
/// Evaluates to nothing.
#define NOTHING(...)
/// No operation dummy thing for atom property purposes, most of the stuff is there to suppress warnings, does nothing
#define DUMMY(_, _, lol, ...) ASSERT(UNLINT(lol || 1))

#define _LENGTH_GETTER(args...) _GETTER_10(##args, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
#define TUPLE_LENGTH(x) x(_LENGTH_GETTER)

#define _GETTER_1_OR_EMPTY(args...) _GETTER_1(##args, , , , , , , , , , )
#define TUPLE_GET_1_OR_EMPTY(x) x(_GETTER_1_OR_EMPTY)
#define _GETTER_2_OR_EMPTY(args...) _GETTER_2(##args, , , , , , , , , , )
#define TUPLE_GET_2_OR_EMPTY(x) x(_GETTER_2_OR_EMPTY)
#define _GETTER_3_OR_EMPTY(args...) _GETTER_3(##args, , , , , , , , , , )
#define TUPLE_GET_3_OR_EMPTY(x) x(_GETTER_3_OR_EMPTY)
#define _GETTER_4_OR_EMPTY(args...) _GETTER_4(##args, , , , , , , , , , )
#define TUPLE_GET_4_OR_EMPTY(x) x(_GETTER_4_OR_EMPTY)

#define _GETTER_1_OR_NOTHING(args...) _GETTER_1(##args, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING)
#define TUPLE_GET_1_OR_NOTHING(x) x(_GETTER_1_OR_NOTHING)
#define _GETTER_2_OR_NOTHING(args...) _GETTER_2(##args, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING)
#define TUPLE_GET_2_OR_NOTHING(x) x(_GETTER_2_OR_NOTHING)
#define _GETTER_3_OR_NOTHING(args...) _GETTER_3(##args, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING)
#define TUPLE_GET_3_OR_NOTHING(x) x(_GETTER_3_OR_NOTHING)
#define _GETTER_4_OR_NOTHING(args...) _GETTER_4(##args, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING, NOTHING)
#define TUPLE_GET_4_OR_NOTHING(x) x(_GETTER_4_OR_NOTHING)

#define _GETTER_1_OR_DUMMY(args...) _GETTER_1(##args, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY)
#define TUPLE_GET_1_OR_DUMMY(x) x(_GETTER_1_OR_DUMMY)
#define _GETTER_2_OR_DUMMY(args...) _GETTER_2(##args, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY)
#define TUPLE_GET_2_OR_DUMMY(x) x(_GETTER_2_OR_DUMMY)
#define _GETTER_3_OR_DUMMY(args...) _GETTER_3(##args, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY)
#define TUPLE_GET_3_OR_DUMMY(x) x(_GETTER_3_OR_DUMMY)
#define _GETTER_4_OR_DUMMY(args...) _GETTER_4(##args, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY)
#define TUPLE_GET_4_OR_DUMMY(x) x(_GETTER_4_OR_DUMMY)
