/datum/targetable/ai/module/camera_gun
	name = "Camera Lasers"
	desc = "Makes nearby cameras shoot lasers at the target. Somehow."
	targeted = TRUE
	target_anything = 1
	var/datum/projectile/P
	var/projectile_cd = 10 SECONDS
	var/charge_color = rgb(255,0,0)
	var/charge_time = 1.5 SECONDS

	onAttach(datum/abilityHolder/H)
		. = ..()
		var/datum/abilityHolder/silicon/ai/AIH = H
		if(istype(AIH))
			AIH.active_camera_gun = src

	cast(atom/target)
		if (..())
			return 1

		if(ispath(P))
			P = new P()

		var/camera_on_cd = FALSE
		var/turf/T = get_turf(target)

		var/obj/projectile/test_projectile = new
		test_projectile.proj_data = P

		for(var/obj/machinery/camera/cam in T.cameras)
			if(!isturf(cam.loc))
				continue

			if(istype(cam, /mob/living/silicon/hivebot/eyebot))
				if (issilicon(cam))
					var/mob/living/silicon/S = cam
					if(S?.cell.charge < P.cost)
						continue
			else if (istype(cam, /obj/machinery/camera/television))
				continue // no mobile camera turrets, please

			if(!can_shoot_to(cam, T, test_projectile, max_length=15))
				continue

			if(!ON_COOLDOWN(cam,"[src.type]", src.projectile_cd))
				cam.add_filter("charge_outline", 0, outline_filter(size=0, color=charge_color))
				animate(cam.get_filter("charge_outline"), size=0.5, time=charge_time)
				SPAWN(charge_time)
					logTheThing(LOG_COMBAT, holder.owner, "[key_name(holder.owner)] fires a camera projectile [src.name], targeting [key_name(target)] [log_loc(target)].")
					shoot_projectile_ST_pixel_spread(cam, P, target)
					if(P.cost > 1)
						if (issilicon(cam))
							var/mob/living/silicon/S = cam
							if (S.cell)
								S.cell.use(P.cost)
						else
							cam.use_power(P.cost / CELLRATE)
					cam.remove_filter("charge_outline")
				return
			else
				camera_on_cd = TRUE

		if(camera_on_cd)
			boutput(holder.owner, SPAN_ALERT("Available camera is still cooling down..."))
		else
			boutput(holder.owner, SPAN_ALERT("Unable to calculate valid shot from available camera."))
		return 1

/datum/targetable/ai/module/camera_gun/taser
	name = "Camera Taser"
	icon_state = "camera_taser"
	P = /datum/projectile/energy_bolt
	charge_color = rgb(217, 255, 0)

/datum/targetable/ai/module/camera_gun/laser
	name = "Camera Laser"
	icon_state = "camera_laser"
	P = /datum/projectile/laser/light/tracer

