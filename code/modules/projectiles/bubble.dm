/datum/projectile/special/bubble
	name = "bubble"
	sname = "bubble"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bubble"
	cost = 1
	damage = 0
	dissipation_delay = 50
	shot_sound = 'sound/effects/zzzt.ogg'
	projectile_speed = 5

	on_pre_hit(atom/hit, angle, obj/projectile/O)
		if (O.was_pointblank)
			O.die()
			return TRUE
		if (ismob(hit))
			if (!length(O.contents))
				var/mob/M = hit
				M.set_loc(O)
				O.vis_contents += M
			return TRUE
		. = ..()

	on_end(obj/projectile/O)
		. = ..()
		playsound(O, 'sound/misc/bubble_pop.ogg', 100, 1)
		var/turf/T = get_turf(O)
		for (var/atom/movable/AM as anything in O.contents)
			AM.set_loc(T)

/datum/projectile/special/bubble/bomb
	name = "bubble bomb"
	sname = "bubble bomb"
	icon_state = "bubble_bomb"
	var/explosion_power = 5
	var/turf_safe_explosion = FALSE

	on_end(obj/projectile/O)
		. = ..()
		explosion_new(O, get_turf(O), explosion_power, 1, turf_safe = src.turf_safe_explosion)

/datum/projectile/special/bubble/bomb/turf_safe
	turf_safe_explosion = TRUE
