// this is sorta similar to /obj/adventurepuzzle/triggerable/light
// meant to replace those fucking instanced glow decals

/obj/map/light
	icon_state = "light"

	var
		brightness = 0
		color_r = 0.36
		color_g = 0.35
		color_b = 0.21

		datum/light/light

	New()
		..()
		if(!QDELETED(src)) //It's possible. Don't ask.
			light = new /datum/light/point
			light.attach(src)
			light.set_color(src.color_r, src.color_g, src.color_b)
			light.set_brightness(src.brightness / 5)
			light.enable()

	disposing()
		qdel(src.light)
		src.light = null
		..()

	// some common presets
	cyan
		name = "glow - CYAN";
		brightness = 4
		color_b = 0.4
		color_g = 0.3
		color_r = 0.2

	lava
		name = "glow - LAVA"
		brightness = 2.5
		color_b = 0.3
		color_g = 0.5
		color_r = 0.7

	yellow
		name = "glow - YELLOW"
		brightness = 3
		color_b = 0.2
		color_g = 0.45
		color_r = 0.5

	void
		name = "glow - VOID"
		brightness = 6
		color_b = 0.5
		color_g = 0.2
		color_r = 0.3

	white
		name = "glow - WHITE"
		brightness = 3
		color_b = 0.35
		color_g = 0.35
		color_r = 0.35

	screen
		name = "glow - SCREENS"
		brightness = 4
		color_b = 0.5
		color_g = 0.33
		color_r = 0.3

	graveyard
		name = "graveyard glow"
		brightness = 1
		color_b = 1
		color_g = 0.75
		color_r = 0.75

	dimreddish
		name = "glow - DIM REDDISH"
		brightness = 3
		color_b = 0.3
		color_g = 0.3
		color_r = 0.4

	dimred
		name = "glow - DIM RED"
		brightness = 4
		color_b = 0.3
		color_g = 0.3
		color_r = 0.42

	meatland
		name = "glow - MEATLAND"
		brightness = 4
		color_b = 0.1
		color_g = 0.35
		color_r = 0.5

	brightwhite
		name = "glow - BRIGHT WHITE"
		brightness = 4
		color_b = 0.35
		color_g = 0.35
		color_r = 0.35

	brighterwhite
		name = "glow - BRIGHTER WHITE"
		brightness = 5
		color_b = 0.35
		color_g = 0.35
		color_r = 0.35

	green
		icon_state = "lightG"
		name = "glow - GREEN"
		brightness = 3
		color_b = 0.2
		color_g = 0.7
		color_r = 0.2

	secretpink
		name = "glow - SECRET PINK"
		brightness = 5
		color_r = 0.9
		color_g = 0.65
		color_b = 0.7

	secretblue
		name = "glow - SECRET BLUE"
		brightness = 5
		color_r = 0.9
		color_g = 0.8
		color_b = 0.35

	secretwhite
		name = "glow - SECRET WHITE"
		brightness = 5
		color_r = 0.8
		color_g = 0.8
		color_b = 0.8

	pink
		name = "glow - PINK"
		brightness = 4
		color_r = 0.9
		color_g = 0.4
		color_b = 0.7

	purple
		name = "glow - PURPLE"
		brightness = 4
		color_r = 0.7
		color_g = 0.4
		color_b = 0.9
