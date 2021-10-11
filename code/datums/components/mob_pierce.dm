/datum/component/flamethrower_pierce // pierces /mob and /obj except windows and some blob)
	var/pierces_left = 1 //default to 1 wall

/datum/component/flamethrower_pierce/Initialize(var/num_pierces)
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	if(num_pierces)
		src.pierces_left=num_pierces
	RegisterSignal(parent, list(COMSIG_PROJ_COLLIDE), .proc/update_pierces)

/datum/component/flamethrower_pierce/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	if(isobj(hit))
		var/obj/hit_obj = hit
		if(HAS_FLAG(hit_obj.object_flags, BLOCKS_CHEMGAS_PROJ))
			return
		else
			return PROJ_ATOM_PASSTHROUGH
	if(ismob(hit))
		return PROJ_ATOM_PASSTHROUGH
	return

/datum/component/flamethrower_pierce/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PROJ_COLLIDE)
	. = ..()
