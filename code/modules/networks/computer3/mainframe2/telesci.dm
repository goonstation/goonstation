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
	for (var/atom/A as anything in by_cat[TR_CAT_TELEPORT_JAMMERS])
		if (IN_RANGE(A, T, GET_ATOM_PROPERTY(A, PROP_ATOM_TELEPORT_JAMMER)))
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

TYPEINFO(/obj/machinery/networked/telepad)
	mats = 16

/obj/machinery/networked/telepad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	name = "teleport pad"
	anchored = ANCHORED
	density = 0
	layer = FLOOR_EQUIP_LAYER1
	timeout = 10
	desc = "Stand on this to have your wildest dreams come true!"
	device_tag = "PNET_S_TELEPAD"
	plane = PLANE_NOSHADOW_BELOW
	power_usage = 200
	var/recharging = 0
	var/realx = 0
	var/realy = 0
	var/realz = 0
	var/tmp/session = null
	var/obj/laser_sink/perm_portal/start_portal
	var/obj/laser_sink/perm_portal/end_portal
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
			. += SPAN_ALERT("The [src.name]'s \"disconnected from host\" light is flashing.")

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Telepad")
			ui.open()

	ui_data(mob/user)
		. = list(
			"host_connection" = !!src.host_id
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("reset_connection")
				if(last_reset && (last_reset + NETWORK_MACHINE_RESET_DELAY >= world.time))
					return

				if(!host_id && !old_host_id)
					return

				src.last_reset = world.time
				var/rem_host = src.host_id ? host_id : old_host_id
				src.host_id = null
				//src.old_host_id = null
				src.post_status(rem_host, "command","term_disconnect")
				SPAWN(1 SECOND)
					src.post_status(rem_host, "command","term_connect","device",src.device_tag)

				src.updateUsrDialog()
				return

	attack_hand(mob/user)
		if(..())
			return
		src.ui_interact(user)

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
								sleep(0.5 SECONDS)
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
								sleep(0.5 SECONDS)
								src.badreceive()
							else if(!is_teleportation_allowed(turfcheck))
								src.message_host("command=nack&cause=interference")
							else
								message_host("command=ack")
								sleep(0.5 SECONDS)
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

					if ("lrt")
						var/tmp_place = replacetext(data["place"], "_", " ")
						if(!(tmp_place in special_places))
							message_host("command=nack&cause=badplace")
							return

						src.icon_state = "pad1"
						switch(data["action"])
							if("send")
								if(src.lrtsend(tmp_place))
									message_host("command=ack")
								else
									message_host("command=nack&cause=recharge")
							if("receive")
								if(src.lrtreceive(tmp_place))
									message_host("command=ack")
								else
									message_host("command=nack&cause=recharge")
							if("portal")
								if (src.start_portal || src.end_portal)
									if (start_portal)
										qdel(start_portal)
										start_portal = null
									if (end_portal)
										qdel(end_portal)
										end_portal = null

									message_host("command=ack")
									return

								if(src.lrtportal(tmp_place))
									message_host("command=ack")
								else
									message_host("command=nack&cause=recharge")
							else
								message_host("command=nack&cause=badcmd")
						src.icon_state = "pad0"

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
									if(length(T.active_hotspots))
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
		..()
		if(status & (NOPOWER|BROKEN))
			if (start_portal || end_portal)
				qdel(start_portal)
				start_portal = null
				qdel(end_portal)
				end_portal = null
				badreceive()

			return

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

	proc/lrtsend(var/place)
		if (!ON_COOLDOWN(src, "busy", 5 SECOND))
			if (place && (place in special_places))
				var/turf/target = null
				for(var/turf/T in landmarks[LANDMARK_LRT])
					var/name = landmarks[LANDMARK_LRT][T]
					if(name == place)
						target = T
						break
				if (!target) //we didnt find a turf to send to
					return 0
				leaveresidual(target)
				sleep(0.5 SECONDS)

				showswirl_out(src.loc, FALSE)
				playsound(src.loc, 'sound/machines/lrteleport.ogg', 60, TRUE)
				leaveresidual(src.loc)
				showswirl(target)
				use_power(1500)

				for(var/atom/movable/M in src.loc)
					if(M.anchored)
						continue
					animate_teleport(M)
					if(ismob(M))
						var/mob/O = M
						O.changeStatus("stunned", 2 SECONDS)
					SPAWN(6 DECI SECONDS)
						if(ismob(M))
							logTheThing(LOG_STATION, usr, "sent [constructTarget(M,"station")] to [log_loc(target)] from [log_loc(src)] with a telepad")
						else
							logTheThing(LOG_STATION, usr, "sent [log_object(M)] from [log_loc(M)] to [log_loc(target)] with a telepad")
						do_teleport(M,target,FALSE,use_teleblocks=FALSE,sparks=FALSE)
				return 1
			return 0

	proc/lrtreceive(var/place)
		if (!ON_COOLDOWN(src, "busy", 5 SECOND))
			if (place && (place in special_places))
				var/turf/target = null
				for(var/turf/T in landmarks[LANDMARK_LRT])
					var/name = landmarks[LANDMARK_LRT][T]
					if(name == place)
						target = T
						break
				if (!target) //we didnt find a turf to send to
					return 0
				leaveresidual(target)
				sleep(0.5 SECONDS)

				showswirl(src.loc, FALSE)
				playsound(src.loc, 'sound/machines/lrteleport.ogg', 60, TRUE)
				leaveresidual(src.loc)
				showswirl_out(target)
				use_power(1500)
				for(var/atom/movable/M in target)
					if(M.anchored)
						continue
					animate_teleport(M)
					if(ismob(M))
						var/mob/O = M
						O.changeStatus("stunned", 2 SECONDS)
					SPAWN(6 DECI SECONDS)
						if(ismob(M))
							logTheThing(LOG_STATION, usr, "received [constructTarget(M,"station")] from [log_loc(M)] to [log_loc(src)] with a telepad")
						else
							logTheThing(LOG_STATION, usr, "received [log_object(M)] from [log_loc(M)] to [log_loc(src)] with a telepad")
						do_teleport(M,src.loc,FALSE,use_teleblocks=FALSE,sparks=FALSE)
				return 1
			return 0

	proc/lrtportal(var/place)
		if (!ON_COOLDOWN(src, "busy", 5 SECOND))
			if (place && (place in special_places))
				var/turf/target = null
				for(var/turf/T in landmarks[LANDMARK_LRT])
					var/name = landmarks[LANDMARK_LRT][T]
					if(name == place)
						target = T
						break
				if (!target) //we didnt find a turf to send to
					return 0

				var/list/send = list()
				var/list/receive = list()
				for(var/atom/movable/O as obj|mob in src.loc)
					if(O.anchored) continue
					send.Add(O)
				for(var/atom/movable/O as obj|mob in target)
					if(O.anchored) continue
					receive.Add(O)
				for(var/atom/movable/O in send)
					do_teleport(O,target,FALSE,use_teleblocks=FALSE,sparks=FALSE)
					if(ismob(O))
						logTheThing(LOG_STATION, usr, "sent [constructTarget(O,"station")] to [log_loc(target)] from [log_loc(src)] with a telepad")

				for(var/atom/movable/O in receive)
					if(ismob(O))
						logTheThing(LOG_STATION, usr, "received [constructTarget(O,"station")] from [log_loc(O)] to [log_loc(src)] with a telepad")
					do_teleport(O,src.loc,FALSE,use_teleblocks=FALSE,sparks=FALSE)

				showswirl(src.loc, FALSE)
				playsound(src.loc, 'sound/machines/lrteleport.ogg', 60, TRUE)
				showswirl(target)
				use_power(400000)
				start_portal = makeportal(src.loc, target)
				if (start_portal)
					end_portal = makeportal(target, src.loc)
					logTheThing(LOG_STATION, usr, "created a portal to [log_loc(target)] at [log_loc(src.loc)] with a telepad")
				return 1

	proc/send(var/turf/target)
		if (!target)
			return 1

		leaveresidual(target)
		sleep(0.5 SECONDS)

		var/list/stuff = list()
		for(var/atom/movable/O as obj|mob in src.loc)
			if(O.anchored) continue
			if(O == src) continue
			stuff.Add(O)
		if (stuff.len)
			var/atom/movable/which = pick(stuff)
			if(ismob(which))
				logTheThing(LOG_STATION, usr, "sent [constructTarget(which,"station")] to [log_loc(target)] from [log_loc(src)] with a telepad")
			else
				logTheThing(LOG_STATION, usr, "sent [log_object(which)] from [log_loc(which)] to [log_loc(target)] with a telepad")
			// teleblock checks should already be done
			do_teleport(which,target,FALSE,use_teleblocks=FALSE,sparks=FALSE)

		showswirl_out(src.loc)
		leaveresidual(src.loc)
		showswirl(target)
		use_power(1500)
		if(prob(2) && prob(2))
			src.visible_message(SPAN_ALERT("The console emits a loud pop and an acrid smell fills the air!"))
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

		leaveresidual(receiveturf)
		sleep(0.5 SECONDS)

		var/list/stuff = list()
		for(var/atom/movable/O as obj|mob in receiveturf)
			if(O.anchored) continue
			stuff.Add(O)
		if (stuff.len)
			var/atom/movable/which = pick(stuff)
			if(ismob(which))
				logTheThing(LOG_STATION, usr, "received [constructTarget(which,"station")] from [log_loc(which)] to [log_loc(src)] with a telepad")
			else
				logTheThing(LOG_STATION, usr, "received [log_object(which)] from [log_loc(which)] to [log_loc(src)] with a telepad")
			do_teleport(which,src.loc,FALSE,use_teleblocks=FALSE,sparks=FALSE)
		showswirl(src.loc)
		leaveresidual(src.loc)
		showswirl_out(receiveturf)
		use_power(1500)
		if(prob(2) && prob(2))
			src.visible_message(SPAN_ALERT("The console emits a loud pop and an acrid smell fills the air!"))
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
			do_teleport(O,target,FALSE,use_teleblocks=FALSE,sparks=FALSE)
			if(ismob(O))
				logTheThing(LOG_STATION, usr, "sent [constructTarget(O,"station")] to [log_loc(target)] from [log_loc(src)] with a telepad")

		for(var/atom/movable/O in receive)
			if(ismob(O))
				logTheThing(LOG_STATION, usr, "received [constructTarget(O,"station")] from [log_loc(O)] to [log_loc(src)] with a telepad")
			do_teleport(O,src.loc,FALSE,use_teleblocks=FALSE,sparks=FALSE)
		showswirl(src.loc)
		showswirl(target)
		use_power(400000)
		if(prob(2))
			src.visible_message(SPAN_ALERT("The console emits a loud pop and an acrid smell fills the air!"))
			XSUBTRACT = rand(0,100)
			YSUBTRACT = rand(0,100)
			ZSUBTRACT = rand(0,world.maxz)
			SPAWN(1 SECOND)
				processbadeffect(pick("flash","buzz","scatter","ignite","chill"))
		if(prob(5) && !locate(/obj/dfissure_to) in get_step(src, NORTHEAST))
			new/obj/dfissure_to(get_step(src, NORTHEAST))
		else
			start_portal = makeportal(src.loc, target)
			if (start_portal)
				end_portal = makeportal(target, src.loc)
				logTheThing(LOG_STATION, usr, "created a portal to [log_loc(target)] at [log_loc(src.loc)] with a telepad")

	proc/makeportal(var/turf/newloc, var/turf/destination)
		var/obj/laser_sink/perm_portal/P = new /obj/laser_sink/perm_portal (newloc)
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
		INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/networked/telepad, processbadeffect), effect)

	proc/processbadeffect(var/effect)
		switch(effect)
			if("")
				return
			if("flash")
				for(var/mob/O in AIviewers(src, null)) O.show_message(SPAN_ALERT("A bright flash emnates from the [src]!"), 1)
				playsound(src.loc, 'sound/weapons/flashbang.ogg', 35, 1)
				for (var/mob/N in viewers(src, null))
					if (GET_DIST(N, src) <= 6)
						N.apply_flash(30, 5)
					if (N.client)
						shake_camera(N, 6, 32)
				return
			if("buzz")
				for(var/mob/O in AIviewers(src, null)) O.show_message(SPAN_ALERT("You hear a loud buzz coming from the [src]!"), 1)
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
						if(target) do_teleport(O,target,FALSE,use_teleblocks=FALSE,sparks=FALSE)
				qdel(turfs)
				return
			if("ignite")
				for(var/mob/living/carbon/M in src.loc)
					M.update_burning(30)
					boutput(M, SPAN_ALERT("You catch fire!"))
				return
			if("chill")
				for(var/mob/living/carbon/M in src.loc)
					M.bodytemperature -= 100
					boutput(M, SPAN_ALERT("You feel colder!"))
				return
			if("tempblind")
				for(var/mob/living/carbon/M in src.loc)
					M.take_eye_damage(10, 1)
					boutput(M, SPAN_ALERT("You can't see anything!"))
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
					if(ismob(M))
						M.changeStatus("knockdown", 8 SECONDS)
					if(ismob(M)) random_brute_damage(M, 20)
					var/dir_away = get_dir(myturf,M)
					var/turf/target = get_step(myturf,dir_away)
					M.throw_at(target, 10, 2)
				return
			if("rads")
				playsound(src, 'sound/weapons/ACgun2.ogg', 50, TRUE)
				for (var/i in 1 to rand(3,5))
					var/datum/projectile/neutron/projectile = new(15)
					shoot_projectile_DIR(src, projectile, pick(alldirs))
				src.visible_message(SPAN_ALERT("A bright green pulse emanates from the [src]!"))
				return
			if("fire")
				fireflash(src.loc, 6, chemfire = CHEM_FIRE_RED) // cogwerks - lowered from 8, too laggy
				for(var/mob/O in AIviewers(src, null)) O.show_message(SPAN_ALERT("A huge wave of fire explodes out from the [src]!"), 1)
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
						if(target) do_teleport(O,target,FALSE,use_teleblocks=FALSE,sparks=FALSE)
				qdel(turfs)
				return
			if("brute")
				for(var/mob/living/M in src.loc)
					M.TakeDamage("chest", rand(20,30), 0)
					boutput(M, SPAN_ALERT("You feel like you're being pulled apart!"))
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
				for(var/mob/O in AIviewers(src, null)) O.show_message(SPAN_ALERT("A bright green pulse emnates from the [src]!"), 1)
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
						if(target) do_teleport(O,target,FALSE,use_teleblocks=FALSE,sparks=FALSE)
				qdel(turfs)
				return
			if("minorsummon")
				var/summon = pick("pig","mouse","roach","rockworm")
				switch(summon)
					if("pig")
						new /mob/living/critter/small_animal/pig(src.loc)
					if("mouse")
						for(var/i = 1 to rand(3,8))
							new /mob/living/critter/small_animal/mouse(src.loc)
					if("roach")
						for(var/i = 1 to rand(3,8))
							new /mob/living/critter/small_animal/cockroach(src.loc)
					if("rockworm")
						for(var/i = 1 to rand(3,8))
							new /mob/living/critter/rockworm(src.loc)
				return
			if("tinyfire")
				fireflash(src.loc, 3, chemfire = CHEM_FIRE_RED)
				for(var/mob/O in AIviewers(src, null))
					O.show_message(SPAN_ALERT("The area surrounding the [src] bursts into flame!"), 1)
				return
			if("mediumsummon")
				var/summon = pick(/mob/living/critter/plant/maneater, /obj/critter/killertomato, /mob/living/critter/small_animal/wasp, /mob/living/critter/golem, /mob/living/critter/skeleton, /mob/living/critter/mimic)
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
					do_teleport(O,src.loc,FALSE,use_teleblocks=FALSE,sparks=FALSE)
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
						if(target) do_teleport(O,target,FALSE,use_teleblocks=FALSE,sparks=FALSE)
				qdel(turfs)
				return
			if("majorsummon")
				var/summon = pick(
					/mob/living/critter/zombie,
					/mob/living/critter/bear,
					/mob/living/critter/martian/soldier,
					/mob/living/critter/lion,
					/obj/critter/yeti,
					/obj/critter/gunbot/drone,
					/obj/critter/ancient_thing)
				new summon(src.loc)
				return

TYPEINFO(/obj/machinery/networked/teleconsole)
	mats = 14

/obj/machinery/networked/teleconsole
	icon = 'icons/obj/computer.dmi'
	icon_state = "s_teleport"
	name = "teleport computer"
	density = 1
	anchored = ANCHORED
	device_tag = "SRV_TERMINAL"
	timeout = 10
	var/xtarget = 0
	var/ytarget = 0
	var/ztarget = 0

	var/list/bookmarks = new/list()
	var/max_bookmarks = 5
	var/allow_bookmarks = 1
	var/allow_scan = 1
	var/coord_update_flag = 1

	var/readout = ""
	var/datum/computer/file/record/user_data
	var/obj/item/disk/data/floppy/diskette = null
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
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return

				if(src.host_id)
					return

				if (!istype(user_data))
					user_data = new

					user_data.fields["userid"] = src.net_id
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
					tgui_process.update_uis(src)

				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

		return

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.panel_open = !src.panel_open
			boutput(user, "You [src.panel_open ? "unscrew" : "secure"] the cover.")
			return
		else if (istype(W, /obj/item/disk/data/floppy))
			if (!src.diskette)
				user.drop_item()
				W.set_loc(src)
				src.diskette = W
				boutput(user, "You insert [W].")
				src.updateUsrDialog()
				return
		else
			return ..()

	process()
		if(status & (NOPOWER|BROKEN))
			return
		use_power(200)

		if(!host_id || !link)
			return

		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

		return

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "TeleConsole", src.name)
			ui.open()

	ui_data(mob/user)
		. = list(
			"xTarget" = xtarget,
			"yTarget" = ytarget,
			"zTarget" = ztarget,
			"hostId" = host_id,
			"readout" = readout,
			"isPanelOpen" = panel_open,
			"padNum" = padNum,
			"maxBookmarks" = max_bookmarks,
			"bookmarks" = list(),
			"destinations" = list(),
			"disk" = !isnull(src.diskette),
		)

		if (length(special_places))
			.["destinations"] = list()

			for(var/A in special_places)
				.["destinations"] += list(list(
					"ref" = ref(A),
					"name" = "[A]"))

		if (length(bookmarks) > 0)
			.["bookmarks"] = list()
			for (var/datum/teleporter_bookmark/b as anything in bookmarks)
				.["bookmarks"] += list(list(
					"nameRef" = ref(b),
					"name" = b.name,
					"x" = b.x,
					"y" = b.y,
					"z" = b.z,
				))

	ui_act(action, params)
		. = ..()
		if (.)
			return .

		switch(action)
			if ("setX")
				xtarget = clamp(text2num(params["value"]), 0, 500)
				coord_update_flag = TRUE
				. = TRUE
			if ("setY")
				ytarget = clamp(text2num(params["value"]), 0, 500)
				coord_update_flag = TRUE
				. = TRUE
			if ("setZ")
				ztarget = clamp(text2num(params["value"]), 0, 14)
				coord_update_flag = TRUE
				. = TRUE

			if ("send")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if (!host_id)
					boutput(usr, SPAN_ALERT("Error: No host connection!"))
					return

				if (coord_update_flag)
					coord_update_flag = FALSE
					message_host("command=teleman&args=-p [padNum] coords x=[xtarget] y=[ytarget] z=[ztarget]")

				message_host("command=teleman&args=-p [padNum] send")
				. = TRUE
			if ("receive")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if (!host_id)
					boutput(usr, SPAN_ALERT("Error: No host connection!"))
					return

				if (coord_update_flag)
					coord_update_flag = TRUE
					message_host("command=teleman&args=-p [padNum] coords x=[xtarget] y=[ytarget] z=[ztarget]")

				message_host("command=teleman&args=-p [padNum] receive")
				. = TRUE
			if ("portal")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if (!host_id)
					boutput(usr, SPAN_ALERT("Error: No host connection!"))
					return

				if (coord_update_flag)
					coord_update_flag = TRUE
					message_host("command=teleman&args=-p [padNum] coords x=[xtarget] y=[ytarget] z=[ztarget]")

				message_host("command=teleman&args=-p [padNum] portal toggle")
				. = TRUE
			if ("scan")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if (!host_id)
					boutput(usr, SPAN_ALERT("Error: No host connection!"))
					return

				if (coord_update_flag)
					coord_update_flag = TRUE
					message_host("command=teleman&args=-p [padNum] coords x=[xtarget] y=[ytarget] z=[ztarget]")

				message_host("command=teleman&args=-p [padNum] scan")
				. = TRUE
			if ("restorebookmark")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				var/datum/teleporter_bookmark/bm = locate(params["value"]) in src.bookmarks
				if(!bm) return
				xtarget = bm.x
				ytarget = bm.y
				ztarget = bm.z
				coord_update_flag = TRUE
				. = TRUE

			if ("deletebookmark")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				var/datum/teleporter_bookmark/bm = locate(params["value"]) in src.bookmarks
				if(!bm) return
				bookmarks.Remove(bm)
				. = TRUE

			if ("addbookmark")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if(length(bookmarks) >= max_bookmarks)
					boutput(usr, SPAN_ALERT("Maximum number of Bookmarks reached."))
					return
				var/datum/teleporter_bookmark/bm = new
				var/title = params["value"]
				title = copytext(adminscrub(title), 1, 128)
				if(!length(title)) return
				bm.name = title
				bm.x = xtarget
				bm.y = ytarget
				bm.z = ztarget
				bookmarks.Add(bm)
				playsound(src.loc, "keyboard", 50, 1, -15)
				. = TRUE

			if ("reconnect")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if (params["value"] == "2")
					host_id = null

				var/old = old_host_id
				old_host_id = null
				var/datum/signal/newsignal = get_free_signal()
				newsignal.source = src
				newsignal.transmission_method = TRANSMISSION_WIRE
				newsignal.data["command"] = "term_connect"
				newsignal.data["device"] = src.device_tag

				if (!istype(user_data))
					user_data = new
					user_data.fields["userid"] = src.net_id
					user_data.fields["access"] = "11"

				newsignal.data_file = user_data.copy_file()

				newsignal.data["address_1"] = old
				newsignal.data["sender"] = src.net_id

				src.link.post_signal(src, newsignal)
				SPAWN(1 SECOND)
					if (!old_host_id)
						old_host_id = old
				. = TRUE

			if ("setpad")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				src.padNum = (src.padNum & 3) + 1
				. = TRUE

			if ("lrt_portal")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if (!host_id)
					boutput(usr, SPAN_ALERT("Error: No host connection!"))
					return

				message_host("command=teleman&args=-p [padNum] lrt portal place=[replacetext(params["name"], " ", "_")]")
				. = TRUE

			if ("lrt_send")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if (!host_id)
					boutput(usr, SPAN_ALERT("Error: No host connection!"))
					return

				message_host("command=teleman&args=-p [padNum] lrt send place=[replacetext(params["name"], " ", "_")]")
				. = TRUE

			if ("lrt_receive")
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				if (!host_id)
					boutput(usr, SPAN_ALERT("Error: No host connection!"))
					return

				message_host("command=teleman&args=-p [padNum] lrt receive place=[replacetext(params["name"], " ", "_")]")
				. = TRUE

			if ("eject_disk")
				if (!isnull(src.diskette))
					playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
					src.diskette.set_loc(src.loc)
					usr.put_in_hand_or_eject(src.diskette)
					src.diskette = null
					. = TRUE

			if ("scan_disk")
				if (!isnull(src.diskette))
					playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
					var/file_found
					var/file_added
					for(var/datum/computer/file/lrt_data/galactic_position in src.diskette.root.contents)
						if(!special_places.Find(galactic_position.place_name))
							var/target
							for(var/turf/T in landmarks[LANDMARK_LRT])
								var/name = landmarks[LANDMARK_LRT][T]
								if(name == galactic_position.place_name)
									target = T
									break
							if (!target) //we didnt find a turf to send to
								src.readout = "Invalid Galactic Coordinates"
								return
							else
								special_places.Add(galactic_position.place_name)
							file_added = TRUE
						file_found = TRUE

					if(file_added)
						src.readout = "Galactic Coordinates Saved"
					else if(file_found)
						src.readout = "No new data"
					else
						src.readout = "Galactic Coordinates not found"
					. = TRUE

	proc/message_host(var/message, var/datum/computer/file/file)
		if (!src.host_id || !message)
			return

		if (ON_COOLDOWN(src, "hostmsg", 0.5 SECONDS))
			return

		if (file)
			src.post_file(src.host_id,"data",message, file)
		else
			src.post_status(src.host_id,"command","term_message","data",message)


