/datum/component/pierce_non_opaque // and non-opaque blobtiles
	var/pierces_left = 1 //default to 1 wall

/datum/component/pierce_non_opaque/Initialize(var/num_pierces)
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	if(num_pierces)
		src.pierces_left=num_pierces
	RegisterSignal(parent, list(COMSIG_PROJ_COLLIDE), .proc/update_pierces)

/datum/component/pierce_non_opaque/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	if(!hit.opacity)
		return PROJ_ATOM_PASSTHROUGH

/datum/component/pierce_non_opaque/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PROJ_COLLIDE)
	. = ..()
