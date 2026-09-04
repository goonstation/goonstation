/datum/component/extradimensional_storage/shrink

/datum/component/extradimensional_storage/shrink/Initialize(width = 9, height = 9, region_init_proc = null)
	if (!istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.exit = get_turf(src.parent)
	. = ..()

	src.RegisterSignal(src.parent, COMSIG_ATTACKHAND, PROC_REF(on_entered))

/datum/component/extradimensional_storage/shrink/UnregisterFromParent()
	src.UnregisterSignal(src.parent, COMSIG_ATTACKHAND)
	. = ..()

/datum/component/extradimensional_storage/shrink/on_entered(atom/movable/thing, mob/user)
	if (user.loc == src.parent)
		return
	user.set_loc(src.parent)
	var/atom/movable/am_parent = src.parent
	am_parent.vis_contents += user
	animate(user, transform = matrix(user.transform, 0.1, 0.1, MATRIX_SCALE), time = 1 SECOND, easing = SINE_EASING)
	SPAWN(1 SECOND)
		am_parent.vis_contents -= user
		user.transform = matrix(user.transform, 10, 10, MATRIX_SCALE)
		user.set_loc(src.region.turf_at(rand(3, src.region.width - 2), rand(3, src.region.height - 2)))
