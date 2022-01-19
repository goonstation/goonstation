/obj/machinery/communications_dish/transception
	name = "Transception Array"
	desc = "Sends and receives both energy and matter over considerable distance. Figuratively, but hopefully not literally, duct-taped together."
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "arrayPLACEHOLDER"
	bound_height = 64
	bound_width = 96

	New()
		..()
		src.UpdateIcon()

/obj/machinery/communications_dish/transception/update_icon()
	var/image/glowy = SafeGetOverlayImage("glows", 'icons/obj/machines/transception.dmi', "glowPLACEHOLDER")
	glowy.plane = PLANE_SELFILLUM
	UpdateOverlays(glowy, "glows", 0, 1)

	var/image/lat = SafeGetOverlayImage("lattices", 'icons/obj/machines/transception.dmi', "latticesPLACEHOLDER")
	lat.plane = PLANE_SELFILLUM + 1
	UpdateOverlays(lat, "lattices", 0, 1)
