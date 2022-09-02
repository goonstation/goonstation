/datum/projectile/pie
	name = "pie"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "pie"
	power = 1
	dissipation_rate = 1
	dissipation_delay = 7
	ks_ratio = 0
	shot_number = 1
	shot_sound = 'sound/effects/throw.ogg'
	damage_type = D_SPECIAL

	on_hit(atom/hit, angle, var/obj/projectile/P)
		if (ismob(hit))
			var/mob/M = hit
			playsound(hit, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			M.change_eye_blurry(rand(5,10))
			M.take_eye_damage(rand(0, 2), 1)
