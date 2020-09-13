// PLEASE DONT ADD STUFF TO THIS THAT ISNT DIRECTLY RELATED TO GAME SETUP

//#define IM_REALLY_IN_A_FUCKING_HURRY_HERE 1 //Uncomment this to just skip everything possible and get into the game asap.
//#define GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW 1 // uncomment this to use atlas as the single map. will horribly break things but speeds up compile/boot times.

#ifdef IM_REALLY_IN_A_FUCKING_HURRY_HERE
#define SKIP_FEA_SETUP 1
#define SKIP_Z5_SETUP 1
#define IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME 1 //Skip changelogs
#define I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO 1 //Automatically ready up and start the game ASAP. No input required.
#endif

#ifndef IM_REALLY_IN_A_FUCKING_HURRY_HERE
#define SKIP_FEA_SETUP 0 //Skip atmos setup
#define SKIP_Z5_SETUP 0 //Skip z5 gen
#endif

// Server side profiler stuff for when you want to profile how laggy the game is
// FULL_ROUND
//   Start profiling immediately, save profiler data when world is rebooting (data/profile/xxxxxxxx-full.log)
// PREGAME
//   Start profiling immediately, save profiler data when entering pregame state (data/profile/xxxxxx-pregame.log)
// INGAME_ONLY
//   Clear and start profiling once the PREGAME part ends. (data/profile/xxxxxxxx-ingame.log)
//
// FULL_ROUND and INGAME_ONLY are not compatible with one another, because INGAME_ONLY will
// clear the pre-game data FULL_ROUND collects. Use PREGAME instead if you want that.
//
//#define SERVER_SIDE_PROFILING_FULL_ROUND 1 // Generate and save profiler data for the entire round
//#define SERVER_SIDE_PROFILING_PREGAME 1	// Generate and save profiler data for pregame work (before "Welcome to pregame lobby")
//#define SERVER_SIDE_PROFILING_INGAME_ONLY 1 // Generate and save profiler data for post-pregame work

#define MINING_Z 5
// Defines the Mining Z level, change this when the map changes
// all this does is set the z-level to be ignored by erebite explosion admin log messages
// if you want to see all erebite explosions set this to 0 or -1 or something

// gameticker
#define GAME_STATE_WORLD_INIT	1
#define GAME_STATE_PREGAME		2
#define GAME_STATE_SETTING_UP	3
#define GAME_STATE_PLAYING		4
#define GAME_STATE_FINISHED		5

#define DATALOGGER

#define CREW_OBJECTIVES

#define MISCREANTS

//#define RESTART_WHEN_ALL_DEAD 1

//#define PLAYSOUND_LIMITER

#define LOOC_RANGE 8

//Ass Jam! enables a bunch of wacky and not-good features. BUILD LOCALLY!!!
#ifdef RP_MODE
#define ASS_JAM 0
#elif BUILD_TIME_DAY == 13 && defined(ASS_JAM_ENABLED)
#define ASS_JAM 1
#else
#define ASS_JAM 0
#endif

// holiday toggles!

//#define HALLOWEEN 1
//#define XMAS 1
//#define CANADADAY 1

// other toggles

#define FOOTBALL_MODE 1
//#define RP_MODE
//#define ASS_JAM_ENABLED 1 //you need to set BUILD_TIME_DAY to 13 manually in __build.dm

//handles ass jam stuff
#if ASS_JAM
#ifndef TRAVIS_ASSJAM
#warn Building with ASS_JAM features enabled. Toggle this by changing BUILD_TIME_DAY in __build.dm
#endif
#endif

#ifdef Z_LOG_ENABLE
var/ZLOG_START_TIME
#define Z_LOG(LEVEL, WHAT, X) world.log << "\[[add_zero(world.timeofday - ZLOG_START_TIME, 6)]\] [WHAT] ([LEVEL]) " + X
#define Z_LOG_DEBUG(WHAT, X) Z_LOG("DEBUG", WHAT, X)
#define Z_LOG_INFO(WHAT, X) Z_LOG("INFO", WHAT, X)
#define Z_LOG_WARN(WHAT, X) Z_LOG("WARN", WHAT, X)
#define Z_LOG_ERROR(WHAT, X) Z_LOG("ERROR", WHAT, X)
#else
#define Z_LOG(LEVEL, WHAT, X) //
#define Z_LOG_DEBUG(WHAT, X) //
#define Z_LOG_INFO(WHAT, X) //
#define Z_LOG_WARN(WHAT, X) //
#define Z_LOG_ERROR(WHAT, X) //
#endif

/// Activates the viscontents warps
#define NON_EUCLIDEAN 1

// Used for /datum/respawn_controller - DOES NOT COVER ALL RESPAWNS YET
#define DEFAULT_RESPAWN_TIME 18000
#define RESPAWNS_ENABLED 0

#if (defined(SERVER_SIDE_PROFILING_PREGAME) || defined(SERVER_SIDE_PROFILING_FULL_ROUND) || defined(SERVER_SIDE_PROFILING_INGAME_ONLY))
#ifndef SERVER_SIDE_PROFILING
	#define SERVER_SIDE_PROFILING 1
#endif
#endif

//Amount of 1 Second ticks to spend in the pregame lobby before roundstart. Has been 150 seconds for a couple years.
#define PREGAME_LOBBY_TICKS 150	// raised from 120 to 180 to accomodate the v500 ads, then raised back down to 150 after Z5 was introduced.

//The value of mapvotes. A passive vote is one done through player preferences, an active vote is one where the player actively chooses a map
#define MAPVOTE_PASSIVE_WEIGHT 1.0
#define MAPVOTE_ACTIVE_WEIGHT 1.0

//what counts as participation?
#ifdef RP_MODE
#define MAX_PARTICIPATE_TIME 80 MINUTES //the maximum shift time before it doesnt count as "participating" in the round
#else
#define MAX_PARTICIPATE_TIME 40 MINUTES //ditto above
#endif

// IN_MAP_EDITOR macro is used to make some things appear visually more clearly in the map editor
// this handles StrongDMM (and other editors using SpacemanDMM parser), toggle it manually if using a different editor
#ifdef SPACEMAN_DMM
#define IN_MAP_EDITOR
#endif
