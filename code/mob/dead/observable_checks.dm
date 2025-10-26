/atom/proc/is_observable_by(var/mob/observer)
	var/list/all_observables = machine_registry[MACHINES_BOTS] + by_cat[TR_CAT_GHOST_OBSERVABLES]
	if(!(src in all_observables))
		return FALSE
	if(isnull(src.loc) && !isadmin(observer)) //nullspace will trap observers there, so you're gonna need an admin to get out
		return FALSE
	return TRUE

/mob/is_observable_by(var/mob/observer)
	. = ..(observer)
	if(!.)
		return FALSE
	if(isadmin(observer))
		return TRUE
	if(src.unobservable)
		return FALSE
	if(istype(get_area(src), /area/prison/cell_block/wards))
		return FALSE
	if(isadmin(src) && !src.client.player_mode) //TODO: Make this an admin pref
		return FALSE
	var/player_owned = (src.client == null && src.ghost == null)
	if(!player_owned && isrestrictedz(src.z))
		return FALSE
