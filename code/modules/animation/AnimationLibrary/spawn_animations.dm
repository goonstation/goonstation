ADD_TO_NAMESPACE(ANIMATE)(proc/spawn_animation1(atom/A))
	var/matrix/M = A.transform
	A.transform = A.transform.Scale(0.1)
	A.pixel_y = 300

	animate(A, time = 10, pixel_y = -16, alpha = 255, easing = QUAD_EASING, flags = ANIMATION_PARALLEL)

	animate(transform = A.transform.Scale(10,1), time = 2, easing = SINE_EASING)


	animate(transform = A.transform.Scale(1,10), time = 2, pixel_y = 0, easing = SINE_EASING)
	animate(transform = M)

ADD_TO_NAMESPACE(ANIMATE)(proc/leaving_animation(atom/A))
	animate(A, transform = A.transform.Scale(0.1, 1), time = 5, alpha = 255, easing = QUAD_EASING, flags = ANIMATION_PARALLEL)
	animate(time = 10, pixel_y = 512, easing = CUBIC_EASING)
	sleep(1.5 SECONDS)

ADD_TO_NAMESPACE(ANIMATE)(proc/heavenly_spawn(atom/movable/A, reverse = FALSE))
	var/obj/effects/heavenly_light/lightbeam = new /obj/effects/heavenly_light
	lightbeam.set_loc(A.loc)
	var/was_anchored = A.anchored
	var/oldlayer = A.layer
	var/old_canbegrabbed = null
	A.layer = EFFECTS_LAYER + 1
	A.anchored = ANCHORED
	if (!reverse)
		A.alpha = 0
		A.pixel_y = 176
	lightbeam.alpha = 0
	if (ismob(A))
		var/mob/M = A
		if (isliving(M))
			var/mob/living/living = M
			old_canbegrabbed = living.canbegrabbed
			living.canbegrabbed = FALSE
		APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, M.type)
	playsound(A.loc, 'sound/voice/heavenly3.ogg', 50,0)
	animate(lightbeam, alpha=255, time=45)
	animate(A,alpha=255,time=45)
	sleep(4.5 SECONDS)
	animate(A, pixel_y = reverse ? 176 : 0, time = 120, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	sleep(12 SECONDS)
	A.anchored = was_anchored
	A.layer = oldlayer
	animate(lightbeam,alpha = 0, time=15)
	if (reverse)
		animate(A,alpha=0,time=15)
	sleep(1.5 SECONDS)
	qdel(lightbeam)
	if (ismob(A))
		var/mob/M = A
		if (isliving(M))
			var/mob/living/living = M
			living.canbegrabbed = old_canbegrabbed
		REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, M.type)
	if (reverse)
		if (ismob(A))
			var/mob/M = A
			M.ghostize()
			M.set_loc(null)
			M.death()
		qdel(A)

/obj/effects/heavenly_light
	icon = 'icons/obj/large/32x192.dmi'
	icon_state = "heavenlight"
	layer = EFFECTS_LAYER
	blend_mode = BLEND_ADD

ADD_TO_NAMESPACE(ANIMATE)(proc/demonic_spawn(atom/movable/A, size = 1, play_sound = TRUE))
	if (!A) return
	var/was_anchored = A.anchored
	var/original_plane = A.plane
	var/original_density = A.density
	var/matrix/M1 = matrix()
	A.transform = M1.Scale(0,0)
	var/turf/center = get_turf(A)
	if (!center) return

	A.plane = PLANE_UNDERFLOOR
	A.anchored = ANCHORED
	A.density = FALSE
	if (ismob(A))
		var/mob/M = A
		APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, M.type)
	if (play_sound)
		playsound(center, 'sound/effects/darkspawn.ogg', 50,FALSE)
	SPAWN(5 SECONDS)
		var/turf/TA = locate(A.x - size, A.y - size, A.z)
		var/turf/TB = locate(A.x + size, A.y + size, A.z)
		if (!TA || !TB) return

		var/list/fake_hells = list()
		for (var/turf/T in block(TA, TB))
			fake_hells += new /obj/fake_hell(T)
			var/x_modifier = (T.x - center.x)
			var/y_modifier = (T.y - center.y)
			if (x_modifier || y_modifier)
				animate(T, pixel_x = ((32 * (x_modifier / max(1, abs(x_modifier)))) * (size - abs(x_modifier) + 1)), pixel_y = ((32 * (y_modifier / max(1, abs(y_modifier)))) * (size - abs(y_modifier) + 1)), 7.5 SECONDS, easing = SINE_EASING)
			else // center tile
				animate(T, transform = M1.Scale(0,0), 5 SECONDS, easing = SINE_EASING)
		sleep(7.5 SECONDS)
		animate(A, transform = null, time=20, easing = SINE_EASING)
		A.plane = original_plane
		A.anchored = was_anchored
		A.density = original_density
		if (ismob(A))
			var/mob/M = A
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, M.type)
		for (var/turf/T in block(TA, TB))
			animate(T, transform = null, pixel_x = 0, pixel_y = 0, 7.5 SECONDS, easing = SINE_EASING)
		sleep(7.5 SECONDS)
		for (var/obj/fake_hell/O in fake_hells)
			qdel(O)

/obj/fake_hell //for use with /proc/demonic_spawn
	name = "???"
	desc = "just standing next to it burns your very soul."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "lava_floor"
	anchored = ANCHORED
	plane = PLANE_UNDERFLOOR
	layer = -100

/obj/fake_hell/New()
	. = ..()
	src.icon_state = pick("lava_floor", "lava_floor_bubbling", "lava_floor_bubbling2")

/obj/fake_hell/Crossed(atom/movable/AM)
	. = ..()
	if (isliving(AM))
		var/mob/living/M = AM
		M.update_burning(10)

/obj/fake_hell/meteorhit()
	return

/obj/fake_hell/ex_act()
	return
