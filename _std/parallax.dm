/// Whether parallax has been enabled or disabled globally.
var/parallax_enabled = TRUE

/// An associative list of each z-level define and its corresponding parallax layer render source group. See `code\map\map_settings.dm` for the default parallax render sources for each z-level.
var/list/z_level_parallax_render_source_groups = list()
/// An associative list of parallax render source group types and the corresponding instance of that type.
var/list/area_parallax_render_source_groups = list()
/// An list of parallax render source group instances that are used within procedurally generated planets.
var/list/planet_parallax_render_source_groups = list()

/// Initialises `z_level_parallax_render_source_groups` by populating it with z-level parallax render source groups.
/proc/setup_z_level_parallax_render_sources()
	for (var/render_source_group_type as anything in concrete_typesof(/datum/parallax_render_source_group/z_level))
		var/datum/parallax_render_source_group/z_level/render_source_group = new render_source_group_type()
		z_level_parallax_render_source_groups["[render_source_group.z_level]"] = render_source_group

/// Returns a reference to the parallax render source group datum belonging to either an area or z-level.
/proc/get_parallax_render_source_group(z_level_or_area)
	RETURN_TYPE(/datum/parallax_render_source_group)

	// Z-levels.
	if (isnum(z_level_or_area))
		return z_level_parallax_render_source_groups["[z_level_or_area]"]

	if (!istype(z_level_or_area, /area))
		return

	// Areas, where `area_parallax_render_source_group` is a path.
	var/area/A = z_level_or_area
	if (ispath(A.area_parallax_render_source_group))
		var/group_path = A.area_parallax_render_source_group
		if(isnull(area_parallax_render_source_groups[group_path]))
			area_parallax_render_source_groups[group_path] = new group_path()

		return area_parallax_render_source_groups[group_path]

	// Planet areas, where `area_parallax_render_source_group` is a reference to an instance of a render source group.
	if (istype(A.area_parallax_render_source_group, /datum/parallax_render_source_group))
		return A.area_parallax_render_source_group

#define ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(z_level_or_area, render_source_type, animation_time) get_parallax_render_source_group(z_level_or_area)?.add_parallax_render_source(render_source_type, animation_time)
#define ADD_PARALLAX_RENDER_SOURCES_FROM_GROUP(z_level_or_area, render_group, animation_time) get_parallax_render_source_group(z_level_or_area)?.copy_parallax_render_sources_from_group(render_group, animation_time)
#define REMOVE_PARALLAX_RENDER_SOURCE_FROM_GROUP(z_level_or_area, render_source_type, animation_time) get_parallax_render_source_group(z_level_or_area)?.remove_parallax_render_source(render_source_type, animation_time)
#define REMOVE_ALL_PARALLAX_RENDER_SOURCES_FROM_GROUP(z_level_or_area) get_parallax_render_source_group(z_level_or_area)?.remove_parallax_render_source(get_parallax_render_source_group(z_level_or_area).parallax_render_source_types_and_sources)
#define RESTORE_PARALLAX_RENDER_SOURCE_GROUP_TO_DEFAULT(z_level_or_area) get_parallax_render_source_group(z_level_or_area)?.restore_parallax_render_sources_to_default()
#define RECOLOUR_PARALLAX_RENDER_SOURCES_IN_GROUP(z_level_or_area, colour, animation_time) get_parallax_render_source_group(z_level_or_area)?.recolour_parallax_render_sources(colour, animation_time)

#define GET_PARALLAX_RENDER_SOURCE_FROM_GROUP(z_level_or_area, render_source_type) get_parallax_render_source_group(z_level_or_area)?.parallax_render_source_types_and_sources[render_source_type]

#define VAR_Z_LEVEL_PARALLAX_RENDER_SOURCES(z_level) var/list/z_level_parallax_render_sources_##z_level
#define Z_LEVEL_PARALLAX_RENDER_SOURCES(z_level) z_level_parallax_render_sources_##z_level

/// Realigns the parallax layer so that the centremost tessellated tile occupies the position of the tessellated tile closest to the player.
#define UPDATE_TESSELLATION_ALIGNMENT(parallax_layer) if (parallax_layer.parallax_render_source.tessellate) { \
	var/pixel_x_offset = 0; \
	var/pixel_y_offset = 0; \
	if (parallax_layer.transform.c + parallax_layer.animation_pixel_x_offset > 0) { \
		pixel_x_offset -= parallax_layer.parallax_render_source.icon_width; \
	} \
	else if (parallax_layer.transform.c + parallax_layer.animation_pixel_x_offset < -(parallax_layer.parallax_render_source.icon_width)) { \
		pixel_x_offset += parallax_layer.parallax_render_source.icon_width; \
	} \
	if (parallax_layer.transform.f + parallax_layer.animation_pixel_y_offset > 0) { \
		pixel_y_offset -= parallax_layer.parallax_render_source.icon_height; \
	} \
	else if (parallax_layer.transform.f + parallax_layer.animation_pixel_y_offset < -(parallax_layer.parallax_render_source.icon_height)) { \
		pixel_y_offset += parallax_layer.parallax_render_source.icon_height; \
	} \
	if (pixel_x_offset || pixel_y_offset) { \
		parallax_layer.transform = parallax_layer.transform.Translate(pixel_x_offset, pixel_y_offset); \
	} \
}
