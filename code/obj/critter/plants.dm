/obj/critter/maneater
	name = "man-eating plant"
	desc = "It looks hungry..."
	icon_state = "maneater"
	density = 1
	health = 30
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 0
	firevuln = 2
	brutevuln = 0.5
	butcherable = 1
	name_the_meat = 0
	chase_text = "slams into"
	meat_type = /obj/item/reagent_containers/food/snacks/salad
	generic = 0 // get this using the plant quality

	New()
		..()
		playsound(src.loc, pick('sound/voice/MEilive.ogg'), 45, 0)

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.job == "Botanist") continue
			if (iskudzuman(C)) continue
			if (C.health < 0) continue
			if (C in src.friends) continue
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> charges at [C.name]!</span>")
				playsound(src.loc, pick('sound/voice/MEhunger.ogg', 'sound/voice/MEraaargh.ogg', 'sound/voice/MEruncoward.ogg', 'sound/voice/MEbewarecoward.ogg'), 40, 0)
				src.task = "chasing"
				break
			else continue

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
		M.changeStatus("stunned", 2 SECONDS)
		M.changeStatus("weakened", 2 SECONDS)

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message("<span class='combat'><B>[src]</B> starts trying to eat [M]!</span>")
		SPAWN(7 SECONDS)
			if (BOUNDS_DIST(src, M) == 0 && ((M:loc == target_lastloc)) && src.alive) // added a health check so dead maneaters stop eating people - cogwerks
				if(iscarbon(M))
					src.visible_message("<span class='combat'><B>[src]</B> ravenously wolfs down [M]!</span>")
					logTheThing(LOG_COMBAT, M, "was devoured by [src] at [log_loc(src)].") // Some logging for instakill critters would be nice (Convair880).
					playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
					M.death(TRUE)
					var/atom/movable/overlay/animation = null
					M.transforming = 1
					M.canmove = 0
					M.icon = null
					APPLY_ATOM_PROPERTY(M, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
					if(ishuman(M))
						animation = new(src.loc)
						animation.icon_state = "blank"
						animation.icon = 'icons/mob/mob.dmi'
						animation.master = src
					if (M.client)
						M.ghostize()
					qdel(M)

					sleeping = 2
					src.target = null
					src.task = "thinking"
					playsound(src.loc, pick('sound/voice/burp_alien.ogg'), 50, 0)
			else
				if (isliving(M))
					var/mob/living/H = M
					H.was_harmed(src)
				if(src.alive) // don't gnash teeth if dead
					src.visible_message("<span class='combat'><B>[src]</B> gnashes its teeth in fustration!</span>")
			src.attacking = 0

/obj/critter/killertomato
	name = "killer tomato"
	desc = "Today, Space Station 13 - tomorrow, THE WORLD!"
	icon_state = "ktomato"
	density = 1
	health = 15
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	firevuln = 2
	brutevuln = 2
	butcherable = 1
	name_the_meat = 0
	death_text = "%src% messily splatters into a puddle of tomato sauce!"
	chase_text = "viciously lunges at"
	atk_brute_amt = 4
	crit_brute_amt = 6
	crit_chance = 10
	meat_type = /obj/item/reagent_containers/food/snacks/plant/tomato/incendiary
	generic = 0

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (iskudzuman(C)) continue
			if (C in src.friends) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> charges at [C:name]!</span>")
				playsound(src.loc, pick('sound/voice/MEhunger.ogg', 'sound/voice/MEraaargh.ogg', 'sound/voice/MEruncoward.ogg', 'sound/voice/MEbewarecoward.ogg'), 40, 0)
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		..()
		if (prob(20)) M.changeStatus("stunned", 2 SECONDS)
		random_brute_damage(M, rand(4,6),1)

	CritterAttack(mob/M)
		..()

	CritterDeath()
		..()
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
		var/obj/decal/cleanable/blood/B = make_cleanable(/obj/decal/cleanable/blood,src.loc)
		B.name = "ruined tomato"
		qdel (src)
