//Chickens

/*
Spoilers Lay Within:

Secret Chickens:
Space
Time
Spacetime
Timespace

Closed Source Chickens (Not Secret)
Dragon
Coral
Phoenix
Zappy

All other chickens in this file are non-secret. Please be respectful.
*/


/mob/living/critter/small_animal/ranch_base/chicken
	name = "chick"
	real_name = "chick"
	desc = "Aww, a baby chicken! Cluck cluck!"
	icon = 'icons/mob/ranch/chickens.dmi'
	//icon_state = "chick"
	icon_state_dead = "chick-dead"
	speech_verb_say = "chirps"
	speech_verb_exclaim = "cheeps"
	speech_verb_ask = "boks"
	health_brute = 10
	health_burn = 10
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	hand_count = 2

	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1

	is_npc = 0

	butcherable = 1
	butcher_time = 0.2 SECONDS
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget

	skinresult = /obj/item/feather
	max_skins = 3

	pet_text = list("scritches", "pats", "pets")

	density = 0

	impressionable = 1

	///Controls whether or not hens will fight or run
	var/hens_fight = FALSE

	critter_scream_sound = 'sound/voice/screams/chicken_bawk.ogg'

	var/chicken_id = "white"

	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/white

	species_type = /mob/living/critter/small_animal/ranch_base/chicken

	base_move_delay = 2.3
	base_walk_delay = 4

	New()
		..()

		START_TRACKING
		icon_state = "chick-[chicken_id]"
		icon_state_alive = icon_state
		icon_state_dead = "chick-[chicken_id]-dead"
		icon_state_ghost = "chick-[chicken_id]"
		meat_type = text2path("/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/[chicken_id]")

		if(is_masc)
			egg_cooldown = 20
			abilityHolder.addAbility(/datum/targetable/critter/hatch_egg)
		else
			abilityHolder.addAbility(/datum/targetable/critter/lay_egg)

		if(is_npc && !has_special_ai)
			if(is_masc)
				src.ai = new /datum/aiHolder/chicken/rooster(src)
			else if(hens_fight)
				src.ai = new /datum/aiHolder/chicken/hen/aggressive(src)
			else
				src.ai = new /datum/aiHolder/chicken/hen(src)

	disposing()
		STOP_TRACKING
		..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "beak"					// name for the dummy holder
		HH.can_hold_items = 0

	death(var/gibbed, var/do_drop_equipment = 1)
		..()
		remove_lifeprocess(/datum/lifeprocess/chicken/egg_timer)
		remove_lifeprocess(/datum/lifeprocess/chems)
		name = "dead [name]"
		real_name = "[name]"
		desc = "Rest in peace, lil' nugget."

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), critter_scream_sound , 50, 1, pitch = critter_scream_pitch, channel = VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> boks!"
		return null

	on_pet(mob/user)
		if(isdead(src))
			return
		..()
		var/chance_egg = max(clamp(src.happiness,0,100) - clamp(((src.hunger-25)*2),0,100),20)
		if(prob(chance_egg))
			src.visible_message(SPAN_NOTICE("[src] [src.happy_pet_message]"))
			src.change_happiness(rand(1,5))
		if(src.befriend_with_pets && prob(chance_egg*2))
			if(src.stage == RANCH_STAGE_CHILD)
				if(src.ai)
					src.update_shitlist(user,remove = 1)
					src.update_friendlist(user,FALSE)

	grow_up()
		..()
		name = "chicken"
		real_name = "chicken"
		desc = "Aww, a chicken! Cluck cluck!"
		critter_scream_pitch = 1
		if(is_masc)
			icon_state = "rooster-[chicken_id]"
			icon_state_alive = icon_state
			icon_state_dead = "rooster-[chicken_id]-dead"
			icon_state_ghost = "rooster-[chicken_id]"
		else
			icon_state = "hen-[chicken_id]"
			icon_state_alive = icon_state
			icon_state_dead = "hen-[chicken_id]-dead"
			icon_state_ghost = "hen-[chicken_id]"
		flags = flags & ~DOORPASS
		return

	special_feed_behavior(var/flag,var/happiness_amt,var/hunger_amt)
		switch(flag)
			if("chicken_meat")
				if(!(src.favorite_flag == "chicken_meat")) //who would do this
					happiness_amt = min(-50, happiness_amt)
					hunger_amt = 0
					SPAWN(3 SECONDS)
						src.visible_message(SPAN_ALERT("[src] looks sick with disgust and guilt!"))
						src.vomit()
						src.hunger = 0
						if(src.happiness > 0)
							src.happiness = 0
			if("ageless")
				src.egg_cooldown++

		return ..(flag,happiness_amt,hunger_amt)

	proc/lay_egg()
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E = new egg_type()
		if (E.chicken_egg_props.is_hatchable)
			E.icon_state = "egg-[E.chicken_egg_props.chicken_id]"
			E.chicken_egg_props.happiness_value += src.happiness/3
			E.set_loc(get_turf(src))
			src.egg_pity_count = 0
			src.egg_timer = src.egg_cooldown
			return E
		else if (!E.chicken_egg_props.is_hatchable)
			src.egg_timer = src.egg_cooldown
			src.egg_pity_count = 0
			E.set_loc(get_turf(src))
			return E.chicken_egg_props.ItemHatch()

	proc/special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		return

/datum/lifeprocess/chicken/egg_timer
	process()
		var/mob/living/critter/small_animal/ranch_base/chicken/C = critter_owner
		if(istype(C))
			var/mult = get_multiplier()
			if(C.named)
				C.egg_timer = max(0, (C.egg_timer - mult/20))
			else
				C.egg_timer = max(0, (C.egg_timer - mult))

/datum/lifeprocess/chicken/produce_reagent
	process()
		var/mob/living/critter/small_animal/ranch_base/chicken/glass/G = critter_owner
		if(istype(G))

			var/datum/reagents/R = new()
			var/amt = 5*get_multiplier()
			R.maximum_volume = amt
			R.add_reagent(G.my_reagent_id,amt)
			if(prob(50))
				R.reaction(G,INGEST)
			else
				R.reaction(G,TOUCH)

			R.trans_to(G,amt)

			R = null

/datum/lifeprocess/honk_randomly
	process()
		if(prob(5 + (5 * get_multiplier())))
			playsound(get_turf(owner), "sound/musical_instruments/Bikehorn_[rand(1,2)].ogg", 30, 1)

/datum/lifeprocess/cluwne_honk_randomly
	process()
		if(prob(5 + (5 * get_multiplier())))
			playsound(get_turf(owner), "sound/voice/cluwnelaugh[rand(1,3)].ogg", 35, 1)

/mob/living/critter/small_animal/ranch_base/chicken/white
	name = "chick"
	real_name = "chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/white
	chicken_id = "white"
	happiness = 0
	favorite_flag = "rice"
	base_evolution_type = /datum/ranch/evolution/chicken/white

	New()
		. = ..()
		if(is_masc)
			src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/honk(null)
		else
			src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/glass(null)
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/purple
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/onagadori
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/pet
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/silkie
		src.evolutions += new/datum/ranch/evolution/chicken/silkie_black
		src.evolutions += new/datum/ranch/evolution/chicken/silkie_white
		src.evolutions += new/datum/ranch/evolution/chicken/brown

	grow_up()
		..()
		if(is_masc)
			name = "rooster"
			real_name = "rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "hen"
			real_name = "hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/silkie
	name = "silkie chick"
	real_name = "silkie chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/silkie
	chicken_id = "silkie"
	happiness = 0
	favorite_flag = "silkie"
	base_evolution_type = /datum/ranch/evolution/chicken/feed_threshold/silkie

	New()
		. = ..()
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/candy
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/pigeon


	grow_up()
		..()
		if(is_masc)
			name = "silkie rooster"
			real_name = "silkie rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "silkie hen"
			real_name = "silkie hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/silkie_black
	name = "black silkie chick"
	real_name = "black silkie chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/silkie_black
	chicken_id = "silkie_black"
	happiness = 0
	favorite_flag = "silkie_black"
	negative_happiness = TRUE
	//base_evolution_type = /datum/ranch/evolution/chicken/silkie_black

	grow_up()
		..()
		if(is_masc)
			name = "black silkie rooster"
			real_name = "black silkie rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "black silkie hen"
			real_name = "black silkie hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	change_happiness(var/amt)
		..()

	die_of_old_age()
		. = ..()
		if(!is_masc)
			if(src.age >= 666)
				src.visible_message(SPAN_NOTICE("[src] lays one last egg before it shuffles off this mortal coil."))
				egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/dream
				src.lay_egg()
		if(src.age < 666)
			src.visible_message(SPAN_NOTICE("A ghost rises from [src]'s body!"))
			var/mob/living/critter/small_animal/ranch_base/chicken/C = null
			if(src.is_masc)
				C = new/mob/living/critter/small_animal/ranch_base/chicken/ghost/rooster/ai_controlled
			else
				C = new/mob/living/critter/small_animal/ranch_base/chicken/ghost/ai_controlled
			C.grow_up()
			C.set_loc(get_turf(src))

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/silkie_white
	name = "white silkie chick"
	real_name = "white silkie chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/silkie_white
	chicken_id = "silkie_white"
	happiness = 0
	favorite_flag = "silkie_white"
	base_evolution_type = /datum/ranch/evolution/chicken/silkie_white

	New()
		. = ..()
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/sea
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/snow

	grow_up()
		..()
		if(is_masc)
			name = "white silkie rooster"
			real_name = "white silkie rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "white silkie hen"
			real_name = "white silkie hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/brown
	name = "brown chick"
	real_name = "brown chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/brown
	chicken_id = "brown"
	happiness = 0
	favorite_flag = "spicy"
	base_evolution_type = /datum/ranch/evolution/chicken/brown

	New()
		. = ..()
		if(is_masc)
			src.evolutions += new/datum/ranch/evolution/chicken/golden
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/spicy
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/plant
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/raptor

	grow_up()
		..()
		if(is_masc)
			name = "brown rooster"
			real_name = "brown rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "brown hen"
			real_name = "brown hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1


/mob/living/critter/small_animal/ranch_base/chicken/golden
	name = "golden chick"
	real_name = "golden chick"
	chicken_id = "golden"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/golden
	favorite_flag = "glass"
	happiness = 0

	grow_up()
		..()
		if(is_masc)
			name = "golden rooster"
			real_name = "golden rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "golden hen"
			real_name = "golden hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	change_happiness(var/amt)
		..()
		src.happiness -= abs(amt/2)
		src.happiness = max(src.happiness,0)
		egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/golden

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/spicy
	name = "spicy chick"
	real_name = "spicy chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/spicy
	chicken_id = "spicy"
	favorite_flag = "spicy"
	happiness = 0
	attack_ability_type = /datum/targetable/critter/fire_breath
	health_burn_vuln = 0
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/spicy
	//base_evolution_type = /datum/ranch/evolution/chicken/feed_threshold/spicy

	grow_up()
		..()
		if(is_masc)
			name = "spicy rooster"
			real_name = "spicy rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "spicy hen"
			real_name = "spicy hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

#ifdef SECRETS_ENABLED
	special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		. = ..()
		if(E.chicken_egg_props.chicken_id == "onagadori")
			. = /datum/chicken_egg_props/phoenix
#endif

/mob/living/critter/small_animal/ranch_base/chicken/honk
	name = "honkling"
	real_name = "honkling"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/honk
	chicken_id = "honk"
	happiness = 0
	favorite_flag = "honk"
	negative_happiness = TRUE
	base_evolution_type = /datum/ranch/evolution/chicken/feed_threshold/honk

	New()
		. = ..()
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/helium
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/hydrogen
		src.evolutions += new/datum/ranch/evolution/chicken/cluwne
		src.evolutions += new/datum/ranch/evolution/level_up/chicken/honk/mime

	restore_life_processes()
		. = ..()
		add_lifeprocess(/datum/lifeprocess/honk_randomly)

	reduce_lifeprocess_on_death()
		. = ..()
		remove_lifeprocess(/datum/lifeprocess/honk_randomly)

	proc/transform_into_mime()
		var/mob/living/critter/small_animal/ranch_base/chicken/mime/M = null
		if(is_masc)
			M = new /mob/living/critter/small_animal/ranch_base/chicken/mime/rooster/ai_controlled
		else
			M = new /mob/living/critter/small_animal/ranch_base/chicken/mime/ai_controlled

		if(M)
			M.happiness = src.happiness
			M.my_friends = src.my_friends
			M.shit_list = src.shit_list
			M.age = src.age
			M.ageless = src.ageless
			M.immortal = src.immortal
			M.set_loc(get_turf(src))
			qdel(src)


	attackby(var/obj/item/W, mob/user)
		if(istype(W,/obj/item/clothing/mask/cigarette))
			user.visible_message(SPAN_NOTICE("<b>[user]</b> hands [src] a cigarette."),SPAN_NOTICE("You hand [src] a cigarette."))
			src.xp += 1
			user.u_equip(W)
			W.set_loc(src)
			qdel(W)
		else
			. = ..()

	grow_up()
		..()
		if(is_masc)
			name = "honkster"
			real_name = "honkster"
			desc = "What's up, honkster buddy?"
		else
			name = "henk"
			real_name = "henk"
			desc = "Aww, a henk! Honk honk!"
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

	lay_egg()
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E = ..()
		if (src.egg_type == /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_hydrogen)
			E.icon_state += "-blue"
		return E

/mob/living/critter/small_animal/ranch_base/chicken/cluwne
	name = "hueueuhnkling"
	real_name = "hueueuhnkling"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/cluwne
	chicken_id = "cluwne"
	desc = "Oh god. Oh god. Oh jesus christ."
	happiness = -1332
	favorite_flag = "banana"
	hyperaggressive = 1
	befriend_with_pets = FALSE
	befriend_with_feed = FALSE
	attack_ability_type = /datum/targetable/critter/cluwnemask

	restore_life_processes()
		. = ..()
		add_lifeprocess(/datum/lifeprocess/cluwne_honk_randomly)

	reduce_lifeprocess_on_death()
		. = ..()
		remove_lifeprocess(/datum/lifeprocess/cluwne_honk_randomly)

	grow_up()
		..()
		if(is_masc)
			name = "HoNk heunK HONkster"
			real_name = "HoNk heunK HONkster"
			desc = "Oh god. Oh god. Oh jesus christ."
		else
			name = "hueneneuenk"
			real_name = "hueneneuenk"
			desc = "Oh god. Oh god. Oh jesus christ."
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/raptor
	name = "chick (?)"
	real_name = "chick (?)"
	desc = "Aww, a baby chick! Maybe? Looks a bit funny."
	health_brute = 45
	health_burn = 45
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/raptor
	chicken_id = "raptor"
	favorite_flag = "chicken_meat" // I am a monster
	attack_ability_type = /datum/targetable/critter/tackle
	happiness = 0
	species_type = /mob/living/critter/small_animal/ranch_base/chicken/raptor
	befriend_with_feed = FALSE
	happy_pet_message = "walps happily!"
	hens_fight = TRUE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		var/datum/limb/small_critter/claw = HH.limb
		claw.dam_high = 10
		claw.dam_low = 5
		claw.actions = list("tears", "rips", "slashes", "slices")
		claw.max_wclass = 4

	grow_up()
		..()
		if(is_masc)
			name = "raptor tiercel"
			real_name = "raptor tiercel"
			desc = "Clever boy."
		else
			name = "raptor hen"
			real_name = "raptor hen"
			desc = "Clever girl."
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1
		hyperaggressive = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/glass
	name = "glass chick"
	real_name = "glass chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/glass
	chicken_id = "glass"
	happiness = 0
	var/my_reagent_id = null
	var/my_reagent_name = null
	base_evolution_type = /datum/ranch/evolution/chicken/feed_threshold/glass

	New(var/reagent_id = null, reagent_name = null)
		..()
		if(reagent_id && reagent_name)
			my_reagent_id = reagent_id
			my_reagent_name = reagent_name
			name = "[reagent_name]-filled glass chick"
			real_name = "[reagent_name]-filled glass chick"
			logTheThing(LOG_DEBUG, null, "Reagent-producing chicken was born, will make [reagent_name] ([reagent_id])")
			add_lifeprocess(/datum/lifeprocess/chicken/produce_reagent)

		if(!is_masc)
			src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/stone
			src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/wizard

	reduce_lifeprocess_on_death()
		. = ..()
		remove_lifeprocess(/datum/lifeprocess/chicken/produce_reagent)

	restore_life_processes()
		. = ..()
		if(src.my_reagent_id)
			add_lifeprocess(/datum/lifeprocess/chicken/produce_reagent)

	on_reagent_change(add)
		. = ..()
		if(src.my_reagent_id)
			if(src.reagents.total_volume > 0)
				src.color = reagents.get_average_color().to_rgb()

	grow_up()
		..()
		if(src.my_reagent_id)
			if(is_masc)
				name = "[my_reagent_name]-filled glass rooster"
				real_name = "[my_reagent_name]-filled glass rosoter"
			else
				name = "[my_reagent_name]-filled glass hen"
				real_name = "[my_reagent_name]-filled glass hen"
		else
			if(is_masc)
				name = "glass rooster"
				real_name = "glass rooster"
				desc = "What's up, rooster buddy?"
			else
				name = "glass hen"
				real_name = "glass hen"
				desc = "Aww, a chicken! Cluck cluck!"
		return

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if(src.disposed) // destroyed in throw_impact()
			return

		src.visible_message(SPAN_ALERT("[src] shatters!"))
		playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)

		var/list/throw_targets = list()
		for (var/i=1, i<=10, i++)
			throw_targets += get_offset_target_turf(get_turf(src), rand(5)-rand(5), rand(5)-rand(5))

		for(var/i=1, i<=5, i++)
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(get_turf(src))
			G.throw_at(pick(throw_targets), 5, 1)

		src.death(0,1)
		qdel(src)

	lay_egg()
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E = ..()
		if(istype(E))
			if(src.my_reagent_id)
				E.reagents.add_reagent(my_reagent_id,5)
				E.color = E.reagents.get_average_color().to_rgb()
		return E

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/stone
	name = "stone chick"
	real_name = "stone chick"
	health_brute = 75
	health_burn = 75
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/stone
	chicken_id = "stone"
	happiness = 0
	var/my_material = null
	base_evolution_type = /datum/ranch/evolution/chicken/feed_threshold/stone

	New(var/datum/material/source_material = null)
		..()
		if(source_material)
			src.setMaterial(source_material)
			my_material = source_material.getName()
			src.name = "[my_material] chick"
			src.real_name = "[my_material] chick"
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/cockatrice

	grow_up()
		..()
		if(my_material)
			if(is_masc)
				name = "[my_material] rooster"
				real_name = "[my_material] rooster"
				desc = "What's up, rooster buddy?"
			else
				name = "[my_material] hen"
				real_name = "[my_material] hen"
				desc = "Aww, a chicken! Cluck cluck!"
		else
			if(is_masc)
				name = "stone rooster"
				real_name = "stone rooster"
				desc = "What's up, rooster buddy?"
			else
				name = "stone hen"
				real_name = "stone hen"
				desc = "Aww, a chicken! Cluck cluck!"
		return
#ifdef SECRETS_ENABLED
	special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		. = ..()
		if(E.chicken_egg_props.chicken_id == "sea")
			. = /datum/chicken_egg_props/coral
#endif

	proc/explode_into_shards()
		src.visible_message(SPAN_ALERT("[src] shatters!"))
		playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)

		var/list/throw_targets = list()
		for (var/i=1, i<=10, i++)
			throw_targets += get_offset_target_turf(get_turf(src), rand(5)-rand(5), rand(5)-rand(5))

		for(var/i=1, i<=5, i++)
			var/obj/item/raw_material/shard/plasmacrystal/G = new /obj/item/raw_material/shard/plasmacrystal
			if(src.material)
				G.setMaterial(src.material)
			G.set_loc(get_turf(src))
			G.throw_at(pick(throw_targets), 5, 1)

		src.death()
		qdel(src)

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()

		if(weapon?.force >= 10 || special == "explosion")
			src.explode_into_shards()

	ex_act(severity)
		. = ..()
		src.explode_into_shards()

	lay_egg()
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E = ..()
		if(istype(E))
			if(src.material)
				E.setMaterial(src.material)
		return E

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/time
	name = "time chick"
	real_name = "time chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/time
	chicken_id = "time"
	happiness = 0
	favorite_flag = "clockwork"
	immortal = TRUE
	var/turf/maturity_location = null

	New()
		..()

	grow_up()
		..()
		maturity_location = get_turf(src)
		src.AddComponent(/datum/component/afterimage, 10, 0.1 SECONDS)
		if(is_masc)
			name = "time rooster"
			real_name = "time rooster"
			desc = "It's hard to get a good look at it; it seems like it's in multiple places at once!"
		else
			name = "time hen"
			real_name = "time hen"
			desc = "It's hard to get a good look at it; it seems like it's in multiple places at once!"
		return

	change_happiness(var/amt)
		..()

	special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		. = ..()
		if(E.chicken_egg_props.chicken_id == "space")
			. = /datum/chicken_egg_props/power_gold

	death(gibbed, do_drop_equipment)
		. = ..()
		var/datum/component/D = src.GetComponent(/datum/component/afterimage)
		D?.RemoveComponent()

		playsound(src.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)

		elecflash(src,power = 2)

		for(var/mob/O in AIviewers(src, null)) O.show_message(SPAN_ALERT("[src] disappears in a flash of light!!"), 1)

		playsound(src.loc, 'sound/weapons/flashbang.ogg', 25, 1)

		for (var/mob/N in viewers(src, null))
			if (get_dist(N, src) <= 6)
				N.apply_flash(20, 1)
			if (N.client)
				shake_camera(N, 6, 32)

		var/mob/living/critter/small_animal/ranch_base/chicken/time/T = null

		if(src.is_masc)
			T = new/mob/living/critter/small_animal/ranch_base/chicken/time/rooster/ai_controlled
		else
			T = new/mob/living/critter/small_animal/ranch_base/chicken/time/ai_controlled

		T.set_loc(maturity_location)

		T.grow_up()

		src.set_loc(maturity_location)

		for(var/mob/O in AIviewers(T, null)) O.show_message(SPAN_ALERT("[T] appears in a flash of light!!"), 1)

		playsound(T.loc, 'sound/weapons/flashbang.ogg', 25, 1)

		for (var/mob/N in viewers(T, null))
			if (get_dist(N, T) <= 6)
				N.apply_flash(20, 1)
			if (N.client)
				shake_camera(N, 6, 32)

		qdel(src)

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/space
	name = "space chick"
	real_name = "space chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/space
	chicken_id = "space"
	happiness = 0
	favorite_flag = "clockwork"
	immortal = TRUE
	var/turf/maturity_location = null

	grow_up()
		..()
		maturity_location = get_turf(src)
		if(is_masc)
			name = "space rooster"
			real_name = "space rooster"
			desc = "A rooster. In space. Made of space? A space rooster."
		else
			name = "space hen"
			real_name = "space hen"
			desc = "A hen. In space. Made of space? A space hen."
		return

	change_happiness(var/amt)
		..()

	death(gibbed, do_drop_equipment)
		. = ..()

		playsound(src.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)

		elecflash(src,power = 2)

		for(var/mob/O in AIviewers(src, null)) O.show_message(SPAN_ALERT("[src] disappears in a flash of light!!"), 1)

		playsound(src.loc, 'sound/weapons/flashbang.ogg', 25, 1)

		for (var/mob/N in viewers(src, null))
			if (get_dist(N, src) <= 6)
				N.apply_flash(20, 1)
			if (N.client)
				shake_camera(N, 6, 32)

		var/mob/living/critter/small_animal/ranch_base/chicken/space/S = null

		if(src.is_masc)
			S = new/mob/living/critter/small_animal/ranch_base/chicken/space/rooster/ai_controlled
		else
			S = new/mob/living/critter/small_animal/ranch_base/chicken/space/ai_controlled

		S.set_loc(maturity_location)

		S.grow_up()

		src.set_loc(maturity_location)

		for(var/mob/O in AIviewers(S, null)) O.show_message(SPAN_ALERT("[S] appears in a flash of light!!"), 1)

		playsound(S.loc, 'sound/weapons/flashbang.ogg', 25, 1)

		for (var/mob/N in viewers(S, null))
			if (get_dist(N, S) <= 6)
				N.apply_flash(20, 1)
			if (N.client)
				shake_camera(N, 6, 32)

		qdel(src)

	special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		. = ..()
		if(E.chicken_egg_props.chicken_id == "time")
			. = /datum/chicken_egg_props/power_blue

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/power
	name = "space-time chick"
	real_name = "space-time chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/power_blue
	chicken_id = "power_blue"
	happiness = 0
	favorite_flag = "none"
	immortal = TRUE
	health_brute = 300
	health_burn = 300
	attack_ability_type = /datum/targetable/critter/bee_teleport/non_bee

	New()
		. = ..()
		src.AddComponent(/datum/component/afterimage, 5, 0.1 SECONDS)
		SPAWN(5 DECI SECONDS) // prevents runtime where the chicken's dad disappears mid-hatch
			for(var/mob/living/critter/small_animal/ranch_base/chicken/space/S in by_type[/mob/living/critter/small_animal/ranch_base])
				S.visible_message(SPAN_ALERT("<B>[S] melts into the fabric of spacetime.</B>"))
				qdel(S)
			for(var/mob/living/critter/small_animal/ranch_base/chicken/time/T in by_type[/mob/living/critter/small_animal/ranch_base])
				T.visible_message(SPAN_ALERT("<B>[T] melts into the fabric of spacetime.</B>"))
				qdel(T)

			if(src.is_masc)
				if(chicken_id == "power_blue")
					var/mob/living/critter/small_animal/ranch_base/chicken/power/power_gold/ai_controlled/PG = new()
					PG.set_loc(get_turf(src))
				else
					var/mob/living/critter/small_animal/ranch_base/chicken/power/ai_controlled/PB = new()
					PB.set_loc(get_turf(src))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		var/datum/limb/small_critter/claw = HH.limb
		claw.dam_high = 20
		claw.dam_low = 10
		claw.actions = list("tears", "rips", "slashes", "rends")
		claw.max_wclass = 4

	grow_up()
		..()

		if(chicken_id == "power_blue")

			if(is_masc)
				name = "space-time rooster"
				real_name = "space-time rooster"
				desc = "The end of a long journey. The beginning of all things. Its claws are said to rend the stars asunder."
			else
				name = "space-time hen"
				real_name = "space-time hen"
				desc = "The universe may be infinite, but think of how far we've come. The Channel. Precursors. Teleportation. Humankind yearns to reach ever further, but will we ever see the end? The space-time chicken's eggs are said to contain the answer."

		else

			if(is_masc)
				name = "time-space rooster"
				real_name = "time-space rooster"
				desc = "The end of a long journey. The beginning of all things. Its claws are said to cut time itself."
			else
				name = "time-space hen"
				real_name = "time-space hen"
				desc = "Is it not a logical paradox to think of time as having a beginning? If there were a start to time, what could have been \"before\"? The time-space chicken's eggs are said to contain the answer."

		return

	change_happiness(var/amt)
		..()

	death(gibbed, do_drop_equipment, var/kill_partner = 1)
		. = ..()

		if(kill_partner)
			if(chicken_id == "power_blue")
				for(var/mob/living/critter/small_animal/ranch_base/chicken/C in by_type[/mob/living/critter/small_animal/ranch_base])
					if(C.chicken_id == "power_gold")
						C.death(0,1,0)
			else
				for(var/mob/living/critter/small_animal/ranch_base/chicken/C in by_type[/mob/living/critter/small_animal/ranch_base])
					if(C.chicken_id == "power_blue")
						C.death(0,1,0)

		src.lay_egg()
		src.visible_message(SPAN_ALERT("[src] cries out in sorrow and becomes an egg!"))
		qdel(src)

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

	power_gold
		name = "time-space chick"
		real_name = "time-space chick"
		egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/power_gold
		chicken_id = "power_gold"

		rooster
			is_masc = 1

			ai_controlled
				is_npc = 1

		ai_controlled
			is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/plant
	name = "synthchick"
	real_name = "synthchick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/plant
	chicken_id = "plant"
	happiness = 0
	favorite_flag = "synth"
	base_evolution_type = /datum/ranch/evolution/chicken/feed_threshold/plant

	New()
		. = ..()
		evolutions += new/datum/ranch/evolution/chicken/feed_threshold/robot

	grow_up()
		..()
		if(is_masc)
			name = "synthrooster"
			real_name = "synthrooster"
			desc = "What's up, synthrooster buddy?"
		else
			name = "synthhen"
			real_name = "synthhen"
			desc = "Aww, a synthchicken! Cluck cluck!"
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/robot
	name = "robot chick"
	real_name = "robot chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/robot
	chicken_id = "robot"
	happiness = 0
	favorite_flag = "robot"
	attack_ability_type = /datum/targetable/critter/zzzap

	grow_up()
		..()
		if(is_masc)
			name = "robot rooster"
			real_name = "robot rooster"
			desc = "What's up, rooster bot?"
		else
			name = "robot hen"
			real_name = "robot hen"
			desc = "Aww, a robot chicken! Beep Beep!"
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/purple
	name = "void chick"
	real_name = "void chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/purple
	chicken_id = "purple"
	happiness = 0
	favorite_flag = "eggplant"

	grow_up()
		..()
		if(is_masc)
			name = "void rooster"
			real_name = "void rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "void hen"
			real_name = "robot hen"
			desc = "Aww, a chicken! Cluck Cluck!"
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/candy
	name = "cotton candy chick"
	real_name = "cotton candy chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/candy
	chicken_id = "candy"
	happiness = 0
	favorite_flag = "sugar"
	health_brute = 50
	base_evolution_type = /datum/ranch/evolution/chicken/feed_threshold/candy
	density = 1
	forgive_species = TRUE
	forgive_timer = 3

	New()
		. = ..()
#ifdef SECRETS_ENABLED
		src.evolutions += new/datum/ranch/evolution/level_up/chicken/candy/zappy
#endif
	Life(datum/controller/process/mobs/parent)
		. = ..()
		if(src.stage != RANCH_STAGE_CHILD)
			if(prob(30) && !src.density)
				src.changeStatus("sugar_rush",60)

	grow_up()
		..()
		if(is_masc)
			name = "cotton candy rooster"
			real_name = "cotton candy rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "cotton candy hen"
			real_name = "cotton candy hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	Crossed(atom/movable/AM)
		. = ..()
		if(!(isintangible(AM) || isobserver(AM)) && src.hasStatus("sugar_rush"))
			bump(AM)

	bump(atom/A)
		. = ..()
		if(src.throwing)
			src.xp += 1
			var/mob/living/critter/small_animal/ranch_base/chicken/candy/N = A
			if(istype(N))
				src.xp += 10
				N.xp += 10
				playsound(src, "sound/effects/sparks[rand(1,6)].ogg", 25, 1,extrarange = -25)
				elecflash(src)

	change_happiness(var/amt)
		..()

	special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		. = ..()
		if(E.chicken_egg_props.chicken_id == "snow")
			. = /datum/chicken_egg_props/popsicle

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/sea
	name = "selkie chick"
	real_name = "selkie chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/sea
	chicken_id = "sea"
	happiness = 0
	favorite_flag = "fish"

	var/out_of_water_debuff = 2
	var/in_water_buff = 2
	var/datum/lifeprocess/aquatic_breathing/aquabreath_process = null

	restore_life_processes()
		. = ..()
		aquabreath_process = add_lifeprocess(/datum/lifeprocess/aquatic_breathing,src.in_water_buff,src.out_of_water_debuff)

	reduce_lifeprocess_on_death()
		. = ..()
		remove_lifeprocess(/datum/lifeprocess/aquatic_breathing)

	Move(NewLoc, direct)
		. = ..()
		if(src.aquabreath_process.water_need && prob(20 * src.aquabreath_process.water_need))
			hit_twitch(src)
			src.visible_message("<b>[src]</b> [pick("flops around desperately","gasps","shudders")].")

	grow_up()
		..()
		if(is_masc)
			name = "selkie rooster"
			real_name = "selkie rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "sea hen"
			real_name = "sea hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	change_happiness(var/amt)
		..()

#ifdef SECRETS_ENABLED
	special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		. = ..()
		if(E.chicken_egg_props.chicken_id == "stone")
			. = /datum/chicken_egg_props/coral
#endif

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/dream
	name = "dream chick"
	real_name = "dream chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/dream
	chicken_id = "dream"
	happiness = 0
	favorite_flag = "silkie_black"
	egg_cooldown = 60

	grow_up()
		..()
		if(is_masc)
			name = "dream rooster"
			real_name = "dream rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "dream hen"
			real_name = "dream hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/pet
	name = "ixworth chick"
	real_name = "ixworth chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/pet
	chicken_id = "pet"
	happiness = 0
	favorite_flag = "tomato"
	egg_cooldown = 60

	grow_up()
		..()
		if(is_masc)
			name = "ixworth rooster"
			real_name = "ixworth rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "ixworth hen"
			real_name = "ixworth hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/balloon
	name = "balloon chick"
	real_name = "balloon chick"
	desc = "They're quite pop-ular."
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_helium
	chicken_id = "balloon"
	happiness = 0
	favorite_flag = "helium"
	egg_cooldown = 60
	//nitrogen is dangerous
	var/explosive = FALSE
	var/explosion_power = 10

	grow_up()
		..()
		if(is_masc)
			name = "ballooster"
			real_name = "balloon rooster"
			desc = "A [src], it's value keeps going up due to inflation."
		else
			name = "balloon hen"
			real_name = "balloon hen"
			desc = "A [src], no strings attached."

	change_happiness(var/amt = 0)
		src.happiness += amt
		if(is_masc)
			if(get_feed_count("hydrogen") >= feed_count_threshold && get_feed_count("helium") >= feed_count_threshold)
				egg_type = pick(/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_hydrogen, /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_helium)
			else if(get_feed_count("hydrogen") >= feed_count_threshold)
				egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_hydrogen
			else if(get_feed_count("helium") >= feed_count_threshold)
				egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_helium
		else
			if(get_feed_count("hydrogen") >= feed_count_threshold && get_feed_count("helium") >= feed_count_threshold)
				egg_type = pick(/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_hydrogen, /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_helium)
			else if(get_feed_count("hydrogen") >= feed_count_threshold)
				egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_hydrogen
			else if(get_feed_count("helium") >= feed_count_threshold)
				egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_helium

	lay_egg()
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E = ..()
		if (src.egg_type == /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_hydrogen)
			E.icon_state += "-blue"
		return E

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		. = ..()
		if(src.explosive && src.hasStatus("burning"))
			explosion_new(src, get_turf(src), explosion_power)
			fireflash(get_turf(src), 1)
			src.explosive = FALSE

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/snow
	name = "snow chick"
	real_name = "snow chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/snow
	chicken_id = "snow"
	happiness = 0
	favorite_flag = "snow"
	base_body_temp = T0C
	temp_tolerance = 10

	New()
		. = ..()
		src.bodytemperature = src.base_body_temp

	restore_life_processes()
		. = ..()
		add_lifeprocess(/datum/lifeprocess/melt,5)
		add_lifeprocess(/datum/lifeprocess/bodytemp)

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if(prob(10))
			if (!locate(/obj/decal/icefloor) in get_turf(src))
				var/obj/decal/icefloor/B = new /obj/decal/icefloor(get_turf(src))
				SPAWN(5 SECONDS)
					qdel (B)

	is_cold_resistant()
		return TRUE

	grow_up()
		..()
		if(is_masc)
			name = "snow rooster"
			real_name = "snow rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "snow hen"
			real_name = "snow hen"
			desc = "Aww, a chicken! Cluck cluck!"
		return

	change_happiness(var/amt)
		..()

	special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		. = ..()
		if(E.chicken_egg_props.chicken_id == "candy")
			. = /datum/chicken_egg_props/popsicle

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/datum/lifeprocess/melt
	var/damage_amount = 5

	New(new_owner,arguments)
		. = ..()
		if(length(arguments) >= 1)
			damage_amount = arguments[1]

	process()
		var/mob/living/L = owner
		if(istype(L))
			if(L.bodytemperature >= (L.base_body_temp + L.temp_tolerance))
				L.TakeDamage("All",0,damage_amount,0,DAMAGE_BURN)
			else if (L.bodytemperature <= (L.base_body_temp - L.temp_tolerance))
				L.TakeDamage("All",0,-damage_amount,0,DAMAGE_BURN)



/mob/living/critter/small_animal/ranch_base/chicken/ghost
	name = "ghost chick"
	real_name = "ghost chick"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/ghost
	chicken_id = "ghost"
	happiness = 0
	favorite_flag = "ghost"
	immortal = 1
	hyperaggressive = TRUE
	befriend_with_feed = FALSE
	befriend_with_pets = FALSE

	grow_up()
		..()
		if(is_masc)
			name = "ghost rooster"
			real_name = "ghost rooster"
			desc = "Some say that these roosters appear to avenge abused chickens."
		else
			name = "ghost hen"
			real_name = "ghost hen"
			desc = "This poor hen is mourning the life of a poorly treated creature."
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/wizard
	name = "chick adept"
	real_name = "chick adept"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/wizard
	chicken_id = "wizard"
	happiness = 0
	favorite_flag = "wizard"
	attack_ability_type = /datum/targetable/critter/magic_missile
	var/hoard_size = 0

	base_evolution_type = /datum/ranch/evolution/level_up/chicken/wizard

	New()
		. = ..()
		src.evolutions += new/datum/ranch/evolution/level_up/chicken/wizard/two
		src.evolutions += new/datum/ranch/evolution/level_up/chicken/wizard/three
#ifdef SECRETS_ENABLED
		src.evolutions += new/datum/ranch/evolution/level_up/chicken/wizard/dragon
#endif

	attackby(obj/item/I, mob/M)
		if(istype(I,/obj/item/currency/spacecash))
			var/obj/item/currency/spacecash/cash = I
			M.visible_message(SPAN_NOTICE("<b>[M]</b> hands [src] some cash."),SPAN_NOTICE("You hand [src] some cash."))
			src.say("Bawk!")
			src.visible_message(SPAN_NOTICE("<b>[src]</b> pockets the cash for later."))
			M.u_equip(I)
			I.set_loc(src)
			src.xp += cash.amount
			qdel(I)
		else
			. = ..()

	grow_up()
		..()
		if(is_masc)
			name = "Wizster"
			real_name = "Wizster"
			desc = "Woah! It's a wizster!"
		else
			name = "Witchen"
			real_name = "Witchen"
			desc = "Hey! It's a witchen!"
		return

	change_happiness(var/amt)
		..()

	death(gibbed, do_drop_equipment)
		. = ..()
		var/obj/item/clothing/head/wizard/W = new()
		W.set_loc(get_turf(src))

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/pigeon
	name = "chick"
	real_name = "chick"
	desc = "You're pretty sure that's not a chicken!"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/pigeon
	chicken_id = "pigeon"
	happiness = 0
	favorite_flag = "peas"
	open_to_sound = TRUE

	New()
		. = ..()
		var/obj/item/device/radio/pigeon/P = new/obj/item/device/radio/pigeon(src)
		P.toggle_microphone(FALSE)


	grow_up()
		..()
		if(is_masc)
			name = "Messenger Pigeon"
			real_name = "Messenger Pigeon"
			desc = "It hatched from a chicken egg, but that's no rooster!"
		else
			name = "Messenger Pigeon Hen"
			real_name = "Messenger Pigeon Hen"
			desc = "It hatched from a chicken egg, but that's no hen!"
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/cockatrice
	name = "chick?"
	real_name = "chick?"
	desc = "Uh oh, uh, hmm..."
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/cockatrice
	chicken_id = "cockatrice"
	happiness = 0
	favorite_flag = "lizard"
	attack_ability_type = /datum/targetable/critter/medusa
	hyperaggressive = TRUE
	befriend_with_feed = FALSE

	grow_up()
		..()
		if(is_masc)
			name = "Cockatrice"
			real_name = "Cockatrice"
			desc = "The mythical cockatrice, said to be able to turn people to stone with a stare. People say a lot of things, though."
		else
			name = "Cockatrice Hen"
			real_name = "Cockatrice Hen"
			desc = "The mythical cockatrice, said to be born of an egg laid on the full moon, hatched by a toad. People say a lot of things, though."
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/popsicle
	name = "dreamsicle chick"
	real_name = "dreamsicle chick"
	desc = "A cute lil soft serve! Better keep it cold!"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/popsicle
	chicken_id = "popsicle"
	happiness = 0
	favorite_flag = "icecream"

	New()
		. = ..()
		src.bodytemperature = src.base_body_temp

	restore_life_processes()
		. = ..()
		add_lifeprocess(/datum/lifeprocess/melt,5)
		add_lifeprocess(/datum/lifeprocess/bodytemp)

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if(prob(10))
			if (!locate(/obj/decal/icefloor) in get_turf(src))
				var/obj/decal/icefloor/B = new /obj/decal/icefloor(get_turf(src))
				SPAWN(5 SECONDS)
					qdel (B)

	grow_up()
		..()
		if(is_masc)
			name = "Dreamsicle Rooster"
			real_name = "Dreamsicle Rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "Dreamsicle Hen"
			real_name = "Dreamsicle Hen"
			desc = "Aw, a chicken! Cluck cluck!"
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/onagadori
	name = "onagadori chick"
	real_name = "onagadori chick"
	desc = "Its tail hasn't grown in yet, how cute!"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/onagadori
	chicken_id = "onagadori"
	happiness = 0
	favorite_flag = "peanut"
	base_evolution_type = /datum/ranch/evolution/chicken/feed_threshold/onagadori

	New()
		. = ..()
		src.evolutions += new/datum/ranch/evolution/chicken/feed_threshold/knight

	grow_up()
		..()
		if(is_masc)
			name = "Onagadori Rooster"
			real_name = "Onagadori Rooster"
			desc = "What's up, rooster buddy?"
		else
			name = "Onagadori Hen"
			real_name = "Onagadori Hen"
			desc = "Aw, an onagadori! In some cultures, they're called \"phoenix\" chickens!"
		return

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

#ifdef SECRETS_ENABLED
	special_hatch(var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E)
		. = ..()
		if(E.chicken_egg_props.chicken_id == "spicy")
			. = /datum/chicken_egg_props/phoenix
#endif

/mob/living/critter/small_animal/ranch_base/chicken/knight
	name = "chick squire"
	real_name = "chick squire"
	desc = "Its little practice sword is so cute!"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/knight
	chicken_id = "knight"
	happiness = 0
	favorite_flag = "metal"
	hens_fight = 1

	grow_up()
		..()
		if(is_masc)
			name = "Fowlchion"
			real_name = "Fowlchion"
			desc = "Trained in the chivalrous art of doodle-doo-good."
		else
			name = "Shieldmaidhen"
			real_name = "Shieldmaidhen"
			desc = "Knowledgeble of many acts both galant and gallina-nt."
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1

/mob/living/critter/small_animal/ranch_base/chicken/mime
	name = "mime chick"
	real_name = "mime chick"
	desc = "..."
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/mime
	chicken_id = "mime"
	happiness = 0
	favorite_flag = "nicotine"
	attack_ability_type = /datum/targetable/critter/mime_cage
	happy_pet_message = "looks happy."

	grow_up()
		..()
		if(is_masc)
			name = "mime rooster"
			real_name = "mime rooster"
			desc = "..."
		else
			name = "mime hen"
			real_name = "mime hen"
			desc = "..."
		return

	change_happiness(var/amt)
		..()

	rooster
		is_masc = 1

		ai_controlled
			is_npc = 1

	ai_controlled
		is_npc = 1
