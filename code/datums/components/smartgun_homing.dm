/datum/component/holdertargeting/smartgun/homing/shoot_tracked_targets(mob/user)
	if(shooting)
		return
	shooting = TRUE
	var/obj/item/gun/G = parent
	var/list/local_targets = tracked_targets.Copy()
	SPAWN(0)
		if(length(local_targets))
			G.suppress_fire_msg = TRUE
			for(var/atom/A as anything in local_targets)
				for(var/i in 1 to local_targets[A])
					if (istype(G.current_projectile, /datum/projectile/bullet/homing))
						var/datum/projectile/bullet/homing/homing_projectile = G.current_projectile
						homing_projectile.targets = list()
						homing_projectile.targets.Add(A)
					G.shoot(mouse_target, get_turf(user), user)
					sleep(G.current_projectile.shot_delay)

			G.suppress_fire_msg = initial(G.suppress_fire_msg)
		else
			if(!ON_COOLDOWN(G, "shoot_delay", G.shoot_delay))
				if (istype(G.current_projectile, /datum/projectile/bullet/homing))
					var/datum/projectile/bullet/homing/homing_projectile = G.current_projectile
					homing_projectile.targets = list()
				G.shoot(mouse_target, get_turf(user), user)
		shooting = 0

	tracked_targets = list()
	shotcount = 0
	if(aimer)
		for(var/atom/A as anything in targeting_images)
			aimer.images -= targeting_images[A]
			targeting_images -= A

// Pod targeting varient.
/datum/component/holdertargeting/smartgun/homing/pod
	type_to_target = /obj

/datum/component/holdertargeting/smartgun/homing/pod/is_valid_target(mob/user, atom/A)
	return ((istype(A, /obj/critter/gunbot/drone) || istype(A, /obj/machinery/vehicle/miniputt) || istype(A, /obj/machinery/vehicle/pod_smooth)) && !A.invisibility)

/datum/component/holdertargeting/smartgun/homing/pod/track_targets(mob/user)
	set waitfor = 0
	if(shooting || tracking)
		return
	tracking = 1
	shotcount = 0
	while(!stopping)
		if(!shooting)
			for(var/atom/A as anything in range(2, mouse_target))
				if (!istype(A, type_to_target) || !src.is_valid_target(user, A) || tracked_targets[A] >= src.maxlocks)
					continue

				if(shotcount < src.checkshots(parent, user))
					tracked_targets[A] += 1
					shotcount++
					src.update_targeting_images(A)
					continue

				var/farthest_target = get_farthest_tracked_target_from_cursor(user)
				if (farthest_target && (GET_DIST(mouse_target, A) < GET_DIST(mouse_target, farthest_target)))
					tracked_targets[farthest_target]--
					src.update_targeting_images(farthest_target)
					if(tracked_targets[farthest_target] <= 0)
						tracked_targets -= farthest_target

					tracked_targets[A] += 1
					src.update_targeting_images(A)

		sleep(0.6 SECONDS)

	stopping = 0
	tracking = 0

/datum/component/holdertargeting/smartgun/homing/pod/update_targeting_images(atom/A)
	if(!src.aimer)
		return
	if(tracked_targets[A] > 0)
		if(!targeting_images[A])
			var/icon/icon = icon(A.icon)
			var/image/targeting_image
			if (icon.Height() <= 32)
				targeting_image = image(icon('icons/effects/128x128.dmi', "reticle_small"), A, pixel_x = -48, pixel_y = -48)
			else if (icon.Height() <= 64)
				targeting_image = image(icon('icons/effects/128x128.dmi', "reticle_medium"), A, pixel_x = -32, pixel_y = -32)
			else if (icon.Height() <= 96)
				targeting_image = image(icon('icons/effects/128x128.dmi', "reticle_large"), A, pixel_x = -16, pixel_y = -16)
			targeting_images[A] = targeting_image
			aimer.images += targeting_images[A]
	else
		aimer.images -= targeting_images[A]
		targeting_images -= A

/datum/component/holdertargeting/smartgun/homing/pod/proc/get_farthest_tracked_target_from_cursor(mob/user)
	var/farthest_target_from_cursor
	for(var/atom/A as anything in tracked_targets)
		if (!farthest_target_from_cursor)
			farthest_target_from_cursor = A
		if (GET_DIST(mouse_target, farthest_target_from_cursor) < GET_DIST(mouse_target, A))
			farthest_target_from_cursor = A

	return farthest_target_from_cursor
