// ABSTRACT_TYPE(/obj/machinery/disposal/extradimensional)
// Curse you SpacemanDMM, if you make this type I will laugh at you because it will do nothing, use the /host one.
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
	if(severity == 1)
		src.set_broken()
	else
		. = ..()


// ------------ ENTRANCE ------------ //
/obj/machinery/disposal/extradimensional/host
	var/prefab_path = /datum/mapPrefab/allocated/syndicate_hideout
	var/datum/component/extradimensional_storage/dimension_component

/obj/machinery/disposal/extradimensional/host/New()
	. = ..()
	src.dimension_component = src.AddComponent(/datum/component/extradimensional_storage/prefab, src.prefab_path)
	dimension_component.exit = src

/obj/machinery/disposal/extradimensional/host/disposing()
	//Oh no, time to collapse the pocket dimension!
	var/turf/my_turf = get_turf(src)
	for(var/atom/movable/AM in REGION_TILES(src.dimension_component.region))
		if((AM.anchored && !length(get_all_mobs_in(AM))) || IS_OVERLAY_OR_EFFECT(AM))
			continue
		var/target_turf = get_offset_target_turf(my_turf, rand(-7, 7), rand(-7, 7))
		AM.set_loc(my_turf)
		var/was_anchored = AM.anchored
		AM.anchored = FALSE
		AM.throw_at(target_turf, 5, 1, throw_type = THROW_PHASE)
		AM.anchored = was_anchored
	src.visible_message(SPAN_ALERT("<b>[src]'s pocket dimension collapses!</b>"))
	playsound(my_turf, 'sound/machines/singulo_start.ogg', 90, FALSE, 5, -1)
	. = ..()

/obj/machinery/disposal/extradimensional/host/on_flushed(atom/movable/AM)
	src.dimension_component.on_entered(AM)

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
	if(!exit || QDELETED(exit))
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

// ------------ CONVERTER ------------ //
/obj/item/device/disposals_hijacker
	name = "disposals hijacker"
	desc = "A highly experimental piece of syndicate tech capable of manifesting an entire pocket dimension inside of a disposals unit."
	icon_state = "disposals_hijacker"
	var/datum/weakref/dimension_host //The "/obj/machinery/disposal/extradimensional/host" this hijacker made

	pickup(mob/user)
		. = ..()
		if (src.dimension_host?.deref())
			user.AddComponent(/datum/component/tracker_hud, src.dimension_host.deref(), "#b22c20")

	dropped(mob/user)
		. = ..()
		var/datum/component/tracker_hud/arrow = user.GetComponent(/datum/component/tracker_hud)
		arrow?.RemoveComponent()

	afterattack(atom/target, mob/user)
		if(!istype(target, /obj/machinery/disposal))
			return ..()
		if(src.dimension_host?.deref())
			boutput(user, SPAN_ALERT("[src] can only maintain one pocket dimension at a time!"))
			return
		var/obj/machinery/disposal/target_chute = target
		if(istype(target, /obj/machinery/disposal/extradimensional))
			boutput(user, SPAN_ALERT("[src] detects existing dimensional energies in the target chute, and refuses to install a pocket dimension."))
			return
		playsound(src, 'sound/weapons/rev_flash_startup.ogg', 30, TRUE, 0, 0.6)
		actions.start(new/datum/action/bar/icon/disposals_hijack(src,target_chute), user)

	proc/replace_chute(var/obj/machinery/disposal/target_chute, var/mob/user)
		var/obj/machinery/disposal/extradimensional/host/new_chute = new(src)
		new_chute.appearance = target_chute.appearance
		new_chute.dir = target_chute.dir
		new_chute.icon_style = target_chute.icon_style
		new_chute.light_style = target_chute.light_style
		new_chute.density = target_chute.density
		src.dimension_host = get_weakref(new_chute)
		new_chute.set_loc(target_chute.loc)
		for(var/atom/movable/AM in target_chute)
			AM.set_loc(new_chute)
		qdel(target_chute)
		user.AddComponent(/datum/component/tracker_hud, new_chute, "#b22c20")

/datum/action/bar/icon/disposals_hijack
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE  | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ACTION
	var/obj/machinery/disposal/chute
	var/obj/item/device/disposals_hijacker/hijacker

	New(hijacker, chute)
		src.hijacker = hijacker
		src.chute = chute
		src.icon = src.hijacker.icon
		src.icon_state = src.hijacker.icon_state
		..()

	onUpdate()
		..()
		var/mob/mob_owner = src.owner
		if(BOUNDS_DIST(mob_owner, src.chute) > 0 || src.chute == null || mob_owner == null || mob_owner.equipped() != src.hijacker)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/mob/mob_owner = src.owner
		if(BOUNDS_DIST(mob_owner, src.chute) > 0 || src.chute == null || mob_owner == null || mob_owner.equipped() != src.hijacker)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		var/mob/mob_owner = src.owner
		if(src.owner && istype(src.chute) && mob_owner.equipped() == src.hijacker)
			src.hijacker.replace_chute(src.chute, src.owner)
