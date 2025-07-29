/mob/living/critter/small_animal/mechdrone //Yes I know it's silly but if it works, eh.
	name = "Mech Drone"
	desc = "A programmable robotic drone that responds to network packets."
	icon = 'icons/misc/mechDrone.dmi'
	icon_state = "mechdrone"
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

	proc/receive_signal(datum/signal/signal)
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
			if("follow")
				src.follow(signal)
			if("stop")
				src.stop_movement()
			if("load")
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
						icon_state = "mechdrone_carrying"

			if("unload")
				if(load)
					src.drop_from_slot(load)
					icon_state = "mechdrone"
					load = null

			if("say")
				if(signal.data["data"])
					var/message = signal.data["data"]
					if(istext(message))
						src.say(message)

			if("pointer")
				if(signal.data["data"])
					var/pointer_name = signal.data["data"]
					// Search for a pointer with the given name on the same z-level
					for_by_tcl(P, /obj/item/mechdrone_pointer)
						if(P.pointer_name == pointer_name && P.z == src.z)
							// Use mulebot-style pathfinding
							var/list/path = get_path_to(src, P, max_distance=200, id=null, skip_first=FALSE, exclude=null, cardinal_only=TRUE, do_doorcheck=TRUE)
							if(path && length(path) > 1)
								for(var/turf/step in path)
									if(!src) break
									sleep(3)
									step_to(src, step)
									sleep(1)
							else
								// Fallback to walk_to if pathfinding fails
								walk_to(src, P, 0, 5, 5)
							break
			if("interact")
				if(signal.data["data"])
					var/target_name = signal.data["data"]
					var/found = FALSE
					for(var/obj/O in oview(1, src))
						if(O.name == target_name)
							var/obj/item/held = src.get_active_hand().item
							if(held)
								O.attackby(get_active_hand().item, src)
							else
								O.attack_hand(src)
							// After interaction, check if the item is still in hand
							if(!src.get_active_hand().item)
								load = null
								icon_state = "mechdrone"
							else
								load = src.get_active_hand()
								icon_state = "mechdrone_carrying"
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

	proc/follow(datum/signal/signal)
	//Follows the source of the signal
		var/atom/target = find_target_location_from_signal(signal)
		if(!target)
			return
		if(target.z != src.z)
			return // Don't follow if the target is on a different z-level
			// Use mulebot-style pathfinding
		var/list/path = get_path_to(src, target, max_distance=200, id=null, skip_first=FALSE, exclude=null, cardinal_only=TRUE, do_doorcheck=TRUE)
		if(path && length(path) > 1)
			for(var/turf/step in path)
				if(!src) break
				sleep(3)
				step_to(src, step)
			sleep(1)
		else
		// Fallback to walk_to if pathfinding fails
			walk_to(src, target, 0, 5, 5)


	death(gibbed)
		..()
		elecflash(src, 1, 1) // Flash the area with an electric effect
		qdel(src) // Remove the mechdrone from the world


/obj/item/mechdrone_pointer
	name = "MechDrone Pointer"
	desc = "A pointer for the MechDrone. It can be used to control the drone."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "capacitor2"
	var/pointer_name = null
	anchored = UNANCHORED

	New()
		..()
		START_TRACKING

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

	disposing()
		. = ..()
		STOP_TRACKING









