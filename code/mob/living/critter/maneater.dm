/proc/vegetablegibs(turf/T, list/ejectables, bdna, btype)
	var/list/vegetables = list(/obj/item/reagent_containers/food/snacks/plant/soylent, \
		                       /obj/item/reagent_containers/food/snacks/plant/lettuce, \
		                       /obj/item/reagent_containers/food/snacks/plant/cucumber, \
		                       /obj/item/reagent_containers/food/snacks/plant/carrot, \
		                       /obj/item/reagent_containers/food/snacks/plant/slurryfruit)

	var/list/dirlist = list(list(NORTH, NORTHEAST, NORTHWEST), \
		                    list(SOUTH, SOUTHEAST, SOUTHWEST), \
		                    list(WEST, NORTHWEST, SOUTHWEST),  \
		                    list(EAST, NORTHEAST, SOUTHEAST))

	var/list/produce = list()

	for (var/i = 1, i <= 4, i++)
		var/PT = pick(vegetables)
		var/obj/item/reagent_containers/food/snacks/plant/P = new PT(T)
		P.streak_object(dirlist[i])
		produce += P

	var/extra = rand(2,4)
	for (var/i = 1, i <= extra, i++)
		var/PT = pick(vegetables)
		var/obj/item/reagent_containers/food/snacks/plant/P = new PT(T)
		P.streak_object(alldirs)
		produce += P

	return produce

/mob/living/critter/plant/maneater
	name = "man-eating plant"
	real_name = "man-eating plant"
	desc = "It looks hungry..."
	density = TRUE
	icon_state = "maneater"
	icon_state_dead = "maneater-dead"
	custom_gib_handler = /proc/vegetablegibs
	butcherable = TRUE
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	custom_vomit_type = /obj/decal/cleanable/blood
	blood_id = "poo"
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	is_npc = TRUE
	ai_type = /datum/aiHolder/maneater
	//if someone is really annoying and an ally, give them a smack to put them in their place
	ai_retaliates = TRUE
	ai_retaliate_patience = 1
	ai_retaliate_persistence = RETALIATE_ONCE
	add_abilities = list(/datum/targetable/critter/maneater_devour)
	planttype = /datum/plant/maneater
	var/baseline_health = 120 //! how much health the maneater should get normally and at 0 endurance
	var/scaleable_limb = null //! used for scaling the values on one of the critters limbs
	var/list/devoured_items = null

/mob/living/critter/plant/maneater/New()
	src.devoured_items = list()
	APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/maneater, src) // They are approaching you, slowly and menacing...
	//Maneaters are scary and big, they should not be pinned for helplessly thrown around
	APPLY_ATOM_PROPERTY(src, PROP_MOB_CANT_BE_PINNED, "Maneater")
	APPLY_ATOM_PROPERTY(src, PROP_MOB_CANTTHROW, "Maneater")
	APPLY_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY, "Maneater", 25)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY_MAX, "Maneater", 25)
	..()

/mob/living/critter/plant/maneater/disposing()
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_CANTTHROW, "Maneater")
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_CANT_BE_PINNED, "Maneater")
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY, "Maneater")
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY_MAX, "Maneater")
	..()

/mob/living/critter/plant/maneater/setup_healths()
	var/health_per_healthholder = round(src.baseline_health / 3)
	add_hh_flesh(health_per_healthholder, 1)
	add_hh_flesh_burn(health_per_healthholder, 1.25)
	var/datum/healthHolder/toxin/tox = add_health_holder(/datum/healthHolder/toxin)
	tox.maximum_value = health_per_healthholder
	tox.value = health_per_healthholder
	tox.last_value = health_per_healthholder
	tox.damage_multiplier = 1

/mob/living/critter/plant/maneater/setup_equipment_slots()
	src.equipment += new /datum/equipmentHolder/ears(src)
	src.equipment += new /datum/equipmentHolder/head(src)

/mob/living/critter/plant/maneater/setup_hands()
	..()
	var/datum/handHolder/holdinghands = src.hands[1]
	holdinghands.name = "tendrils"
	holdinghands = src.hands[2]
	holdinghands.name = "mouth"								// designation of the hand - purely for show
	holdinghands.icon = 'icons/mob/critter_ui.dmi'			// the icon of the hand UI background
	holdinghands.icon_state = "mouth"						// the icon state of the hand UI background
	holdinghands.limb_name = "teeth"						// name for the dummy holder
	holdinghands.limb = new /datum/limb/mouth/maneater	// if not null, the special limb to use when attack_handing
	src.scaleable_limb = holdinghands.limb //we need this later for applying botany chems with it
	holdinghands.can_hold_items = 0

/mob/living/critter/plant/maneater/HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
	var/health_per_endurance = 3 // how much health the maneater should get per point of endurance
	var/stamina_per_potency = 3 // how much stamina each point of potency should add. With the inate stun resist, its equal to 3,75 stamina per potency
	var/stamreg_per_potency = 0.1 // how much stamina regen each point of potency should add
	var/maximum_stamreg = 30 // how much stamina regen should be the max. Don't want to have complete immunity to stun batoning
	var/baseline_injection = 3 // how much chems the maneater should inject upon attacking
	var/injection_amount_per_yield = 0.1 //how much their injection amount should scale with yield

	var/scaled_health = round(src.baseline_health + (passed_genes?.get_effective_value("endurance") * health_per_endurance))
	src.max_health = max(10, scaled_health)
	for (var/T in healthlist)
		var/datum/healthHolder/lifepool = healthlist[T]
		lifepool.maximum_value = scaled_health / length(healthlist)
		lifepool.value = scaled_health / length(healthlist)
		lifepool.last_value = scaled_health / length(healthlist)

	// Stamina modifiert scale of potency
	APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "maneater_dna", min(round( passed_genes?.get_effective_value("potency") * stamreg_per_potency), maximum_stamreg))
	src.add_stam_mod_max("maneater_dna", (passed_genes?.get_effective_value("potency") * stamina_per_potency))

	// now, we set the arm injection up
	if (length(origin_plant.assoc_reagents) > 0)
		var/datum/limb/mouth/maneater/manipulated_limb = src.scaleable_limb
		manipulated_limb.amount_to_inject = max(1, round(baseline_injection + injection_amount_per_yield * passed_genes?.get_effective_value("cropsize")))
		manipulated_limb.chems_to_inject |= origin_plant.assoc_reagents
	..()
	return src


/mob/living/critter/plant/maneater/gib(give_medal, include_ejectables)
	//We violently eject each item the maneater devoured in all directions
	. = list()
	if(length(src.devoured_items) > 0)
		for (var/obj/item/handled_item in src.devoured_items)
			handled_item.set_loc(get_turf(src))
			handled_item.streak_object(alldirs)
			src.devoured_items -= handled_item
			. += handled_item
	. += ..()

/mob/living/critter/plant/maneater/butcher(var/mob/M, drop_brain = TRUE)
	//We drop all items we devoured prior
	if(length(src.devoured_items) > 0)
		for (var/obj/item/handled_item in src.devoured_items)
			handled_item.set_loc(get_turf(src))
			src.devoured_items -= handled_item
	..()



/mob/living/critter/plant/maneater/seek_food_target(var/range = 7)
	. = list()
	for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/potential_meat in view(range, get_turf(src)))
		//no fish meat, no synthmeat. chickens nuggets are ok, though.
		if (istype(potential_meat, /obj/item/reagent_containers/food/snacks/ingredient/meat/fish)) continue
		if (istype(potential_meat, /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)) continue
		. += potential_meat


/mob/living/critter/plant/maneater/seek_target(var/range = 9)
	. = ..()
	if ((length(.) > 0) && prob(10))
		if (!ON_COOLDOWN(src, "maneater_snarling", 15 SECONDS))
			playsound(src.loc, 'sound/voice/maneatersnarl.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
			src.visible_message("<span class='alert'><B>[src]</B> snarls!</span>")

/mob/living/critter/plant/maneater/seek_scavenge_target(var/range = 5)
	. = list()
	var/target_being_devoured = FALSE
	for (var/mob/living/carbon/human/checked_human in view(range, get_turf(src)))
		target_being_devoured = FALSE
		for(var/mob/living/critter/plant/maneater/checked_maneater in get_turf(checked_human))
			if (checked_maneater != src)
				target_being_devoured = TRUE
		if (!(target_being_devoured) && isdead(checked_human) && checked_human.decomp_stage <= 3 && !checked_human.bioHolder?.HasEffect("husk"))
			//is dead, isn't a skeleton, isn't a grody husk, isn't occupied by another maneater
			. += checked_human

/mob/living/critter/plant/maneater/can_critter_scavenge()
	var/datum/targetable/critter/checked_ability = src.abilityHolder.getAbility(/datum/targetable/critter/maneater_devour)
	if (checked_ability.disabled || !checked_ability.cooldowncheck()) return FALSE
	return can_act(src,TRUE)



/mob/living/critter/plant/maneater/critter_attack(mob/target)
	// first we check if our maneater is munching on something
	var/datum/targetable/critter/devour_ability = src.abilityHolder.getAbility(/datum/targetable/critter/maneater_devour)
	if (!(src in actions.running))
		//first, we check if another maneater is on that persons tile. This way, we don't have food fights between maneaters
		var/target_being_devoured = FALSE
		for(var/mob/living/critter/plant/maneater/checked_maneater in get_turf(target))
			if (checked_maneater != src)
				target_being_devoured = TRUE
		//if the target is unconscious, being eaten by another maneater and we are unable to eat them, we gotta wack them a bit
		if(!target_being_devoured && (isunconscious(target) || isdead(target)) && ishuman(target) && !devour_ability.disabled && devour_ability.cooldowncheck())
			//we we grab and devour our target :)
			return src.grab_and_devour(target, devour_ability)

		else
			//we want to nibble on them with out right hand
			src.set_a_intent(INTENT_HARM)
			src.set_dir(get_dir(src, target))
			src.active_hand = 2

			var/list/params = list()
			params["right"] = TRUE
			params["ai"] = TRUE

			src.hand_attack(target, params)
			return
	else
		//let's wait until we finished eating our target :)
		return


/mob/living/critter/plant/maneater/critter_scavenge(var/mob/target)
	// first we check if our maneater is munching on something
	if (!(src in actions.running))
		return src.grab_and_devour(target, src.abilityHolder.getAbility(/datum/targetable/critter/maneater_devour))
	return TRUE

/mob/living/critter/plant/maneater/proc/grab_and_devour(var/mob/target, var/datum/targetable/critter/devour_ability)
	//we want to grab with our left tentacle hand
	src.set_a_intent(INTENT_GRAB)
	src.set_dir(get_dir(src, target))
	src.active_hand = 1

	var/list/params = list()
	params["left"] = TRUE
	params["ai"] = TRUE

	var/obj/item/grab/checked_grab = src.equipped()
	if (!istype(checked_grab)) //if it hasn't grabbed something, try to
		if(!isnull(checked_grab)) //if we somehow have something that isn't a grab in our hand
			src.drop_item()
		src.hand_attack(target, params)
		return
	else
		if (checked_grab.affecting == null || checked_grab.assailant == null || checked_grab.disposed || !ishuman(checked_grab.affecting) || checked_grab.affecting != target)
			src.drop_item()
			return

		if (checked_grab.state <= GRAB_PASSIVE)
			checked_grab.AttackSelf(src)
			return
		else
			devour_ability.handleCast(target)
			return



/mob/living/critter/plant/maneater/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	// we don't want this behaviour when the maneater is dead
	if (isdead(src)) return
	// if we got too much items in our stomach we try to vomit some out
	if (length(src.devoured_items) > 6)
		if(!ON_COOLDOWN(src, "item_vomiting", 1 MINUTES))
			src.vomit()
	else if (isturf(src.loc) && prob(4))
		var/list/potential_caretakers = list()
		for(var/mob/living/carbon/human/checked_human in hearers(5, src))
			//botanists or people who contributed to the plant can be caretakers and be talked to
			if ((checked_human.faction & src.faction) || (checked_human in src.growers))
				potential_caretakers += checked_human
		//we only talk to people we actually want to talk to
		if (length(potential_caretakers) > 0)
			//don't wanmt our plant to be too talkative
			if (!ON_COOLDOWN(src, "maneater_talking", 25 SECONDS))
				//now, we pick one caretaker if there is one. Maybe we talk directly to them!
				var/mob/living/carbon/human/caretaker = pick(potential_caretakers)
				//yes, maneater know your real name and will happiely call you out.
				var/maneater_voice_line = pick("Feed me, [caretaker.real_name]!", "I'm hungryyyy...", "Ooooh, cut the crap! Bring on the meat!", "I'm starving!", "Must be fresh!")
				src.say(maneater_voice_line)

/mob/living/critter/plant/maneater/specific_emotes(var/act, var/param = null, var/voluntary = 0)
	switch (act)
		if ("scream")
			if (src.emote_check(voluntary, 5 SECONDS))
				playsound(src.loc, 'sound/voice/maneatersnarl.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				return "<b><span class='alert'>[src] snarls!</span></b>"
	return ..()

/mob/living/critter/plant/maneater/vomit(var/nutrition=0, var/specialType=null, var/flavorMessage="[src] vomits!")
	if (src.reagents?.get_reagent_amount("promethazine")) // Anti-emetics stop vomiting from occuring
		return
	//We vomit out an item, if we have eaten some.
	if(length(src.devoured_items) > 0)
		var/obj/item/handled_item = pick(src.devoured_items)
		handled_item.set_loc(get_turf(src))
		src.devoured_items -= handled_item
	..()

/mob/living/critter/plant/maneater/polymorph
	name = "man-eating plant"
	real_name = "Wizard-eating plant"
	desc = "It looks upset about something..."
	density = 1
	icon_state = "maneater"
	icon_state_dead = "maneater-dead"
	custom_gib_handler = /proc/vegetablegibs
	butcherable = TRUE
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	custom_vomit_type = /obj/decal/cleanable/blood
	blood_id = "poo"
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	add_abilities = list(/datum/targetable/critter/bite/maneater_bite)   //Devour way too abusable, but plant with teeth needs bite =)
	planttype = /datum/plant/maneater

/mob/living/critter/plant/maneater_polymorph/specific_emotes(var/act, var/param = null, var/voluntary = 0)
	switch (act)
		if ("scream")
			if (src.emote_check(voluntary, 50))
				playsound(src.loc, 'sound/voice/maneatersnarl.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				return "<b><span class='alert'>[src] snarls!</span></b>"
	return null

/mob/living/critter/plant/maneater_polymorph/specific_emote_type(var/act)
	switch (act)
		if ("scream")
			return 2
	return ..()

/mob/living/critter/plant/maneater_polymorph/setup_equipment_slots()
	equipment += new /datum/equipmentHolder/ears(src)
	equipment += new /datum/equipmentHolder/head(src)

/mob/living/critter/plant/maneater_polymorph/setup_hands()
	..()
	var/datum/handHolder/holdinghands = src.hands[1]
	holdinghands.name = "tendrils"
	holdinghands = src.hands[2]
	holdinghands.name = "mouth"								// designation of the hand - purely for show
	holdinghands.icon = 'icons/mob/critter_ui.dmi'			// the icon of the hand UI background
	holdinghands.icon_state = "mouth"						// the icon state of the hand UI background
	holdinghands.limb_name = "teeth"						// name for the dummy holder
	holdinghands.limb = new /datum/limb/mouth/maneater		// if not null, the special limb to use when attack_handing
	holdinghands.can_hold_items = 0

/mob/living/critter/plant/maneater_polymorph/New()
	..()

/mob/living/critter/plant/maneater_polymorph/setup_healths()
	add_hh_flesh(40, 1)
	add_hh_flesh_burn(40, 1.25)
	var/datum/healthHolder/toxin/tox = add_health_holder(/datum/healthHolder/toxin)
	tox.maximum_value = 40
	tox.value = 40
	tox.last_value = 40
	tox.damage_multiplier = 1
