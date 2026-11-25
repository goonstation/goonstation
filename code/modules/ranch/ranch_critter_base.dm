/obj/ranch_status_bubble
	icon = 'icons/misc/ranch/ranch_status_bubble.dmi'
	icon_state = null

/mob/living/critter/small_animal/ranch_base
	name = "base ranch critter"
	desc = "somebody fucked up if you're seeing this!"
	gender = PLURAL
	player_can_spawn_with_pet = FALSE
	ailment_immune = TRUE
	has_genes = FALSE
	/// sound the critter makes when doing a scream emote
	var/critter_scream_sound = null
	/// pitch used when playing chicken scream sound
	var/critter_scream_pitch = 2

	var/age = 0

	var/xp = 0
	///used for level up evolutions

	/// stage of life
	var/stage = RANCH_STAGE_CHILD
	var/hunger = 0
	var/happiness = 10

	///list of possible evolutions
	var/list/datum/ranch/evolution/evolutions = null
	/// current evolution, if any
	var/datum/ranch/evolution/evolved = null
	/// base evolution
	var/base_evolution_type = null
	var/datum/ranch/evolution/base_evolution = null

	///immortal = does not need food, does not grow old, and does not die of old age
	var/immortal = 0
	/// ageless = extends lifespan beyond normal limits
	var/ageless = 0

	///is happiness allowed to go negative?
	var/negative_happiness = FALSE

	var/is_masc = 0

	var/list/shit_list = null
	var/shit_list_distance = FLEE_DISTANCE

	///will the mob forgive entries on its shit list on its own?
	var/forgiving = FALSE
	var/forgive_species = FALSE
	var/forgive_timer = 10


	var/attack_ability_type = /datum/targetable/critter/peck
	var/datum/targetable/attack_ability = null

	/// associative list containing all of our feed flags and counts
	var/list/feed_counts = null
	var/feed_count_threshold = 7

	var/hyperaggressive = 0
	var/list/my_friends = null

	var/befriend_with_pets = TRUE
	var/befriend_with_feed = TRUE

	var/happy_pet_message = "clucks happily!"

	/// used so that hyperaggressive creatures don't kill their babies
	/// by default, critters should show global species solidarity
	var/species_type = null

	/// if you set this, you need to set the special ai in the subtype's New()
	var/has_special_ai = 0

	/// what food does this chicken really like?
	var/favorite_flag = "rice"

	var/obj/ranch_status_bubble/status_bubble = null

	///the number of nearby ranch animals nearby before the animal starts feeling crowded
	var/crowded_minimum = 15
	///the amount of unhappiness per cycle per each neighbor in excess of the crowding minimum
	var/crowding_coefficient = 2

	ai_retaliates = FALSE //we handle our own retaliation behaviour

	/// Our pair-bonded creature, if it exists
	var/mob/living/critter/small_animal/ranch_base/mate = null

	/// Our current child, if it exists
	var/mob/living/critter/small_animal/ranch_base/baby = null

	/// Our parent to follow, if it exists
	var/mob/parent = null

	/// Controls whether our baby version is impressionable and can imprint on mobs
	var/impressionable = 0

	///Fully Automated Gay Space Communism
	var/gender_preference = 0

	/// life ticks between until next egg attempt
	var/egg_cooldown = 25
	/// life ticks remaining until next egg attempt
	var/egg_timer = 0
	/// guarantee an egg within this many attempts
	var/egg_pity_limit = 5
	/// number of failed attempts since last succesful egg laying
	var/egg_pity_count = 0

	var/egg_type = null

	var/can_be_named = TRUE
	var/named = null

	New()
		..()
		START_TRACKING
		shit_list = list()
		my_friends = list()
		feed_counts = list()
		evolutions = list()
		abilityHolder.addAbility(/datum/targetable/critter/eat_feed)

		if(base_evolution_type)
			base_evolution = new base_evolution_type
			base_evolution.evolution_priority = -1

		status_bubble = new()
		src.vis_contents += status_bubble
		status_bubble.vis_flags |= VIS_INHERIT_ID

		if(attack_ability_type)
			attack_ability = abilityHolder.addAbility(attack_ability_type)

			src.RemoveElement(/datum/element/lifeprocess/blindness)

		if(!gender_preference)
			var/roll = rand(1,100)
			switch(roll)
				if(1 to 4)
					gender_preference |= RANCH_PREFERENCE_SAME
				if(5 to 8)
					gender_preference |= RANCH_PREFERENCE_SAME
					gender_preference |= RANCH_PREFERENCE_DIFF
				if(9 to 10)
					gender_preference |= RANCH_PREFERENCE_NONE
				else
					gender_preference |= RANCH_PREFERENCE_DIFF

	restore_life_processes()
		. = ..()
		src.AddElement(/datum/element/lifeprocess/ranch/age)
		src.AddElement(/datum/element/lifeprocess/ranch/hunger)
		src.AddElement(/datum/element/lifeprocess/ranch/evolution)
		src.AddElement(/datum/element/lifeprocess/ranch/crowding)
		src.AddElement(/datum/element/lifeprocess/chemical)

	disposing()
		qdel(src.evolved)
		src.evolved = null
		qdel(src.base_evolution)
		src.base_evolution = null

		src.evolutions = null
		src.shit_list = null
		src.my_friends = null
		src.attack_ability = null

		qdel(src.status_bubble)
		src.status_bubble = null

#ifdef SECRETS_ENABLED
		src.secret_cleanup()
#endif

		STOP_TRACKING
		. = ..()

	attackby(obj/item/I, mob/M)
		var/obj/item/ranch_nametag/tag = I
		if(istype(tag))
			if(src.can_be_named)
				if(tag.critter_name)
					if(!src.named)
						src.name = tag.critter_name
						src.real_name = tag.critter_name
						src.named = tag.critter_name
						M.visible_message(SPAN_NOTICE("<b>[M]</b> loops the nametag around [src]'s neck")
											,SPAN_NOTICE("You loop the nametag around [src]'s neck"))
						M.u_equip(I)
						I.set_loc(src)
						qdel(I)
					else
						boutput(M, SPAN_NOTICE("They've already been named!"))
				else
					boutput(M, SPAN_NOTICE("That nametag is empty!"))
			else
				boutput(M, SPAN_NOTICE("They reject your attempt to name them."))
			return
		. = ..()

	Life(datum/controller/process/mobs/parent)
		..()
		if(!can_lie && !isdead(src))
			can_lie = 1

	get_desc(dist, mob/user)
		. = ..()
		if (src.stage == RANCH_STAGE_SENIOR)
			. += "<br>This animal looks rather old and probably won't be able to produce anything."

	reduce_lifeprocess_on_death()
		. = ..()
		src.RemoveElement(/datum/element/lifeprocess/ranch/age)
		src.RemoveElement(/datum/element/lifeprocess/ranch/hunger)

	was_harmed(mob/M as mob, obj/item/weapon = 0, special = 0, intent = null)
		if(src.ai)
			if(!isalive(src))
				return ..()
			if(weapon || (!isnull(intent) && intent != INTENT_GRAB) || isnull(intent))
				SPAWN(0) // prevents this message from coming before the attack that caused it
					src.visible_message(SPAN_ALERT("[src] cries out in pain!"))
				src.gossip(M)
			return ..()

	proc/gossip(mob/M)
		if(!M)
			return
		src.update_friendlist(M,remove = 1)

		for(var/mob/living/critter/small_animal/ranch_base/C in view(src.shit_list_distance, src))
			if(istype(C,src.species_type))
				C.update_shitlist(M)

	proc/grow_old()
		stage = RANCH_STAGE_SENIOR
		return

	proc/die_of_old_age()
		death_text = "%src% dies of old age! Good night, %src%."
		src.death(0,1)
		return

	proc/die_of_hunger()
		death_text = "%src% dies of hunger! How cruel."
		src.death(0,1)
		return

	proc/grow_up()
		stage = RANCH_STAGE_ADULT
		if(src.ai)
			src.ai.stop_move()
			src.ai.interrupt()

/// stuff to do after all growing up code is run
	proc/after_grow_up()
		if(src.named)
			src.name = named
			src.real_name = named
		return

	proc/update_shitlist(var/mob/M, var/remove = FALSE)
		if(M == src)
			return
		if(remove)
			if(M in src.shit_list)
				shit_list.Remove(M)
				UnregisterSignal(M, COMSIG_MOB_DEATH)
		else
			if(src.ai)
				if(!(M in src.shit_list))
					if(!(M in src.my_friends))
						if(src.faction)
							if(!faction_check(src, M))
								return
						src.shit_list |= list(M)
						RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(cleanup_lists))
						src.ai.stop_move()
						src.ai.interrupt()
						if(src.forgiving || (src.forgive_species && istype(M,src.species_type)))
							SPAWN(forgive_timer SECONDS)
								src.update_shitlist(M,TRUE)


	proc/update_friendlist(var/mob/M, var/remove = FALSE)
		if(M == src)
			return
		if(remove)
			if(M in src.my_friends)
				my_friends.Remove(M)
				UnregisterSignal(M, COMSIG_MOB_DEATH)
		else
			if(src.ai)
				if(!(M in src.my_friends))
					if(!(M in src.shit_list))
						src.my_friends |= list(M)
						RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(cleanup_lists))
						src.ai.stop_move()
						src.ai.interrupt()

	proc/cleanup_lists(var/mob/M)
		src.update_shitlist(M, TRUE)
		src.update_friendlist(M, TRUE)

	proc/create_child(var/mob/M)
		return

	can_eat(var/atom/A)
		if(isalive(src))
			if(istype(A,/obj/item/reagent_containers/food/snacks/ranch_feed_bag))
				return 1
		return 0

	on_eat(var/atom/A, mob/feeder)
		if(istype(A,/obj/item/reagent_containers/food/snacks/ranch_feed_bag))
			var/obj/item/reagent_containers/food/snacks/ranch_feed_bag/B = A
			var/obj/decal/cleanable/ranch_feed/F = B.make_feed(B)
			src.on_eat_feed(F)
			qdel(F)

			if(src.befriend_with_feed && feeder)
				src.update_shitlist(feeder,remove = 1)
				src.update_friendlist(feeder)

	butcher(mob/M, drop_brain = FALSE, drop_meat = TRUE)
		. = ..()

	/// update the count of a feed flag by a given value
	proc/update_feed_count(feed_flag, feed_value = 1)
		if (feed_flag in src.feed_counts)
			src.feed_counts[feed_flag] += feed_value
		else
			src.feed_counts[feed_flag] = feed_value

	/// set the count of a feed flag to the given value
	proc/set_feed_count(feed_flag, feed_value = 0)
		src.feed_counts[feed_flag] = feed_value

	/// return the value of a feed flag if we have it, else return 0
	proc/get_feed_count(feed_flag)
		if (feed_flag in src.feed_counts)
			return src.feed_counts[feed_flag]
		else
			return 0

	proc/show_status(var/status)
		FLICK("status-[status]",status_bubble)

	proc/change_happiness(var/amt = 0)
		src.happiness += amt
		if(!src.negative_happiness)
			src.happiness = max(src.happiness,0)
		return

	proc/on_eat_feed(var/obj/decal/cleanable/ranch_feed/F)
		var/status = null
		var/favorite = 0
		var/happiness_amt = F.happiness_mod + 5
		var/hunger_amt = 20 + F.hunger_mod

		for(var/flag in F.feed_flags)
			// update our feed counts for the given flag
			update_feed_count(flag)
			// do some special stuff based on the flag too
			var/list/adj = null
			adj = special_feed_behavior(flag, happiness_amt, hunger_amt)
			happiness_amt = adj[1]
			hunger_amt = adj[2]

			if(flag == src.favorite_flag)
				favorite = 1

		if(favorite)
			status = "love"
		else if(happiness_amt >= 5)
			status = "happy_plus"
		else if (happiness_amt > 0)
			status = "happy"
		else if (happiness_amt <= -5)
			status = "sick"
		else if (happiness_amt < 0)
			status = "sad"
		else
			status = "neutral"
#ifdef SECRETS_ENABLED
			if (rand(1,1000) == 1)
				status = src.do_a_secret_thing()
#endif

		if(favorite)
			happiness_amt = abs(happiness_amt) + 5
			hunger_amt = abs(hunger_amt) + 5

		if(hunger < -50)
			status = "sick"
			src.visible_message(SPAN_ALERT("[src] looks sick from overeating!"))
			if(happiness_amt > -100)
				happiness_amt = max(-100, (happiness_amt -100))
			hunger_amt = 0
			SPAWN(3 SECONDS)
				src.vomit()
				src.hunger = 0
		if(!isnull(status))
			src.show_status(status)
		src.change_happiness(happiness_amt)
		src.hunger -= hunger_amt

	proc/special_feed_behavior(var/flag, var/happiness_amt, var/hunger_amt)
		return list(happiness_amt, hunger_amt)

	vomit(var/nutrition=0, var/specialType=null, var/flavorMessage="[src] vomits!", var/selfMessage = null)
		. = ..()
		if(.)
			update_feed_count("purple")
			for (var/flag in src.feed_counts)
				if (flag == "purple") continue
				if (get_feed_count(flag) > 0)
					update_feed_count(flag, -1)

	full_heal()
		if(isdead(src))
			// Re-age them to ensure the name is correct
			if(src.stage == RANCH_STAGE_CHILD)
				src.name = initial(name)
				src.real_name = "[src.name]"
				src.desc = initial(desc)
			if(src.stage >= RANCH_STAGE_ADULT)
				src.grow_up()
				src.after_grow_up()
			if(src.stage >= RANCH_STAGE_SENIOR)
				src.grow_old()
		. = ..()
