#ifdef APRIL_FOOLS

#if defined(SPACE_PREFAB_RUNTIME_CHECKING)
#include "blank.dm"

#elif defined(UNIT_TESTS)
#include "unit_tests.dm"

#elif defined(UNDERWATER_PREFAB_RUNTIME_CHECKING)
#include "big/blank_underwater.dm"

#elif defined(MAP_OVERRIDE_CONSTRUCTION)
#include "big/construction.dm"

#elif defined(MAP_OVERRIDE_DESTINY)
#include "big/destiny.dm"

#elif defined(MAP_OVERRIDE_CLARION)
#include "big/clarion.dm"

#elif defined(MAP_OVERRIDE_COGMAP)
#include "big/cogmap.dm"

#elif defined(MAP_OVERRIDE_COGMAP2)
#include "big/cogmap2.dm"

#elif defined(MAP_OVERRIDE_DONUT2)
#include "big/donut2.dm"

#elif defined(MAP_OVERRIDE_DONUT3)
#include "big/donut3.dm"

#elif defined(MAP_OVERRIDE_MUSHROOM)
#include "big/mushroom.dm"

#elif defined(MAP_OVERRIDE_TRUNKMAP)
#include "big/trunkmap.dm"

#elif defined(MAP_OVERRIDE_CHIRON)
#include "big/chiron.dm"

#elif defined(MAP_OVERRIDE_PAMGOC)
#include "big/pamgoc.dm"

#elif defined(MAP_OVERRIDE_OSHAN)
#include "big/oshan.dm"

#elif defined(MAP_OVERRIDE_HORIZON)
#include "big/horizon.dm"

#elif defined(MAP_OVERRIDE_ATLAS)
#include "big/atlas.dm"

#elif defined(MAP_OVERRIDE_MANTA)
#include "big/manta.dm"

#elif defined(MAP_OVERRIDE_KONDARU)
#include "big/kondaru.dm"

#elif defined(MAP_OVERRIDE_OZYMANDIAS)
#include "big/ozymandias.dm"

#elif defined(MAP_OVERRIDE_FLEET)
#include "big/fleet.dm"

#elif defined(MAP_OVERRIDE_ICARUS)
#include "big/icarus.dm"

#elif defined(MAP_OVERRIDE_DENSITY)
#include "big/density.dm"

#elif defined(MAP_OVERRIDE_GEHENNA)
#include "big/gehenna.dm"

#elif defined(MAP_OVERRIDE_WRESTLEMAP)
#include "big/wrestlemap.dm"

#elif defined(MAP_OVERRIDE_POD_WARS)
#include "big/pod_wars.dm"

#elif defined(GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW)
#include "gottagofast.dm"

//Entry below is the "default" map
#else
#include "standard.dm"
#endif

#else

#if defined(SPACE_PREFAB_RUNTIME_CHECKING)
#include "blank.dm"

#elif defined(UNIT_TESTS)
#include "unit_tests.dm"

#elif defined(UNDERWATER_PREFAB_RUNTIME_CHECKING)
#include "blank_underwater.dm"

#elif defined(MAP_OVERRIDE_CONSTRUCTION)
#include "construction.dm"

#elif defined(MAP_OVERRIDE_DESTINY)
#include "destiny.dm"

#elif defined(MAP_OVERRIDE_CLARION)
#include "clarion.dm"

#elif defined(MAP_OVERRIDE_CLARION2)
#include "clarion2.dm"

#elif defined(MAP_OVERRIDE_COGMAP)
#include "cogmap.dm"

#elif defined(MAP_OVERRIDE_COGMAP2)
#include "cogmap2.dm"

#elif defined(MAP_OVERRIDE_DONUT2)
#include "donut2.dm"

#elif defined(MAP_OVERRIDE_DONUT3)
#include "donut3.dm"

#elif defined(MAP_OVERRIDE_MUSHROOM)
#include "mushroom.dm"

#elif defined(MAP_OVERRIDE_TRUNKMAP)
#include "trunkmap.dm"

#elif defined(MAP_OVERRIDE_CHIRON)
#include "chiron.dm"

#elif defined(MAP_OVERRIDE_PAMGOC)
#include "pamgoc.dm"

#elif defined(MAP_OVERRIDE_OSHAN)
#include "oshan.dm"

#elif defined(MAP_OVERRIDE_HORIZON)
#include "horizon.dm"

#elif defined(MAP_OVERRIDE_CRASH)
#include "crash.dm"

#elif defined(MAP_OVERRIDE_ATLAS)
#include "atlas.dm"

#elif defined(MAP_OVERRIDE_MANTA)
#include "manta.dm"

#elif defined(MAP_OVERRIDE_KONDARU)
#include "kondaru.dm"

#elif defined(MAP_OVERRIDE_OZYMANDIAS)
#include "ozymandias.dm"

#elif defined(MAP_OVERRIDE_NADIR)
#include "nadir.dm"

#elif defined(MAP_OVERRIDE_FLEET)
#include "fleet.dm"

#elif defined(MAP_OVERRIDE_ICARUS)
#include "icarus.dm"

#elif defined(MAP_OVERRIDE_DENSITY)
#include "density.dm"

#elif defined(MAP_OVERRIDE_GEHENNA)
#include "gehenna.dm"

#elif defined(MAP_OVERRIDE_WRESTLEMAP)
#include "wrestlemap.dm"

#elif defined(MAP_OVERRIDE_POD_WARS)
#include "pod_wars.dm"

#elif defined(MAP_OVERRIDE_EVENT)
#include "event.dm"

#elif defined(GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW)
#include "gottagofast.dm"

//Entry below is the "default" map
#else
#include "standard.dm"
#endif

#if FOOTBALL_MODE && !defined(GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW) && !defined(UNIT_TESTS) && !defined(SPACE_PREFAB_RUNTIME_CHECKING) && !defined(UNDERWATER_PREFAB_RUNTIME_CHECKING)
INCLUDE_MAP("../zamujasa/football2.dmm")
#endif

#endif
