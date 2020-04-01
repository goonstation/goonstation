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

//Delete queue debug toggle
//This is expensive. don't turn it on on the server unless you want things to be bad and slow
//#define DELETE_QUEUE_DEBUG

//#define UPDATE_QUEUE_DEBUG

//Image deletion debug
//DO NOT ENABLE THIS ON THE SERVER FOR FUCKS SAKE
//#define IMAGE_DEL_DEBUG

// Machine processing debug
//Apparently not that hefty but still
//#define MACHINE_PROCESSING_DEBUG

//Queue worker statistics
//Probably hefty
//#define QUEUE_STAT_DEBUG

//Map overrides

//Construction mode
//#define MAP_OVERRIDE_CONSTRUCTION

// Destiny/RP
//#define MAP_OVERRIDE_DESTINY

// Destiny/Alt RP
//#define MAP_OVERRIDE_CLARION

// Cogmap
//#define MAP_OVERRIDE_COGMAP

// Cogmap 2
//#define MAP_OVERRIDE_COGMAP2

// Updated Donut2
//#define MAP_OVERRIDE_DONUT2

// Linemap by pgoat
//#define MAP_OVERRIDE_LINEMAP

// Updated Mushroom
//#define MAP_OVERRIDE_MUSHROOM

// Updated Ovary
//#define MAP_OVERRIDE_TRUNKMAP

// Chiron by Kusibu
//#define MAP_OVERRIDE_CHIRON

// Samedi by Kusibu
//#define MAP_OVERRIDE_SAMEDI

// Oshan
//#define MAP_OVERRIDE_OSHAN

// Horizon by Warcrimes
//#define MAP_OVERRIDE_HORIZON

// gannetmap OR IS IT KUBIUSGANNETMAP??
//#define MAP_OVERRIDE_ATLAS

//#define MAP_OVERRIDE_MANTA

//WIP do not use
//#define MAP_OVERRIDE_GEHENNA

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
#define BUILD_TIME_DAY 01
#define BUILD_TIME_HOUR 18
#define BUILD_TIME_MINUTE 31
#define BUILD_TIME_SECOND 30
#define BUILD_TIME_UNIX 1234567890 // Unix epoch, second precision