/datum/projectile/claw

	name = "crab claw"
	icon = 'icons/obj/crabgun.dmi'
	icon_state = "proj_crab"

	stun = 50
	cost = 30
	dissipation_rate = 1
	dissipation_delay = 20
	sname = "claw"
	shot_sound = 'sound/items/wirecutter.ogg'
	shot_number = 1
	hit_ground_chance = 20
	window_pass = 0
	damage_type = D_ENERGY
	tick(var/obj/projectile/P)
		var/turf/T = get_turf(P)
		if (istype(T,/turf/simulated/floor))
			T.icon = 'icons/misc/beach.dmi'
			T.icon_state = "sand"
			animate(T, time = 10 SECONDS)
			animate(icon_state = initial(T.icon_state))
			animate(icon = initial(T.icon))
	on_hit(atom/hit)
		..()
		var/turf/simulated/T2 = get_turf(hit)
		if (isturf(T2))
			T2.icon = 'icons/misc/beach.dmi'
			T2.icon_state = "sand"
			animate(T2, time = 10 SECONDS)
			animate(icon_state = initial(T2.icon_state))
			animate(icon = initial(T2.icon))
		if (istype(hit, /mob/living/carbon/))
			if (hit.getStatusDuration("stunned") > 0)
				var/mob/living/carbon/human/H = hit


				if (check_target_immunity( H ))
					H.visible_message("<span class='alert'>[H] is already cold blooded enough!</span>")
					return 1

				if (H.mind && (H.mind.assigned_role != "Animal") || (!H.mind || !H.client))
					boutput(H, "<span class='alert'><B>Oh 🦀SNAP🦀!</B></span>")
					if (H.mind)
						H.mind.assigned_role = "Animal"
				H.emote("scream", 0)
				var/atom/movable/overlay/gibs/animation = null
				animation = new(hit.loc)
				animation.master = hit
				flick("implode", animation)

				H.unequip_all()
				logTheThing(LOG_COMBAT, H, "is transformed into a crab by the crab gun at [log_loc(H)].")
				var/mob/living/critter/C = H.make_critter(/mob/living/critter/small_animal/crab)
				if (istype(C))

					playsound(T2, 'sound/effects/splort.ogg', 50, 1)
					C.change_misstep_chance(30)
					C.stuttering = 40
