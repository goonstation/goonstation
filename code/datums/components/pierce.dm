/datum/component/limited_wallpierce
	var/pierces_left = 1 //default to 1 wall

/datum/component/limited_wallpierce/Initialize(var/num_pierces)
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	if(num_pierces)
		src.pierces_left=num_pierces
	RegisterSignal(parent, list(COMSIG_PROJ_PASS_DENSE_OBJ, COMSIG_PROJ_PASS_DENSE_TURF), .proc/update_pierces)

/datum/component/limited_wallpierce/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	if(--pierces_left <= 0)
		P.goes_through_walls = 0