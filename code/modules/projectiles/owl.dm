/datum/projectile/owl
	name = "space-time disruption"
	icon = 'icons/misc/bird.dmi'
	icon_state = "owl"
//How much of a punch this has, tends to be seconds/damage before any resist
	stun = 10
//How much ammo this costs
	cost = 1
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//name of the projectile setting, used when you change a guns setting
	sname = "Owlize"
//file location for the sound you want it to play
	shot_sound = 'sound/voice/animal/hoot.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
//What is our damage type
	damage_type = 0
	//With what % do we hit mobs laying down
	hit_ground_chance = 10
	//Can we pass windows
	window_pass = 0

	on_hit(atom/hit)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if (!(M.wear_mask && istype(M.wear_mask, /obj/item/clothing/mask/owl_mask)))
				for(var/obj/item/clothing/O in M)
					M.u_equip(O)
					if (O)
						O.set_loc(M.loc)
						O.dropped(M)
						O.layer = initial(O.layer)

				var/obj/item/clothing/under/gimmick/owl/owlsuit = new /obj/item/clothing/under/gimmick/owl(M)
				owlsuit.cant_self_remove = 1
				var/obj/item/clothing/mask/owl_mask/owlmask = new /obj/item/clothing/mask/owl_mask(M)
				owlmask.cant_self_remove = 1


				M.equip_if_possible(owlsuit, M.slot_w_uniform)
				M.equip_if_possible(owlmask, M.slot_wear_mask)
				M.set_clothing_icon_dirty()


/datum/projectile/owl/owlate
	sname = "Owlate"

	on_hit(atom/hit)

		if(ishuman(hit))
			SPAWN(1 DECI SECOND)
			hit:owlgib()
