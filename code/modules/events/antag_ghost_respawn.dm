/datum/random_event/major/player_spawn
	///Can this event be given a custom spawn location
	var/targetable = FALSE
	var/turf/custom_spawn_turf = null
	admin_call(var/source)
		if (src.targetable)
			var/custom_loc = alert("Custom spawn location?","[src.name]","Default","Custom") == "Custom"
			if (custom_loc)
				src.custom_spawn_turf = get_turf(pick_ref(usr))

	cleanup()
		src.custom_spawn_turf = null
/datum/random_event/major/player_spawn/antag/antagonist
	name = "Antagonist Spawn"
	required_elapsed_round_time = 26.6 MINUTES
	customization_available = 1
	announce_to_admins = 0 // Doing it manually.
	centcom_headline = "Biogenic Outbreak"
	centcom_message = "Aggressive macrocellular organism detected aboard the station. All personnel must contain the outbreak."
	message_delay = 5 MINUTES // (+ ghost_confirmation_delay). Don't out them too early, blobs in particular need time to establish themselves.
	targetable = TRUE
	var/antagonist_type = "Blob"
	var/ghost_confirmation_delay = 2 MINUTES // time to acknowledge or deny respawn offer.
	var/respawn_lock = 0
	var/admin_override = 0
	var/antag_count = 1
#ifdef RP_MODE
	disabled = 1
#endif

	admin_call(var/source)
		if (..())
			return

		if (src.respawn_lock != 0)
			message_admins("Setup of previous Antagonist Spawn hasn't finished yet, aborting.")
			return

		var/type = input(usr, "Select antagonist type.", "Antagonists", "Blob") as null|anything in list("Blob", "Blob (AI)", "Hunter", "Werewolf", "Wizard", "Wraith", "Wrestler", "Wrestler_Doodle", "Vampire", "Changeling", "Headspider", "Salvager", "Arcfiend", "Flockmind")
		if (!type)
			return
		else
			src.antagonist_type = type

		if(type != "Blob (AI)")
			src.antag_count = input(usr, "How many to assign? ([length(eligible_dead_player_list(allow_dead_antags = TRUE))] players eligible)", src.name, antag_count) as num|null
			if (isnull(src.antag_count))
				return
			else if (src.antag_count < 1)
				return
			else
				src.antag_count = round(src.antag_count)

		src.admin_override = 1
		src.event_effect(source)
		return

	event_effect(var/source)
		if (src.respawn_lock != 0)
			message_admins("Setup of previous Antagonist Spawn hasn't finished yet, aborting.")
			return

		// Admin-configured respawns seem to work out fine, so let's give automatic role selection a try.
		if (src.admin_override != 1)
			if (!source && (!ticker.mode || ticker.mode.latejoin_antag_compatible == 0 || late_traitors == 0))
				message_admins("Antagonist Spawn (non-admin) is disabled in this game mode, aborting.")
				return
			#ifdef MAP_OVERRIDE_NADIR
			src.antagonist_type = pick(list("Hunter", "Werewolf", "Wizard", "Wraith", "Wrestler", "Wrestler_Doodle", "Vampire", "Changeling", "Flockmind"))
			#else
			src.antagonist_type = pick(list("Blob", "Hunter", "Werewolf", "Wizard", "Wraith", "Wrestler", "Wrestler_Doodle", "Vampire", "Changeling", "Flockmind"))
			#endif
			for(var/mob/living/intangible/wraith/W in ticker.mode.traitors)
				if(W.deaths < 2)
					src.antagonist_type -= list("Wraith")
					src.antagonist_type = pick(list())
				if(isnull(W.deaths))
					continue

		switch (src.antagonist_type)
			if ("Blob", "Blob (AI)")
				src.centcom_headline = initial(src.centcom_headline) // Gotta reset this.
				src.centcom_message = initial(src.centcom_message)
			else
				src.centcom_headline = "Intruder Alert"
				src.centcom_message = "Our [pick("probes", "sensors", "listening devices", "wiretaps", "informants", "well-informed sources")] indicate the presence of a hostile intruder in the vicinity of [station_or_ship()]."

		src.message_delay = src.message_delay + src.ghost_confirmation_delay

		message_admins("<span class='internal'>Setting up Antagonist Spawn event ([src.antagonist_type]). Source: [source ? "[source]" : "random"]</span>")
		logTheThing(LOG_ADMIN, null, "Setting up Antagonist Spawn event ([src.antagonist_type]). Source: [source ? "[source]" : "random"]")

		// No need for a fancy setup here.
		if (src.antagonist_type == "Blob (AI)")
			var/BS = pick_landmark(LANDMARK_BLOBSTART)
			if (BS)
				new /mob/living/intangible/blob_overmind/ai(BS)
				message_admins("Antagonist Spawn spawned an AI blob at [log_loc(BS)].")
				logTheThing(LOG_ADMIN, null, "Antagonist Spawn spawned an AI blob at [log_loc(BS)]. Source: [source ? "[source]" : "random"]")
				..() // Report spawn().
			else
				message_admins("Couldn't spawn AI blob (no blobstart landmark found).")
			src.cleanup()
			return

		// Don't lock up the event controller.
		SPAWN(0)
			if (src) src.do_event(source)

		return

	is_event_available(var/ignore_time_lock = 0)
		if( emergency_shuttle.online )
			return 0

		return ..()

	proc/do_event(var/source)
		if (!src || !istype(src, /datum/random_event/major/player_spawn/antag/antagonist))
			return

		src.respawn_lock = 1

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a [src.antagonist_type] antagonist? Your name will be added to the list of eligible candidates and may be selected at random by the game.") // Do disclose which type it is. You know, ghosts can already metagame in a myriad of ways.
		text_messages.Add("You are eligible to be respawned as a [src.antagonist_type] antagonist. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)

		if (!islist(candidates) || !length(candidates))
			message_admins("Couldn't set up Antagonist Spawn ([src.antagonist_type]); no ghosts responded. Source: [source ? "[source]" : "random"]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up Antagonist Spawn ([src.antagonist_type]); no ghosts responded. Source: [source ? "[source]" : "random"]")
			src.cleanup()
			global.random_events.next_spawn_event = TIME + 1 MINUTE
			return

		for(var/antag_idx in 1 to src.antag_count)
			// Check against player preferences.
			var/attempts = 0
			var/datum/mind/lucky_dude = null

			while (attempts < 4 && length(candidates) && !(lucky_dude && istype(lucky_dude) && lucky_dude.current))
				lucky_dude = candidates[1]
				attempts++
				/*
				// Latejoin antagonists ignore antag prefs and so should this
				// Nobody even realized that it checked this!
				if (lucky_dude.current.client.preferences)
					var/datum/preferences/P = lucky_dude.current.client.preferences
					switch (src.antagonist_type)
						if ("Blob")
							if (!P.be_blob)
								lucky_dude = null
						if ("Wraith")
							if (!P.be_wraith)
								lucky_dude = null
						if ("Wizard")
							if (!P.be_wizard)
								lucky_dude = null
						if ("Werewolf")
							if (!P.be_misc)
								lucky_dude = null
						if ("Hunter")
							if (!P.be_misc)
								lucky_dude = null
				else
					lucky_dude = null
				*/


			if (!(lucky_dude && istype(lucky_dude) && lucky_dude.current))
				message_admins("Couldn't set up Antagonist Spawn ([src.antagonist_type]); candidate selection failed (had [candidates.len] candidate(s)). Source: [source ? "[source]" : "random"]")
				logTheThing(LOG_ADMIN, null, "Couldn't set up Antagonist Spawn ([src.antagonist_type]); candidate selection failed (had [candidates.len] candidate(s)). Source: [source ? "[source]" : "random"]")
				src.cleanup()
				return

			candidates -= lucky_dude

			// Respawn and assign role.
			var/mob/M3
			if (!M3)
				M3 = lucky_dude.current
			else
				if (src.respawn_lock != 1) // Respawn might be in progress still.
					src.cleanup()
				return

			// Shouldn't happen, will happen.
			if (lucky_dude.special_role)
				if (lucky_dude in ticker.mode.traitors)
					ticker.mode.traitors.Remove(lucky_dude)
				if (lucky_dude in ticker.mode.Agimmicks)
					ticker.mode.Agimmicks.Remove(lucky_dude)
				if (!lucky_dude.former_antagonist_roles.Find(lucky_dude.special_role))
					lucky_dude.former_antagonist_roles.Add(lucky_dude.special_role)
				if (!(lucky_dude in ticker.mode.former_antagonists))
					ticker.mode.former_antagonists.Add(lucky_dude)

			var/role = null
			var/objective_path = null
			var/send_to = 1 // 1: arrival shuttle/latejoin missile | 2: wizard shuttle | 3: safe start for incorporeal antags
			var/ASLoc = pick_landmark(LANDMARK_LATEJOIN)
			var/failed = 0
			log_respawn_event(lucky_dude, src.antagonist_type, source)
			var/datum/mind/mind = M3.mind
			mind.wipe_antagonists()
			M3 = mind.current
			switch (src.antagonist_type)
				if ("Blob")
					if (istype(mind))
						send_to = 3
						mind.add_antagonist(ROLE_BLOB, do_relocate = FALSE, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_BLOB
						M3 = mind.current
					else
						failed = 1

				if ("Flockmind")
					if (istype(mind))
						send_to = 3
						mind.add_antagonist(ROLE_FLOCKMIND, do_relocate = FALSE, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_FLOCKMIND
						M3 = mind.current
						var/mob/living/intangible/flock/flockmind/F = mind.current
						if (istype(F) && (alive_player_count() > 40)) // Flockmind can have a free trace, as a treat.
							SPAWN(1)
								F.partition(ANTAGONIST_SOURCE_RANDOM_EVENT)
					else
						failed = 1

				if ("Wraith")
					if (istype(mind))
						send_to = 3
						mind.add_antagonist(ROLE_WRAITH, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_WRAITH
						M3 = mind.current
					else
						failed = 1

				if ("Wizard")
					var/mob/living/L = M3.humanize()
					if (istype(L))
						M3 = L
						send_to = 2
						L.mind?.add_antagonist(ROLE_WIZARD, do_relocate = FALSE, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_WIZARD
					else
						failed = 1

				if ("Werewolf")
					var/mob/living/L = M3.humanize()
					if (istype(L))
						M3 = L
						L.mind?.add_antagonist(ROLE_WEREWOLF, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_WEREWOLF
					else
						failed = 1

				if ("Hunter")
					var/mob/living/L = M3.humanize()
					if (istype(L))
						M3 = L
						L.mind?.add_antagonist(ROLE_HUNTER, do_equip = FALSE, do_relocate = TRUE, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_HUNTER
					else
						failed = 1

				if ("Salvager")
					var/mob/living/L = M3.humanize(equip_rank=FALSE)
					if (istype(L))
						M3 = L
						L.mind?.add_antagonist(ROLE_SALVAGER, do_equip = TRUE, do_relocate = TRUE, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_SALVAGER
					else
						failed = 1

				if ("Wrestler")
					var/mob/living/L = M3.humanize()
					if (istype(L))
						M3 = L
						L.mind?.add_antagonist(ROLE_WRESTLER, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_WRESTLER
						var/antagonist_role = src.antagonist_type
						SPAWN(0)
							M3.choose_name(3, antagonist_role, M3.real_name + " the " + antagonist_role)
					else
						failed = 1

				if ("Wrestler_Doodle")
					var/mob/living/critter/C = M3.critterize(/mob/living/critter/small_animal/bird/timberdoodle/strong)
					if (istype(C))
						M3 = C
						C.mind?.add_antagonist(ROLE_WRESTLER, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_WRESTLER
						var/antagonist_role = src.antagonist_type
						SPAWN(0)
							C.choose_name(3, antagonist_role, C.real_name + " the " + antagonist_role)
					else
						failed = 1

				if ("Vampire")
					var/mob/living/L = M3.humanize()
					if (istype(L))
						M3 = L
						L.mind?.add_antagonist(ROLE_VAMPIRE, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_VAMPIRE
					else
						failed = 1

				if ("Changeling")
					var/mob/living/L = M3.humanize()
					if (istype(L))
						M3 = L
						L.mind?.add_antagonist(ROLE_CHANGELING, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_CHANGELING
					else
						failed = 1

				if ("Headspider")
					var/mob/living/critter/C = M3.critterize(/mob/living/critter/changeling/headspider)
					if (C && istype(C))
						M3 = C
						C.mind.add_antagonist(ROLE_CHANGELING, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						C.remove_ability_holder(/datum/abilityHolder/changeling/)
					else
						failed = 1

				if ("Arcfiend")
					var/mob/living/L = M3.humanize()
					if (istype(L))
						M3 = L
						L.mind?.add_antagonist(ROLE_ARCFIEND, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						role = ROLE_ARCFIEND
					else
						failed = 1
				else
					failed = 1

			if (!ASLoc)
				failed = 1

			if (failed != 0)
				message_admins("Couldn't set up Antagonist Spawn ([src.antagonist_type]); respawn failed. Source: [source ? "[source]" : "random"]")
				logTheThing(LOG_ADMIN, null, "Couldn't set up Antagonist Spawn ([src.antagonist_type]); respawn failed. Source: [source ? "[source]" : "random"]")
				src.cleanup()
				return

			lucky_dude.assigned_role = "MODE"
			lucky_dude.special_role = role
			lucky_dude.random_event_special_role = 1
			if (!(lucky_dude in ticker.mode.Agimmicks))
				ticker.mode.Agimmicks.Add(lucky_dude)

			if (!isnull(objective_path))
				if (ispath(objective_path, /datum/objective_set))
					new objective_path(lucky_dude)
				else if (ispath(objective_path, /datum/objective))
					ticker.mode.bestow_objective(lucky_dude, objective_path)

			var/i = 1
			for (var/datum/objective/Obj in lucky_dude.objectives)
				if (istype(Obj, /datum/objective/crew))
					continue
				boutput(M3, "<b>Objective #[i]</b>: [Obj.explanation_text]")
				i++

			if (src.custom_spawn_turf)
				M3.set_loc(src.custom_spawn_turf)
			else
				switch (send_to)
					if (1)
						if (map_settings?.arrivals_type == MAP_SPAWN_MISSILE)
							latejoin_missile_spawn(M3)
						else
							M3.set_loc(ASLoc)
					if (2)
						if (!job_start_locations["wizard"])
							boutput(M3, "<B><span class='alert'>A starting location for you could not be found, please report this bug!</span></B>")
							M3.set_loc(ASLoc)
						else
							M3.set_loc(pick(job_start_locations["wizard"]))
					if (3)
						M3.set_loc(ASLoc)
			//nah
			/*
			if (src.centcom_headline && src.centcom_message && random_events.announce_events)
				SPAWN(src.message_delay)
					command_alert("[src.centcom_message]", "[src.centcom_headline]")
			*/

			if (lucky_dude.current)
				lucky_dude.current.show_text("<h3>You have been respawned as a random event [src.antagonist_type].</h3>", "blue")
			message_admins("[key_name(lucky_dude.key)] respawned as a random event [src.antagonist_type]. Source: [source ? "[source]" : "random"]")
		src.cleanup()
		return

	// Restore defaults.
	cleanup()
		if (!src || !istype(src, /datum/random_event/major/player_spawn/antag/antagonist))
			return
		..()
		src.antagonist_type = initial(src.antagonist_type)
		src.respawn_lock = initial(src.respawn_lock)
		src.message_delay = initial(src.message_delay)
		src.admin_override = initial(src.admin_override)
		src.antag_count = initial(src.antag_count)
