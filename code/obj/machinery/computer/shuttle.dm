#define MINING_OUTPOST_NAME "Old Mining Station"

/obj/machinery/computer/shuttle
	name = "Shuttle"
	icon_state = "shuttle"
	var/auth_need = 3
	var/list/authorized = list(  )
	desc = "A computer that controls the movement of the nearby shuttle."

	light_r =0.6
	light_g = 1
	light_b = 0.1

/obj/machinery/computer/shuttle/embedded
	icon_state = "shuttle-embed"
	density = 0
	layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.
	plane = PLANE_DEFAULT

	north
		dir = NORTH
		pixel_y = 25

	east
		dir = EAST
		pixel_x = 25

	south
		dir = SOUTH
		pixel_y = -25

	west
		dir = WEST
		pixel_x = -25

/obj/machinery/computer/shuttle/embedded/syndieshuttle
	name = "Shuttle Computer"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndiepc4"

/obj/machinery/computer/asylum_shuttle
	name = "Asylum Shuttle"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_SHUTTLECOMPS
	var/active = 0
	var/shuttle_loc = 2 //1 = asylum, 2 = medbay, 3 = pathology

/obj/machinery/computer/asylum_shuttle/embedded
	icon_state = "shuttle-embed"
	density = 0
	layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.

	north
		dir = NORTH
		pixel_y = 25

	east
		dir = EAST
		pixel_x = 25

	south
		dir = SOUTH
		pixel_y = -25

	west
		dir = WEST
		pixel_x = -25

/obj/machinery/computer/prison_shuttle
	name = "Prison Shuttle"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_SHUTTLECOMPS
	var/active = 0

/obj/machinery/computer/prison_shuttle/embedded
	icon_state = "shuttle-embed"
	density = 0
	layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.

	north
		dir = NORTH
		pixel_y = 25

	east
		dir = EAST
		pixel_x = 25

	south
		dir = SOUTH
		pixel_y = -25

	west
		dir = WEST
		pixel_x = -25

/obj/machinery/computer/mining_shuttle
	name = "Shuttle Control"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_SHUTTLECOMPS
	var/active = 0
	var/shuttle_loc = 2 //1 = station 2 = diner 3 = mining outpost

/obj/machinery/computer/mining_shuttle/embedded
	icon_state = "shuttle-embed"
	density = 0
	layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.

	north
		dir = NORTH
		pixel_y = 25

	east
		dir = EAST
		pixel_x = 25

	south
		dir = SOUTH
		pixel_y = -25

	west
		dir = WEST
		pixel_x = -25

/obj/machinery/computer/research_shuttle
	name = "Shuttle Control"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_SHUTTLECOMPS
	var/active = 0
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null

/obj/machinery/computer/research_shuttle/embedded
	icon_state = "shuttle-embed"
	density = 0
	layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.

	north
		dir = NORTH
		pixel_y = 25

	east
		dir = EAST
		pixel_x = 25

	south
		dir = SOUTH
		pixel_y = -25

	west
		dir = WEST
		pixel_x = -25

/obj/machinery/computer/icebase_elevator
	name = "Elevator Control"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_ELEVATORCOMPS
	var/active = 0
	var/location = 1 // 0 for bottom, 1 for top

/obj/machinery/computer/biodome_elevator
	name = "Elevator Control"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_ELEVATORCOMPS
	var/active = 0
	var/location = 1 // 0 for bottom, 1 for top

/obj/machinery/computer/shuttle/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if(emergency_shuttle.location != SHUTTLE_LOC_STATION) return

	if (user)
		var/choice = tgui_alert(user, "Would you like to launch the shuttle?", "Shuttle control", list("Launch", "Cancel"))
		if(BOUNDS_DIST(user, src) > 0 || emergency_shuttle.location != SHUTTLE_LOC_STATION) return
		if (choice == "Launch")
			boutput(world, "<span class='notice'><B>Alert: Shuttle launch time shortened to 10 seconds!</B></span>")
			emergency_shuttle.settimeleft( 10 )
			logTheThing(LOG_ADMIN, user, "shortens Emergency Shuttle launch time to 10 seconds.")
	else
		boutput(world, "<span class='notice'><B>Alert: Shuttle launch time shortened to 10 seconds!</B></span>")
		emergency_shuttle.settimeleft( 10 )
	return TRUE

/obj/machinery/computer/shuttle/attackby(var/obj/item/W, var/mob/user)
	if(status & (BROKEN|NOPOWER))
		return
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if ((!( istype(W, /obj/item/card) ) || !( ticker ) || emergency_shuttle.location != SHUTTLE_LOC_STATION || !( user )))
		return


	if (istype(W, /obj/item/card/id))

		if (!W:access) //no access
			boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
			return

		var/list/cardaccess = W:access
		if(!istype(cardaccess, /list) || !length(cardaccess)) //no access
			boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
			return

		if(!(access_heads in W:access)) //doesn't have this access
			boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
			return 0

		var/choice = tgui_alert(user, "Would you like to (un)authorize a shortened launch time? [src.auth_need - length(src.authorized)] authorization\s are still needed. Use abort to cancel all authorizations.", "Shuttle Launch", list("Authorize", "Repeal", "Abort"))
		if(!choice || emergency_shuttle.location != SHUTTLE_LOC_STATION || BOUNDS_DIST(user, src) > 0) return
		switch(choice)
			if("Authorize")
				if(emergency_shuttle.timeleft() < 60)
					boutput(user, "The shuttle is already leaving in less than 60 seconds!")
					return
				src.authorized |= W:registered
				if (src.auth_need - src.authorized.len > 0)
					boutput(world, text("<span class='notice'><B>Alert: [] authorizations needed until shuttle is launched early</B></span>", src.auth_need - src.authorized.len))
				else
					boutput(world, "<span class='notice'><B>Alert: Shuttle launch time shortened to 60 seconds!</B></span>")
					emergency_shuttle.settimeleft(60)
					qdel(src.authorized)
					src.authorized = list(  )

			if("Repeal")
				src.authorized -= W:registered
				boutput(world, text("<span class='notice'><B>Alert: [] authorizations needed until shuttle is launched early</B></span>", src.auth_need - src.authorized.len))

			if("Abort")
				boutput(world, "<span class='notice'><B>All authorizations to shorting time for shuttle launch have been revoked!</B></span>")
				src.authorized.len = 0
				src.authorized = list(  )
	return

/obj/machinery/computer/mining_shuttle/attack_hand(mob/user)
	if(..())
		return
#ifdef TWITCH_BOT_ALLOWED
	if (user == twitch_mob)
		src.send() //hack to make this traversible for twitch
		return
#endif

	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	switch(shuttle_loc)
		if(1)
			dat += "Shuttle Location: [station_name]"
		if(2)
			dat += "Shuttle Location: Diner"
		if(3)
			dat += "Shuttle Location: [MINING_OUTPOST_NAME]"
	dat += "<BR><BR>"

	if(active)
		dat += "Moving"
	else
		for(var/i=1,i<=3,i++)
			if(i == shuttle_loc)
				continue
			switch(i)
				if(1)
					dat += "<a href='byond://?src=\ref[src];Station=1'>[station_name]</a><BR>"
				if(2)
					dat += "<a href='byond://?src=\ref[src];Diner=1'>Diner</a><BR>"
				if(3)
					dat += "<a href='byond://?src=\ref[src];Mining Outpost=1'>[MINING_OUTPOST_NAME]</a><BR>"

	user.Browse(dat, "window=shuttle")
	onclose(user, "shuttle")
	return

/obj/machinery/computer/mining_shuttle/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if(href_list["Station"])
			src.call_shuttle(1)
		else if(href_list["Diner"])
			src.call_shuttle(2)
		else if(href_list["Mining Outpost"])
			src.call_shuttle(3)
		else if (href_list["close"])
			src.remove_dialog(usr)
			usr.Browse(null, "window=shuttle")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	usr.Browse(null, "window=shuttle")
	return

/obj/machinery/computer/mining_shuttle/proc/send()
	if(!active)
		for(var/obj/machinery/computer/mining_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
			active = 1
			C.visible_message("<span class='alert'>The Old Fortuna Taxi Shuttle has been called and will leave shortly!</span>")
		SPAWN(10 SECONDS)
			call_shuttle()

/obj/machinery/computer/mining_shuttle/proc/call_shuttle(var/target_loc)
	if(!active)
		for(var/obj/machinery/computer/mining_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
			C.active = 1
			var/message_string
			switch(target_loc)
				if(1)
					message_string = "[the_station_name]"
				if(2)
					message_string = "the Diner"
				if(3)
					message_string = "the [MINING_OUTPOST_NAME]"
			C.visible_message("<span class='alert'>The Old Fortuna Taxi Shuttle is en route to [message_string]!</span>")
		SPAWN(10 SECONDS)
			var/area/start_location
			var/area/end_location
			switch(shuttle_loc)
				if(1)
					start_location = locate(/area/shuttle/mining/station)
				if(2)
					start_location = locate(/area/shuttle/mining/diner)
				if(3)
					start_location = locate(/area/shuttle/mining/outpost)
			switch(target_loc)
				if(1)
					end_location = locate(/area/shuttle/mining/station)
				if(2)
					end_location = locate(/area/shuttle/mining/diner)
				if(3)
					end_location = locate(/area/shuttle/mining/outpost)

			for(var/x in end_location)
				if(isliving(x) && !isintangible(x))
					var/mob/living/M = x
					logTheThing(LOG_COMBAT, M, "was gibbed by an arriving shuttle at [log_loc(M)].")
					M.gib(1)
				if(istype(x, /obj/storage))
					var/obj/storage/S = x
					qdel(S)

			start_location.move_contents_to(end_location)

			if(station_repair.station_generator)
				var/list/turf/turfs_to_fix = get_area_turfs(start_location)
				if(length(turfs_to_fix))
					station_repair.repair_turfs(turfs_to_fix)

			for(var/obj/machinery/computer/mining_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
				C.active = 0
				C.shuttle_loc = target_loc
				C.visible_message("<span class='alert'>The Old Fortuna Taxi Shuttle has moved!</span>")
			return

/obj/machinery/computer/prison_shuttle/attack_hand(mob/user)
	if(..())
		return
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	switch(brigshuttle_location)
		if(0)
			dat += "Shuttle Location: Prison Station"
		if(1)
			dat += "Shuttle Location: Station"
			/*
		if(2)
			dat += "Shuttle Location: Research Outpost"
			*/

	dat += "<BR>"
	if(active)
		dat += "Moving"
	else
		dat += "<a href='byond://?src=\ref[src];send=1'>Move Shuttle</a><BR><BR>"

	user.Browse(dat, "window=shuttle")
	onclose(user, "shuttle")
	return

/obj/machinery/computer/prison_shuttle/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if (href_list["send"])
			if(!active)
				for(var/obj/machinery/computer/prison_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
					active = 1
					C.visible_message("<span class='alert'>The Prison Shuttle has been called and will leave shortly!</span>")

				SPAWN(10 SECONDS)
					call_shuttle()

		else if (href_list["close"])
			src.remove_dialog(usr)
			usr.Browse(null, "window=shuttle")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/prison_shuttle/proc/call_shuttle()
	//Prison -> Station -> Outpost -> Prison.
	//Skip outpost if there's a lockdown there.
	//drsingh took outpost out for cogmap prison shuttle
	var/area/start_location
	var/area/end_location
	switch(brigshuttle_location)
		if(0)
			start_location = locate(/area/shuttle/brig/prison)
			end_location = locate(/area/shuttle/brig/station)
			start_location.move_contents_to(end_location)
			brigshuttle_location = 1
		if(1)
			start_location = locate(/area/shuttle/brig/station)
			end_location = null
			//if(researchshuttle_lockdown)
			end_location = locate(/area/shuttle/brig/prison)
			//else
				//end_location = locate(/area/shuttle/brig/outpost)

			start_location.move_contents_to(end_location)
			//if(researchshuttle_lockdown)
			brigshuttle_location = 0
			//else
				//brigshuttle_location = 2
		/*
		if(2)
			var/area/start_location = locate(/area/shuttle/brig/outpost)
			var/area/end_location = locate(/area/shuttle/brig/prison)
			start_location.move_contents_to(end_location)
			brigshuttle_location = 0
		*/

	if(station_repair.station_generator)
		var/list/turf/turfs_to_fix = get_area_turfs(start_location)
		if(length(turfs_to_fix))
			station_repair.repair_turfs(turfs_to_fix)

	for(var/obj/machinery/computer/prison_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
		active = 0
		C.visible_message("<span class='alert'>The Prison Shuttle has moved!</span>")

	return

/obj/machinery/computer/research_shuttle/New()
	..()
	SPAWN(0.5 SECONDS)
		src.net_id = generate_net_id(src)

		if(!src.link)
			var/turf/T = get_turf(src)
			var/obj/machinery/power/data_terminal/test_link = locate() in T
			if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
				src.link = test_link
				src.link.master = src

/obj/machinery/computer/research_shuttle/attack_hand(mob/user)
	if(..())
		return
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	if(researchshuttle_location)
		dat += "Shuttle Location: Station"
	else
		dat += "Shuttle Location: Research Outpost"
	dat += "<BR>"
	if(active)
		dat += "Moving"
	else
		dat += "<a href='byond://?src=\ref[src];send=1'>Move Shuttle</a><BR><BR>"

	user.Browse(dat, "window=shuttle")
	onclose(user, "shuttle")
	return

/obj/machinery/computer/research_shuttle/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (isturf(src.loc) && in_interact_range(src, usr))) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["send"])
			for(var/obj/machinery/shuttle/engine/propulsion/eng as anything in machine_registry[MACHINES_SHUTTLEPROPULSION]) // ehh
				if(eng.stat1 == 0 && eng.stat2 == 0 && eng.id == "zeta")
					boutput(usr, "<span class='alert'>Propulsion thruster damaged. Unable to move shuttle.</span>")
					return
				else
					continue

			if(researchshuttle_lockdown)
				boutput(usr, "<span class='alert'>The shuttle cannot be called during lockdown.</span>")
				return

			if(!active)
				for(var/obj/machinery/computer/research_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
					active = 1
					C.visible_message("<span class='alert'>The Research Shuttle has been called and will leave shortly!</span>")

				SPAWN(10 SECONDS)
					call_shuttle()

		else if (href_list["close"])
			src.remove_dialog(usr)
			usr.Browse(null, "window=shuttle")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/research_shuttle/proc/call_shuttle()
	if(researchshuttle_lockdown)
		boutput(usr, "<span class='alert'>This shuttle is currently on lockdown and cannot be used.</span>")
		return

	var/area/start_location
	var/area/end_location
	if(researchshuttle_location == 0)
		start_location = locate(/area/shuttle/research/outpost)
		end_location = locate(/area/shuttle/research/station)
		start_location.move_contents_to(end_location)
		researchshuttle_location = 1
	else
		if(researchshuttle_location == 1)
			start_location = locate(/area/shuttle/research/station)
			end_location = locate(/area/shuttle/research/outpost)
			start_location.move_contents_to(end_location)
			researchshuttle_location = 0

	if(station_repair.station_generator)
		var/list/turf/turfs_to_fix = get_area_turfs(start_location)
		if(length(turfs_to_fix))
			station_repair.repair_turfs(turfs_to_fix)

	for(var/obj/machinery/computer/research_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
		active = 0
		C.visible_message("<span class='alert'>The Research Shuttle has moved!</span>")

	return

/obj/machinery/computer/asylum_shuttle/attack_hand(mob/user)
	if(..())
		return

	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	switch(shuttle_loc)
		if(1)
			dat += "Shuttle Location: Asylum"
		if(2)
			dat += "Shuttle Location: Medbay"
		if(3)
			dat += "Shuttle Location: Pathology Research"
	dat += "<BR><BR>"

	if(active)
		dat += "Moving"
	else
		for(var/i=1,i<=3,i++)
			if(i == shuttle_loc)
				continue
			switch(i)
				if(1)
					dat += "<a href='byond://?src=\ref[src];asylum=1'>Asylum</a><BR>"
				if(2)
					dat += "<a href='byond://?src=\ref[src];medbay=1'>Medbay</a><BR>"
				if(3)
					dat += "<a href='byond://?src=\ref[src];pathology=1'>Pathology Research</a><BR>"

	user.Browse(dat, "window=shuttle")
	onclose(user, "shuttle")
	return

/obj/machinery/computer/asylum_shuttle/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if(href_list["asylum"])
			src.call_shuttle(1)
		else if(href_list["medbay"])
			src.call_shuttle(2)
		else if(href_list["pathology"])
			src.call_shuttle(3)
		else if (href_list["close"])
			src.remove_dialog(usr)
			usr.Browse(null, "window=shuttle")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	usr.Browse(null, "window=shuttle")
	return

/obj/machinery/computer/asylum_shuttle/proc/call_shuttle(var/target_loc)
	if(!active)
		for(var/obj/machinery/computer/asylum_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
			C.active = 1
			var/message_string
			switch(target_loc)
				if(1)
					message_string = "the Asylum"
				if(2)
					message_string = "Medbay"
				if(3)
					message_string = "Pathology Research"
			C.visible_message("<span class='alert'>The Asylum Shuttle has been sent to [message_string]!</span>")
		SPAWN(10 SECONDS)
			var/area/start_location
			var/area/end_location
			switch(shuttle_loc)
				if(1)
					start_location = locate(/area/shuttle/asylum/observation)
				if(2)
					start_location = locate(/area/shuttle/asylum/medbay)
				if(3)
					start_location = locate(/area/shuttle/asylum/pathology)
			switch(target_loc)
				if(1)
					end_location = locate(/area/shuttle/asylum/observation)
				if(2)
					end_location = locate(/area/shuttle/asylum/medbay)
				if(3)
					end_location = locate(/area/shuttle/asylum/pathology)

			for(var/x in end_location)
				if(isliving(x) && !isintangible(x))
					var/mob/living/M = x
					logTheThing(LOG_COMBAT, M, "was gibbed by an arriving shuttle at [log_loc(M)].")
					M.gib(1)
				if(istype(x, /obj/storage))
					var/obj/storage/S = x
					qdel(S)

			start_location.move_contents_to(end_location)

			if(station_repair.station_generator)
				var/list/turf/turfs_to_fix = get_area_turfs(start_location)
				if(length(turfs_to_fix))
					station_repair.repair_turfs(turfs_to_fix)

			for(var/obj/machinery/computer/asylum_shuttle/C in machine_registry[MACHINES_SHUTTLECOMPS])
				C.active = 0
				C.shuttle_loc = target_loc
				C.visible_message("<span class='alert'>The Asylum Shuttle has moved!</span>")
			return


/obj/machinery/computer/icebase_elevator/attack_hand(mob/user)
	if(..())
		return
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	if(location)
		dat += "Elevator Location: Upper level"
	else
		dat += "Elevator Location: Lower Level"
	dat += "<BR>"
	if(active)
		dat += "Moving"
	else
		dat += "<a href='byond://?src=\ref[src];send=1'>Move Elevator</a><BR><BR>"

	user.Browse(dat, "window=ice_elevator")
	onclose(user, "ice_elevator")
	return

/obj/machinery/computer/icebase_elevator/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if (href_list["send"])
			if(!active)
				for(var/obj/machinery/computer/icebase_elevator/C in machine_registry[MACHINES_ELEVATORCOMPS])
					active = 1
					C.visible_message("<span class='alert'>The elevator begins to move!</span>")
					playsound(C.loc, 'sound/machines/elevator_move.ogg', 100, 0)
				SPAWN(5 SECONDS)
					call_shuttle()

		if (href_list["close"])
			src.remove_dialog(usr)
			usr.Browse(null, "window=ice_elevator")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/icebase_elevator/proc/call_shuttle()

	if(location == 0) // at bottom
		var/area/start_location = locate(/area/shuttle/icebase_elevator/lower)
		var/area/end_location = locate(/area/shuttle/icebase_elevator/upper)
		start_location.move_contents_to(end_location, /turf/simulated/floor/plating)
		location = 1
	else // at top
		var/area/start_location = locate(/area/shuttle/icebase_elevator/upper)
		var/area/end_location = locate(/area/shuttle/icebase_elevator/lower)
		for(var/mob/living/L in end_location) // oh dear, stay behind the yellow line kids
			if(!isintangible(L))
				SPAWN(1 DECI SECOND)
					logTheThing(LOG_COMBAT, L, "was gibbed by an elevator at [log_loc(L)].")
					L.gib()
		start_location.move_contents_to(end_location, /turf/simulated/floor/arctic_elevator_shaft)
		location = 0

	for(var/obj/machinery/computer/icebase_elevator/C in machine_registry[MACHINES_ELEVATORCOMPS])
		active = 0
		C.visible_message("<span class='alert'>The elevator has moved.</span>")
		C.location = src.location

	return

/obj/machinery/computer/biodome_elevator/attack_hand(mob/user)
	if(..())
		return
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	if(location)
		dat += "Elevator Location: Upper level"
	else
		dat += "Elevator Location: Lower Level"
	dat += "<BR>"
	if(active)
		dat += "Moving"
	else
		dat += "<a href='byond://?src=\ref[src];send=1'>Move Elevator</a><BR><BR>"

	user.Browse(dat, "window=ice_elevator")
	onclose(user, "biodome_elevator")
	return

/obj/machinery/computer/biodome_elevator/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if (href_list["send"])
			if(!active)
				for(var/obj/machinery/computer/icebase_elevator/C in machine_registry[MACHINES_ELEVATORCOMPS])
					active = 1
					C.visible_message("<span class='alert'>The elevator begins to move!</span>")
					playsound(C.loc, 'sound/machines/elevator_move.ogg', 100, 0)
				SPAWN(5 SECONDS)
					call_shuttle()

		if (href_list["close"])
			src.remove_dialog(usr)
			usr.Browse(null, "window=biodome_elevator")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


// Biodome elevator code


/obj/machinery/computer/biodome_elevator/proc/call_shuttle()

	if(location == 0) // at bottom
		var/area/start_location = locate(/area/shuttle/biodome_elevator/lower)
		var/area/end_location = locate(/area/shuttle/biodome_elevator/upper)
		start_location.move_contents_to(end_location, /turf/simulated/floor/plating)
		location = 1
	else // at top
		var/area/start_location = locate(/area/shuttle/biodome_elevator/upper)
		var/area/end_location = locate(/area/shuttle/biodome_elevator/lower)
		for(var/mob/living/L in end_location) // oh dear, stay behind the yellow line kids
			if(!isintangible(L))
				SPAWN(1 DECI SECOND)
					logTheThing(LOG_COMBAT, L, "was gibbed by an elevator at [log_loc(L)].")
					L.gib()
			bioele_accident()
		start_location.move_contents_to(end_location, /turf/unsimulated/floor/setpieces/ancient_pit/shaft)
		location = 0

	for(var/obj/machinery/computer/biodome_elevator/C in machine_registry[MACHINES_ELEVATORCOMPS])
		active = 0
		C.visible_message("<span class='alert'>The elevator has moved.</span>")
		C.location = src.location

	return

/obj/sign_accidents
	name = "Elevator Safety Sign"
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "accidents_sign"
	flags = FPRINT
	density = 0
	anchored = 1

	get_desc()
		return "It says \"[bioele_shifts_since_accident] shifts since the last elevator accident. ([bioele_accidents] accidents in total.)\"."

	attack_hand(mob/user)
		boutput(user, "The sign says \"[bioele_shifts_since_accident] shifts since the last elevator accident. ([bioele_accidents] accidents in total.)\".")

proc/bioele_load_stats()
	var/savefile/S = LoadSavefile("data/ElevatorStats.sav")
	if(!S)
		return
	var/accidents
	S["accidents"] >> accidents
	if(accidents)
		bioele_accidents = accidents
	var/shifts_since_accident
	S["shifts_since_accident"] >> shifts_since_accident
	if(shifts_since_accident)
		bioele_shifts_since_accident = shifts_since_accident

proc/bioele_save_stats()
	var/savefile/S = LoadSavefile("data/ElevatorStats.sav")
	if(!S)
		return
	S["accidents"] << bioele_accidents
	S["shifts_since_accident"] << bioele_shifts_since_accident

proc/bioele_accident()
	bioele_load_stats()
	bioele_accidents++
	bioele_shifts_since_accident = 0
	bioele_save_stats()


// JOHN BILL'S JUICIN' BUS
// This is used for a secondary reliable transport between Z3 and Z5
// And also for certain adventure zones!
// You can ask warc for details but c'mon it's just copypasted prison shuttle code (for now)


var/bombini_saved = 0

/obj/machinery/computer/shuttle_bus
	name = "John's Bus"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_SHUTTLECOMPS

/obj/machinery/computer/shuttle_bus/embedded
	icon_state = "shuttle-embed"
	density = 0
	layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.


	north
		dir = NORTH
		pixel_y = 25

	east
		dir = EAST
		pixel_x = 25

	south
		dir = SOUTH
		pixel_y = -25

	west
		dir = WEST
		pixel_x = -25




/obj/machinery/computer/shuttle_bus/attack_hand(mob/user)
	if(..())
		return
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	switch(johnbus_location)
		if(0)
#ifdef MAP_OVERRIDE_NADIR
			dat += "Shuttle Location: Nadir Extraction Site"
#else
			dat += "Shuttle Location: Diner"
#endif
		if(1)
			dat += "Shuttle Location: Frontier Space Owlery"
		if(2)
			dat += "Shuttle Location: [MINING_OUTPOST_NAME]"
		if(3)
			dat += "Shuttle Location: Juicer Schweet's"


	dat += "<BR>"
	switch(johnbus_destination)
		if(0)
#ifdef MAP_OVERRIDE_NADIR
			dat += "Shuttle Destination: Nadir Extraction Site"
#else
			dat += "Shuttle Destination: Diner"
#endif
		if(1)
			dat += "Shuttle Destination: Frontier Space Owlery"
		if(2)
			dat += "Shuttle Destination: [MINING_OUTPOST_NAME]"
		if(3)
			dat += "Shuttle Destination: Juicer Schweet's"

	dat += "<BR><BR>"
	if(johnbus_active)
		dat += "Status: Cruisin"
	else

#ifdef MAP_OVERRIDE_NADIR
		dat += "<a href='byond://?src=\ref[src];dine=1'>Set Target: Nadir</a><BR>"
#else
		dat += "<a href='byond://?src=\ref[src];dine=1'>Set Target: Diner</a><BR>"
#endif
		dat += "<a href='byond://?src=\ref[src];owle=1'>Set Target: Owlery</a><BR>"
#ifndef UNDERWATER_MAP
		dat += "<a href='byond://?src=\ref[src];mine=1'>Set Target: [MINING_OUTPOST_NAME]</a><BR>"
#endif
		if(johnbill_shuttle_fartnasium_active) // here's how you can set conditional locations
			dat += "<a href='byond://?src=\ref[src];fart=1'>Set Target: Juicer Schweet's</a><BR>"
		dat += "<BR>"
		if (johnbus_location != johnbus_destination)
			dat += "<a href='byond://?src=\ref[src];send=1'>Send It</a><BR><BR>"
		else
			dat += "Let's go somewhere else, ok?<BR>"

	user.Browse(dat, "window=shuttle")
	onclose(user, "shuttle")
	return

/obj/machinery/computer/shuttle_bus/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if (href_list["send"])
			if(!johnbus_active)
				var/turf/T = get_turf(src)
				johnbus_active = 1
				for(var/obj/machinery/computer/shuttle_bus/C in machine_registry[MACHINES_SHUTTLECOMPS])

					C.visible_message("<span class='alert'>John is starting up the engines, this could take a minute!</span>")

				for(var/obj/machinery/computer/shuttle_bus/embedded/B in machine_registry[MACHINES_SHUTTLECOMPS])
					T = get_turf(B)
					SPAWN(1 DECI SECOND)
						playsound(T, 'sound/effects/ship_charge.ogg', 60, 1)
						sleep(3 SECONDS)
						playsound(T, 'sound/machines/weaponoverload.ogg', 60, 1)
						src.visible_message("<span class='alert'>The shuttle is making a hell of a racket!</span>")
						sleep(5 SECONDS)
						playsound(T, 'sound/impact_sounds/Machinery_Break_1.ogg', 60, 1)
						for(var/mob/living/M in range(src.loc, 10))
							shake_camera(M, 5, 8)
							M.add_karma(0.1)

						sleep(2 SECONDS)
						playsound(T, 'sound/effects/creaking_metal2.ogg', 70, 1)
						sleep(3 SECONDS)
						src.visible_message("<span class='alert'>The shuttle engine alarms start blaring!</span>")
						playsound(T, 'sound/machines/pod_alarm.ogg', 60, 1)
						var/obj/decal/fakeobjects/shuttleengine/smokyEngine = locate() in get_area(src)
						var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
						smoke.set_up(5, 0, smokyEngine)
						smoke.start()
						sleep(4 SECONDS)
						playsound(T, 'sound/machines/boost.ogg', 60, 1)
						for(var/mob/living/M in range(src.loc, 10))
							shake_camera(M, 10, 16)

				T = get_turf(src)
				SPAWN(25 SECONDS)
					playsound(T, 'sound/effects/flameswoosh.ogg', 70, 1)
					call_shuttle()

		else if (href_list["dine"])
			if(!johnbus_active)
				johnbus_destination = 0
				var/turf/T = get_turf(src)
				playsound(T, 'sound/machines/glitch1.ogg', 60, 1)

		else if (href_list["owle"])
			if(!johnbus_active)
				johnbus_destination = 1
				var/turf/T = get_turf(src)
				playsound(T, 'sound/machines/glitch1.ogg', 60, 1)

		else if (href_list["mine"])
			if(!johnbus_active)
				johnbus_destination = 2
				var/turf/T = get_turf(src)
				playsound(T, 'sound/machines/glitch1.ogg', 60, 1)

		else if (href_list["fart"])
			if(!johnbus_active)
				johnbus_destination = 3
				var/turf/T = get_turf(src)
				playsound(T, 'sound/machines/glitch1.ogg', 60, 1)


		else if (href_list["close"])
			src.remove_dialog(usr)
			usr.Browse(null, "window=shuttle")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/shuttle_bus/proc/call_shuttle()
	var/area/end_location = null
	var/area/start_location = null

	switch(johnbus_destination)
		if(0)
			end_location = locate(/area/shuttle/john/diner)
		if(1)
			end_location = locate(/area/shuttle/john/owlery)
		if(2)
			end_location = locate(/area/shuttle/john/mining)
		if(3)
			end_location = locate(/area/shuttle/john/grillnasium)

	switch(johnbus_location)
		if(0)
			start_location = locate(/area/shuttle/john/diner)
			start_location.move_contents_to(end_location, turf_to_skip=list(/turf/space, global.map_settings.shuttle_map_turf))

		if(1)
			start_location = locate(/area/shuttle/john/owlery)

			if(!bombini_saved)
				for(var/obj/npc/trader/bee/b in start_location)
					bombini_saved = 1
					for(var/mob/M in start_location)
						boutput(M, "<span class='notice'>It would be great if things worked that way, but they don't. You'll need to find what <b>Bombini</b> is missing, now.</span>")

			start_location.move_contents_to(end_location, turf_to_skip=list(/turf/space, global.map_settings.shuttle_map_turf))

		if(2)
			start_location = locate(/area/shuttle/john/mining)
			start_location.move_contents_to(end_location, turf_to_skip=list(/turf/space, global.map_settings.shuttle_map_turf))

		if(3)
			start_location = locate(/area/shuttle/john/grillnasium)
			start_location.move_contents_to(end_location, turf_to_skip=list(/turf/space, global.map_settings.shuttle_map_turf))

	johnbus_location = johnbus_destination

	johnbus_active = 0

	for(var/obj/machinery/computer/shuttle_bus/C in machine_registry[MACHINES_SHUTTLECOMPS])

		C.visible_message("<span class='alert'>John's Juicin' Bus has Moved!</span>")

	return

#undef MINING_OUTPOST_NAME
