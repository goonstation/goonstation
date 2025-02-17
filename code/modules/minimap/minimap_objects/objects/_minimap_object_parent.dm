/**
 *	Minimap objects are responsible for displaying and handling player interaction with minimaps. They act as the physical
 *	manifestation of minimap datums, being displayed either on the map or in a UI element.
 */
/obj/minimap
	name = "Station Map"
	layer = TURF_LAYER
	anchored = ANCHORED

	/// The minimap datum for this minimap object, containing data on the appearance and scale of the minimap, handling resizes, and managing markers.
	var/datum/minimap/map
	/// The minimap type path that `map` should use.
	var/map_path = /datum/minimap
	/// A bitflag that will be passed to the datum and determines which areas and minimap markers are to be rendered on the minimap. For available flags, see `_std/defines/minimap.dm`.
	var/map_type
	/// The desired scale of the physical map, as a multiple of the original size (300x300px).
	var/map_scale = 1

/obj/minimap/New()
	. = ..()
	START_TRACKING
	if (global.current_state > GAME_STATE_WORLD_NEW)
		src.initialise_minimap()

/obj/minimap/disposing()
	QDEL_NULL(map)
	vis_contents = null
	STOP_TRACKING
	. = ..()

/// Set up this minimap object's minimap datum and click overlay.
/obj/minimap/proc/initialise_minimap()
	src.map = new map_path(src.map_scale, src.map_type)
	src.vis_contents += src.map.minimap_holder

	// As the minimap render is transparent to clicks, the minimap will require an overlay which clicks may register on.
	if (!src.icon || !src.icon_state)
		var/icon/click_overlay_icon = icon('icons/obj/minimap/minimap.dmi', "blank")
		click_overlay_icon.Scale(src.map.x_max * map_scale, src.map.y_max * map_scale)
		click_overlay_icon.ChangeOpacity(0)
		src.icon = click_overlay_icon
		src.mouse_opacity = 2

/obj/minimap/proc/get_turf_at_screen_coords(screen_x,screen_y)
	var/x = round((screen_x - src.map.minimap_render.pixel_x) / (src.map.zoom_coefficient * src.map.map_scale))
	var/y = round((screen_y - src.map.minimap_render.pixel_y) / (src.map.zoom_coefficient * src.map.map_scale))
	return locate(x, y, map.z_level)
