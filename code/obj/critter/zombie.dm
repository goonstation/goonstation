/obj/critter/zombie
	name = "Zombie"
	desc = "BraaAAAinnsSSs..."
	icon_state = "zombie"
	density = 1
	health = 20
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 1
	firevuln = 0.25
	brutevuln = 0.5
	butcherable = 1
	chase_text = "slams into"
	is_pet = 0

	var/punch_damage_max = 9
	var/punch_damage_min = 3
	var/hulk = 0 //A zombie hulk? Oh god.
	var/eats_brains = 1

	skinresult = /obj/item/material_piece/cloth/leather
	max_skins = 2

	/*New()
		..()
		playsound(src.loc, pick('sound/voice/Zgroan1.ogg', 'sound/voice/Zgroan2.ogg', 'sound/voice/Zgroan3.ogg', 'sound/voice/Zgroan4.ogg'), 25, 0)*/

	seek_target()
		src.anchored = UNANCHORED
		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iszombie(C)) continue // For admin gimmicks mixing player zombies and critters
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C in src.friends) continue

			if (C.health < 0) continue
			if (ishuman(C))
				if (C:mutantrace && istype(C:mutantrace, /datum/mutantrace/zombie)) continue
				if (istype(C:head, /obj/item/clothing/head/void_crown)) continue

			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='alert'><b>[src]</b> lunges at [C.name]!</span>")
				playsound(src.loc, pick('sound/voice/Zgroan1.ogg', 'sound/voice/Zgroan2.ogg', 'sound/voice/Zgroan3.ogg', 'sound/voice/Zgroan4.ogg'), 25, 0)
				src.task = "chasing"
				return
			else
				continue


		if(!src.atcritter) return
		for (var/obj/critter/C in view(src.seekrange,src))
			if (!C.alive) continue
			if (C.health < 0) continue
			if (!istype(C, /obj/critter/zombie)) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='alert'><b>[src]</b> lunges at [C.name]!</span>")
				playsound(src.loc, pick('sound/voice/Zgroan1.ogg', 'sound/voice/Zgroan2.ogg', 'sound/voice/Zgroan3.ogg', 'sound/voice/Zgroan4.ogg'), 25, 0)
				src.task = "chasing"
				return

			else continue

	proc/after_attack_special(mob/living/M) //Override in subtype
		return

	ChaseAttack(mob/M)
		if(iscarbon(M) && prob(15))
			..()
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
			random_brute_damage(M, rand(0,3),1)
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)
		else
			src.visible_message("<span class='alert'><B>[src]</B> tries to knock down [src.target] but misses!</span>")

	CritterAttack(mob/living/M)
		src.attacking = 1
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)
		if(istype(M,/obj/critter))
			var/obj/critter/C = M
			src.visible_message("<span class='alert'><B>[src]</B> punches [src.target]!</span>")
			playsound(C.loc, "punch", 25, 1, -1)
			C.health -= 4
			if(C.health <= 0)
				C.CritterDeath()
			SPAWN(2.5 SECONDS)
				src.attacking = 0
			return

		if (!M.getStatusDuration("weakened") && !M.lying)
			src.visible_message("<span class='alert'><B>[src]</B> punches [src.target]!</span>")
			playsound(M.loc, "punch", 25, 1, -1)

			var/to_deal = rand(punch_damage_min,punch_damage_max)
			random_brute_damage(M, to_deal,1)
			after_attack_special(src.target)
			if(iscarbon(M))
				if(to_deal > (((punch_damage_max-punch_damage_min)/2)+punch_damage_min) && prob(50))
					src.visible_message("<span class='alert'><B>[src] knocks down [M]!</B></span>")
					M:changeStatus("weakened", 8 SECONDS)
		//		if(prob(4) && eats_brains) //Give the gift of being a zombie (unless we eat them too fast)
		//			M.contract_disease(/datum/ailment/disease/necrotic_degeneration, null, null, 1) // path, name, strain, bypass resist
			if(src.hulk) //TANK!
				SPAWN(0)
					M:changeStatus("paralysis", 2 SECONDS)
					step_away(M,src,15)
					sleep(0.3 SECONDS)
					step_away(M,src,15)
			SPAWN(2.5 SECONDS)
				src.attacking = 0
		else
			if(ishuman(M) && src.eats_brains) //These only make human zombies anyway!
				src.visible_message("<span class='alert'><B>[src]</B> starts trying to eat [M]'s brain!</span>")
			else
				src.visible_message("<span class='alert'><B>[src]</B> attacks [src.target]!</span>")
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
				random_brute_damage(src.target, rand(punch_damage_min,punch_damage_max),1)
				after_attack_special(src.target)
				SPAWN(2.5 SECONDS)
					src.attacking = 0
				return
			SPAWN(6 SECONDS)
				if (BOUNDS_DIST(src, M) == 0 && ((M:loc == target_lastloc)) && M.lying)
					if(iscarbon(M))
						logTheThing(LOG_COMBAT, M, "was zombified by [src] at [log_loc(src)].") // Some logging for instakill critters would be nice (Convair880).
						M.death(TRUE)
						src.visible_message("<span class='alert'><B>[src]</B> slurps up [M]'s brain!</span>")
						playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
						M.canmove = 0
						M.icon = null
						APPLY_ATOM_PROPERTY(M, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
						M:death()
						var/obj/critter/zombie/P = new(M.loc)
						///this little bit of code prevents multiple zombies from the same victim
						if (M == null)
							qdel(P)
							return
						src.visible_message("<span class='alert'>[M]'s corpse reanimates!</span>")
						//Zombie is all dressed up and no place to go
						var/stealthy = 0 //High enough and people won't even see it's undead right away.
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							//Uniform
							if(H.w_uniform)
								if (istype(H.w_uniform, /obj/item/clothing/under))
									P.overlays += image("icon" = 'icons/mob/clothing/jumpsuits/worn_js.dmi', "icon_state" = H.w_uniform.icon_state, "layer" = FLOAT_LAYER)
									stealthy += 4
							//Suit
							if(H.wear_suit)
								if (istype(H.wear_suit, /obj/item/clothing/suit))
									P.overlays += image("icon" = 'icons/mob/clothing/overcoats/worn_suit.dmi', "icon_state" = H.wear_suit.icon_state, "layer" = FLOAT_LAYER)
									stealthy += 2
							//Back
							if(H.back)
								var/t1 = H.back.icon_state
								P.overlays += image("icon" = 'icons/mob/clothing/back.dmi', "icon_state" = t1, "layer" = FLOAT_LAYER)
							//Mask
							if (H.wear_mask)
								if (istype(H.wear_mask, /obj/item/clothing/mask))
									var/t1 = H.wear_mask.icon_state
									P.overlays += image("icon" = 'icons/mob/clothing/mask.dmi', "icon_state" = t1, "layer" = FLOAT_LAYER)
									if (H.wear_mask.c_flags & COVERSEYES)
										stealthy += 2
							//Shoes
							if (H.shoes)
								if (istype(H.shoes))
									var/t1 = H.shoes.icon_state
									P.overlays += image("icon" = 'icons/mob/clothing/feet.dmi', "icon_state" = t1, "layer" = FLOAT_LAYER)
									stealthy++
							//Gloves.  Zombie boxers??
							if (H.gloves)
								if (istype(H.gloves))
									var/t1 = H.gloves.item_state
									P.overlays += image("icon" = 'icons/mob/clothing/hands.dmi', "icon_state" = t1, "layer" = FLOAT_LAYER)
									stealthy++
							//Head
							if (H.head)
								var/t1 = H.head.icon_state
								var/icon/head_icon = icon('icons/mob/clothing/head.dmi', "[t1]")
								if (istype(H.head, /obj/item/clothing/head/butt))
									var/obj/item/clothing/head/butt/B = H.head
									if (B.s_tone)
										head_icon.Blend(B.s_tone, ICON_ADD)
								P.overlays += image(icon = head_icon, layer = FLOAT_LAYER)
								if (H.head.c_flags & COVERSEYES)
									stealthy += 2
								if (H.head.c_flags & COVERSMOUTH)
									stealthy += 2

							//Oh no, a tank!
							if(H.is_hulk())
								P.hulk = 1
								P.punch_damage_max += 4

						P.health = src.health
						if(stealthy >= 10)
							P.name = M.real_name
						else
							P.name += " [M.real_name]"

						var/atom/movable/overlay/animation = null
						if(ishuman(M))
							animation = new(src.loc)
							animation.icon_state = "blank"
							animation.icon = 'icons/mob/mob.dmi'
							animation.master = src
						if (M.client)
							var/mob/dead/observer/newmob
							newmob = new/mob/dead/observer(M)
							M.client:mob = newmob
							M.mind.transfer_to(newmob)
						qdel(M)
						qdel(animation)
						sleeping = 2
						SPAWN(2 SECONDS)
							playsound(src.loc, 'sound/voice/burp_alien.ogg', 50, 0)
				else
					src.visible_message("<span class='alert'><B>[src]</B> gnashes its teeth in fustration!</span>")
				src.attacking = 0

	CritterDeath()
		..()
		if (istype(src, /obj/critter/zombie/h7)) return //special death
		gibs(src.loc) //cmon let's let them really make a mess
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
		qdel (src)


/obj/critter/zombie/scientist
	name = "Shambling Scientist"
	desc = "Physician, heal thyself! Welp, so much for that."
	icon_state = "scizombie"
	health = 10
	firevuln = 0.15
	generic = 0

	ChaseAttack(mob/M)
		if(!attacking)
			src.CritterAttack(M)
		return

/obj/critter/zombie/security
	name = "Undead Guard"
	desc = "Eh, couldn't be any worse than regular security."
	icon_state = "seczombie"
	health = 18
	brutevuln = 0.6
	generic = 0

	ChaseAttack(mob/M)
		if(!attacking)
			src.CritterAttack(M)
		return

/obj/critter/zombie/h7
	name = "Biosuit Shambler"
	desc = "This does not reassure one about biosuit reliability."
	icon_state = "suitzombie"
	health = 10
	brutevuln = 0.6
	atcritter = 0
	eats_brains = 0
	generic = 0

	ChaseAttack(mob/M)
		if(!attacking)
			src.CritterAttack(M)
		return

	CritterDeath()
		..()
		src.visible_message("<span class='alert'>Black mist flows from the broken suit!</span>")
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)

		harmless_smoke_puff(src.loc)

		new /mob/living/critter/aberration(src.loc)
		new /obj/item/clothing/suit/bio_suit(src.loc)
		new /obj/item/clothing/gloves/latex(src.loc)
		new /obj/item/clothing/head/bio_hood(src.loc)
		qdel (src)

//It's like the jam mansion is back!
/obj/critter/zombie/wrestler
	name = "Zombie Wrestler"
	desc = "This zombie is hulked out! Watch out for the piledriver!"
	icon_state = "wrestlerzombie"
	health = 25
	firevuln = 0.15
	hulk = 1
	generic = 0

	ChaseAttack(mob/M)
		if(!attacking)
			src.CritterAttack(M)
		return

//For Jones City Ruins
/obj/critter/zombie/radiation
	name = "Shambling Technician"
	desc = "Looks like they got a large dose of the Zetas."
	icon_state = "radzombie"
	health = 25
	brutevuln = 0.4
	firevuln = 0.4
	eats_brains = 0
	generic = 0
	atcritter = 0
	butcherable = 0
	defensive = 1

	New()
		..()
		src.add_simple_light("rad", list(0, 0.8 * 255, 0.3 * 255, 0.8 * 255))

	ChaseAttack(mob/M)
		if(!attacking)
			src.CritterAttack(M)
		return

	after_attack_special(mob/living/M)
		boutput(M, "<span class='alert'>You are enveloped by a soft green glow emanating from [src].</span>")
		M.take_radiation_dose(1 SIEVERTS)

	CritterDeath()
		..()
		src.remove_simple_light("rad")
		make_cleanable( /obj/decal/cleanable/greenglow,src.loc)
