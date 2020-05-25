
// zero overhead tuple macros
// useful when you want to store multiple values in one macro
// Note that you can use other macros inside a tuple definition, see mob_properties.dm for an example
/*
Example:
#define RADIO_MEDICAL(x) x(1356, "#461B7E", "medical")

#define RADIO_GET_FREQ TRIPLE_GET_1
#define RADIO_GET_COLOR TRIPLE_GET_2
#define RADIO_GET_NAME TRIPLE_GET_3

#define TALK_OVER_RADIO(r, msg) radio_thing.send(RADIO_GET_FREQ(r), "<span style='color:[RADIO_GET_COLOR(r)]'>[msg]</span>")
*/

#define _GETTER_PAIR_1(a1, a2) a1
#define _GETTER_PAIR_2(a1, a2) a2

#define GET_PAIR_1(x) x(_GETTER_PAIR_1)
#define GET_PAIR_2(x) x(_GETTER_PAIR_2)


#define _GETTER_TRIPLE_1(a1, a2, a3) a1
#define _GETTER_TRIPLE_2(a1, a2, a3) a2
#define _GETTER_TRIPLE_3(a1, a2, a3) a3

#define GET_TRIPLE_1(x) x(_GETTER_TRIPLE_1)
#define GET_TRIPLE_2(x) x(_GETTER_TRIPLE_2)
#define GET_TRIPLE_3(x) x(_GETTER_TRIPLE_3)


#define _GETTER_4TUPLE_1(a1, a2, a3, a4) a1
#define _GETTER_4TUPLE_2(a1, a2, a3, a4) a2
#define _GETTER_4TUPLE_3(a1, a2, a3, a4) a3
#define _GETTER_4TUPLE_4(a1, a2, a3, a4) a4

#define GET_4TUPLE_1(x) x(_GETTER_4TUPLE_1)
#define GET_4TUPLE_2(x) x(_GETTER_4TUPLE_2)
#define GET_4TUPLE_3(x) x(_GETTER_4TUPLE_3)
#define GET_4TUPLE_4(x) x(_GETTER_4TUPLE_4)


#define _GETTER_5TUPLE_1(a1, a2, a3, a4, a5) a1
#define _GETTER_5TUPLE_2(a1, a2, a3, a4, a5) a2
#define _GETTER_5TUPLE_3(a1, a2, a3, a4, a5) a3
#define _GETTER_5TUPLE_4(a1, a2, a3, a4, a5) a4
#define _GETTER_5TUPLE_5(a1, a2, a3, a4, a5) a5

#define GET_5TUPLE_1(x) x(_GETTER_5TUPLE_1)
#define GET_5TUPLE_2(x) x(_GETTER_5TUPLE_2)
#define GET_5TUPLE_3(x) x(_GETTER_5TUPLE_3)
#define GET_5TUPLE_4(x) x(_GETTER_5TUPLE_4)
#define GET_5TUPLE_5(x) x(_GETTER_5TUPLE_5)


#define _GETTER_6TUPLE_1(a1, a2, a3, a4, a5, a6) a1
#define _GETTER_6TUPLE_2(a1, a2, a3, a4, a5, a6) a2
#define _GETTER_6TUPLE_3(a1, a2, a3, a4, a5, a6) a3
#define _GETTER_6TUPLE_4(a1, a2, a3, a4, a5, a6) a4
#define _GETTER_6TUPLE_5(a1, a2, a3, a4, a5, a6) a5
#define _GETTER_6TUPLE_6(a1, a2, a3, a4, a5, a6) a6

#define GET_6TUPLE_1(x) x(_GETTER_6TUPLE_1)
#define GET_6TUPLE_2(x) x(_GETTER_6TUPLE_2)
#define GET_6TUPLE_3(x) x(_GETTER_6TUPLE_3)
#define GET_6TUPLE_4(x) x(_GETTER_6TUPLE_4)
#define GET_6TUPLE_5(x) x(_GETTER_6TUPLE_5)
#define GET_6TUPLE_6(x) x(_GETTER_6TUPLE_6)
