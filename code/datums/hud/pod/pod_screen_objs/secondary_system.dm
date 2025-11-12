/atom/movable/screen/hud/pod/secondary_system
	name = "Secondary System"
	desc = "Activate the secondary system installed in the pod, if there is one"
	icon_state = "blank"
	tooltip_options = list("theme" = "pod")
	base_name = "Secondary System"
	pod_part_id = POD_PART_SECONDARY

/atom/movable/screen/hud/pod/secondary_system/update_state()
	var/obj/item/shipcomponent/secondary_system/secondary_part = src.pod_hud.master.get_part(POD_PART_SECONDARY)
	if (!istype(secondary_part))
		return

	if (secondary_part.f_active)
		src.icon_state = secondary_part.hud_state
	else if (secondary_part.active)
		src.icon_state = "[secondary_part.hud_state]-on"
	else
		src.icon_state = "[secondary_part.hud_state]-off"

/atom/movable/screen/hud/pod/secondary_system/update_system()
	. = ..()

	var/obj/item/shipcomponent/secondary_system/secondary_part = src.pod_hud.master.get_part(POD_PART_SECONDARY)
	if (!istype(secondary_part))
		src.icon_state = "blank"
