
/// If this movable is in a slot in its loc this var contains the slot's name
/atom/movable/var/in_slot = null

/// Override this to
/atom/movable/proc/can_enter_slot(atom/movable/entering, slot)
	return FALSE

/atom/movable/proc/put_into_slot(atom/movable/new_loc, slot)
	SHOULD_NOT_OVERRIDE(TRUE)
