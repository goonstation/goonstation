/atom/movable/screen/hud/pod/set_lock_code
	name = "Set Lock Code"
	desc = "Set the code used to unlock the pod."
	icon_state = "set-code"
	tooltip_options = list("theme" = "pod")
	pod_part_id = POD_PART_LOCK

/atom/movable/screen/hud/pod/set_lock_code/on_click(mob/user)
	var/obj/item/shipcomponent/secondary_system/lock/lock_part = src.pod_hud.master.get_part(POD_PART_LOCK)
	if (!istype(lock_part))
		return FALSE

	if (lock_part.is_set())
		if (!lock_part.can_reset)
			boutput(user, SPAN_NOTICE("This lock cannot have its code reset."))
			return FALSE

		boutput(user, SPAN_NOTICE("Code reset. Please type new code and press enter."))

	src.pod_hud.master?.locked = FALSE
	lock_part.configure_mode = TRUE
	lock_part.code = ""
	lock_part.show_lock_panel(user)

/atom/movable/screen/hud/pod/set_lock_code/update_system()
	src.overlays = list()

	var/obj/item/shipcomponent/secondary_system/lock/dependent_pod_part = src.pod_hud.master.get_part(POD_PART_LOCK)
	if (!istype(dependent_pod_part))
		src.overlays += image('icons/mob/hud_pod.dmi', "marker")
