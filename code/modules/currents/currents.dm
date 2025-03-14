//TODO: SPRITES

//slightly cursed path because we just want the "immune to everything" quality
/obj/effects/current
	icon = 'icons/effects/effects.dmi'
	icon_state = "barrier"
	var/datum/force_push_controller/ocean/controller = null

	Crossed(atom/movable/AM)
		..()
		if (HAS_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH) || (AM.event_handler_flags & IMMUNE_OCEAN_PUSH))
			return
		APPLY_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH, src)
		src.controller.addAtom(AM, dir)

	Uncrossed(atom/movable/AM)
		..()
		REMOVE_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH, src)
		src.controller.removeAtom(AM, dir)

/obj/landmark/current_spawner
	name = "current spawner"
	icon = 'icons/effects/effects.dmi'
	icon_state = "barrier"
	add_to_landmarks = TRUE
	deleted_on_start = FALSE
	var/interval = 10

	init(delay_qdel = FALSE)
		if (!global.processScheduler) //wait to be set up later
			return ..()
		var/datum/controller/process/fMove/fmove_controller = global.processScheduler.getProcess("Forced movement")
		src.set_up(fmove_controller)
		..()

	proc/set_up(datum/controller/process/fMove/fmove_controller)
		var/datum/force_push_controller/ocean/current_controller = fmove_controller.requestCurrentController()
		current_controller.interval = src.interval
		var/turf/T = get_turf(src)
		while(istype(T, /turf/space/fluid))
			var/obj/effects/current/new_current = new(T)
			new_current.dir = src.dir
			new_current.controller = current_controller
			T = get_step(T, src.dir)


