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

/obj/critter/wasp
	name = "space wasp"
	desc = "A wasp in space."
	icon_state = "wasp"
	critter_family = BUG
	density = 1
	health = 10
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 1
	firevuln = 1
	brutevuln = 1
	angertext = "buzzes at"
	butcherable = 1
	flags = NOSPLASH | OPENCONTAINER
	flying = 1
	//var/neurotoxin = 2
	chase_text = "stings"

	CritterDeath()
		..()
		src.reagents.add_reagent("toxin", 50, null)
		src.reagents.add_reagent("histamine", 50, null)
		return

	seek_target()
		src.anchored = UNANCHORED
		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.job == "Botanist") continue
			if (C.health < 0) continue
			if (C in src.friends) continue
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> charges at [C.name]!</span>")
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		..()
		if (M.reagents)
			M.reagents.add_reagent("histamine", 12)
			M.reagents.add_reagent("toxin", 2)
			M.add_karma(1)

/obj/critter/wasp/angry
	name = "angry space wasp"
	desc = "An angry wasp in space."
	angertext = "buzzes furiously at"
	health = 30
	firevuln = 1
	brutevuln = 0.8

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/wasp
	name = "space wasp egg"
	critter_type = /obj/critter/wasp

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/wasp/angry
	critter_type = /obj/critter/wasp/angry

/obj/critter/golem
	name = "Golem"
	desc = "An elemental being, crafted by local artisans using traditional techniques."
	icon_state = "golem"
	density = 1
	health = 25
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 0 // don't bother!
	firevuln = 0.25
	brutevuln = 0.5
	generic = 0
	atk_text = "bashes against"
	atk_brute_amt = 7
	is_pet = FALSE
	var/reagent_id = null

	New()
		..()

		src.create_reagents(1000)

		SPAWN(4 SECONDS)
			if(reagents && !reagents.total_volume)
				if (all_functional_reagent_ids.len > 0)
					src.reagent_id = pick(all_functional_reagent_ids)
				else
					src.reagent_id = "water"

				reagents.add_reagent(src.reagent_id, 10)

				var/oldcolor = src.reagents.get_master_color()
				var/icon/I = new /icon('icons/misc/critter.dmi',"golem")
				I.Blend(oldcolor, ICON_ADD)
				src.icon = I
				src.name = "[capitalize(src.reagents.get_master_reagent_name())]-Golem"

		return

	seek_target()
		src.anchored = UNANCHORED
		var/mob/living/Cc
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (C.ckey == null) continue //do not attack non-threats ie. NPC monkeys and AFK players
			if (iswizard(C)) continue //do not attack our master
			if (isintangible(C)) continue
			var/mob/living/carbon/human/H = C
			if (istype(C) && (H.traitHolder.hasTrait("training_chaplain"))) continue
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (isdead(C)) continue
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1
			Cc = C

		if (src.attack)
			src.target = Cc
			src.oldtarget_name = Cc.name
			src.visible_message("<span class='combat'><b>[src]</b> charges at [Cc.name]!</span>")
			src.task = "chasing"
			return


	proc/CustomizeGolem(var/datum/reagents/CR) //customise it with the reagents in a container

		for(var/current_id in CR.reagent_list)
			var/datum/reagent/R = CR.reagent_list[current_id]
			src.reagents.add_reagent(current_id, min(R.volume * 5, 50))

		var/oldcolor = src.reagents.get_master_color()
		var/icon/I = new /icon('icons/misc/critter.dmi',"golem")
		I.Blend(oldcolor, ICON_ADD)
		src.icon = I
		src.name = "[capitalize(src.reagents.get_master_reagent_name())]-Golem"
		src.desc = "An elemental entity composed of [src.reagents.get_master_reagent_name()], conjured by a wizard."
		return

	CritterAttack(mob/M)
		var/mob/living/carbon/human/H = M
		if (istype(M) && (H.traitHolder.hasTrait("training_chaplain"))) return
		..()
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
		if(M.reagents)
			if(src.reagents && src.reagents.total_volume)

				src.reagents.reaction(M, TOUCH)
				reagents.trans_to(M, 5)

	CritterDeath()
		if (!src.alive) return
		..()

		src.visible_message("<span class='combat'><b>[src]</b> bursts into a puff of smoke!</span>")
		logTheThing(LOG_COMBAT, src, "died, causing [src.reagents.get_master_reagent_name()] smoke at [log_loc(src)].")
		src.reagents.smoke_start(12)
		invisibility = INVIS_ALWAYS_ISH
		SPAWN(5 SECONDS)
			qdel(src)

/obj/critter/townguard
	name = "Town Guard"
	desc = "An angry man dressed in medieval armor."
	icon_state = "townguard"
	density = 1
	health = 100
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 1
	firevuln = 0.75
	brutevuln = 0.5
	death_text = "%src% seizes up and falls limp, his eyes dead and lifeless..."
	chase_text = "tackles"

	var/sword_damage_max = 12
	var/sword_damage_min = 6

	passive
		sword_damage_max = 0
		sword_damage_min = 0
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
				src.visible_message("<span class='combat'><b>[src]</b> points at [C.name]!</span>")
				for(var/mob/O in hearers(src, null))
					O.show_message("<b>[src]</b> says, \"HALT!\"", 2)
				playsound(src.loc, 'sound/voice/guard_halt.ogg', 50, 0)
				src.task = "chasing"
				return
			else
				continue


		if(!src.atcritter) return
		for (var/obj/critter/C in view(src.seekrange,src))
			if (!C.alive) continue
			if (C.health < 0) continue
			if (!istype(C, /obj/critter/townguard)) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> points at [C.name]!</span>")
				for(var/mob/O in hearers(src, null))
					O.show_message("<b>[src]</b> says, \"HALT!\"", 2)
				playsound(src.loc, 'sound/voice/guard_halt.ogg', 50, 0)
				src.task = "chasing"
				return

			else continue

	ChaseAttack(mob/M)
		if(iscarbon(M) && prob(15))
			..()
			playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
			random_brute_damage(M, rand(0,3))//this is weak enough as it is without being nerfed by armor - Tarm
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)
		else
			src.visible_message("<span class='combat'><B>[src]</B> tries to knock down [src.target] but misses!</span>", 1)

	CritterAttack(mob/M)
		for(var/mob/O in viewers(src, null))
			O.show_message("<b>[src]</b> says, \"HALT!\"", 2)
		playsound(src.loc, 'sound/voice/guard_halt.ogg', 50, 0)
		src.attacking = 1
		if(istype(M,/obj/critter))
			var/obj/critter/C = M
			for(var/mob/O in hearers(src, null))
				O.show_message("<b>[src]</b> says, \"HALT!\"", 2)
			playsound(C.loc, "swing_hit", 50, 1, -1)
			C.health -= 6
			if(C.health <= 0)
				C.CritterDeath()
			SPAWN(2.5 SECONDS)
				src.attacking = 0
			return

		if (M.health > 40 && !M.getStatusDuration("weakened"))
			src.visible_message("<span class='combat'><B>[src]</B> attacks [src.target] with his sword!</span>")
			playsound(M.loc, "swing_hit", 50, 1, -1)

			var/to_deal = rand(sword_damage_min,sword_damage_max)
			random_brute_damage(M, to_deal,1)
			if(iscarbon(M))
				if(to_deal > (((sword_damage_max-sword_damage_min)/2)+sword_damage_min) && prob(50))
					src.visible_message("<span class='combat'><B>[src] knocks down [M]!</B></span>")
					M:changeStatus("weakened", 8 SECONDS)
			SPAWN(2.5 SECONDS)
				src.attacking = 0
		else
			src.visible_message("<span class='combat'><B>[src]</B> kicks [src.target]!</span>")
			playsound(src.loc, "swing_hit", 50, 1, -1)
			random_brute_damage(src.target, rand(4,8),1)
			SPAWN(2.5 SECONDS)
				src.attacking = 0
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)
		return

	ai_think()
		if (prob(20))
			if (src.target)
				for(var/mob/O in viewers(src, null))
					O.show_message("<b>[src]</b> says, \"HALT!\"", 2)
				playsound(src.loc, 'sound/voice/guard_halt.ogg', 50, 0)
		return ..()

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/townguard
	name = "\improper Town Guard egg"
	desc = "This is not how humans reproduce. They do not lay eggs. <i>What the hell is this?</i>"
	critter_type = /obj/critter/townguard
	warm_count = 75
/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/townguard/passive
	critter_type = /obj/critter/townguard/passive

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

/obj/critter/blobman
	name = "mutant"
	desc = "Some sort of horrific, pulsating blob of flesh."
	icon_state = "blobman"
	density = 1
	health = 15
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 1
	firevuln = 0.75
	brutevuln = 0.5
	death_text = "%src% collapses into viscera."
	atk_text = "flails against"
	atk_brute_amt = 6
	crit_text = "flails heavily against"
	crit_brute_amt = 12
	chase_text = "headbutts"

	CritterAttack(mob/M)
		..()
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)

	ChaseAttack(mob/M)
		..()
		if(iscarbon(M))
			if (prob(5)) M.changeStatus("stunned", 2 SECONDS)
			random_brute_damage(M, rand(2,5),1)

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

/obj/critter/crunched
	name = "transposed scientist"
	desc = "A fellow who seems to have been shunted between dimensions. Not a good state to be in."
	icon_state = "crunched"
	health = 10
	brutevuln = 0.5
	firevuln = 0
	aggressive = 1
	generic = 0

	attack_hand(var/mob/user)
		if (user.a_intent == "help")
			return

		..()

	ChaseAttack(mob/M)
		return

	CritterAttack(mob/M)
		if (!ismob(M))
			return

		src.attacking = 1

		if (M.lying)
			src.speak( pick("No! Get up! Please, get up!", "Not again! Not again! I need you!", "Please! Please get up! Please!", "I don't want to be alone again!") )
			src.visible_message("<span class='notice'>[src] shakes [M] trying to wake them up!</span>")
			boutput(M, "<span class='combat'><b>It burns!</b></span>")
			M.TakeDamage("chest", 0, rand(5,15))
		else
			src.speak( pick("Please! Help! I need help!", "Please...help me!", "Are you real? You're real! YOU'RE REAL", "Everything hurts! Everything hurts!", "Please, make the pain stop! MAKE IT STOP!") )
			src.visible_message("<span class='combat'><B>[src]</B> grabs at [M]'s arm!</span>")
			boutput(M, "<span class='combat'><b>It burns!</b></span>")
			M.TakeDamage("chest", 0, rand(5,15))
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)
		SPAWN(6 SECONDS)
			src.attacking = 0

	ai_think()
		if(task == "thinking" || task == "wandering")
			if (prob(5))
				src.speak( pick("Cut the power! It's about to go critical, cut the power!","I warned them. I warned them the system wasn't ready.","Shut it down!","It hurts, oh God, oh God.") )
		else
			if (prob(5))
				src.speak( pick("Please...help...it hurts...please", "I'm...sick...help","It went wrong.  It all went wrong.","I didn't mean for this to happen!", "I see everything twice!") )

		return ..()

	CritterDeath()
		..()
		speak( pick("There...is...nothing...","It's dark.  Oh god, oh god, it's dark.","Thank you.","Oh wow. Oh wow. Oh wow.") )
		SPAWN(1.5 SECONDS)
			qdel(src)

	seek_target()
		src.anchored = UNANCHORED
		if (src.target)
			src.task = "chasing"
			return

		for (var/mob/living/carbon/C in view(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (C.stat || C.health < 0) continue

			src.target = C
			src.oldtarget_name = C.name
			src.task = "chasing"
			src.speak( pick("Hey..you! Help! Help me please!","I need..a doctor...","Someone...new? Help me...please.","Are you real?") )
			break

	proc/speak(var/message)
		if (!message)
			return

		var/fontSize = 1
		var/fontIncreasing = 1
		var/fontSizeMax = 3
		var/fontSizeMin = -3
		var/messageLen = length(message)
		var/processedMessage = ""

		for (var/i = 1, i <= messageLen, i++)
			processedMessage += "<font size=[fontSize]>[copytext(message, i, i+1)]</font>"
			if (fontIncreasing)
				fontSize = min(fontSize+1, fontSizeMax)
				if (fontSize >= fontSizeMax)
					fontIncreasing = 0
			else
				fontSize = max(fontSize-1, fontSizeMin)
				if (fontSize <= fontSizeMin)
					fontIncreasing = 1

		src.visible_message("<b>[src.name]</b> says, \"[processedMessage]\"")
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
