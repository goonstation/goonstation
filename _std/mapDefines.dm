// special modes
#if defined(MAP_OVERRIDE_DEVTEST)

#elif defined(MAP_OVERRIDE_CONSTRUCTION)

#elif defined(MAP_OVERRIDE_POD_WARS)

#elif defined(MAP_OVERRIDE_EVENT)

#elif defined(MAP_OVERRIDE_WRESTLEMAP)

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

// rotation maps
#elif defined(MAP_OVERRIDE_COGMAP)

#elif defined(MAP_OVERRIDE_COGMAP2)
#define MAPSIZE_LARGE 1

#elif defined(MAP_OVERRIDE_DECARABIA)

#elif defined(MAP_OVERRIDE_DONUT2)

#elif defined(MAP_OVERRIDE_DONUT3)
#define MAPSIZE_LARGE 1

#elif defined(MAP_OVERRIDE_KONDARU)

#elif defined(MAP_OVERRIDE_CLARION)

#elif defined(MAP_OVERRIDE_OSHAN)
#define UNDERWATER_MAP 1
#define HOTSPOTS_ENABLED 1

#elif defined(MAP_OVERRIDE_NADIR)
#define UNDERWATER_MAP 1

#elif defined(MAP_OVERRIDE_NEON)
#define UNDERWATER_MAP 1
#define HOTSPOTS_ENABLED 1
#define MAPSIZE_SMALL 1

// non rotation maps
#elif defined(MAP_OVERRIDE_ATLAS)
#define MAPSIZE_SMALL 1

#elif defined(MAP_OVERRIDE_CRASH)

#elif defined(MAP_OVERRIDE_MUSHROOM)

#elif defined(MAP_OVERRIDE_DENSITY2)
#define MAPSIZE_SMALL 1

#elif defined(MAP_OVERRIDE_PROBSTATION)

#else // the "default" map

#endif
