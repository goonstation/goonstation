// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA


/obj/machinery/bot/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	layer = MOB_LAYER
	density = 1
	anchored = 1
	animate_movement=1
	soundproofing = 0
	on = TRUE
	access_lookup = "Captain"
	var/atom/movable/load = null		// the loaded crate (usually)
	///sanitycheck so we can't try to unload during an unload operation
	var/unloading = FALSE

	var/beacon_freq = FREQ_NAVBEACON
	var/control_freq = FREQ_BOT_CONTROL

	suffix = ""

	var/turf/target				// this is turf to navigate to (location of beacon)
	var/loaddir = 0				// this the direction to unload onto/load from
	var/new_destination = ""	// pending new destination (waiting for beacon response)
	var/destination = ""		// destination description
	var/home_destination = "" 	// tag of home beacon
	req_access = list(access_cargo)

	var/mode = 0		//0 = idle/ready
						//1 = loading/unloading
						//2 = moving to deliver
						//3 = returning to home
						//4 = blocked
						//5 = computing navigation
						//6 = waiting for nav computation
						//7 = no destination beacon found (or no route)

	var/blockcount	= 0		//number of times retried a blocked path
	var/reached_target = 1 	//true if already reached the target

	var/auto_return = 1	// true if auto return to home beacon after unload
	var/auto_pickup = 1 // true if auto-pickup at beacon

	var/obj/item/cell/cell
						// the installed power cell
	no_camera = 1

	var/bloodiness = 0		// count of bloodiness
	var/nocellspawn = 0 //Used for spawning a MULE w/o a cell.

	/// Wire Panel for 10 wires.
	var/static/datum/wirePanel/panelDefintion/panel_def = new /datum/wirePanel/panelDefintion(
		controls=list(
			WIRE_CONTROL_POWER_A,	// power connections
			WIRE_CONTROL_POWER_B,	//
			WIRE_CONTROL_SAFETY,	// mob avoidance
			WIRE_CONTROL_ACTIVATE,	// load checking (non-crate)
			WIRE_CONTROL_BACKUP_A,	// motor wires
			WIRE_CONTROL_BACKUP_B,	//
			WIRE_CONTROL_ACCESS,	// remote recv functions
			WIRE_CONTROL_RESTRICT,	// remote trans status
			WIRE_CONTROL_RECIEVE,	// beacon ping recv
			WIRE_CONTROL_TRANSMIT,	// beacon ping trans
			),
		color_pool=list("red", "green", "blue", "magenta", "cyan", "yellow", "pink", "white", "orange", "grey"),
		custom_acts=list(
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_POWER_A, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_POWER_B, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_SAFETY, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_ACTIVATE, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_BACKUP_A, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_BACKUP_B, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_ACCESS, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_RESTRICT, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_RECIEVE, WIRE_ACT_MEND, WIRE_ACT_CUT),
			WPANEL_CUSTOM_ACT(WIRE_CONTROL_TRANSMIT, WIRE_ACT_MEND, WIRE_ACT_CUT),
		)
	)

	New()
		..()

		var/global/mulecount = 0
		if(!suffix)
			mulecount++
			suffix = "#[mulecount]"
		name = "Mulebot ([suffix])"

		if (!nocellspawn)
			cell = new(src)
			cell.charge = 2000
			cell.maxcharge = 2000

		MAKE_DEFAULT_RADIO_PACKET_COMPONENT("control", control_freq)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT("beacon", beacon_freq)
		AddComponent(/datum/component/wirePanel, src.panel_def)
		RegisterSignal(src, COMSIG_WPANEL_MOB_WIRE_ACT, .proc/mob_wire_act)
		RegisterSignal(src, COMSIG_WPANEL_SET_COVER, .proc/set_cover)
		SEND_SIGNAL(src, COMSIG_WPANEL_SET_COVER, null, WPANEL_COVER_LOCKED)

	// attack by item
	// emag: lock/unlock
	// cell: insert it
	// other: chance to knock rider off bot

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		var/cover_status = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_COVER)
		var/locking
		switch (cover_status)
			if (WPANEL_COVER_OPEN)
				SEND_SIGNAL(src, COMSIG_WPANEL_SET_COVER, usr, WPANEL_COVER_LOCKED) // emags close things magically vOv
				locking = TRUE
			if (WPANEL_COVER_CLOSED)
				SEND_SIGNAL(src, COMSIG_WPANEL_SET_COVER, usr, WPANEL_COVER_LOCKED)
				locking = TRUE
			if (WPANEL_COVER_LOCKED)
				SEND_SIGNAL(src, COMSIG_WPANEL_SET_COVER, usr, WPANEL_COVER_CLOSED)
				locking = FALSE
			else
				return

		if(user)
			boutput(user, "<span class='notice'>You [locking ? "lock" : "unlock"] the mulebot's controls!</span>")

		flick("mulebot-emagged", src)
		playsound(src.loc, 'sound/effects/sparks1.ogg', 100, 0)
		return 1

	attackby(var/obj/item/I, var/mob/user)
		var/cover_status = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_COVER)
		if(istype(I,/obj/item/cell) && cover_status == WPANEL_COVER_OPEN && !cell)
			var/obj/item/cell/C = I
			user.drop_item()
			C.set_loc(src)
			cell = C
			updateDialog()
		else if(load && ismob(load))  // chance to knock off rider
			if(prob(1+I.force * 2))
				unload(0)
				user.visible_message("<span class='alert'>[user] knocks [load] off [src] with \the [I]!</span>", "<span class='alert'>You knock [load] off [src] with \the [I]!</span>")
			else
				boutput(user, "You hit [src] with \the [I] but to no effect.")
		else
			..()
		return

	ex_act(var/severity)
		unload(0)
		switch(severity)
			if(1)
				qdel(src)
			if(2)
				SEND_SIGNAL(src, COMSIG_WPANEL_DISABLE_RANDOM_WIRE)
				SEND_SIGNAL(src, COMSIG_WPANEL_DISABLE_RANDOM_WIRE)
				SEND_SIGNAL(src, COMSIG_WPANEL_DISABLE_RANDOM_WIRE)
			if(3)
				SEND_SIGNAL(src, COMSIG_WPANEL_DISABLE_RANDOM_WIRE)

		return

	bullet_act(var/obj/projectile/P)
		if (!P)
			return
		if(prob(50) && src.load)
			src.load.bullet_act(P)
			src.unload(0)
		if(prob(25))
			src.visible_message("Something shorts out inside [src]!")
			SEND_SIGNAL(src, COMSIG_WPANEL_DISABLE_RANDOM_WIRE)

	attack_ai(var/mob/user, params)
		interacted(user, 1, params)

	attack_hand(var/mob/user, params)
		interacted(user, 0, params)

	proc/interacted(var/mob/user, var/ai=0, params)
		var/cover_state = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_COVER)
		var/dat
		dat += "<TT><B>Multiple Utility Load Effector Mk. III</B></TT><BR><BR>"
		dat += "ID: [suffix]<BR>"
		dat += "Power: [on ? "On" : "Off"]<BR>"

		if(cover_state != WPANEL_COVER_OPEN)
			dat += "Status: "
			switch(mode)
				if(0)
					dat += "Ready"
				if(1)
					dat += "Loading/Unloading"
				if(2)
					dat += "Navigating to Delivery Location"
				if(3)
					dat += "Navigating to Home"
				if(4)
					dat += "Waiting for clear path"
				if(5,6)
					dat += "Calculating navigation path"
				if(7)
					dat += "Unable to locate destination"

			dat += "<BR>Current Load: [load ? load.name : "<i>none</i>"]<BR>"
			dat += "Destination: [!destination ? "<i>none</i>" : destination]<BR>"
			dat += "Power level: [cell ? cell.percent() : 0]%<BR>"

			if(cover_state == WPANEL_COVER_LOCKED && !ai)
				dat += "Controls are locked <A href='byond://?src=\ref[src];op=unlock'><I>(unlock)</I></A>"
			else
				dat += "Controls are unlocked <A href='byond://?src=\ref[src];op=lock'><I>(lock)</I></A><hr>"

				dat += "<A href='byond://?src=\ref[src];op=power'>Toggle Power</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=stop'>Stop</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=go'>Proceed</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=home'>Return to Home</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=destination'>Set Destination</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=setid'>Set Bot ID</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=sethome'>Set Home</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
				dat += "<A href='byond://?src=\ref[src];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"

				if(load)
					dat += "<A href='byond://?src=\ref[src];op=unload'>Unload Now</A><BR>"
				dat += "<HR>The maintenance hatch is closed.<BR>"

		else
			if(!ai)
				dat += "The maintenance hatch is open.<BR><BR>"
				dat += "Power cell: "
				if(cell)
					dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
				else
					dat += "<A href='byond://?src=\ref[src];op=cellinsert'>Removed</A><BR>"
			else
				dat += "The bot is in maintenance mode and cannot be controlled.<BR>"

		if (user.client?.tooltipHolder)
			user.client.tooltipHolder.showClickTip(src, list(
				"params" = params,
				"title" = "Mulebot [suffix ? "([suffix])" : ""] controls",
				"content" = dat,
			))

		return

	Topic(href, href_list)
		if(..())
			return
		if (usr.stat)
			return
		if ((in_interact_range(src, usr) && istype(src.loc, /turf)) || (issilicon(usr)))
			src.add_dialog(usr)
			var/cover_status = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_COVER)
			switch(href_list["op"])
				if("lock", "unlock")
					if(src.allowed(usr))
						switch (cover_status)
							if (WPANEL_COVER_OPEN)
								boutput(usr, "<span class='notice'>You must closed the hatch before locking it!</span>")
							if (WPANEL_COVER_CLOSED)
								SEND_SIGNAL(src, COMSIG_WPANEL_SET_COVER, usr, WPANEL_COVER_CLOSED)
							if (WPANEL_COVER_LOCKED)
								SEND_SIGNAL(src, COMSIG_WPANEL_SET_COVER, usr, WPANEL_COVER_CLOSED)
					else
						boutput(usr, "<span class='alert'>Access denied.</span>")
						return

				if("power")
					on = !on
					if(!cell || cover_status == WPANEL_COVER_OPEN)
						on = FALSE
						return
					boutput(usr, "You switch [on ? "on" : "off"] [src].")
					for(var/mob/M in AIviewers(src))
						if(M==usr) continue
						boutput(M, "[usr] switches [on ? "on" : "off"] [src].")
					src.updateDialog()

				if("cellremove")
					if(cover_status == WPANEL_COVER_OPEN && cell && !usr.equipped())
						cell.add_fingerprint(usr)
						cell.UpdateIcon()
						usr.put_in_hand_or_drop(cell)
						cell = null

						usr.visible_message("<span class='notice'>[usr] removes the power cell from [src].</span>", "<span class='notice'>You remove the power cell from [src].</span>")

				if("cellinsert")
					if(cover_status == WPANEL_COVER_OPEN && !cell)
						var/obj/item/cell/C = usr.equipped()
						if(istype(C))
							usr.drop_item()
							cell = C
							C.set_loc(src)
							C.add_fingerprint(usr)

							usr.visible_message("<span class='notice'>[usr] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")

				if("stop")
					if(mode >=2)
						mode = 0

				if("go")
					if(mode == 0)
						start()

				if("home")
					if(mode == 0 || mode == 2)
						start_home()

				if("destination")
					var/new_dest = input("Enter new destination tag", "Mulebot [suffix ? "([suffix])" : ""]", destination) as text|null
					new_dest = copytext(adminscrub(new_dest),1, MAX_MESSAGE_LEN)
					if(new_dest)
						set_destination(new_dest)

				if("setid")
					var/new_id = input("Enter new bot ID", "Mulebot [suffix ? "([suffix])" : ""]", suffix) as text|null
					new_id = copytext(adminscrub(new_id), 1, 128)
					if(new_id)
						suffix = new_id
						name = "Mulebot ([suffix])"

				if("sethome")
					var/new_home = input("Enter new home tag", "Mulebot [suffix ? "([suffix])" : ""]", home_destination) as text|null
					new_home = copytext(adminscrub(new_home),1, 128)
					if(new_home)
						home_destination = new_home

				if("unload")
					if(load && mode !=1)
						if(loc == target)
							unload(loaddir)
						else
							unload(0)

				if("autoret")
					auto_return = !auto_return

				if("autopick")
					auto_pickup = !auto_pickup

				if("close")
					src.remove_dialog(usr)
					usr.Browse(null,"window=mulebot")

			updateDialog()
		else
			usr.Browse(null, "window=mulebot")
			src.remove_dialog(usr)
		return

	proc/mob_wire_act(obj/parent, mob/user, wire, action)
		if (HAS_FLAG(src.panel_def.wire_definitions[wire].control_flags, WIRE_CONTROL_SAFETY))
			switch (action)
				if (WIRE_ACT_CUT)
					logTheThing(LOG_VEHICLE, user, "disables the safety of a MULE ([src.name]) at [log_loc(user)].")
					src.emagger = user
				if (WIRE_ACT_MEND)
					logTheThing(LOG_VEHICLE, user, "reactivates the safety of a MULE ([src.name]) at [log_loc(user)].")
					src.emagger = null

		if (action == WIRE_ACT_PULSE)
			if (HAS_FLAG(src.panel_def.wire_definitions[wire].control_flags, WIRE_CONTROL_SAFETY))
				boutput(user, "<span class='notice'>[bicon(src)] The external warning lights flash briefly.</span>")
				return
			if (HAS_FLAG(src.panel_def.wire_definitions[wire].control_flags, WIRE_CONTROL_POWER_A))
				boutput(user, "<span class='notice'>[bicon(src)] The charge light flickers.</span>")
				return
			if (HAS_FLAG(src.panel_def.wire_definitions[wire].control_flags, WIRE_CONTROL_POWER_B))
				boutput(user, "<span class='notice'>[bicon(src)] The charge light flickers.</span>")
				return
			if (HAS_FLAG(src.panel_def.wire_definitions[wire].control_flags, WIRE_CONTROL_ACTIVATE))
				boutput(user, "<span class='notice'>[bicon(src)] The load platform clunks.</span>")
				return
			if (HAS_FLAG(src.panel_def.wire_definitions[wire].control_flags, WIRE_CONTROL_BACKUP_A))
				boutput(user, "<span class='notice'>[bicon(src)] The drive motor whines briefly.</span>")
				return
			if (HAS_FLAG(src.panel_def.wire_definitions[wire].control_flags, WIRE_CONTROL_BACKUP_B))
				boutput(user, "<span class='notice'>[bicon(src)] The drive motor whines briefly.</span>")
				return
			boutput(user, "<span class='notice'>[bicon(src)] You hear a radio crackle.</span>")

	proc/set_cover(obj/parent, mob/user, status)
		if (status == WPANEL_COVER_OPEN)
			src.on = FALSE
			src.icon_state = "mulebot-hatch"
			src.updateDialog()
		else
			src.on = has_power()
			src.icon_state = "mulebot0"
			if(!isnull(tgui_process)) // we need this b/c we set the cover in New
				// the only TGUI for this object is wire panels, so close if the cover closes
				for(var/datum/tgui/ui in tgui_process.get_uis(parent))
					if(!parent.can_access_remotely(ui.user))
						tgui_process.close_user_uis(ui.user, parent)
				src.updateDialog()

	// returns true if the bot has power
	proc/has_power()
		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
		var/cover_status = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_COVER)
		return !(cover_status == WPANEL_COVER_OPEN) && cell?.charge>0 && HAS_ALL_FLAGS(active_controls, WIRE_CONTROL_POWER_A | WIRE_CONTROL_POWER_B)

	// mousedrop a crate to load the bot
	MouseDrop_T(var/atom/movable/C, mob/user)

		if(user.stat)
			return

		if (!on || !istype(C)|| C.anchored || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(src, C) > 0 )
			return

		if(load)
			return

		load(C)

	// called to load a crate
	proc/load(var/atom/movable/C)
		if (istype(C, /atom/movable/screen) || C.anchored)
			return

		if(BOUNDS_DIST(C, src) > 0 || load || !on)
			return
		mode = 1

		// if a create, close before loading
		var/obj/storage/crate/crate = C
		if(istype(crate))
			crate.close()
		C.anchored = 1
		C.set_loc(src.loc)
		sleep(0.2 SECONDS)
		C.set_loc(src)
		load = C
		if(ismob(C))
			C.pixel_y = 9
		else
			C.pixel_y += 9
		if(C.layer < layer)
			C.layer = layer + 0.1
		overlays += C

		mode = 0
		send_status()

	// called to unload the bot
	// argument is optional direction to unload
	// if zero, unload at bot's location
	proc/unload(var/dirn = 0, var/setloc = 1)
		if(!load || unloading)
			return
		unloading = TRUE

		mode = 1
		overlays = null

		if(setloc)
			load.set_loc(src.loc)
		load.pixel_y -= 9
		load.layer = initial(load.layer)
		if(ismob(load))
			load.pixel_y = 0

		reset_anchored(load)

		if(dirn)
			step(load, dirn)

		load = null

		// in case non-load items end up in contents, dump every else too
		// this seems to happen sometimes due to race conditions
		// with items dropping as mobs are loaded

		for(var/atom/movable/AM in src)
			if(AM == cell || AM == botcard) continue

			AM.set_loc(src.loc)
			AM.layer = initial(AM.layer)
			AM.pixel_y = initial(AM.pixel_y)
		mode = 0

		unloading = FALSE

	var/last_process_time

	Exited(Obj, newloc)
		. = ..()
		if(Obj == load)
			unload(0, 0)

	process()
		. = ..()
		var/time_since_last = TIME - last_process_time
		last_process_time = TIME
		if(!has_power())
			on = 0
			return
		if(on)
			SPAWN(0)
				var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
				// speed varies between 1-4 depending on how many wires are cut (and which of the two)
				var/speed = 1
				if (HAS_FLAG(active_controls, WIRE_CONTROL_BACKUP_A))
					speed += 1
				if (HAS_FLAG(active_controls, WIRE_CONTROL_BACKUP_B))
					speed += 2
				// both wires results in no speed at all :(
				var/n_steps = list(0, 12, 7, 6)[speed]

				var/sleep_time = n_steps ? clamp(time_since_last / n_steps, 0.04 SECONDS, 1.5 SECONDS) : 0

				for (var/i = 1 to n_steps)
					sleep(sleep_time)
					process_bot()

	proc/process_bot()
		//if(mode) boutput(world, "Mode: [mode]")
		switch(mode)
			if(0)		// idle
				icon_state = "mulebot0"
				return
			if(1)		// loading/unloading
				return
			if(2,3,4)		// navigating to deliver,home, or blocked

				if(loc == target)		// reached target
					at_target()
					return

				else if(length(path) && target) // valid path
					var/turf/next = path[1]
					reached_target = 0
					if(next == loc)
						path -= next
						return

					if(istype( next, /turf/simulated))
						//boutput(world, "at ([x],[y]) moving to ([next.x],[next.y])")

						if(bloodiness)
							var/obj/decal/cleanable/blood/tracks/B = make_cleanable(/obj/decal/cleanable/blood/tracks, loc)
							var/newdir = get_dir(next, loc)
							if(newdir == dir)
								B.set_dir(newdir)
							else
								newdir = newdir | dir
								if(newdir == 3)
									newdir = 1
								else if(newdir == 12)
									newdir = 4
								B.set_dir(newdir)
							bloodiness--

						step_towards(src, next)	// attempt to move
						var/moved = src.loc == next // step_towards return value is unreliable at best and always false at worst
						if(cell) cell.use(1)
						if(moved)	// successful move
							//boutput(world, "Successful move.")
							blockcount = 0
							path -= loc

							if(mode==4)
								SPAWN(1 DECI SECOND)
									send_status()

							if(destination == home_destination)
								mode = 3
							else
								mode = 2

						else		// failed to move
							// we did not move, so let us see if we are being blocked by a door
							var/obj/machinery/door/block_door = locate(/obj/machinery/door/) in next
							if (block_door)
								// we patiently wait for the door - they only need half their operation time until they are non-dense
								sleep(block_door.operation_time/2)

							blockcount++
							mode = 4
							if(blockcount == 3)
								src.visible_message("[src] makes an annoyed buzzing sound", "You hear an electronic buzzing sound.")
								playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)

							if(blockcount > 5)	// attempt 5 times before recomputing
								// find new path excluding blocked turf
								src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
								playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)

								SPAWN(0.2 SECONDS)
									calc_path(next)
									if(path)
										src.visible_message("[src] makes a delighted ping!", "You hear a ping.")
										playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
									mode = 4
								mode = 6
								return
							return
					else
						src.visible_message("[src] makes an annoyed buzzing sound", "You hear an electronic buzzing sound.")
						playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
						//boutput(world, "Bad turf.")
						mode = 5
						return
				else
					//boutput(world, "No path.")
					mode = 5
					return

			if(5)		// calculate new path
				//boutput(world, "Calc new path.")
				mode = 6
				SPAWN(0)

					calc_path()

					if(path)
						blockcount = 0
						mode = 4
						src.visible_message("[src] makes a delighted ping!", "You hear a ping.")
						playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)

					else
						src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
						playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)

						mode = 7
			//if(6)
				//boutput(world, "Pending path calc.")
			//if(7)
				//boutput(world, "No dest / no route.")
		return

	// calculates a path to the current destination
	// given an optional turf to avoid
	proc/calc_path(var/turf/avoid = null)
		src.path = get_path_to(src, src.target, max_distance=200, id=src.botcard, skip_first=FALSE, exclude=avoid, cardinal_only=TRUE, do_doorcheck=TRUE)

	// sets the current destination
	// signals all beacons matching the delivery code
	// beacons will return a signal giving their locations
	proc/set_destination(var/new_dest)
		SPAWN(0)
			new_destination = new_dest
			post_signal_multiple("beacon", list("findbeacon" = "delivery", "address_tag" = "delivery"))
			updateDialog()

	// starts bot moving to current destination
	proc/start()
		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
		if(destination == home_destination)
			mode = 3
		else
			mode = 2

		icon_state = "mulebot[HAS_FLAG(active_controls, WIRE_CONTROL_SAFETY) > 0]"

	// starts bot moving to home
	// sends a beacon query to find
	proc/start_home()
		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
		SPAWN(0)
			set_destination(home_destination)
			mode = 4
		icon_state = "mulebot[HAS_FLAG(active_controls, WIRE_CONTROL_SAFETY) > 0]"

	// called when bot reaches current target
	proc/at_target()
		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
		if(!reached_target)
			src.visible_message("[src] makes a chiming sound!", "You hear a chime.")
			playsound(src.loc, 'sound/machines/chime.ogg', 50, 0)
			reached_target = 1

			if(load)		// if loaded, unload at target
				unload(loaddir)
			else
				// not loaded
				if(auto_pickup)		// find a crate
					var/atom/movable/AM
					if(!(HAS_FLAG(active_controls, WIRE_CONTROL_ACTIVATE)))		// if emagged, load first unanchored thing we find
						for(var/atom/movable/A in get_step(loc, loaddir))
							if(!A.anchored)
								AM = A
								break
					else			// otherwise, look for crates only
						AM = locate(/obj/storage) in get_step(loc,loaddir)
					if (AM && !AM.anchored)
						load(AM)
			// whatever happened, check to see if we return home

			if(auto_return && destination != home_destination)
				// auto return set and not at home already
				start_home()
				mode = 4
			else
				mode = 0	// otherwise go idle

		send_status()	// report status to anyone listening

		return

	// called when bot bumps into anything
	bump(var/atom/obs)
		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
		//usually just bumps, but if safety disabled knock over mobs
		if(!HAS_FLAG(active_controls, WIRE_CONTROL_SAFETY))
			var/mob/M = obs
			if(ismob(M))
				if(isrobot(M))
					src.visible_message("<span class='alert'>[src] bumps into [M]!</span>")
				else
					src.visible_message("<span class='alert'>[src] knocks over [M]!</span>")
					M.remove_pulling()
					M.changeStatus("stunned", 8 SECONDS)
					M.changeStatus("weakened", 5 SECONDS)
					M.lying = 1
					M.set_clothing_icon_dirty()
		..()

	alter_health()
		return get_turf(src)

	// called from mob/living/carbon/human/Crossed(atom/movable/)
	// when mulebot is in the same loc
	proc/RunOver(var/mob/living/carbon/human/H)
		src.visible_message("<span class='alert'>[src] drives over [H]!</span>")
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

		logTheThing(LOG_VEHICLE, H, "is run over by a MULE ([src.name]) at [log_loc(src)].[src.emagger && ismob(src.emagger) ? " Safety disabled by [constructTarget(src.emagger,"vehicle")]." : ""]")

		if(ismob(load))
			var/mob/M = load
			if (M.reagents && M.reagents.has_reagent("ethanol"))
				M.unlock_medal("DUI", 1)

		var/damage = rand(5,15)

		H.TakeDamage("head", 2*damage, 0)
		H.TakeDamage("chest",2*damage, 0)
		H.TakeDamage("l_leg",0.5*damage, 0)
		H.TakeDamage("r_leg",0.5*damage, 0)
		H.TakeDamage("l_arm",0.5*damage, 0)
		H.TakeDamage("r_arm",0.5*damage, 0)

		take_bleeding_damage(H, null, 2 * damage, DAMAGE_BLUNT)

		bloodiness += 4

	// player on mulebot attempted to move
	relaymove(var/mob/user)
		if(user.stat)
			return
		if(load == user)
			unload(0)
		return

	// receive a radio signal
	// used for control and beacon reception

	receive_signal(datum/signal/signal)

		if(!on)
			return

		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)

		/*
		boutput(world, "rec signal: [signal.source]")
		for(var/x in signal.data)
			boutput(world, "* [x] = [signal.data[x]]")
		*/
		var/recv = signal.data["command"]
		// process all-bot input
		if(recv=="bot_status" && (HAS_FLAG(active_controls, WIRE_CONTROL_ACCESS)))
			send_status()

		recv = signal.data["command_[ckey(suffix)]"]

		if(HAS_FLAG(active_controls, WIRE_CONTROL_ACCESS))
			// process control input
			switch(recv)
				if("stop")
					mode = 0
					return

				if("go")
					start()
					return

				if("target")
					set_destination(signal.data["destination"] )
					return

				if("unload")
					if(loc == target)
						unload(loaddir)
					else
						unload(0)
					return

				if("home")
					start_home()
					return

				if("bot_status")
					send_status()
					return

				if("autoret")
					auto_return = text2num_safe(signal.data["value"])
					return

				if("autopick")
					auto_pickup = text2num_safe(signal.data["value"])
					return

		// receive response from beacon
		recv = signal.data["beacon"]
		if(HAS_FLAG(active_controls, WIRE_CONTROL_RECIEVE))
			if(recv == new_destination)	// if the recvd beacon location matches the set destination
										// the we will navigate there
				destination = new_destination
				target = signal.source.loc
				var/direction = signal.data["dir"]	// this will be the load/unload dir
				if(direction)
					loaddir = text2num_safe(direction)
				else
					loaddir = 0
				icon_state = "mulebot[HAS_FLAG(active_controls, WIRE_CONTROL_SAFETY) > 0]"
				calc_path()
				updateDialog()

	// send a radio signal with a single data key/value pair
	proc/post_signal(var/freq, var/key, var/value)
		post_signal_multiple(freq, list("[key]" = value) )

	// send a radio signal with multiple data key/values
	proc/post_signal_multiple(var/freq, var/list/keyval)
		var/active_controls = SEND_SIGNAL(src, COMSIG_WPANEL_STATE_CONTROLS)
		if(freq == beacon_freq && !(HAS_FLAG(active_controls, WIRE_CONTROL_TRANSMIT)))
			return
		if(freq == control_freq && !(HAS_FLAG(active_controls, WIRE_CONTROL_RESTRICT)))
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.data["sender"] = src.botnet_id
		for(var/key in keyval)
			signal.data[key] = keyval[key]
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, freq)

	// signals bot status etc. to controller
	proc/send_status()
		var/list/kv = new()
		kv["type"] = "mulebot"
		kv["name"] = ckey(suffix)
		kv["loca"] = get_area(src)
		kv["mode"] = mode
		kv["powr"] = cell ? cell.percent() : 0
		kv["dest"] = destination
		kv["home"] = home_destination
		kv["load"] = load
		kv["retn"] = auto_return
		kv["pick"] = auto_pickup
		post_signal_multiple(control_freq, kv)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		SEND_SIGNAL(src, COMSIG_WPANEL_UI_ACT, action, params, ui)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "WirePanelWindow", src.name)
			ui.open()

	ui_data(mob/user)
		. = ..()
		SEND_SIGNAL(src, COMSIG_WPANEL_UI_DATA, user, .)

	ui_static_data(mob/user)
		. = ..()
		.["wirePanelTheme"] = list(
			"wireTheme" = WPANEL_THEME_TEXT,
			"controlTheme" = WPANEL_THEME_PHYSICAL,
		)
		SEND_SIGNAL(src, COMSIG_WPANEL_UI_STATIC_DATA, user, .)

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/obj/machinery/bot/mulebot/QM1
	home_destination = "QM #1"

/obj/machinery/bot/mulebot/QM2
	home_destination = "QM #2"

/obj/machinery/bot/mulebot/broken //cell is missing, hatch open
	nocellspawn = TRUE
	on = FALSE
	icon_state="mulebot-hatch"

	New()
		. = ..()
		SEND_SIGNAL(src, COMSIG_WPANEL_SET_COVER, null, WPANEL_COVER_OPEN)
