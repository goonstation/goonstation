#ifdef SECRETS_ENABLED
INCLUDE_MAP("../../+secret/maps/warc/gehenna_colony.dmm")
#else
INCLUDE_MAP("../warwip/gehenna.dmm")
#endif
#ifndef GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW
INCLUDE_MAP("../z2.dmm")
INCLUDE_MAP("../warwip/z3_gehenna.dmm")
#include "z4.dm"
INCLUDE_MAP("../z5.dmm")
#endif
#define MAP_MODE "standard"
