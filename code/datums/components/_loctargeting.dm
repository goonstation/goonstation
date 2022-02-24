/datum/component/loctargeting
	var/list/signals = list()
	var/proctype // = .proc/pass
	var/loctype = /atom/movable
	var/atom/current_loc

TYPEINFO(/datum/component/loctargeting)
	initialization_args = list()

/datum/component/loctargeting/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/loctargeting/proc/on_change_loc(atom/movable/source, atom/old_loc)
	if(old_loc == current_loc)
		src.current_loc = null
		src.on_removed(source, old_loc)
	if(istype(source.loc, loctype))
		src.current_loc = source.loc
		src.on_added(source, old_loc)

/datum/component/loctargeting/proc/on_added(atom/movable/source, atom/old_loc)
	RegisterSignal(source.loc, signals, proctype, TRUE)

/datum/component/loctargeting/proc/on_removed(atom/movable/source, atom/old_loc)
	UnregisterSignal(old_loc, signals)

/datum/component/loctargeting/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_SET_LOC, .proc/on_change_loc)
	var/atom/movable/source = parent
	if(istype(source.loc, loctype))
		src.current_loc = source.loc
		on_added(source, null)

/datum/component/loctargeting/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_SET_LOC)
	if(current_loc)
		UnregisterSignal(current_loc, signals)
		current_loc = null
	. = ..()
