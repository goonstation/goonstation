/datum/computer/file/coords
	name = "coordinates"
	extension = "GPS"
	var/destx = 0
	var/desty = 0
	var/destz = 0

	var/origx = 0	//Only used for relaying stuff.
	var/origy = 0	//Fun for people who can't spell.
	var/origz = 0

	var/can_cheat = 0	//Flag to ignore destination restrictions.

var/telesci_modifiers_set = 0

proc/is_teleportation_allowed(var/turf/T)
	for (var/atom in by_cat[TR_CAT_TELEPORT_JAMMERS])
		if (istype(atom, /obj/machinery/telejam))
			var/obj/machinery/telejam/TJ = atom
			if (!TJ.active)
				continue
			if(IN_RANGE(TJ, T, TJ.range))
				return FALSE
		if (istype(atom, /obj/item/device/flockblocker))
			var/obj/item/device/flockblocker/F = atom
			if (!F.active)
				continue
			if(IN_RANGE(F, T, F.range))
				return FALSE

	for_by_tcl(N, /obj/blob/nucleus)
		if(IN_RANGE(N, T, 3))
			return FALSE

	// first check the always allowed turfs from map landmarks
	if (T in landmarks[LANDMARK_TELESCI])
		return TRUE

	if ((istype(T.loc,/area) && T.loc:teleport_blocked) || isrestrictedz(T.z))
		return FALSE

	if (istype(T.loc, /area/shuttle/escape/station))
		if (T.density)
			return FALSE
		for (var/obj/O in T)
			if (O.density)
				return FALSE

	return TRUE

/obj/machinery/networked/telepad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	name = "teleport pad"
	anchored = 1
	density = 0
	layer = FLOOR_EQUIP_LAYER1
	mats = 16
	timeout = 10
	desc = "Stand on this to have your wildest dreams come true!"
	device_tag = "PNET_S_TELEPAD"
	plane = PLANE_NOSHADOW_BELOW
	var/recharging = 0
	var/realx = 0
	var/realy = 0
	var/realz = 0
	var/tmp/session = null
	var/obj/perm_portal/start_portal
	var/obj/perm_portal/end_portal
	var/image/disconnectedImage
	deconstruct_flags = DECON_CROWBAR | DECON_MULTITOOL | DECON_WELDER | DECON_WIRECUTTERS | DECON_WRENCH | DECON_DESTRUCT

	New()
		..()
		if (!telesci_modifiers_set)
			telesci_modifiers_set = 1
			XMULTIPLY = pick(1,2,4) //If it is three, perfect precision is impossible because fractions will be recurring.
			XSUBTRACT = rand(0,100)
			YMULTIPLY = pick(1,2,4) // same as above
			YSUBTRACT = rand(0,100)
			ZSUBTRACT = rand(0,world.maxz)

		disconnectedImage = image('icons/obj/stationobjs.dmi', "pad-noconnect")

		SPAWN(0.5 SECONDS)
			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

	ex_act()
		return

	examine()
		. = ..()
		if (!src.host_id)
			. += "<span class='alert'>The [src.name]'s \"disconnected from host\" light is flashing.</span>"

	attack_hand(mob/user)
		if(..())
			return

		src.add_dialog(user)

		var/dat = "<html><head><title>Telepad</title></head><body>"

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += net_switch_html()

		user.Browse(dat,"window=telepad;size=245x302")
		onclose(user,"telepad")
		return

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)
		if (href_list["reset"])
			if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
				return

			if(!host_id && !old_host_id)
				return

			src.last_reset = world.time
			var/rem_host = src.host_id ? host_id : old_host_id
			src.host_id = null
			//src.old_host_id = null
			src.post_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_status(rem_host, "command","term_connect","device",src.device_tag)

			src.updateUsrDialog()
			return


		src.add_fingerprint(usr)
		return

	updateUsrDialog()
		..()
		if (src.host_id)
			src.overlays.len = 0
		else if (!src.overlays.len)
			src.overlays += src.disconnectedImage

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]

		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS)
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
				if(target == src.host_id)
					src.host_id = null
					src.updateUsrDialog()
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return

				if(src.host_id)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = target
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
					src.post_status(target,"command","term_message","data","command=register")
				return

			if("term_message","term_file")
				if(target != src.host_id) //Huh, who is this?
					return

				var/list/data = params2list(signal.data["data"])
				if(!data)
					return

				session = data["session"]

				switch(data["command"])
					if ("set_coords")
						var/datum/computer/file/coords/coords = signal.data_file
						if (!istype(coords))
							message_host("command=nack")
							return

						src.realx = round(  clamp(coords.destx, 0, world.maxx+1) )
						src.realy = round(  clamp(coords.desty, 0, world.maxy+1) )
						src.realz = round(  clamp(coords.destz, 0, world.maxz+1) )
						message_host("command=ack")

					if ("send")
						if (recharging)
							message_host("command=nack&cause=recharge")
							return

						src.icon_state = "pad1"
						recharging = 1
						SPAWN(0)

							var/turf/turfcheck = doturfcheck(1)
							if(!istype(turfcheck))
								src.badsend()
								if (isnum(turfcheck))
									src.message_host("command=nack&cause=bad[turfcheck & 1 ? "x" : null][turfcheck & 2 ? "y" : null][turfcheck & 4 ? "z" : null]")
								else
									src.message_host("command=nack&cause=badxyz")
							else if(!is_teleportation_allowed(turfcheck))
								src.message_host("command=nack&cause=interference")
							else
								message_host("command=ack")
								sleep(1 SECOND)
								src.send(turfcheck)
							sleep(0.5 SECONDS)

							src.icon_state = "pad0"
							sleep(1 SECOND)

							recharging = 0

					if ("receive")
						if (recharging)
							message_host("command=nack&cause=recharge")
							return

						src.icon_state = "pad1"
						recharging = 1
						SPAWN(0)

							var/turf/turfcheck = doturfcheck(1)
							if(!istype(turfcheck))
								if (isnum(turfcheck))
									src.message_host("command=nack&cause=bad[turfcheck & 1 ? "x" : null][turfcheck & 2 ? "y" : null][turfcheck & 4 ? "z" : null]")
								else
									src.message_host("command=nack&cause=badxyz")
								sleep(1 SECOND)
								src.badreceive()
							else if(!is_teleportation_allowed(turfcheck))
								src.message_host("command=nack&cause=interference")
							else
								message_host("command=ack")
								sleep(1 SECOND)
								src.receive(turfcheck)
							sleep(0.5 SECONDS)

							src.icon_state = "pad0"
							sleep(1 SECOND)

							recharging = 0

					if ("relay")
						if (recharging)
							message_host("command=nack&cause=recharge")
							return

						var/datum/computer/file/coords/coords = signal.data_file
						if (!istype(coords))
							message_host("command=nack")
							return

						var/original_realx = realx
						var/original_realy = realy
						var/original_realz = realz

						realx = coords.origx
						realy = coords.origy
						realz = coords.origz


						var/turf/sourceturf = doturfcheck(0)
						realx = coords.destx
						realy = coords.desty
						realz = coords.destz

						var/turf/endturf = doturfcheck(0)
						recharging = 1
						if (istype(sourceturf) && istype(endturf))
							if (coords.can_cheat || (is_teleportation_allowed(endturf) && is_teleportation_allowed(sourceturf)))
								src.receive(sourceturf)
								SPAWN(0)
									sleep(1 SECOND)
									recharging = 0
									sleep(4 SECONDS)
									src.send(endturf)
								message_host("command=ack")

							else
								src.message_host("command=nack&cause=interference")
								recharging = 0

						else
							src.message_host("command=nack&cause=badxyz")
							recharging = 0

						realx = original_realx
						realy = original_realy
						realz = original_realz

					if ("portal")
						if (src.start_portal || src.end_portal)
							if (start_portal)
								qdel(start_portal)
								start_portal = null
							if (end_portal)
								qdel(end_portal)
								end_portal = null

							message_host("command=ack")
							return

						if (recharging)
							message_host("command=nack&cause=recharge")
							return

						src.icon_state = "pad1"
						recharging = 1
						SPAWN(0)

							var/turf/turfcheck = doturfcheck(1)
							if(!istype(turfcheck))
								if (isnum(turfcheck))
									src.message_host("command=nack&cause=bad[turfcheck & 1 ? "x" : null][turfcheck & 2 ? "y" : null][turfcheck & 4 ? "z" : null]")
								else
									src.message_host("command=nack&cause=badxyz")
								sleep(1 SECOND)
								src.badreceive()
							else if(!is_teleportation_allowed(turfcheck))
								src.message_host("command=nack&cause=interference")
							else
								message_host("command=ack")
								sleep(1 SECOND)
								src.doubleportal(turfcheck)
							sleep(0.5 SECONDS)

							src.icon_state = "pad0"
							sleep(1 SECOND)

							recharging = 0

					if ("scan")
						var/turf/scanTurf = doturfcheck(1)
						if(!scanTurf)
							message_host("command=nack&cause=badxyz")
							return
						else
							if (isnum(scanTurf))
								src.message_host("command=nack&cause=bad[scanTurf & 1 ? "x" : null][scanTurf & 2 ? "y" : null][scanTurf & 4 ? "z" : null]")

							else if(!istype(scanTurf, /turf/space))
								var/datum/gas_mixture/GM = scanTurf.return_air()
								var/burning = 0
								if(istype(scanTurf, /turf/simulated))
									var/turf/simulated/T = scanTurf
									if(T.active_hotspot)
										burning = 1
								message_host("command=scan_reply&[MOLES_REPORT_PACKET(GM)]temp=[GM.temperature]&pressure=[MIXTURE_PRESSURE(GM)][(burning)?("&burning=1"):(null)]")
							else
								message_host("command=scan_reply&cause=noatmos")

				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.updateUsrDialog()
				return

		return

	process()
		if(status & (NOPOWER|BROKEN))
			if (start_portal || end_portal)
				qdel(start_portal)
				start_portal = null
				qdel(end_portal)
				end_portal = null
				badreceive()

			return

		use_power(200)

		if (start_portal || end_portal)
			use_power(50000) //Apparently this could run indefinitely on solar power. Fuck that. 25 000 -> 250 000
			if(prob(1))
				badreceive()

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		return

	proc/message_host(var/message, var/datum/computer/file/file)
		if (!src.host_id || !message)
			return

		if (session)
			message += "&session=[session]"

		if (file)
			src.post_file(src.host_id,"data",message, file)
		else
			src.post_status(src.host_id,"command","term_message","data",message)

		return

	proc/doturfcheck(var/notify_invalid)
		var/turf/realturf = null
		var/xisbad = (realx < 1 || realx > world.maxx) || (realx - round(realx) != 0) ? 1 : 0;
		var/yisbad = (realy < 1 || realy > world.maxy) || (realy - round(realy) != 0) ? 1 : 0;
		var/zisbad = (realz < 1 || realz > world.maxz) || (realz - round(realz) != 0) ? 1 : 0;
		if (!xisbad && !yisbad && !zisbad)
			realturf = locate(realx, realy, realz)
		else if (notify_invalid)
			realturf = 0
			realturf |= (xisbad * 1) | (yisbad * 2) | (zisbad * 4)

		return realturf

	proc/send(var/turf/target)
		if (!target)
			return 1

		var/list/stuff = list()
		for(var/atom/movable/O as obj|mob in src.loc)
			if(O.anchored) continue
			if(O == src) continue
			stuff.Add(O)
		if (stuff.len)
			var/atom/movable/which = pick(stuff)
			if(ismob(which))
				logTheThing(LOG_STATION, usr, "sent [constructTarget(which,"station")] to [log_loc(target)] from [log_loc(src)] with a telepad")
			which.set_loc(target)

		showswirl_out(src.loc)
		leaveresidual(src.loc)
		showswirl(target)
		leaveresidual(target)
		use_power(1500)
		if(prob(2) && prob(2))
			src.visible_message("<span class='alert'>The console emits a loud pop and an acrid smell fills the air!</span>")
			XSUBTRACT = rand(0,100)
			YSUBTRACT = rand(0,100)
			ZSUBTRACT = rand(0,world.maxz)
			SPAWN(1 SECOND)
				processbadeffect(pick("flash","buzz","scatter","ignite","chill"))

		return 0

	proc/receive(var/turf/receiveturf)
		if (!receiveturf)
			//boutput(usr, "Unknown interference prevents teleportation from that location!")
			return 1

		var/list/stuff = list()
		for(var/atom/movable/O as obj|mob in receiveturf)
			if(O.anchored) continue
			stuff.Add(O)
		if (stuff.len)
			var/atom/movable/which = pick(stuff)
			if(ismob(which))
				logTheThing(LOG_STATION, usr, "received [constructTarget(which,"station")] from [log_loc(which)] to [log_loc(src)] with a telepad")
			which.set_loc(src.loc)
		showswirl(src.loc)
		leaveresidual(src.loc)
		showswirl_out(receiveturf)
		leaveresidual(receiveturf)
		use_power(1500)
		if(prob(2) && prob(2))
			src.visible_message("<span class='alert'>The console emits a loud pop and an acrid smell fills the air!</span>")
			XSUBTRACT = rand(0,100)
			YSUBTRACT = rand(0,100)
			ZSUBTRACT = rand(0,world.maxz)
			SPAWN(0.5 SECONDS)
				processbadeffect(pick("flash","buzz","minorsummon","tinyfire","chill"))

		return 0

	proc/doubleportal(var/turf/target)
		if (!target)
			return 	1

		var/list/send = list()
		var/list/receive = list()
		for(var/atom/movable/O as obj|mob in src.loc)
			if(O.anchored) continue
			send.Add(O)
		for(var/atom/movable/O as obj|mob in target)
			if(O.anchored) continue
			receive.Add(O)
		for(var/atom/movable/O in send)
			O.set_loc(target)
			if(ismob(O))
				logTheThing(LOG_STATION, usr, "sent [constructTarget(O,"station")] to [log_loc(target)] from [log_loc(src)] with a telepad")

		for(var/atom/movable/O in receive)
			if(ismob(O))
				logTheThing(LOG_STATION, usr, "received [constructTarget(O,"station")] from [log_loc(O)] to [log_loc(src)] with a telepad")
			O.set_loc(src.loc)
		showswirl(src.loc)
		showswirl(target)
		use_power(500000)
		if(prob(2))
			src.visible_message("<span class='alert'>The console emits a loud pop and an acrid smell fills the air!</span>")
			XSUBTRACT = rand(0,100)
			YSUBTRACT = rand(0,100)
			ZSUBTRACT = rand(0,world.maxz)
			SPAWN(1 SECOND)
				processbadeffect(pick("flash","buzz","scatter","ignite","chill"))
		if(prob(5) && !locate(/obj/dfissure_to) in get_step(src, EAST))
			new/obj/dfissure_to(get_step(src, EAST))
		else
			start_portal = makeportal(src.loc, target)
			if (start_portal)
				end_portal = makeportal(target, src.loc)
				logTheThing(LOG_STATION, usr, "created a portal to [log_loc(target)] at [log_loc(src.loc)] with a telepad")

	proc/makeportal(var/turf/newloc, var/turf/destination)
		var/obj/perm_portal/P = new /obj/perm_portal (newloc)
		P.target = destination
		return P

	proc/badsend()
		showswirl_error(src.loc)

		var/effect = ""
		if(prob(90)) //MINOR EFFECTS
			effect = pick("flash","buzz","scatter","ignite","chill")
		else if(prob(80)) //MEDIUM EFFECTS
			effect = pick("tempblind","minormutate","sorium","rads","fire","widescatter","brute")
		else //MAJOR EFFECTS
			effect = pick("gib","majormutate","mutatearea","fullscatter")
		logTheThing(LOG_STATION, usr, "sends the telepad at [log_loc(src)] on invalid coords, causing the [effect] effect.")
		processbadeffect(effect)

	proc/badreceive()
		showswirl_error(src.loc)

		var/effect = ""
		if(prob(80)) //MINOR EFFECTS
			effect = pick("flash","buzz","minorsummon","tinyfire","chill")
		else if(prob(80)) //MEDIUM EFFECTS
			effect = pick("mediumsummon","sorium","rads","fire","getrandom")
		else //MAJOR EFFECTS
			effect = pick("mutatearea","areascatter","majorsummon")
		logTheThing(LOG_STATION, usr, "receives the telepad at [log_loc(src)] on invalid coords, causing the [effect] effect.")
		INVOKE_ASYNC(src, /obj/machinery/networked/telepad.proc/processbadeffect, effect)

	proc/processbadeffect(var/effect)
		switch(effect)
			if("")
				return
			if("flash")
				for(var/mob/O in AIviewers(src, null)) O.show_message("<span class='alert'>A bright flash emnates from the [src]!</span>", 1)
				playsound(src.loc, 'sound/weapons/flashbang.ogg', 35, 1)
				for (var/mob/N in viewers(src, null))
					if (GET_DIST(N, src) <= 6)
						N.apply_flash(30, 5)
					if (N.client)
						shake_camera(N, 6, 32)
				return
			if("buzz")
				for(var/mob/O in AIviewers(src, null)) O.show_message("<span class='alert'>You hear a loud buzz coming from the [src]!</span>", 1)
				playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
				return
			if("scatter") //stolen from hand tele, heh
				var/list/turfs = new
				var/turf/target = null
				for(var/turf/T in orange(5,src.loc))
					if(T.x>world.maxx-4 || T.x<4)	continue
					if(T.y>world.maxy-4 || T.y<4)	continue
					if (is_teleportation_allowed(T))
						turfs += T
				if(length(turfs))
					for(var/atom/movable/O as obj|mob in src.loc)
						if(O.anchored) continue
						target = pick(turfs)
						if(target) O.set_loc(target)
				qdel(turfs)
				return
			if("ignite")
				for(var/mob/living/carbon/M in src.loc)
					M.update_burning(30)
					boutput(M, "<span class='alert'>You catch fire!</span>")
				return
			if("chill")
				for(var/mob/living/carbon/M in src.loc)
					M.bodytemperature -= 100
					boutput(M, "<span class='alert'>You feel colder!</span>")
				return
			if("tempblind")
				for(var/mob/living/carbon/M in src.loc)
					M.take_eye_damage(10, 1)
					boutput(M, "<span class='alert'>You can't see anything!</span>")
				return
			if("minormutate")
				for(var/mob/living/carbon/M in src.loc)
					M:bioHolder:RandomEffect("bad")
				return
			if("sorium") // stolen from sorium, obviously
				explosion(src, src.loc, -1, -1, -1, 4)
				var/myturf = src.loc
				for(var/atom/movable/M in view(4, myturf))
					if(M.anchored) continue
					if(ismob(M)) if(hasvar(M,"weakened")) M:changeStatus("weakened", 8 SECONDS)
					if(ismob(M)) random_brute_damage(M, 20)
					var/dir_away = get_dir(myturf,M)
					var/turf/target = get_step(myturf,dir_away)
					M.throw_at(target, 10, 2)
				return
			if("rads")
				for(var/turf/T in view(5,src.loc))
					if(!T.reagents)
						T.create_reagents(1000)
					T.reagents.add_reagent("radium", 20)
				for(var/mob/O in AIviewers(src, null)) O.show_message("<span class='alert'>The area surrounding the [src] begins to glow bright green!</span>", 1)
				return
			if("fire")
				fireflash(src.loc, 6) // cogwerks - lowered from 8, too laggy
				for(var/mob/O in AIviewers(src, null)) O.show_message("<span class='alert'>A huge wave of fire explodes out from the [src]!</span>", 1)
				return
			if("widescatter")
				var/list/turfs = new
				var/turf/target = null
				for(var/turf/T in orange(30,src.loc))
					if(T.x>world.maxx-4 || T.x<4)	continue
					if(T.y>world.maxy-4 || T.y<4)	continue
					if (is_teleportation_allowed(T))
						turfs += T
				if(length(turfs))
					for(var/atom/movable/O as obj|mob in src.loc)
						if(O.anchored) continue
						target = pick(turfs)
						if(target) O.set_loc(target)
				qdel(turfs)
				return
			if("brute")
				for(var/mob/living/M in src.loc)
					M.TakeDamage("chest", rand(20,30), 0)
					boutput(M, "<span class='alert'>You feel like you're being pulled apart!</span>")
				return
			if("gib")
				for(var/mob/living/M in src.loc)
					logTheThing(LOG_COMBAT, M, "was gibbed by a telescience fault at [log_loc(M)].")
					M.gib()
				return
			if("majormutate")
				for(var/mob/living/carbon/M in src.loc)
					M:bioHolder:RandomEffect("bad")
					M:bioHolder:RandomEffect("bad")
					M:bioHolder:RandomEffect("bad")
					M:bioHolder:RandomEffect("bad")
					M:bioHolder:RandomEffect("bad")
				return
			if("mutatearea")
				for(var/mob/living/carbon/M in orange(5,src.loc))
					M:bioHolder:RandomEffect("bad")
				for(var/mob/O in AIviewers(src, null)) O.show_message("<span class='alert'>A bright green pulse emnates from the [src]!</span>", 1)
				return
			if("explosion")
				explosion(src, src.loc, 0, 0, 5, 10)
				return
			if("fullscatter")
				var/list/turfs = new
				var/turf/target = null
				for(var/turf/T in world)
					LAGCHECK(LAG_LOW)
					if(T.x>world.maxx-4 || T.x<4)	continue
					if(T.y>world.maxy-4 || T.y<4)	continue
					if (is_teleportation_allowed(T))
						turfs += T
				if(length(turfs))
					for(var/atom/movable/O as obj|mob in src.loc)
						if(O.anchored) continue
						target = pick(turfs)
						if(target) O.set_loc(target)
				qdel(turfs)
				return
			if("minorsummon")
				var/summon = pick("pig","mouse","roach","rockworm")
				switch(summon)
					if("pig")
						new /obj/critter/pig(src.loc)
					if("mouse")
						for(var/i = 1 to rand(3,8))
							new/mob/living/critter/small_animal/mouse(src.loc)
					if("roach")
						for(var/i = 1 to rand(3,8))
							new/obj/critter/roach(src.loc)
					if("rockworm")
						for(var/i = 1 to rand(3,8))
							new/obj/critter/rockworm(src.loc)
				return
			if("tinyfire")
				fireflash(src.loc, 3)
				for(var/mob/O in AIviewers(src, null))
					O.show_message("<span class='alert'>The area surrounding the [src] bursts into flame!</span>", 1)
				return
			if("mediumsummon")
				var/summon = pick(/obj/critter/maneater,/obj/critter/killertomato,/obj/critter/wasp,/obj/critter/golem,/obj/critter/magiczombie,/obj/critter/mimic)
				new summon(src.loc)
				return
			if("getrandom")
				var/turfs = list()
				for(var/turf/T in world)
					LAGCHECK(LAG_LOW)
					if(!contents) continue
					if(isrestrictedz(T.z)) continue
					turfs += T
				var/turf = pick(turfs)
				for(var/atom/movable/O as obj|mob in turf)
					O.set_loc(src.loc)
				return
			if("areascatter")
				var/list/turfs = new
				var/turf/target = null
				for(var/turf/T in orange(10,src.loc))
					if(T.x>world.maxx-4 || T.x<4)	continue
					if(T.y>world.maxy-4 || T.y<4)	continue
					if (is_teleportation_allowed(T))
						turfs += T
				if (length(turfs))
					for(var/atom/movable/O as obj|mob in oview(src,5))
						if(O.anchored) continue
						target = pick(turfs)
						if(target) O.set_loc(target)
				qdel(turfs)
				return
			if("majorsummon")
				var/summon = pick(
					/obj/critter/zombie,
					/obj/critter/bear,
					/mob/living/carbon/human/npc/syndicate,
					/obj/critter/martian/soldier,
					/obj/critter/lion,
					/obj/critter/yeti,
					/obj/critter/gunbot/drone,
					/obj/critter/ancient_thing)
				new summon(src.loc)
				return


/obj/machinery/networked/teleconsole
	icon = 'icons/obj/computer.dmi'
	icon_state = "s_teleport"
	name = "teleport computer"
	density = 1
	anchored = 1
	device_tag = "SRV_TERMINAL"
	timeout = 10
	mats = 14
	var/xtarget = 0
	var/ytarget = 0
	var/ztarget = 0

	var/list/bookmarks = new/list()
	var/max_bookmarks = 5
	var/allow_bookmarks = 1
	var/allow_scan = 1
	var/coord_update_flag = 1

	var/readout = "&nbsp;"
	var/datum/computer/file/record/user_data
	var/padNum = 1

	deconstruct_flags = DECON_CROWBAR | DECON_MULTITOOL | DECON_WIRECUTTERS | DECON_WRENCH | DECON_DESTRUCT

	New()
		..()
		START_TRACKING
		SPAWN(0.5 SECONDS)
			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

	disposing()
		. = ..()
		STOP_TRACKING

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN) || !src.link)
			return

		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/target = signal.data["sender"]

		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS)
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
				if(target == src.host_id)
					src.host_id = null
					src.updateUsrDialog()
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return

				if(src.host_id)
					return

				if (!istype(user_data))
					user_data = new

					user_data.fields["userid"] = "telepad"
					user_data.fields["access"] = "11"

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = src.host_id
				if(signal.data["data"] != "noreply" && src.link)
					//src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
					var/datum/signal/newsignal = get_free_signal()
					newsignal.source = src
					newsignal.transmission_method = TRANSMISSION_WIRE
					newsignal.data["command"] = "term_connect"
					newsignal.data["data"] = "noreply"
					newsignal.data["device"] = src.device_tag

					newsignal.data_file = user_data.copy_file()

					newsignal.data["address_1"] = target
					newsignal.data["sender"] = src.net_id

					src.link.post_signal(src, newsignal)

				src.updateUsrDialog(1)
				//SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
				//	src.post_status(target,"command","term_message","data","command=register")
				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_message","term_file")
				var/message = strip_html(signal.data["data"])
				if (message)
					message = replacetext(message, "|n", "<br>")

					src.readout = copytext(message,9,256)

				src.updateUsrDialog(1)
				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.updateUsrDialog()
				return

		return

	attack_hand(var/mob/user)
		if (..(user))
			return

		var/dat = "<head><TITLE>Teleport Computer</TITLE></head><body><br>"
		if (!host_id)
			dat += "<center id = \"readout\"><tt><font color=red><b>NO CONNECTION TO HOST</b></font></tt><br><a href='?src=\ref[src];reconnect=1'>Retry</a></center><br>"
		else
			dat += "<center id = \"readout\"><tt>[readout]</tt></center><br>"

		dat += {"<script language="JavaScript">
	function updateReadout(t)
	{
		document.getElementById("readout").innerHTML = "<tt>" + t + "</tt>";
	}
	</script>"}

		dat += "<b>Target Coordinates</b><BR>"
		dat += "X: <A href='?src=\ref[src];decreaseX=10'>(<<)</A><A href='?src=\ref[src];decreaseX=1'>(<)</A><A href='?src=\ref[src];setX=1'> [xtarget] </A><A href='?src=\ref[src];increaseX=1'>(>)</A><A href='?src=\ref[src];increaseX=10'>(>>)</A><BR><BR>"
		dat += "Y: <A href='?src=\ref[src];decreaseY=10'>(<<)</A><A href='?src=\ref[src];decreaseY=1'>(<)</A><A href='?src=\ref[src];setY=1'> [ytarget] </A><A href='?src=\ref[src];increaseY=1'>(>)</A><A href='?src=\ref[src];increaseY=10'>(>>)</A><BR><BR>"
		dat += "Z: <A href='?src=\ref[src];decreaseZ=1'>(<)</A><A href='?src=\ref[src];setZ=1'> [ztarget] </A><A href='?src=\ref[src];increaseZ=1'>(>)</A>"
		dat += "<br><br><br><A href='?src=\ref[src];send=1'>Send</A>"
		dat += "<br><A href='?src=\ref[src];receive=1'>Receive</A>"

		dat += "<br><A href='?src=\ref[src];portal=1'>Toggle Portal</A>"

		if(allow_scan)
			dat += "<br><br><A href='?src=\ref[src];scan=1'>Scan</A>"

		if(allow_bookmarks)
			dat += "<br><A href='?src=\ref[src];addbookmark=1'>Add Bookmark</A>"

		if(allow_bookmarks && length(bookmarks))
			dat += "<br><br><br>Bookmarks:"
			for (var/datum/teleporter_bookmark/b in bookmarks)
				dat += "<br>[b.name] ([b.x]/[b.y]/[b.z]) <A href='?src=\ref[src];restorebookmark=\ref[b]'>Restore</A> <A href='?src=\ref[src];deletebookmark=\ref[b]'>Delete</A>"

		dat += "<br><br><br><br><br><center><a href='?src=\ref[src];reconnect=2'>Reset Connection</a></center>"

		if (src.panel_open)
			dat += "<br>Linked Pad Number: <a href='?src=\ref[src];setpad=1'>[src.padNum]</a><br>"
			dat += net_switch_html()

		src.add_dialog(user)
		user.Browse(dat, "window=t_computer;size=400x600")
		onclose(user, "t_computer")
		return

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.panel_open = !src.panel_open
			boutput(user, "You [src.panel_open ? "unscrew" : "secure"] the cover.")
			src.updateUsrDialog()
			return

		else
			return ..()


	updateUsrDialog(var/updateReadout)
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if (M.using_dialog_of(src))
				if (updateReadout)
					M << output(url_encode(src.readout), "t_computer.browser:updateReadout")
				else
					src.Attackhand(M)

		if (issilicon(usr) || isAIeye(usr))
			if (!(usr in nearby))
				if (usr.using_dialog_of(src))
					if (updateReadout)
						usr << output(url_encode(src.readout), "t_computer.browser:updateReadout")
					else
						src.attack_ai(usr)

	Topic(href, href_list)
		if (..(href, href_list))
			return

		src.add_dialog(usr)
		playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)

		if (href_list["scan"])
			if (!host_id)
				boutput(usr, "<span class='alert'>Error: No host connection!</span>")
				return

			if (coord_update_flag)
				coord_update_flag = 0
				message_host("command=teleman&args=-p [padNum] coords x=[xtarget] y=[ytarget] z=[ztarget]")

			message_host("command=teleman&args=-p [padNum] scan")
			src.updateUsrDialog(1)
			return

		if (href_list["reconnect"])
			if ((host_id && href_list["reconnect"] != "2") || !old_host_id || !src.link)
				return

			if (href_list["reconnect"] == "2")
				host_id = null

			var/old = old_host_id
			old_host_id = null
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_WIRE
			newsignal.data["command"] = "term_connect"
			newsignal.data["device"] = src.device_tag

			newsignal.data_file = user_data.copy_file()

			newsignal.data["address_1"] = old
			newsignal.data["sender"] = src.net_id

			src.link.post_signal(src, newsignal)
			SPAWN(1 SECOND)
				if (!old_host_id)
					old_host_id = old

		if (href_list["restorebookmark"])
			var/datum/teleporter_bookmark/bm = locate(href_list["restorebookmark"]) in bookmarks
			if(!bm) return
			xtarget = bm.x
			ytarget = bm.y
			ztarget = bm.z
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		if (href_list["deletebookmark"])
			var/datum/teleporter_bookmark/bm = locate(href_list["deletebookmark"]) in bookmarks
			if(!bm) return
			bookmarks.Remove(bm)
			src.updateUsrDialog()
			return

		if (href_list["addbookmark"])
			if(bookmarks.len >= max_bookmarks)
				boutput(usr, "<span class='alert'>Maximum number of Bookmarks reached.</span>")
				return
			var/datum/teleporter_bookmark/bm = new
			var/title = input(usr,"Enter name:","Name","New Bookmark") as text
			title = copytext(adminscrub(title), 1, 128)
			if(!length(title)) return
			bm.name = title
			bm.x = xtarget
			bm.y = ytarget
			bm.z = ztarget
			bookmarks.Add(bm)
			src.updateUsrDialog()
			playsound(src.loc, "keyboard", 50, 1, -15)
			return

		if (href_list["setpad"])
			src.padNum = (src.padNum & 3) + 1
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		if (href_list["decreaseX"])
			var/change = text2num_safe(href_list["decreaseX"])
			xtarget = clamp(xtarget-change, 0, 500)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["increaseX"])
			var/change = text2num_safe(href_list["increaseX"])
			xtarget = clamp(xtarget+change, 0, 500)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["setX"])
			var/change = input(usr,"Target X:","Enter target X coordinate",xtarget) as num
			if(!isnum_safe(change))
				return
			xtarget = clamp(change, 0, 500)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["decreaseY"])
			var/change = text2num_safe(href_list["decreaseY"])
			ytarget = clamp(ytarget-change, 0, 500)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["increaseY"])
			var/change = text2num_safe(href_list["increaseY"])
			ytarget = clamp(ytarget+change, 0, 500)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["setY"])
			var/change = input(usr,"Target Y:","Enter target Y coordinate",ytarget) as num
			if(!isnum_safe(change))
				return
			ytarget = clamp(change, 0, 500)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["decreaseZ"])
			var/change = text2num_safe(href_list["decreaseZ"])
			ztarget = clamp(ztarget-change, 0, 14)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["increaseZ"])
			var/change = text2num_safe(href_list["increaseZ"])
			ztarget = clamp(ztarget+change, 0, 14)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["setZ"])
			var/change = input(usr,"Target Z:","Enter target Z coordinate",ztarget) as num
			if(!isnum_safe(change))
				return
			ztarget = clamp(change, 0, 14)
			coord_update_flag = 1
			src.updateUsrDialog()
			return

		else if (href_list["send"])
			if (!host_id)
				boutput(usr, "<span class='alert'>Error: No host connection!</span>")
				return

			if (coord_update_flag)
				coord_update_flag = 0
				message_host("command=teleman&args=-p [padNum] coords x=[xtarget] y=[ytarget] z=[ztarget]")

			message_host("command=teleman&args=-p [padNum] send")

			return

		else if (href_list["receive"])
			if (!host_id)
				boutput(usr, "<span class='alert'>Error: No host connection!</span>")
				return

			if (coord_update_flag)
				coord_update_flag = 0
				message_host("command=teleman&args=-p [padNum] coords x=[xtarget] y=[ytarget] z=[ztarget]")

			message_host("command=teleman&args=-p [padNum] receive")

			return

		else if (href_list["portal"])
			if (coord_update_flag)
				coord_update_flag = 0
				message_host("command=teleman&args=-p [padNum] coords x=[xtarget] y=[ytarget] z=[ztarget]")

			message_host("command=teleman&args=-p [padNum] portal toggle")

			return

		else
			usr.Browse(null, "window=t_computer")
			src.updateUsrDialog()
			return

	process()
		if(status & (NOPOWER|BROKEN))
			return
		use_power(200)

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		return

	proc/message_host(var/message, var/datum/computer/file/file)
		if (!src.host_id || !message)
			return

		if (ON_COOLDOWN(src, "hostmsg", 0.5 SECONDS))
			return

		if (file)
			src.post_file(src.host_id,"data",message, file)
		else
			src.post_status(src.host_id,"command","term_message","data",message)
