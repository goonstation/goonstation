//used for pods

#define BOARD_DIST_ALLOWED(M,V) ( can_reach(M, V) )
#define isvehicle(x) istype(x, /obj/machinery/vehicle) || istype(x, /obj/vehicle)
