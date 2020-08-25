#ifdef SPACEMAN_DMM
#define LAGCHECK(x)
#else
#define LAGCHECK(x) if (lagcheck_enabled && world.tick_usage > x) sleep(world.tick_lag)
#endif

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


//MBC : I should have added defines like these earlier - most widescreen bits aren't using them as of now!
#define WIDE_TILE_WIDTH 21
#define SQUARE_TILE_WIDTH 15

//The value of mapvotes. A passive vote is one done through player preferences, an active vote is one where the player actively chooses a map
#define MAPVOTE_PASSIVE_WEIGHT 1.0
#define MAPVOTE_ACTIVE_WEIGHT 1.0
//Amount of 1 Second ticks to spend in the pregame lobby before roundstart. Has been 150 seconds for a couple years.
#define PREGAME_LOBBY_TICKS 150	// raised from 120 to 180 to accomodate the v500 ads, then raised back down to 150 after Z5 was introduced.

//for light queue - when should we queue? and when should we pause processing our dowork loop?
#define LIGHTING_MAX_TICKUSAGE 90

//lag levels
#define LAG_LOW 13
#define LAG_MED 20
#define LAG_HIGH 40
#define LAG_REALTIME 66
