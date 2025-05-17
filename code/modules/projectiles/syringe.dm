/datum/projectile/syringe
	name = "syringe"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "syringeproj"
	damage = 1
	cost = 15
	dissipation_rate = 1
	dissipation_delay = 7
	power = 1
	hit_ground_chance = 10
	implanted = /obj/item/implant/projectile/body_visible/syringe
	shot_sound = 'sound/effects/syringeproj.ogg'
	default_firemode = /datum/firemode/single
	damage_type = D_TOXIC //needed for reagent shit

	syringe_barbed
		icon_state = "syringeproj_barbed"
		implanted = /obj/item/implant/projectile/body_visible/syringe/syringe_barbed
