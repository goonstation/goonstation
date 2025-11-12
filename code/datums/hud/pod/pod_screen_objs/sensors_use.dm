/atom/movable/screen/hud/pod/sensors_use
	name = "Activate Sensors"
	desc = "Use the pod's sensors to search for vehicles and lifeforms nearby."
	icon_state = "sensors-use"
	tooltip_options = list("theme" = "pod")
	pod_part_id = POD_PART_SENSORS
	dependent_parts = list(POD_PART_SENSORS)

/atom/movable/screen/hud/pod/sensors_use/on_click(mob/user)
	var/obj/item/shipcomponent/sensors_part = src.pod_hud.master.get_part(POD_PART_SENSORS)
	if (!istype(sensors_part) || !sensors_part.active)
		return FALSE

	sensors_part.opencomputer(user)
	return TRUE
