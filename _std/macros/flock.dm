// hi here's some flockdrone BS - cirr
#define isfeathertile(x) (istype(x, /turf/simulated/floor/feather) || istype(x, /turf/simulated/wall/auto/feather))
#define isflock(x) (istype(x, /mob/living/intangible/flock) || istype(x, /mob/living/critter/flock))
#define isflockstructure(x) (istype(x, /obj/flock_structure))