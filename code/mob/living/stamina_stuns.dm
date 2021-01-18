/mob/
	var/list/stun_resist_mods = list()



//PLEASE ONLY EVER USE THESE TO MODIFY STAMINA. NEVER SET IT DIRECTLY.

//Returns current stamina
/mob/proc/get_stamina()
	return 0

/mob/living/get_stamina()
	if (!src.use_stamina) return
	return stamina

//Adds a stamina max modifier with the given key. This uses unique keys to allow for "categories" of max modifiers - so you can only have one food buff etc.
//If you get a buff of a category you already have, nothing will happen.
/mob/proc/add_stam_mod_max(var/key, var/value)
	return 0

/mob/living/add_stam_mod_max(var/key, var/value)
	if (!src.use_stamina) return
	if(!isnum(value)) return
	if(stamina_mods_max.Find(key)) return 0
	stamina_mods_max.Add(key)
	stamina_mods_max[key] = value
	return 1

//Removes a stamina max modifier with the given key.
/mob/proc/remove_stam_mod_max(var/key)
	return 0

/mob/living/remove_stam_mod_max(var/key)
	if (!src.use_stamina) return
	if(!stamina_mods_max.Find(key)) return 0
	stamina_mods_max.Remove(key)
	return 1

//Returns the total modifier for stamina max
/mob/proc/get_stam_mod_max()
	return 0

/mob/living/get_stam_mod_max()
	if (!src.use_stamina) return
	var/val = 0
	for(var/x in stamina_mods_max)
		val += stamina_mods_max[x]

	var/stam_mod_items = 0
	for (var/obj/item/C as() in src.get_equipped_items())
		stam_mod_items += C.getProperty("stammax")

	return (val + stam_mod_items)

//Adds a stamina regen modifier with the given key. This uses unique keys to allow for "categories" of regen modifiers - so you can only have one food buff etc.
//If you get a buff of a category you already have, nothing will happen.
/mob/proc/add_stam_mod_regen(var/key, var/value)
	return 0

/mob/living/add_stam_mod_regen(var/key, var/value)
	if (!src.use_stamina) return
	if(!isnum(value)) return
	if(stamina_mods_regen.Find(key)) return 0
	stamina_mods_regen.Add(key)
	stamina_mods_regen[key] = value
	return 1

//Removes a stamina regen modifier with the given key.
/mob/proc/remove_stam_mod_regen(var/key)
	return 0

/mob/living/remove_stam_mod_regen(var/key)
	if (!src.use_stamina) return
	if(!stamina_mods_regen.Find(key)) return 0
	stamina_mods_regen.Remove(key)
	return 1

//Returns the total modifier for stamina regen
/mob/proc/get_stam_mod_regen()
	return 0

/mob/living/get_stam_mod_regen()
	if (!src.use_stamina) return
	var/val = 0
	for(var/x in stamina_mods_regen)
		val += stamina_mods_regen[x]

	var/stam_mod_items = 0
	for (var/obj/item/C as() in src.get_equipped_items())
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

/mob/living/add_stamina(var/x as num)
	if(!src.use_stamina) return
	if(!isnum(x)) return
	if(prob(20) && ishellbanned(src)) return //Stamina regenerates 20% slower for you. RIP
	stamina = min(stamina_max, stamina + x)
	if(src.stamina_bar) src.stamina_bar.update_value(src)
	return

//Removes stamina
/mob/proc/remove_stamina(var/x)
	return

/mob/living/remove_stamina(var/x)
	if(!src.use_stamina) return
	if(!isnum(x)) return
	if(prob(4) && ishellbanned(src)) //Chances are this will happen during combat
		SPAWN_DBG(rand(5, 80)) //Detach the cause (hit, reduced stamina) from the consequence (disconnect)
			var/dur = src.client.fake_lagspike()
			sleep(dur)
			del(src.client)

	var/stam_mod_items = 0
	for (var/obj/item/C as() in src.get_equipped_items())
		stam_mod_items += C.getProperty("stamcost")

	var/percReduction = 0
	if(stam_mod_items)
		percReduction = (x * (stam_mod_items / 100))

	stamina = max(STAMINA_NEG_CAP, stamina - (x - percReduction) )
	src.stamina_bar?.update_value(src)
	return

/mob/living/carbon/human/remove_stamina(var/x)
	..()
	if (x >= 30 && src.hud && src.hud.stamina_back)
		flick("stamina_back", src.hud.stamina_back)

/mob/living/critter/remove_stamina(var/x)
	..()
	if (x >= 30 && src.hud && src.hud.stamina_back)
		flick("stamina_back", src.hud.stamina_back)


//Sets stamina
/mob/proc/set_stamina(var/x)
	return

/mob/living/set_stamina(var/x)
	if(!src.use_stamina) return
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
/mob/living/handle_stamina_crit(var/damage)
	if(!src.use_stamina) return
	damage = max(damage,10)
	damage *= 4
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
			src.visible_message("<span class='alert'>[src] collapses!</span>")
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

/mob/living/stamina_stun()
	if(!src.use_stamina) return
	if(src.stamina <= 0)
		var/chance = STAMINA_SCALING_KNOCKOUT_BASE
		chance += (src.stamina / STAMINA_NEG_CAP) * STAMINA_SCALING_KNOCKOUT_SCALER
		if(prob(chance))
			if(!src.getStatusDuration("weakened"))
				src.visible_message("<span class='alert'>[src] collapses!</span>")
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
	for (var/obj/item/C as() in src.get_equipped_items())
		if(C.hasProperty("disorient_resist"))
			res = C.getProperty("disorient_resist")
			if (res >= 100)
				return 100 //a singular item with resistance 100 or higher will block ALL
			. += res
		if(C.hasProperty("I_disorient_resist")) //cursed
			res = C.getProperty("I_disorient_resist")
			if (res >= 100)
				return 100 //a singular item with resistance 100 or higher will block ALL
			. += res


	.= clamp(.,0,90) //0 to 90 range

/mob/proc/get_disorient_protection_eye()
	.= 0

	var/res = 0
	for (var/obj/item/C as() in src.get_equipped_items())
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
	for (var/obj/item/C as() in src.get_equipped_items())
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
/mob/living/do_disorient(var/stamina_damage, var/weakened, var/stunned, var/paralysis, var/disorient = 60, var/remove_stamina_below_zero = 0, var/target_type = DISORIENT_BODY)
	if(!src.use_stamina) return ..()
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

/mob/living/silicon/do_disorient(var/stamina_damage, var/weakened, var/stunned, var/paralysis, var/disorient = 60, var/remove_stamina_below_zero = 0, var/target_type = DISORIENT_BODY)
	// Apply the twitching disorient animation for as long as the maximum stun duration is.
	src.changeStatus("cyborg-disorient", max(weakened, stunned, paralysis))
	. = ..()

//STAMINA UTILITY PROCS


/mob/proc/process_stamina(var/cost)
	return 1

/mob/living/process_stamina(var/cost)
	#if STAMINA_NO_ATTACK_CAP == 0
	// why
	// in what world is condition two not equivalent to condition one
	// there are literally two outcomes to this
	// if (true or true); and if (false or false)
	if(src.stamina <= cost || (src.stamina - cost) <= 0)
		boutput(src, STAMINA_EXHAUSTED_STR)
		return 0
	src.remove_stamina(cost)
	#else
	if(src.stamina > STAMINA_MIN_ATTACK)
		cost = min(cost,src.stamina - STAMINA_MIN_ATTACK)
		src.remove_stamina(cost)
	#endif
	return 1
