/datum/component/gaseous_projectile // and non-opaque blobtiles
	var/pierces_left = 1 //default to 1 wall

/datum/component/gaseous_projectile/Initialize(var/num_pierces)
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	if(num_pierces)
		src.pierces_left=num_pierces
	RegisterSignal(parent, list(COMSIG_PROJ_COLLIDE), .proc/update_pierces)

/datum/component/gaseous_projectile/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	var/turf/T = get_turf(hit)
	return PROJ_ATOM_PASSTHROUGH * !!T.CanPass(null, get_turf(P), 0, 1)

/datum/component/gaseous_projectile/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PROJ_COLLIDE)
	. = ..()
