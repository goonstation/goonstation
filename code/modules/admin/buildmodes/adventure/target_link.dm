/obj/adventurepuzzle/invisible/target_link

	var/triggerable_id = null
	var/obj/adventurepuzzle/triggerable/targetable/trap

	New()
		..()
		START_TRACKING
		SPAWN(1 DECI SECOND)
			src.target_me()

	disposing()
		STOP_TRACKING
		..()

	proc/target_me()
		for_by_tcl(target, /obj/adventurepuzzle/triggerable/targetable)
			if(target.id == src.triggerable_id)
				src.trap = target
		src.trap?.setTarget(src)
