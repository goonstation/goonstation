/////////// cogwerks - hideous brullbar beast

/obj/critter/brullbar
	name = "brullbar"
	desc = "Oh god."
	icon_state = "brullbar"
	invisibility = INVIS_SPOOKY
	health = 60
	firevuln = 1
	brutevuln = 0.5
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	seekrange = 6
	density = 0
	butcherable = 1
	can_revive = 1
	chase_text = "tackles"
	var/boredom_countdown = 0
	var/flailing = 0
	var/frenzied = 0
	var/king = 0

	var/left_arm_stage = 0
	var/right_arm_stage = 0
	var/obj/item/parts/human_parts/arm/left/brullbar/left_arm
	var/obj/item/parts/human_parts/arm/right/brullbar/right_arm

	skinresult = /obj/item/material_piece/cloth/brullbarhide

	New()
		src.left_arm = new /obj/item/parts/human_parts/arm/left/brullbar(src)
		src.right_arm = new /obj/item/parts/human_parts/arm/right/brullbar(src)
		..()

	on_revive()
		if (!src.left_arm)
			src.left_arm = new /obj/item/parts/human_parts/arm/left/brullbar(src)
			src.left_arm_stage = 0
			src.visible_message("<span class='alert'>[src]'s left arm regrows!</span>")
		if (!src.right_arm)
			src.right_arm = new /obj/item/parts/human_parts/arm/right/brullbar(src)
			src.right_arm_stage = 0
			src.visible_message("<span class='alert'>[src]'s right arm regrows!</span>")
		..()

	CritterDeath()
		..()
		layer = initial(layer)
		if (king) return // king has his own death noises, spooky
		playsound(src.loc, 'sound/voice/animal/brullbar_cry.ogg', 60, 1)

	seek_target()
		src.anchored = 0
		if (src.target)
			src.task = "chasing"
			return
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (!isrobot(C) && !ishuman(C)) continue
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			//if (C.stat || C.health < 0) continue

			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(!king && iswerewolf(H))
					src.visible_message("<span class='alert'><b>[src] backs away in fear!</b></span>")
					step_away(src, H, 15)
					src.set_dir(get_dir(src, H))
					continue

			src.boredom_countdown = rand(2,5)
			if(king)
				boredom_countdown = rand(0,1) // king brullbars are pretty much grump elementals
			src.target = C
			src.oldtarget_name = C.name
			src.task = "chasing"
			src.appear()
			if(king)
				playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 75, 1)
				src.visible_message("<span class='alert'><b>[src] roars!</b></span>", 1)
			break

	proc/update_dead_icon()
		if (src.alive)
			return
		. = "brullbar"
		if (!src.left_arm)
			. += "-l"
		if (!src.right_arm)
			. += "-r"
		. += "-dead"
		icon_state = .

	attackby(obj/item/W, mob/living/user) //ARRRRGH WHY
		user.lastattacked = src
		if (!src.alive)
			// TODO: tie this into surgery()
			if (iscuttingtool(W))
				if (user.zone_sel.selecting == "l_arm")
					if (src.left_arm_stage == 0)
						user.visible_message("<span class='alert'>[user] slices through the skin and flesh of [src]'s left arm with [W].</span>", "<span class='alert'>You slice through the skin and flesh of [src]'s left arm with [W].</span>")
						src.left_arm_stage++
					else if (src.left_arm_stage == 2)
						user.visible_message("<span class='alert'>[user] cuts through the remaining strips of skin holding [src]'s left arm on with [W].</span>", "<span class='alert'>You cut through the remaining strips of skin holding [src]'s left arm on with [W].</span>")
						src.left_arm_stage++

						src.left_arm.quality = (src.quality + 150) / 350
						var/nickname = "king"
						if (src.quality < 200)
							nickname = src.quality_name
						if (nickname)
							src.left_arm.name = "[nickname] [initial(src.left_arm.name)]"

						var/turf/location = get_turf(src)
						if (location)
							src.left_arm.set_loc(location)
							src.left_arm = null
						src.update_dead_icon()

				else if (user.zone_sel.selecting == "r_arm")
					if (src.right_arm_stage == 0)
						user.visible_message("<span class='alert'>[user] slices through the skin and flesh of [src]'s right arm with [W].</span>", "<span class='alert'>You slice through the skin and flesh of [src]'s right arm with [W].</span>")
						src.right_arm_stage++
					else if (src.right_arm_stage == 2)
						user.visible_message("<span class='alert'>[user] cuts through the remaining strips of skin holding [src]'s right arm on with [W].</span>", "<span class='alert'>You cut through the remaining strips of skin holding [src]'s right arm on with [W].</span>")
						src.right_arm_stage++

						src.right_arm.quality = (src.quality + 100) / 350
						var/nickname = "king"
						if (src.quality < 200)
							nickname = src.quality_name
						if (nickname)
							src.right_arm.name = "[nickname] [initial(src.right_arm.name)]"

						var/turf/location = get_turf(src)
						if (location)
							src.right_arm.set_loc(location)
							src.right_arm = null
						src.update_dead_icon()

			else if (issawingtool(W))
				if (user.zone_sel.selecting == "l_arm")
					if (src.left_arm_stage == 1)
						user.visible_message("<span class='alert'>[user] saws through the bone of [src]'s left arm with [W].</span>", "<span class='alert'>You saw through the bone of [src]'s left arm with [W].</span>")
						src.left_arm_stage++
				else if (user.zone_sel.selecting == "r_arm")
					if (src.right_arm_stage == 1)
						user.visible_message("<span class='alert'>[user] saws through the bone of [src]'s right arm with [W].</span>", "<span class='alert'>You saw through the bone of [src]'s right arm with [W].</span>")
						src.right_arm_stage++
			else
				..()
			return
		var/attack_force = 0
		var/damage_type = "brute"
		if (istype(W, /obj/item/artifact/melee_weapon))
			var/datum/artifact/melee/ME = W.artifact
			attack_force = ME.dmg_amount
			damage_type = ME.damtype
		else
			attack_force = W.force
			switch(W.hit_type)
				if (DAMAGE_BURN)
					damage_type = "fire"
				else
					damage_type = "brute"

		switch(damage_type)
			if("fire")
				src.health -= attack_force * src.firevuln
			if("brute")
				src.health -= attack_force * src.brutevuln
			else
				src.health -= attack_force * src.miscvuln
		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='alert'><b>[user]</b> hits [src] with [W]!</span>", 1)
		if(prob(30))
			playsound(src.loc, 'sound/voice/animal/brullbar_cry.ogg', 60, 1)
			src.visible_message("<span class='alert'><b>[src] cries!</b></span>", 1)
		if(prob(25) && alive) // crowds shouldn't be able to beat the fuck out of a confused brullbar with impunity, fuck that
			src.target = user
			src.oldtarget_name = user.name
			src.task = "chasing"
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 60, 1)
			src.visible_message("<span class='alert'><b>[src]</b> slams into [src.target]!</span>")
			frenzy(src.target)

		if (src.alive && src.health <= 0) src.CritterDeath()

		//src.boredom_countdown = rand(5,10)
		src.target = user
		src.oldtarget_name = user.name
		src.task = "chasing"

	attack_hand(var/mob/user)
		user.lastattacked = src
		if (!src.alive)
			..()
			return
		if (user.a_intent == INTENT_HARM)
			src.health -= rand(1,2) * src.brutevuln
			on_damaged(src)
			for(var/mob/O in viewers(src, null))
				O.show_message("<span class='alert'><b>[user]</b> punches [src]!</span>", 1)
			playsound(src.loc, "punch", 50, 1)
			if(prob(30))
				playsound(src.loc, 'sound/voice/animal/brullbar_cry.ogg', 60, 1)
				src.visible_message("<span class='alert'><b>[src] cries!</b></span>", 1)
			if(prob(20) && alive) // crowd beatdown fix
				src.target = user
				src.oldtarget_name = user.name
				src.task = "chasing"
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1)
				src.visible_message("<span class='alert'><b>[src]</b> slams into [src.target]!</span>")
				user.changeStatus("weakened", 2 SECONDS)
				frenzy(src.target)
			if (src.alive && src.health <= 0) src.CritterDeath()

			//src.boredom_countdown = rand(5,10)
			src.target = user
			src.oldtarget_name = user.name
			src.task = "chasing"
		else
			src.visible_message("<span class='alert'><b>[user]</b> pets [src]!</span>", 1)
			playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 60, 1)
			src.visible_message("<span class='alert'><b>[src] laughs!</b></span>", 1)

	on_sleep()
		..()
		src.disappear()

	ChaseAttack(mob/M)
		if(prob(10))
			playsound(src.loc, 'sound/voice/animal/brullbar_scream.ogg', 75, 1)
			src.visible_message("<span class='alert'><b>[src] howls!</b></span>", 1)
			..()
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
			if(ismob(M))
				M.changeStatus("stunned", 2 SECONDS)
				M.changeStatus("weakened", 2 SECONDS)

	CritterAttack(mob/M) // nominating this for scariest goddamn critter 2013
		src.attacking = 1
		var/attack_delay = rand(10,30) // needs to attack more often, changed from 30

		if (isrobot(M))
			var/mob/living/silicon/robot/BORG = M
			if (!BORG.part_head)
				src.visible_message("<span class='alert'><B>[src]</B> sniffs at [BORG.name].</span>")
				sleep(1.5 SECONDS)
				src.visible_message("<span class='alert'><B>[src]</B> throws a tantrum and smashes [BORG.name] to pieces!</span>")
				playsound(src.loc, 'sound/voice/animal/brullbar_scream.ogg', 75, 1)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
				logTheThing(LOG_COMBAT, src, "gibs [constructTarget(BORG,"combat")] at [log_loc(src)].")
				BORG.gib()
				src.target = null
				src.boredom_countdown = 0
			else
				if (BORG.part_head.ropart_get_damage_percentage() >= 85)
					src.visible_message("<span class='alert'><B>[src]</B> grabs [BORG.name]'s head and wrenches it right off!</span>")
					playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 70, 1)
					playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
					BORG.compborg_lose_limb(BORG.part_head)
					sleep(1.5 SECONDS)
					src.visible_message("<span class='alert'><B>[src]</B> ravenously eats the mangled brain remnants out of the decapitated head!</span>")
					playsound(src.loc, 'sound/voice/animal/brullbar_maul.ogg', 80, 1)
					make_cleanable( /obj/decal/cleanable/blood,src.loc)
					src.target = null
				else
					src.visible_message("<span class='alert'><B>[src]</B> pounds on [BORG.name]'s head furiously!</span>")
					playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 50, 1)
					if (BORG.part_head.ropart_take_damage(rand(20,40),0) == 1)
						BORG.compborg_lose_limb(BORG.part_head)
					if (prob(33)) playsound(src.loc, 'sound/voice/animal/brullbar_scream.ogg', 75, 1)
					attack_delay = 5
		else
			if (boredom_countdown-- > 0)
				if(prob(70))
					src.visible_message("<span class='alert'><B>[src]</B> [pick("bites", "nibbles", "chews on", "gnaws on")] [src.target]!</span>")
					playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
					playsound(src.loc, 'sound/items/eatfood.ogg', 50, 1)
					random_brute_damage(target, 10,1)
					take_bleeding_damage(target, null, 5, DAMAGE_STAB, 1, get_turf(target))
					if(prob(40))
						playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 70, 1)
						src.visible_message("<span class='alert'><b>[src] laughs!</b></span>", 1)
				else
					src.visible_message("<span class='alert'><B>[src]</B> [pick("slashes", "swipes", "claws", "tears")] a chunk out of [src.target]!</span>")
					playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
					random_brute_damage(target, 20,1)
					take_bleeding_damage(target, null, 10, DAMAGE_CUT, 0, get_turf(target))
					playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
					playsound(src.loc, 'sound/voice/animal/brullbar_scream.ogg', 75, 1)
					src.visible_message("<span class='alert'><b>[src] howls!</b></span>", 1)
					if(!M.stat) M.emote("scream") // don't scream while dead/asleep

			else // flip the fuck out
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1)
				src.visible_message("<span class='alert'><b>[src]</b> slams into [src.target]!</span>")
				M.changeStatus("weakened", 2 SECONDS)
				frenzy(src.target)

			if (isdead(M)) // devour corpses
				src.visible_message("<span class='alert'><b>[src] devours [src.target]! Holy shit!</b></span>")
				playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				M.ghostize()
				new /obj/decal/fakeobjects/skeleton(M.loc)
				M.gib()
				src.target = null
			else if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)

		SPAWN(attack_delay)
			src.attacking = 0

	proc/appear()
		if (!invisibility)
			return
		src.icon_state = "brullbar_appear"
		src.invisibility = INVIS_NONE
		set_density(1)
		SPAWN(1.2 SECONDS)
			if(king)
				src.icon_state = "brullbarking"
			else
				src.icon_state = "brullbar"
			playsound(src.loc, 'sound/voice/animal/brullbar_scream.ogg', 85, 1)
			src.visible_message("<span class='alert'><B>[src]</B> howls!</span>")
		return

	proc/disappear()
		if (invisibility)
			return

		src.icon_state = "brullbar_melt"
		set_density(0)
		SPAWN(1.2 SECONDS)
			src.invisibility = INVIS_SPOOKY
			if(king)
				src.icon_state = "brullbarking"
			else
				src.icon_state = "brullbar"
		return

	proc/flail()
		if (flailing)
			return

		flailing = 25
		SPAWN(0)
			while(flailing-- > 0)
				src.pixel_x = rand(-2,2) * 2
				src.pixel_y = rand(-2,2) * 2
				src.set_dir(pick(alldirs))
				sleep(0.4 SECONDS)
			src.pixel_x = 0
			src.pixel_y = 0
			if(flailing < 0)
				flailing = 0


	// go crazy and make a huge goddamn mess
	proc/frenzy(mob/M)
		if (src.frenzied)
			return

		SPAWN(0)
			src.visible_message("<span class='alert'><b>[src] goes [pick("into a frenzy", "into a bloodlust", "berserk", "hog wild", "crazy")]!</b></span>")
			playsound(src.loc, 'sound/voice/animal/brullbar_maul.ogg', 80, 1)
			if(king)
				playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 80, 1)
				src.visible_message("<span class='alert'><b>[src] roars!</b></span>")
			src.set_loc(M.loc)
			src.frenzied = 20
			sleep(1 DECI SECOND)
			if(!flailing) src.flail()
			while(src.target && src.frenzied && src.alive && src.loc == M.loc )
				src.visible_message("<span class='alert'><b>[src] [pick("mauls", "claws", "slashes", "tears at", "lacerates", "mangles")] [src.target]!</b></span>")
				random_brute_damage(target, 10,1)
				take_bleeding_damage(target, null, 5, DAMAGE_CUT, 0, get_turf(target))
				if(prob(33)) // don't make quite so much mess
					bleed(target, 5, 5, get_step(src.loc, pick(alldirs)), 1)
				if(king && prob(33))
					bleed(target, 5, 5, get_step(src.loc, pick(alldirs)), 1)
				sleep(0.4 SECONDS)
				src.frenzied--
			src.frenzied = 0

////////////////
//////king brullbar, why not
///////////////

/obj/critter/brullbar/king
	name = "brullbar king"
	desc = "You should run."
	death_text = "%src% collapses in a heap!"
	health = 500
	icon_state = "brullbarking"
	king = 1

	skinresult = /obj/item/material_piece/cloth/kingbrullbarhide

	New()
		..()
		quality = 200 // for the limbs

	CritterDeath()
		..()
		playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 75, 1)
		playsound(src.loc, 'sound/voice/animal/brullbar_cry.ogg', 75, 1)

////////////////
////// e-egg?
///////////////

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/brullbar
	name = "brullbar egg"
	desc = "They lay eggs?!"
	critter_type = /obj/critter/brullbar
	warm_count = 100
	critter_reagent = "ice"
