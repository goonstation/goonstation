/*#define ALIVE_ANTAGS_THRESHOLD 0.015
#define ALIVE_CREW_THRESHOLD 50

/datum/random_event/major/nukiestrikeforce
	name = "Syndicate Retribution"
	required_elapsed_round_time = 40 MINUTES
	weight = 88
	var/agent_number = 1
	var/list/datum/mind/syndicates = list()
	var/list/possible_syndicates = list()

	if (!landmarks[LANDMARK_SYNDICATE])
		boutput(world, "<span class='alert'><b>ERROR: couldn't find Syndicate spawn landmark, aborting nuke round pre-setup.</b></span>")
		return 0
		possible_syndicates = get_possible_enemies(ROLE_NUKEOP, num_synds)




	#undef ALIVE_ANTAGS_THRESHOLD
	#undef ALIVE_CREW_THRESHOLD*/


/*defines an event critter as well as any possible drop tables
/datum/eventSpawnedCritter


	New(critter_types)
		..()
		src.critter_types = critter_types*/



/datum/random_event/major/antag/midroundnukies
	name = "midround nukies"
	customization_available = 0
	required_elapsed_round_time = 40 MINUTES
	weight = 88

	disabled = 1

	//var/num_critters = 0
	//var/critter_type = null

	required_elapsed_round_time = 5 MINUTES

	var/ghost_confirmation_delay = 1 MINUTES // time to acknowledge or deny respawn offer.

	var/list/pest_invasion_critter_datums = list(

		list(new /datum/eventSpawnedCritter(
			critter_types = list(/mob/living/critter/fire_elemental),
			drop_tables = list(
				new /datum/event_item_drop_table(
					potential_drop_items = list(/obj/item/mutation_orb/fire_orb, /obj/item/rejuvenation_feather, /obj/item/property_setter/fire_jewel)
					)
				)
			)
		),

				)

	event_effect(var/source)
		..()

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a random antagonist critter? You may be randomly selected from the list of candidates.")
		text_messages.Add("You are eligible to be respawned as a random antagonist critter. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. Please wait for the game to choose, good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)


	/*	if (src.num_critters) //custom selected
			src.num_critters = (min(src.num_critters, candidates.len))
		else //random selected
			src.num_critters = rand(1,min(3,candidates.len))*/
		//for (var/i in 1 to src.num_critters)



		if (!candidates)
			return
		var/datum/mind/lucky_dude = pick(candidates)


		var/mob/M3
		if (!M3)
			M3 = lucky_dude.current
		else
			return

		if (lucky_dude.special_role)
			if (lucky_dude in ticker.mode.traitors)
				ticker.mode.traitors.Remove(lucky_dude)
			if (lucky_dude in ticker.mode.Agimmicks)
				ticker.mode.Agimmicks.Remove(lucky_dude)
			if (!lucky_dude.former_antagonist_roles.Find(lucky_dude.special_role))
				lucky_dude.former_antagonist_roles.Add(lucky_dude.special_role)
			if (!(lucky_dude in ticker.mode.former_antagonists))
				ticker.mode.former_antagonists.Add(lucky_dude)

		//var/role = null
		/*var/objective_path = null
		var/send_to = 1 // 1: arrival shuttle/latejoin missile | 2: wizard shuttle | 3: safe start for incorporeal antags
		var/ASLoc = pick_landmark(LANDMARK_SYNDICATE)
		var/failed = 0*/


		var/mob/living/carbon/human/R = M3.humanize()
		if (R && istype(R))
			M3 = R
			R.unequip_all(1)
			equip_syndicate(R, 1)

			//objective_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			R.set_loc(pick_landmark(LANDMARK_SYNDICATE))
			SPAWN(0)
				R.choose_name(3, "Nukie")

				lucky_dude.special_role = ROLE_NUKEOP
		else
			return
			/*
				var/picked_critter = /mob/living/critter/robotic/sawfly
				if (istype(picked_critter, /datum/eventSpawnedCritter)) // datum provided
					var/datum/eventSpawnedCritter/picked_critter_datum = picked_critter
					M.current.make_critter(pick(picked_critter_datum.critter_types), pick_landmark(LANDMARK_SYNDICATE))
					//var/list/items_to_drop = picked_critter_datum.roll_for_items()
				else // only path provided
					M.current.make_critter(picked_critter, pick_landmark(LANDMARK_SYNDICATE))
				var/obj/item/implant/access/infinite/assistant/O = new /obj/item/implant/access/infinite/assistant(M.current)
				O.owner = M.current
				O.implanted = 1*/


		candidates -= lucky_dude

		command_alert("Our sensors have detected a hostile nonhuman lifeform in the vicinity of the station.", "Hostile Critter", alert_origin = ALERT_GENERAL)
		//src.critter_type = null
		//src.num_critters = 0
