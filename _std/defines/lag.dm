//deletion queue controls
#define DELQUEUE_SIZE 35
#define DELQUEUE_WAIT 30
#define MIN_DELETE_CHUNK_SIZE 1
#define MAX_DELETE_CHUNK_SIZE 100

//lagcheck stuff
#ifdef SPACEMAN_DMM
#define LAGCHECK(x)
#else
#define LAGCHECK(x) if (lagcheck_enabled && world.tick_usage > x) sleep(world.tick_lag)
#endif

//for light queue - when should we queue? and when should we pause processing our dowork loop?
#define LIGHTING_MAX_TICKUSAGE 90

//lag levels
#define LAG_LOW 13
#define LAG_MED 20
#define LAG_HIGH 40
#define LAG_REALTIME 66

//ticklag stuff
#define TIME_DILATION_ENABLED 1
#define MIN_TICKLAG 0.4 /// min value ticklag can be
#define OVERLOADED_WORLD_TICKLAG 1 /// max value ticklag can be
#define TICKLAG_DILATION_INC 0.2 /// how ticklag much to increase by when appropriate
#define TICKLAG_DILATION_DEC 0.2 /// how much to decrease by when appropriate //MBCX I DONT KNOW WHY BUT MOST VALUES CAUSE ROUNDING ERRORS, ITS VERY IMPORTANT THAT THIS REMAINS 0.2 FIOR NOW
#define TICKLAG_DILATION_THRESHOLD 5 // these values dont make sense to you? read the math in gameticker
#define TICKLAG_NORMALIZATION_THRESHOLD 0.3 // these values dont make sense to you? read the math in gameticker
#define TICKLAG_DILATE_INTERVAL 20

#define OVERLOAD_PLAYERCOUNT 95 /// when pcount is above this number on round start, increase ticklag to OVERLOADED_WORLD_TICKLAG to try to maintain smoothness
#define OSHAN_LIGHT_OVERLOAD 18 /// when pcount is above this number on game load, dont generate lighting surrounding the station because it lags the map to heck
#define SLOW_LIFE_PLAYERCOUNT 65 /// whenn pcount is >= this number, slow Life() processing a bit
#define SLOWEST_LIFE_PLAYERCOUNT 85 /// whenn pcount is >= this number, slow Life() processing a lot

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

#define DEFAULT_CLICK_DELAY MIN_TICKLAG //used to be 1
#define CLICK_GRACE_WINDOW 0 //2.5

//pools!!
//How much stuff is allowed in the pools before the lifeguard throws them into the deletequeue instead. A shameful lifeguard.
#define DEFAULT_POOL_SIZE 150
//#define DETAILED_POOL_STATS
