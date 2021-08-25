/obj/machinery/phosphorizer
	name = "Phosphorizer"
	desc = "A device capable of baking a phosphor onto light tubes or bulbs, changing the color of light they emit."
	icon = 'icons/obj/machines/phosphorizer.dmi'
	icon_state = "baseunit"
	anchored = 1
	density = 1
	mats = 20
	power_usage = 150

	var/phosphorizing = false //whether the phosphorizer is currently operating
	var/failbreak = false //set to true if phosphorizing ended without processing all bulbs
	var/phos_delay = 12 //delay between bulb processing

	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')
	var/sound/sound_process = sound('sound/effects/pop.ogg')
	var/sound/sound_grump = sound('sound/machines/buzz-two.ogg')

	//color values to install into the bulb
	var/ctrl_R = 255
	var/ctrl_G = 255
	var/ctrl_B = 255

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/storage/))
			var/obj/item/storage/S = W
			var/items = S.get_contents()
			for(var/obj/item/O in items)
				if (load_bulb(O))
					. = TRUE
					if (istype(S))
						S.hud.remove_object(O)
			if (.)
				user.visible_message("<b>[user.name]</b> loads [W] into [src].")
				playsound(src, sound_load, 40, 1)
				attack_hand(user)
		else if(load_bulb(W,user))
			boutput(user, "You load [W] into [src].")
			playsound(src, sound_load, 40, 1)
			attack_hand(user)
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
		//this gets it to come out to a finite point, but at what cost
		phos_target.color_r = min(ctrl_R * 0.004,1)
		phos_target.color_g = min(ctrl_G * 0.004,1)
		phos_target.color_b = min(ctrl_B * 0.004,1)

		//partial color adjustment for the bulb itself, probably overfancy but it's a cool trick
		var/colr2 = num2hex(round((510 + ctrl_R) / 3),2)
		var/colg2 = num2hex(round((510 + ctrl_G) / 3),2)
		var/colb2 = num2hex(round((510 + ctrl_B) / 3),2)
		phos_target.color = "#[colr2][colg2][colb2]"

		var/nameadjust = istype_exact(phos_target,/obj/item/light/tube) ? "tube" : "bulb"

		phos_target.name = "phosphorized light [nameadjust]"
		phos_target.desc = "A light [nameadjust] that has been coated with a phosphor to change its hue. A small label is marked '[ctrl_R]-[ctrl_G]-[ctrl_B]'."

		phos_target.pixel_x = -4
		phos_target.pixel_y = -8 //move bulb more towards output chute
		phos_target.set_loc(src.loc)

		playsound(src.loc, sound_process, 80, 1)

	proc/stop_phos()
		src.phosphorizing = false
		UpdateOverlays(null, "operatebar", 0, 1)

	proc/start_phos()
		src.phosphorizing = true
		var/image/O_panel = SafeGetOverlayImage("operatebar", 'icons/obj/machines/phosphorizer.dmi', "activelight")
		UpdateOverlays(O_panel, "operatebar", 0, 1)
		sleep(phos_delay)

		for (var/obj/item/M in src.contents)
			if(status & NOPOWER || src.phosphorizing == false)
				failbreak = true
				break
			use_power(src.power_usage)
			colorize_bulb(M)

			sleep(phos_delay)

		if(failbreak)
			failbreak = false
			src.visible_message("<b>[src]</b> stops operating.")
			playsound(src.loc, sound_grump, 40, 1)
		else
			src.visible_message("<b>[src]</b> finishes working and shuts down.")
		if(src.phosphorizing) stop_phos()

/obj/machinery/phosphorizer/power_change()
	var/image/I_panel = SafeGetOverlayImage("statuspanel", 'icons/obj/machines/phosphorizer.dmi', "powerpanel")
	I_panel.plane = PLANE_SELFILLUM
	I_panel.alpha = 128
	if (status & BROKEN)
		UpdateOverlays(null, "statuspanel", 0, 1)
		if(src.phosphorizing) src.stop_phos()
	else
		if ( powered() )
			UpdateOverlays(I_panel, "statuspanel", 0, 1)
			status &= ~NOPOWER
		else
			SPAWN_DBG(rand(0, 15))
				UpdateOverlays(null, "statuspanel", 0, 1)
				status |= NOPOWER

/obj/machinery/phosphorizer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Phosphorizer", name)
		ui.open()

/obj/machinery/phosphorizer/ui_data(mob/user)
	. = list(
		"tubes" = src.contents.len,
		"hostR" = src.ctrl_R,
		"hostG" = src.ctrl_G,
		"hostB" = src.ctrl_B,
	)

/obj/machinery/phosphorizer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("tune_hue")
			switch(params["hue"])
				if("R") src.ctrl_R = clamp(round(params["output"]), 20, 255)
				if("G") src.ctrl_G = clamp(round(params["output"]), 20, 255)
				if("B") src.ctrl_B = clamp(round(params["output"]), 20, 255)
			. = TRUE
		if("process")
			if(status | BROKEN && powered() && src.contents.len)
				src.start_phos()
				ui_interact(usr, ui)
		if("eject")
			if(src.contents.len)
				for (var/obj/item/M in src.contents)
					M.pixel_x = -4
					M.pixel_y = 2 //bulb being blorfed out the input slot
					M.set_loc(src.loc)
				ui_interact(usr, ui)

	src.add_fingerprint(usr)
