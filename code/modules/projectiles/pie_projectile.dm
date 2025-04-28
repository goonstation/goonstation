/datum/projectile/pie
	name = "pie"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "pie"
	stun = 1
	dissipation_rate = 1
	dissipation_delay = 7
	default_firemode = /datum/firemode/single
	shot_sound = 'sound/effects/throw.ogg'
	damage_type = D_SPECIAL

	on_hit(atom/hit, angle, var/obj/projectile/P)
		if (ismob(hit))
			var/mob/M = hit
			playsound(hit, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, TRUE)
			M.change_eye_blurry(rand(5,10))
			M.take_eye_damage(rand(0, 2), 1)
