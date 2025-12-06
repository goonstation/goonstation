/atom/movable/screen/hud/pod/leave_pod
	name = "Leave Pod"
	desc = "Get out of the pod."
	icon_state = "leave"
	tooltip_options = list("theme" = "pod-alt", "align" = TOOLTIP_TOP | TOOLTIP_RIGHT)

/atom/movable/screen/hud/pod/leave_pod/on_click(mob/user)
	src.pod_hud.master.leave_pod(user)
	return TRUE
