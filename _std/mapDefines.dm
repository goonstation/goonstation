
#if defined(MAP_OVERRIDE_CONSTRUCTION)

//#elif defined(MAP_OVERRIDE_POD_WARS)

//#elif defined(MAP_OVERRIDE_EVENT)

#elif defined(SPACE_PREFAB_RUNTIME_CHECKING)
#define CI_RUNTIME_CHECKING 1
#define CHECK_MORE_RUNTIMES 1
#define PREFAB_CHECKING 1

#elif defined(UNDERWATER_PREFAB_RUNTIME_CHECKING)
#define UNDERWATER_MAP 1
#define CI_RUNTIME_CHECKING 1
#define CHECK_MORE_RUNTIMES 1
#define PREFAB_CHECKING 1

#elif defined(RANDOM_ROOM_RUNTIME_CHECKING)
#define CI_RUNTIME_CHECKING 1
#define CHECK_MORE_RUNTIMES 1
#define RANDOM_ROOM_CHECKING 1

#elif defined(MAP_OVERRIDE_PAMGOC)

#define REVERSED_MAP

//#elif defined(MAP_OVERRIDE_WRESTLEMAP)

// rotation
#elif defined(MAP_OVERRIDE_COGMAP)

#elif defined(MAP_OVERRIDE_COGMAP2)

#elif defined(MAP_OVERRIDE_DONUT2)

#elif defined(MAP_OVERRIDE_DONUT3)

// #elif defined(MAP_OVERRIDE_KONDARU)

#elif defined(MAP_OVERRIDE_CLARION)

#elif defined(MAP_OVERRIDE_ATLAS)

#elif defined(MAP_OVERRIDE_OSHAN)
#define UNDERWATER_MAP 1
#define HOTSPOTS_ENABLED 1

#elif defined(MAP_OVERRIDE_NADIR)
#define UNDERWATER_MAP 1

// Non rotation
#elif defined(MAP_OVERRIDE_MANTA)

#define UNDERWATER_MAP 1
#define MOVING_SUB_MAP 1
#define SUBMARINE_MAP 1

#elif defined(MAP_OVERRIDE_DESTINY)

#elif defined(MAP_OVERRIDE_HORIZON)

//#elif defined(MAP_OVERRIDE_CRASH)

#elif defined(MAP_OVERRIDE_MUSHROOM)

#elif defined(MAP_OVERRIDE_TRUNKMAP)

/*#elif defined(MAP_OVERRIDE_DENSITY)

#elif defined(MAP_OVERRIDE_OZYMANDIAS)

#elif defined(MAP_OVERRIDE_FLEET)*/

#else // the "default" map
//#define UNDERWATER_MAP 1

#endif
