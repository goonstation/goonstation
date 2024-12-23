// special tests and defines up here
#if defined(SPACE_PREFAB_RUNTIME_CHECKING)
#include "blank.dm"

#elif defined(UNIT_TESTS)
#include "unit_tests.dm"

#elif defined(UNDERWATER_PREFAB_RUNTIME_CHECKING)
#include "blank_underwater.dm"

#elif defined(RANDOM_ROOM_RUNTIME_CHECKING)
#include "blank.dm"

// special modes
#elif defined(MAP_OVERRIDE_CONSTRUCTION)
#include "construction.dm"

#elif defined(MAP_OVERRIDE_POD_WARS)
#include "pod_wars.dm"

#elif defined(MAP_OVERRIDE_EVENT)
#include "event.dm"

#elif defined(MAP_OVERRIDE_PAMGOC)
#include "pamgoc.dm"

#elif defined(MAP_OVERRIDE_WRESTLEMAP)
#include "wrestlemap.dm"

// rotation maps
#elif defined(MAP_OVERRIDE_COGMAP)
#include "cogmap.dm"

#elif defined(MAP_OVERRIDE_COGMAP2)
#include "cogmap2.dm"

#elif defined(MAP_OVERRIDE_DONUT2)
#include "donut2.dm"

#elif defined(MAP_OVERRIDE_DONUT3)
#include "donut3.dm"

#elif defined(MAP_OVERRIDE_KONDARU)
#include "kondaru.dm"

#elif defined(MAP_OVERRIDE_ATLAS)
#include "atlas.dm"

#elif defined(MAP_OVERRIDE_CLARION)
#include "clarion.dm"

#elif defined(MAP_OVERRIDE_OSHAN)
#include "oshan.dm"

#elif defined(MAP_OVERRIDE_NADIR)
#include "nadir.dm"

// non rotation maps
#elif defined(MAP_OVERRIDE_MANTA)
#include "manta.dm"

#elif defined(MAP_OVERRIDE_DESTINY)
#include "destiny.dm"

#elif defined(MAP_OVERRIDE_DENSITY2)
#include "density2.dm"

#elif defined(MAP_OVERRIDE_HORIZON)
#include "horizon.dm"

#elif defined(MAP_OVERRIDE_CRASH)
#include "crash.dm"

#elif defined(MAP_OVERRIDE_MUSHROOM)
#include "mushroom.dm"

#elif defined(MAP_OVERRIDE_TRUNKMAP)
#include "trunkmap.dm"

#elif defined(MAP_OVERRIDE_DENSITY)
#include "density.dm"

#elif defined(MAP_OVERRIDE_DENSITY2)
#include "density2.dm"

#elif defined(MAP_OVERRIDE_OZYMANDIAS)
#include "ozymandias.dm"

#elif defined(MAP_OVERRIDE_FLEET)
#include "fleet.dm"

#elif defined(MAP_OVERRIDE_DEVTEST)
#include "devtest.dm"

#elif defined(GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW)
#include "gottagofast.dm"

//Entry below is the "default" map
#else
#include "standard.dm"
#endif

#if defined(ENABLE_ARTEMIS) && !defined(GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW)
#include "..\artemis\planets.dmm"
#endif
