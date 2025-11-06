/mob/living/critter/small_animal/pig
	name = "space pig"
	desc = "A pig. In space."
	icon_state = "pig"
	icon_state_dead = "pig-dead"
	density = TRUE
	speech_verb_say = "oinks"
	speech_verb_exclaim = "squeals"
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw
	name_the_meat = FALSE
	var/feral = FALSE

	ai_type = /datum/aiHolder/pig // Worry not they will only attack mice
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					return SPAN_EMOTE("<b>[src]</b> squeals!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(10))
			src.audible_message("[src] purrs![prob(20) ? " Wait, what?" : null]",\
			"You purr!")

	valid_target(mob/living/C)
		if(feral) //yes I should just fix the inheritance here but I'm lazy
			return ..()
		else
			if (isintangible(C)) return FALSE
			if (isdead(C)) return FALSE
			if (length(C.faction & src.faction)) return FALSE
			if (istype(C, /mob/living/critter/small_animal/mouse)) return TRUE

	death(var/gibbed)
		if (!gibbed)
			src.reagents.add_reagent("beff", 50, null)
		return ..()

/mob/living/critter/small_animal/pig/feral_hog
	name = "feral hog"
	desc = "A feral hog. In space."
	health_brute = 35
	health_burn = 35
	feral = TRUE

	ai_type = /datum/aiHolder/aggressive

	New(loc)
		. = ..()
		remove_stam_mod_max("small_animal")

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[1]
		var/datum/limb/mouth/maneater/limb = new/datum/limb/mouth/maneater
		HH.limb = limb
		limb.dam_high = 12
		limb.dam_low = 8
		limb.miss_prob = 100
		limb.borg_damage_bonus = 5
		limb.human_desorient_duration = 0
		limb.human_stam_damage = 20

/mob/living/critter/small_animal/pig/flying
	icon_state = "pig-fly"
	ai_type = /datum/aiHolder/pig_flying

	New(loc)
		..()
		src.flags |= TABLEPASS
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		animate_bumble(src)
