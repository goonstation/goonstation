#if defined(MAP_OVERRIDE_DEVTEST)
INCLUDE_MAP("../blank_maps/devtest.dmm")
#elif defined(MAP_OVERRIDE_TESTING_UNSIMMED)
INCLUDE_MAP("../blank_maps/unsimmed_test.dmm")
#elif defined(MAP_OVERRIDE_TESTING_SIMMED)
INCLUDE_MAP("../blank_maps/simmed_test.dmm")
#endif

#define MAP_MODE "testing"
