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
	butcherable = BUTCHER_ALLOWED
	name_the_meat = 0
	death_text = "%src% messily splatters into a puddle of tomato sauce!"
	chase_text = "viciously lunges at"
	atk_brute_amt = 4
	crit_brute_amt = 6
	crit_chance = 10
	meat_type = /obj/item/reagent_containers/food/snacks/plant/tomato/incendiary
	generic = 0

	seek_target()
		src.anchored = UNANCHORED
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
				src.visible_message(SPAN_COMBAT("<b>[src]</b> charges at [C:name]!"))
				playsound(src.loc, pick('sound/voice/MEhunger.ogg', 'sound/voice/MEraaargh.ogg', 'sound/voice/MEruncoward.ogg', 'sound/voice/MEbewarecoward.ogg'), 25, 0)
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
