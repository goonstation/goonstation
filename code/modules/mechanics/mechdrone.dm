/mob/living/critter/small_animal/mechdrone //Yes I know it's silly but if it works, eh.
	name = "Mech Drone"
	desc = "A programmable robotic drone that responds to network packets."
	icon = 'icons/misc/mechDrone.dmi'
	icon_state = "1"
	density = FALSE
	var/range = 150
	var/net_id = null //What is our ID on the network?
	var/frequency = FREQ_FREE
	var/obj/item/load = null
	ai_type = null
	health_brute = 400
	health_brute_vuln = 0.1
	blood_id = "oil"





	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute)


	New()
		..()
		src.health = 4000
		src.max_health = 4000
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Frequency",PROC_REF(setFreqManually))

		src.net_id = format_net_id("\ref[src]")
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "main", frequency)

	get_desc()
		. = ..()
		. += SPAN_NOTICE("<br>Its network address is [net_id].")

	Cross(atom/movable/mover)
		. = ..()
		if(istype(mover, /turf/simulated/wall))
			return  // Don't cross walls
		if(istype(mover, /obj/window))
			return // Don't cross windows
		else
			return TRUE // Cross other turfs



	proc/setFreqManually(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Frequency:","Frequency setting", frequency) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(!isnull(inp))
			set_frequency(inp)
			boutput(user, "Frequency set to [inp]")
			// tooltip_rebuild = 1
			return 1
		return 0

	proc/set_frequency(new_frequency)
		if(!radio_controller) return
		//tooltip_rebuild = 1
		new_frequency = clamp(new_frequency, 1000, 1500)
		frequency = new_frequency
		get_radio_connection_by_id(src, "main").update_frequency(frequency)

	/mob/living/critter/small_animal/mechdrone/proc/receive_signal(datum/signal/signal)
		if((signal.data["address_1"] == src.net_id)  || (signal.data["address_1"] == "ping"))

			if((signal.data["address_1"] == "ping") && signal.data["sender"])
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.source = src
				pingsignal.data["device"] = "MECH_DRONE"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"
				pingsignal.data["data"] = "Mech Drone"

				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal, src.range)

		//var/senderid = signal.data["sender"]
		switch( lowertext(signal.data["command"]) )
			// if("open") //debug test
			// 	SPAWN(0)
			// 		src.icon_state = "2"
			if("follow")
				SPAWN(0)
					var/turf/target_turf = find_target_location_from_signal(signal)
					if(target_turf && (istype(target_turf, /turf) || istype(target_turf, /mob) || istype(target_turf, /obj)))
						if(target_turf.z == src.z)
						// Use mulebot-style pathfinding
							var/list/path = get_path_to(src, target_turf, max_distance=200, id=null, skip_first=FALSE, exclude=null, cardinal_only=TRUE, do_doorcheck=TRUE)
							if(path && length(path) > 1)
								for(var/turf/step in path)
									if(!src) break
									// If the next step is an airlock, open it if needed
									for(var/obj/machinery/door/airlock/A in step)
										if(A.density && (!A.req_access || A.req_access == access_engineering || A.req_access == access_maint_tunnels))
											A.open()
											sleep(3)
									step_to(src, step)
									sleep(1)
							else
								// Fallback to walk_to if pathfinding fails
								walk_to(src, target_turf, 0, 5, 5)


			if("stop")
				SPAWN(0)
					src.stop_movement()
			if("load")
				SPAWN(0)
					var/turf/current_turf = get_turf(src)
					if(current_turf)
						var/obj/item/smallest_item = null
						var/smallest_volume = INFINITY
						for(var/obj/item/I in current_turf)
							if(I.loc == current_turf && I != src && !I.anchored)
								if(I.w_class < smallest_volume)
									smallest_volume = I.w_class
									smallest_item = I
						if(smallest_item)
							// Use the hand system to pick up the item
							src.put_in_hand(smallest_item)
							load = smallest_item
							icon_state = "2"

			if("unload")
				SPAWN(0)
					if(load)
						src.drop_from_slot(load)
						icon_state = "1"
						load = null

			if("say")
				SPAWN(0)
					if(signal.data["data"])
						var/message = signal.data["data"]
						if(istext(message))
							src.say(message)
			// if("step")
			// 	SPAWN(0)
			// 		if(signal.data["data"])
			// 			var/direction = lowertext(signal.data["data"])
			// 			var/dir_const
			// 			switch(direction)
			// 				if("north") dir_const = NORTH
			// 				if("south") dir_const = SOUTH
			// 				if("east") dir_const = EAST
			// 				if("west") dir_const = WEST
			// 			if(dir_const)
			// 				var/turf/target_turf = get_step(src, dir_const)
			// 				if(target_turf && (istype(target_turf, /turf) || istype(target_turf, /mob) || istype(target_turf, /obj)))
			// 					step_to(src, target_turf)

			if("pointer")
				SPAWN(0)
					if(signal.data["data"])
						var/pointer_name = signal.data["data"]
						// Search for a pointer with the given name on the same z-level
						for(var/obj/item/mechdrone_pointer/P in world)
							if(P.pointer_name == pointer_name && P.z == src.z)
								// Use mulebot-style pathfinding
								var/list/path = get_path_to(src, P, max_distance=200, id=null, skip_first=FALSE, exclude=null, cardinal_only=TRUE, do_doorcheck=TRUE)
								if(path && length(path) > 1)
									for(var/turf/step in path)
										if(!src) break
										// If the next step is an airlock, open it if needed
										for(var/obj/machinery/door/airlock/A in step)
											if(A.density && (!A.req_access || A.req_access == access_engineering || A.req_access == access_maint_tunnels))
												A.open()
												sleep(3)
										step_to(src, step)
										sleep(1)
								else
									// Fallback to walk_to if pathfinding fails
									walk_to(src, P, 0, 5, 5)
								break
			if("interact")
				SPAWN(0)
					if(signal.data["data"])
						var/target_name = signal.data["data"]
						var/found = FALSE
						for(var/dir in cardinal)
							var/turf/T = get_step(get_turf(src), dir)
							if(!T) continue
							for(var/obj/O in T)
								if(O.name == target_name)
									var/obj/item/held = src.get_active_hand().item
									if(held)
										O.attackby(get_active_hand().item, src)
									else
										O.attack_hand(src)
									// After interaction, check if the item is still in hand
									if(!src.get_active_hand().item)
										load = null
										icon_state = "1"
									else
										load = src.get_active_hand()
										icon_state = "2"
									found = TRUE
									break
							if(found) break




	proc/find_target_location_from_signal(datum/signal/signal)
		if(!signal || !signal.source)
			return null
		if(isturf(signal.source))
			return signal.source
		if(ismob(signal.source) || isobj(signal.source))
			if(signal.source.loc && isturf(signal.source.loc))
				return signal.source.loc
			return null

	proc/stop_movement()
		// Stops the movement of the mechdog
		walk(src, 0)

	proc/say_something(var/message)
		// message = trimtext(copytext(sanitize(html_encode(message)), 1, MAX_MESSAGE_LEN))
		if (!message)
			return
		src.visible_message(SPAN_SAY("[src] says, \"[message]\""))


	death(gibbed)
		..()
		elecflash(src, 1, 1) // Flash the area with an electric effect
		qdel(src) // Remove the mechdrone from the world

//SCRAPPED REMOTE WITH UI THINGY
// /obj/item/remote/mechdrone_remote
// 	name = "MechDrone Remote"
// 	desc = "A remote for the basic functions of the MechDrone."
// 	icon = 'icons/obj/electronics.dmi'
// 	icon_state = "screen2"
// 	var/range = 150
// 	var/net_id = null //What is our ID on the network?
// 	var/frequency = FREQ_FREE
// 	/// Data entered by the user. Its contents will be provided as the `data` field in packets sent to implants.
// 	var/entered_data
// 	/// The current selected command that implants will be sent.
// 	var/selected_command = "say"
// 	//
// 	var/mechdrone_address = null

// 	New()
// 		..()


// 		src.net_id = format_net_id("\ref[src]")
// 		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "main", frequency)

// 	get_desc()
// 		. = ..()
// 		. += SPAN_NOTICE("<br>Its network address is [net_id].")

// 	attack_self(mob/user)
// 		src.ui_interact(user)

// 	attackby(obj/item/W, mob/user, params)
// 		return ..()

// 	afterattack(atom/target, mob/user, reach, params)
// 		if (istype(target, /obj/machinery/mechdrone))
// 			var/obj/machinery/mechdrone/drone = target
// 			mechdrone_address = drone.net_id
// 			boutput(user, SPAN_NOTICE("You set the remote to control to [mechdrone_address]."))
// 		else
// 			return ..()

// 	receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
// 		if (!signal || signal.encryption)
// 			return

// 		if (lowertext(signal.data["address_1"]) != src.net_id)
// 			return

// 		var/sender_address = lowertext(signal.data["sender"])
// 		if (sender_address == src.net_id)
// 			return


// 	ui_interact(mob/user, datum/tgui/ui)
// 		ui = tgui_process.try_update_ui(user, src, ui)
// 		if (!ui)
// 			ui = new(user, src, "MechDroneRemote", name)
// 			ui.open()

// 	ui_data(mob/user)
// 		. = ..()
// 		.["entered_data"] = src.entered_data
// 		.["selected_command"] = src.selected_command

// 	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
// 		. = ..()
// 		if (.)
// 			return
// 		if (action == "set_data")
// 			var/new_data = params["new_data"]
// 			if (!istext(new_data))
// 				return
// 			new_data = copytext(new_data, 1, 46)
// 			src.entered_data = new_data
// 			playsound(src.loc, "keyboard", 25, TRUE, -(MAX_SOUND_RANGE - 5))
// 			. = TRUE
// 		else if (action == "set_command")
// 			src.selected_command = params["new_command"]
// 			playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
// 			. = TRUE
// 		else
// 			// var/address_1 = params["address_1"]
// 			var/command = params["packet_command"]
// 			var/data = params["packet_data"]
// 			if (action == "activate")
// 				if (!mechdrone_address)
// 					boutput(usr, SPAN_ALERT("No MechDrone selected! Use the remote on a MechDrone to set the address."))
// 					return
// 				var/datum/signal/activation_packet = get_free_signal()
// 				activation_packet.source = src
// 				activation_packet.data["device"] = "MECHDRONE_REMOTE"
// 				activation_packet.data["sender"] = src.net_id
// 				activation_packet.data["address_1"] = mechdrone_address
// 				activation_packet.data["command"] = command
// 				activation_packet.data["data"] = data
// 				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, activation_packet)
// 				playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
// 				. = TRUE


	// proc/link_with(obj/item/W, mob/living/user)
	// 	var/obj/item/implant/marionette/M
	// 	if (istype(W, /obj/item/implanter))
	// 		var/obj/item/implanter/I = W
	// 		if (!istype(I.imp, /obj/item/implant/marionette))
	// 			boutput(user, SPAN_ALERT("\The [W] doesn't have a compatible implant."))
	// 			return TRUE
	// 		M = I.imp
	// 	else if (istype(W, /obj/item/implantcase))
	// 		var/obj/item/implantcase/IC = W
	// 		if (!istype(IC.imp, /obj/item/implant/marionette))
	// 			boutput(user, SPAN_ALERT("\The [W] doesn't have a compatible implant."))
	// 			return TRUE
	// 		M = IC.imp
	// 	else if (istype(W, /obj/item/implant))
	// 		M = W
	// 	if (istype(M))
	// 		if (M.burned_out)
	// 			boutput(user, SPAN_ALERT("The implant is burned out and permanently unusable."))
	// 		else if (M.net_id in src.implant_status)
	// 			boutput(user, SPAN_NOTICE("This implant is already in the remote's tracking list."))
	// 		else
	// 			boutput(user, SPAN_NOTICE("You scan the implant into \the [src]'s database."))
	// 			src.implant_status[M.net_id] = "UNKNOWN"
	// 			M.linked_address = src.net_id
	// 			user.playsound_local(user, "sound/machines/tone_beep.ogg", 30)
	// 		return TRUE



/obj/item/mechdrone_pointer
	name = "MechDrone Pointer"
	desc = "A pointer for the MechDrone. It can be used to control the drone."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "capacitor2"
	var/pointer_name = null
	anchored = UNANCHORED

	attackby(obj/item/W, mob/user)
		user.lastattacked = get_weakref(src)
		if (iswrenchingtool(W))
			if (src.anchored == ANCHORED)
				src.anchored = UNANCHORED
				boutput(user, "You unanchor the [src].")
			else
				src.anchored = ANCHORED
				boutput(user, "You anchor the [src].")
			return TRUE


	attack_self(mob/user)
		// Prompt for pointer name as before
		pointer_name = input("Name pointer:") as text
		desc = "A pointer for the MechDrone. It can be used to control the drone. Its name is [pointer_name]."

//SCRAPPED INSERT POINTER INTO MACHINERY FUNCTIONALITY
		// // Find adjacent machinery
		// var/list/nearby_machinery = list()
		// var/turf/user_turf = get_turf(user)
		// for(var/dir in cardinal)
		// 	var/turf/T = get_step(user_turf, dir)
		// 	if(!T) continue
		// 	for(var/obj/O in T)
		// 		nearby_machinery += O

		// if(!length(nearby_machinery))
		// 	boutput(user, "No adjacent machinery to insert the pointer into.")
		// 	return

		// // Let the user pick a machine
		// var/obj/machinery/choice = input(user, "Choose a machine to insert the pointer into:", "Insert Pointer") as null|anything in nearby_machinery
		// if(!choice)
		// 	boutput(user, "No machine selected.")
		// 	return

		// // Insert the pointer into the chosen machine's contents
		// choice.contents += src
		// choice.overlays += src
		// boutput(user, "You insert the [src] into [choice].")







