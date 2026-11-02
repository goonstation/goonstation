/datum/targetable/ai/module/flash
	name = "Camera Flash"
	desc = "Supercharge the camera light to produce a flash like effect."
	targeted = TRUE
	target_anything = TRUE
	icon_state = "flash"
	var/flash_range = 5
	var/turboflash
	cooldown = 15 SECONDS

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/camera/C
		var/turf/T = get_turf(target)
		var/range = flash_range
		var/dist
		for(var/obj/machinery/camera/cam in T.cameras)
			dist = GET_DIST(cam, target)
			if(dist <= range)
				C = cam

		if(C)
			logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] activates AI [src.name], targeting [log_loc(target)].")
			playsound(C, 'sound/weapons/flash.ogg', 100, TRUE)
			C.visible_message("[C] emits a sudden flash.")
			for (var/atom/A in oviewers((flash_range), get_turf(C)))
				var/mob/living/M
				if (istype(A, /obj/vehicle))
					var/obj/vehicle/V = A
					if (V.rider && V.rider_visible)
						M = V.rider
				else if (ismob(A))
					M = A
				if (M)
					if (src.turboflash)
						M.apply_flash(35, 0, 0, 25)
					else
						dist = clamp(dist,1,4)
						M.apply_flash(20, knockdown = 2, uncloak_prob = 100, stamina_damage = (35 / dist), disorient_time = 3)
		else
			boutput(holder.owner, "Target is outside of camera range!")
