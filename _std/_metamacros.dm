
// zero overhead tuple macros
// useful when you want to store multiple values in one macro
// Note that you can use other macros inside a tuple definition, see mob_properties.dm for an example
/*
Example:
#define RADIO_MEDICAL(x) x(1356, "#461B7E", "medical")

#define RADIO_GET_FREQ TUPLE_GET_1
#define RADIO_GET_COLOR TUPLE_GET_2
#define RADIO_GET_NAME TUPLE_GET_3

#define TALK_OVER_RADIO(r, msg) radio_thing.send(RADIO_GET_FREQ(r), "<span style='color:[RADIO_GET_COLOR(r)]'>[msg]</span>")
*/

#define _GETTER_1(a, ...) a
#define _GETTER_2(_, a, ...) a
#define _GETTER_3(_, _, a, ...) a
#define _GETTER_4(_, _, _, a, ...) a
#define _GETTER_5(_, _, _, _, a, ...) a
#define _GETTER_6(_, _, _, _, _, a, ...) a
#define _GETTER_7(_, _, _, _, _, _, a, ...) a
#define _GETTER_8(_, _, _, _, _, _, _, a, ...) a

#define TUPLE_GET_1(x) x(_GETTER_1)
#define TUPLE_GET_2(x) x(_GETTER_2)
#define TUPLE_GET_3(x) x(_GETTER_3)
#define TUPLE_GET_4(x) x(_GETTER_4)
#define TUPLE_GET_5(x) x(_GETTER_5)
#define TUPLE_GET_6(x) x(_GETTER_6)
#define TUPLE_GET_7(x) x(_GETTER_7)
#define TUPLE_GET_8(x) x(_GETTER_8)


#define IDENTITY(x) x
#define NOTHING(x)
