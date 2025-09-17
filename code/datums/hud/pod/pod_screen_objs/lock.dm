/atom/movable/screen/hud/pod/lock
	name = "Lock"
	desc = "Lock or unlock the pod."
	icon_state = "lock-locked"
	tooltip_options = list("theme" = "pod-alt")
	base_name = "Lock"
	pod_part_id = POD_PART_LOCK

/atom/movable/screen/hud/pod/lock/on_click(mob/user)
	var/obj/item/shipcomponent/secondary_system/lock/lock_part = src.pod_hud.master.get_part(POD_PART_LOCK)
	if (!istype(lock_part))
		return FALSE

	if (!lock_part.is_set())
		src.pod_hud.master?.locked = FALSE
		lock_part.configure_mode = TRUE
		lock_part.code = ""
		lock_part.show_lock_panel(user)

	else if (src.pod_hud.master.locked)
		src.pod_hud.master.locked = FALSE
		boutput(user, SPAN_ALERT("The ship mechanism clicks unlocked."))

	else
		src.pod_hud.master.locked = TRUE
		boutput(user, SPAN_ALERT("The lock mechanism clunks locked."))

	return TRUE

/atom/movable/screen/hud/pod/lock/update_state()
	var/obj/item/shipcomponent/secondary_system/lock/lock_part = src.pod_hud.master.get_part(POD_PART_LOCK)
	if (!istype(lock_part))
		return

	if (lock_part.is_set() && src.pod_hud.master.locked)
		src.icon_state = "lock-locked"
	else
		src.icon_state = "lock-unlocked"

/atom/movable/screen/hud/pod/lock/update_system()
	. = ..()

	var/obj/item/shipcomponent/secondary_system/lock/lock_part = src.pod_hud.master.get_part(POD_PART_LOCK)
	if (istype(lock_part) && !src.pod_hud.master.locked)
		src.icon_state = "lock-unlocked"
	else
		src.icon_state = "lock-locked"
