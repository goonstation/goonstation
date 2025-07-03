//deletion queue controls
#define DELQUEUE_SIZE 35
#define DELQUEUE_WAIT 30
#define MIN_DELETE_CHUNK_SIZE 1
#define MAX_DELETE_CHUNK_SIZE 100

//close only counts in horseshoes and byond
#define EXTRA_TICK_SPACE 2

#define APPROX_TICK_USE (world.tick_usage + world.map_cpu + EXTRA_TICK_SPACE)

//lagcheck stuff
#ifndef SPACEMAN_DMM
#define LAGCHECK(x) if (lagcheck_enabled && APPROX_TICK_USE > x) sleep(world.tick_lag)
#else
#define LAGCHECK(x) // this is wrong and bad, but it'd be way too much effort to remove lagchecks from everything :/
#endif

#ifdef LIVE_SERVER
#define LAGCHECK_IF_LIVE(x) LAGCHECK(x)
#else
#define LAGCHECK_IF_LIVE(x) sleep(-1)
#endif

//for light queue - when should we queue? and when should we pause processing our dowork loop?
#define LIGHTING_MAX_TICKUSAGE 140

//LAGCHECK parameter levels. "when the tick is this% complete, sleep here."
//lower numbers will sleep more often, and should be used for lower priority tasks.
//higher numbers will sleep less often, and should be used for high priority tasks.
#define LAG_LOW 90
#define LAG_MED 90
#define LAG_HIGH 90
#define LAG_REALTIME 90
#define LAG_INIT 95

/// Waits until a given condition is true, tg-style async
#define UNTIL(X) while(!(X)) sleep(1)

//ticklag stuff. code lives in gameticker's process() in datums/gameticker.dm
#define TIME_DILATION_ENABLED 1
/// min value ticklag can be
#define MIN_TICKLAG 0.2
/// max value ticklag can be
#define OVERLOADED_WORLD_TICKLAG 1.4
/// where to start ticklag if many players present
#define SEMIOVERLOADED_WORLD_TICKLAG 1
/// how ticklag much to increase by when appropriate
#define TICKLAG_DILATION_INC 0.2
/// how much to decrease by when appropriate //MBCX I DONT KNOW WHY BUT MOST VALUES CAUSE ROUNDING ERRORS, ITS VERY IMPORTANT THAT THIS REMAINS 0.2 FIOR NOW
#define TICKLAG_DILATION_DEC 0.2
/// what cpu percent is too high in the dilation check
#define TICKLAG_CPU_MAX 90
/// what cpu percent is low enough in the dilation check
#define TICKLAG_CPU_MIN 70
/// what map_cpu percent is too high in the dilation check
#define TICKLAG_MAPCPU_MAX 70
/// what map_cpu percent is low enough in the dilation check
#define TICKLAG_MAPCPU_MIN 55
/// number of times the dilation check needs to see lag in a row to slow down the ticker
#define TICKLAG_INCREASE_THRESHOLD 5
/// number of times to see no lag in a row to speed up the ticker
#define TICKLAG_DECREASE_THRESHOLD 10
/// how often to check for time dilation, against world.time, so counted in game ticks.
#define TICKLAG_DILATE_INTERVAL 20

/// whether we want to profile in advance of a lagspike every tick to catch relevant lagspike info
#define PRE_PROFILING_ENABLED
/// what value must world.cpu cross upwards to trigger automatic profiling
#define CPU_START_PROFILING_THRESHOLD 100
/// what value must world.cpu cross upwards to trigger automatic profiling but this one ignores CPU_START_PROFILING_COUNT
#define CPU_START_PROFILING_IMMEDIATELY_THRESHOLD 400
/// what value must world.cpu cross downwards to stop automatic profiling
#define CPU_STOP_PROFILING_THRESHOLD 95
/// how many ticks in a row does world.cpu needs to be above the threshold to start profiling
#define CPU_START_PROFILING_COUNT 40
/// how many ticks in a row does world.cpu needs to be below the threshold to stop profiling
#define CPU_STOP_PROFILING_COUNT 40
/// how long the round needs to be in progress before we can start profiling
#define CPU_PROFILING_ROUNDSTART_GRACE_PERIOD 10 SECONDS
/// even if world.cpu is normal if tick took this amount of time profiling will start
#define TICK_TIME_PROFILING_THRESHOLD 1.5 SECONDS

/// when pcount is above this number on round start, increase ticklag to OVERLOADED_WORLD_TICKLAG to try to maintain smoothness
#define OVERLOAD_PLAYERCOUNT 120
/// when pcount is above this number on round start, increase ticklag to SEMIOVERLOADED_WORLD_TICKLAG to try to maintain smoothness
#define SEMIOVERLOAD_PLAYERCOUNT 85
/// whenn pcount is >= this number, slow Life() processing a bit
#define SLOW_LIFE_PLAYERCOUNT 85
/// whenn pcount is >= this number, slow Life() processing a lot
#define SLOWEST_LIFE_PLAYERCOUNT 120

//Define clientside tick lag seperately from world.tick_lag
//'cause smoothness looks good.
// Glides are supposed to automatically adjust to client framerate. HOWEVER THEY DO NOT :: http://www.byond.com/forum/?post=2241289
// We do the glide size compensation manually in the relevant places.
#define CLIENTSIDE_TICK_LAG_SMOOTH 0.25
//fuck me, I have no idea why there's only 2 framerates that handle smooth glides for us. It's probably because byond is bugged.
//anyway just putting this define here for the client framerate toggle button between SMOOTH AND CHUNKY OH YEAH
#define CLIENTSIDE_TICK_LAG_CHUNKY 0.4
//its the future now
#define CLIENTSIDE_TICK_LAG_CREAMY 0.15
//its the future now
#define CLIENTSIDE_TICK_LAG_VELVETY 0.09

#define DEFAULT_CLICK_DELAY MIN_TICKLAG //used to be 1
#define CLICK_GRACE_WINDOW 0 //2.5

//pools!!

/// How much stuff is allowed in the pools before the lifeguard throws them into the deletequeue instead. A shameful lifeguard.
#define DEFAULT_POOL_SIZE 150

//#define DETAILED_POOL_STATS
