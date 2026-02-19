/atom/movable/screen/hud/pod/engine
	name = "Engine"
	desc = "Turn the pod's engine on or off."
	icon_state = "engine-off"
	tooltip_options = list("theme" = "pod-alt")
	base_name = "Engine"
	base_icon_state = "engine"
	pod_part_id = POD_PART_ENGINE

/atom/movable/screen/hud/pod/engine/on_click(mob/user)
	if (user != src.pod_hud.master.pilot)
		boutput(user, SPAN_ALERT("Only the pilot may do that!"))
		return FALSE

	. = ..()
