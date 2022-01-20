/obj/machinery/communications_dish/transception
	name = "Transception Array"
	desc = "Sends and receives both energy and matter over considerable distance. Figuratively, but hopefully not literally, duct-taped together."
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "arrayPLACEHOLDER"
	bound_height = 64
	bound_width = 96

	New()
		. = ..()
		src.UpdateIcon()

	power_change()
		. = ..()
		src.UpdateIcon()

/obj/machinery/communications_dish/transception/update_icon()
	var/state = "glowPLACEHOLDER"
	if(!powered())
		state = "allquiet"
	var/image/glowy = SafeGetOverlayImage("glows", 'icons/obj/machines/transception.dmi', state)
	glowy.plane = PLANE_OVERLAY_EFFECTS
	UpdateOverlays(glowy, "glows", 0, 1)
