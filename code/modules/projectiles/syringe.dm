/datum/projectile/syringe
	name = "syringe"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "syringeproj"
	power = 1
	cost = 15
	dissipation_rate = 1
	dissipation_delay = 7
	power = 1
	ks_ratio = 1.0
	hit_ground_chance = 10
	shot_sound = 'sound/effects/syringeproj.ogg'
	shot_number = 1

	on_hit(atom/hit, angle, var/obj/projectile/P)
		if (ismob(hit))
			if (P.reagents && hit.reagents)
				P.reagents.trans_to(hit, src.cost)
				P.reagents.clear_reagents()
