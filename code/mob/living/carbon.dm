
/mob/
	var/list/stun_resist_mods = list()


/mob/living/carbon/
	gender = MALE // WOW RUDE
	var/list/stomach_contents = list()
	var/last_eating = 0

	var/oxyloss = 0
	var/toxloss = 0
	var/brainloss = 0
	//var/brain_op_stage = 0.0
	//var/heart_op_stage = 0.0

	var/stamina = STAMINA_MAX
	var/stamina_max = STAMINA_MAX
	var/stamina_regen = STAMINA_REGEN
	var/stamina_crit_chance = STAMINA_CRIT_CHANCE
	var/list/stamina_mods_regen = list()
	var/list/stamina_mods_max = list()

	infra_luminosity = 4


//PLEASE ONLY EVER USE THESE TO MODIFY STAMINA. NEVER SET IT DIRECTLY.

//Returns current stamina
/mob/proc/get_stamina()
	return 0

/mob/living/carbon/get_stamina()
	return stamina

//Adds a stamina max modifier with the given key. This uses unique keys to allow for "categories" of max modifiers - so you can only have one food buff etc.
//If you get a buff of a category you already have, nothing will happen.
/mob/proc/add_stam_mod_max(var/key, var/value)
	return 0

/mob/living/carbon/add_stam_mod_max(var/key, var/value)
	if(!isnum(value)) return
	if(stamina_mods_max.Find(key)) return 0
	stamina_mods_max.Add(key)
	stamina_mods_max[key] = value
	return 1

//Removes a stamina max modifier with the given key.
/mob/proc/remove_stam_mod_max(var/key)
	return 0

/mob/living/carbon/remove_stam_mod_max(var/key)
	if(!stamina_mods_max.Find(key)) return 0
	stamina_mods_max.Remove(key)
	return 1

//Returns the total modifier for stamina max
/mob/proc/get_stam_mod_max()
	return 0

/mob/living/carbon/get_stam_mod_max()
	var/val = 0
	for(var/x in stamina_mods_max)
		val += stamina_mods_max[x]

	var/stam_mod_items = 0
	for(var/atom in src.get_equipped_items())
		var/obj/item/C = atom
		stam_mod_items += C.getProperty("stammax")

	return (val + stam_mod_items)

//Adds a stamina regen modifier with the given key. This uses unique keys to allow for "categories" of regen modifiers - so you can only have one food buff etc.
//If you get a buff of a category you already have, nothing will happen.
/mob/proc/add_stam_mod_regen(var/key, var/value)
	return 0

/mob/living/carbon/add_stam_mod_regen(var/key, var/value)
	if(!isnum(value)) return
	if(stamina_mods_regen.Find(key)) return 0
	stamina_mods_regen.Add(key)
	stamina_mods_regen[key] = value
	return 1

//Removes a stamina regen modifier with the given key.
/mob/proc/remove_stam_mod_regen(var/key)
	return 0

/mob/living/carbon/remove_stam_mod_regen(var/key)
	if(!stamina_mods_regen.Find(key)) return 0
	stamina_mods_regen.Remove(key)
	return 1

//Returns the total modifier for stamina regen
/mob/proc/get_stam_mod_regen()
	return 0

/mob/living/carbon/get_stam_mod_regen()
	var/val = 0
	for(var/x in stamina_mods_regen)
		val += stamina_mods_regen[x]

	var/stam_mod_items = 0
	for(var/atom in src.get_equipped_items())
		var/obj/item/C = atom
		stam_mod_items += C.getProperty("stamregen")
	return val


/mob/proc/add_stun_resist_mod(var/key, var/value)
	if(!isnum(value)) return
	if(stun_resist_mods.Find(key)) return 0
	stun_resist_mods.Add(key)
	stun_resist_mods[key] = value
	return 1

//Removes a stamina max modifier with the given key.
/mob/proc/remove_stun_resist_mod(var/key)
	if(!stun_resist_mods.Find(key)) return 0
	stun_resist_mods.Remove(key)
	return 1

//Returns the total modifier for stamina max
/mob/proc/get_stun_resist_mod()
	.= 0
	var/highest = 0
	for(var/x in stun_resist_mods)
		. += stun_resist_mods[x]
		if (stun_resist_mods[x] > highest)
			highest = stun_resist_mods[x]


	var/max_allowed = 80 //basically if we dont have a singular 100% or above protection moddifier, we wont allow the user to completely ignore stuns
	if (highest > 80)
		max_allowed = min(highest, 100)

	.= clamp(., 0, max_allowed)


//Restores stamina
/mob/proc/add_stamina(var/x)
	return

/mob/living/carbon/add_stamina(var/x as num)
	if(!isnum(x)) return
	if(prob(20) && ishellbanned(src)) return //Stamina regenerates 20% slower for you. RIP
	stamina = min(stamina_max, stamina + x)
	if(src.stamina_bar) src.stamina_bar.update_value(src)
	return

//Removes stamina
/mob/proc/remove_stamina(var/x)
	return

/mob/living/carbon/remove_stamina(var/x)
	if(!isnum(x)) return
	if(prob(4) && ishellbanned(src)) //Chances are this will happen during combat
		SPAWN_DBG(rand(5, 80)) //Detach the cause (hit, reduced stamina) from the consequence (disconnect)
			var/dur = src.client.fake_lagspike()
			SPAWN_DBG(dur)
				del(src.client)

	var/stam_mod_items = 0
	for(var/atom in src.get_equipped_items())
		var/obj/item/C = atom
		stam_mod_items += C.getProperty("stamcost")

	var/percReduction = 0
	if(stam_mod_items)
		percReduction = (x * (stam_mod_items / 100))

	stamina = max(STAMINA_NEG_CAP, stamina - (x - percReduction) )
	if(src.stamina_bar) src.stamina_bar.update_value(src)
	return

//Sets stamina
/mob/proc/set_stamina(var/x)
	return

/mob/living/carbon/set_stamina(var/x)
	if(!isnum(x)) return
	stamina = max(min(stamina_max, x), STAMINA_NEG_CAP)
	if(src.stamina_bar) src.stamina_bar.update_value(src)
	return

//PLEASE ONLY EVER USE THESE TO MODIFY STAMINA. NEVER SET IT DIRECTLY.


//STAMINA UTILITY PROCS

//Responsible for executing critical hits to stamina
/mob/proc/handle_stamina_crit(var/damage)
	.=0
//ddoub le dodbleu
/mob/living/carbon/handle_stamina_crit(var/damage)
	damage = max(damage,10)
	damage *= 4
	//playsound(src.loc, "sound/impact_sounds/Generic_Punch_1.ogg", 50, 1, -1)
	if(src.stamina >= 1 )
		#if STAMINA_CRIT_DROP == 1
		src.set_stamina(min(src.stamina,STAMINA_CRIT_DROP_NUM))
		#else
		src.set_stamina (max(0,src.stamina - damage))
		src.stamina_stun()
		#endif
		#if STAMINA_STUN_ON_CRIT == 1
		src.changeStatus("stunned", STAMINA_STUN_ON_CRIT_SEV)
		#endif
	else if(src.stamina <= 0)
		#if STAMINA_CRIT_DROP == 1
		src.set_stamina(min(src.stamina * 2,STAMINA_CRIT_DROP_NUM))
		#else
		src.set_stamina (max(0,src.stamina - damage))
		src.stamina_stun()\
		#endif
		#if STAMINA_STUN_ON_CRIT == 1
		src.changeStatus("stunned", STAMINA_STUN_ON_CRIT_SEV)
		#endif
		#if STAMINA_NEG_CRIT_KNOCKOUT == 1
		if(!src.getStatusDuration("weakened"))
			src.visible_message("<span style=\"color:red\">[src] collapses!</span>")
			src.changeStatus("weakened", (STAMINA_STUN_CRIT_TIME)*10)
		#endif
	stamina_stun() //Just in case.
	return

//Checks if mob should be stunned for being at or below 0 stamina and then does so.
//This is in a proc so we can easily instantly apply the stun from other areas of the game.
//For example: You'd put this on a weapon after it removes stamina to make sure the stun applies
//instantly and not on the next life tick.
/mob/proc/stamina_stun()
	return

/mob/living/carbon/stamina_stun()
	if(src.stamina <= 0)
		var/chance = STAMINA_SCALING_KNOCKOUT_BASE
		chance += (src.stamina / STAMINA_NEG_CAP) * STAMINA_SCALING_KNOCKOUT_SCALER
		if(prob(chance))
			if(!src.getStatusDuration("weakened"))
				src.visible_message("<span style=\"color:red\">[src] collapses!</span>")
				src.changeStatus("weakened", (STAMINA_STUN_TIME)*10)
				src.force_laydown_standup()
	return


//new disorient thing

#define DISORIENT_BODY 1
#define DISORIENT_EYE 2
#define DISORIENT_EAR 4

/mob/proc/get_disorient_protection()
	.= 0

	var/res = 0
	for(var/atom in src.get_equipped_items())
		var/obj/item/C = atom
		if(C.hasProperty("disorient_resist"))
			res = C.getProperty("disorient_resist")
			if (res >= 100)
				return 100 //a singular item with resistance 100 or higher will block ALL
			. += res

	.= clamp(.,0,90) //0 to 90 range

/mob/proc/get_disorient_protection_eye()
	.= 0

	var/res = 0
	for(var/atom in src.get_equipped_items())
		var/obj/item/C = atom
		if(C.hasProperty("disorient_resist_eye"))
			res = C.getProperty("disorient_resist_eye")
			if (res >= 100)
				return 100 //a singular item with resistance 100 or higher will block ALL
			. += res

	.= clamp(.,0,90) //90 max!

/mob/living/get_disorient_protection_eye()
	.= ..()

	if (. >= 100)
		return .

	if (organHolder)//factor in me eyes
		if (organHolder.left_eye)
			var/res = organHolder.left_eye.getProperty("disorient_resist_eye")
			if (res >= 100)
				return 100
			.+= res
		if (organHolder.right_eye)
			var/res = organHolder.right_eye.getProperty("disorient_resist_eye")
			if (res >= 100)
				return 100
			.+= res

	.= clamp(.,0,90)

/mob/proc/get_disorient_protection_ear()
	.= 0

	var/res = 0
	for(var/atom in src.get_equipped_items())
		var/obj/item/C = atom
		if(C.hasProperty("disorient_resist_ear"))
			res = C.getProperty("disorient_resist_ear")
			if (res >= 100)
				return 100 //a singular item with resistance 100 or higher will block ALL
			. += res

	.= clamp(.,0,90) //0 to 90 range


/mob/proc/force_laydown_standup() //the real force laydown lives in Life.dm
	.=0

/mob/proc/do_disorient(var/stamina_damage, var/weakened, var/stunned, var/paralysis, var/disorient = 60, var/remove_stamina_below_zero = 0, var/target_type = DISORIENT_BODY)
	.= 1
	if (stunned)
		src.changeStatus("stunned", stunned)
	if (weakened)
		src.changeStatus("weakened", weakened)
	if (paralysis)
		src.changeStatus("paralysis", paralysis)

	src.force_laydown_standup()

	if (src.canmove)
		.= 0

//Do stamina damage + disorient above 0 stamina. Stun/Weaken/Paralyze when we hit or drop below 0.
/mob/living/carbon/do_disorient(var/stamina_damage, var/weakened, var/stunned, var/paralysis, var/disorient = 60, var/remove_stamina_below_zero = 0, var/target_type = DISORIENT_BODY)
	var/protection = 0

	if (target_type & DISORIENT_BODY)
		protection = max (protection, get_disorient_protection())
	if (target_type & DISORIENT_EYE)
		protection =  max (protection, get_disorient_protection_eye())
	if (target_type & DISORIENT_EAR)
		protection =  max (protection, get_disorient_protection_ear())

	if (protection >= 100)
		return

	var/disorient_mult = 1 - (protection/100)
	var/stamdmg_mult = lerp(disorient_mult, 1, 0.25) // apply 3/4 the reduction effect to the stamina damage

	disorient *= disorient_mult
	stamina_damage *= stamdmg_mult

	if (remove_stamina_below_zero)
		src.remove_stamina(stamina_damage)
	else if (src.stamina > 0)
		src.remove_stamina(min(stamina_damage, src.stamina))

	if(src.stamina <= 0)
		.= 1
		if (! ..()) //stun failed, do a disorient!
			src.changeStatus("disorient", disorient)
	else
		.= 0
		src.changeStatus("disorient", disorient)

//STAMINA UTILITY PROCS


/mob/living/carbon/disposing()
	stomach_contents = null
	..()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.bioHolder && src.bioHolder.HasEffect("fat") && src.m_intent == "run")
			src.bodytemperature += 2

		//SLIP handling
		if (!src.throwing && !src.lying && isturf(NewLoc))
			var/turf/T = NewLoc
			if (T.turf_flags & MOB_SLIP)
				switch (T.wet)
					if (1)
						if (locate(/obj/item/clothing/under/towel) in T)
							src.inertia_dir = 0
							T.wet = 0
							return
						if (src.can_slip())
							src.pulling = null
							src.throwing = 1
							SPAWN_DBG(0) // this stops the entire server from crashing when SOMEONE (read: wonk) space lubes the entire station
								step(src, src.dir)
								src.throwing = 0
							boutput(src, "<span style=\"color:blue\">You slipped on the wet floor!</span>")
							playsound(T, "sound/misc/slip.ogg", 50, 1, -3)
							src.changeStatus("stunned", 2 SECONDS)
							src.changeStatus("weakened", 2 SECONDS)
							src.unlock_medal("I just cleaned that!", 1)
							src.force_laydown_standup()
						else
							src.inertia_dir = 0
							return
					if (2) //lube
						src.pulling = null
						src.changeStatus("weakened", 35)
						boutput(src, "<span style=\"color:blue\">You slipped on the floor!</span>")
						playsound(T, "sound/misc/slip.ogg", 50, 1, -3)
						/*
						SPAWN_DBG(0)
							step(src, src.dir)
							for (var/i = 4, i>0, i--)
								if (!isturf(src.loc) || !step(src, src.dir) || i == 1)
									src.throwing = 0
									break
						*/
						var/atom/target = get_edge_target_turf(src, src.dir)
						SPAWN_DBG(0) src.throw_at(target, 12, 1)
					if (3) // superlube
						src.pulling = null
						src.changeStatus("weakened", 6 SECONDS)
						playsound(T, "sound/misc/slip.ogg", 50, 1, -3)
						boutput(src, "<span style=\"color:blue\">You slipped on the floor!</span>")
						var/atom/target = get_edge_target_turf(src, src.dir)
						SPAWN_DBG(0) src.throw_at(target, 30, 1)
						random_brute_damage(src, 10)

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span style=\"color:red\">You hear something rumbling inside [src]'s stomach...</span>"), 2)
			var/obj/item/I = user.equipped()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				src.TakeDamage("chest", d, 0)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span style=\"color:red\"><B>[user] attacks [src]'s stomach wall with the [I.name]!</span>"), 2)
				playsound(user.loc, "sound/impact_sounds/Slimy_Hit_3.ogg", 50, 1)

				if(prob(get_brute_damage() - 50))
					src.gib()

/mob/living/carbon/gib(give_medal)
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		if (!isobserver(M))
			src.visible_message("<span style=\"color:red\"><B>[M] bursts out of [src]!</B></span>")
		else if (istype(M, /mob/dead/target_observer))
			M.cancel_camera()

		M.set_loc(src.loc)
	. = ..(give_medal)

/mob/living/carbon/proc/urinate()
	SPAWN_DBG(0)
		var/obj/item/reagent_containers/pee_target = src.equipped()
		if(istype(pee_target) && pee_target.reagents && pee_target.reagents.total_volume < pee_target.reagents.maximum_volume && pee_target.is_open_container())
			src.visible_message("<span style=\"color:red\"><B>[src] pees in [pee_target]!</B></span>")
			playsound(get_turf(src), "sound/misc/pourdrink.ogg", 50, 1)
			pee_target.reagents.add_reagent("urine", 20)
			return

		// possibly change the text colour to the gray emote text
		src.visible_message(pick("<B>[src]</B> unzips their pants and pees on the floor.", "<B>[src]</B> pisses all over the floor!", "<B>[src]</B> makes a big piss puddle on the floor."))

		var/obj/decal/cleanable/urine/U = make_cleanable(/obj/decal/cleanable/urine, src.loc)

		// Flag the urine stain if the pisser is trying to make fake initropidril
		if(src.reagents.has_reagent("tongueofdog"))
			U.thrice_drunk = 4
		else if(src.reagents.has_reagent("woolofbat"))
			U.thrice_drunk = 3
		else if(src.reagents.has_reagent("toeoffrog"))
			U.thrice_drunk = 2
		else if(src.reagents.has_reagent("eyeofnewt"))
			U.thrice_drunk = 1


		// check for being in sight of a working security camera

		if(seen_by_camera(src) && ishuman(src))

			// determine the name of the perp (goes by ID if wearing one)
			var/perpname = src.name
			if(src:wear_id && src:wear_id:registered)
				perpname = src:wear_id:registered
			// find the matching security record
			for(var/datum/data/record/R in data_core.general)
				if(R.fields["name"] == perpname)
					for (var/datum/data/record/S in data_core.security)
						if (S.fields["id"] == R.fields["id"])
							// now add to rap sheet

							S.fields["criminal"] = "*Arrest*"
							S.fields["mi_crim"] = "Public urination."

							break



/mob/living/carbon/swap_hand()
	src.hand = !src.hand

/mob/living/carbon/lastgasp()
	// making this spawn a new proc since lastgasps seem to be related to the mob loop hangs. this way the loop can keep rolling in the event of a problem here. -drsingh
	SPAWN_DBG(0)
		if (!src || !src.client) return														// break if it's an npc or a disconnected player
		var/enteredtext = winget(src, "mainwindow.input", "text")							// grab the text from the input bar
		if ((copytext(enteredtext,1,6) == "say \"") && length(enteredtext) > 5)				// check if the player is trying to say something
			winset(src, "mainwindow.input", "text=\"\"")									// clear the player's input bar to register death / unconsciousness
			var/grunt = pick("NGGH","OOF","UGH","ARGH","BLARGH","BLUH","URK")				// pick a grunt to append
			src.say(copytext(enteredtext,6,0) + "--" + grunt, ignore_stamina_winded = 1)	// say the thing they were typing and grunt

// cogwerks - fix for soulguard and revive
/mob/living/carbon/proc/remove_ailments()
	if (src.ailments)
		for (var/datum/ailment_data/disease/D in src.ailments)
			src.cure_disease(D)
		for (var/datum/ailment_data/malady/M in src.ailments)
			src.cure_disease(M)

/mob/living/carbon/full_heal()
	src.remove_ailments()
	src.take_toxin_damage(-INFINITY)
	src.take_oxygen_deprivation(-INFINITY)
	src.change_misstep_chance(-INFINITY)
	if (src.reagents)
		src.reagents.clear_reagents()
	..()

/mob/living/carbon/take_brain_damage(var/amount)
	if (..())
		return
#if ASS_JAM //pausing damage for timestop
	if(paused)
		src.pausedbrain = max(0,src.pausedbrain + amount)
		return
#endif
	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		amount *= -1

	src.brainloss = max(0,min(src.brainloss + amount,120))

	if (src.brainloss >= 120)
		// instant death, we can assume a brain this damaged is no longer able to support life
		src.visible_message("<span style=\"color:red\"><b>[src.name]</b> goes limp, their facial expression utterly blank.</span>")
		src.death()
		return

	return

/mob/living/carbon/take_toxin_damage(var/amount)
	if (..())
		return
#if ASS_JAM //pausing damage for timestop
	if(paused)
		src.pausedtox = max(0,src.pausedtox + amount)
		return
#endif
	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		amount *= -1

	if (src.bioHolder && src.bioHolder.HasEffect("resist_toxic"))
		src.toxloss = 0
		return

	src.toxloss = max(0,src.toxloss + amount)
	return

/mob/living/carbon/take_oxygen_deprivation(var/amount)
	if (..())
		return

	if (src.bioHolder && src.bioHolder.HasEffect("breathless"))
		src.oxyloss = 0
		return
#if ASS_JAM //pausing damage for timestop
	if(paused)
		src.pausedoxy = max(0,src.pausedoxy + amount)
#endif
	src.oxyloss = max(0,src.oxyloss + amount)
	return

/mob/living/carbon/get_brain_damage()
	return src.brainloss

/mob/living/carbon/get_toxin_damage()
	return src.toxloss

/mob/living/carbon/get_oxygen_deprivation()
	return src.oxyloss
