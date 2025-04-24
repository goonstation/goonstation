// Z-Level Parallax Layers
#define Z_LEVEL_PARALLAX_RENDER_SOURCE_GROUP(_Z) \
/datum/parallax_render_source_group/z_level/z_##_Z{z_level = _Z}; \
/datum/parallax_render_source_group/z_level/z_##_Z/New() { \
	src.parallax_render_source_types = map_settings.Z_LEVEL_PARALLAX_RENDER_SOURCES(_Z); \
	. = ..(); \
}

Z_LEVEL_PARALLAX_RENDER_SOURCE_GROUP(0)
Z_LEVEL_PARALLAX_RENDER_SOURCE_GROUP(1)
Z_LEVEL_PARALLAX_RENDER_SOURCE_GROUP(2)
Z_LEVEL_PARALLAX_RENDER_SOURCE_GROUP(3)
Z_LEVEL_PARALLAX_RENDER_SOURCE_GROUP(4)
Z_LEVEL_PARALLAX_RENDER_SOURCE_GROUP(5)

#undef Z_LEVEL_PARALLAX_RENDER_SOURCE_GROUP


// Area Parallax Layers
/datum/parallax_render_source_group/area/cairngorm
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1,
		/atom/movable/screen/parallax_render_source/space_2,
		/atom/movable/screen/parallax_render_source/asteroids_near/sparse,
	)

/datum/parallax_render_source_group/area/assault_pod
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1/south,
		/atom/movable/screen/parallax_render_source/space_2/south,
		/atom/movable/screen/parallax_render_source/asteroids_near/sparse/south,
	)

/datum/parallax_render_source_group/area/wizard_den
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1,
		/atom/movable/screen/parallax_render_source/space_2,
		/atom/movable/screen/parallax_render_source/asteroids_near/sparse,
	)

/datum/parallax_render_source_group/area/magpie
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1,
		/atom/movable/screen/parallax_render_source/space_2,
		/atom/movable/screen/parallax_render_source/asteroids_far,
	)

/datum/parallax_render_source_group/area/pirate
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1,
		/atom/movable/screen/parallax_render_source/space_2,
		/atom/movable/screen/parallax_render_source/asteroids_far,
	)

/datum/parallax_render_source_group/area/void
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/void,
		/atom/movable/screen/parallax_render_source/void/clouds_1,
		/atom/movable/screen/parallax_render_source/void/clouds_2,
	)

/datum/parallax_render_source_group/area/ice_moon
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/foreground/snow,
		/atom/movable/screen/parallax_render_source/foreground/snow/sparse,
	)

/datum/parallax_render_source_group/area/io_moon
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/foreground/embers,
		/atom/movable/screen/parallax_render_source/foreground/embers/sparse,
	)

/datum/parallax_render_source_group/area/mars
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/foreground/dust,
		/atom/movable/screen/parallax_render_source/foreground/dust/sparse,
	)

/datum/parallax_render_source_group/area/owlery
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1,
		/atom/movable/screen/parallax_render_source/space_2,
		/atom/movable/screen/parallax_render_source/typhon/donut3,
		/atom/movable/screen/parallax_render_source/asteroids_far,
		/atom/movable/screen/parallax_render_source/asteroids_near,
	)

/datum/parallax_render_source_group/area/observatory
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1,
		/atom/movable/screen/parallax_render_source/space_2,
		/atom/movable/screen/parallax_render_source/asteroids_far,
	)

/datum/parallax_render_source_group/area/grillnasium
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1,
		/atom/movable/screen/parallax_render_source/space_2,
		/atom/movable/screen/parallax_render_source/asteroids_far,
	)

/datum/parallax_render_source_group/area/ntps
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_1,
		/atom/movable/screen/parallax_render_source/space_2,
	)

/datum/parallax_render_source_group/area/watchful_eye_sensor
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/space_2,
		/atom/movable/screen/parallax_render_source/void/clouds_1,
		/atom/movable/screen/parallax_render_source/void/clouds_2,
		/atom/movable/screen/parallax_render_source/asteroids_near/sparse,
		/atom/movable/screen/parallax_render_source/typhon
	)

// Planet Parallax Layers
/datum/parallax_render_source_group/planet/snow
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/foreground/snow,
		/atom/movable/screen/parallax_render_source/foreground/snow/sparse,
		)

/datum/parallax_render_source_group/planet/snow/setup_render_sources()
	var/angle = rand(110, 250)
	var/scroll_speed = rand(50, 100)
	var/colour_alpha = rand(30, 60) / 100
	var/colour_matrix = list(
		1, 0, 0, colour_alpha,
		0, 1, 0, colour_alpha,
		0, 0, 1, colour_alpha,
		0, 0, 0, 1,
		0, 0, 0, -1,
		)

	var/atom/movable/screen/parallax_render_source/snow_layer = src.parallax_render_source_types_and_sources[/atom/movable/screen/parallax_render_source/foreground/snow]
	snow_layer.color = colour_matrix
	snow_layer.scroll_speed = scroll_speed
	snow_layer.scroll_angle = angle

	var/atom/movable/screen/parallax_render_source/sparse_snow_layer = src.parallax_render_source_types_and_sources[/atom/movable/screen/parallax_render_source/foreground/snow/sparse]
	sparse_snow_layer.color = colour_matrix
	sparse_snow_layer.scroll_speed = scroll_speed + 25
	sparse_snow_layer.scroll_angle = angle

/datum/parallax_render_source_group/planet/desert
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/foreground/dust,
		/atom/movable/screen/parallax_render_source/foreground/dust/sparse,
	)

/datum/parallax_render_source_group/planet/lava_moon
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/foreground/embers,
	)

/datum/parallax_render_source_group/planet/desert/setup_render_sources()
	var/angle = rand(110, 250)
	var/scroll_speed = rand(75, 175)
	var/colour_alpha = rand(40, 80) / 100
	var/colour_matrix = list(
		1, 0, 0, colour_alpha,
		0, 1, 0, colour_alpha,
		0, 0, 1, colour_alpha,
		0, 0, 0, 1,
		0, 0, 0, -1,
	)

	var/atom/movable/screen/parallax_render_source/dust_layer = src.parallax_render_source_types_and_sources[/atom/movable/screen/parallax_render_source/foreground/dust]
	dust_layer.color = colour_matrix
	dust_layer.scroll_speed = scroll_speed
	dust_layer.scroll_angle = angle

	var/atom/movable/screen/parallax_render_source/sparse_dust_layer = src.parallax_render_source_types_and_sources[/atom/movable/screen/parallax_render_source/foreground/dust/sparse]
	sparse_dust_layer.color = colour_matrix
	sparse_dust_layer.scroll_speed = scroll_speed * 1.5
	sparse_dust_layer.scroll_angle = angle

/datum/parallax_render_source_group/planet/forest
	parallax_render_source_types = list(
		/atom/movable/screen/parallax_render_source/foreground/clouds,
	)

/datum/parallax_render_source_group/planet/forest/setup_render_sources()
	var/angle = rand(90, 270)

	if(prob(20))
		src.add_parallax_render_source(/atom/movable/screen/parallax_render_source/foreground/clouds/dense)
		src.parallax_render_source_types_and_sources[/atom/movable/screen/parallax_render_source/foreground/clouds/dense].scroll_angle = angle + rand(5, 5)

	if(prob(20))
		src.add_parallax_render_source(/atom/movable/screen/parallax_render_source/foreground/clouds/sparse)
		src.parallax_render_source_types_and_sources[/atom/movable/screen/parallax_render_source/foreground/clouds/sparse].scroll_angle = angle + rand(5, 5)

	if(prob(20))
		src.add_parallax_render_source(/atom/movable/screen/parallax_render_source/foreground/snow)
		src.parallax_render_source_types_and_sources[/atom/movable/screen/parallax_render_source/foreground/snow].scroll_speed = rand(1, 5)
