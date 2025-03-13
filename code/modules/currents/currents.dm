//slightly cursed path because we just want the "immune to everything" quality
/obj/effects/current
	icon = 'icons/effects/effects.dmi'
	icon_state = "barrier"

	Crossed(atom/movable/AM)
		..()
		if (HAS_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH) || (AM.event_handler_flags & IMMUNE_OCEAN_PUSH))
			return
		APPLY_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH, src, src.dir)

	Uncrossed(atom/movable/AM)
		..()
		REMOVE_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH, src)

/obj/landmark/current_spawner
	name = "current spawner"
	icon = 'icons/effects/effects.dmi'
	icon_state = "barrier"
	add_to_landmarks = FALSE

	init(delay_qdel = FALSE)
		var/turf/T = get_turf(src)
		while(istype(T, /turf/space/fluid))
			var/obj/effects/current/new_current = new(T)
			new_current.dir = src.dir
			T = get_step(T, src.dir)
		..()

