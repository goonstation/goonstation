/obj/neon_lining
	anchored = 1
	icon = 'icons/obj/decals/neon_lining.dmi'
	icon_state = "base2"
	name = "neon lining"
	real_name = "neon lining"
	var/lining_shape = 2          												//Shapes: 1 = circle, 2 = _ that's a tile long, 3 = _ that's half a tile long, 4 = |_| shape, 5 = _| shape, 6 = _| shape but twice as wide & tall.
	var/lining_pattern = 0        												//Most shapes use patterns in such a way: 0 = no glow on the ends, 1 = glow on both ends, 2 = glow on one end, 3 = glow on the other end; Shape 3 has 4 additional patterns that are used for alternative positioning; Shape 1 only has a single pattern, 0; Shape 0 was removed during development as it was literally 3 pixels and was basically invisible & unclickable.
	var/lining_neOn = 1           												//The on/off variable: 0 = off, 1 = on. Yes, it's a pun.
	var/lining_color = "blue"          											//Colors: blue, pink, yellow.
	var/lining_rotation = 0		  												//Rotation: 0 = south, 1 = west, 2 = north, 3 = east.
	var/lining_icon_state = 1													//This is used for choosing the proper icon state for reasons stated in the lining_pattern comment.
	var/datum/light/light														//The light. Obviously.
	var/image/glow																//The overlay image which hosts the glowing parts.

	New()
		. = ..()
		glow = image('icons/obj/decals/neon_lining.dmi', "blue2_1")
		glow.plane = PLANE_SELFILLUM
		src.UpdateOverlays(glow, "glow")
		light = new /datum/light/point
		light.set_brightness(0.1)
		if (lining_color == "pink")
			light.set_color(108, 7, 67)
		else if (lining_color == "yellow")
			light.set_color(126, 114, 54)
		else
			light.set_color(17, 74, 124)
		light.attach(src)
		light.enable()

	proc/lining_UpdateIcon()
		if (lining_color == "pink")
			light.set_color(108, 7, 67)
		else if (lining_color == "yellow")
			light.set_color(126, 114, 54)
		else
			light.set_color(17, 74, 124)

		if (lining_pattern > 3)
			if (lining_pattern % 2)											//5 & 7
				lining_icon_state = (lining_pattern - 3) / 2
			else															//4 & 6
				lining_icon_state = ((lining_pattern - 4) / 2) + 1
		else
			if (lining_pattern % 2)											//1 & 3
				lining_icon_state = (lining_pattern + 1) / 2
			else															//0 & 2
				lining_icon_state = (lining_pattern / 2) + 1

		if (lining_pattern % 2)												//1,3,5,7
			if (lining_rotation == 0)
				set_dir(2)
			else if (lining_rotation == 1)
				set_dir(8)
			else if (lining_rotation == 2)
				set_dir(1)
			else
				set_dir(4)
		else																//0,2,4,6
			if (lining_rotation == 0)
				set_dir(6)
			else if (lining_rotation == 1)
				set_dir(9)
			else if (lining_rotation == 2)
				set_dir(10)
			else
				set_dir(5)

		if (lining_shape < 1 || lining_shape > 6)
			lining_shape = 1
		else if (lining_shape == 3)
			if (lining_pattern < 2)
				set_icon_state("base3_1")
				glow.icon_state = "[lining_color][lining_shape]_1"
				src.UpdateOverlays(glow, "glow")
			else if (lining_pattern > 1 && lining_pattern < 4)
				set_icon_state("base3_1")
				glow.icon_state = "[lining_color][lining_shape]_2"
				src.UpdateOverlays(glow, "glow")
			else if (lining_pattern > 3 && lining_pattern < 6)
				set_icon_state("base3_2")
				glow.icon_state = "[lining_color][lining_shape]_3"
				src.UpdateOverlays(glow, "glow")
			else if (lining_pattern > 5 && lining_pattern < 8)
				set_icon_state("base3_2")
				glow.icon_state = "[lining_color][lining_shape]_4"
				src.UpdateOverlays(glow, "glow")
		else
			set_icon_state("base[lining_shape]")
			if (lining_shape == 1)
				glow.icon_state = "[lining_color]1"
			else
				glow.icon_state = "[lining_color][lining_shape]_[lining_icon_state]"
			src.UpdateOverlays(glow, "glow")
		return

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W))
			new /obj/item/neon_lining(get_turf(user))
			qdel(src)
			return
		if (iswrenchingtool(W))
			if (lining_shape > 0 && lining_shape < 6)
				lining_shape++
			else
				lining_shape = 1
			lining_UpdateIcon()
			return
		if (isscrewingtool(W))
			if (lining_rotation >-1 && lining_rotation <3)
				lining_rotation++
			else
				lining_rotation = 0
			lining_UpdateIcon()
			return
		if (issnippingtool(W))
			if (lining_neOn == 0)
				lining_neOn++
				glow.icon_state = "off"
				src.UpdateOverlays(glow, "glow")
				light.set_brightness(0)
			else
				lining_neOn = 0
				light.set_brightness(0.1)
				lining_UpdateIcon()
			return
		if (ispulsingtool(W))
			if (lining_pattern > -1 && lining_pattern < 7)
				lining_pattern++
			else
				lining_pattern = 0
			lining_UpdateIcon()
			return
		return
