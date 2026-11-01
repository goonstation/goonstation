/atom/movable/screen/hud/pod/comms_use
	name = "Use Comms System"
	desc = "Use the communications system to talk or whatever."
	icon_state = "comms_system"
	tooltip_options = list("theme" = "pod")
	pod_part_id = POD_PART_COMMS
	dependent_parts = list(POD_PART_COMMS)

/atom/movable/screen/hud/pod/comms_use/on_click(mob/user)
	var/obj/item/shipcomponent/communications/comms_part = src.pod_hud.master.get_part(POD_PART_COMMS)
	if (!istype(comms_part))
		boutput(user, "[src.pod_hud.master.ship_message("System not installed in ship!")]")
		return FALSE

	if (!comms_part.active)
		boutput(user, "[src.pod_hud.master.ship_message("SYSTEM OFFLINE")]")
		return FALSE

	comms_part.External()
	return TRUE
