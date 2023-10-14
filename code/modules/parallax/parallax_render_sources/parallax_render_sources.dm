/atom/movable/screen/parallax_render_source/foreground
	plane = PLANE_FOREGROUND_PARALLAX

// ================= Space Layers =================
/atom/movable/screen/parallax_render_source/space_1
	parallax_icon_state = "space_1"
	parallax_value = 0

/atom/movable/screen/parallax_render_source/space_1/south
	parallax_value = 0.005
	scroll_speed = 240
	scroll_angle = 180

/atom/movable/screen/parallax_render_source/space_1/west
	parallax_value = 0.005
	scroll_speed = 240
	scroll_angle = 270


/atom/movable/screen/parallax_render_source/space_2
	parallax_icon_state = "space_2"
	parallax_value = 0.009
	blend_mode = BLEND_ADD

/atom/movable/screen/parallax_render_source/space_2/south
	scroll_speed = 240
	scroll_angle = 180

/atom/movable/screen/parallax_render_source/space_2/west
	scroll_speed = 240
	scroll_angle = 270


// =================    Stars     =================
/atom/movable/screen/parallax_render_source/typhon
	parallax_icon = 'icons/misc/1024x1024.dmi'
	parallax_icon_state = "plasma_giant"
	static_colour = TRUE
	parallax_value = 0.015
	tessellate = FALSE

	cogmap
		initial_x_coordinate = 0
		initial_y_coordinate = 167

	cogmap2
		initial_x_coordinate = 300
		initial_y_coordinate = 140

	kondaru
		initial_x_coordinate = 150
		initial_y_coordinate = 500

	donut2
		initial_x_coordinate = 300
		initial_y_coordinate = 350

	donut3
		initial_x_coordinate = -50
		initial_y_coordinate = 350

	closer // for the debris field
		parallax_icon = 'icons/misc/1024x1024.dmi'
		parallax_icon_state = "plasma_giant"
		initial_x_coordinate = -50
		initial_y_coordinate = 350
		parallax_value = 0.02

	further // for the mining level
		parallax_icon = 'icons/misc/1024x1024.dmi'
		parallax_icon_state = "plasma_giant"
		initial_x_coordinate = -50
		initial_y_coordinate = 350
		parallax_value = 0.01

// for lore reasons, only one of fugere or sid should be visible at a time really.
/atom/movable/screen/parallax_render_source/fugere
	parallax_icon = 'icons/misc/galactic_objects_large.dmi'
	parallax_icon_state = "star-red"
	static_colour = TRUE
	parallax_value = 0.003
	tessellate = FALSE
	initial_x_coordinate = -300
	initial_y_coordinate = 450

/atom/movable/screen/parallax_render_source/sid
	parallax_icon = 'icons/misc/galactic_objects_large.dmi'
	parallax_icon_state = "star-blue"
	static_colour = TRUE
	parallax_value = 0.003
	tessellate = FALSE
	initial_x_coordinate = -300
	initial_y_coordinate = 450

// =================    Planets   =================
/atom/movable/screen/parallax_render_source/planet
	parallax_icon = 'icons/misc/512x512.dmi'
	static_colour = TRUE
	parallax_value = 0.03
	tessellate = FALSE
// RADIATION BELT DISTRICT PLANETS
	// we don't have any yet, lol. They are Pendus, Fortitudo and Antistes, for reference.
// MAIN RINGS DISTRICT PLANETS------------
/atom/movable/screen/parallax_render_source/planet/quadriga
	parallax_icon_state = "quadriga"
	initial_x_coordinate = 100
	initial_y_coordinate = -100

/atom/movable/screen/parallax_render_source/planet/amantes
	parallax_icon_state = "amantes"
	initial_x_coordinate = -200
	initial_y_coordinate = 50

/atom/movable/screen/parallax_render_source/planet/faatus
	parallax_icon_state = "faatus"
	initial_x_coordinate = 230
	initial_y_coordinate = 100

/atom/movable/screen/parallax_render_source/planet/faatus/domusDei
	parallax_icon_state = "domusDei"
	initial_x_coordinate = 230
	initial_y_coordinate = 100
	parallax_value = 0.035
	// this version is behind faatus instead of in front
	behind
		parallax_value = 0.025

// MUNDUS GAP DISTRICT PLANETS------------
/atom/movable/screen/parallax_render_source/planet/mundus
	parallax_icon_state = "mundus"
	initial_x_coordinate = 300
	initial_y_coordinate = -100

/atom/movable/screen/parallax_render_source/planet/mundus/iustitia
	parallax_icon_state = "iustitia"
	initial_x_coordinate = 65
	initial_y_coordinate = 0
	parallax_value = 0.035
	// This version is slightly behind mundus.
	behind
		parallax_value = 0.025

/atom/movable/screen/parallax_render_source/planet/mundus/iudicium
	parallax_icon_state = "iudicium"
	initial_x_coordinate = 45
	initial_y_coordinate = 200
	parallax_value = 0.035
	// this version is slightly behind mundus
	behind
		parallax_value = 0.025

/atom/movable/screen/parallax_render_source/planet/fortuna
	parallax_icon_state = "fortuna"
	initial_x_coordinate = 70
	initial_y_coordinate = 0

// ROYAL RINGS DISTRICT PLANETS------------
/atom/movable/screen/parallax_render_source/planet/mors
	parallax_icon_state = "mors"
	initial_x_coordinate = 40
	initial_y_coordinate = -100

/atom/movable/screen/parallax_render_source/planet/mors/regis
	parallax_icon_state = "regis"
	initial_x_coordinate = 40
	initial_y_coordinate = -100
	parallax_value = 0.035
	// version behind mors
	behind
		parallax_value = 0.025

// todo: magus and regina sprites
/atom/movable/screen/parallax_render_source/planet/magus
	parallax_icon_state = "magus"
	initial_x_coordinate = -50
	initial_y_coordinate = -10
/atom/movable/screen/parallax_render_source/planet/magus/regina
	parallax_icon_state = "regina"
	initial_x_coordinate = -30
	initial_y_coordinate = -20
	parallax_value = 0.035
	// version of regina behind magus
	behind
		parallax_value = 0.025

// NIFLHEIM BELT DISTRICT PLANETS------------
// todo

// ================= Asteroid Layers =================
/atom/movable/screen/parallax_render_source/asteroids_far
	parallax_icon_state = "asteroids_far"
	static_colour = TRUE
	parallax_value = 0.06

/atom/movable/screen/parallax_render_source/asteroids_far/kondaru
	scroll_speed = 100
	scroll_angle = 98


/atom/movable/screen/parallax_render_source/asteroids_near
	parallax_icon_state = "asteroids_near"
	static_colour = TRUE
	parallax_value = 0.1

/atom/movable/screen/parallax_render_source/asteroids_near/sparse
	parallax_icon_state = "asteroids_sparse"
	parallax_value = 0.15

/atom/movable/screen/parallax_render_source/asteroids_near/sparse/south
	scroll_speed = 240
	scroll_angle = 180


// ================= Miscellaneous Layers =================
/atom/movable/screen/parallax_render_source/blowout_clouds
	parallax_icon_state = "blowout_clouds"
	static_colour = TRUE
	parallax_value = 0.5
	blend_mode = BLEND_ADD
	scroll_speed = 500
	scroll_angle = 240

/atom/movable/screen/parallax_render_source/meteor_shower
	parallax_icon_state = "meteors"
	static_colour = TRUE
	parallax_value = 0.5
	scroll_speed = 500


// =================     Effects    =================

// Clouds
/atom/movable/screen/parallax_render_source/foreground/clouds
	parallax_icon_state = "clouds_3"
	color = list(
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, 1,
		0, 0, 0, 0)
	static_colour = TRUE
	parallax_value = 0.9
	scroll_speed = 5
	scroll_angle = 150

/atom/movable/screen/parallax_render_source/foreground/clouds/dense
	color = list(
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, 1,
		0, 0, 0, -0.5)
	parallax_icon_state = "clouds_1"
	parallax_value = 0.8
	scroll_speed = 1

/atom/movable/screen/parallax_render_source/foreground/clouds/sparse
	color = list(
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, 0,
		0, 0, 0, -0.4)
	parallax_icon_state = "clouds_2"
	parallax_value = 0.7
	scroll_speed = 10


// ================= Adventure Zones =================

// Snow Storm Layers
/atom/movable/screen/parallax_render_source/foreground/snow
	parallax_icon_state = "snow_dense"
	color = list(
		1, 0, 0, 0.4,
		0, 1, 0, 0.4,
		0, 0, 1, 0.4,
		0, 0, 0, 1,
		0, 0, 0, -1)
	static_colour = TRUE
	parallax_value = 0.8
	scroll_speed = 100
	scroll_angle = 240

/atom/movable/screen/parallax_render_source/foreground/snow/sparse
	parallax_icon_state = "snow_sparse"
	color = null
	blend_mode = BLEND_ADD
	parallax_value = 0.9
	scroll_speed = 150


// Dust Storm Layers
/atom/movable/screen/parallax_render_source/foreground/dust
	parallax_icon_state = "dust_dense"
	color = list(
		1, 0, 0, 0.8,
		0, 1, 0, 0.8,
		0, 0, 1, 0.8,
		0, 0, 0, 1,
		0, 0, 0, -1)
	static_colour = TRUE
	parallax_value = 0.8
	scroll_speed = 150
	scroll_angle = 240

/atom/movable/screen/parallax_render_source/foreground/dust/sparse
	parallax_icon_state = "dust_sparse"
	color = null
	blend_mode = BLEND_ADD
	parallax_value = 0.9
	scroll_speed = 225


// Embers Layers
/atom/movable/screen/parallax_render_source/foreground/embers
	parallax_icon_state = "embers_dense"
	color = list(
		1, 0, 0, -0.8,
		0, 1, 0, -0.8,
		0, 0, 1, -0.8,
		0, 0, 0, 1,
		0, 0, 0, -0.7)
	static_colour = TRUE
	parallax_value = 0.8
	scroll_speed = 25
	scroll_angle = 135

/atom/movable/screen/parallax_render_source/foreground/embers/sparse
	parallax_icon_state = "embers_sparse"
	color = null
	parallax_value = 0.9
	scroll_speed = 35


// Void Layers
/atom/movable/screen/parallax_render_source/void
	parallax_icon_state = "void"
	parallax_value = 0.1
	scroll_speed = 20
	scroll_angle = 150

/atom/movable/screen/parallax_render_source/void/clouds_1
	parallax_icon_state = "void_clouds_1"
	parallax_value = 0.4
	blend_mode = BLEND_ADD

/atom/movable/screen/parallax_render_source/void/clouds_2
	parallax_icon_state = "void_clouds_2"
	parallax_value = 0.7
	blend_mode = BLEND_ADD
