
/*
/mob/living/proc/get_food_bonus()
	var/return_string = ""
	for(var/D in src.bioHolder.effects)
		var/datum/bioEffect/hidden/foodbonus/BE = src.bioHolder.effects[D]
		if (istype(BE))
			return_string += BE.name
			return_string += " "
	return return_string
*/

//DEPRECATED by status efffects
/*

/datum/bioEffect/hidden/foodbonus
	effectType = EFFECT_TYPE_FOOD
	curable_by_mutadone = 0
	occur_in_genepools = 0
	can_copy = 0
	timeLeft = 60

	var/time_per_bite = 40
	var/max_time = 300

	OnAdd()
		..()
		if (time_per_bite > 0)
			timeLeft = time_per_bite

	proc/RemoveSelf()
		if (ishuman(owner))
			owner:bioHolder.RemoveEffect(src.id)



/datum/bioEffect/hidden/foodbonus/heal_over_time
	var/regen = 0.17


/datum/bioEffect/hidden/foodbonus/heal_over_time/brute_hot
	name = "Brute Regeneration"
	desc = "Slowly regenerate brute damage over time."
	id = "food_brute"
	msgGain = "You feel your stomach working."

	OnLife()
		if(..()) return
		owner.HealDamage("All", regen, 0, 0)

/datum/bioEffect/hidden/foodbonus/heal_over_time/burn_hot
	name = "Burn Regeneration"
	desc = "Slowly regenerate burn damage over time."
	id = "food_burn"
	msgGain = "You feel your stomach working."

	OnLife()
		if(..()) return
		owner.HealDamage("All", 0, regen, 0)

/datum/bioEffect/hidden/foodbonus/heal_over_time/tox_hot
	name = "Toxin Regeneration"
	desc = "Slowly regenerate toxic damage over time."
	id = "food_tox"
	msgGain = "You feel your stomach working."

	OnLife()
		if(..()) return
		owner.HealDamage("All", 0, 0, regen)


/datum/bioEffect/hidden/foodbonus/heal_over_time/all
	name = "General Regeneration"
	desc = "Slowly regenerate brute, burn, and toxin damage over time."
	id = "food_all"

	OnLife()
		if(..()) return
		owner.HealDamage("All", regen/3, regen/3, regen/3)

/datum/bioEffect/hidden/foodbonus/warm
	name = "Warm"
	desc = "Your stomach feels warm."
	id = "food_warm"
	msgGain = "Your stomach feels warm."

	OnLife()
		if(..()) return
		if (ishuman(owner))
			owner:bodytemperature += 6

/datum/bioEffect/hidden/foodbonus/cooled
	name = "Cooled"
	desc = "Your stomach feels cooled."
	id = "food_cold"
	msgGain = "Your stomach feels cooled."

	OnLife()
		if(..()) return
		if (ishuman(owner))
			owner:bodytemperature -= 3

/datum/bioEffect/hidden/foodbonus/stamina_regen
	name = "food_refreshed"
	desc = "You feel refreshed."
	id = "food_refreshed"
	msgGain = "You feel refreshed."
	var/added = 0
	var/bonus = 1

	OnAdd()
		..()
		if(hascall(owner, "add_stam_mod_regen"))
			if(owner:add_stam_mod_regen("food_bonus", bonus) )
				added = 1
	OnRemove()
		..()
		if(added)
			owner:remove_stam_mod_regen("food_bonus")

/datum/bioEffect/hidden/foodbonus/stamina_regen/big
	name = "Very Refreshed"
	desc = "You feel very refreshed."
	id = "food_refreshed_big"
	msgGain = "You feel very refreshed."
	bonus = 3

/datum/bioEffect/hidden/foodbonus/stamina_up
	name = "food_energized"
	desc = "You feel energized."
	id = "food_energized"
	msgGain = "You feel energized."
	var/added = 0
	var/bonus = 15


	OnAdd()
		..()
		if(hascall(owner, "add_stam_mod_max"))
			if(owner:add_stam_mod_max("food_bonus", bonus))
				added = 1
	OnRemove()
		..()
		if(added)
			owner:remove_stam_mod_max("food_bonus")

/datum/bioEffect/hidden/foodbonus/stamina_up/big
	name = "Very Energized"
	desc = "You feel very energized."
	id = "food_energized_big"
	msgGain = "You feel very energized."
	bonus = 40

/datum/bioEffect/hidden/foodbonus/hp_up
	name = "Healthy"
	desc = "Increased max health."
	id = "food_hp_up"
	msgGain = "You feel satisfied."
	var/buff_amt = 15

	OnAdd()
		..()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health += buff_amt

	OnRemove()
		..()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health -= buff_amt

/datum/bioEffect/hidden/foodbonus/hp_up/big
	name = "Very Healthy"
	id = "food_hp_up_big"
	msgGain = "You feel very satisfied."
	buff_amt = 30


/datum/bioEffect/hidden/foodbonus/deep_fart
	name = "Gassy"
	desc = "Deep farts."
	id = "food_deep_fart"
	msgGain = "You feel gassy."

/datum/bioEffect/hidden/foodbonus/deep_burp
	name = "Gassy"
	desc = "Deep burps."
	id = "food_deep_burp"
	msgGain = "Your stomach feels gassy."

/datum/bioEffect/hidden/foodbonus/cateyes
	name = "Improved vision"
	desc = "Increased night vision."
	id = "food_cateyes"
	msgGain = "Your eyes feel relaxed."
	msgLose = "Your eyes feel normal."


//Fire breath : sort of copied from powers.dm with slight changes
/datum/bioEffect/hidden/foodbonus/fire_burp
	name = "Fire Burp"
	desc = "Allows the subject to burp flames."
	id = "food_fireburp"
	msgGain = "Your stomach is burning!"
	msgLose = "Your stomach feels a lot better now."
	//ability_path = /datum/targetable/geneticsAbility/spicy_food
	var/temp = 1200
	var/range = 4

	var/uses = 2

	proc/cast()
		if (..())
			return 1

		var/turf/T = get_step(owner,owner.dir)
		T = get_step(T,owner.dir)
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

		uses--
		if (uses <= 0)
			src.RemoveSelf()

/datum/bioEffect/hidden/foodbonus/fire_burp/big
	id = "food_fireburp_big"
	temp = 1800
	range = 6
	uses = 3

/datum/bioEffect/hidden/foodbonus/vomit_spawn
	name = "Indigestion"
	desc = "Your stomach is not happy."
	id = "indigestion"
	msgGain = "You feel queasy."

	OnRemove()
		//vomit

/datum/bioEffect/hidden/foodbonus/explosion_resist
	name = "Sturdy"
	desc = "Explosion resistance."
	id = "food_explosion_resist"
	msgGain = "Your joints feel sturdy."


/datum/bioEffect/hidden/foodbonus/disease_resist
	name = "Cleanse"
	desc = "Resist disease."
	id = "food_disease_resist"
	msgGain = "You feel clean."

/datum/bioEffect/hidden/foodbonus/rad_resist
	name = "Radiation Wick"
	desc = "Resist radiation."
	id = "food_rad_resist"
	msgGain = "You feel calm."

/datum/bioEffect/hidden/foodbonus/space_fart
	name = "Fart Thruster"
	desc = "Space farts provide maximum thrust."
	id = "food_space_farts"
	msgGain = "Your butt feels energized!"

/datum/bioEffect/hidden/foodbonus/sweaty
	name = "food_sweaty"
	desc = "You're sweating a lot!"
	id = "food_sweaty"
	msgGain = "You feel sweaty."
	var/sweat_prob = 10

	OnLife()
		if(..()) return
		if (prob(sweat_prob))
			var/turf/owner_turf = get_turf(owner)
			if (istype(owner_turf))
				new /obj/decal/cleanable/water(owner_turf)

datum/bioEffect/hidden/foodbonus/sweaty/big
	name = "Very Sweaty"
	desc = "You're sweating a lot!"
	id = "food_sweaty_big"
	msgGain = "You feel very sweaty."
	sweat_prob = 20


/datum/bioEffect/hidden/foodbonus/bad_breath
	name = "Bad Breath"
	desc = "Your breat smells bad!"
	id = "bad_breath"
	msgGain = "Your breath is stinky."

*/
