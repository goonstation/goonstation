
/* ==================== Area ==================== */

/area/station/shield_zone
	name = "shield protected space"
	icon_state = "shield_zone"
	expandable = FALSE
	do_not_irradiate = TRUE
	requires_power = FALSE

/* ==================== Generator ==================== */

/obj/machinery/shield_generator
	name = "shield generator"
	desc = "Some kinda thing what generates a big ol' shield around everything."
	icon = 'icons/obj/large/32x96.dmi'
	icon_state = "shieldgen0"
	anchored = 1
	density = 1
	bound_height = 96
	var/obj/machinery/power/data_terminal/link = null
	var/net_id = null
	var/list/shields = list()
	var/active = 0
	var/image/image_active = null
	var/image/image_shower_dir = null
	var/sound_startup = 'sound/machines/shieldgen_startup.ogg' // 40
	var/sound_shutoff = 'sound/machines/shieldgen_shutoff.ogg' // 35
	var/lastuse = 0

	New()
		..()
		src.UpdateIcon()
		SPAWN(0.6 SECONDS)
			if (!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if (test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src
			src.net_id = generate_net_id(src)

	update_icon()

		if (status & (NOPOWER|BROKEN))
			src.icon_state = "shieldgen0"
			src.UpdateOverlays(null, "top_lights")
			src.UpdateOverlays(null, "meteor_dir1")
			src.UpdateOverlays(null, "meteor_dir2")
			src.UpdateOverlays(null, "meteor_dir3")
			src.UpdateOverlays(null, "meteor_dir4")
			return

		if (src.active)
			src.icon_state = "shieldgen-anim"
			if (!src.image_active)
				src.image_active = image(src.icon, "shield-top_anim")
			src.UpdateOverlays(src.image_active, "top_lights")
		else
			src.icon_state = "shieldgen1"
			src.UpdateOverlays(null, "top_lights")

		if (meteor_shower_active)
			if (!src.image_shower_dir)
				src.image_shower_dir = image(src.icon, "shield-D[meteor_shower_active]")
			src.image_shower_dir.icon_state = "shield-D[meteor_shower_active]"
			src.UpdateOverlays(src.image_shower_dir, "meteor_dir[meteor_shower_active]")
		else
			src.UpdateOverlays(null, "meteor_dir1")
			src.UpdateOverlays(null, "meteor_dir2")
			src.UpdateOverlays(null, "meteor_dir3")
			src.UpdateOverlays(null, "meteor_dir4")

	process()
		if (status & BROKEN)
			src.deactivate()
			return
		..()
		if (status & NOPOWER)
			src.deactivate()
			return

		src.use_power(250)
		if (src.shields.len)
			src.use_power(5*src.shields.len)

	disposing()
		src.remove_shield()
		src.link = null
		src.image_active = null
		src.image_shower_dir = null
		..()

	receive_signal(datum/signal/signal)
		if (status & (NOPOWER|BROKEN) || !src.link)
			return
		if (!signal || !src.net_id || signal.encryption)
			return

		if (signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]

		//They don't need to target us specifically to ping us.
		//Otherwise, ff they aren't addressing us, ignore them
		if (signal.data["address_1"] != src.net_id)
			if ((signal.data["address_1"] == "ping") && signal.data["sender"])
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					src.post_status(target, "command", "ping_reply", "device", "PNET_SHIELD_GEN", "netid", src.net_id)
			return

		var/sigcommand = lowertext(signal.data["command"])
		if (!sigcommand || !signal.data["sender"])
			return

		switch (sigcommand)
			if ("activate")
				if (src.active)
					src.post_reply("SGEN_ACT", target)
					return
				src.activate()
				src.post_reply("SGEN_ACTVD", target)

			if ("deactivate")
				if (!src.active)
					src.post_reply("SGEN_NACT", target)
					return
				src.deactivate()
				src.post_reply("SGEN_DACTVD", target)

	// for testing atm
	attack_hand(mob/user)
		if (status & (NOPOWER|BROKEN) || !src.link)
			user.show_text("[src] seems inoperable, as pressing the button does nothing.")
			return

		var/diff = world.timeofday - lastuse
		if(diff < 0) diff += 864000 //Wrapping protection.

		if(diff > 1500)
			lastuse = world.timeofday
			visible_message("[src] beeps loudly.","You hear a loud beep.")
			if (src.active)
				src.deactivate()
				user.show_text("Shields Deactivated.")
			else
				src.activate()
				user.show_text("Shields Activated.")
			message_admins("<span class='internal'>[key_name(user)] [src.active ? "activated" : "deactivated"] shields</span>")
			logTheThing(LOG_STATION, null, "[key_name(user)] [src.active ? "activated" : "deactivated"] shields")
		else
			user.show_text("<span class='alert'><b>That is still not ready to be used again.</b></span>")

	proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
		if (!src.link || !target_id)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = TRANSMISSION_WIRE
		signal.data[key] = value
		if (key2)
			signal.data[key2] = value2
		if (key3)
			signal.data[key3] = value3

		signal.data["address_1"] = target_id
		signal.data["sender"] = src.net_id

		src.link.post_signal(src, signal)

	proc/post_reply(error_text, target_id)
		if (!error_text || !target_id)
			return
		SPAWN(0.3 SECONDS)
			src.post_status(target_id, "command", "device_reply", "status", error_text)
		return

	proc/create_shield()
		var/area/shield_loc = locate(/area/station/shield_zone)
		for (var/turf/T in shield_loc)
			if (!(locate(/obj/forcefield/meteorshield) in T))
				var/obj/forcefield/meteorshield/MS = new /obj/forcefield/meteorshield(T)
				MS.deployer = src
				src.shields += MS

	proc/remove_shield()
		for (var/obj/forcefield/meteorshield/MS in src.shields)
			MS.deployer = null
			src.shields -= MS
			qdel(MS)

	proc/activate()
		if (src.active)
			return
		src.active = 1
		src.create_shield()
		src.UpdateIcon()
		playsound(src.loc, src.sound_startup, 75)

	proc/deactivate()
		if (!src.active)
			return
		src.active = 0
		src.remove_shield()
		src.UpdateIcon()
		playsound(src.loc, src.sound_shutoff, 75)


/obj/machinery/shield_generator/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "engine1"

	update_icon()

		return

/obj/machinery/shield_generator/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "engine2"

	update_icon()

		return

/* ==================== Computer ==================== */

/obj/machinery/computer3/generic/shield_control
	name = "shield control computer"
	icon_state = "engine"
	base_icon_state = "engine"
	setup_drive_size = 48

	setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
	//setup_starting_peripheral2 = /obj/item/peripheral/network/radio/locked/pda
	setup_starting_program = /datum/computer/file/terminal_program/shield_control

/obj/machinery/computer3/generic/shield_control/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "engine1"
	base_icon_state = "engine1"
/obj/machinery/computer3/generic/shield_control/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "engine2"
	base_icon_state = "engine2"

/* ==================== Program ==================== */

/datum/computer/file/terminal_program/shield_control
	name = "ShieldControl"
	size = 10
	req_access = list(access_engineering_engine)
	var/tmp/authenticated = null //Are we currently logged in?
	var/datum/computer/file/user_data/account = null
	var/obj/item/peripheral/network/powernet_card/pnet_card = null
	var/tmp/gen_net_id = null //The net id of our linked generator
	var/tmp/reply_wait = -1 //How long do we wait for replies? -1 is not waiting.

	var/setup_acc_filepath = "/logs/sysusr"//Where do we look for login data?

	initialize()
		src.authenticated = null
		src.master.temp = null
		if (!src.find_access_file()) //Find the account information, as it's essentially a ~digital ID card~
			src.print_text("<b>Error:</b> Cannot locate user file.  Quitting...")
			src.master.unload_program(src) //Oh no, couldn't find the file.
			return

		src.pnet_card = locate() in src.master.peripherals
		if (!pnet_card || !istype(src.pnet_card))
			src.pnet_card = null
			src.print_text("<b>Warning:</b> No network adapter detected.")

		if (!src.check_access(src.account.access))
			src.print_text("User [src.account.registered] does not have needed access credentials.<br>Quitting...")
			src.master.unload_program(src)
			return

		src.reply_wait = -1
		src.authenticated = src.account.registered

		var/intro_text = {"<b>ShieldControl</b>
		<br>Emergency Defense Shield System
		<br><b>Commands:</b>
		<br>(Link) to link with a shield generator.
		<br>(Activate) to activate shields.
		<br>(Deactivate) to deactivate shields.
		<br>(Clear) to clear the screen.
		<br>(Quit) to exit ShieldControl."}
		src.print_text(intro_text)

	input_text(text)
		if (..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1] //Remove the command we are now processing.

		switch (lowertext(command))

			if ("link")
				if (!src.pnet_card) //can't do this ~fancy network stuff~ without a network card.
					src.print_text("<b>Error:</b> Network card required.")
					src.master.add_fingerprint(usr)
					return

				src.print_text("Now scanning for shield generator...")
				src.detect_generator()

			if ("activate")
				if (!src.pnet_card)
					src.print_text("<b>Error:</b> Network card required.")
					src.master.add_fingerprint(usr)
					return

				if (!src.gen_net_id)
					src.detect_generator()
					sleep(0.8 SECONDS)
					if (!src.gen_net_id)
						src.print_text("<b>Error:</b> Unable to detect generator.  Please check network cabling.")
						return
				else
					src.print_text("Transmitting activation request...")
					generate_signal(gen_net_id, "command", "activate")

			if ("deactivate")
				if (!src.pnet_card)
					src.print_text("<b>Error:</b> Network card required.")
					src.master.add_fingerprint(usr)
					return

				if (!src.gen_net_id)
					src.detect_generator()
					sleep(0.8 SECONDS)
					if (!src.gen_net_id)
						src.print_text("<b>Error:</b> Unable to detect generator.  Please check network cabling.")
						return
				else
					src.print_text("Transmitting deactivation request...")
					generate_signal(gen_net_id, "command", "deactivate")

			if ("help")
				var/help_text = {"<br><b>ShieldControl</b>
				<br>Emergency Defense Shield System
				<br><b>Commands:</b>
				<br>(Link) to link with a shield generator.
				<br>(Activate) to activate shields.
				<br>(Deactivate) to deactivate shields.
				<br>(Clear) to clear the screen.
				<br>(Quit) to exit ShieldControl."}
				src.print_text(help_text)

			if ("clear")
				src.master.temp = null
				src.master.temp_add = "Workspace cleared.<br>"

			if ("quit")
				src.master.temp = ""
				print_text("Now quitting...")
				src.master.unload_program(src)
				return

			else
				print_text("Unknown command : \"[copytext(strip_html(command), 1, 16)]\"")

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	process()
		if (..())
			return

		if (src.reply_wait > 0)
			src.reply_wait--
			if (src.reply_wait == 0)
				src.print_text("Timed out on generator. Please rescan and retry.")
				src.gen_net_id = null

	receive_command(obj/source, command, datum/signal/signal)
		if ((..()) || (!signal))
			return

		//If we don't have a generator net_id to use, set one.
		switch (signal.data["command"])
			if ("ping_reply")
				if (src.gen_net_id)
					return
				if ((signal.data["device"] != "PNET_SHIELD_GEN") || !signal.data["netid"])
					return

				src.gen_net_id = signal.data["netid"]
				src.print_text("Shield generator detected.")

			if ("device_reply")
				if (!src.gen_net_id || signal.data["sender"] != src.gen_net_id)
					return

				src.reply_wait = -1

				switch (lowertext(signal.data["status"]))
					if ("sgen_act")
						src.print_text("<b>Alert:</b> Shield generator is already active.")

					if ("sgen_nact")
						src.print_text("<b>Alert:</b> Shield generator is already inactive.")

					if ("sgen_actvd")
						src.print_text("<b>Alert:</b> Shield generator activated.")
						if (usr)
							message_admins("<span class='internal'>[key_name(usr)] activated shields</span>")
							logTheThing(LOG_STATION, null, "[key_name(usr)] activated shields")

					if ("sgen_dactvd")
						src.print_text("<b>Alert:</b> Shield generator deactivated.")
						if (usr)
							message_admins("<span class='internal'>[key_name(usr)] deactivated shields</span>")
							logTheThing(LOG_STATION, null, "[key_name(usr)] deactivated shields")
				return
		return

	proc/find_access_file() //Look for the whimsical account_data file
		var/datum/computer/folder/accdir = src.holder.root
		if (src.master.host_program) //Check where the OS is, preferably.
			accdir = src.master.host_program.holder.root

		var/datum/computer/file/user_data/target = parse_file_directory(setup_acc_filepath, accdir)
		if (target && istype(target))
			src.account = target
			return 1

		return 0

	proc/detect_generator() //Send out a ping signal to find a comm dish.
		if (!src.pnet_card)
			return //The card is kinda crucial for this.

		var/datum/signal/newsignal = get_free_signal()
		//newsignal.encryption = "\ref[src.pnet_card]"

		src.gen_net_id = null
		src.reply_wait = -1
		src.peripheral_command("ping", newsignal, "\ref[src.pnet_card]")

	proc/generate_signal(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
		if (!src.pnet_card || !gen_net_id)
			return

		var/datum/signal/signal = get_free_signal()
		//signal.encryption = "\ref[src.pnet_card]"
		signal.data["address_1"] = target_id
		signal.data[key] = value
		if (key2)
			signal.data[key2] = value2
		if (key3)
			signal.data[key3] = value3

		src.reply_wait = 5
		src.peripheral_command("transmit", signal, "\ref[src.pnet_card]")
