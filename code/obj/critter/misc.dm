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
				src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [C.name]!</span>")
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		..()
		if (prob(30)) M.changeStatus("weakened", 3 SECONDS)

	CritterAttack(mob/M)
		..()

	CritterDeath()
		if (!src.alive)
			return
		..()
		new /obj/item/reagent_containers/food/snacks/ectoplasm(src.loc)
		qdel(src)

	bullet_act(var/obj/projectile/P)
		if (istype(P, /datum/projectile/energy_bolt_antighost))
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
		if (narrator_mode)
			playsound(src.loc, 'sound/vox/ghost.ogg', 50, 1, -1)
		else
			playsound(src.loc, 'sound/effects/ghost.ogg', 30, 1, -1)
		if(iscarbon(M) && prob(50))
			boutput(M, "<span class='combat'><b>You are forced to the ground by \the [src]!</b></span>")
			random_brute_damage(M, rand(0,5))
			M.changeStatus("stunned", 5 SECONDS)
			M.changeStatus("weakened", 5 SECONDS)
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
				boutput(M, "<span class='combat'><b>You feel [what_is_sucked_out] getting drawn out through your skin!</b></span>")
			else
				boutput(M, "<span class='combat'>You feel uncomfortable. Your [what_is_sucked_out] seeks to escape you.</span>")
				M.changeStatus("slowed", 3 SECONDS, 3)

		SPAWN(0.5 SECONDS)
			attacking = 0


	attackby(obj/item/W, mob/living/user)
		if (!src.alive)
			return
		else
			if(!W.reagents)
				boutput(user, "<span class='combat'>Hitting it with [W] is ineffective!</span>")
				return
			if(W.reagents.has_reagent("water_holy"))
				boutput(user, "[src] screams!")
				CritterDeath()
				return
			else
				boutput(user, "<span class='combat'>Hitting it with [W] is ineffective!</span>")
				return

	attack_hand(var/mob/user)
		if (src.alive)
			boutput(user, "<span class='combat'><b>Your hand passes right through!</b></span>")
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
			src.visible_message("<span class='combat'><B>[src]</B> [pick("measures", "gently pulls at", "examines", "pokes", "gently prods", "feels")] [src.target]'s [pick("head","neck","shoulders","right arm", "left arm","left leg","right leg")]!</span>")
			if (prob(50))
				boutput(src.target, "<span class='combat'>You feel [pick("very ",null,"rather ","fairly ","remarkably ")]uncomfortable.</span>")
		else
			var/mob/living/doomedMob = src.target
			if (!istype(doomedMob))
				return

			src.visible_message("<span class='combat'><b>In a whirling flurry of tendrils, [src] rends down [src.target]! Holy shit!</b></span>")
			logTheThing(LOG_COMBAT, M, "was gibbed by [src] at [log_loc(src)].") // Some logging for instakill critters would be nice (Convair880).
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			doomedMob.ghostize()
			new /obj/decal/fakeobjects/skeleton(doomedMob.loc)
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

/obj/critter/livingtail
	name = "Living tail"
	desc = "A twitching saurian tail, you feel mildly uncomfortable looking at it."
	icon_state = "twitchytail"
	density = 0
	health = 20
	flags = NOSPLASH | TABLEPASS
	maxhealth = 40
	butcherable = 1

	var/obj/item/organ/tail/lizard/tail_memory = null
	var/maxsteps
	var/currentsteps = 0
	var/primary_color =	"#21a833"
	var/secondary_color = "#000000"

	New()
		..()
		maxsteps = rand(2,12)

	proc/setup_overlays()
		var/image/overlayprimary = image('icons/misc/critter.dmi', "twitchytail_colorkey1")
		overlayprimary.color = primary_color
		var/image/overlaysecondary = image('icons/misc/critter.dmi', "twitchytail_colorkey2")
		overlaysecondary.color = secondary_color
		src.UpdateOverlays(overlayprimary, "bottomdetail")
		src.UpdateOverlays(overlaysecondary, "topdetail")

	process()
		currentsteps++

		if (currentsteps >= maxsteps)
			CritterDeath()

		if (prob(70))
			playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, 1)
			make_cleanable(/obj/decal/cleanable/blood/splatter,src.loc)
		..()

	CritterDeath()
		..()
		if (tail_memory)
			tail_memory.set_loc(get_turf(src))
		else
			new/obj/item/organ/tail/lizard(get_turf(src))
		qdel(src)

	Crossed(atom/movable/M as mob)
		..()
		if (ishuman(M) && prob(25))
			src.visible_message("<span class='combat'>[src] coils itself around [M]'s legs and trips [him_or_her(M)]!</span>")
			M:changeStatus("weakened", 2 SECONDS)
		return
