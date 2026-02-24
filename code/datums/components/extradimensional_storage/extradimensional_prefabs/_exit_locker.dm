/obj/storage/closet/extradimensional_exit
	anchored = ANCHORED

/obj/storage/closet/extradimensional_exit/New()
	. = ..()

	src.RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(enter_locker))
	src.AddComponent(/datum/component/extradimensional_prefab_entrance, CALLBACK(src, PROC_REF(on_prefab_enter)))
	src.AddComponent(/datum/component/extradimensional_prefab_exit, CALLBACK(src, PROC_REF(on_prefab_exit)))

/obj/storage/closet/extradimensional_exit/proc/enter_locker(_, atom/movable/AM, turf/old_loc)
	SEND_SIGNAL(src, COMSIG_EXTRADIMENSIONAL_PREFAB_EXIT, AM, old_loc)

/obj/storage/closet/extradimensional_exit/proc/on_prefab_enter(atom/movable/AM)
	AM.set_loc(src)

/obj/storage/closet/extradimensional_exit/proc/on_prefab_exit(atom/movable/AM, atom/exit)
	AM.set_loc(exit)
