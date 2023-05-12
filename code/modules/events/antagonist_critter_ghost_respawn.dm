//defines an item drop table
/datum/event_item_drop_table
	var/list/potential_drop_items
	var/remove_dropped_items
	var/number_of_rolls
	var/percent_droprate
	var/pity_drop_atleast_one //if no item(s) at all dropped after rolling, just drop a single random one from the list

	proc/roll_for_items()
		var/list/dropped_items = list()
		var/list/potential_drops = potential_drop_items.Copy()
		for (var/i = 1 to number_of_rolls)
			if (potential_drops && length(potential_drops))
				if (prob(src.percent_droprate))
					var/item_to_drop = pick(potential_drops)
					if (remove_dropped_items)
						potential_drops -= item_to_drop
					dropped_items += item_to_drop

		if (pity_drop_atleast_one)
			if (!length(dropped_items)) //dropped_items is empty, aka we didn't drop any item, initiate pity drop
				dropped_items += pick(potential_drops)
		return dropped_items

	New(potential_drop_items, remove_dropped_items = 0, number_of_rolls = 1, percent_droprate = 100, pity_drop_atleast_one = 0)
		..()
		src.potential_drop_items = potential_drop_items
		src.remove_dropped_items = remove_dropped_items
		src.number_of_rolls = number_of_rolls
		src.percent_droprate = percent_droprate
		src.pity_drop_atleast_one = pity_drop_atleast_one


//defines an event critter as well as any possible drop tables
/datum/eventSpawnedCritter
	var/list/critter_types // can be a list of just one, if multiple are present then one is picked at random, so similar mobs can be grouped together
	var/list/datum/event_item_drop_table/drop_tables
	var/name = null

	proc/roll_for_items()
		var/list/items_to_drop = list()
		var/datum/event_item_drop_table/drop_table
		for (drop_table in src.drop_tables)
			var/drop_table_dropped_items = drop_table.roll_for_items()
			if (drop_table_dropped_items && length(drop_table_dropped_items))
				items_to_drop.Add(drop_table.roll_for_items())

		return items_to_drop

	New(name, critter_types, drop_tables)
		..()
		src.name = name
		src.critter_types = critter_types
		src.drop_tables = drop_tables


//very similar to playable_pests.dm :)
/datum/random_event/major/player_spawn/antag/antagonist_pest
	name = "Antagonist Critter Spawn"
	customization_available = 1
	targetable = TRUE
	var/num_critters = 0
	var/critter_type = null
#ifdef RP_MODE
	disabled = 1
#endif

	required_elapsed_round_time = 5 MINUTES

	var/ghost_confirmation_delay = 1 MINUTES // time to acknowledge or deny respawn offer.

	var/list/pest_invasion_critter_datums = list(
		list(new /datum/eventSpawnedCritter(
			name = "spiders",
			critter_types = list(/mob/living/critter/spider/baby),
			drop_tables = list(
				new /datum/event_item_drop_table(  // several baby spiders crawl out of the corpse like those horror short videos oh no
					potential_drop_items = list(/mob/living/critter/spider/baby),
					number_of_rolls = 6
					),
				new /datum/event_item_drop_table(  // but on the bright side it drops an egg!
					potential_drop_items = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/clown, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/cluwne,
																			/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/nicespider, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/parrot,
																			/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/skeleton, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/goose),
					)
				)
			)
		) = 100,
		list(new /datum/eventSpawnedCritter(
			name = "fire elementals",
			critter_types = list(/mob/living/critter/fire_elemental),
			drop_tables = list(
				new /datum/event_item_drop_table(
					potential_drop_items = list(/obj/item/mutation_orb/fire_orb, /obj/item/rejuvenation_feather, /obj/item/property_setter/fire_jewel)
					)
				)
			)
		) = 100,
		list(new /datum/eventSpawnedCritter(
			name = "gunbots",
			critter_types = list(/mob/living/critter/robotic/gunbot),
			drop_tables = list(
				new /datum/event_item_drop_table(
					potential_drop_items = list(/obj/item/property_setter/reinforce, /obj/item/property_setter/thermal, /obj/item/property_setter/speedy),
					remove_dropped_items = 1, number_of_rolls = 3, percent_droprate = 50, pity_drop_atleast_one = 1
					)
				)
			)
		) = 100,
		list(new /datum/eventSpawnedCritter(
			name = "emagged bots",
			critter_types = list(/mob/living/critter/robotic/bot/cleanbot/emagged, /mob/living/critter/robotic/bot/firebot/emagged),
			drop_tables = list(
				new /datum/event_item_drop_table(
					potential_drop_items = list(/obj/item/property_setter/reinforce, /obj/item/property_setter/thermal, /obj/item/property_setter/speedy),
					remove_dropped_items = 1, number_of_rolls = 3, percent_droprate = 50, pity_drop_atleast_one = 1
					)
				)
			)
		) = 100,
		list(new /datum/eventSpawnedCritter(
			name = "jean elementals",
			critter_types = list(/mob/living/critter/jeans_elemental),
			drop_tables = list(
				new /datum/event_item_drop_table(
					potential_drop_items = list(/obj/item/property_setter/reinforce, /obj/item/property_setter/thermal, /obj/item/property_setter/speedy),
					remove_dropped_items = 1, number_of_rolls = 2, percent_droprate = 30, pity_drop_atleast_one = 0
					)
				)
			)
		) = 10,
		list(new /datum/eventSpawnedCritter(
			name = "mimics",
			critter_types = list(/mob/living/critter/mimic/antag_spawn)
			)
		) = 100, //no loot for mimics
	)

	admin_call(var/source)
		if (..())
			return

		switch (alert(usr, "Choose the critter type?", src.name, "Random", "Custom"))
			if ("Custom")
				src.critter_type = input("Enter a /mob/living/critter path or partial name", src.name, null) as null|text
				src.critter_type = get_one_match(src.critter_type, "/mob/living/critter")
				if (!src.critter_type)//invalid entry
					return
			if ("Random") //random
				src.critter_type = null

		src.num_critters = input(usr, "How many critter antagonists to spawn? ([length(eligible_dead_player_list(allow_dead_antags = TRUE))] players eligible)", src.name, 0) as num|null
		if (!src.num_critters || src.num_critters < 1)
			cleanup()
			return
		else
			src.num_critters = round(src.num_critters)

		//confirmation
		if (alert(usr, "You have chosen to spawn [src.num_critters] [src.critter_type ? src.critter_type : "random critters"]. Is this correct?", src.name, "Yes", "No") == "Yes")
			event_effect(source)
		else
			cleanup()

	event_effect(var/source)
		..()

		var/critter_name = "unknown mystery critters"
		var/list/select = null
		if (src.critter_type)
			select = src.critter_type
			var/atom/dummy = src.critter_type
			critter_name = initial(dummy.name) + "s"
		else
			select = weighted_pick(src.pest_invasion_critter_datums)
			#ifdef APRIL_FOOLS
			while(TRUE)
				var/datum/eventSpawnedCritter/esc = select[1]
				if(esc.name != "jean elementals")
					select = pick(src.pest_invasion_critter_datums)
				else
					break
			#endif
			var/list/name_list = list()
			for (var/datum/eventSpawnedCritter/C in select)
				if(C.name)
					name_list += C.name
			if(length(name_list))
				critter_name = english_list(name_list)

		SPAWN(0)
			// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
			var/list/text_messages = list()
			text_messages.Add("Would you like to respawn as one of a team of [critter_name] (antagonist critters)? You may be randomly selected from the list of candidates.")
			text_messages.Add("You are eligible to be respawned as one of the [critter_name] (antagonist critters)?. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
			text_messages.Add("You have been added to the list of eligible candidates. Please wait for the game to choose, good luck!")

			// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
			message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
			var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)


			if (!length(candidates))
				cleanup()
				global.random_events.next_spawn_event = TIME + 1 MINUTE
				return

			var/list/EV = list()
			for (var/landmark_type in list(LANDMARK_PESTSTART, LANDMARK_MONKEY, LANDMARK_BLOBSTART, LANDMARK_KUDZUSTART))
				if (landmarks[landmark_type])
					EV += landmarks[landmark_type]

			EV += job_start_locations["Clown"]

			if(!EV.len)
				EV += landmarks[LANDMARK_LATEJOIN]
				if (!EV.len)
					message_admins("Pests event couldn't find a pest landmark!")
					cleanup()
					return

			var/atom/pestlandmark = pick(EV)

			if (src.num_critters) //custom selected
				src.num_critters = (min(src.num_critters, candidates.len))
			else //random selected
				src.num_critters = rand(1,min(3,candidates.len))

			for (var/i in 1 to src.num_critters)
				if (!candidates || !length(candidates))
					break

				var/datum/mind/M = candidates[1]
				if (M.current)
					var/picked_critter = pick(select)
					log_respawn_event(M, picked_critter, source)
					if (istype(picked_critter, /datum/eventSpawnedCritter)) // datum provided
						var/datum/eventSpawnedCritter/picked_critter_datum = picked_critter
						M.current.make_critter(pick(picked_critter_datum.critter_types), pestlandmark)
						var/list/items_to_drop = picked_critter_datum.roll_for_items()
						if (items_to_drop && length(items_to_drop))
							M.current._AddComponent(list(/datum/component/drop_loot_on_death, items_to_drop))
					else // only path provided
						M.current.make_critter(picked_critter, pestlandmark)
					new /obj/item/implant/access/infinite/assistant(M.current)
					if (src.custom_spawn_turf)
						M.current.set_loc(src.custom_spawn_turf)
					antagify(M.current, null, 1)
				candidates -= M

			command_alert("Our sensors have detected a hostile nonhuman lifeform in the vicinity of the station.", "Hostile Critter", alert_origin = ALERT_GENERAL)
			cleanup()

	cleanup()
		..()
		src.critter_type = null
		src.num_critters = 0
