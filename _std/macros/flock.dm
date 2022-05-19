// hi here's some flockdrone BS - cirr
#define isfeathertile(x) (istype(x, /turf/simulated/floor/feather) || istype(x, /turf/simulated/wall/auto/feather))
#define isflock(x) (istype(x, /mob/living/intangible/flock) || istype(x, /mob/living/critter/flock))
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
