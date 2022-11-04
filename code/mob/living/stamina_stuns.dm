/mob/
	var/list/stun_resist_mods = list()



//PLEASE ONLY EVER USE THESE TO MODIFY STAMINA. NEVER SET IT DIRECTLY.

///Returns current stamina
/mob/proc/get_stamina()
	. = 0

/mob/living/get_stamina()
	if (!src.use_stamina)
		return
	. = stamina

///Adds a stamina max modifier with the given key. This uses unique keys to allow for "categories" of max modifiers - so you can only have one food buff etc.
///If you get a buff of a category you already have, nothing will happen.
/mob/proc/add_stam_mod_max(var/key, var/value)
	return 0

/mob/living/add_stam_mod_max(var/key, var/value)
	if (!src.use_stamina) return
	if(!isnum(value)) return
	if(key in stamina_mods_max)
		return 0
	stamina_mods_max.Add(key)
	stamina_mods_max[key] = value
	return 1

///Removes a stamina max modifier with the given key.
/mob/proc/remove_stam_mod_max(var/key)
	return 0

/mob/living/remove_stam_mod_max(var/key)
	if (!src.use_stamina) return
	if(!(key in stamina_mods_max))
		return 0
	stamina_mods_max.Remove(key)
	return 1

///Returns the total modifier for stamina max
/mob/proc/get_stam_mod_max()
	. = 0

/mob/living/get_stam_mod_max()
	if (!src.use_stamina) return
	var/val = 0
	for(var/x in stamina_mods_max)
		val += stamina_mods_max[x]

	var/stam_mod_items = 0
	for (var/obj/item/C as anything in src.get_equipped_items())
		stam_mod_items += C.getProperty("stammax")

	return (val + stam_mod_items)

//Returns the total modifier for stamina max
/mob/proc/get_stun_resist_mod()
	return min(GET_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST), clamp(GET_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX), 80, 100)) + 0

//Restores stamina
/mob/proc/add_stamina(var/x)
	return

/mob/living/add_stamina(var/x as num)
	if(!src.use_stamina) return
	if(!isnum(x)) return
	stamina = min(stamina_max, stamina + x)
	if(src.stamina_bar && src.stamina_bar.last_update != TIME)
		src.stamina_bar.update_value(src)
	return

//Removes stamina
/mob/proc/remove_stamina(var/x)
	return

/mob/living/remove_stamina(var/x)
	if(!src.use_stamina) return
	if(!isnum(x)) return

	var/stam_mod_items = 0
	for (var/obj/item/C as anything in src.get_equipped_items())
		stam_mod_items += C.getProperty("stamcost")

	var/percReduction = 0
	if(stam_mod_items)
		percReduction = (x * (stam_mod_items / 100))

	stamina = max(STAMINA_NEG_CAP, stamina - (x - percReduction) )
	if(src.stamina_bar?.last_update != TIME) src.stamina_bar?.update_value(src)
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
	stamina = clamp(x, STAMINA_NEG_CAP, stamina_max)
	if(src.stamina_bar) src.stamina_bar.update_value(src)
	return

//PLEASE ONLY EVER USE THESE TO MODIFY STAMINA. NEVER SET IT DIRECTLY.


//STAMINA UTILITY PROCS

///Responsible for executing critical hits to stamina
/mob/proc/handle_stamina_crit(var/damage)
	. = 0

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
		if(!src.getStatusDuration("weakened") && isalive(src))
			src.visible_message("<span class='alert'>[src] collapses!</span>")
			src.changeStatus("weakened", (STAMINA_STUN_CRIT_TIME) SECONDS)
		#endif
	stamina_stun() //Just in case.
	return


/**
 * Checks if mob should be stunned for being at or below 0 stamina and then does so.
 *
 * This is in a proc so we can easily instantly apply the stun from other areas of the game.
 *
 * For example: You'd put this on a weapon after it removes stamina to make sure the stun applies
 * instantly and not on the next life tick.
 */
/mob/proc/stamina_stun()
	return

/mob/living/stamina_stun(stunmult = 1)
	if(!src.use_stamina) return
	if(src.stamina <= 0)
		var/chance = STAMINA_SCALING_KNOCKOUT_BASE
		chance += (src.stamina / STAMINA_NEG_CAP) * STAMINA_SCALING_KNOCKOUT_SCALER
		if(prob(chance))
			if(!src.getStatusDuration("weakened") && isalive(src))
				src.visible_message("<span class='alert'>[src] collapses!</span>")
				src.changeStatus("weakened", (STAMINA_STUN_TIME * stunmult) SECONDS)
				src.force_laydown_standup()

//new disorient thing

#define DISORIENT_NONE 0
#define DISORIENT_BODY 1
#define DISORIENT_EYE 2
#define DISORIENT_EAR 4

/mob/proc/get_disorient_protection()
	return min(GET_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY), clamp(GET_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY_MAX), 90, 100)) + 0

/mob/proc/get_disorient_protection_eye()
	return min(GET_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_EYE), clamp(GET_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_EYE_MAX), 90, 100)) + 0

/mob/proc/get_disorient_protection_ear()
	return min(GET_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_EAR), clamp(GET_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_EAR_MAX), 90, 100)) + 0


/mob/proc/force_laydown_standup() //the real force laydown lives in Life.dm
	.=0

/mob/proc/do_disorient(var/stamina_damage, var/weakened, var/stunned, var/paralysis, var/disorient = 60, var/remove_stamina_below_zero = 0, var/target_type = DISORIENT_BODY, stack_stuns = 1)
	.= 1
	if (stunned)
		if(stack_stuns)
			src.changeStatus("stunned", stunned)
		else if(stunned >= src.getStatusDuration("stunned"))
			src.setStatus("stunned", stunned)
	if (weakened)
		if(stack_stuns)
			src.changeStatus("weakened", weakened)
		else if(weakened >= src.getStatusDuration("weakened"))
			src.setStatus("weakened", weakened)
	if (paralysis)
		if(stack_stuns)
			src.changeStatus("paralysis", paralysis)
		else if(paralysis >= src.getStatusDuration("paralysis"))
			src.setStatus("paralysis", paralysis)

	src.force_laydown_standup()

	if (src.canmove)
		.= 0

//Do stamina damage + disorient above 0 stamina. Stun/Weaken/Paralyze when we hit or drop below 0.
/mob/living/do_disorient(var/stamina_damage, var/weakened, var/stunned, var/paralysis, var/disorient = 60, var/remove_stamina_below_zero = 0, var/target_type = DISORIENT_BODY, stack_stuns = 1)
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
	var/stamdmg_mult = erp(disorient_mult, 1, 0.25) // apply 3/4 the reduction effect to the stamina damage

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

/mob/living/silicon/do_disorient(var/stamina_damage, var/weakened, var/stunned, var/paralysis, var/disorient = 60, var/remove_stamina_below_zero = 0, var/target_type = DISORIENT_BODY, stack_stuns = 1)
	// Apply the twitching disorient animation for as long as the maximum stun duration is.
	src.changeStatus("cyborg-disorient", max(weakened, stunned, paralysis, disorient))
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
