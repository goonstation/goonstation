/atom/movable/screen/hud/pod/lights
	name = "Toggle Lights"
	desc = "Turn the pod's external lights on or off."
	icon_state = "lights-off"
	tooltip_options = list("theme" = "pod")
	base_name = "Lights"
	pod_part_id = POD_PART_LIGHTS

/atom/movable/screen/hud/pod/lights/update_state()
	var/obj/item/shipcomponent/pod_lights/lights_part = src.pod_hud.master.get_part(POD_PART_LIGHTS)
	if (!istype(lights_part))
		return

	if (lights_part.active)
		src.icon_state = "[lights_part.hud_state]-on"
	else
		src.icon_state = "[lights_part.hud_state]-off"
