/datum/component/complexsignal/outermost_movable
	var/list/atom/movable/loc_chain

/datum/component/complexsignal/outermost_movable/proc/get_outermost_movable()
	RETURN_TYPE(/atom/movable)
	return loc_chain[length(loc_chain)]

/datum/component/complexsignal/outermost_movable/proc/on_loc_change()
	var/atom/movable/old_outermost = src.get_outermost_movable()
	var/atom/movable/loc_crawl = parent
	var/break_index = 0
	var/current_index = 1
	for(var/atom/movable/AM as anything in loc_chain)
		if(!break_index && loc_crawl != AM)
			break_index = current_index
		if(break_index) // chain broken
			src.UnregisterSignal(AM, COMSIG_MOVABLE_SET_LOC)
		if(!break_index)
			loc_crawl = loc_crawl.loc
		current_index++

	if(break_index)
		loc_chain.len = break_index - 1 // cut away the incorrect locs

	loc_crawl = loc_chain[length(loc_chain)].loc
	while(ismovable(loc_crawl))
		loc_chain += loc_crawl
		src.RegisterSignal(loc_crawl, COMSIG_MOVABLE_SET_LOC, .proc/on_loc_change)
		loc_crawl = loc_crawl.loc

	SEND_COMPLEX_SIGNAL(src, COMSIG_OUTERMOST_MOVABLE_CHANGED, old_outermost, src.get_outermost_movable())

/datum/component/complexsignal/outermost_movable/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.RegisterSignal(parent, COMSIG_MOVABLE_SET_LOC, .proc/on_loc_change)
	src.loc_chain = list(parent)
	src.on_loc_change()
	. = ..()

/datum/component/complexsignal/outermost_movable/UnregisterFromParent()
	var/atom/movable/outermost = src.get_outermost_movable()
	for(var/atom/movable/AM as anything in loc_chain)
		if(AM != outermost)
			AM.UnregisterSignal(src, COMSIG_MOVABLE_SET_LOC)
	src.loc_chain.len = 0
	. = ..()
