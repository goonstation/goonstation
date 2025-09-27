/atom/movable/screen/hud/pod/comms
	name = "Comms"
	desc = "Turn the pod's communications system on or off."
	icon_state = "comms-off"
	tooltip_options = list("theme" = "pod-alt")
	base_name = "Comms"
	base_icon_state = "comms"
	pod_part_id = POD_PART_COMMS

/atom/movable/screen/hud/pod/comms/on_click(mob/user)
	. = ..()
	if (!.)
		return

	src.pod_hud.update_systems()
