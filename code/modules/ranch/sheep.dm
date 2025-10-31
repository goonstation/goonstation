// Sheep

/mob/living/critter/small_animal/ranch_base/sheep
	name = "lamb"
	real_name = "lamb"
	desc = "On the lamb."
	icon = 'icons/mob/ranch/sheep.dmi'
	speech_verb_say = "baas"
	speech_verb_exclaim = "screams"
	speech_verb_ask = "bleats"
	health_brute = 30
	health_burn = 30
	hand_count = 2

	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1

	butcherable = BUTCHER_ALLOWED
	butcher_time = 0.2 SECONDS
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/sheep

	skinresult = /obj/item/material_piece/cloth/leather
	max_skins = 3

	pet_text = list("scritches", "pats", "pets")

	density = 0

	happy_pet_message = "nuzzles your hand."

	critter_scream_sound = null

	attack_ability_type = null

	var/sheep_id = "white"

	var/wool_grown = 0

	var/wool_type = /obj/item/material_piece/cloth/wool/white

	var/custom_icon = FALSE

	species_type = /mob/living/critter/small_animal/ranch_base/sheep

	egg_type = /mob/living/critter/small_animal/ranch_base/sheep

	/// path to the sheep_baby_props datum, used to setup babies
	var/sheep_baby_props_path = /datum/sheep_baby_props/white

	base_move_delay = 2.3
	base_walk_delay = 4

	crowded_minimum = 25

	New()
		..()
		UpdateIcon()

		if(is_npc && !has_special_ai)
			if(is_masc)
				src.ai = new /datum/aiHolder/sheep/ram(src)
			else
				src.ai = new /datum/aiHolder/sheep/ewe(src)

		src.abilityHolder.addAbility(/datum/targetable/critter/seek_mate)
		src.abilityHolder.addAbility(/datum/targetable/critter/create_child)

	restore_life_processes()
		. = ..()
		add_lifeprocess(/datum/lifeprocess/ranch/sheep/grow_wool)

	death(var/gibbed, var/do_drop_equipment = 1)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/P = src.parent
		if(P)
			if(P.baby == src)
				P.baby = null
			if(P.mate && P.mate.baby == src)
				P.mate.baby = null
		src.parent = null

	reduce_lifeprocess_on_death()
		. = ..()
		remove_lifeprocess(/datum/lifeprocess/ranch/sheep/grow_wool)

	update_icon()

		if(!custom_icon)
			var/growth = null
			if (stage == RANCH_STAGE_CHILD)
				growth = "lamb"
			else
				if(is_masc)
					growth = "ram"
				else
					growth = "ewe"

			var/wool = null

			if(!wool_grown && stage != RANCH_STAGE_CHILD)
				wool = "-shorn"

			if(isalive(src))
				icon_state = "sheep-[sheep_id]-[growth][wool]"
				icon_state_alive = icon_state
			icon_state_dead = "sheep-[sheep_id]-[growth]-dead"
			icon_state_ghost = "sheep-[sheep_id]-[growth][wool]"
			if(!isalive(src))
				icon_state = icon_state_dead


	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		var/datum/limb/small_critter/LSC = HH.limb
		LSC.actions = list("hoofs", "kicks", "bashes", "stomps on")
		HH.icon_state = "handn"
		HH.name = "hoof"
		HH.limb_name = "hoof"
		LSC.sound_attack = 'sound/impact_sounds/Generic_Hit_1.ogg'

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "mouth"					// name for the dummy holder
		HH.can_hold_items = 0

	death(var/gibbed, var/do_drop_equipment = 1)
		..()
		name = "dead [name]"
		real_name = "[name]"
		desc = "Rest in peace, lil' lambchop."

	// specific_emotes(var/act, var/param = null, var/voluntary = 0)
	// 	switch (act)
	// 		if ("scream")
	// 			if (src.emote_check(voluntary, 50))
	// 				playsound(get_turf(src), critter_scream_sound , 50, 1, pitch = critter_scream_pitch, channel = VOLUME_CHANNEL_EMOTE)
	// 				return "<b>[src]</b> boks!"
	// 	return null

	on_pet(mob/user)
		if(isdead(src))
			return
		..()
		var/chance_egg = max(clamp(src.happiness,0,100) - clamp(((src.hunger-25)*2),0,100),20)
		if(prob(chance_egg))
			boutput(user, SPAN_NOTICE("[src] [src.happy_pet_message]"))
			src.change_happiness(rand(1,5))
		if(src.befriend_with_pets && prob(chance_egg*2))
			if(src.stage == RANCH_STAGE_CHILD)
				if(src.ai)
					src.update_shitlist(user,remove = 1)
					src.update_friendlist(user,FALSE)

	grow_up()
		..()
		name = "ewe"
		real_name = "ewe"
		desc = "frick ewe"
		critter_scream_pitch = 1
		UpdateIcon()
		flags = flags & ~DOORPASS

		var/mob/living/critter/small_animal/ranch_base/P = parent

		if(P)
			if(P.baby)
				P.baby = null
			if(P.mate)
				if(P.mate.baby)
					P.mate.baby = null
		parent = null
		return

	special_feed_behavior(var/flag,var/happiness_amt,var/hunger_amt)
		switch(flag)
			if("raptor", "chicken_meat")
				//sheep can't eat meat unless I make a cannibal sheep later
				happiness_amt = min(-50, happiness_amt)
				hunger_amt = 0
				SPAWN(3 SECONDS)
					src.visible_message(SPAN_ALERT("[src]'s stomach doesn't agree with eating meat!"))
					src.vomit()
					src.hunger = 0
					if(src.happiness > 0)
						src.happiness = 0
			// if("ageless")
			// 	src.egg_cooldown++

		return ..(flag,happiness_amt,hunger_amt)

	proc/grow_wool()
		src.wool_grown = 1
		src.UpdateIcon()

	proc/shear(var/mob/M)
		src?.canmove = 1
		src.wool_grown = 0
		src.UpdateIcon()
		src.visible_message(SPAN_NOTICE("[M] shears [src]'s wool."), SPAN_NOTICE("You shear [src]'s wool."))
		var/obj/item/material_piece/cloth/wool = new wool_type
		wool.set_loc(get_turf(src))

	attackby(obj/item/I, mob/M)
		if(issnippingtool(I))
			if(wool_grown)
				src?.canmove = 0
				SPAWN(2 SECONDS)
					src?.canmove = 1
				var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(M, src, 2 SECONDS,\
				/mob/living/critter/small_animal/ranch_base/sheep/proc/shear,list(M), I.icon, I.icon_state, null)

				playsound(src.loc, 'sound/items/Scissor.ogg', 50, 1)
				src.visible_message(SPAN_NOTICE("[M] begins to shear [src]'s wool!"), SPAN_NOTICE("You begin to shear [src]'s wool!"))
				actions.start(action_bar, M)
			else
				boutput(M, SPAN_ALERT("[src] doesn't have enough wool to shear!"))
			return
		else
			. = ..()

	gossip(var/mob/M)
		if(src == M)
			return
		if(src.mate && src.mate == M)
			return
		if(src.parent  && src.parent == M)
			return
		var/mob/living/critter/small_animal/ranch_base/P = src.parent
		if(P && P.mate && P.mate == M)
			return
		src.update_friendlist(M,remove = 1)
		src.update_shitlist(M)
		src.ai.interrupt()
		if(src.mate)
			src.mate.update_friendlist(M,remove = 1)
			src.mate.update_shitlist(M)
			src.mate.ai.interrupt()
		if(P)
			P.update_friendlist(M,remove = 1)
			P.update_shitlist(M)
			P.ai.interrupt()
			if(P.mate)
				P.mate.update_friendlist(M,remove = 1)
				P.mate.update_shitlist(M)
				P.mate.ai.interrupt()

	create_child(var/mob/M)
		var/mob/living/critter/small_animal/ranch_base/sheep/S = M
		if(!istype(S))
			return
		var/mob/living/critter/small_animal/ranch_base/sheep/parent = pick(src,S)
		if(istype(parent))

			var/datum/sheep_baby_props/SBS = new parent.sheep_baby_props_path

			SBS.BeforeBirth()

			if(SBS.unique)
				for(var/mob/living/critter/small_animal/ranch_base/sheep/C in by_type[/mob/living/critter/small_animal/ranch_base])
					if(C.sheep_id == SBS.sheep_id)
						src.visible_message(SPAN_ALERT("[parent] looks incredibly confused!"))
						qdel(src)
						return

			var/mob/living/critter/small_animal/ranch_base/sheep/child

			if (prob(SBS.gender_balance))
				if (length(SBS.arguments))
					child = new SBS.ram_type(arglist(SBS.arguments))
				else // kind of annoyed that you can't just pass arglist an empty list or null without runtimes...
					child  = new SBS.ram_type()
			else
				if (length(SBS.arguments))
					child  = new SBS.ewe_type(arglist(SBS.arguments))
				else // kind of annoyed that you can't just pass arglist an empty list or null without runtimes...
					child = new SBS.ewe_type()
			if (!child)
				parent.visible_message(SPAN_ALERT("[parent] looks incredibly confused!"))
				return
			if(child)
				child.set_loc(get_turf(parent))
				child.happiness += SBS.happiness_value

			// do after hatch tasks
				SBS.AfterBirth(child)

				child.parent = S
				src.baby = child
				S.baby = child

				child.visible_message(SPAN_NOTICE("Hey! Where did that [child] come from?"))

/datum/lifeprocess/ranch/sheep/grow_wool
	var/wool_counter = 0
	process()
		var/mob/living/critter/small_animal/ranch_base/sheep/S = critter_owner
		if(istype(S))
			if(S.stage == RANCH_STAGE_CHILD)
				return
			if(S.wool_grown)
				wool_counter = 0
				return
			else
				wool_counter += get_multiplier()
				var/chance = max(clamp(S.happiness,0,100) - clamp(((S.hunger-25)*2) + wool_counter,0,100),20)
				if(wool_counter >= 100)
					S.grow_wool()
				else if (wool_counter >= 30 && prob(chance))
					S.grow_wool()
				else
					return

/mob/living/critter/small_animal/ranch_base/sheep/white
	name = "lamb"
	real_name = "lamb"
	sheep_id = "white"
	happiness = 0
	favorite_flag = "wheat"
	egg_type = /mob/living/critter/small_animal/ranch_base/sheep/white
	sheep_baby_props_path = /datum/sheep_baby_props/white
	wool_type = /obj/item/material_piece/cloth/wool/white

	grow_up()
		..()
		if(is_masc)
			name = "ram"
			real_name = "ram"
			desc = "Likes to butt in." // woah black betty bambalamb , ram
		else
			name = "ewe"
			real_name = "ewe"
			desc = "Soft and fluffy, like a cloud."
		return

	change_happiness(var/amt)
		..()

	ram
		is_masc = 1

		ai_controlled
			is_npc = 1

			bi
				New()
					. = ..()
					gender_preference |= RANCH_PREFERENCE_DIFF
					gender_preference |= RANCH_PREFERENCE_SAME


	ai_controlled
		is_npc = 1

		bi
			New()
				. = ..()
				gender_preference |= RANCH_PREFERENCE_DIFF
				gender_preference |= RANCH_PREFERENCE_SAME
