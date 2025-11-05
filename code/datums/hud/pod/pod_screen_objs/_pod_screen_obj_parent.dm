/atom/movable/screen/hud/pod
	icon = 'icons/mob/hud_pod.dmi'
	show_tooltip = TRUE
	var/base_name = ""
	var/base_icon_state = ""
	var/datum/hud/pod/pod_hud = null
	var/pod_part_id = null
	var/list/dependent_parts = null

/atom/movable/screen/hud/pod/New(loc, datum/hud/pod/pod_hud)
	src.master = pod_hud
	src.pod_hud = pod_hud
	. = ..()

/atom/movable/screen/hud/pod/clicked(list/params)
	var/mob/user = usr
	if (!istype(src.pod_hud) || !istype(user))
		return

	if (user.loc != src.pod_hud.master)
		boutput(user, SPAN_ALERT("You're not in the pod doofus. (Call 1-800-CODER.)"))
		src.pod_hud.remove_client(user.client)
		return

	if (!can_act(user))
		boutput(user, SPAN_ALERT("Not when you are incapacitated or restrained."))
		return

	src.on_click(user)
	src.pod_hud.update_states()

/atom/movable/screen/hud/pod/proc/on_click(mob/user)
	var/obj/item/shipcomponent/pod_part = src.pod_hud.master.get_part(src.pod_part_id)
	if (!istype(pod_part))
		return FALSE

	pod_part.toggle()
	src.pod_hud.switch_sound()
	return TRUE

/atom/movable/screen/hud/pod/proc/update_state()
	if (length(src.dependent_parts))
		src.overlays = list()
		for (var/part_id as anything in src.dependent_parts)
			var/obj/item/shipcomponent/dependent_pod_part = src.pod_hud.master.get_part(part_id)
			if (istype(dependent_pod_part) && dependent_pod_part.active)
				continue

			src.overlays += image('icons/mob/hud_pod.dmi', "marker")
			break

		return

	if (src.base_icon_state)
		var/obj/item/shipcomponent/pod_part = src.pod_hud.master.get_part(src.pod_part_id)
		if (istype(pod_part))
			if (pod_part.active)
				src.icon_state = "[src.base_icon_state]-on"
			else
				src.icon_state = "[src.base_icon_state]-off"

/atom/movable/screen/hud/pod/proc/update_system()
	if (length(src.dependent_parts))
		src.update_state()
		return

	if (src.base_name)
		var/obj/item/shipcomponent/pod_part = src.pod_hud.master.get_part(src.pod_part_id)
		if (istype(pod_part))
			src.name = pod_part.name
			src.overlays = list()
		else
			src.name = src.base_name
			src.overlays += image('icons/mob/hud_pod.dmi', "marker")


/atom/movable/screen/hud/pod/read_only
	mouse_opacity = FALSE
	show_tooltip = FALSE

/atom/movable/screen/hud/pod/read_only/on_click()
	return

/atom/movable/screen/hud/pod/read_only/update_state()
	return

/atom/movable/screen/hud/pod/read_only/update_system()
	return
