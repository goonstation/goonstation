/datum/component/pierce_mobs // and non-opaque blobtiles
	var/pierces_left = 1 //default to 1 wall

/datum/component/pierce_mobs/Initialize(var/num_pierces)
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	if(num_pierces)
		src.pierces_left=num_pierces
	RegisterSignal(parent, list(COMSIG_PROJ_COLLIDE), .proc/update_pierces)

/datum/component/pierce_mobs/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	var/turf/T = get_turf(hit)
	if(isrestrictedz(T.z))
		return 0
	if((ismob(hit) || (istype(hit, /obj/blob) && !hit.opacity)) && pierces_left-- > 0)
		return PROJ_ATOM_PASSTHROUGH

/datum/component/pierce_mobs/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PROJ_COLLIDE)
	. = ..()
