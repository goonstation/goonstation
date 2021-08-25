/obj/machinery/phosphorizer
	name = "Phosphorizer"
	desc = "A device capable of baking a phosphor onto light tubes or bulbs, changing the color of light they emit."
	icon = 'icons/obj/machines/phosphorizer.dmi'
	icon_state = "baseunit"
	anchored = 1
	density = 1
	mats = 20
	power_usage = 150

	var/mode = "ready"
	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')
	var/sound/sound_process = sound('sound/effects/pop.ogg')

	//color values to install into the bulb
	var/ctrl_R = 1.0
	var/ctrl_G = 0.2
	var/ctrl_B = 0

	attack_hand(mob/user as mob)
		for(var/obj/item/AQ in src.contents)
			src.colorize_bulb(AQ)

	attackby(obj/item/W as obj, mob/user as mob)
		if(load_bulb(W,user))
			boutput(user, "You load [W] into [src].")
			playsound(src, sound_load, 40, 1)
		else
			. = ..()

	proc/load_bulb(obj/item/W as obj, mob/user as mob)
		. = FALSE
		if (istype_exact(W,/obj/item/light/tube) || istype_exact(W,/obj/item/light/bulb)) //exact type so you're not coloring a colored bulb
			W.set_loc(src)
			if (user) user.u_equip(W)
			W.dropped()
			. = TRUE

	proc/colorize_bulb(var/obj/item/light/phos_target)
		phos_target.color_r = ctrl_R
		phos_target.color_g = ctrl_G
		phos_target.color_b = ctrl_B

		//partial color adjustment for the bulb itself, probably overfancy but it's a cool trick
		var/colr2 = num2hex(round((510 + ctrl_R * 255) / 3),2)
		var/colg2 = num2hex(round((510 + ctrl_G * 255) / 3),2)
		var/colb2 = num2hex(round((510 + ctrl_B * 255) / 3),2)
		phos_target.color = "#[colr2][colg2][colb2]"

		var/nameadjust = istype_exact(phos_target,/obj/item/light/tube) ? "tube" : "bulb"

		phos_target.name = "phosphorized light [nameadjust]"
		phos_target.desc = "A light [nameadjust] that has been coated with a phosphor to change its hue. A small label is marked '[ctrl_R]-[ctrl_G]-[ctrl_B]'."

		phos_target.pixel_x = -4
		phos_target.pixel_y = 8
		phos_target.set_loc(src.loc)

		playsound(src.loc, sound_process, 40, 1)

/obj/machinery/phosphorizer/power_change()
	var/image/I_panel = SafeGetOverlayImage("statuspanel", 'icons/obj/machines/phosphorizer.dmi', "powerpanel")
	I_panel.plane = PLANE_OVERLAY_EFFECTS
	I_panel.alpha = 128
	if (status & BROKEN)
		UpdateOverlays(null, "statuspanel", 0, 1)
		//light.disable()
	else
		if ( powered() )
			UpdateOverlays(I_panel, "statuspanel", 0, 1)
			status &= ~NOPOWER
			//light.enable()
		else
			SPAWN_DBG(rand(0, 15))
				UpdateOverlays(null, "statuspanel", 0, 1)
				status |= NOPOWER
				//light.disable()

/obj/machinery/phosphorizer/process(mult)
	if (status & BROKEN)
		return
	if (src.mode == "working")
		use_power(src.power_usage)
