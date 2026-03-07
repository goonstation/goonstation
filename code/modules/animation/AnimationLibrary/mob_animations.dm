/mob
	var/obj/particle/attack/attack_particle = null
	var/obj/particle/attack/sprint/sprint_particle = null
	var/last_interact_particle = 0

/mob/New()
	..()
	src.attack_particle = new /obj/particle/attack //don't use pooling for these particles
	src.attack_particle.appearance_flags = TILE_BOUND | PIXEL_SCALE
	src.attack_particle.add_filter("attack blur", 1, gauss_blur_filter(size=0.2))
	src.attack_particle.add_filter("attack drop shadow", 2, drop_shadow_filter(x=1, y=-1, size=0.7))

	src.sprint_particle = new /obj/particle/attack/sprint //don't use pooling for these particles

/mob/disposing()
	QDEL_NULL(src.attack_particle)
	QDEL_NULL(src.sprint_particle)
	. = ..()


/obj/particle/attack/sprint
	icon = 'icons/mob/mob.dmi'
	icon_state = "sprint_cloud"
	layer = MOB_LAYER_BASE - 0.1
	appearance_flags = TILE_BOUND | PIXEL_SCALE

/obj/particle/attack/muzzleflash
	icon = 'icons/mob/mob.dmi'
	alpha = 255
	plane = PLANE_OVERLAY_EFFECTS
	appearance_flags = TILE_BOUND | PIXEL_SCALE

/obj/particle/attack/bot_hit
	icon = 'icons/mob/mob.dmi'





/**
 *	Mob-specific animations.
 */
CREATE_NAMESPACE(ANIMATE, MOB)


ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/attack_particle(mob/M, atom/target))
	if (!M || !target || !M.attack_particle) return
	if(istype(M, /mob/dead))
		return
	var/diff_x = target.x - M.x
	var/diff_y = target.y - M.y

	M.attack_particle.invisibility = M.invisibility

	if (target) //I want these to be recent, but sometimes they can be deleted during course of a spawn
		diff_x = target.x - M.x
		diff_y = target.y - M.y

	M.last_interact_particle = world.time

	var/obj/item/I = M.equipped()
	if (I && !isgrab(I))
		M.attack_particle.icon = I.icon
		M.attack_particle.icon_state = I.icon_state
	else
		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "[M.a_intent]"

	M.attack_particle.alpha = 180
	M.attack_particle.loc = M.loc
	M.attack_particle.pixel_x = 0
	M.attack_particle.pixel_y = 0

	var/matrix/start = matrix()
	start.Scale(0.3,0.3)
	start.Turn(rand(-80,80))
	M.attack_particle.transform = start
	var/matrix/t_size = matrix()

	//animate(M.attack_particle, alpha = 200, time = 1, easing = SINE_EASING)

	//animate(M.attack_particle, pixel_x = diff_x*32, pixel_y = diff_y*32, time = 2, easing = CUBIC_EASING)
	//animate(transform = t_size, time = 6, easing = BOUNCE_EASING,  flags = ANIMATION_PARALLEL)

	animate(M.attack_particle, transform = t_size, time = 6, easing = BOUNCE_EASING)
	animate(pixel_x = diff_x*32, pixel_y = diff_y*32, time = 2, easing = BOUNCE_EASING,  flags = ANIMATION_PARALLEL)
	SPAWN(0.5 SECONDS)
		//animate(M.attack_particle, alpha = 0, time = 2, flags = ANIMATION_PARALLEL)
		M.attack_particle?.alpha = 0

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/interact_particle(mob/M, atom/target))
	if(istype(M, /mob/dead))
		return
	if (!M || !target) return
	if (world.time <= M.last_interact_particle + M.combat_click_delay) return
	var/diff_x = target.x - M.x
	var/diff_y = target.y - M.y
	SPAWN(0)
		if (!M || !M.attack_particle) //ZeWaka: Fix for Cannot modify null.icon.
			return

		M.attack_particle.invisibility = M.invisibility

		if (target) //I want these to be recent, but sometimes they can be deleted during course of a spawn
			diff_x = target.x - M.x
			diff_y = target.y - M.y

		M.last_interact_particle = world.time

		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "interact"

		M.attack_particle.alpha = 180
		M.attack_particle.loc = M.loc
		M.attack_particle.pixel_x = 0
		M.attack_particle.pixel_y = 0

		var/matrix/start = matrix()
		start.Scale(0.3,0.3)
		start.Turn(rand(-80,80))
		M.attack_particle.transform = start
		var/matrix/t_size = matrix()

		//animate(M.attack_particle, alpha = 200, time = 1, easing = SINE_EASING)

		//animate(M.attack_particle, pixel_x = diff_x*32, pixel_y = diff_y*32, time = 2, easing = CUBIC_EASING)
		//animate(transform = t_size, time = 6, easing = BOUNCE_EASING,  flags = ANIMATION_PARALLEL)

		animate(M.attack_particle, transform = t_size, time = 6, easing = BOUNCE_EASING)
		animate(pixel_x = (diff_x*32) + target.pixel_x, pixel_y = (diff_y*32)  + target.pixel_y, time = 2, easing = BOUNCE_EASING,  flags = ANIMATION_PARALLEL)
		sleep(0.5 SECONDS)
		//animate(M.attack_particle, alpha = 0, time = 2, flags = ANIMATION_PARALLEL)
		M.attack_particle.alpha = 0

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/pickup_particle(mob/M, atom/target))
	if (!ismob(M) || !M.attack_particle || !target)
		return

	var/diff_x = target.x - M.x
	var/diff_y = target.y - M.y

	var/obj/item/I = target
	if (I && !isgrab(I))
		M.attack_particle.icon = I.icon
		M.attack_particle.icon_state = I.icon_state
	else
		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "[M.a_intent]"

	M.attack_particle.alpha = 200
	M.attack_particle.loc = M.loc
	M.attack_particle.pixel_x = I.pixel_x + (diff_x*32)
	M.attack_particle.pixel_y = I.pixel_y + (diff_y*32)

	var/matrix/start = matrix()//(I.transform)
	M.attack_particle.transform = start
	var/matrix/t_size = matrix()
	t_size.Scale(0.3,0.3)
	t_size.Turn(rand(-40,40))

	animate(M.attack_particle, pixel_x = M.get_hand_pixel_x(), pixel_y = M.get_hand_pixel_y(), time = 1, easing = LINEAR_EASING)
	animate(transform = t_size, time = 1, easing = LINEAR_EASING,  flags = ANIMATION_PARALLEL)
	animate(alpha = 0, time = 1)

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/pull_particle(mob/M, atom/target))
	if (!M || !target) return
	if (world.time <= M.last_interact_particle + M.combat_click_delay) return

	var/diff_x = target.x
	var/diff_y = target.y
	SPAWN(0)
		if (target && M) //I want these to be recent, but sometimes they can be deleted during course of a spawn
			diff_x = diff_x - M.x
			diff_y = diff_y - M.y

		M.last_interact_particle = world.time

		if (!M || !M.attack_particle) //ZeWaka: Fix for Cannot modify null.icon.
			return

		var/atom/I = target

		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "pull"

		M.attack_particle.alpha = 200
		M.attack_particle.loc = M.loc
		M.attack_particle.pixel_x = I.pixel_x + (diff_x*32)
		M.attack_particle.pixel_y = I.pixel_y + (diff_y*32)

		var/matrix/start = matrix()//(I.transform)
		M.attack_particle.transform = start
		var/matrix/t_size = matrix()
		t_size.Scale(0.3,0.3)
		t_size.Turn(rand(-40,40))

		animate(M.attack_particle, pixel_x = M.get_hand_pixel_x(), pixel_y = M.get_hand_pixel_y(), time = 2, easing = LINEAR_EASING)
		sleep(0.5 SECONDS)
		M.attack_particle.alpha = 0

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/unpull_particle(mob/M, atom/target))
	if (!M || !target) return
	if (world.time <= M.last_interact_particle + M.combat_click_delay) return

	var/diff_x = target.x
	var/diff_y = target.y
	SPAWN(0)
		if (target && M) //I want these to be recent, but sometimes they can be deleted during course of a spawn
			diff_x = diff_x - M.x
			diff_y = diff_y - M.y

		M.last_interact_particle = world.time

		if (!M || !M.attack_particle) //ZeWaka: Fix for Cannot modify null.icon.
			return

		var/atom/I = target

		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "unpull"

		M.attack_particle.alpha = 200
		M.attack_particle.loc = M.loc
		M.attack_particle.pixel_x = M.get_hand_pixel_x()
		M.attack_particle.pixel_y = M.get_hand_pixel_y()

		var/matrix/start = matrix()//(I.transform)
		M.attack_particle.transform = start
		var/matrix/t_size = matrix()
		t_size.Scale(0.3,0.3)
		t_size.Turn(rand(-40,40))

		animate(M.attack_particle, pixel_x = I.pixel_x + (diff_x*32), pixel_y = I.pixel_y + (diff_y*32), time = 2, easing = LINEAR_EASING)
		sleep(0.5 SECONDS)
		M.attack_particle.alpha = 0

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/block_begin(mob/M))
	if (!M || !M.attack_particle) return

	M.attack_particle.invisibility = M.invisibility
	M.last_interact_particle = world.time

	M.attack_particle.icon = 'icons/mob/mob.dmi'
	M.attack_particle.icon_state = "block"

	M.attack_particle.alpha = 255
	M.attack_particle.loc = M.loc
	M.attack_particle.pixel_x = 0
	M.attack_particle.pixel_y = 0

	var/matrix/start = matrix()
	start.Scale(0.3,0.3)
	start.Turn(rand(-45,45))
	M.attack_particle.transform = start
	var/matrix/t_size = matrix()

	animate(M.attack_particle, transform = t_size, time = 2, easing = BOUNCE_EASING)
	SPAWN(0.5 SECONDS)
		M.attack_particle.alpha = 0

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/block_spark(mob/M, armor = 0))
	if (!M || !M.attack_particle) return
	var/state_string = ""
	if(armor)
		state_string = "block_spark_armor"
	else
		state_string = "block_spark"

	M.attack_particle.invisibility = M.invisibility
	M.last_interact_particle = world.time

	M.attack_particle.icon = 'icons/mob/mob.dmi'
	if (M.attack_particle.icon_state == state_string)
		FLICK(state_string,M.attack_particle)
	M.attack_particle.icon_state = state_string

	M.attack_particle.alpha = 255
	M.attack_particle.loc = M.loc
	M.attack_particle.pixel_x = 0
	M.attack_particle.pixel_y = 0

	M.attack_particle.transform.Turn(rand(0,360))

	SPAWN(1 SECOND)
		M.attack_particle?.alpha = 0

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/fuckup_attack_particle(mob/M))
	SPAWN(0.1 SECONDS)
		if (!M || !M.attack_particle) return
		var/r = rand(0,360)
		var/x = cos(r)
		var/y = sin(r)
		x *= 22
		y *= 22
		animate(M.attack_particle, pixel_x = M.attack_particle.pixel_x + x , pixel_y = M.attack_particle.pixel_y + y, time = 5, easing = BOUNCE_EASING, flags = ANIMATION_END_NOW)

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/sprint_particle(mob/M, turf/T))
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.set_dir(null)
	if (M.sprint_particle.icon_state == "sprint_cloud")
		FLICK("sprint_cloud",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud"

	SPAWN(0.6 SECONDS)
		if (M.sprint_particle?.loc == T)
			M.sprint_particle.loc = null

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/sprint_particle_small(mob/M, turf/T, direct))
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.set_dir(direct)
	if (M.sprint_particle.icon_state == "sprint_cloud_small")
		FLICK("sprint_cloud_small",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud_small"

	SPAWN(0.4 SECONDS)
		if (M.sprint_particle?.loc == T)
			M.sprint_particle.loc = null

ADD_TO_NAMESPACE(ANIMATE, MOB)(proc/sprint_particle_tiny(mob/M, turf/T, direct))
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.set_dir(direct)
	if (M.sprint_particle.icon_state == "sprint_cloud_tiny")
		FLICK("sprint_cloud_tiny",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud_tiny"

	SPAWN(0.3 SECONDS)
		if (M.sprint_particle?.loc == T)
			M.sprint_particle.loc = null
