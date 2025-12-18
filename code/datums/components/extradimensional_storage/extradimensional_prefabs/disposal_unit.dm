ABSTRACT_TYPE(/obj/machinery/disposal/extradimensional)
/obj/machinery/disposal/extradimensional
	deconstruct_flags = DECON_NONE
	_health = 500
	_max_health = 500
	SYNDICATE_STEALTH_DESCRIPTION("You can't see the bottom.", null)

/obj/machinery/disposal/extradimensional/flush()
	src.flushing = 1
	FLICK("[icon_style]-flush", src)
	sleep(1 SECOND)
	playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE, 0)
	sleep(0.5 SECONDS) // wait for animation to finish

	for(var/atom/movable/AM in src)
		if (istype(AM, /obj/dummy) || istype(AM, /obj/disposalholder))
			continue
		src.on_flushed(AM)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			H.unlock_medal("It'sa me, Mario", 1)
		LAGCHECK(LAG_HIGH)

	// now reset disposal state
	ZERO_GASES(src.air_contents)
	src.flushing = 0
	src.flush = 0
	if(src.mode == 2) //Charged mode
		src.mode = 1 //Charging mode
	src.update()

/obj/machinery/disposal/extradimensional/proc/on_flushed(atom/movable/AM)
	return

/obj/machinery/disposal/extradimensional/ex_act(severity)
	src.set_broken()
	return


// ------------ ENTRANCE ------------ //
/obj/machinery/disposal/extradimensional/host
	var/prefab_path = /datum/mapPrefab/allocated/syndicate_hideout

/obj/machinery/disposal/extradimensional/host/New()
	. = ..()
	var/datum/component/extradimensional_storage/dimension_component = src.AddComponent(/datum/component/extradimensional_storage/prefab, src.prefab_path)
	dimension_component.exit = src

/obj/machinery/disposal/extradimensional/host/on_flushed(atom/movable/AM)
	var/datum/component/extradimensional_storage/dimension_component = src.GetComponent(/datum/component/extradimensional_storage)
	dimension_component.on_entered(AM)

// ------------ EXIT ------------ //

/obj/machinery/disposal/extradimensional/exit/New()
	. = ..()
	src.AddComponent(/datum/component/extradimensional_prefab_entrance, CALLBACK(src, PROC_REF(on_prefab_enter)))
	src.AddComponent(/datum/component/extradimensional_prefab_exit, CALLBACK(src, PROC_REF(on_prefab_exit)))

/obj/machinery/disposal/extradimensional/exit/on_flushed(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_EXTRADIMENSIONAL_PREFAB_EXIT, AM, src)

/obj/machinery/disposal/extradimensional/exit/proc/on_prefab_enter(atom/movable/AM)
	AM.set_loc(src)

/obj/machinery/disposal/extradimensional/exit/proc/on_prefab_exit(atom/movable/AM, atom/exit)
	if(!exit)
		var/list/potential_exits = list()
		for_by_tcl(chute, /obj/machinery/disposal)
			if(get_z(chute) == Z_LEVEL_STATION && istype(get_area(chute), /area/station))
				potential_exits |= chute
		exit = pick(potential_exits)
	if(!exit) //Enjoy your pocket dimension for eternity.
		src.go_out(AM)
		if(ismob(AM))
			boutput(AM, SPAN_ALERT("The chute couldn't find an exit, you're trapped inside forever..."))
		return
	AM.set_loc(exit)

/obj/machinery/disposal/extradimensional/exit/ex_act(severity)
	return
