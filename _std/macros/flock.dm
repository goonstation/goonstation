// type check macros
#define isfeathertile(x) (istype(x, /turf/simulated/floor/feather) || istype(x, /turf/simulated/wall/auto/feather))
#define isflockmob(x) (istype(x, /mob/living/intangible/flock) || istype(x, /mob/living/critter/flock))
#define isflockstructure(x) (istype(x, /obj/flock_structure))
#define isflockdeconimmune(x) (istype(target, /obj/flock_structure/ghost) || istype(target, /mob/living/critter/flock) || istype(target, /turf/simulated/floor/feather) || istype(target, /obj/flock_structure/rift) || istype(target, /obj/flock_structure/egg) || istype(target, /obj/flock_structure/relay))
/// Checks if something could potentially be considered an enemy of the flock
#define isflockvalidenemy(x) ((ismob(x) || iscritter(x) || isvehicle(x)) && !isflockmob(x))

// process controller
#define FLOCK_PROCESS_SCHEDULE_INTERVAL 2 SECONDS

//annotation name macros
#define FLOCK_ANNOTATION_DECONSTRUCT "deconstruct"
#define FLOCK_ANNOTATION_HAZARD "hazard"
#define FLOCK_ANNOTATION_PRIORITY "priority"
#define FLOCK_ANNOTATION_RESERVED "reserved"
#define FLOCK_ANNOTATION_FLOCKMIND_CONTROL "flockmind_face"
#define FLOCK_ANNOTATION_FLOCKTRACE_CONTROL "flocktrace_face"
#define FLOCK_ANNOTATION_HEALTH "health"

// flock intangibles
#define FLOCK_AFK_COUNTER_THRESHOLD 180 SECONDS

// costs
#define FLOCK_CONVERT_COST 20
#define FLOCK_BARRICADE_COST 20
#define FLOCK_LAY_EGG_COST 100
#define FLOCK_REPAIR_COST 10
#define FLOCK_GHOST_DEPOSIT_AMOUNT 10

#define FLOCK_RELAY_COMPUTE_COST 500 // total compute

#define FLOCKTRACE_COMPUTE_COST 100

// achievements
#define FLOCK_ACHIEVEMENT_CHEAT_STRUCTURES "all_structures"
#define FLOCK_ACHIEVEMENT_CHEAT_COMPUTE "infinite_compute"
#define FLOCK_ACHIEVEMENT_CAGE_HUMAN "human_dissection"
#define FLOCK_ACHIEVEMENT_BULLETS_HIT "bullets_hit"

#define FLOCK_BULLETS_HIT_THRESHOLD 15

// radio effects
#define FLOCK_RADIO_GARBLE_CHANCE 50

// replication defs
#define FLOCK_MIN_DESIRED_POP 10
#define FLOCK_ADDITIONAL_RESOURCE_RESERVATION_PER_DRONE 7.5

// drone compute configs
#define FLOCK_DRONE_COMPUTE 10
#define FLOCK_DRONE_COMPUTE_HIBERNATE 15
// how many times a drone must wander in a row before it hibernates
#define FLOCK_DRONE_WANDER_PAUSE_COUNT 5
// maximum number of flockdrones allowed
#define FLOCK_DRONE_LIMIT 75

//TUTORIAL
#define FLOCK_ACTION_RIFT_SPAWN "spawn rift"
#define FLOCK_ACTION_RIFT_COMPLETE "rift complete"
#define FLOCK_ACTION_GATECRASH "gatecrash"
#define FLOCK_ACTION_DRAGMOVE "click drag move"
#define FLOCK_ACTION_MARK_ENEMY "designate enemy"
#define FLOCK_ACTION_TEALPRINT_PLACE "place tealprint"
#define FLOCK_ACTION_TEALPRINT_COMPLETE "building complete"
//drones
#define FLOCK_ACTION_DRONE_CONTROL "control drone"
#define FLOCK_ACTION_DRONE_RELEASE "release drone"
#define FLOCK_ACTION_DRONE_SELECT "select drone"
#define FLOCK_ACTION_DRONE_ORDER "order drone"

#define FLOCK_ACTION_GAIN_RESOURCES "gain resources"
#define FLOCK_ACTION_START_CONVERSION "start conversion"
#define FLOCK_ACTION_FLOORRUN "floorrun"
#define FLOCK_ACTION_CAGE "cage"
#define FLOCK_ACTION_TURF_CLAIM "claim turf"
