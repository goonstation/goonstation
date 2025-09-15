// Includes:
// - Airbridge controllers
// - Airbridge computers
// - Airbridge test buttons
// - Dummy turfs

//air bridge controllers of the same id will automatically establish and destroy air bridges between each other if told to.
//air bridges have a width of 3 not including the walls.
//dont create more than 2 controllers with the same id or stuff will break. And itll be your fault.
//Also, make sure the bridges can extend in a straight line. Or you're gonna have a really bad time

/* -------------------- Controller -------------------- */
ADMIN_INTERACT_PROCS(/obj/airbridge_controller, proc/toggle_bridge, proc/pressurize)
/obj/airbridge_controller
	name = "Airbridge Controller"
	desc = "This is an invisible thing. Yet you can see it. You notice reality unraveling around you."
	icon = 'icons/misc/mark.dmi'
	icon_state = "airbr"
	invisibility = INVIS_ALWAYS_ISH
	anchored = ANCHORED
	density = 0

	var/tunnel_width = 1
	var/id = "noodles"
	var/working = 0
	var/maintaining_bridge = 0
	var/obj/airbridge_controller/linked = null

	var/list/path = new/list()
	var/list/maintaining_turfs = new/list()

	var/primary_controller = 0 // if 1, the bridge extends from this controller to the other one when toggled by an airbridge computer
	// ONLY SET ONE CONTROLLER TO 1 OR IT'S TOTALLY POINTLESS
	var/list/obj/machinery/computer/airbr/computers = null

	var/original_turf = /turf/space
	var/floor_turf = /turf/simulated/floor/airbridge
	var/wall_turf = /turf/simulated/wall/airbridge
	var/floor_light_type = /obj/machinery/light/small/floor

	var/list/obj/my_lights = null

	var/slide_delay = 1 SECOND

	drawbridge
		name = "Drawbridge Controller"
		original_turf = /turf/simulated/floor/plating/airless/asteroid

	New()
		START_TRACKING
		..()

	proc/get_link()
		for_by_tcl(C, /obj/airbridge_controller)
			if(C.z == src.z && C.id == src.id && C != src)
				linked = C
				break

	proc/toggle_bridge()
		if(linked == null) get_link()
		if(linked == null) return

		if(linked.maintaining_bridge)
			return linked.remove_bridge()
		else if(maintaining_bridge)
			return linked.remove_bridge()
		else
			return establish_bridge()

	proc/pressurize()
		if(linked == null) get_link()
		if(linked == null) return

		if(linked.working || working) return
		if(!linked.maintaining_bridge && !maintaining_bridge) return

		if(!maintaining_turfs.len) return

		working = 1

		SPAWN(2 SECONDS)
			for(var/turf/simulated/T in maintaining_turfs)
				if(!T.air && T.density)
					continue
				if(T.parent?.group_processing)
					T.parent.suspend_group_processing()
				T.stabilize()
				LAGCHECK(LAG_LOW)

			working = 0
			updateComps()

		return

	proc/get_state_string()
		if(linked == null) get_link()
		if(linked == null) return "ERROR: Connection to secondary Airbridge controller lost."

		if(linked.working || working) return "Airbridge controller working. Please wait."
		if(linked.maintaining_bridge || maintaining_bridge) return "Airbridge established."
		if(!linked.maintaining_bridge && !maintaining_bridge) return "No active Airbridge."

		return "Unknown State."

	proc/is_working()
		if(linked == null) get_link()
		if(linked == null) return 0

		if(linked.working || working) return 1
		else return 0

	proc/is_established()
		if(linked == null) get_link()
		if(linked == null) return FALSE
		if(!linked.maintaining_bridge && !maintaining_bridge) return FALSE
		return TRUE

	proc/establish_bridge()
		if(linked == null) get_link()
		if(linked == null) return

		if(linked.working || working) return
		if(linked.maintaining_bridge || maintaining_bridge) return
		if((linked.x != src.x && linked.y != src.y) || linked.z != src.z) return

		working = 1
		maintaining_bridge = 1

		SPAWN(0)
			path.Cut()

			var/turf/current = src.loc
			path.Add(current)
			var/direction = get_dir(current, get_step(current,get_dir(current, linked.loc)))
			path[current] = direction

			while(current != linked.loc)
				var/previous = current
				current = get_step(current,get_dir(current, linked.loc))
				path.Add(current)
				direction = get_dir(previous,current)
				path[current] = direction

			var/turf/curr
			var/j = 1
			var/light_index = 1
			for(var/turf/T in path)
				if(j % 3 == 2 && floor_light_type)
					var/obj/light = null
					if(light_index <= length(my_lights))
						light = my_lights[light_index]
					else
						if(!my_lights)
							my_lights = list()
						light = new floor_light_type(T)
						my_lights += light
					light.set_loc(T)
					light.alpha = 0
					light_index++
				j++

			for(var/turf/T in path)
				var/dir = path[T]
				for(var/i = -tunnel_width, i <= tunnel_width, i++)
					if(abs(i) == tunnel_width) // wall
						curr = get_steps(T, turn(dir, 90),i)
						animate_turf_slideout(curr, src.wall_turf, dir, slide_delay)
					else // floor
						curr = get_steps(T, turn(dir, 90),i)
						animate_turf_slideout(curr, src.floor_turf, dir, slide_delay)
					curr.set_dir(dir)
					maintaining_turfs.Add(curr)
				playsound(T, 'sound/effects/airbridge_dpl.ogg', 50, TRUE)
				sleep(slide_delay)
				for(var/i = -tunnel_width, i <= tunnel_width, i++)
					curr = get_steps(T, turn(dir, 90), i)
					animate_turf_slideout_cleanup(curr)

			for(var/obj/light in my_lights)
				animate_open_from_floor(light, time=1 SECOND, self_contained=0)
				light.alpha = 255
			sleep(1 SECOND)
			for(var/obj/light in my_lights)
				light.remove_filter("alpha white")
				light.remove_filter("alpha black")
				var/obj/machinery/light/l = light
				if(istype(l))
					l.seton(1)


			working = 0
			updateComps()

		return

	proc/remove_bridge()
		if(linked == null) get_link()
		if(linked == null) return

		if(linked.working || working) return
		if(!linked.maintaining_bridge && !maintaining_bridge) return

		if(!maintaining_bridge && linked.maintaining_bridge)
			linked.remove_bridge()
			return

		if (global.map_currently_underwater)
			src.original_turf = /turf/space/fluid
		else if (src.original_turf == /turf/space/fluid)
			src.original_turf = /turf/space

		working = 1
		maintaining_bridge = 0
		playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, 1)

		SPAWN(2 SECONDS)
			var/list/path_reverse = reverse_list_range(path)

			for(var/obj/light in src.my_lights)
				animate_close_into_floor(light, time=1 SECOND, self_contained=0)
			sleep(1 SECOND)
			for(var/obj/light in my_lights)
				light.remove_filter("alpha white")
				light.remove_filter("alpha black")
				light.alpha = 0

			var/turf/curr
			for(var/turf/T in path_reverse)
				var/dir = path[T]
				var/opdir = turn(dir, 180)
				for(var/i = -tunnel_width, i <= tunnel_width, i++)
					curr = get_steps(T, turn(dir, 90), i)
					animate_turf_slidein(curr, src.original_turf, opdir, slide_delay)
				playsound(T, 'sound/effects/airbridge_dpl.ogg', 50, TRUE)
				sleep(slide_delay)
				for(var/i = -tunnel_width, i <= tunnel_width, i++)
					curr = get_steps(T, turn(dir, 90), i)
					animate_turf_slidein_cleanup(curr)

			for(var/obj/light in src.my_lights)
				light.set_loc(src)

			maintaining_turfs.Cut()
			working = 0
			updateComps()

		return

	proc/updateComps()
		for (var/obj/machinery/computer/airbr/C in src.computers)
			C.updateDialog()

	disposing()
		STOP_TRACKING
		. = ..()


/* -------------------- Computer -------------------- */

/obj/machinery/computer/airbr
	name = "Airbridge Computer"
	desc = "Used to control the airbridge."
	id = "noodles"
	icon = 'icons/obj/airtunnel.dmi'
	icon_state = "airbr0"

	// set this var to 1 in the map editor if you want the airbridge to establish and pressurize when the round starts
	// only do it to ONE of the computers for the airbridge ID or they will both try to do it and get confused
	var/starts_established = 0

	var/working = 0
	var/state_str = ""
	var/established = FALSE

	req_access = list(access_heads)

	var/list/links = list()

	var/obj/airbridge_controller/primary_controller = null

	var/emergency = 0 // 1 to automatically extend when the emergency shuttle docks
	var/connected_dock = null

	New()
		..()
		START_TRACKING
		if (src.emergency && emergency_shuttle) // emergency_shuttle is the controller datum
			emergency_shuttle.airbridges += src
		if (src.connected_dock)
			RegisterSignal(GLOBAL_SIGNAL, src.connected_dock, PROC_REF(dock_signal_handler))

	initialize()
		..()
		update_status()
		if (starts_established && length(links))
			SPAWN(1 SECOND)
				do_initial_extend()

	disposing()
		STOP_TRACKING
		..()

	proc/dock_signal_handler(datum/holder, var/signal)
		switch(signal)
			if(DOCK_EVENT_INCOMING)
				src.establish_bridge()
			if(DOCK_EVENT_ARRIVED)
				src.pressurize()
			if(DOCK_EVENT_DEPARTED)
				src.remove_bridge()

	proc/get_links()
		for_by_tcl(C, /obj/airbridge_controller)
			if (C.id == src.id)
				links.Add(C)
				if (C.primary_controller)
					src.primary_controller = C
				if(isnull(C.computers))
					C.computers = list(src)
				else
					C.computers += src

	process()
		..()
		update_status()
		if (starts_established && length(links))
			SPAWN(1 SECOND)
				do_initial_extend()
		return

	proc/pick_controller()
		if (istype(src.primary_controller))
			return src.primary_controller
		var/obj/airbridge_controller/C = pick(links)
		if (istype(C))
			return C

	proc/do_initial_extend()
		var/obj/airbridge_controller/C = src.pick_controller()
		if (!istype(C))
			return

		C.establish_bridge()

		var/sanity_counter = 0
		while (C.working && sanity_counter < 30)
			sanity_counter++
			sleep(2 SECONDS)

		C.pressurize()
		starts_established = 0

	proc/update_status()
		if(src.status & BROKEN)
			return

		if (!links.len)
			get_links()

		if (!links.len)
			working = 0
			starts_established = 0
			state_str = "ERROR: No controllers found."
			return

		var/obj/airbridge_controller/C = src.pick_controller()
		if (!istype(C))
			return

		working = C.is_working()
		icon_state = "airbr[working]"
		state_str = C.get_state_string()
		established = C.is_established()

	attack_hand(var/mob/user, params)
		if (..(user, params))
			return

		if (user.client?.tooltips)
			update_status()
			user.client.tooltips.show(
				TOOLTIP_PINNED, src,
				title = src.name,
				content = alist(
					"file" = "airbridge_controller.eta",
					"data" = alist(
						"src" = "\ref[src]",
						"state_has_error" = startswith(state_str, "ERROR"),
						"established" = established,
						"state_str" = state_str,
						"working" = working,
					)
				),
			)

		return

	proc/ensure_links()
		if (!src.links.len)
			src.get_links()
		if (!src.links.len)
			src.working = 0
			src.state_str = "ERROR: No controllers found."
			return 0
		else
			return 1

	proc/establish_bridge()
		if (!src.ensure_links())
			return 0
		var/obj/airbridge_controller/C = src.pick_controller()
		if (istype(C))
			C.establish_bridge()
			return 1

	proc/remove_bridge()
		if (!src.ensure_links())
			return 0
		var/obj/airbridge_controller/C = src.pick_controller()
		if (istype(C))
			C.remove_bridge()
			return 1

	proc/pressurize()
		if (!src.ensure_links())
			return 0
		var/obj/airbridge_controller/C = src.pick_controller()
		if (istype(C))
			C.pressurize()
			return 1

	Topic(href, href_list)
		if (..(href, href_list))
			return

		if (href_list["create"])
			if (src.emergency && emergency_shuttle)
				if (emergency_shuttle.location != SHUTTLE_LOC_STATION)
					boutput(usr, SPAN_ALERT("The airbridge cannot be deployed while the shuttle is not in position."))
					return
			if (!(src.allowed(usr)))
				boutput(usr, SPAN_ALERT("Access denied."))
				return
			if (src.establish_bridge())
				logTheThing(LOG_STATION, usr, "extended the airbridge at [usr.loc.loc] ([log_loc(usr)])")

		else if (href_list["remove"])
			if (!(src.allowed(usr)))
				boutput(usr, SPAN_ALERT("Access denied."))
				return
			if (src.remove_bridge())
				logTheThing(LOG_STATION, usr, "retracted the airbridge at [usr.loc.loc] ([log_loc(usr)])")

		else if (href_list["air"])
			if (!(src.allowed(usr)))
				boutput(usr, SPAN_ALERT("Access denied."))
				return
			if (src.pressurize())
				logTheThing(LOG_STATION, usr, "pressurized the airbridge at [usr.loc.loc] ([log_loc(usr)])")

		update_status()
		src.updateDialog()
		return

	power_change()
		if(status & BROKEN)
			icon_state = "airbrbr"
			light.disable()

		else if(powered())
			icon_state = "airbr0"
			status &= ~NOPOWER
			light.enable()
		else
			SPAWN(rand(0, 15))
				icon_state = "airbroff"
				status |= NOPOWER
				light.disable()

/obj/machinery/computer/airbr/emergency_shuttle
	emergency = 1

/obj/machinery/computer/airbr/trader_left // matching mapping area conventions
	connected_dock = COMSIG_DOCK_TRADER_WEST

/obj/machinery/computer/airbr/trader_right
	connected_dock = COMSIG_DOCK_TRADER_EAST

/obj/machinery/computer/airbr/medical_medbay
	connected_dock = COMSIG_DOCK_MEDICAL_MEDBAY

/obj/machinery/computer/airbr/medical_pathology
	connected_dock = COMSIG_DOCK_MEDICAL_PATHOLOGY

/obj/machinery/computer/airbr/mining_station
	connected_dock = COMSIG_DOCK_MINING_STATION

/* -------------------- Button -------------------- */
/obj/machinery/airbr_test_button
	name = "Airbridge Button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = ""
	var/id = "noodles"
	var/state = 0
	anchored = ANCHORED

	attack_hand(mob/user)
		for(var/obj/airbridge_controller/C in range(3, src))
			boutput(user, SPAN_NOTICE("[C.toggle_bridge()]"))
			break
		return
