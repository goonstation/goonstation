//Contains all status effects of the food group.

//ideas :

// bad breath (speaking makes others vomit)

// magboots

// slime

/mob/living/proc/add_food_bonus(var/id, var/obj/item/reagent_containers/food/snacks/eaten)
	if(id)
		//bleh. We don't want the 'tiny' version to override the 'big' version.
		if (src.hasStatus("[id]_big"))
			return
		else if (findtextEx(id,"_big"))
			var/id_no_big = copytext(id, 1, length(id)-3)
			if (src.hasStatus(id_no_big))
				src.delStatus(id_no_big)

		var/bite_time = 600
		if (src.reagents && src.reagents.has_reagent("THC"))
			bite_time = 1200
		if (eaten)
			if (eaten.quality >= 5)
				bite_time *= 2
			else if (eaten.quality <= 0.5)
				bite_time *= 0.3

		src.changeStatus(id, bite_time)

/mob/living/proc/handle_digestion(var/mult = 1)
	if (src.stomach_process && src.stomach_process.len)
		for(var/obj/item/reagent_containers/food/snacks/bite/B in stomach_process)
			B.process_stomach(src, (1 / stomach_process.len) * mult) //1 units processed per Life() tick. Takes an even amt of reagents from all stomach contents

//TODO MOVE
/mob/living/proc/handle_skinstuff(var/mult = 1)
	if (src.skin_process && src.skin_process.len)

		//you absorb shit faster if you have lots of patches stacked
		//gives patches a way to heal quickly if you slap on a whole bunch, also makes long heals over time less viable

		var/multi_process_mult = skin_process.len > 1 ? (skin_process.len * 1.5) : 1
		var/use_volume = 0.35 * mult * multi_process_mult

		for(var/atom in skin_process)
			var/atom/A = atom

			if (A.loc != src)
				skin_process -= A
				continue

			if (A.reagents && A.reagents.total_volume)
				A.reagents.reaction(src, TOUCH, react_volume = use_volume, paramslist = (A.reagents.total_volume == A.reagents.maximum_volume) ? 0 : list("silent", "nopenetrate"))
				A.reagents.trans_to(src, use_volume/2)
				A.reagents.remove_any(use_volume/2)
			else
				if (A.reagents.total_volume <= 0)
					src.skin_process -= A //disposing will do this too but whatever
					qdel(A)


/mob/living/vomit(var/nutrition=0, var/specialType=null)
	..()
	if (src.stomach_process && src.stomach_process.len)
		var/obj/gross = pick(src.stomach_process)
		src.stomach_process -= gross
		gross.loc = src.loc
		return gross



/datum/statusEffect/simplehot/foodBrute
	id = "food_brute"
	name = "Food HoT (Brute)"
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	heal_brute = 0.26
	maxDuration = 6000
	unique = 1
	tickSpacing = 20

	getTooltip()
		return "Healing [heal_brute] brute damage every [tickSpacing/10] sec."

/datum/statusEffect/simplehot/foodTox
	id = "food_tox"
	name = "Food HoT (Toxin)"
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	heal_tox = 0.26
	maxDuration = 6000
	unique = 1
	tickSpacing = 20

	getTooltip()
		return "Healing [heal_tox] toxin damage every [tickSpacing/10] sec."

/datum/statusEffect/simplehot/foodBurn
	id = "food_burn"
	name = "Food HoT (Burn)"
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	heal_burn = 0.26
	maxDuration = 6000
	unique = 1
	tickSpacing = 20

	getTooltip()
		return "Healing [heal_burn] burn damage every [tickSpacing/10] sec."

/datum/statusEffect/simplehot/foodAll
	id = "food_all"
	name = "Food HoT (All)"
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	heal_burn = 0.086
	heal_tox = 0.086
	heal_brute = 0.086
	maxDuration = 6000
	unique = 1
	tickSpacing = 20

	getTooltip()
		return "Healing 0.26 damage spread across Brute/Burn/Toxin damage [tickSpacing/10] sec."

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

	onUpdate(var/timedPassed)
		tickCount += timedPassed
		var/times = (tickCount / tickSpacing)
		if(times >= 1 && ismob(owner))
			tickCount -= (round(times) * tickSpacing)
			var/mob/M = owner
			if (M.bodytemperature > M.base_body_temp + 3)
				for(var/i = 0, i < times, i++)
					M.bodytemperature -= 2
		return

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

	onUpdate(var/timedPassed)
		tickCount += timedPassed
		var/times = (tickCount / tickSpacing)
		if(times >= 1 && ismob(owner))
			tickCount -= (round(times) * tickSpacing)
			var/mob/M = owner
			if (M.bodytemperature < M.base_body_temp + 8)
				for(var/i = 0, i < times, i++)
					M.bodytemperature += 6
		return

/datum/statusEffect/foodstaminaregen
	id = "food_refreshed"
	name = "Food (Refreshed)"
	desc = ""
	icon_state = "stam+"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1
	var/change = 2.2

	big
		name = "Food (Refreshed+)"
		id = "food_refreshed_big"
		change = 5

	getTooltip()
		return "Your stamina regen is increased by [change]."

	onAdd(var/optional=null)
		if(hascall(owner, "add_stam_mod_regen"))
			owner:add_stam_mod_regen("food_bonus", change)
		return

	onRemove()
		if(hascall(owner, "remove_stam_mod_regen"))
			owner:remove_stam_mod_regen("food_bonus")
		return

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
		return "Your max. stamina is increased by [change]."

	onAdd(var/optional=null)
		if(hascall(owner, "add_stam_mod_max"))
			owner:add_stam_mod_max("food_bonus", change)
		return

	onRemove()
		if(hascall(owner, "remove_stam_mod_max"))
			owner:remove_stam_mod_max("food_bonus")
		return


/datum/statusEffect/maxhealth/food
	id = "food_hp_up"
	name = "Food (HP Up)"
	desc = ""
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1
	change = 20

	big
		name = "Food (HP Up+)"
		id = "food_hp_up_big"
		change = 40

	getTooltip()
		return "Your max. health is increased by [change]."

	onAdd(var/optional=null)
		return ..(change)

	onChange(var/optional=null)
		return ..(change)


/datum/statusEffect/deep_fart
	id = "food_deep_fart"
	name = "Food (Gassy)"
	desc = "You feel gassy."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

/datum/statusEffect/deep_burp
	id = "food_deep_burp"
	name = "Food (Gross Burps)"
	desc = "Your stomach feels gassy."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

/datum/statusEffect/food_cat_eyes
	id = "food_cateyes"
	name = "Food (Night Vision)"
	desc = "Your vision feels improved."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

/datum/statusEffect/fire_burp
	id = "food_fireburp"
	name = "Food (Fire Burps)"
	desc = "Your stomach is flaming hot!"
	icon_state = "foodbuff"
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

	proc/cast()

		var/turf/T = get_step(owner,owner.dir)
		var/range_breath = 1
		while((get_dist(owner,T) < range) && (range_breath < 20))// range is used for the range the fireburp can reach from the caster.
			T = get_step(T,owner.dir)
			range_breath ++ //range_breath is used to make sure the loop doesn't stay active too long and lag the game if something messes up range.
		var/list/affected_turfs = getline(owner, T)

		owner.visible_message("<span class='alert'><b>[owner] burps a stream of fire!</b></span>")
		playsound(owner.loc, "sound/effects/mag_fireballlaunch.ogg", 30, 0)

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
			if (get_dist(owner,F) > range)
				continue
			tfireflash(F,0.5,temp)

		//reduce duration
		src.duration -= min(durationLoss,src.duration)
		if(src.duration <= 0)//without this check, it will get stuck at 0 and never go away.
			if(src.owner)
				src.owner.delStatus(src)

/datum/statusEffect/explosion_resist
	id = "food_explosion_resist"
	name = "Food (Sturdy)"
	desc = "Your joints feel sturdy, as if they are more resistant to popping off. Uh."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1
	onAdd(optional)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			APPLY_MOB_PROPERTY(M, PROP_EXPLOPROT, src, 1)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			REMOVE_MOB_PROPERTY(M, PROP_EXPLOPROT, src)

/datum/statusEffect/disease_resist
	id = "food_disease_resist"
	name = "Food (Cleanse)"
	desc = "You are more resistant to disease."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

/datum/statusEffect/rad_resist
	id = "food_rad_resist"
	name = "Food (Rad-Wick)"
	desc = "You are more resistant to radiation."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

/datum/statusEffect/space_farts
	id = "food_space_farts"
	name = "Food (Fart Thrust)"
	desc = "Farts in space provide maximum thrust."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

/datum/statusEffect/bad_breath
	id = "food_bad_breath"
	name = "Food (Bad Breath)"
	desc = "You have extremely smelly breath."
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

/datum/statusEffect/sweaty
	id = "food_sweaty"
	name = "Food (Sweaty)"
	desc = "You feel sweaty!"
	icon_state = "foodbuff"
	exclusiveGroup = "Food"
	maxDuration = 6000
	unique = 1

	var/sweat_prob = 1
	var/tickCount = 0
	var/static/tickSpacing = 20 //Time between ticks.

	big
		name = "Food (Sweaty+)"
		id = "food_sweaty_big"
		desc = "You feel really sweaty!"
		sweat_prob = 5

	onUpdate(var/timedPassed)
		tickCount += timedPassed
		var/times = (tickCount / tickSpacing)
		if(times >= 1 && ismob(owner))
			tickCount -= (round(times) * tickSpacing)
			for(var/i = 0, i < times, i++)
				if (prob(sweat_prob))
					var/turf/T = get_turf(owner)
					T.fluid_react_single("water",5)
		return

