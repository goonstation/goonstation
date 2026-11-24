/*
  ANY CHANGES HERE WILL BE OVERWRITTEN BY THE SERVER BUILD PROCESS.
  THAT BEING SAID, THIS IS THE IDEAL PLACE TO FORCE A CERTAIN MAP/FLAGS FOR LOCAL DEVELOPMENT.
  ALSO HERE'S A BEE

                .-..-.``        ```````
  .........`   s-`../-...`  `...........`
o+`        `-` ``..-:yooos-..----------..`
             .-`osyyyhssyh:.............-
            `+hh+/::::s::::::/oyysssys-`
          .sh+:o/:::::s:::::::::+yNNNNNs.
         od+:::++:::::s:::::::::::/yNNNmdy`
       .ds::::::+:::::/:::::::::::::/dNNNhd-
      `d+////::::::::::://///::::::::/hNNNym.
      ddmNNNNmy/::::::/ymNNNNds/::::::/dNNNsd`
     :MNNNNNNNNm+::::+mNNNNNNNNd/::::::oNNNydyooyy
     yNNNs::sNNNy::::dNNh/:/mNNN+:::::::mNNdsMNNd-
     dNNd....dNN+::::+NN:...oNNd/:::::::mNNNoNs:
     yyymdoodNd+::::::+hmyoyNNh/::::::::mNNdsh
     /m://ooo/::::::::::/+oo+/:::::::::/NNNhd/
      ds::::::::++:::/++:::::::::::::::sNNNhm`
      .m+::::::::+++++/:::::::::::::::/NNNNm-
       .do:::::::::::::::::::::::::::/mNNNN:
        `yh+::::::::::::::::::::::::/mNMMyd-
          .ydo/::::::::::::::::::::oNNmds :d
           .N:+yhyso//::::::://+osyyN- /h  N`
           .N   y:-:++osssssso++:`  M` :s
           `d.                     .d`
*/

// #region --------- Options to Go Fast ----------

/// Only include the tiny map Devtest, no other zlevels. Boots way faster.
//#define GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW

/// Skips FEA/mining/planet/camera setup, skips changelogs, and auto-readies up.
//#define IM_REALLY_IN_A_FUCKING_HURRY_HERE

/// Skip setting up atmospheric system.
//#define SKIP_FEA_SETUP
/// Skip generation of mining level.
//#define SKIP_Z5_SETUP
/// Skip planet generation (for Artemis).
//#define SKIP_PLANETS_SETUP
/// Skip calculating security camera coverage.
//#define SKIP_CAMERA_COVERAGE
/// Skip changelogs.
//#define IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME
/// Automatically ready up and join the game ASAP.
//#define I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO

// #endregion
// #region --------- Convenience Options ---------

/// Don't load things defined in _std/__build.local.dm. Use if you have some breaking changes in there or whatnot.
//#define DISABLE_DEVFILE
/// All IDs are captain rank, kept separate from below options to avoid disrupting access-related tests.
//#define DEBUG_EVERYONE_GETS_CAPTAIN_ID
/// Captain level ID's have EVERY access.
//#define I_MEAN_ALL_ACCESS
/// Disables all /datum/targetable cooldowns.
//#define NO_COOLDOWNS
/// Gives a bunch of starting points to various abilities/uplinks/weapon vendors.
//#define BONUS_POINTS
/// Causes has_medal to always return true - good for testing medal rewards etc.
//#define SHUT_UP_AND_GIVE_ME_MEDAL_STUFF
/// Incredibly hacky visible status effects.
//#define SHOW_ME_STATUSES
/// Override game mode minimum player requirements for testing revs, nukies etc.
//#define ME_AND_MY_40_ALT_ACCOUNTS
/// Spawn as the given job name. Gives helpful tools for debugging.
//#define I_WANNA_BE_THE_JOB "IMCODER"
/// Spawn as the matching antagonist role as defined in _std/defines/roles.dm.
//#define I_WANNA_DO_CRIME ROLE_TRAITOR
/// Loads the admin speech and listen module trees without any modules.
//#define NO_ADMIN_SPEECH_MODULES
/// Don't spawn the HTML pregame browser lobby screen.
//#define NO_PREGAME_HTML
/// Marks nearly all genes as researched, gives chromosomes/materials/autodecryptors, increases gene storage cap, and removes time/cost limitations on the gene console.
//#define I_HATE_WAITING_FOR_GENES
/// Fills up all APCs and SMESes on the station Z when the round starts.
//#define ROCK_DOWN_TO_ELECTRIC_AVENUE

// #endregion
// #region --------- Stop Distractions -----------

/// All of the below: no secbots/guardbuddies/bots, no monkeys, no clone prebake, instant clones, low security, no critters, no random rooms/events, no shuttle calls, hackerman, more runtime checks, quick mob deletion, no wage/mail/ghostdrone messages, unbreakable lights, no antag popups.
//#define STOP_DISTRACTING_ME

/// Prevents all secbots and guardbuddies from spawning, useful for gun testing.
//#define I_AM_ABOVE_THE_LAW
/// Prevents ALL bots from spawning (not cyborgs).
//#define ALL_ROBOT_AND_COMPUTERS_MUST_SHUT_THE_HELL_UP
/// Prevents landmark monkeys from spawning - monkeys can still be vended etc.
//#define BAD_MONKEY_NO_BANANA
/// Don't prebake clones.
//#define CLONING_IS_A_SIN
/// Clonepods fully heal the clone instantly.
//#define CLONING_IS_INSTANT
/// Deletes turrets.
//#define LOW_SECURITY
/// Deletes mob critters.
//#define NO_CRITTERS
/// Don't generate random rooms. Random room areas will be left blank and the landmark will be visible.
//#define NO_RANDOM_ROOMS
/// Don't spawn random events.
//#define NO_RANDOM_EVENTS
/// Don't autocall the shuttle.
//#define NO_SHUTTLE_CALLS
/// Lets you varedit things you normally couldn't (admin holders, server config).
//#define I_AM_HACKERMAN
/// Enables checking for some additional errors which might be too costly on live server. Also implied by CI_RUNTIME_CHECKING in CI.
//#define CHECK_MORE_RUNTIMES
/// Enables deleting mobs with build mode right click on obj place mode.
//#define QUICK_MOB_DELETION
/// Disables PDA messages from the wage system.
//#define SHUT_UP_ABOUT_MY_PAY
/// Disables random crew mail system.
//#define FUCK_OFF_WITH_THE_MAIL
/// Prevents ghostdrone factory objs from doing stuff.
//#define GHOSTDRONES_ON_STRIKE
/// Stops lights from breaking or burning out when spawning or turning on/off.
//#define STOP_BREAKING_THE_FUCKING_LIGHTS_I_WANT_TO_SEE_SHIT
/// Stops antag popups from coming up at the start of every game.
//#define NO_ANTAG_POPUPS_I_DONT_CARE

// #endregion
// #region --------- Profiling -------------------

/// Enables the hook for the DM Tracy profiler in world/init(), read the code guide.
// #define TRACY_PROFILER_HOOK

/// Generate and save profiler data for the entire round.
//#define SERVER_SIDE_PROFILING_FULL_ROUND
/// Generate and save profiler data for pregame work (before "Welcome to pregame lobby").
//#define SERVER_SIDE_PROFILING_PREGAME
/// Generate and save profiler data for post-pregame work.
//#define SERVER_SIDE_PROFILING_INGAME_ONLY

// #endregion
// #region --------- Debugging Toggles -----------

/// This is expensive. Don't turn it on on the server unless you want things to be bad and slow.
//#define DELETE_QUEUE_DEBUG

/// Probably don't turn it on on a real server but also I have no idea what an update queue is vOv.
//#define UPDATE_QUEUE_DEBUG

/// DO NOT ENABLE THIS ON THE SERVER FOR FUCKS SAKE.
//#define IMAGE_DEL_DEBUG

/// Apparently not that hefty but still.
//#define MACHINE_PROCESSING_DEBUG

/// Probably hefty.
//#define QUEUE_STAT_DEBUG

/// Enable local authentication using a dummy version of the goonhub authentication process.
//#define TEST_AUTH

/// Don't automatically grant admin to all localhost connections.
//#define DONT_ADMIN_MEE

/// Makes the code crash when an abstract type is instantiated. See _std/types.dm:32 for details.
// #define ABSTRACT_VIOLATION_CRASH
/// Makes the code log a warning when an abstract type is instantiated. See _std/types.dm:37 for details.
// #define ABSTRACT_VIOLATION_WARN

/// Makes the delete queue go through every datum in the game when a hard del happens - reported to the debug log. This takes about 4 minutes per hard deletion (during that time the server will be frozen).
// #define LOG_HARD_DELETE_REFERENCES
/// Same as Log hard delete references, electric boogaloo.
// #define LOG_HARD_DELETE_REFERENCES_2_ELECTRIC_BOOGALOO

/// Toggle this to turn .dispose() into qdel(). Useful for trying to find lingering references locally.
//#define DISPOSE_IS_QDEL

/// Toggle this to enable perspective wall icons in .dmm-compatible map editors. By default, icons in the editor will be flat.
//#define USE_PERSPECTIVE_EDITOR_WALLS

/// Enable additional world.log logging.
//#define Z_LOG_ENABLE

// #endregion
// #region --------- Map Overrides ---------------

//#define MAP_OVERRIDE_DEVTEST      // Developer Testing map, by cringe

//-------Special Events:
//#define MAP_OVERRIDE_CONSTRUCTION // Construction mode
//#define MAP_OVERRIDE_POD_WARS     // 500x500 Pod Wars map
//#define MAP_OVERRIDE_EVENT        // Misc. event maps
//#define MAP_OVERRIDE_WRESTLEMAP   // Wrestlemap, by Overtone

//-------Rotation maps:
//#define MAP_OVERRIDE_COGMAP       // Cogmap1, by Dr. Cogwerks
//#define MAP_OVERRIDE_COGMAP2      // Cogmap2, by Dr. Cogwerks
//#define MAP_OVERRIDE_DONUT3       // Donut Station 3, by Ryumi
//#define MAP_OVERRIDE_KONDARU      // Kondaru Station, by Kubius
//#define MAP_OVERRIDE_CLARION      // NSS Clarion (Used to be Destiny's Alt), by Dionsu and a69andahalf.
//#define MAP_OVERRIDE_OSHAN        // Oshan Laboratory, Abzu, by committee
//#define MAP_OVERRIDE_NADIR        // Nadir Extraction Site by Kubius
//#define MAP_OVERRIDE_NEON					// Neon by Sord
//#define MAP_OVERRIDE_MENHIR       // The one with the big artifact in it

//-------Discontinued or gimmick maps:
//#define MAP_OVERRIDE_ATLAS        // NCS Atlas, by Gannets (and Kubius)
//#define MAP_OVERRIDE_CRASH        // Stupid Crash Gimmick Map
//#define MAP_OVERRIDE_MUSHROOM     // Updated Mushroom
//#define MAP_OVERRIDE_DENSITY2     // Density2 (second smallest map), by Emily
//#define MAP_OVERRIDE_PROBSTATION  // Randomly generated map

/// Generate map screenshots for goonhub map viewer (NOT USED NORMALLY). Use together with a map override above.
//#define GENERATE_GOONHUB_MAP

// #endregion
// #region --------- Unit Test Framework ---------

/// Enable the unit test framework.
//#define UNIT_TESTS
/// Bypass 10 Second Limit.
//#define UNIT_TESTS_RUN_TILL_COMPLETION
/// Only run /datum/unit_test/regression subtypes.
//#define UNIT_TESTS_REGRESSION_ONLY
/// Only run tests of these types - comma separated list of types
//#define UNIT_TEST_TYPES /datum/unit_test/explosion_test, /datum/unit_test/deletion_regressions

// #endregion
// #region --------- Holidays and Such -----------

/// Roleplay mode toggle.
//#define RP_MODE

//#define SEASON_WINTER
//#define SEASON_SPRING
//#define SEASON_SUMMER
//#define SEASON_AUTUMN

/// Halloween event toggle.
//#define HALLOWEEN
/// Christmas event toggle.
//#define XMAS
/// Canada Day event toggle.
//#define CANADADAY
/// Football mode toggle.
//#define FOOTBALL_MODE
/// Enables artemis for development.
//#define ENABLE_ARTEMIS
/// Midsummer event toggle.
//#define MIDSUMMER

// #endregion

//----- Testmerge & Revision Information -----//

/// The literal current commit hash the server is running off of
#define VCS_REVISION "1"
/// The literal current author of the commit the server is runing off of
#define VCS_AUTHOR "bob"
/// The latest commit on the origin at the time of the server build, for display
#define ORIGIN_REVISION "1"
/// The latest commit author on the origin at the time of the server build, for display
#define ORIGIN_AUTHOR "bob"
// This exists and is set to a list of PR numbers when testmerges exist - goonstation/goonhub/app/Libraries/GameBuilder/Build.php#L392
// #define TESTMERGE_PRS list(123, 456)

// The following describe when the server was compiled
#define BUILD_TIME_TIMEZONE_ALPHA "UTC" // Server is UTC
#define BUILD_TIME_TIMEZONE_OFFSET 0000
#define BUILD_TIME_FULL "2009-02-13 18:31:30"
#define BUILD_TIME_YEAR 2053
#define BUILD_TIME_MONTH 03
#define BUILD_TIME_DAY 13
#define BUILD_TIME_HOUR 18
#define BUILD_TIME_MINUTE 31
#define BUILD_TIME_SECOND 30
#define BUILD_TIME_UNIX 1234567890 // Unix epoch, second precision

// Uncomment and set to a URL with a zip of the RSC to offload RSC sending to an external webserver/CDN.
//#define PRELOAD_RSC_URL ""

// -- Internal __build.dm stuff --
#ifdef CI_RUNTIME_CHECKING
#define CHECK_MORE_RUNTIMES
#endif

#ifdef GENERATE_GOONHUB_MAP
#define GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW
#define IM_REALLY_IN_A_FUCKING_HURRY_HERE
#define I_AM_ABOVE_THE_LAW
#define ALL_ROBOT_AND_COMPUTERS_MUST_SHUT_THE_HELL_UP
#define BAD_MONKEY_NO_BANANA
#define CLONING_IS_A_SIN
#define NO_CRITTERS
#define NO_RANDOM_ROOMS
#define NO_RANDOM_EVENTS
#define NO_SHUTTLE_CALLS
#define FUCK_OFF_WITH_THE_MAIL
#define GHOSTDRONES_ON_STRIKE
#define STOP_BREAKING_THE_FUCKING_LIGHTS_I_WANT_TO_SEE_SHIT
#endif

#ifdef STOP_DISTRACTING_ME
#define I_AM_ABOVE_THE_LAW
#define ALL_ROBOT_AND_COMPUTERS_MUST_SHUT_THE_HELL_UP
#define BAD_MONKEY_NO_BANANA
#define CLONING_IS_A_SIN
#define CLONING_IS_INSTANT
#define LOW_SECURITY
#define NO_CRITTERS
#define NO_RANDOM_ROOMS
#define NO_RANDOM_EVENTS
#define NO_SHUTTLE_CALLS
#define I_AM_HACKERMAN
#define CHECK_MORE_RUNTIMES
#define QUICK_MOB_DELETION
#define SHUT_UP_ABOUT_MY_PAY
#define FUCK_OFF_WITH_THE_MAIL
#define GHOSTDRONES_ON_STRIKE
#define STOP_BREAKING_THE_FUCKING_LIGHTS_I_WANT_TO_SEE_SHIT
#define NO_ANTAG_POPUPS_I_DONT_CARE
#endif

#ifdef IM_REALLY_IN_A_FUCKING_HURRY_HERE
#define SKIP_FEA_SETUP
#define SKIP_Z5_SETUP
#define SKIP_PLANETS_SETUP
#define SKIP_CAMERA_COVERAGE
#define IM_TESTING_SHIT_STOP_BARFING_CHANGELOGS_AT_ME
#define I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
#endif
