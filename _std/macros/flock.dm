// type check macros
#define isfeathertile(x) (istype(x, /turf/simulated/floor/feather) || istype(x, /turf/simulated/wall/auto/feather))
#define isflockmob(x) (istype(x, /mob/living/intangible/flock) || istype(x, /mob/living/critter/flock))
#define isflockstructure(x) (istype(x, /obj/flock_structure))
#define isflockdeconimmune(x) (istype(target, /obj/flock_structure/ghost) || istype(target, /mob/living/critter/flock) || istype(target, /turf/simulated/floor/feather) || istype(target, /obj/flock_structure/rift) || istype(target, /obj/flock_structure/egg) || istype(target, /obj/flock_structure/relay))

//annotation name macros
#define FLOCK_ANNOTATION_HAZARD "hazard"
#define FLOCK_ANNOTATION_DECONSTRUCT "deconstruct"
#define FLOCK_ANNOTATION_PRIORITY "priority"
#define FLOCK_ANNOTATION_RESERVED "reserved"
#define FLOCK_ANNOTATION_FLOCKMIND_CONTROL "flockmind_face"
#define FLOCK_ANNOTATION_FLOCKTRACE_CONTROL "flocktrace_face"
#define FLOCK_ANNOTATION_HEALTH "health"

// costs
#define FLOCK_CONVERT_COST 20
#define FLOCK_BARRICADE_COST 25
#define FLOCK_CAGE_COST 15
#define FLOCK_LAY_EGG_COST 100
#define FLOCK_REPAIR_COST 10
#define FLOCK_GHOST_DEPOSIT_AMOUNT 10

// achievements
#define FLOCK_ACHIEVEMENT_CHEAT_STRUCTURES "all_structures"
#define FLOCK_ACHIEVEMENT_CHEAT_COMPUTE "infinite_compute"
#define FLOCK_ACHIEVEMENT_CAGE_HUMAN "human_dissection"
