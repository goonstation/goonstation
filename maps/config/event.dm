#ifdef SECRETS_ENABLED
INCLUDE_MAP("../../+secret/maps/midsummer.dmm", /datum/zlevel/main/station/terrestrial)
#else
INCLUDE_MAP("../z4_blank.dmm", /datum/zlevel/secret)
#endif
#define MAP_MODE "standard"
