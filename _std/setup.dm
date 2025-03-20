// PLEASE DONT ADD STUFF TO THIS THAT ISNT DIRECTLY RELATED TO GAME SETUP

//#define IM_REALLY_IN_A_FUCKING_HURRY_HERE 1 //Uncomment this to just skip everything possible and get into the game asap.
//#define GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW 1 // uncomment this to use atlas as the single map and disable all other z levels. Speeds up compile/boot times but will mess up anything relying on other z-levels

#ifdef CHECK_MORE_RUNTIMES
#define ABSTRACT_VIOLATION_CRASH
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

/// values for the current_state var
#define GAME_STATE_INVALID 0
#define GAME_STATE_PRE_MAP_LOAD 1
#define GAME_STATE_MAP_LOAD 2
#define GAME_STATE_WORLD_INIT 3 //! unused currently, probably convert to WORLD_NEW
#define GAME_STATE_WORLD_NEW 4
#define GAME_STATE_PREGAME 5
#define GAME_STATE_SETTING_UP 6
#define GAME_STATE_PLAYING 7
#define GAME_STATE_FINISHED 8

#define DATALOGGER

#define CREW_OBJECTIVES

//#define RESTART_WHEN_ALL_DEAD 1

#define LOOC_RANGE 8

// holiday toggles!

#if (BUILD_TIME_MONTH == 10)
#define HALLOWEEN 1
#endif

#if (BUILD_TIME_MONTH == 12) || (BUILD_TIME_MONTH == 1) || (BUILD_TIME_MONTH == 2)
#define SEASON_WINTER 1
#elif (BUILD_TIME_MONTH == 3) || (BUILD_TIME_MONTH == 4) || (BUILD_TIME_MONTH == 5)
#define SEASON_SPRING 1
#elif (BUILD_TIME_MONTH == 6) || (BUILD_TIME_MONTH == 7) || (BUILD_TIME_MONTH == 8)
#define SEASON_SUMMER 1
#else
#define SEASON_AUTUMN 1
#endif

#if (BUILD_TIME_MONTH == 12)
#define XMAS 1

#endif
#if (BUILD_TIME_MONTH == 7) && (BUILD_TIME_DAY == 1)
#define CANADADAY 1
#endif

#if (BUILD_TIME_MONTH == 7) && (BUILD_TIME_DAY == 6)
#define MIDSUMMER 1
#endif

// other toggles

#define FOOTBALL_MODE 1
//#define ENABLE_ARTEMIS
//#define RP_MODE

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
#define DEFAULT_RESPAWN_TIME 10 MINUTES
#define RESPAWNS_ENABLED 0

#if (defined(SERVER_SIDE_PROFILING_PREGAME) || defined(SERVER_SIDE_PROFILING_FULL_ROUND) || defined(SERVER_SIDE_PROFILING_INGAME_ONLY))
#ifndef SERVER_SIDE_PROFILING
	#define SERVER_SIDE_PROFILING 1
#endif
#endif

//Amount of 1 Second ticks to spend in the pregame lobby before roundstart. Has been 150 seconds for a couple years.
#define PREGAME_LOBBY_TICKS 180	// raised from 120 to 180 to accomodate the v500 ads, then raised back down to 150 after Z5 was introduced.

//The value of mapvotes. A passive vote is one done through player preferences, an active vote is one where the player actively chooses a map
#define MAPVOTE_PASSIVE_WEIGHT 1
#define MAPVOTE_ACTIVE_WEIGHT 1

//what counts as participation?
#ifdef RP_MODE
#define MAX_PARTICIPATE_TIME 60 MINUTES //the maximum shift time before it doesnt count as "participating" in the round
#else
#define MAX_PARTICIPATE_TIME 40 MINUTES //ditto above
#endif

// IN_MAP_EDITOR macro is used to make some things appear visually more clearly in the map editor
// this handles StrongDMM (and other editors using SpacemanDMM parser), toggle it manually if using a different editor
#if (defined(SPACEMAN_DMM) || defined(FASTDMM))
#define IN_MAP_EDITOR
#if (defined(USE_PERSPECTIVE_EDITOR_WALLS))
	#define PERSPECTIVE_EDITOR_WALL
#endif
#endif

//do we want to check incoming clients to see if theyre using a vpn?
#define DO_VPN_CHECKS 1

/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (nameof(.proc/##X))
/// Call by name verb references, checks if the verb exists on either this type or as a global verb.
#define VERB_REF(X) (nameof(.verb/##X))
/// Call by name verb reference, checks if the verb exists on either the given type or as a global verb
#define TYPE_VERB_REF(TYPE, X) (nameof(##TYPE.verb/##X))
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)

//////bad regexes/////
//sort of TYPE_PROC_REF: \/.[^,]*(?!\/)\.proc\/

//PROC_REF replace regex:
/*
\.proc\/([^ ,)]*)
replace with:
PROC_REF($1)
*/
