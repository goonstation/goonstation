/datum/component/loc_invisibility
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/old_invis = null

TYPEINFO(/datum/component/loc_invisibility)
	initialization_args = list()

/datum/component/loc_invisibility/Initialize()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_SET_LOC, .proc/on_set_loc)
	RegisterSignal(parent, COMSIG_ATOM_PROP_MOB_INVISIBILITY, .proc/on_invis_change)

/datum/component/loc_invisibility/RegisterWithParent()
	. = ..()
	var/mob/M = parent
	if(ismovable(M.loc))
		src.old_invis = M.loc.invisibility
		M.loc.invisibility = M.invisibility

/datum/component/loc_invisibility/proc/on_set_loc(mob/M, atom/old_loc)
	if(ismovable(old_loc) && !isnull(src.old_invis))
		old_loc.invisibility = src.old_invis
		src.old_invis = null
	if(ismovable(M.loc))
		src.old_invis = M.loc.invisibility
		M.loc.invisibility = M.invisibility

/datum/component/loc_invisibility/proc/on_invis_change(mob/M)
	if(ismovable(M.loc))
		M.loc.invisibility = M.invisibility

/datum/component/loc_invisibility/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_SET_LOC, COMSIG_ATOM_PROP_MOB_INVISIBILITY))
	. = ..()
