#define DEBUG
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


//////////// OPTIONS TO GO FAST

//#define IM_REALLY_IN_A_FUCKING_HURRY_HERE 1  // Skip setup for atmos, Z5, don't show changelogs, skip pregame lobby
//#define GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW 1  // Only include the map Atlas, no other zlevels. Boots way faster
//#define Z_LOG_ENABLE 1  // Enable additional world.log logging


//////////// PROFILING OPTIONS

//#define SERVER_SIDE_PROFILING_FULL_ROUND 1 // Generate and save profiler data for the entire round
//#define SERVER_SIDE_PROFILING_PREGAME 1	// Generate and save profiler data for pregame work (before "Welcome to pregame lobby")
//#define SERVER_SIDE_PROFILING_INGAME_ONLY 1 // Generate and save profiler data for post-pregame work


//////////// DEBUGGING TOGGLES

// Delete queue debug toggle
// This is expensive. don't turn it on on the server unless you want things to be bad and slow
//#define DELETE_QUEUE_DEBUG

// Update queue debug toggle
// Probably don't turn it on on a real server but also I have no idea what an update queue is vOv
//#define UPDATE_QUEUE_DEBUG

// Image deletion debug
// DO NOT ENABLE THIS ON THE SERVER FOR FUCKS SAKE
//#define IMAGE_DEL_DEBUG

// Machine processing debug
// Apparently not that hefty but still
//#define MACHINE_PROCESSING_DEBUG

// Queue worker statistics
// Probably hefty
//#define QUEUE_STAT_DEBUG

// Makes the code crash / log when an abstract type is instantiated.
// see _stadlib/_types.dm for details
// #define ABSTRACT_VIOLATION_CRASH
// #define ABSTRACT_VIOLATION_WARN

// Makes the delete queue go through every single datum in the game when a hard del happens
// It gets reported to the debug log. This process takes about 4 minutes per hard deletion
// (during that time the server will be frozen).
//#define LOG_HARD_DELETE_REFERENCES
//#define LOG_HARD_DELETE_REFERENCES_2_ELECTRIC_BOOGALOO
// The same thing but powered by extools. Better, harder, faster, stronger.
// You'll need an extools version that has the right stuff in it to make this work.
//#define REFERENCE_TRACKING
//#define AUTO_REFERENCE_TRACKING_ON_HARD_DEL

// Toggle this to turn .dispose() into qdel( ). Useful for trying to find lingering references locally.
//#define DISPOSE_IS_QDEL

//////////// MAP OVERRIDES

//#define MAP_OVERRIDE_CONSTRUCTION		// Construction mode
//#define MAP_OVERRIDE_DESTINY			// Destiny/RP
//#define MAP_OVERRIDE_CLARION			// Destiny/Alt RP
#define MAP_OVERRIDE_COGMAP			// Cogmap
//#define MAP_OVERRIDE_COGMAP2			// Cogmap 2
//#define MAP_OVERRIDE_DONUT2			// Updated Donut2
//#define MAP_OVERRIDE_DONUT3			// Donut3 by Ryumi
//#define MAP_OVERRIDE_LINEMAP			// Linemap by pgoat
//#define MAP_OVERRIDE_MUSHROOM			// Updated Mushroom
//#define MAP_OVERRIDE_TRUNKMAP			// Updated Ovary
//#define MAP_OVERRIDE_CHIRON			// Chiron by Kusibu
//#define MAP_OVERRIDE_SAMEDI			// Samedi by Kusibu
//#define MAP_OVERRIDE_OSHAN			// Oshan
//#define MAP_OVERRIDE_HORIZON			// Horizon by Warcrimes
//#define MAP_OVERRIDE_ATLAS			// gannetmap OR IS IT KUBIUSGANNETMAP??
//#define MAP_OVERRIDE_MANTA			// manta map
//#define MAP_OVERRIDE_DENSITY
//#define MAP_OVERRIDE_KONDARU
//#define MAP_OVERRIDE_OZYMANDIAS
//#define MAP_OVERRIDE_FLEET
//#define MAP_OVERRIDE_ICARUS
//#define MAP_OVERRIDE_GEHENNA			// Warcrimes WIP do not use
//#define MAP_OVERRIDE_PAMGOC			// Pamgoc
//#define MAP_OVERRIDE_WRESTLEMAP		// Wrestlemap by Overtone


//////////// HOLIDAYS AND OTHER SUCH TOGGLES

//#define RP_MODE
//#define HALLOWEEN 1
//#define XMAS 1
//#define CANADADAY 1
//#define FOOTBALL_MODE 1

//#define ASS_JAM_ENABLED 1 // BUT YOU ALSO GOTTA SET BUILD_TIME_DAY TO 13 BELOW!!!


var/global/vcs_revision = "1"
var/global/vcs_author = "bob"

var/global/ci_dm_version_major = "1"
var/global/ci_dm_version_minor = "100"

// The following describe when the server was compiled
#define BUILD_TIME_TIMEZONE_ALPHA "EST" // Server is EST
#define BUILD_TIME_TIMEZONE_OFFSET -0500
#define BUILD_TIME_FULL "2009-02-13 18:31:30"
#define BUILD_TIME_YEAR 2053
#define BUILD_TIME_MONTH 01
#define BUILD_TIME_DAY 01 //SET ME TO 13 TO TEST YOUR ASS_JAM CONTENT!!
#define BUILD_TIME_HOUR 18
#define BUILD_TIME_MINUTE 31
#define BUILD_TIME_SECOND 30
#define BUILD_TIME_UNIX 1234567890 // Unix epoch, second precision
