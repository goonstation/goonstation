/atom/movable/screen/hud/pod/leave_pod
	name = "Leave Pod"
	desc = "Get out of the pod."
	icon_state = "leave"
	tooltip_options = list("theme" = "pod-alt", "align" = TOOLTIP_TOP | TOOLTIP_RIGHT)

// short-circuit ghostcritter pod interaction ban
/atom/movable/screen/hud/pod/leave_pod/clicked(list/params)
	var/mob/user = usr
	if (isghostcritter(user))
		src.on_click(user)
		src.pod_hud.update_states()
		return
	. = ..()

/atom/movable/screen/hud/pod/leave_pod/on_click(mob/user)
	src.pod_hud.master.leave_pod(user)
	return TRUE
