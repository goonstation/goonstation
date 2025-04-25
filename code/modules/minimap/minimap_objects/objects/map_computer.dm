/obj/minimap/map_computer
	bound_width = 160
	bound_height = 160

	map_path = /datum/minimap/area_map

	icon = 'icons/obj/minimap/map_computer.dmi'
	icon_state = "frame"

	pixel_point = TRUE

	map_scale = 0.5

	var/light_r = 1
	var/light_g = 1
	var/light_b = 1

/obj/minimap/map_computer/initialise_minimap()
	. = ..()
	// Magic numbers to align the minimap with the physical frame of the map.
	src.map.minimap_holder.pixel_x += 5
	src.map.minimap_holder.pixel_y += 4

	src.create_overlays()

/obj/minimap/map_computer/proc/create_overlays()
	// Computer scanlines overlay.
	var/atom/movable/overlay/scanlines = new /atom/movable/overlay
	var/icon/scanlines_icon = icon('icons/obj/minimap/map_computer.dmi', "scanlines")
	scanlines_icon.ChangeOpacity(0.2)
	scanlines.icon = scanlines_icon
	scanlines.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
	scanlines.mouse_opacity = 0
	scanlines.color = "#303030" // The scanlines are by default white, allowing them to be recoloured.

	// Glass screen overlay.
	var/atom/movable/overlay/glass = new /atom/movable/overlay
	var/icon/glass_icon = icon('icons/obj/minimap/map_computer.dmi', "glass")
	glass_icon.ChangeOpacity(0.2)
	glass.icon = glass_icon
	glass.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
	glass.mouse_opacity = 0

	// Computer screen glow overlay.
	var/atom/movable/overlay/screen_light = new /atom/movable/overlay
	screen_light.icon = icon('icons/obj/minimap/map_computer.dmi', "screen_light")
	screen_light.vis_flags = VIS_INHERIT_ID
	screen_light.mouse_opacity = 0
	screen_light.plane = PLANE_LIGHTING
	screen_light.blend_mode = BLEND_ADD
	screen_light.layer = LIGHTING_LAYER_BASE
	screen_light.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)

	src.vis_contents += scanlines
	src.vis_contents += glass
	src.vis_contents += screen_light

	var/datum/light/light = new/datum/light/point
	light.set_brightness(1.3)
	light.set_color(src.light_r, src.light_g, src.light_b)
	light.set_height(2)
	light.attach(src, 2.5 + (src.pixel_x / 32), 2.5 + (src.pixel_y / 32))
	light.enable()


/obj/minimap/map_computer/nukeop
	name = "Atrium Station Map"
	desc = "A cutting-edge cathode ray tube monitor, actively rendering many dozens of kilobytes of stolen structural data."
	map_type = MAP_SYNDICATE

	light_r = 1
	light_g = 0.3
	light_b = 0.3

/obj/minimap/map_computer/nukeop/New()
	. = ..()
	START_TRACKING

/obj/minimap/map_computer/nukeop/disposing()
	STOP_TRACKING
	. = ..()


/obj/minimap/map_computer/pod_wars
	name = "Debris Field Map"
	desc = "A cutting-edge cathode ray tube monitor, actively rendering many dozens of kilobytes of reconnaissance data on the surrounding debris field."
	map_scale = 0.25


/obj/minimap/map_computer/pod_wars/nanotrasen
	map_type = MAP_POD_WARS_NANOTRASEN
	light_r = 0.3
	light_g = 0.3
	light_b = 1

/obj/minimap/map_computer/pod_wars/nanotrasen/New()
	. = ..()
	START_TRACKING

/obj/minimap/map_computer/pod_wars/nanotrasen/disposing()
	STOP_TRACKING
	. = ..()


/obj/minimap/map_computer/pod_wars/syndicate
	map_type = MAP_POD_WARS_SYNDICATE
	light_r = 1
	light_g = 0.3
	light_b = 0.3

/obj/minimap/map_computer/pod_wars/syndicate/New()
	. = ..()
	START_TRACKING

/obj/minimap/map_computer/pod_wars/syndicate/disposing()
	STOP_TRACKING
	. = ..()


/obj/minimap/map_computer/pod_wars/both_teams
	map_type = MAP_POD_WARS_NANOTRASEN | MAP_POD_WARS_SYNDICATE

/obj/minimap/map_computer/pod_wars/both_teams/New()
	. = ..()
	START_TRACKING

/obj/minimap/map_computer/pod_wars/both_teams/disposing()
	STOP_TRACKING
	. = ..()

/obj/minimap/map_computer/htr_team
	name = "Station Map"
	desc = "A cutting-edge cathode ray tube monitor, actively rendering a visualization of the target station."
	map_type = MAP_HTR_TEAM

	light_r = 0.3
	light_g = 0.3
	light_b = 1

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()
