// TODO: Does this even work anymore??
INCLUDE_MAP("../unused/construction_shuttle.dmm", /datum/zlevel/main/station)
#ifndef GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW
#include "z2.dm"
INCLUDE_MAP("../z3.dmm", /datum/zlevel/debris/space)
INCLUDE_MAP("../z5.dmm", /datum/zlevel/mining/space)
#endif
#define MAP_MODE "construction"
