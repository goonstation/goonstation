ABSTRACT_TYPE(/datum/job)
/datum/job
	var/name = null
	var/list/alias_names = null
	var/initial_name = null
	var/ui_colour = TGUI_COLOUR_TEAL

	/// Job starting wages
	var/wages = 0
	var/limit = -1
	var/list/trait_list = list() // specific job trait string, i.e. "training_security"
	/// job category flag for use with loops rather than a needing a bunch of type checks
	var/job_category = JOB_SPECIAL
	var/upper_limit = null //! defaults to `limit`
	var/lower_limit = 0
	var/admin_set_limit = FALSE //! has an admin manually set the limit to something
	var/variable_limit = FALSE //! does this job scale down at lower population counts
	var/add_to_manifest = TRUE //! On join, add to general, bank, and security records.
	var/no_late_join = FALSE
	var/no_jobban_from_this_job = FALSE
	///can you roll this job if you rolled antag with a non-traitor-allowed favourite job (e.g.: prevent sec mains from forcing only captain antag rounds)
	var/allow_antag_fallthrough = TRUE

	///Can this job roll antagonist? if FALSE ignores invalid_antagonist_roles
	var/can_roll_antag = TRUE
	///Which station antagonist roles can this job NOT be (e.g. ROLE_TRAITOR but not ROLE_NUKEOP)
	var/list/invalid_antagonist_roles = list()

	var/requires_whitelist = FALSE
	var/trusted_only = FALSE // Do we require mentor/HoS status to be played
	var/requires_supervisor_job = null //! String name of another job. The current job will only be available if the supervisor job is filled.
	var/needs_college = 0
	var/assigned = 0
	var/high_priority_job = FALSE
	///Fill up to this limit, then drop this job out of high priotity
	var/high_priority_limit = INFINITY
	//should a job be considered last for selection, but also as a last resort fallback job? NOTE: ignores other requirements such as round min/max
	var/low_priority_job = FALSE
	var/order_priority = 1 //! What order jobs are filled in within their priority tier, lower number = higher priority
	var/cant_allocate_unwanted = FALSE //! Job cannot be set to "unwanted" in player preferences.
	var/receives_miranda = FALSE
	var/list/receives_implants = null //! List of object paths of implant types given on spawn.
	var/receives_disk = FALSE //! Job spawns with cloning data disk, can specify a type
	var/obj/item/clothing/suit/security_badge/badge = null //! Typepath of the badge to spawn the player with
	var/world_announce_priority = ANNOUNCE_ORDER_NEVER //! On join, send message to all players indicating who is fulfilling the role; ordered by rank, ANNOUNCE_ORDER_NEVER to never announce
	var/radio_announcement = TRUE //! The announcement computer will send a message when the player joins after round-start.
	var/list/alt_names = list()
	var/slot_card = /obj/item/card/id //! Object path of the ID card type to issue player. Overridden by `spawn_id`.
	var/spawn_id = TRUE //! Does player spawn with an ID. Overrides slot_card if TRUE.
	// Following slots support single item list or weighted list - Do not use regular lists or it will error!
	var/list/slot_head = list()
	var/list/slot_mask = list()
	var/list/slot_ears = list(/obj/item/device/radio/headset) // cogwerks experiment - removing default headsets
	var/list/slot_eyes = list()
	var/list/slot_suit = list()
	var/list/slot_jump = list()
	var/list/slot_glov = list()
	var/list/slot_foot = list()
	var/list/slot_back = list(/obj/item/storage/backpack)
	var/list/slot_belt = list(/obj/item/device/pda2)
	var/list/slot_poc1 = list() // Pay attention to size. Not everything is small enough to fit in jumpsckets.
	var/list/slot_poc2 = list()
	var/list/slot_lhan = list()
	var/list/slot_rhan = list()
	var/list/items_in_backpack = list() // stop giving everyone a free airtank gosh
	var/list/items_in_belt = list() // works the same as above but is for jobs that spawn with a belt that can hold things
	var/access_string = null // used to quickly grab access via string, i.e. "Chief Engineer", completely overrides var/list/access if non-null !!!
	var/list/access = list(access_fuck_all) // Please define in global get_access() proc (access.dm), so it can also be used by bots etc.
	var/mob/living/mob_type = /mob/living/carbon/human
	var/datum/mutantrace/starting_mutantrace = null
	var/change_name_on_spawn = FALSE
	var/tmp/special_spawn_location = null
	var/bio_effects = null
	var/objective = null
	var/rounds_needed_to_play = 0 //0 by default, set to the amount of rounds they should have in order to play this
	var/rounds_allowed_to_play = 0 //0 by default (which means infinite), set to the amount of rounds they are allowed to have in order to play this, primarily for assistant jobs
	var/map_can_autooverride = TRUE //! Base the initial limit of job slots on the number of map-defined job start locations.
	/// Does this job use the name and appearance from the character profile? (for tracking respawned names)
	var/uses_character_profile = TRUE
	/// The faction to be assigned to the mob on setup uses flags from factions.dm
	var/faction = list()

	var/short_description = null //! Description provided when a player hovers over the job name in latejoin menu
	var/wiki_link = null //! Link to the wiki page for this job

	///If this job should show in the ID computer (only works for staple jobs)
	var/show_in_id_comp = TRUE

	var/counts_as = null //! Name of a job that we count towards the cap of
	///if true, cryoing won't free up slots, only ghosting will
	///basically there should never be two of these
	var/unique = FALSE
	var/request_limit = 0 //!Maximum total `limit` via RoleControl request function
	var/request_cost = null //!Cost to open an additional slot using RoleControl
	var/player_requested = FALSE //! Flag if currently requested via RoleControl



	New()
		..()
		src.initial_name = src.name
		if (isnull(src.upper_limit))
			src.upper_limit = src.limit

		if (src.access_string)
			src.access = get_access(src.access_string)

#define SLOT_SCALING_UPPER_THRESHOLD 50 //the point at which we have maximum slots open
#define SLOT_SCALING_LOWER_THRESHOLD 20 //the point at which we have minimum slots open

	proc/recalculate_limit(player_count)
		if (src.limit < 0 || src.admin_set_limit) //don't mess with infinite slot or admin limit set jobs
			return src.limit
		if (player_count >= SLOT_SCALING_UPPER_THRESHOLD) //above this just open everything up
			src.limit = src.upper_limit
			return src.limit
		var/old_limit = src.limit
		//basic linear scale between upper and lower limits
		var/scalar = (player_count - SLOT_SCALING_LOWER_THRESHOLD) / (SLOT_SCALING_UPPER_THRESHOLD - SLOT_SCALING_LOWER_THRESHOLD)
		src.limit = src.lower_limit + scalar * (src.upper_limit - src.lower_limit)
		logTheThing(LOG_DEBUG, src, "Variable job limit for [src.name] calculated as [src.limit] slots at [player_count] player count")
		src.limit = round(src.limit, 1)
		src.limit = clamp(src.limit, src.lower_limit, src.upper_limit) //paranoia clamp, probably not needed
		if (src.limit != old_limit)
			logTheThing(LOG_DEBUG, src, "Altering variable job limit for [src.name] from [old_limit] to [src.limit] at [player_count] player count.")
		return src.limit

#undef SLOT_SCALING_UPPER_THRESHOLD
#undef SLOT_SCALING_LOWER_THRESHOLD

	onVarChanged(variable, oldval, newval)
		. = ..()
		if (variable == "limit")
			src.admin_set_limit = TRUE

	proc/special_setup(var/mob/M, no_special_spawn)
		SHOULD_NOT_SLEEP(TRUE)
		if (!M)
			return
		if (src.receives_miranda)
			M.verbs += /mob/proc/recite_miranda
			M.verbs += /mob/proc/add_miranda
		LAZYLISTADDUNIQUE(M.faction, src.faction)
		for (var/T in src.trait_list)
			M.traitHolder.addTrait(T)
		SPAWN(0)
			if (length(src.receives_implants))
				for(var/obj/item/implant/implant as anything in src.receives_implants)
					if(ispath(implant))
						new implant(M)

			var/give_access_implant = ismobcritter(M)
			if(!spawn_id && (length(access) > 0 || length(access) == 1 && access[1] != access_fuck_all))
				give_access_implant = TRUE
			if (give_access_implant)
				var/obj/item/implant/access/I = new /obj/item/implant/access(M)
				I.access.access = src.access.Copy()
				I.uses = -1

			if (src.special_spawn_location && !no_special_spawn)
				var/location = src.special_spawn_location
				if (!istype(src.special_spawn_location, /turf))
					location = pick_landmark(src.special_spawn_location)
				if (!isnull(location))
					M.set_loc(location)

			if (ishuman(M) && src.bio_effects)
				var/list/picklist = params2list(src.bio_effects)
				if (length(picklist))
					for(var/pick in picklist)
						M.bioHolder.AddEffect(pick)

			if (ishuman(M) && src.starting_mutantrace)
				var/mob/living/carbon/human/H = M
				H.set_mutantrace(src.starting_mutantrace)

			if (src.objective)
				var/datum/objective/newObjective = new /datum/objective/crew(src.objective, M.mind)
				boutput(M, "<B>Your OPTIONAL Crew Objectives are as follows:</b>")
				boutput(M, "<B>Objective #1</B>: [newObjective.explanation_text]")

			if (M.client && src.change_name_on_spawn && !jobban_isbanned(M, "Custom Names"))
				//if (ishuman(M)) //yyeah this doesn't work with critters fix later
				var/default = M.real_name + " the " + src.name
				var/orig_real = M.real_name
				M.choose_name(3, src.name, default)
				if(M.real_name != default && M.real_name != orig_real)
					phrase_log.log_phrase("name-[ckey(src.name)]", M.real_name, no_duplicates=TRUE)

	proc/can_be_antag(var/role)
		if (!src.can_roll_antag)
			return FALSE
		return !(role in src.invalid_antagonist_roles)

	/// The default miranda's rights for this job
	proc/get_default_miranda()
		return DEFAULT_MIRANDA

	///Check if a string matches this job's name or alias with varying case sensitivity
	proc/match_to_string(string, case_sensitive)
		if (case_sensitive)
			return src.name == string || (string in src.alias_names)
		else
			if(cmptext(src.name, string))
				return TRUE
			for (var/alias in src.alias_names)
				if (cmptext(src.name, string))
					return TRUE

	proc/has_rounds_needed(datum/player/player, var/min = 0, var/max = 0)
		if (src.rounds_needed_to_play)
			min = src.rounds_needed_to_play
		if (src.rounds_allowed_to_play)
			max = src.rounds_allowed_to_play
		if (!min && !max)
			return TRUE

		var/round_num = player?.get_rounds_participated()
		if (isnull(round_num)) //fetch failed, assume they're allowed because everything is probably broken right now
			return TRUE
		if (player.cloudSaves.getData("bypass_round_reqs")) //special flag for account transfers etc.
			return TRUE
		if (round_num >= min && (round_num <= max || !max))
			return TRUE
		return FALSE
