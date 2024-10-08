/obj/critter/spore
	name = "plasma spore"
	desc = "A barely intelligent colony of organisms. Very volatile."
	icon_state = "spore"
	death_text = "%src% ruptures and explodes!"
	density = 1
	health = 1
	aggressive = 0
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 2
	brutevuln = 2
	flying = 1

	CritterDeath()
		..()
		var/turf/T = get_turf(src.loc)
		if(T)
			T.hotspot_expose(700,125)
			explosion(src, T, -1, -1, 2, 3)
		qdel (src)

	ex_act(severity)
		CritterDeath()

	bullet_act(flag, A as obj)
		CritterDeath()


/obj/critter/spirit
	name = "spirit"
	desc = null
	invisibility = INVIS_GHOST
	icon_state = "spirit"
	health = 10
	aggressive = 1
	defensive = 1
	wanderer = 0
	atkcarbon = 1
	atksilicon = 1
	brutevuln = 0.5
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	seekrange = 5
	density = 0
	angertext = "suddenly materializes and lunges at"
	flying = 1
	generic = 0
	death_text = "%src% dissipates!"
	chase_text = "hurls itself at"
	atk_text = "attacks"
	atk_brute_amt = 3
	crit_chance = 0

	ai_think()
		..()
		if (src.alive)
			switch(task)
				if("thinking")
					src.invisibility = INVIS_GHOST
				if("chasing")
					src.invisibility = INVIS_NONE
				if("attacking")
					src.invisibility = INVIS_NONE

	seek_target()
		src.anchored = UNANCHORED
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C in src.friends) continue
			if (isvampire(C)) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message(SPAN_COMBAT("<b>[src]</b> [src.angertext] [C.name]!"))
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		..()
		if (prob(30)) M.changeStatus("knockdown", 3 SECONDS)

	CritterAttack(mob/M)
		..()

	CritterDeath()
		if (!src.alive)
			return
		..()
		new /obj/item/reagent_containers/food/snacks/ectoplasm(src.loc)
		qdel(src)

	bullet_act(var/obj/projectile/P)
		if (istype(P.proj_data, /datum/projectile/energy_bolt_antighost))
			src.CritterDeath()
			return
		else
			..()

	Cross(atom/movable/mover)
		if (istype(mover, /obj/projectile))
			var/obj/projectile/proj = mover
			if (istype(proj.proj_data, /datum/projectile/energy_bolt_antighost))
				return 0

		return 1

/obj/critter/bloodling
	name = "Bloodling"
	desc = "A force of pure sorrow and evil. They shy away from that which is holy."
	icon_state = "bling"
	density = 1
	health = 50
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 0
	atcritter = 0
	firevuln = 1
	brutevuln = 0.5
	seekrange = 5
	flying = 1
	is_pet = FALSE
	generic = 0
	var/cleanable_type = /obj/decal/cleanable/blood
	var/what_is_sucked_out = "blood"

	New()
		UpdateParticles(new/particles/bloody_aura, "bloodaura")
		..()

	seek_target()
		src.anchored = UNANCHORED
		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.task = "chasing"
				return
			else
				continue

	ChaseAttack(mob/M)
		src.attacking = 1
		playsound(src.loc, 'sound/effects/ghost.ogg', 30, 1, -1)
		if(iscarbon(M) && prob(50))
			boutput(M, SPAN_COMBAT("<b>You are forced to the ground by \the [src]!</b>"))
			random_brute_damage(M, rand(0,5))
			M.changeStatus("stunned", 5 SECONDS)
			M.changeStatus("knockdown", 5 SECONDS)
			src.attacking = 0
			return

	CritterAttack(mob/M)
		if(!what_is_sucked_out)
			return
		playsound(src.loc, 'sound/effects/ghost2.ogg', 30, 1, -1)
		attacking = 1
		if(iscarbon(M))
			if(prob(66))
				random_brute_damage(M, rand(5,10))
				take_bleeding_damage(M, null, rand(10,35), DAMAGE_CRUSH, 5, get_turf(M))
				boutput(M, SPAN_COMBAT("<b>You feel [what_is_sucked_out] getting drawn out through your skin!</b>"))
			else
				boutput(M, SPAN_COMBAT("You feel uncomfortable. Your [what_is_sucked_out] seeks to escape you."))
				M.changeStatus("slowed", 3 SECONDS, 3)

		SPAWN(0.5 SECONDS)
			attacking = 0


	attackby(obj/item/W, mob/living/user)
		if (!src.alive)
			return
		else
			if(!W.reagents)
				boutput(user, SPAN_COMBAT("Hitting it with [W] is ineffective!"))
				return
			if(W.reagents.has_reagent("water_holy"))
				boutput(user, "[src] screams!")
				CritterDeath()
				return
			else
				boutput(user, SPAN_COMBAT("Hitting it with [W] is ineffective!"))
				return

	attack_hand(var/mob/user)
		if (src.alive)
			boutput(user, SPAN_COMBAT("<b>Your hand passes right through!</b>"))
		return

	ai_think()
		if(!locate(cleanable_type) in src.loc)
			if(prob(50))
				playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, 1, -1)
				make_cleanable(cleanable_type, loc)
		return ..()

	CritterDeath()
		if (!src.alive)
			return
		..()
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, 1, -1)
		new cleanable_type(src.loc)
		qdel(src)

/obj/critter/bloodling/ketchupling
	name = "Ketchupling"
	desc = "A force of pure tomato and evil. They shy away from that which is holy."
	cleanable_type = /obj/decal/cleanable/tomatosplat
	what_is_sucked_out = "ketchup"

/obj/critter/ancient_thing
	name = "???"
	desc = "What the hell is that?"
	icon = 'icons/mob/critter/robotic/ancient/robot.dmi'
	icon_state = "ancientrobot"
	dead_state = "ancientrobot" // fades away
	death_text = "%src% fades away."
	post_pet_text = " For some reason! Not like that's weird or anything!"
	invisibility = INVIS_GHOST
	health = 30
	firevuln = 0
	brutevuln = 0.5
	aggressive = 1
	defensive = 1
	wanderer = 0
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	seekrange = 5
	density = 1
	var/boredom_countdown = 0

	CritterDeath()
		..()
		flick("ancientrobot-disappear",src)
		SPAWN(16) //maybe let the animation actually play
			qdel(src)

	seek_target()
		src.anchored = UNANCHORED
		if (src.target)
			src.task = "chasing"
			return

		for (var/mob/living/carbon/C in view(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (C.stat || C.health < 0) continue

			src.boredom_countdown = rand(5,10)
			src.target = C
			src.oldtarget_name = C.name
			src.task = "chasing"
			src.appear()
			break

	attackby(obj/item/W, mob/living/user)
		..()
		src.boredom_countdown = rand(5,10)

	attack_hand(var/mob/user)
		..()
		src.boredom_countdown = rand(5,10)

	ChaseAttack(mob/M)
		return

	CritterAttack(mob/M)
		src.attacking = 1

		if (boredom_countdown-- > 0)
			src.visible_message(SPAN_COMBAT("<B>[src]</B> [pick("measures", "gently pulls at", "examines", "pokes", "gently prods", "feels")] [src.target]'s [pick("head","neck","shoulders","right arm", "left arm","left leg","right leg")]!"))
			if (prob(50))
				boutput(src.target, SPAN_COMBAT("You feel [pick("very ",null,"rather ","fairly ","remarkably ")]uncomfortable."))
		else
			var/mob/living/doomedMob = src.target
			if (!istype(doomedMob))
				return

			src.visible_message(SPAN_COMBAT("<b>In a whirling flurry of tendrils, [src] rends down [src.target]! Holy shit!</b>"))
			logTheThing(LOG_COMBAT, M, "was gibbed by [src] at [log_loc(src)].") // Some logging for instakill critters would be nice (Convair880).
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			doomedMob.ghostize()
			new /obj/fakeobject/skeleton(doomedMob.loc)
			doomedMob.gib()
			src.target = null

		SPAWN(4 SECONDS)
			src.attacking = 0

	proc/appear()
		if (!invisibility || (src.icon_state != "ancientrobot"))
			return
		src.name = pick("something","weird thing","odd thing","whatchamacallit","thing","something weird","old thing")
		src.icon_state = "ancientrobot-appear"
		src.invisibility = INVIS_NONE
		SPAWN(1.2 SECONDS)
			src.icon_state = "ancientrobot"
		return
