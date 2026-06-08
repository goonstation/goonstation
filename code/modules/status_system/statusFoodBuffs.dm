//Contains all status effects of the food group.

//ideas :
// bad breath (speaking makes others vomit)
// magboots
// slime

/// Special wrapper to add food status effects, due to special overriding and duration behavior.
/mob/living/proc/add_food_bonus(var/id, var/obj/item/reagent_containers/food/snacks/eaten)
	if(id)

		/*
		Sorry about this findtext junk. Kinda needed while we're still working with just IDs,
		can't implement a priority system on the datums unless we're passing those around... could do an initial() thing for good perf with those tho
		*/

		// We don't want the 'small' version to override the 'normal' or 'big' version
		if (findtextEx(id,"_small"))
			var/id_regular = copytext(id, 1, length(id)-5)
			if (src.hasStatus(id_regular) || src.hasStatus("[id_regular]_big"))
				return
		else
			//bleh. We don't want the 'normal' version to override the 'big' version.
			if (src.hasStatus("[id]_big"))
				return
			else if (findtextEx(id,"_big"))
				var/id_no_big = copytext(id, 1, length(id)-3)
				if (src.hasStatus(id_no_big))
					src.delStatus(id_no_big)

		var/bite_time = (1 MINUTE)
		if (src.reagents && src.reagents.has_reagent("THC"))
			bite_time = (2 MINUTES)
		if (eaten)
			if (eaten.quality >= 5)
				bite_time *= 2
			else if (eaten.quality <= 0.5)
				bite_time *= 0.3

		src.changeStatus(id, bite_time)


/datum/statusEffect/simplehot/foodBrute
	id = "food_brute"
	name = "Food HoT (Brute)"
	icon_state = "hot_brute"
	exclusiveGroup = "Food"
	heal_brute = 0.26
	maxDuration = 6000
	unique = 1
	tickSpacing = 20

	getTooltip()
		. = "Healing [heal_brute] brute damage every [tickSpacing/(1 SECOND)] sec."
	getChefHint()
		. = "Heals [heal_brute] brute damage every [tickSpacing/ (1 SECOND)] sec."

/datum/statusEffect/simplehot/foodTox
	id = "food_tox"
	name = "Food HoT (Toxin)"
	icon_state = "hot_tox"
	exclusiveGroup = "Food"
	heal_tox = 0.26
	maxDuration = 6000
	unique = 1
	tickSpacing = 20

	getTooltip()
		. = "Healing [heal_tox] toxin damage every [tickSpacing/(1 SECOND)] sec."

	getChefHint()
		. = "Heals [heal_tox] toxin damage every [tickSpacing/ (1 SECOND)] sec."

/datum/statusEffect/simplehot/foodBurn
	id = "food_burn"
	name = "Food HoT (Burn)"
	icon_state = "hot_burn"
	exclusiveGroup = "Food"
	heal_burn = 0.26
	maxDuration = 6000
	unique = 1
	tickSpacing = 20

	getTooltip()
		. = "Healing [heal_burn] burn damage every [tickSpacing/(1 SECOND)] sec."

	getChefHint()
		. = "Heals [heal_burn] burn damage every [tickSpacing/ (1 SECOND)] sec."

/datum/statusEffect/simplehot/foodAll
	id = "food_all"
	name = "Food HoT (All)"
	icon_state = "hot_all"
	exclusiveGroup = "Food"
	heal_burn = 0.086
	heal_tox = 0.086
	heal_brute = 0.086
	maxDuration = 6000
	unique = 1
	tickSpacing = 20

	getTooltip()
		. = "Healing 0.26 damage spread across Brute/Burn/Toxin damage every [tickSpacing/(1 SECOND)] sec."

	getChefHint()
		. = "Heals 0.26 damage spread across Brute/Burn/Toxin damage every [tickSpacing/ (1 SECOND)] sec."

/datum/statusEffect/foodcold
	id = "food_cold"
	name = "Food (Cold)"
	desc = "Cold food is cooling you down."
	icon_state = "cold"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	var/tickCount = 0
	var/tickSpacing = 20 //Time between ticks.

	getChefHint()
		. = "Decreases the consumer's body temperature."


	onUpdate(timePassed)
		tickCount += timePassed
		var/times = (tickCount / tickSpacing)
		if(times >= 1 && ismob(owner))
			tickCount -= (round(times) * tickSpacing)
			var/mob/M = owner
			M.changeBodyTemp(-2 KELVIN * times, min_temp = M.base_body_temp + 3)

/datum/statusEffect/foodwarm
	id = "food_warm"
	name = "Food (Warm)"
	desc = "Warm food is heating you up."
	icon_state = "warm"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	var/tickCount = 0
	var/tickSpacing = 20 //Time between ticks.

	getChefHint()
		. = "Incrases the consumer's body temperature."

	onUpdate(timePassed)
		tickCount += timePassed
		var/times = (tickCount / tickSpacing)
		if(times >= 1 && ismob(owner))
			tickCount -= (round(times) * tickSpacing)
			var/mob/M = owner
			M.changeBodyTemp(6 KELVIN * times, max_temp = M.base_body_temp + 8)

/datum/statusEffect/staminaregen/food
	id = "food_refreshed"
	name = "Food (Refreshed)"
	desc = ""
	icon_state = "stam+"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1
	change = 2.2

	big
		name = "Food (Refreshed+)"
		id = "food_refreshed_big"
		change = 5

	getTooltip()
		. = "Your stamina regen is increased by [change]."

	getChefHint()
		. = "Increases stamina regen by [change]."

/datum/statusEffect/foodstaminamax
	id = "food_energized"
	name = "Food (Energized)"
	desc = ""
	icon_state = "stam+"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1
	var/change = 18

	big
		name = "Food (Energized+)"
		id = "food_energized_big"
		change = 40

	getTooltip()
		. = "Your max. stamina is increased by [change]."

	getChefHint()
		. = "Increases max. stamina by [change]."

	onAdd(optional=null)
		. = ..()
		if(hascall(owner, "add_stam_mod_max"))
			owner:add_stam_mod_max("food_bonus", change)

	onRemove()
		. = ..()
		if(hascall(owner, "remove_stam_mod_max"))
			owner:remove_stam_mod_max("food_bonus")

/datum/statusEffect/maxhealth/food
	id = "food_hp_up"
	name = "Food (HP++)"
	desc = ""
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1
	change = 20

	small
		name = "Food (HP+)"
		id = "food_hp_up_small"
		change = 10

	big
		name = "Food (HP+++)"
		id = "food_hp_up_big"
		change = 40

	getTooltip()
		. = "Your max. health is increased by [change]."

	getChefHint()
		. = "Increases max. health by [change]"

	onAdd(optional=null)
		. = ..(change)

	onChange(optional=null)
		. = ..(change)


/datum/statusEffect/deep_fart
	id = "food_deep_fart"
	name = "Food (Gassy)"
	desc = "You feel gassy."
	visible = FALSE
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	getChefHint()
		. = "Makes the consumer feel more gassy."

/datum/statusEffect/deep_burp
	id = "food_deep_burp"
	name = "Food (Gross Burps)"
	desc = "Your stomach feels gassy."
	visible = FALSE
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	getChefHint()
		. = "Makes the consumer's stomach feel more gassy."

/datum/statusEffect/food_cat_eyes
	id = "food_cateyes"
	name = "Food (Night Vision)"
	desc = "Your vision feels improved."
	icon_state = "cateyes"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	getChefHint()
		. = "Improves the consumer's vision in dark spaces"

/datum/statusEffect/fire_burp
	id = "food_fireburp"
	name = "Food (Fire Burps)"
	desc = "Your stomach is flaming hot!"
	icon_state = "fireburp"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	var/temp = 1200
	var/range = 4
	var/static/durationLoss = 500

	big
		name = "Food (Fire Burps+)"
		id = "food_fireburp_big"
		temp = 1800
		range = 6

	getChefHint()
		. = "Creates fire in the consumer's stomach."

	proc/cast()
		var/turf/T = get_step(owner,owner.dir)
		var/range_breath = 1
		while((GET_DIST(owner,T) < range) && (range_breath < 20))// range is used for the range the fireburp can reach from the caster.
			T = get_step(T,owner.dir)
			range_breath ++ //range_breath is used to make sure the loop doesn't stay active too long and lag the game if something messes up range.
		var/list/affected_turfs = getline(owner, T)

		owner.visible_message(SPAN_ALERT("<b>[owner] burps a stream of fire!</b>"))
		playsound(owner.loc, 'sound/effects/mag_fireballlaunch.ogg', 30, 0)

		var/turf/currentturf
		var/turf/previousturf
		for(var/turf/F in affected_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density || istype(currentturf, /turf/space))
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				break
			if (F == get_turf(owner))
				continue
			if (GET_DIST(owner,F) > range)
				continue
			fireflash(F,0.5,temp, chemfire = CHEM_FIRE_RED)

		//reduce duration
		src.duration -= min(durationLoss,src.duration)
		if(src.duration <= 0)//without this check, it will get stuck at 0 and never go away.
			if(src.owner)
				src.owner.delStatus(src)

/datum/statusEffect/explosion_resist
	id = "food_explosion_resist"
	name = "Food (Sturdy)"
	desc = "Your joints feel sturdy, as if they are more resistant to popping off. Uh."
	icon_state = "explosion_resist"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	getChefHint()
		. = "Increases resilience of the joints, making them somehow more resistant to \"Popping Off\"..."

	onAdd(optional = 10)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			APPLY_ATOM_PROPERTY(M, PROP_MOB_EXPLOPROT, src, optional)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_EXPLOPROT, src)

/datum/statusEffect/disease_resist
	id = "food_disease_resist"
	name = "Food (Cleanse)"
	desc = "You are more resistant to disease."
	icon_state = "disease_resist"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	getChefHint()
		. = "Strengthens the body's resilience to diseases"

/datum/statusEffect/rad_resist
	id = "food_rad_resist"
	name = "Food (Rad-Wick)"
	desc = "You are more resistant to radiation."
	icon_state = "rad_resist"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	getChefHint()
		. = "Strengthens the body's resistance to radiation."

	onAdd(optional = 80)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			APPLY_ATOM_PROPERTY(M, PROP_MOB_RADPROT_INT, src, optional)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_RADPROT_INT, src)

/datum/statusEffect/space_farts
	id = "food_space_farts"
	name = "Food (Fart Thrust)"
	desc = "Farts in space provide maximum thrust."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	getChefHint()
		. = "Increase strengths of farts as to provide thrust."

/datum/statusEffect/bad_breath
	id = "food_bad_breath"
	name = "Food (Bad Breath)"
	desc = "You have extremely smelly breath."
	icon_state = "badbreath"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	getChefHint()
		. = "Gives the consumer an absolutely terrible breath smell."

	onAdd()
		. = ..()
		RegisterSignal(owner, COMSIG_ATOM_SAY, PROC_REF(smell_breath))

	onRemove()
		UnregisterSignal(owner,COMSIG_ATOM_SAY)
		. = ..()

	proc/smell_breath()
		for (var/mob/living/L in oview(2, owner))
			if (prob(50))
				continue

			boutput(L, SPAN_ALERT("Good lord, [owner]'s breath smells bad!"))
			L.nauseate(1)

/datum/statusEffect/slimy
	id = "food_slimy"
	name ="Food (Slimy)"
	desc = "You're oozing..."
	maxDuration = 600
	icon_state = "-"
	unique = 1

	onUpdate(timePassed)
		dropSweat("slime", 5, 5, sweatpools=TRUE)

/datum/statusEffect/sweaty
	id = "food_sweaty"
	name = "Food (Sweaty)"
	desc = "You feel sweaty!"
	icon_state = "sweaty"
	exclusiveGroup = "Food"
	maxDuration = 900
	unique = 1

	var/sweat_adjective = "" // used for getChefHint()

	onUpdate(timePassed)
		dropSweat("water")

	big
		name = "Food (Sweaty+)"
		id = "food_sweaty_big"
		desc = "You feel really sweaty!"
		sweat_adjective = "REALLY "
		maxDuration = 600

		onUpdate(timePassed)
			dropSweat("water", 5, 10, sweatpools=TRUE)

	bigger
		name ="Food (Sweaty++)"
		id = "food_sweaty_bigger"
		desc = "You're drowning in sweat!"
		sweat_adjective = "RIDICULOUSLY "
		maxDuration = 300

		onUpdate(timePassed)
			dropSweat("water", 15, 35, sweatpools=TRUE)

	getChefHint()
		. = "Makes the consumer [sweat_adjective]sweaty."

/datum/statusEffect/brainfood
	id = "brain_food"
	name = "Brain Food"
	desc = "Slowly restore brain damage."
	icon_state = "+"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1
	visible = TRUE

	var/tickCount = 0
	var/tickSpacing = 20 //Time between ticks.

	onUpdate(timePassed)
		tickCount += timePassed
		var/times = (tickCount / tickSpacing)
		if(times >= 1 && ismob(owner))
			tickCount -= (round(times) * tickSpacing)
			for(var/i in 1 to times)
				var/mob/M = owner
				M.take_brain_damage(-1)
		return

	ithillid
		id = "brain_food_ithillid"

		onAdd(optional)
			. = ..()
			var/mob/living/carbon/human/H = owner
			if(!(istype(H) && istype(H.mutantrace, /datum/mutantrace/ithillid)))
				visible = FALSE
				duration = 0

/datum/statusEffect/full
	id = "full"
	name = "Full"
	desc = "Your stomach is completely full!"
	icon_state = "stomach"
	unique = TRUE
