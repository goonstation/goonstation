/obj/critter/yeti
	name = "space yeti"
	desc = "Well-known as the single most aggressive, dangerous and hungry thing in the universe."
	icon_state = "yeti"
	density = 1
	health = 75
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 1
	firevuln = 3
	brutevuln = 1
	angertext = "starts chasing" // comes between critter name and target name
	butcherable = BUTCHER_ALLOWED
	chase_text = "punches out"

	skinresult = /obj/item/material_piece/cloth/leather
	max_skins = 2

	New()
		..()
		src.atk_delay = 4
		src.seek_target()

	seek_target()
		src.anchored = UNANCHORED
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (C.health < 0) continue
			if (C.name == src.attacker || iscarbon(C) || issilicon(C)) src.attack = 1 //If the living mob C attacked the yeti set attack flag to true
			if (src.attack)  //If attack flag was set, attack this target
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message(SPAN_COMBAT("<b>[src]</b> [src.angertext] [src.target]!"))
				playsound(src.loc, pick('sound/voice/animal/YetiGrowl.ogg'), 40, 0)
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 40, 1, -1)
		M.changeStatus("stunned", 10 SECONDS)
		M.changeStatus("knockdown", 10 SECONDS)

	CritterAttack(mob/M)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/parts/targetLimb = pickTargetLimb(H)
			if(targetLimb)
				src.attacking = 0
				src.visible_message(SPAN_COMBAT("<b>[src]</b> bites [targetLimb] right off!'"))
				random_brute_damage(H, 25)
				targetLimb.remove(0)
				H.update_body()
				M.emote("scream")
				bleed(H, 20, 30)
				targetLimb.delete()
				return

		//Instakill code. Happens when there are no more limbs to chew.
		//I want to rework this so the yeti keeps the heads as a trophy and he drops them once dead
		src.attacking = 1
		src.visible_message(SPAN_COMBAT("<B>[src]</B> devours the rest of [M] in one bite!"))
		logTheThing(LOG_COMBAT, M, "was devoured by [src] at [log_loc(src)].") // Some logging for instakill critters would be nice (Convair880).
		playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
		M.remove()
		src.task = "thinking"
		src.seek_target()
		src.attacking = 0
		playsound(src.loc, pick('sound/voice/burp_alien.ogg'), 50, 0)

		sleeping = 1

	proc/pickTargetLimb(var/mob/living/carbon/human/H)
		if(!H)
			return null
		var/list/part_list = list("l_arm", "r_arm", "l_leg", "r_leg")

		while(length(part_list) > 0)
			var/current_part = pick(part_list)
			part_list -= current_part
			var/obj/item/parts/bodypart = H.limbs.get_limb(current_part)
			if(bodypart && !istype(bodypart, /obj/item/parts/robot_parts)) //Quick check for robolimbs. It may be wrong, limb check examples give me headaches
				return bodypart
		return null


/obj/critter/yeti/super
	name = "super space yeti"
	desc = "Well-known as the single most aggressive, dangerous, intelligent, sturdy and hungry thing in the universe."
	health = 225
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY

/obj/critter/bat
	name = "bat"
	desc = "skreee!"
	icon_state = "bat"
	density = 1
	health = 5
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	atk_brute_amt = 1
	crit_brute_amt = 2
	atk_text = "bites"
	chase_text = "flaps into"
	crit_text = "really sinks its teeth into"


	var/blood_volume = 0		//This will count all the blood that Dr. Acula has fed on. Cheaper than having a reagent_holder holding blood I suppose
	var/atom/drink_target		//this would be the mob or obj/item/reagent_container that contains blood that we drink from
	var/last_drink				//world.time last time this bat drank blood. Just so that they don't just drink a whole 300u of an iv bag without prompting in under a minute.
	var/sips_taken = 0			//for calculating how many times a bat should drink at a souce before they are satiated for a time.
	var/const/sips_to_take = 5	//amount of sips of blood a bat will take from a source of blood.
	var/const/blood_sip_amt = 20	//amount of blood a single sip this bat takes contains.


	mouse_drop(atom/over_object as mob|obj)
		//if this bat is attacking/chasing someone, they won't stop just because you point at blood. Come on.
		if (src.target)
			return ..()

		if (src.task == "wandering" || src.task == "thinking")
			if (ishuman(over_object) && usr == over_object)
				var/mob/living/carbon/human/H = over_object
				if (H && !H.restrained() && !H.stat && in_interact_range(src, H))
					src.task = "drink mob"
					src.drink_target = H
					src.set_loc(H.loc)
					src.visible_message("[usr] offers up [his_or_her(usr)] arm to feed [src].")
					if (prob(30))
						take_bleeding_damage(usr, null, 5, DAMAGE_CUT, 0, get_turf(src))
						src.visible_message(SPAN_ALERT("<B>Whoops, looks like [src] bit down a bit too hard."))

			//stand next to bat, and point towards some blood, the bat will try to drink it
			else if (istype(over_object,/obj/item/reagent_containers/) && BOUNDS_DIST(usr, src) == 0)
				src.task = "chasing blood"
				src.drink_target = over_object
				src.visible_message("[usr] gestures towards [over_object] to try to get [src] to drink from it.")
		else
			boutput(usr, "[src] looks a bit too preoccupied for you to direct it anywhere.")
			return ..()

	//stolen first part from the seek_target in parent that seeks for food/snack. in here we'll search for reagent containers with blood
	proc/seek_blood()
		if (src.target)
			src.task = "chasing"
			return 0

		//gotta wait 1 min from the last drink before the bat goes looking for blood on its own again.
		if (last_drink+600 > world.time)
			return 0

		for (var/obj/fluid/F in view(src.seekrange,src))
			if (F.name == "blood")
				src.drink_target = F
				src.task = "chasing blood"
				return 1

		for (var/obj/item/reagent_containers/S  in view(src.seekrange,src))
			if (S.reagents && S.reagents.has_reagent("blood"))
				src.drink_target = S
				src.task = "chasing blood"
				return 1
		return 0

	proc/drink_blood(var/atom/target)
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (H.blood_volume < blood_sip_amt)
				H.blood_volume = 0
			else
				H.blood_volume -= blood_sip_amt
				src.blood_volume += blood_sip_amt*2			//fresh blood is the quenchiest. Bats get more blood points this way
			src.health += 2

		else if (istype(target,/obj/item/reagent_containers/))
			var/obj/item/reagent_containers/container = target
			container.reagents.remove_reagent("blood", blood_sip_amt)
			blood_volume += blood_sip_amt
			src.health ++

		else if (istype(target,/obj/fluid))
			var/obj/fluid/F = target
			if (F.group)
				F.group.queued_drains += 1
				F.group.last_drain = get_turf(F)
				if (!F.group.draining)
					F.group.add_drain_process()
			blood_volume += max(blood_sip_amt, F.group.amt_per_tile)
			src.health ++

		else return 0

		if (sips_taken == 0 || prob(80))
			playsound(src.loc,'sound/items/drink.ogg', rand(10,50), 1)
		// if (prob(20))
		eat_twitch(src)

		last_drink = world.time
		sips_taken++
		if (sips_taken >= sips_to_take)
			src.task = "thinking"
			src.visible_message("[src]'s finishes drinking blood from [drink_target] for now. That cutie looks pretty satisfied.")
			src.drink_target = null
			src.sips_taken = 0
		return 1



	//overriding ai_think, adding new switch cases for bats. If these new ones (or overridden "think") get hit, special action happens here and we return. otherwise call parent.
	ai_think()
		switch (task)
			if ("thinking")
				src.attack = 0
				src.target = null
				walk_to(src,0)

				if (seek_blood()) return 1
				if (src.aggressive) seek_target()
				if (src.wanderer && src.mobile && !src.target) src.task = "wandering"
				return 0

			if ("chasing blood")
				if (!drink_target || !isobj(drink_target) || GET_DIST(src, src.drink_target) > 3)
					src.task = "thinking"
					drink_target = null
				else if (GET_DIST(src, src.drink_target) <= 0)
					src.task = "drink obj"
				else
					walk_to(src, src.drink_target,0,4)
				return 0

			if ("drink obj")
				if (!drink_target || GET_DIST(src, src.drink_target) > 0)
					src.task = "thinking"
				else
					drink_blood(drink_target)
				return 0

			if ("drink mob")
				if (!src.drink_target || GET_DIST(src, src.drink_target) > src.attack_range)
					src.task = "thinking"
				else
					drink_blood(drink_target)
				return 0
		..()


	CritterDeath()
		..()
		src.reagents?.add_reagent("woolofbat", 50, null)
		return

	CritterAttack(mob/M)
		drink_blood(M)//steal blood
		if (prob(20))
			take_bleeding_damage(usr, null, 5, DAMAGE_CUT, 0, get_turf(src))
		..()

	Move()
		if(prob(15))
			playsound(src.loc, "rustle", 10, 1)
		. = ..()

/obj/critter/bat/doctor
	name = "Dr. Acula"
	desc = "If you ask nicely he might even write you a preskreeeption!"
	icon_state = "batdoctor"
	health = 30
	generic = 0
	is_pet = 2

	drink_blood(var/atom/target)
		..()
		JOB_XP(target, "Medical Doctor", 1)


// A slightly scarier (but still cute) bat for vampires

/obj/critter/bat/buff
	name = "angry bat"
	desc = "It doesn't look too happy!"
	icon_state = "scarybat"
	health = 25
	aggressive = 1
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	brutevuln = 0.7
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	seekrange = 5
	density = 1 // so lasers can hit them
	angertext = "screeches at"
	atk_brute_amt = 4
	crit_brute_amt = 8
	atk_text = "bites and claws at"

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
		if (prob(30)) M.changeStatus("knockdown", 2 SECONDS)

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/bat
	name = "bat egg"
	critter_type = /obj/critter/bat
