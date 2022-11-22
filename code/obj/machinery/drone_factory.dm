/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-GHOST-DRONE-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/obj/machinery/ghost_catcher
	name = "ghost catcher"
	desc = "It catches ghosts! Read the name gosh I shouldn't have to explain everything to you."
	anchored = 1
	density = 1
	icon = 'icons/mob/ghost_drone.dmi'
	icon_state = "ghostcatcher0"
	mats = 0
	//var/id = "ghostdrone"
	event_handler_flags = USE_FLUID_ENTER

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	Crossed(atom/movable/O)
		if (!istype(O, /mob/dead/observer))
			return ..()
		var/mob/dead/observer/G = O
		var/datum/mind/M = G.mind

		if(!istype(M))
			return ..()

		if (!assess_ghostdrone_eligibility(M))
			out(G, "<span class='bold alert'>You are ineligible for ghostdrones!</span>")
			return ..()

		var/position = find_ghostdrone_position(M)
		if (position)
			out(G, "<span class='bold alert'>You are already #[position] in the ghostdrone queue!</span>")
			return ..()

		. = ..()
		SPAWN(0)
			if (tgui_alert(G, "Add yourself to the ghostdrone queue?", "Confirmation", list("Yes", "No")) != "Yes")
				return

			ghostdrone_candidates += M
			position = length(ghostdrone_candidates)
			out(G, "<span class='bold notice'>You have been added to the ghostdrone queue. Now position #[position].</span>")

	process()
		..()
		if (available_ghostdrones.len && length(ghostdrone_candidates))
			src.icon_state = "ghostcatcher1"

			SPAWN(0)
				var/datum/mind/M = dequeue_next_ghostdrone_candidate()
				if(istype(M))
					var/mob/dead/D = M.current
					if(istype(D))
						D.visible_message("[src] scoops up [D]!",\
						"You feel yourself being torn away from the afterlife and into [src]!")
						if(!droneize(D, TRUE))
							D.visible_message("There are no ghost drones available! Your soul is added back to the queue.")
							ghostdrone_candidates += M

		else
			src.icon_state = "ghostcatcher0"

/proc/find_ghostdrone_position(var/datum/mind/M)
	return ghostdrone_candidates.Find(M)

/proc/dequeue_next_ghostdrone_candidate()
	if(ghostdrone_candidates.len)

		for(var/i = 1; i <= ghostdrone_candidates.len; i++)
			var/datum/mind/M = ghostdrone_candidates[i]
			if(!assess_ghostdrone_eligibility(M))
				//Invalid target for the proc
				ghostdrone_candidates.Cut(i, (i--) + 1) //This looks like bullshit (and it is). It removes whatever is at position i in the list and subtracts 1 from i.
				if(istype(M))
					//Notify M that they've been punted due to ineligibility
					out(M.current, "<span class='bold alert'>You were removed from the ghostdrone queue due to ineligibility!</span>")
			else if(!.) //We have not yet selected a candidate, pick this one and dequeue
				. = M
				ghostdrone_candidates.Cut(i, (i--) + 1)
			else
				//Let them know that the queue has moved
				out(M.current, "<span class='bold notice'>You are now position #[i] in the ghostdrone queue.</span>")

/proc/assess_ghostdrone_eligibility(var/datum/mind/M)
	if(!istype(M))
		return FALSE

	var/mob/dead/G = M.current
	if (!istype(G))
		return FALSE

	if (!G.client)
		return FALSE

	if (jobban_isbanned(G, "Ghostdrone"))
		return FALSE

	if (G.client.player)
		var/round_num = G.client.player.get_rounds_participated()
		if (!isnull(round_num) && round_num < 20)
			boutput(G, "<span class='alert'>You only have [round_num] rounds played. You need 20 rounds to play this role.")
			return FALSE

	if (!G.can_respawn_as_ghost_critter())
		return FALSE

	return TRUE

#define GHOSTDRONE_BUILD_INTERVAL 1000

var/global/ghostdrone_factory_working = null // will be set to the current instance of a drone assembly when the first factory makes one, then set to null when it arrives at a recharger
var/global/last_ghostdrone_build_time = 0
var/global/list/available_ghostdrones = list()
var/global/list/ghostdrone_candidates = list()

/obj/machinery/ghostdrone_factory
	name = "drone factory"
	desc = "A slightly mysterious looking factory that spits out weird looking drones every so often. Why not."
	anchored = 1
	density = 0
	icon = 'icons/mob/ghost_drone.dmi'
	icon_state = "factory10"
	jpsUnstable = TRUE
	layer = 5 // above mobs hopefully
	mats = 0
	var/factory_section = 1 // can be 1 to 3
	var/id = "ghostdrone" // the belts through the factory should be set to the same as the factory pieces so they can control them
	var/obj/item/ghostdrone_assembly/current_assembly = null
	var/list/obj/machinery/conveyor/conveyors = list()
	var/list/obj/machinery/drone_recharger/factory/factory_rechargers = list()
	var/working = 0 // are we currently doing something to a drone piece?
	var/work_time = 20 // how long do_work()'s animation and sound effect loop runs
	var/worked_time = 0 // how long the current work cycle has run
	var/single_system = 0 // for destiny, does this only need one machine in order to make all the parts?

	New()
		..()
		src.icon_state = "factory[src.factory_section][src.working]"
		SPAWN(1 SECOND)
			src.update_conveyors()
			src.update_rechargers()

	proc/update_conveyors()
		if (src.conveyors.len)
			for (var/obj/machinery/conveyor/C as anything in src.conveyors)
				if (C.id != src.id)
					src.conveyors -= C
		for (var/obj/machinery/conveyor/C as anything in machine_registry[MACHINES_CONVEYORS])
			if (C.id == src.id)
				if (C in src.conveyors)
					continue
				src.conveyors += C

	proc/update_rechargers()
		if (src.factory_rechargers.len)
			for (var/obj/machinery/drone_recharger/factory/C as anything in src.factory_rechargers)
				if (C.id != src.id)
					src.conveyors -= C
		for (var/obj/machinery/drone_recharger/factory/C in machine_registry[MACHINES_DRONERECHARGERS])
			if (C.id == src.id)
				if (C in src.factory_rechargers)
					continue
				src.factory_rechargers += C

	disposing()
		..()
		if (src.current_assembly)
			qdel(src.current_assembly)
		if (src.conveyors.len)
			src.conveyors.len = 0

	Cross(atom/movable/O)
		if (!istype(O, /obj/item/ghostdrone_assembly))
			return ..()
		if (src.current_assembly) // we're full
			return 0 // thou shall not pass
		else // we're not full
			return 1 // thou shall pass

	Crossed(atom/movable/O)
		if (src.factory_section == 1 || !istype(O, /obj/item/ghostdrone_assembly))
			return ..()
		var/obj/item/ghostdrone_assembly/G = O
		if (G.stage != (src.factory_section - 1) || src.current_assembly)
			return ..()
		src.start_work(G)

	process()
		..()
		if (working && src.current_assembly)
			worked_time ++
			if (work_time - worked_time <= 0)
				src.stop_work()
				return

			if (prob(40))
				SPAWN(0)
					src.shake(rand(4,6))
				playsound(src, pick('sound/impact_sounds/Wood_Hit_1.ogg', 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'), 30, 1, -3)
			if (prob(40))
				var/list/sound_list = pick(ghostly_sounds, sounds_engine, sounds_enginegrump, sounds_sparks)
				if (!sound_list.len)
					return
				var/chosen_sound = pick(sound_list)
				if (!chosen_sound)
					return
				playsound(src, chosen_sound, rand(20,40), 1)

		else if (!ghostdrone_factory_working)
			if (src.factory_section == 1 || src.single_system)
				if (!ticker) // game ain't started
					return
				if (world.timeofday >= (last_ghostdrone_build_time + GHOSTDRONE_BUILD_INTERVAL))
					src.start_work()
			else
				var/obj/item/ghostdrone_assembly/G = locate() in get_turf(src)
				if (G && G.stage == (src.factory_section - 1))
					src.start_work(G)

	proc/start_work(var/obj/item/ghostdrone_assembly/G)
		if (!src.factory_rechargers.len)
			src.update_rechargers()
			if (!src.factory_rechargers.len)
				return
		var/emptySpot = 0
		for (var/obj/machinery/drone_recharger/factory/C as anything in src.factory_rechargers)
			if (!C.occupant)
				emptySpot = 1
				break
		if (!emptySpot)
			return

		if (G && !src.current_assembly && G.stage == (src.factory_section - 1))
			src.visible_message("[src] scoops up [G]!")
			G.set_loc(src)
			src.current_assembly = G
			src.working = 1
			src.icon_state = "factory[src.factory_section]1"

		else if ((src.factory_section == 1 || src.single_system) && !ghostdrone_factory_working && !src.current_assembly)
			src.current_assembly = new /obj/item/ghostdrone_assembly
			if (!src.current_assembly)
				src.current_assembly = new(src)
			src.current_assembly.set_loc(src)
			ghostdrone_factory_working = src.current_assembly // if something happens to the assembly, for whatever, reason this should become null, I guess?
			src.working = 1
			src.icon_state = "factory[src.factory_section]1"
			last_ghostdrone_build_time = world.timeofday

		if (!src.current_assembly)
			src.working = 0
			src.icon_state = "factory[src.factory_section]0"
			return

		for (var/obj/machinery/conveyor/C as anything in src.conveyors)
			if(C.disposed)
				src.conveyors -= C
				continue
			C.operating = 0
			C.setdir()

	proc/stop_work()
		src.worked_time = 0
		src.working = 0
		src.icon_state = "factory[src.factory_section]0"

		if(QDELETED(src.current_assembly))
			src.current_assembly = null
			return

		if (src.current_assembly)
			src.current_assembly.stage = src.single_system ? 3 : src.factory_section
			src.current_assembly.icon_state = "drone-stage[src.current_assembly.stage]"
			src.current_assembly.set_loc(get_turf(src))
			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 1)
			src.visible_message("[src] ejects [src.current_assembly]!")
			src.current_assembly = null

		for (var/obj/machinery/conveyor/C as anything in src.conveyors)
			if(C.disposed)
				src.conveyors -= C
				continue
			C.operating = 1
			C.setdir()

	proc/shake(var/amt = 5)
		var/orig_x = src.pixel_x
		var/orig_y = src.pixel_y
		for (amt, amt>0, amt--)
			src.pixel_x = rand(-2,2)
			src.pixel_y = rand(-2,2)
			sleep(0.1 SECONDS)
		src.pixel_x = orig_x
		src.pixel_y = orig_y
		return 1

	proc/force_new_drone()
		var/obj/item/ghostdrone_assembly/G = new /obj/item/ghostdrone_assembly
		ghostdrone_factory_working = G
		src.start_work(G)

/obj/machinery/ghostdrone_factory/part2
	icon_state = "factory20"
	factory_section = 2

/obj/machinery/ghostdrone_factory/part3
	icon_state = "factory30"
	factory_section = 3

/obj/item/ghostdrone_assembly
	name = "drone assembly"
	desc = "an incomplete floaty robot"
	icon = 'icons/mob/ghost_drone.dmi'
	icon_state = "drone-stage1"
	mats = 0
	var/stage = 1

	New()
		..()
		src.icon_state = "drone-stage[src.stage]"

	disposing()
		if (ghostdrone_factory_working == src)
			ghostdrone_factory_working = null
		..()

/obj/machinery/ghostdrone_conveyor_sensor
	name = "conveyor sensor"
	desc = "A small sensor that pauses the conveyors it's attached to until it receives a signal to start them again."
	anchored = 1
	density = 0
	icon = 'icons/obj/recycling.dmi'
	icon_state = "stopper1"
	mats = 0
	var/id_belt = "ghostdrone_lower"
	var/id_recharger = "ghostdrone"
	var/list/obj/machinery/conveyor/conveyors = list()
	var/list/obj/machinery/drone_recharger/factory/factory_rechargers = list()
	var/conveyors_active = 0

	New()
		..()
		SPAWN(1 SECOND)
			src.update_conveyors()
			src.update_rechargers()

	proc/update_conveyors()
		if (src.conveyors.len)
			for (var/obj/machinery/conveyor/C as anything in src.conveyors)
				if (C.id != src.id_belt)
					src.conveyors -= C
		for (var/obj/machinery/conveyor/C as anything in machine_registry[MACHINES_CONVEYORS])
			if (C.id == src.id_belt)
				if (C in src.conveyors)
					continue
				src.conveyors += C

	proc/update_rechargers()
		if (src.factory_rechargers.len)
			for (var/obj/machinery/drone_recharger/factory/C as anything in src.factory_rechargers)
				if (C.id != src.id_recharger)
					src.conveyors -= C
		for (var/obj/machinery/drone_recharger/factory/C in machine_registry[MACHINES_DRONERECHARGERS])
			if (C.id == src.id_recharger)
				if (C in src.factory_rechargers)
					continue
				src.factory_rechargers += C

	process()
		..()
		if (ghostdrone_factory_working)
			var/emptySpot = src.check_rechargers()
			if (src.conveyors_active && !emptySpot)
				src.set_conveyors(0)
			else if (!src.conveyors_active && emptySpot)
				src.set_conveyors(1)
			else
				return

	proc/check_rechargers()
		var/emptySpot = 0
		for (var/obj/machinery/drone_recharger/factory/C as anything in src.factory_rechargers)
			if (!C.occupant)
				emptySpot = 1
				break
		return emptySpot

	proc/set_conveyors(var/set_active = 0)
		src.conveyors_active = set_active
		for (var/obj/machinery/conveyor/C as anything in src.conveyors)
			if(C.disposed)
				src.conveyors -= C
				continue
			C.operating = set_active
			C.setdir()

/area/ghostdrone_factory
	name = "Ghost Drone Factory"
	icon_state = "cloner"
	requires_power = 0
	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	#endif
