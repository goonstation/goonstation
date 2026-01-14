ADD_TO_NAMESPACE(ANIMATE)(proc/portal_appear(atom/A))
	var/matrix/M = matrix(A.transform)
	A.transform = A.transform.Scale(0.6, 0.05)
	animate(A, transform = M, time = 30, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/portal_tele(atom/A))
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(0.95, 0.7), time = 1, easing = EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(transform = M, time = 10, easing = ELASTIC_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/teleport(atom/A))
	if (!istype(A))
		return
	var/matrix/original = matrix(A.transform)
	var/matrix/M = A.transform.Scale(1, 3)
	animate(A, transform = M, pixel_y = 32, time = 10, alpha = 50, easing = CIRCULAR_EASING, flags=ANIMATION_PARALLEL)
	M.Scale(0,4)
	animate(transform = M, time = 5, color = "#1111ff", alpha = 0, easing = CIRCULAR_EASING)
	animate(transform = original, time = 5, color = "#ffffff", alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/teleport_wiz(atom/A))
	if (!istype(A))
		return
	var/matrix/original = matrix(A.transform)
	var/matrix/M = A.transform.Scale(0, 4)
	animate(A, color = "#ddddff", time = 20, alpha = 70, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
	animate(transform = M, pixel_y = 32, time = 20, color = "#2222ff", alpha = 0, easing = CIRCULAR_EASING)
	animate(time = 8, transform = M, alpha = 5) //Do nothing, essentially
	animate(transform = original, time = 5, color = "#ffffff", alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/showswirl(atom/target, play_sound = TRUE))
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl
	swirl.set_loc(target_turf)
	swirl.pixel_y = 10
	if (play_sound)
		playsound(target_turf, 'sound/effects/teleport.ogg', 50, TRUE)
	SPAWN(1.5 SECONDS)
		if (swirl)
			swirl.pixel_y = 0
			qdel(swirl)

ADD_TO_NAMESPACE(ANIMATE)(proc/showswirl_out(atom/target, play_sound = TRUE))
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/teleport_swirl/swirl/ = new /obj/decal/teleport_swirl/out
	swirl.set_loc(target_turf)
	swirl.pixel_y = 10
	if (play_sound)
		playsound(target_turf, 'sound/effects/teleport.ogg', 50, TRUE)
	SPAWN(1.5 SECONDS)
		if (swirl)
			swirl.pixel_y = 0
			qdel(swirl)

ADD_TO_NAMESPACE(ANIMATE)(proc/showswirl_error(atom/target, play_sound = TRUE))
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/teleport_swirl/swirl/ = new /obj/decal/teleport_swirl/error
	swirl.set_loc(target_turf)
	swirl.pixel_y = 10
	if (play_sound)
		playsound(target_turf, 'sound/effects/teleport.ogg', 50, TRUE)
	SPAWN(1.5 SECONDS)
		if (swirl)
			swirl.pixel_y = 0
			qdel(swirl)

ADD_TO_NAMESPACE(ANIMATE)(proc/leaveresidual(atom/target))
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	if (locate(/obj/decal/residual_energy) in target_turf)
		return
	var/obj/decal/residual_energy/e = new /obj/decal/residual_energy
	e.set_loc(target_turf)
	SPAWN(10 SECONDS)
		if (e)
			qdel(e)

ADD_TO_NAMESPACE(ANIMATE)(proc/shrink_teleport(atom/teleporter))
	var/matrix/M = teleporter.transform
	animate(teleporter, transform = teleporter.transform.Scale(0.1), pixel_y = 6, time = 4, alpha = 255, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	sleep(0.2 SECONDS)
	animate(teleporter, transform = M, time = 9, alpha = 255, pixel_y = 0, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)
	//HAXXX sorry - kyle
	if (istype(teleporter, /mob/dead/observer))
		SPAWN(1 SECOND)
			ANIMATE.bumble(teleporter)
