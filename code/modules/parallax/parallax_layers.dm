// Space Layers
/atom/movable/screen/parallax_layer/space_1
	parallax_icon_state = "space_1"
	parallax_value = 0

	south
		parallax_value = 0.005
		scroll_speed = 240
		scroll_angle = 180

	west
		parallax_value = 0.005
		scroll_speed = 240
		scroll_angle = 270

/atom/movable/screen/parallax_layer/space_2
	parallax_icon_state = "space_2"
	parallax_value = 0.009
	blend_mode = BLEND_ADD

	south
		scroll_speed = 240
		scroll_angle = 180

	west
		scroll_speed = 240
		scroll_angle = 270


// Typhon
/atom/movable/screen/parallax_layer/typhon
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


// Planets
/atom/movable/screen/parallax_layer/planet
	parallax_icon = 'icons/misc/512x512.dmi'
	static_colour = TRUE
	parallax_value = 0.03
	tessellate = FALSE

	mundus
		parallax_icon_state = "mundus"
		initial_x_coordinate = 300
		initial_y_coordinate = -100

	iustitia
		parallax_icon_state = "iustitia"
		initial_x_coordinate = 65
		initial_y_coordinate = 0


// Asteroid Layers
/atom/movable/screen/parallax_layer/asteroids_far
	parallax_icon_state = "asteroids_far"
	static_colour = TRUE
	parallax_value = 0.06

	kondaru
		scroll_speed = 100
		scroll_angle = 98

/atom/movable/screen/parallax_layer/asteroids_near
	parallax_icon_state = "asteroids_near"
	static_colour = TRUE
	parallax_value = 0.1

	sparse
		parallax_icon_state = "asteroids_sparse"
		parallax_value = 0.15


// Void Layers
/atom/movable/screen/parallax_layer/void
	parallax_icon_state = "void"
	parallax_value = 0.1

/atom/movable/screen/parallax_layer/void_clouds_1
	parallax_icon_state = "void_clouds_1"
	parallax_value = 0.4
	blend_mode = BLEND_ADD

/atom/movable/screen/parallax_layer/void_clouds_2
	parallax_icon_state = "void_clouds_2"
	parallax_value = 0.7
	blend_mode = BLEND_ADD


// Miscellaneous Layers
/atom/movable/screen/parallax_layer/blowout_clouds
	parallax_icon_state = "blowout_clouds"
	static_colour = TRUE
	parallax_value = 0.5
	blend_mode = BLEND_ADD
	scroll_speed = 500
	scroll_angle = 240

/atom/movable/screen/parallax_layer/meteor_shower
	parallax_icon_state = "meteors"
	static_colour = TRUE
	parallax_value = 0.5
	scroll_speed = 500
