// comment this line to disable or enable spawn debugging. it's pretty cheap and safe for the live servers though.
// #define ENABLE_SPAWN_DEBUG
// #define ENABLE_SPAWN_DEBUG_2

// for this to work, use SPAWN() instead of spawn(). thank you for loving pupkin. -singh
#ifdef ENABLE_SPAWN_DEBUG
var/list/global_spawn_dbg = list()
#define SPAWN(x) global_spawn_dbg["spawn at [__FILE__]:[__LINE__]"]++; spawn(x)
#elif defined(ENABLE_SPAWN_DEBUG_2)
var/list/detailed_spawn_dbg = list()
#define SPAWN(x) detailed_spawn_dbg += list(list("[__FILE__]:[__LINE__]", TIME, TIME + x)); spawn(x)
#else
#define SPAWN(x) spawn(x)
#endif
