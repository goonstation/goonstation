/datum/job
	var/name = null
	var/list/alias_names = null
	var/initial_name = null
	var/linkcolor = "#0FF"

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
	var/allow_traitors = TRUE
	///can you roll this job if you rolled antag with a non-traitor-allowed favourite job (e.g.: prevent sec mains from forcing only captain antag rounds)
	var/allow_antag_fallthrough = TRUE
	var/allow_spy_theft = TRUE
	var/can_join_gangs = TRUE
	var/cant_spawn_as_rev = FALSE // For the revoltion game mode. See jobprocs.dm for notes etc (Convair880).
	var/cant_spawn_as_con = FALSE // Prevents this job spawning as a conspirator in the conspiracy gamemode.
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
	var/receives_badge = FALSE
	var/announce_on_join = FALSE //! On join, send message to all players indicating who is fulfilling the role; primarily for heads of staff
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
	var/id_band_override = null //Override ID band colour to whatever you want
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

	var/counts_as = null //! Name of a job that we count towards the cap of
	///if true, cryoing won't free up slots, only ghosting will
	///basically there should never be two of these
	var/unique = FALSE

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
			if (!isnull(M.mind))
				M.mind.miranda = DEFAULT_MIRANDA
		LAZYLISTADDUNIQUE(M.faction, src.faction)
		for (var/T in src.trait_list)
			M.traitHolder.addTrait(T)
		SPAWN(0)
			if (length(src.receives_implants))
				for(var/obj/item/implant/implant as anything in src.receives_implants)
					if(ispath(implant))
						var/mob/living/carbon/human/H = M
						var/obj/item/implant/I = new implant(M)
						if (ispath(I, /obj/item/implant/health) && src.receives_disk && ishuman(M))
							if (H.back?.storage)
								var/obj/item/disk/data/floppy/D = locate(/obj/item/disk/data/floppy) in H.back.storage.get_contents()
								if (D)
									var/datum/computer/file/clone/R = locate(/datum/computer/file/clone/) in D.root.contents
									if (R)
										R.fields["imp"] = "\ref[I]"

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

	/// Is this job highlighted for priority latejoining
	proc/is_highlighted()
		return global.priority_job == src

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

		var/round_num = player.get_rounds_participated()
		if (isnull(round_num)) //fetch failed, assume they're allowed because everything is probably broken right now
			return TRUE
		if (player.cloudSaves.getData("bypass_round_reqs")) //special flag for account transfers etc.
			return TRUE
		if (round_num >= min && (round_num <= max || !max))
			return TRUE
		return FALSE


// Command Jobs

ABSTRACT_TYPE(/datum/job/command)
/datum/job/command
	linkcolor = "#00CC00"
	slot_card = /obj/item/card/id/command
	map_can_autooverride = FALSE
	can_join_gangs = FALSE
	job_category = JOB_COMMAND
	unique = TRUE

	special_setup(mob/M, no_special_spawn)
		. = ..()
		var/image/image = image('icons/mob/antag_overlays.dmi', icon_state = "head", loc = M)
		image.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
		get_image_group(CLIENT_IMAGE_GROUP_HEADS_OF_STAFF).add_image(image)

/datum/job/command/captain
	name = "Captain"
	limit = 1
	wages = PAY_EXECUTIVE
	access_string = "Captain"
	high_priority_job = TRUE
	receives_miranda = TRUE
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	announce_on_join = TRUE
	allow_spy_theft = FALSE
	allow_antag_fallthrough = FALSE
	receives_implants = list(/obj/item/implant/health/security/anti_mindhack)
	wiki_link = "https://wiki.ss13.co/Captain"

	slot_card = /obj/item/card/id/gold
	slot_belt = list(/obj/item/device/pda2/captain)
	slot_back = list(/obj/item/storage/backpack/captain)
	slot_jump = list(/obj/item/clothing/under/rank/captain)
	slot_suit = list(/obj/item/clothing/suit/armor/captain)
	slot_foot = list(/obj/item/clothing/shoes/swat/captain)
	slot_glov = list(/obj/item/clothing/gloves/swat/captain)
	slot_head = list(/obj/item/clothing/head/caphat)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_ears = list(/obj/item/device/radio/headset/command/captain)
	slot_poc1 = list(/obj/item/disk/data/floppy/read_only/authentication)
	items_in_backpack = list(/obj/item/storage/box/id_kit,/obj/item/device/flash)
	rounds_needed_to_play = ROUNDS_MIN_CAPTAIN

	derelict
		//name = "NT-SO Commander"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/captain/centcomm)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/centhat)
		slot_belt = list(/obj/item/tank/emergency_oxygen/extended)
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_eyes = list(/obj/item/clothing/glasses/thermal)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/camera,/obj/item/gun/energy/egun)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/head_of_personnel
	name = "Head of Personnel"
	limit = 1
	wages = PAY_IMPORTANT
	access_string = "Head of Personnel"
	wiki_link = "https://wiki.ss13.co/Head_of_Personnel"

	allow_spy_theft = FALSE
	allow_antag_fallthrough = FALSE
	receives_miranda = TRUE
	cant_spawn_as_rev = TRUE
	announce_on_join = TRUE


#ifdef SUBMARINE_MAP
	slot_suit = list(/obj/item/clothing/suit/armor/hopcoat)
#endif
	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2/hop)
	slot_jump = list(/obj/item/clothing/under/suit/hop)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command/hop)
	slot_poc1 = list(/obj/item/pocketwatch)
	items_in_backpack = list(/obj/item/storage/box/id_kit,/obj/item/device/flash,/obj/item/storage/box/accessimp_kit)

/datum/job/command/head_of_security
	name = "Head of Security"
	limit = 1
	wages = PAY_IMPORTANT
	trait_list = list("training_drinker", "training_security")
	access_string = "Head of Security"
	requires_whitelist = TRUE
	receives_miranda = TRUE
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_con = TRUE
	cant_spawn_as_rev = TRUE
	announce_on_join = TRUE
	receives_disk = /obj/item/disk/data/floppy/sec_command
	receives_badge = TRUE
	receives_implants = list(/obj/item/implant/health/security/anti_mindhack)
	items_in_backpack = list(/obj/item/device/flash)
	wiki_link = "https://wiki.ss13.co/Head_of_Security"

#ifdef SUBMARINE_MAP
	slot_jump = list(/obj/item/clothing/under/rank/head_of_security/fancy_alt)
#else
	slot_jump = list(/obj/item/clothing/under/rank/head_of_security)
#endif
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_back = list(/obj/item/storage/backpack/security)
	slot_belt = list(/obj/item/device/pda2/hos)
	slot_poc1 = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_poc2 = list(/obj/item/requisition_token/security)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_head = list(/obj/item/clothing/head/hos_hat)
	slot_ears = list(/obj/item/device/radio/headset/command/hos)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)

	derelict
		name = null//"NT-SO Special Operative"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/NT)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/NTberet)
		slot_belt = list(/obj/item/tank/emergency_oxygen/extended)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_glov = list(/obj/item/clothing/gloves/latex)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_eyes = list(/obj/item/clothing/glasses/thermal)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/breaching_charge,/obj/item/breaching_charge,/obj/item/gun/energy/plasma_gun)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/chief_engineer
	name = "Chief Engineer"
	limit = 1
	wages = PAY_IMPORTANT
	trait_list = list("training_engineer")
	access_string = "Chief Engineer"
	cant_spawn_as_rev = TRUE
	announce_on_join = TRUE
	allow_spy_theft = FALSE
	wiki_link = "https://wiki.ss13.co/Chief_Engineer"

	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_belt = list(/obj/item/storage/belt/utility/prepared/ceshielded)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat/chief_engineer)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_jump = list(/obj/item/clothing/under/rank/chief_engineer)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/engineering)
	slot_poc2 = list(/obj/item/device/pda2/chiefengineer)
	items_in_backpack = list(/obj/item/device/flash, /obj/item/rcd_ammo/medium)

	derelict
		name = null//"Salvage Chief"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/space/industrial)
		slot_foot = list(/obj/item/clothing/shoes/magnetic)
		slot_head = list(/obj/item/clothing/head/helmet/space/industrial)
		slot_belt = list(/obj/item/tank/emergency_oxygen)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_eyes = list(/obj/item/clothing/glasses/thermal) // mesons look fuckin weird in the dark
		items_in_backpack = list(/obj/item/crowbar,/obj/item/rcd,/obj/item/rcd_ammo,/obj/item/rcd_ammo,/obj/item/device/light/flashlight,/obj/item/cell/cerenkite)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/research_director
	name = "Research Director"
	limit = 1
	wages = PAY_IMPORTANT
	trait_list = list("training_scientist")
	access_string = "Research Director"
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	announce_on_join = TRUE
	wiki_link = "https://wiki.ss13.co/Research_Director"

	slot_back = list(/obj/item/storage/backpack/research)
	slot_belt = list(/obj/item/device/pda2/research_director)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/research_director)
	slot_suit = list(/obj/item/clothing/suit/labcoat/research_director)
	slot_rhan = list(/obj/item/clipboard/with_pen)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_ears = list(/obj/item/device/radio/headset/command/rd)
	items_in_backpack = list(/obj/item/device/flash)

	special_setup(var/mob/living/carbon/human/M)
		..()
		for_by_tcl(heisenbee, /obj/critter/domestic_bee/heisenbee)
			if (!heisenbee.beeMom)
				heisenbee.beeMom = M
				heisenbee.beeMomCkey = M.ckey

/datum/job/command/medical_director
	name = "Medical Director"
	limit = 1
	wages = PAY_IMPORTANT
	trait_list = list("training_medical")
	access_string = "Medical Director"
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	announce_on_join = TRUE
	wiki_link = "https://wiki.ss13.co/Medical_Director"

	slot_back = list(/obj/item/storage/backpack/medic)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/medical_director)
	slot_suit = list(/obj/item/clothing/suit/labcoat/medical_director)
	slot_ears = list(/obj/item/device/radio/headset/command/md)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_poc1 = list(/obj/item/device/pda2/medical_director)
	items_in_backpack = list(/obj/item/device/flash)

#ifdef MAP_OVERRIDE_MANTA
/datum/job/command/comm_officer
	name = "Communications Officer"
	limit = 1
	wages = PAY_IMPORTANT
	access_string = "Communications Officer"
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	announce_on_join = TRUE
	wiki_link = "https://wiki.ss13.co/Communications_Officer"

	slot_ears = list(/obj/item/device/radio/headset/command/comm_officer)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_jump = list(/obj/item/clothing/under/rank/comm_officer)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_poc1 = list(/obj/item/pen/fancy)
	slot_head = list(/obj/item/clothing/head/sea_captain/comm_officer_hat)
	items_in_backpack = list(/obj/item/device/camera_viewer/security, /obj/item/device/audio_log, /obj/item/device/flash)
#endif

// Security Jobs

ABSTRACT_TYPE(/datum/job/security)
/datum/job/security
	linkcolor = "#FF0000"
	slot_card = /obj/item/card/id/security
	receives_miranda = TRUE
	job_category = JOB_SECURITY

/datum/job/security/security_officer
	name = "Security Officer"
	limit = 5
	lower_limit = 3
	variable_limit = TRUE
	high_priority_job = TRUE
	high_priority_limit = 2 //always try to make sure there's at least a couple of secoffs
	order_priority = 2 //fill secoffs after captain and AI
	wages = PAY_TRADESMAN
	trait_list = list("training_security")
	access_string = "Security Officer"
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_con = TRUE
	cant_spawn_as_rev = TRUE
	receives_implants = list(/obj/item/implant/health/security/anti_mindhack)
	receives_disk = /obj/item/disk/data/floppy/security
	receives_badge = TRUE
	slot_back = list(/obj/item/storage/backpack/security)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/rank/security)
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat/security)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	slot_poc1 = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_poc2 = list(/obj/item/requisition_token/security)
	rounds_needed_to_play = ROUNDS_MIN_SECURITY
	wiki_link = "https://wiki.ss13.co/Security_Officer"

	assistant
		name = "Security Assistant"
		limit = 3
		lower_limit = 2
		high_priority_job = FALSE //nope
		cant_spawn_as_con = TRUE
		wages = PAY_UNTRAINED
		access_string = "Security Assistant"
		receives_implants = list(/obj/item/implant/health/security)
		slot_back = list(/obj/item/storage/backpack/security)
		slot_jump = list(/obj/item/clothing/under/rank/security/assistant)
		slot_suit = list()
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_head = list(/obj/item/clothing/head/red)
		slot_foot = list(/obj/item/clothing/shoes/brown)
		slot_poc1 = list(/obj/item/storage/security_pouch/assistant)
		slot_poc2 = list(/obj/item/requisition_token/security/assistant)
		items_in_backpack = list(/obj/item/paper/book/from_file/space_law)
		rounds_needed_to_play = ROUNDS_MIN_SECASS
		wiki_link = "https://wiki.ss13.co/Security_Assistant"

	derelict
		//name = "NT-SO Officer"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/NT_alt)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/helmet/swat)
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_belt = list(/obj/item/gun/energy/laser_gun)
		slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/baton,/obj/item/breaching_charge,/obj/item/breaching_charge)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/security/detective
	name = "Detective"
	limit = 1
	wages = PAY_TRADESMAN
	trait_list = list("training_drinker")
	access_string = "Detective"
	receives_badge = TRUE
	cant_spawn_as_rev = TRUE
	can_join_gangs = FALSE
	allow_antag_fallthrough = FALSE
	unique = TRUE
	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/storage/belt/security/shoulder_holster)
	slot_poc1 = list(/obj/item/device/pda2/forensic)
	slot_jump = list(/obj/item/clothing/under/rank/det)
	slot_foot = list(/obj/item/clothing/shoes/detective)
	slot_head = list(/obj/item/clothing/head/det_hat)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_suit = list(/obj/item/clothing/suit/det_suit)
	slot_ears = list(/obj/item/device/radio/headset/detective)
	items_in_backpack = list(/obj/item/clothing/glasses/vr,/obj/item/storage/box/detectivegun)
	map_can_autooverride = FALSE
	rounds_needed_to_play = ROUNDS_MIN_DETECTIVE
	wiki_link = "https://wiki.ss13.co/Detective"

	special_setup(var/mob/living/carbon/human/M)
		..()

		if (M.traitHolder && !M.traitHolder.hasTrait("smoker"))
			items_in_backpack += list(/obj/item/device/light/zippo) //Smokers start with a trinket version

// Research Jobs

ABSTRACT_TYPE(/datum/job/research)
/datum/job/research
	linkcolor = "#9900FF"
	slot_card = /obj/item/card/id/research
	job_category = JOB_RESEARCH

/datum/job/research/geneticist
	name = "Geneticist"
	limit = 2
	wages = PAY_DOCTORATE
	access_string = "Geneticist"
	slot_back = list(/obj/item/storage/backpack/genetics)
	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_jump = list(/obj/item/clothing/under/rank/geneticist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_suit = list(/obj/item/clothing/suit/labcoat/genetics)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_poc1 = list(/obj/item/device/analyzer/genetic)
	wiki_link = "https://wiki.ss13.co/Geneticist"

/datum/job/research/roboticist
	name = "Roboticist"
	limit = 3
	wages = PAY_DOCTORATE
	trait_list = list("training_medical")
	access_string = "Roboticist"
	slot_back = list(/obj/item/storage/backpack/robotics)
	slot_belt = list(/obj/item/storage/belt/roboticist/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/roboticist)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_suit = list(/obj/item/clothing/suit/labcoat/robotics)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_poc1 = list(/obj/item/device/pda2/medical/robotics)
	slot_poc2 = list(/obj/item/reagent_containers/mender/brute)
	wiki_link = "https://wiki.ss13.co/Roboticist"

/datum/job/research/scientist
	name = "Scientist"
	limit = 5
	wages = PAY_DOCTORATE
	trait_list = list("training_scientist")
	access_string = "Scientist"
	slot_back = list(/obj/item/storage/backpack/research)
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_suit = list(/obj/item/clothing/suit/labcoat/science)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_lhan = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_poc1 = list(/obj/item/pen = 50, /obj/item/pen/fancy = 25, /obj/item/pen/red = 5, /obj/item/pen/pencil = 20)
	wiki_link = "https://wiki.ss13.co/Scientist"

/datum/job/research/research_assistant
	name = "Research Trainee"
	limit = 2
	wages = PAY_UNTRAINED
	trait_list = list("training_scientist")
	access_string = "Scientist"
	rounds_allowed_to_play = ROUNDS_MAX_RESASS
	slot_back = list(/obj/item/storage/backpack/research)
	slot_ears = list(/obj/item/device/radio/headset/research)
	slot_jump = list(/obj/item/clothing/under/color/purple)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_poc1 = list(/obj/item/pen = 50, /obj/item/pen/fancy = 25, /obj/item/pen/red = 5, /obj/item/pen/pencil = 20)
	wiki_link = "https://wiki.ss13.co/Research_Assistant"

/datum/job/research/medical_doctor
	name = "Medical Doctor"
	limit = 5
	wages = PAY_DOCTORATE
	trait_list = list("training_medical")
	access_string = "Medical Doctor"
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/medical)
	slot_suit = list(/obj/item/clothing/suit/labcoat/medical)
	slot_foot = list(/obj/item/clothing/shoes/red)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_poc1 = list(/obj/item/device/pda2/medical)
	slot_poc2 = list(/obj/item/paper/book/from_file/pocketguide/medical)
	items_in_backpack = list(/obj/item/crowbar/blue) // cogwerks: giving medics a guaranteed air tank, stealing it from roboticists (those fucks)
	// 2018: guaranteed air tanks now spawn in boxes (depending on backpack type) to save room
	wiki_link = "https://wiki.ss13.co/Medical_Doctor"

	derelict
		//name = "Salvage Medic"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/vest)
		slot_head = list(/obj/item/clothing/head/helmet/swat)
		slot_belt = list(/obj/item/tank/emergency_oxygen)
		slot_mask = list(/obj/item/clothing/mask/breath)
		slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
		slot_glov = list(/obj/item/clothing/gloves/latex)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/storage/firstaid/regular,/obj/item/storage/firstaid/regular)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M) return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/research/medical_assistant
	name = "Medical Trainee"
	limit = 2
	wages = PAY_UNTRAINED
	trait_list = list("training_medical")
	access_string = "Medical Doctor"
	rounds_allowed_to_play = ROUNDS_MAX_MEDASS
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_foot = list(/obj/item/clothing/shoes/red)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_poc1 = list(/obj/item/device/pda2/medical)
	slot_poc2 = list(/obj/item/paper/book/from_file/pocketguide/medical)
	slot_jump = list(/obj/item/clothing/under/scrub = 30,/obj/item/clothing/under/scrub/teal = 14,/obj/item/clothing/under/scrub/blue = 14,/obj/item/clothing/under/scrub/purple = 14,/obj/item/clothing/under/scrub/orange = 14,/obj/item/clothing/under/scrub/pink = 14)
	wiki_link = "https://wiki.ss13.co/Medical_Assistant"

// Engineering Jobs

ABSTRACT_TYPE(/datum/job/engineering)
/datum/job/engineering
	linkcolor = "#FF9900"
	slot_card = /obj/item/card/id/engineering
	job_category = JOB_ENGINEERING

/datum/job/engineering/quartermaster
	name = "Quartermaster"
	limit = 3
	wages = PAY_TRADESMAN
	trait_list = list("training_quartermaster")
	access_string = "Quartermaster"
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_jump = list(/obj/item/clothing/under/rank/cargo)
	slot_belt = list(/obj/item/device/pda2/quartermaster)
	slot_ears = list(/obj/item/device/radio/headset/shipping)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/quartermaster)
	slot_poc2 = list(/obj/item/device/appraisal)
	wiki_link = "https://wiki.ss13.co/Quartermaster"

/datum/job/engineering/miner
	name = "Miner"
	#ifdef UNDERWATER_MAP
	limit = 6
	#else
	limit = 5
	#endif
	wages = PAY_TRADESMAN
	trait_list = list("training_miner")
	access_string = "Miner"
	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_belt = list(/obj/item/storage/belt/mining/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/overalls)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/miner)
	slot_poc1 = list(/obj/item/device/pda2/mining)
	#ifdef UNDERWATER_MAP
	slot_suit = list(/obj/item/clothing/suit/space/diving/engineering)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer/diving/engineering)
	items_in_backpack = list(/obj/item/paper/book/from_file/pocketguide/mining,
							/obj/item/clothing/shoes/flippers,
							/obj/item/item_box/glow_sticker)
	#else
	slot_suit = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer)
	items_in_backpack = list(/obj/item/crowbar,
							/obj/item/paper/book/from_file/pocketguide/mining)
	#endif
	wiki_link = "https://wiki.ss13.co/Miner"

/datum/job/engineering/engineer
	name = "Engineer"
	limit = 8
	wages = PAY_TRADESMAN
	trait_list = list("training_engineer")
	access_string = "Engineer"
	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical/engineer_spawn)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_poc1 = list(/obj/item/device/pda2/engine)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
#ifdef MAP_OVERRIDE_OSHAN
	items_in_backpack = list(/obj/item/paper/book/from_file/pocketguide/engineering, /obj/item/clothing/shoes/stomp_boots)
#else
	items_in_backpack = list(/obj/item/paper/book/from_file/pocketguide/engineering, /obj/item/old_grenade/oxygen)
#endif
	wiki_link = "https://wiki.ss13.co/Engineer"

	derelict
		name = null//"Salvage Engineer"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/space/engineer)
		slot_head = list(/obj/item/clothing/head/helmet/welding)
		slot_belt = list(/obj/item/tank/emergency_oxygen)
		slot_mask = list(/obj/item/clothing/mask/breath)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/device/light/glowstick,/obj/item/gun/kinetic/flaregun,/obj/item/ammo/bullets/flare,/obj/item/cell/cerenkite)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/engineering/technical_assistant
	name = "Technical Trainee"
	limit = 2
	wages = PAY_UNTRAINED
	trait_list = list("training_engineer")
	access_string = "Engineer"
	rounds_allowed_to_play = ROUNDS_MAX_TECHASS
	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical/engineer_spawn)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	slot_jump = list(/obj/item/clothing/under/color/yellow)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_belt = list(/obj/item/device/pda2/technical_assistant)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/engineering)
	wiki_link = "https://wiki.ss13.co/Technical_Assistant"

// Civilian Jobs

ABSTRACT_TYPE(/datum/job/civilian)
/datum/job/civilian
	linkcolor = "#0099FF"
	slot_card = /obj/item/card/id/civilian
	job_category = JOB_CIVILIAN

/datum/job/civilian/chef
	name = "Chef"
	limit = 1
	wages = PAY_UNTRAINED
	trait_list = list("training_chef")
	access_string = "Chef"
	slot_belt = list(/obj/item/device/pda2/chef)
	slot_jump = list(/obj/item/clothing/under/rank/chef)
	slot_foot = list(/obj/item/clothing/shoes/chef)
	slot_head = list(/obj/item/clothing/head/chefhat)
	slot_suit = list(/obj/item/clothing/suit/chef)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/kitchen/rollingpin, /obj/item/kitchen/utensil/knife/cleaver, /obj/item/bell/kitchen)
	wiki_link = "https://wiki.ss13.co/Chef"

/datum/job/civilian/bartender
	name = "Bartender"
	alias_names = list("Barman")
	limit = 1
	wages = PAY_UNTRAINED
	trait_list = list("training_drinker", "training_bartender")
	access_string = "Bartender"
	slot_belt = list(/obj/item/device/pda2/bartender)
	slot_jump = list(/obj/item/clothing/under/rank/bartender)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/cloth/towel/bar)
	slot_poc2 = list(/obj/item/reagent_containers/food/drinks/cocktailshaker)
	items_in_backpack = list(/obj/item/gun/kinetic/sawnoff, /obj/item/ammo/bullets/abg, /obj/item/paper/book/from_file/pocketguide/bartending)
	wiki_link = "https://wiki.ss13.co/Bartender"

/datum/job/civilian/botanist
	name = "Botanist"
	#ifdef MAP_OVERRIDE_DONUT3
	limit = 7
	#else
	limit = 5
	#endif
	wages = PAY_TRADESMAN
	access_string = "Botanist"
	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_jump = list(/obj/item/clothing/under/rank/hydroponics)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_poc1 = list(/obj/item/paper/botany_guide)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Botanist"

	faction = list(FACTION_BOTANY)

/datum/job/civilian/rancher
	name = "Rancher"
	limit = 1
	wages = PAY_TRADESMAN
	access_string = "Rancher"
	slot_belt = list(/obj/item/storage/belt/rancher/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/rancher)
	slot_head = list(/obj/item/clothing/head/cowboy)
	slot_foot = list(/obj/item/clothing/shoes/westboot/brown/rancher)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_poc1 = list(/obj/item/paper/ranch_guide)
	slot_poc2 = list(/obj/item/device/pda2/botanist)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/device/camera_viewer/ranch,/obj/item/storage/box/knitting)
	wiki_link = "https://wiki.ss13.co/Rancher"

/datum/job/civilian/janitor
	name = "Janitor"
	limit = 3
	wages = PAY_TRADESMAN
	access_string = "Janitor"
	slot_belt = list(/obj/item/storage/fanny/janny)
	slot_jump = list(/obj/item/clothing/under/rank/janitor)
	slot_foot = list(/obj/item/clothing/shoes/galoshes)
	slot_glov = list(/obj/item/clothing/gloves/long)
	slot_rhan = list(/obj/item/mop)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/device/pda2/janitor)
	items_in_backpack = list(/obj/item/reagent_containers/glass/bucket, /obj/item/lamp_manufacturer/organic)
	wiki_link = "https://wiki.ss13.co/Janitor"

/datum/job/civilian/chaplain
	name = "Chaplain"
	limit = 1
	wages = PAY_UNTRAINED
	trait_list = list("training_chaplain")
	access_string = "Chaplain"
	slot_jump = list(/obj/item/clothing/under/rank/chaplain)
	slot_belt = list(/obj/item/device/pda2/chaplain)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/bible/loaded)
	wiki_link = "https://wiki.ss13.co/Chaplain"

	special_setup(var/mob/living/carbon/human/M)
		..()
		OTHER_START_TRACKING_CAT(M, TR_CAT_CHAPLAINS)

/datum/job/civilian/staff_assistant
	name = "Staff Assistant"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	no_jobban_from_this_job = TRUE
	low_priority_job = TRUE
	cant_allocate_unwanted = TRUE
	map_can_autooverride = FALSE
	slot_jump = list(/obj/item/clothing/under/rank/assistant)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Staff_Assistant"

	special_setup(mob/living/carbon/human/M, no_special_spawn)
		..()
		if (prob(20))
			M.stow_in_available(new /obj/item/paper/businesscard/seneca)


/datum/job/civilian/mail_courier
	name = "Mail Courier"
	linkcolor = "#0099FF"
	alias_names = "Mailman"
	wages = PAY_TRADESMAN
	access_string = "Mail Courier"
	limit = 1
	slot_jump = list(/obj/item/clothing/under/misc/mail/syndicate)
	slot_head = list(/obj/item/clothing/head/mailcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_ears = list(/obj/item/device/radio/headset/mail)
	slot_poc1 = list(/obj/item/pinpointer/mail_recepient)
	slot_belt = list(/obj/item/device/pda2/quartermaster)
	items_in_backpack = list(/obj/item/wrapping_paper, /obj/item/satchel/mail, /obj/item/scissors, /obj/item/stamp)
	alt_names = list("Head of Deliverying", "Mail Bringer")
	wiki_link = "https://wiki.ss13.co/Mailman"

/datum/job/civilian/clown
	name = "Clown"
	limit = 1
	wages = PAY_DUMBCLOWN
	trait_list = list("training_clown")
	access_string = "Clown"
	linkcolor = "#FF99FF"
	slot_back = list()
	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_mask = list(/obj/item/clothing/mask/clown_hat)
	slot_jump = list(/obj/item/clothing/under/misc/clown)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes)
	slot_lhan = list(/obj/item/instrument/bikehorn)
	slot_poc1 = list(/obj/item/device/pda2/clown)
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/plant/banana)
	slot_card = /obj/item/card/id/clown
	slot_ears = list(/obj/item/device/radio/headset/clown)
	items_in_belt = list(/obj/item/cloth/towel/clown)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Clown"

	faction = list(FACTION_CLOWN)

// AI and Cyborgs

/datum/job/civilian/AI
	name = "AI"
	linkcolor = "#999999"
	limit = 1
	no_late_join = TRUE
	high_priority_job = TRUE
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	slot_ears = list()
	slot_card = null
	slot_back = list()
	slot_belt = list()
	items_in_backpack = list()
	uses_character_profile = FALSE
	wiki_link = "https://wiki.ss13.co/Artificial_Intelligence"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		return M.AIize()

/datum/job/civilian/cyborg
	name = "Cyborg"
	linkcolor = "#999999"
	limit = 8
	no_late_join = TRUE
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	slot_ears = list()
	slot_card = null
	slot_back = list()
	slot_belt = list()
	items_in_backpack = list()
	uses_character_profile = FALSE
	wiki_link = "https://wiki.ss13.co/Cyborg"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/silicon/S = M.Robotize_MK2()
		APPLY_ATOM_PROPERTY(S, PROP_ATOM_ROUNDSTART_BORG, "borg")
		return S

// Special Cases
/datum/job/special
	name = "Special Job"
	wages = PAY_UNTRAINED
	wiki_link = "https://wiki.ss13.co/Jobs#Gimmick_Jobs" // fallback for those without their own page

#ifdef I_WANNA_BE_THE_JOB
/datum/job/special/imcoder
	name = "IMCODER"
	// Used for debug testing. No need to define special landmark, this overrides job picks
	access_string = "Captain"

	slot_belt = list(/obj/item/storage/belt/utility/prepared/ceshielded)
	slot_jump = list(/obj/item/clothing/under/rank/assistant)
	slot_foot = list(/obj/item/clothing/shoes/magnetic)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_head = list(/obj/item/clothing/head/helmet/space/light/engineer)
	slot_suit = list(/obj/item/clothing/suit/space/light/engineer)
	slot_back = list(/obj/item/storage/backpack)
	// slot_mask = list(/obj/item/clothing/mask/gas)
	items_in_backpack = list(
		/obj/item/rcd/construction/safe/admin_crimes,
		/obj/item/device/analyzer/atmospheric/upgraded,
		/obj/item/sheet/steel/fullstack,
		/obj/item/storage/box/cablesbox,
		/obj/item/tank/oxygen,
	)
#endif

/datum/job/special/station_builder
	// Used for Construction game mode, where you build the station
	name = "Station Builder"
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	limit = 0
	wages = PAY_TRADESMAN
	trait_list = list("training_engineer")
	access_string = "Construction Worker"
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_foot = list(/obj/item/clothing/shoes/magnetic)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	slot_rhan = list(/obj/item/tank/jetpack)
	slot_eyes = list(/obj/item/clothing/glasses/construction)
	slot_poc1 = list(/obj/item/currency/spacecash/fivehundred)
	slot_poc2 = list(/obj/item/room_planner)
	slot_suit = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer)
	slot_mask = list(/obj/item/clothing/mask/breath)
	wiki_link = "https://wiki.ss13.co/Construction_Game_Mode" // ?

	items_in_backpack = list(/obj/item/rcd/construction, /obj/item/rcd_ammo/big, /obj/item/rcd_ammo/big, /obj/item/material_shaper,/obj/item/room_marker)

/datum/job/special/hairdresser
	name = "Hairdresser"
	wages = PAY_UNTRAINED
	access_string = "Barber"
	limit = 0
	slot_jump = list(/obj/item/clothing/under/misc/barber)
	slot_head = list(/obj/item/clothing/head/boater_hat)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/scissors)
	slot_poc2 = list(/obj/item/razor_blade)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Barber"

/datum/job/special/mime
	name = "Mime"
	limit = 1
	wages = PAY_DUMBCLOWN*2 // lol okay whatever
	trait_list = list("training_mime")
	access_string = "Mime"
	slot_belt = list(/obj/item/device/pda2)
	slot_head = list(/obj/item/clothing/head/mime_bowler)
	slot_mask = list(/obj/item/clothing/mask/mime)
	slot_jump = list(/obj/item/clothing/under/misc/mime/alt)
	slot_suit = list(/obj/item/clothing/suit/scarf)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/pen/crayon/white)
	slot_poc2 = list(/obj/item/paper)
	items_in_backpack = list(/obj/item/baguette, /obj/item/instrument/whistle/janitor)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Mime"

/datum/job/special/attorney
	name = "Attorney"
	linkcolor = "#FF0000"
	wages = PAY_DOCTORATE
	access_string = "Lawyer"
	limit = 0
	receives_badge = TRUE
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Lawyer"

/datum/job/special/attorney/judge
	name = "Judge"
	limit = 0
	access_string = "Captain" // why does a judge have all access anyway?

/datum/job/special/vice_officer
	name = "Vice Officer"
	linkcolor = "#FF0000"
	limit = 0
	wages = PAY_TRADESMAN
	access_string = "Vice Officer"
	allow_traitors = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_con = TRUE
	cant_spawn_as_rev = TRUE
	receives_badge = TRUE
	receives_miranda = TRUE
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/misc/vice)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list( /obj/item/device/radio/headset/security)
	slot_poc1 = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_poc2 = list(/obj/item/requisition_token/security)
	wiki_link = "https://wiki.ss13.co/Part-Time_Vice_Officer"

/datum/job/special/forensic_technician
	name = "Forensic Technician"
	linkcolor = "#FF0000"
	limit = 0
	wages = PAY_TRADESMAN
	access_string = "Forensic Technician"
	cant_spawn_as_rev = TRUE
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/color/darkred)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_poc1 = list(/obj/item/device/detective_scanner)
	items_in_backpack = list(/obj/item/tank/emergency_oxygen)

/datum/job/special/hall_monitor
	name = "Hall Monitor"
	limit = 2
	wages = PAY_UNTRAINED
	access_string = "Hall Monitor"
	cant_spawn_as_rev = TRUE
	receives_badge = /obj/item/clothing/suit/security_badge/paper
	slot_belt = list(/obj/item/device/pda2)
	slot_jump = list(/obj/item/clothing/under/color/red)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_head = list(/obj/item/clothing/head/basecap/red)
	slot_poc1 = list(/obj/item/pen/pencil)
	slot_poc2 = list(/obj/item/device/radio/hall_monitor)
	items_in_backpack = list(/obj/item/instrument/whistle,/obj/item/device/ticket_writer/crust)


/datum/job/special/toxins_researcher
	name = "Toxins Researcher"
	linkcolor = "#9900FF"
	limit = 0
	wages = PAY_DOCTORATE
	trait_list = list("training_scientist")
	access_string = "Toxins Researcher"
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_lhan = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)

/datum/job/special/chemist
	name = "Chemist"
	linkcolor = "#9900FF"
	limit = 0
	wages = PAY_DOCTORATE
	trait_list = "training_scientist"
	access_string = "Chemist"
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_ears = list(/obj/item/device/radio/headset/research)
	wiki_link = "https://wiki.ss13.co/Chemist"

/datum/job/special/atmospheric_technician
	name = "Atmospherish Technician"
	linkcolor = "#FF9900"
	limit = 0
	wages = PAY_TRADESMAN
	access_string = "Atmospheric Technician"
	slot_belt = list(/obj/item/device/pda2/atmos)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/atmos)
	slot_jump = list(/obj/item/clothing/under/misc/atmospheric_technician)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical)
	slot_poc1 = list(/obj/item/device/analyzer/atmospheric)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	items_in_backpack = list(/obj/item/tank/mini_oxygen,/obj/item/crowbar)
	wiki_link = "https://wiki.ss13.co/Atmospheric_Technician"

/datum/job/special/stowaway
	name = "Stowaway"
	limit = 2
	wages = 0
	trait_list = list("stowaway")
	add_to_manifest = FALSE
	low_priority_job = TRUE
	slot_card = null
	slot_head = list(\
	/obj/item/clothing/head/green = 1,
	/obj/item/clothing/head/red = 1,
	/obj/item/clothing/head/constructioncone = 1,
	/obj/item/clothing/head/helmet/welding = 1,
	/obj/item/clothing/head/helmet/hardhat = 1,
	/obj/item/clothing/head/serpico = 1,
	/obj/item/clothing/head/souschefhat = 1,
	/obj/item/clothing/head/maid = 1,
	/obj/item/clothing/head/cowboy = 1)

	slot_mask = list(\
	/obj/item/clothing/mask/gas = 1,
	/obj/item/clothing/mask/surgical = 1,
	/obj/item/clothing/mask/skull = 1,
	/obj/item/clothing/mask/bandana/white = 1)

	slot_ears = list(\
	/obj/item/device/radio/headset/civilian = 8,
	/obj/item/device/radio/headset/engineer = 1,
	/obj/item/device/radio/headset/research = 1,
	/obj/item/device/radio/headset/shipping = 1,
	/obj/item/device/radio/headset/medical = 1,
	/obj/item/device/radio/headset/miner = 1)

	slot_suit = list(\
	/obj/item/clothing/suit/wintercoat/engineering = 1,
	/obj/item/clothing/suit/wintercoat/robotics = 1,
	/obj/item/clothing/suit/labcoat = 1,
	/obj/item/clothing/suit/labcoat/robotics = 1,
	/obj/item/clothing/suit/wintercoat/research = 1)

	slot_jump = list(\
	/obj/item/clothing/under/color/grey = 1,
	/obj/item/clothing/under/rank/security/assistant = 1,
	/obj/item/clothing/under/rank/roboticist = 1,
	/obj/item/clothing/under/rank/engineer = 1,
	/obj/item/clothing/under/rank/orangeoveralls = 1,
	/obj/item/clothing/under/rank/orangeoveralls/yellow = 1,
	/obj/item/clothing/under/gimmick/maid = 1,
	/obj/item/clothing/under/rank/bartender = 1,
	/obj/item/clothing/under/misc/souschef = 1,
	/obj/item/clothing/under/rank/hydroponics = 1,
	/obj/item/clothing/under/rank/rancher = 1,
	/obj/item/clothing/under/rank/overalls = 1,
	/obj/item/clothing/under/rank/cargo = 1,
	/obj/item/clothing/under/rank/assistant = 10,
	/obj/item/clothing/under/rank/janitor = 1)

	slot_glov = list(\
	/obj/item/clothing/gloves/yellow/unsulated = 1,
	/obj/item/clothing/gloves/black = 1,
	/obj/item/clothing/gloves/fingerless = 1,
	/obj/item/clothing/gloves/long = 1)

	slot_foot = list(\
	/obj/item/clothing/shoes/brown = 6,
	/obj/item/clothing/shoes/red = 1,
	/obj/item/clothing/shoes/white = 1,
	/obj/item/clothing/shoes/black = 4,
	/obj/item/clothing/shoes/swat = 1,
	/obj/item/clothing/shoes/orange = 1,
	/obj/item/clothing/shoes/westboot/brown/rancher = 1,
	/obj/item/clothing/shoes/galoshes = 1)

	slot_back = list(\
	/obj/item/storage/backpack = 1,
	/obj/item/storage/backpack/anello = 1,
	/obj/item/storage/backpack/security = 1,
	/obj/item/storage/backpack/engineering = 1,
	/obj/item/storage/backpack/robotics = 1,
	/obj/item/storage/backpack/research = 1)

	slot_belt = list(\
	/obj/item/crowbar = 6,
	/obj/item/crowbar/red = 1,
	/obj/item/crowbar/yellow = 1,
	/obj/item/crowbar/blue = 1,
	/obj/item/crowbar/grey = 1,
	/obj/item/crowbar/orange = 1)

	slot_poc1 = list(\
	/obj/item/screwdriver = 1,
	/obj/item/screwdriver/yellow = 1,
	/obj/item/screwdriver/grey = 1,
	/obj/item/screwdriver/orange = 1)

	slot_poc2 = list(\
	/obj/item/scissors = 1,
	/obj/item/wirecutters = 1,
	/obj/item/wirecutters/yellow = 1,
	/obj/item/wirecutters/grey = 1,
	/obj/item/wirecutters/orange = 1,
	/obj/item/scissors/surgical_scissors = 1)

	items_in_backpack = list(\
	/obj/item/currency/buttcoin,
	/obj/item/currency/spacecash/fivehundred)

/datum/job/special/souschef
	name = "Sous-Chef"
	limit = 1
	wages = PAY_UNTRAINED
	trait_list = list("training_chef")
	access_string = "Sous-Chef"
	requires_supervisor_job = "Chef"
	slot_belt = list(/obj/item/device/pda2/chef)
	slot_jump = list(/obj/item/clothing/under/misc/souschef)
	slot_foot = list(/obj/item/clothing/shoes/chef)
	slot_head = list(/obj/item/clothing/head/souschefhat)
	slot_suit = list(/obj/item/clothing/suit/apron)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Chef"

// randomizd gimmick jobs

ABSTRACT_TYPE(/datum/job/special/random)
/datum/job/special/random
	limit = 0
	name = "Random"

	New()
		..()
		if (prob(40))
			limit = 1
		if (src.alt_names.len)
			name = pick(src.alt_names)

/datum/job/special/random/hollywood
	name = "Hollywood Actor"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/suit/purple)

/datum/job/special/random/medical_specialist
	name = "Medical Specialist"
	linkcolor = "#9900FF"
	wages = PAY_IMPORTANT
	trait_list = list("training_medical", "training_partysurgeon")
	access_string = "Medical Specialist"
	slot_card = /obj/item/card/id/research
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_jump = list(/obj/item/clothing/under/scrub/maroon)
	slot_suit = list(/obj/item/clothing/suit/apron/surgeon)
	slot_head = list(/obj/item/clothing/head/bouffant)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_rhan = list(/obj/item/storage/firstaid/docbag)
	slot_poc1 = list(/obj/item/device/pda2/medical_director)
	alt_names = list(
		"Acupuncturist",
	  	"Anesthesiologist",
		"Cardiologist",
		"Dental Specialist",
		"Dermatologist",
		"Emergency Medicine Specialist",
		"Hematology Specialist",
		"Hepatology Specialist",
		"Immunology Specialist",
		"Internal Medicine Specialist",
		"Maxillofacial Specialist",
		"Medical Director's Assistant",
		"Neurological Specialist",
		"Ophthalmic Specialist",
		"Orthopaedic Specialist",
		"Otorhinolaryngology Specialist",
		"Plastic Surgeon",
		"Thoracic Specialist",
		"Vascular Specialist",
	)

/datum/job/special/random/vip
	name = "VIP"
	wages = PAY_EXECUTIVE
	access_string = "VIP"
	linkcolor = "#FF0000"
	slot_jump = list(/obj/item/clothing/under/suit/black)
	slot_head = list(/obj/item/clothing/head/that)
	slot_eyes = list(/obj/item/clothing/glasses/monocle)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/secure/sbriefcase)
	items_in_backpack = list(/obj/item/baton/cane)
	alt_names = list("Senator", "President", "Board Member", "Mayor", "Vice-President", "Governor")
	wiki_link = "https://wiki.ss13.co/VIP"

	special_setup(var/mob/living/carbon/human/M)
		..()

		var/obj/item/storage/secure/sbriefcase/B = M.find_type_in_hand(/obj/item/storage/secure/sbriefcase)
		if (B && istype(B))
			for (var/i = 1 to 2)
				B.storage.add_contents(new /obj/item/stamped_bullion(B))

		return

/datum/job/special/random/inspector
	name = "Inspector"
	wages = PAY_IMPORTANT
	access_string = "Inspector"
	receives_miranda = TRUE
	cant_spawn_as_rev = TRUE
	receives_badge = TRUE
	slot_card = /obj/item/card/id/nanotrasen
	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2/ntofficial)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer/black) // so they can slam tables
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command/inspector)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_suit = list(/obj/item/clothing/suit/armor/NT)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_rhan = list(/obj/item/device/ticket_writer)
	items_in_backpack = list(/obj/item/device/flash)
	wiki_link = "https://wiki.ss13.co/Inspector"

	proc/inspector_miranda()
		return "You have been found to be in breach of Nanotrasen corporate regulation [rand(1,100)][pick(uppercase_letters)]. You are allowed a grace period of 5 minutes to correct this infringement before you may be subjected to disciplinary action including but not limited to: strongly worded tickets, reduction in pay, and being buried in paperwork for the next [rand(10,20)] standard shifts."

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/instrument/whistle(B))
			var/obj/item/clipboard/with_pen/inspector/clipboard = new /obj/item/clipboard/with_pen/inspector(B)
			B.storage.add_contents(clipboard)
			clipboard.set_owner(M)
		M.mind?.set_miranda(list(PROC_REF(inspector_miranda)))
		return

/datum/job/special/random/diplomat
	name = "Diplomat"
	wages = PAY_DUMBCLOWN
	access_string = "Diplomat"
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Diplomat", "Ambassador")
	cant_spawn_as_rev = TRUE
	change_name_on_spawn = TRUE

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian,/datum/mutantrace/blob,/datum/mutantrace/cow)
		M.set_mutantrace(morph)
		if (istype(M.mutantrace, /datum/mutantrace/martian) || istype(M.mutantrace, /datum/mutantrace/blob))
			M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_IN_BACKPACK)
		else
			if (M.l_store)
				M.stow_in_available(M.l_store)
			M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_L_STORE)

/datum/job/special/random/testsubject
	name = "Test Subject"
	wages = PAY_DUMBCLOWN
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_mask = list(/obj/item/clothing/mask/monkey_translator)
	change_name_on_spawn = TRUE
	starting_mutantrace = /datum/mutantrace/monkey
	wiki_link = "https://wiki.ss13.co/Monkey"

/datum/job/special/random/union
	name = "Union Rep"
	wages = PAY_TRADESMAN
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Assistants Union Rep", "Cargo Union Rep", "Catering Union Rep", "Union Rep", "Security Union Rep", "Doctors Union Rep", "Engineers Union Rep", "Miners Union Rep")
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/clipboard/with_pen(B))

		return

/datum/job/special/random/salesman
	name = "Salesman"
	wages = PAY_TRADESMAN
	slot_suit = list(/obj/item/clothing/suit/merchant)
	slot_jump = list(/obj/item/clothing/under/gimmick/merchant)
	slot_head = list(/obj/item/clothing/head/merchant_hat)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Salesman", "Merchant")
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Salesman"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if(prob(33))
			var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian)
			M.set_mutantrace(morph)

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			for (var/i = 1 to 2)
				B.storage.add_contents(new /obj/item/stamped_bullion(B))

		return

/datum/job/special/random/coach
	name = "Coach"
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/jersey)
	slot_suit = list(/obj/item/clothing/suit/armor/vest/macho)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_poc1 = list(/obj/item/instrument/whistle)
	slot_glov = list(/obj/item/clothing/gloves/boxing)
	items_in_backpack = list(/obj/item/football,/obj/item/football,/obj/item/basketball,/obj/item/basketball)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/journalist
	name = "Journalist"
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/suit/red)
	slot_head = list(/obj/item/clothing/head/fedora)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_poc1 = list(/obj/item/camera)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	items_in_backpack = list(/obj/item/camera_film/large)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/device/camera_viewer/public(B))
			B.storage.add_contents(new /obj/item/clothing/head/helmet/camera(B))
			B.storage.add_contents(new /obj/item/device/audio_log(B))
			B.storage.add_contents(new /obj/item/clipboard/with_pen(B))

		return

/datum/job/special/random/beekeeper
	name = "Apiculturist"
	wages = PAY_TRADESMAN
	access_string = "Apiculturist"
	slot_jump = list(/obj/item/clothing/under/rank/beekeeper)
	slot_suit = list(/obj/item/clothing/suit/hazard/beekeeper)
	slot_head = list(/obj/item/clothing/head/bio_hood/beekeeper)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/beefood)
	slot_poc2 = list(/obj/item/paper/book/from_file/bee_book)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/bee_egg_carton, /obj/item/bee_egg_carton, /obj/item/bee_egg_carton, /obj/item/reagent_containers/food/snacks/beefood, /obj/item/reagent_containers/food/snacks/beefood)
	alt_names = list("Apiculturist", "Apiarist")
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

	faction = list(FACTION_BOTANY)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if (prob(15))
			var/obj/critter/domestic_bee/bee = new(get_turf(M))
			bee.beeMom = M
			bee.beeMomCkey = M.ckey
			bee.name = pick_string("bee_names.txt", "beename")
			bee.name = replacetext(bee.name, "larva", "bee")

		M.bioHolder.AddEffect("bee", magical=1) //They're one with the bees!


/datum/job/special/random/angler
	name = "Angler"
	wages = PAY_TRADESMAN
	access_string = "Rancher"
	slot_jump = list(/obj/item/clothing/under/rank/angler)
	slot_head = list(/obj/item/clothing/head/black)
	slot_foot = list(/obj/item/clothing/shoes/galoshes/waders)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/fishing_rod/basic)


/datum/job/special/random/pharmacist
	name = "Pharmacist"
	wages = PAY_DOCTORATE
	trait_list = list("training_medical")
	access_string = "Pharmacist"
	slot_card = /obj/item/card/id/research
	slot_belt = list(/obj/item/device/pda2/medical)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	items_in_backpack = list(/obj/item/storage/box/beakerbox, /obj/item/storage/pill_bottle/cyberpunk)

/datum/job/special/random/radioshowhost
	name = "Radio Show Host"
	wages = PAY_TRADESMAN
	access_string = "Radio Show Host"
#ifdef MAP_OVERRIDE_MANTA
	limit = 0
	special_spawn_location = null
#elif defined(MAP_OVERRIDE_OSHAN)
	limit = 1
	special_spawn_location = null
#elif defined(MAP_OVERRIDE_NADIR)
	limit = 1
	special_spawn_location = null
#else
	limit = 1
	special_spawn_location = LANDMARK_RADIO_SHOW_HOST
#endif
	slot_ears = list(/obj/item/device/radio/headset/command/radio_show_host)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_card = /obj/item/card/id/civilian
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/drinks/coffee)
	items_in_backpack = list(/obj/item/device/camera_viewer/security, /obj/item/device/audio_log, /obj/item/storage/box/record/radio/host)
	alt_names = list("Radio Show Host", "Talk Show Host")
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Radio_Host"

/datum/job/special/random/psychiatrist
	name = "Psychiatrist"
	wages = PAY_DOCTORATE
	access_string = "Psychiatrist"
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_card = /obj/item/card/id/research
	slot_belt = list(/obj/item/device/pda2/medical)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_poc1 = list(/obj/item/reagent_containers/food/drinks/tea)
	slot_poc2 = list(/obj/item/reagent_containers/food/drinks/bottle/gin)
	items_in_backpack = list(/obj/item/luggable_computer/personal, /obj/item/clipboard/with_pen, /obj/item/paper_bin, /obj/item/stamp)
	alt_names = list("Psychiatrist", "Psychologist", "Psychotherapist", "Therapist", "Counselor", "Life Coach") // All with slightly different connotations

/datum/job/special/random/artist
	name = "Artist"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/misc/casualjeansblue)
	slot_head = list(/obj/item/clothing/head/mime_beret)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/currency/spacecash/twenty)
	slot_poc2 = list(/obj/item/pen/pencil)
	slot_lhan = list(/obj/item/storage/toolbox/artistic)
	items_in_backpack = list(/obj/item/canvas, /obj/item/canvas, /obj/item/storage/box/crayon/basic ,/obj/item/paint_can/random)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/foodcritic
	name = "Food Critic"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/shirt_pants_br)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc2 = list(/obj/item/paper)
	slot_lhan = list(/obj/item/clipboard/with_pen)
	items_in_backpack = list(/obj/item/item_box/postit)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/pestcontrol
	name = "Pest Control Specialist"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/gimmick/safari)
	slot_head = list(/obj/item/clothing/head/safari)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/pet_carrier)
	items_in_backpack = list(/obj/item/storage/box/mousetraps)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/vehiclemechanic
	name = "Vehicle Mechanic" // fallback name, gets changed later
	#ifdef UNDERWATER_MAP
	name = "Submarine Mechanic"
	#else
	name = "Pod Mechanic"
	#endif
	wages = PAY_TRADESMAN
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/mechanic)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical)
	#ifdef UNDERWATER_MAP
	items_in_backpack = list(/obj/item/preassembled_frame_box/sub, /obj/item/podarmor/armor_light, /obj/item/clothing/head/helmet/welding)
	#else
	items_in_backpack = list(/obj/item/preassembled_frame_box/putt, /obj/item/podarmor/armor_light, /obj/item/clothing/head/helmet/welding)
	#endif
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/phonemerchant
	name = "Phone Merchant"
	wages = PAY_TRADESMAN
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/gimmick/merchant)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/electronics/soldering)
	items_in_backpack = list(/obj/item/electronics/frame/phone, /obj/item/electronics/frame/phone, /obj/item/electronics/frame/phone, /obj/item/electronics/frame/phone)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

// god help us
/datum/job/special/random/influencer
	name = "Influencer"
	wages = PAY_UNTRAINED
	change_name_on_spawn = TRUE
	slot_foot = list(/obj/item/clothing/shoes/dress_shoes)
	slot_jump = list(/obj/item/clothing/under/misc/casualjeanspurp)
	slot_head = list(/obj/item/clothing/head/basecap/purple)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/device/audio_log)
	slot_poc2 = list(/obj/item/camera)
	items_in_backpack = list(/obj/item/storage/box/random_colas, /obj/item/clothing/head/helmet/camera, /obj/item/device/camera_viewer/public)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

#ifdef HALLOWEEN
/*
 * Halloween jobs
 */
ABSTRACT_TYPE(/datum/job/special/halloween)
/datum/job/special/halloween
	linkcolor = "#FF7300"
	wiki_link = "https://wiki.ss13.co/Jobs#Spooktober_Jobs"

/datum/job/special/halloween/blue_clown
	name = "Blue Clown"
	wages = PAY_DUMBCLOWN
	trait_list = list("training_clown")
	access_string = "Clown"
	limit = 1
	change_name_on_spawn = TRUE
	slot_back = list()
	slot_mask = list(/obj/item/clothing/mask/clown_hat/blue)
	slot_ears = list(/obj/item/device/radio/headset/clown)
	slot_jump = list(/obj/item/clothing/under/misc/clown/blue)
	slot_card = /obj/item/card/id/clown
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes/blue)
	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_poc1 = list(/obj/item/bananapeel)
	slot_poc2 = list(/obj/item/device/pda2/clown)
	slot_lhan = list(/obj/item/instrument/bikehorn)

	faction = list(FACTION_CLOWN)

	special_setup(var/mob/living/carbon/human/M)
		..()
		M.bioHolder.AddEffect("regenerator", magical=1)

/datum/job/special/halloween/candy_salesman
	name = "Candy Salesman"
	wages = PAY_UNTRAINED
	access_string = "Salesman"
	limit = 1
	slot_head = list(/obj/item/clothing/head/that/purple)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/suit/purple)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/storage/pill_bottle/cyberpunk)
	slot_poc2 = list(/obj/item/storage/pill_bottle/catdrugs)
	items_in_backpack = list(/obj/item/storage/goodybag, /obj/item/kitchen/everyflavor_box, /obj/item/item_box/heartcandy, /obj/item/kitchen/peach_rings)

/datum/job/special/halloween/pumpkin_head
	name = "Pumpkin Head"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/pumpkin)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/color/orange)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/candy/candy_corn)
	slot_poc2 = list(/obj/item/item_box/assorted/stickers/stickers_limited)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("quiet_voice", magical=1)

/datum/job/special/halloween/wanna_bee
	name = "WannaBEE"
	wages = PAY_UNTRAINED
	access_string = "Botanist"
	limit = 1
	slot_head = list(/obj/item/clothing/head/headband/bee)
	slot_suit = list(/obj/item/clothing/suit/bee)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/rank/beekeeper)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/bee)
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy)
	items_in_backpack = list(/obj/item/reagent_containers/food/snacks/b_cupcake, /obj/item/reagent_containers/food/snacks/ingredient/royal_jelly)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("drunk_bee", magical=1)

/datum/job/special/halloween/dracula
	name = "Discount Dracula"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/that)
	slot_suit = list(/obj/item/clothing/suit/gimmick/vampire)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/vampire)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/syringe)
	slot_poc2 = list(/obj/item/reagent_containers/glass/beaker/large)
	slot_back = list(/obj/item/storage/backpack/satchel)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("aura", magical=1)
		M.bioHolder.AddEffect("cloak_of_darkness", magical=1)

/datum/job/special/halloween/werewolf
	name = "Discount Werewolf"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/werewolf)
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_suit = list(/obj/item/clothing/suit/gimmick/werewolf)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("jumpy", magical=1)

/datum/job/special/halloween/mummy
	name = "Discount Mummy"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_mask = list(/obj/item/clothing/mask/mummy)
	slot_jump = list(/obj/item/clothing/under/gimmick/mummy)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("aura", magical=1)
		M.bioHolder.AddEffect("midas", magical=1)

/datum/job/special/halloween/hotdog
	name = "Hot Dog"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_suit = list(/obj/item/clothing/suit/gimmick/hotdog)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)
	slot_back = list(/obj/item/storage/backpack/satchel/randoseru)
	slot_poc1 = list(/obj/item/shaker/ketchup)
	slot_poc2 = list(/obj/item/shaker/mustard)

/datum/job/special/halloween/godzilla
	name = "Discount Godzilla"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/biglizard)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/color/green)
	slot_suit = list(/obj/item/clothing/suit/gimmick/dinosaur)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/toy/figure)
	slot_poc2 = list(/obj/item/toy/figure)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("lizard", magical=1)
		M.bioHolder.AddEffect("loud_voice", magical=1)

/datum/job/special/halloween/macho
	name = "Discount Macho Man"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/helmet/macho)
	slot_eyes = list(/obj/item/clothing/glasses/macho)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/macho)
	slot_foot = list(/obj/item/clothing/shoes/macho)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/ingredient/sugar)
	slot_poc2 = list(/obj/item/sticker/ribbon/first_place)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("accent_chav", magical=1)

/datum/job/special/halloween/ghost
	name = "Ghost"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	slot_eyes = list(/obj/item/clothing/glasses/regular/ecto/goggles)
	slot_suit = list(/obj/item/clothing/suit/bedsheet)
	slot_ears = list(/obj/item/device/radio/headset)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("chameleon", magical=1)

/datum/job/special/halloween/ghost_buster
	name = "Ghost Buster"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_ears = list(/obj/item/device/radio/headset/ghost_buster)
	slot_eyes = list(/obj/item/clothing/glasses/regular/ecto/goggles)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/magnifying_glass)
	slot_poc2 = list(/obj/item/shaker/salt)
	items_in_backpack = list(/obj/item/device/camera_viewer/security, /obj/item/device/audio_log, /obj/item/gun/energy/ghost)
	alt_names = list("Paranormal Activities Investigator", "Spooks Specialist")
	change_name_on_spawn = TRUE

/datum/job/special/halloween/angel
	name = "Angel"
	wages = PAY_UNTRAINED
	trait_list = list("training_chaplain")
	access_string = "Chaplain"
	limit = 1
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/laurels/gold)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/birdman)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/coin)
	slot_poc2 = list(/obj/item/plant/herb/cannabis/white/spawnable)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("shiny", magical=1)
		M.bioHolder.AddEffect("healing_touch", magical=1)

/datum/job/special/halloween/vendor
	name = "Costume Vendor"
	wages = PAY_TRADESMAN
	limit = 1
	change_name_on_spawn = TRUE
	slot_jump = list(/obj/item/clothing/under/gimmick/trashsinglet)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_back = list(/obj/item/storage/backpack/satchel/anello)
	items_in_backpack = list(/obj/item/storage/box/costume/abomination,
	/obj/item/storage/box/costume/werewolf/odd,
	/obj/item/storage/box/costume/monkey,
	/obj/item/storage/box/costume/eighties,
	/obj/item/clothing/head/zombie)

/datum/job/special/halloween/devil
	name = "Devil"
	wages = PAY_UNTRAINED
	access_string = "Chaplain"
	limit = 0
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/headband/devil)
	slot_mask = list(/obj/item/clothing/mask/moustache/safe)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer/red/demonic)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/pen/fancy/satan)
	slot_poc2 = list(/obj/item/contract/juggle)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("hell_fire", magical=1)

/datum/job/special/halloween/superhero
	name = "Discount Vigilante Superhero"
	wages = PAY_UNTRAINED
	trait_list = list("training_security")
	access_string = "Staff Assistant"
	limit = 0
	change_name_on_spawn = TRUE
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	receives_miranda = TRUE
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud/superhero)
	slot_glov = list(/obj/item/clothing/gloves/latex/blue)
	slot_jump = list(/obj/item/clothing/under/gimmick/superhero)
	slot_foot = list(/obj/item/clothing/shoes/tourist)
	slot_belt = list(/obj/item/storage/belt/utility/superhero)
	slot_back = list()
	slot_poc2 = list(/obj/item/device/pda2)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if(prob(60))
			var/aggressive = pick("eyebeams","cryokinesis")
			var/defensive = pick("fire_resist","cold_resist","rad_resist","breathless") // no thermal resist, gotta have some sort of comic book weakness
			var/datum/bioEffect/power/be = M.bioHolder.AddEffect(aggressive, do_stability=0)
			if(aggressive == "eyebeams")
				var/datum/bioEffect/power/eyebeams/eb = be
				eb.stun_mode = 1
				eb.altered = 1
			else
				be.power = 1
				be.altered = 1
			be = M.bioHolder.AddEffect(defensive, do_stability=0)
		else
			var/datum/bioEffect/power/shoot_limb/sl = M.bioHolder.AddEffect("shoot_limb", do_stability=0)
			sl.safety = 1
			sl.altered = 1
			sl.cooldown = 300
			sl.stun_mode = 1
			var/datum/bioEffect/regenerator/r = M.bioHolder.AddEffect("regenerator", do_stability=0)
			r.regrow_prob = 10
		var/datum/bioEffect/power/be = M.bioHolder.AddEffect("adrenaline", do_stability=0)
		be.safety = 1
		be.altered = 1
		M?.mind?.miranda = "Evildoer! You have been apprehended by a hero of space justice!"

/datum/job/special/halloween/pickle
	name = "Pickle"
	wages = PAY_DUMBCLOWN
	access_string = "Staff Assistant"
	limit = 1
	change_name_on_spawn = TRUE
	slot_ears = list(/obj/item/device/radio/headset)
	slot_suit = list(/obj/item/clothing/suit/gimmick/pickle)
	slot_jump = list(/obj/item/clothing/under/color/green)
	slot_belt = list(/obj/item/device/pda2)
	slot_foot = list(/obj/item/clothing/shoes/black)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/obj/item/trinket = M.trinket?.deref()
		trinket?.setMaterial(getMaterial("pickle"))
		for (var/i in 1 to 3)
			var/type = pick(trinket_safelist)
			var/obj/item/pickle = new type(M.loc)
			pickle.setMaterial(getMaterial("pickle"))
			M.equip_if_possible(pickle, SLOT_IN_BACKPACK)
		M.bioHolder.RemoveEffect("midas") //just in case mildly mutated has given us midas I guess?
		M.bioHolder.AddEffect("pickle", magical=TRUE)
		M.blood_id = "juice_pickle"

/datum/job/special/halloween/cowboy
	name = "Space Cowboy"
	limit = 1
	wages = PAY_UNTRAINED
	starting_mutantrace = /datum/mutantrace/cow
	receives_badge = TRUE
	change_name_on_spawn = TRUE
	access_string = "Rancher" // it didnt actually have a unique string
	slot_jump = list(/obj/item/clothing/under/rank/det)
	slot_suit = list(/obj/item/clothing/suit/poncho)
	slot_belt = list(/obj/item/storage/belt/rancher/cowboy)
	slot_head = list(/obj/item/clothing/head/cowboy)
	slot_mask = list(/obj/item/clothing/mask/cigarette/random)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_foot = list(/obj/item/clothing/shoes/cowboy)
	slot_card = /obj/item/card/id/civilian
	slot_poc1 = list(/obj/item/device/pda2/botanist)
	slot_poc2 = list(/obj/item/device/light/zippo/gold)
	slot_back = list(/obj/item/storage/backpack/satchel/brown)

/datum/job/special/halloween/wizard
	name = "Discount Wizard"
	limit = 1
	wages = PAY_UNTRAINED
	change_name_on_spawn = TRUE
	access_string = "Staff Assistant"
	slot_jump = list(/obj/item/clothing/under/shorts/black)
	slot_suit = list(/obj/item/clothing/suit/bathrobe)
	slot_head = list(/obj/item/clothing/head/apprentice)
	slot_foot = list(/obj/item/clothing/shoes/fuzzy)
	items_in_backpack = list(/obj/item/mop)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("melt", magical=1)

/datum/job/special/halloween/spy
	name = "Super Spy"
	wages = PAY_UNTRAINED
	limit = 1
	access_string = "Staff Assistant"
	slot_jump = list(/obj/item/clothing/under/suit/black)
	slot_eyes = list(/obj/item/clothing/glasses/eyepatch)
	slot_suit = list(/obj/item/clothing/suit/armor/sneaking_suit/costume)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	items_in_backpack = list(/obj/item/clothing/suit/cardboard_box )

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("chameleon", magical=1)

ABSTRACT_TYPE(/datum/job/special/halloween/critter)
/datum/job/special/halloween/critter
	wages = PAY_DUMBCLOWN
	trusted_only = TRUE
	allow_traitors = FALSE
	slot_ears = list()
	slot_card = null
	slot_back = list()

	special_setup(var/mob/living/carbon/human/M)
		if (!M)
			return

		..()
		// Deactivate any gene that was activated by Mildly mutated trait
		M.bioHolder.DeactivateAllPoolEffects()

/datum/job/special/halloween/critter/plush
	name = "Plush Toy"
	trusted_only = FALSE
	limit = 2

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.critterize(/mob/living/critter/small_animal/plush/cryptid)

/datum/job/special/halloween/critter/remy
	name = "Remy"
	limit = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/small_animal/mouse/remy)
		C.flags = null

/datum/job/special/halloween/critter/bumblespider
	name = "Bumblespider"
	limit = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/spider/nice)
		C.flags = null

/datum/job/special/halloween/critter/crow
	name = "Crow"
	limit = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/small_animal/bird/crow)
		C.flags = null

// end halloween jobs
#endif

/datum/job/special/syndicate_weak
	linkcolor = "#880000"
	name = "Junior Syndicate Operative"
	limit = 0
	wages = 0
	slot_back = list(/obj/item/storage/backpack/syndie)
	slot_belt = list(/obj/item/gun/kinetic/pistol)
	slot_jump = list(/obj/item/clothing/under/misc/syndicate)
	slot_suit = list()
	slot_head = list()
	slot_foot = list(/obj/item/clothing/shoes/swat/noslip)
	slot_glov = list(/obj/item/clothing/gloves/swat/syndicate)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_ears = list()
	slot_mask = list(/obj/item/clothing/mask/gas/swat/syndicate)
	slot_card = null		///obj/item/card/id
	slot_poc1 = list(/obj/item/tank/emergency_oxygen/extended)
	slot_poc2 = list(/obj/item/storage/pouch/bullet_9mm)
	slot_lhan = list()
	slot_rhan = list()
	items_in_backpack = list(
		/obj/item/clothing/head/helmet/space/syndicate,
		/obj/item/clothing/suit/space/syndicate)

	faction = list(FACTION_SYNDICATE)
	radio_announcement = FALSE
	add_to_manifest = FALSE

	special_setup(var/mob/living/carbon/human/M)
		..()
		M.mind?.add_generic_antagonist(ROLE_SYNDICATE_AGENT, "Junior Syndicate Operative", source = ANTAGONIST_SOURCE_ADMIN)

/datum/job/special/syndicate_weak/no_ammo
	name = "Poorly Equipped Junior Syndicate Operative"
	slot_poc2 = list()

	faction = list(FACTION_SYNDICATE)

// hidden jobs for nt-so vs syndicate spec-ops

/datum/job/special/syndicate_specialist
	linkcolor = "#880000"
	name = "Syndicate Special Operative"
	limit = 0
	wages = 0
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	receives_implants = list(/obj/item/implant/revenge/microbomb)
	slot_back = list(/obj/item/storage/backpack/syndie)
	slot_belt = list(/obj/item/storage/belt/gun/pistol)
	slot_jump = list(/obj/item/clothing/under/misc/syndicate)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist)
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
	slot_foot = list(/obj/item/clothing/shoes/swat/noslip)
	slot_glov = list(/obj/item/clothing/gloves/swat/syndicate)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_ears = list(/obj/item/device/radio/headset/syndicate) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/swat/syndicate)
	slot_card = /obj/item/card/id
	slot_poc1 = list(/obj/item/tank/emergency_oxygen/extended)
	slot_poc2 = list(/obj/item/storage/pouch/assault_rifle)
	slot_lhan = list()
	slot_rhan = list(/obj/item/tank/jetpack/syndicate)
	items_in_backpack = list(/obj/item/gun/kinetic/assault_rifle,
							/obj/item/old_grenade/stinger/frag,
							/obj/item/breaching_charge,
							/obj/item/remote/syndicate_teleporter)

	faction = list(FACTION_SYNDICATE)
	radio_announcement = FALSE
	add_to_manifest = FALSE
	special_spawn_location = LANDMARK_SYNDICATE

	New()
		..()
		src.access = syndicate_spec_ops_access()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_generic_antagonist(ROLE_SYNDICATE_AGENT, "Syndicate Special Operative", source = ANTAGONIST_SOURCE_ADMIN)
		M.show_text("<b>The assault has begun! Head over to the station and kill any and all Nanotrasen personnel you encounter!</b>", "red")

/datum/job/special/pirate
	linkcolor = "#880000"
	name = "Space Pirate"
	limit = 0
	wages = 0
	add_to_manifest = FALSE
	radio_announcement = FALSE
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	slot_card = /obj/item/card/id
	slot_belt = list()
	slot_back = list()
	slot_jump = list()
	slot_foot = list()
	slot_head = list()
	slot_eyes = list()
	slot_ears = list()
	slot_poc1 = list()
	slot_poc2 = list()
	var/rank = ROLE_PIRATE

	New()
		..()
		src.access = list(access_maint_tunnels, access_pirate )
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		for (var/datum/antagonist/antag in M.mind.antagonists)
			if (antag.id == ROLE_PIRATE || antag.id == ROLE_PIRATE_FIRST_MATE || antag.id == ROLE_PIRATE_CAPTAIN)
				antag.give_equipment()
				return
		M.mind.add_antagonist(rank, source = ANTAGONIST_SOURCE_ADMIN)


	first_mate
		name = "Space Pirate First Mate"
		rank = ROLE_PIRATE_FIRST_MATE

	captain
		name = "Space Pirate Captain"
		rank = ROLE_PIRATE_CAPTAIN

/datum/job/special/juicer_specialist
	linkcolor = "#cc8899"
	name = "Juicer Security"
	limit = 0
	wages = 0
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	add_to_manifest = FALSE

	slot_back = list(/obj/item/gun/energy/blaster_cannon)
	slot_belt = list(/obj/item/storage/fanny)
	//more

/datum/job/special/ntso_specialist
	linkcolor = "#3348ff"
	name = "Nanotrasen Special Operative"
	limit = 0
	wages = PAY_IMPORTANT
	trait_list = list("training_security")
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_rev = TRUE
	receives_badge = TRUE
	receives_miranda = TRUE
	receives_implants = list(/obj/item/implant/health)
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/security/ntso)
	slot_jump = list(/obj/item/clothing/under/misc/turds)
	slot_suit = list(/obj/item/clothing/suit/space/ntso)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_glov = list(/obj/item/clothing/gloves/swat/NT)
	slot_eyes = list(/obj/item/clothing/glasses/nightvision/sechud/flashblocking)
	slot_ears = list(/obj/item/device/radio/headset/command/nt) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_card = /obj/item/card/id/nanotrasen
	slot_poc1 = list(/obj/item/device/pda2/ntso)
	slot_poc2 = list(/obj/item/storage/ntsc_pouch/ntso)
	items_in_backpack = list(/obj/item/storage/firstaid/regular,
							/obj/item/clothing/head/NTberet,
							/obj/item/currency/spacecash/fivehundred)

	faction = list(FACTION_NANOTRASEN)

	New()
		..()
		src.access = get_all_accesses() + access_centcom
		return

/datum/job/special/nt_engineer
	linkcolor = "#3348ff"
	name = "Nanotrasen Emergency Repair Technician"
	limit = 0
	wages = PAY_IMPORTANT
	trait_list = list("training_engineer")
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/utility/nt_engineer)
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_suit = list(/obj/item/clothing/suit/space/industrial/nt_specialist)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_foot = list(/obj/item/clothing/shoes/magnetic)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_ears = list(/obj/item/device/radio/headset/command/nt/engineer) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_card = /obj/item/card/id/nanotrasen
	slot_poc1 = list(/obj/item/tank/emergency_oxygen/extended)
	slot_poc2 = list(/obj/item/device/pda2/nt_engineer)
	items_in_backpack = list(/obj/item/storage/firstaid/regular,
							/obj/item/device/flash,
							/obj/item/sheet/steel/fullstack,
							/obj/item/sheet/glass/reinforced/fullstack)

	faction = list(FACTION_NANOTRASEN)

	New()
		..()
		src.access = get_all_accesses() + access_centcom

	special_setup(var/mob/living/carbon/human/M)
		..()
		SPAWN(1)
			var/obj/item/rcd/rcd = locate() in M.belt.storage.stored_items
			rcd.matter = 100
			rcd.max_matter = 100
			rcd.tooltip_rebuild = TRUE
			rcd.UpdateIcon()

/datum/job/special/nt_medical
	linkcolor = "#3348ff"
	name = "Nanotrasen Emergency Medic"
	limit = 0
	wages = PAY_IMPORTANT
	trait_list = list("training_medical")
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/medical)
	slot_suit = list(/obj/item/clothing/suit/hazard/paramedic/armored)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_ears = list(/obj/item/device/radio/headset/command/nt/medic) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_card = /obj/item/card/id/nanotrasen
	slot_poc1 = list(/obj/item/tank/emergency_oxygen/extended)
	slot_poc2 = list(/obj/item/device/pda2/nt_medical)
	items_in_backpack = list(/obj/item/storage/firstaid/regular,
							/obj/item/device/flash,
							/obj/item/reagent_containers/glass/bottle/omnizine,
							/obj/item/reagent_containers/glass/bottle/ether)

	faction = list(FACTION_NANOTRASEN)

	New()
		..()
		src.access = get_all_accesses() + access_centcom

// Use this one for late respawns to deal with existing antags. they are weaker cause they dont get a laser rifle or frags
/datum/job/special/nt_security
	linkcolor = "#3348ff"
	name = "Nanotrasen Security Consultant"
	limit = 1 // backup during HELL WEEK. players will probably like it
	unique = TRUE
	wages = PAY_TRADESMAN
	trait_list = list("training_security")
	access_string = "Nanotrasen Security Consultant"
	requires_whitelist = TRUE
	requires_supervisor_job = "Head of Security"
	counts_as = "Security Officer"
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_rev = TRUE
	receives_badge = TRUE
	receives_miranda = TRUE
	receives_implants = list(/obj/item/implant/health/security/anti_mindhack)
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/security/ntsc) //special secbelt subtype that spawns with the NTSO gear inside
	slot_jump = list(/obj/item/clothing/under/misc/turds)
	slot_suit = list(/obj/item/clothing/suit/space/ntso)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_glov = list(/obj/item/clothing/gloves/swat/NT)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	slot_ears = list(/obj/item/device/radio/headset/command/nt/consultant) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_card = /obj/item/card/id/nanotrasen
	slot_poc1 = list(/obj/item/storage/ntsc_pouch)
	slot_poc2 = list(/obj/item/device/pda2/ntso)
	items_in_backpack = list(/obj/item/storage/firstaid/regular)
	wiki_link = "https://wiki.ss13.co/Nanotrasen_Security_Consultant"

	faction = list(FACTION_NANOTRASEN)

/datum/job/special/headminer
	name = "Head of Mining"
	limit = 0
	wages = PAY_IMPORTANT
	trait_list = list("training_miner")
	access_string = "Head of Mining"
	linkcolor = "#00CC00"
	cant_spawn_as_rev = TRUE
	slot_card = /obj/item/card/id/command
	slot_belt = list(/obj/item/device/pda2/mining)
	slot_jump = list(/obj/item/clothing/under/rank/overalls)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	items_in_backpack = list(/obj/item/tank/emergency_oxygen,/obj/item/crowbar)

/datum/job/special/machoman
	name = "Macho Man"
	linkcolor = "#9E0E4D"
	limit = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()
	wiki_link = "https://wiki.ss13.co/Admin#Special_antagonists"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_antagonist(ROLE_MACHO_MAN, source = ANTAGONIST_SOURCE_ADMIN)

/datum/job/special/meatcube
	name = "Meatcube"
	linkcolor = "#FF0000"
	limit = 0
	allow_traitors = FALSE
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()
	add_to_manifest = FALSE
	wiki_link = "https://wiki.ss13.co/Critter#Other"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.cubeize(INFINITY)

/datum/job/special/ghostdrone
	name = "Drone"
	linkcolor = "#999999"
	limit = 0
	wages = 0
	allow_traitors = FALSE
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()
	wiki_link = "https://wiki.ss13.co/Ghostdrone"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		droneize(M, 0)

ABSTRACT_TYPE(/datum/job/daily)
/datum/job/daily //Special daily jobs
	var/day = ""
/datum/job/daily/boxer
	day = "Sunday"
	name = "Boxer"
	wages = PAY_UNTRAINED
	access_string = "Boxer"
	limit = 4
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/boxing)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Boxer"

/datum/job/daily/dungeoneer
	day = "Monday"
	name = "Dungeoneer"
	limit = 1
	wages = PAY_UNTRAINED
	access_string = "Dungeoneer"
	slot_belt = list(/obj/item/device/pda2)
	slot_mask = list(/obj/item/clothing/mask/skull)
	slot_jump = list(/obj/item/clothing/under/color/brown)
	slot_suit = list(/obj/item/clothing/suit/cultist/nerd)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_poc1 = list(/obj/item/pen/omni)
	slot_poc2 = list(/obj/item/paper)
	items_in_backpack = list(/obj/item/storage/box/nerd_kit)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Jobs#Job_of_the_Day" // no wiki page yet

/datum/job/daily/barber
	day = "Tuesday"
	name = "Barber"
	wages = PAY_UNTRAINED
	access_string = "Barber"
	limit = 1
	slot_jump = list(/obj/item/clothing/under/misc/barber)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/scissors)
	slot_poc2 = list(/obj/item/razor_blade)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Barber"

/datum/job/daily/waiter
	day = "Wednesday"
	name = "Waiter"
	wages = PAY_UNTRAINED
	access_string = "Waiter"
	slot_jump = list(/obj/item/clothing/under/rank/bartender)
	slot_suit = list(/obj/item/clothing/suit/wcoat)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/plate/tray)
	slot_poc1 = list(/obj/item/cloth/towel/white)
	items_in_backpack = list(/obj/item/storage/box/glassbox,/obj/item/storage/box/cutlery)
	wiki_link = "https://wiki.ss13.co/Jobs#Job_of_the_Day" // no wiki page yet

/datum/job/daily/lawyer
	day = "Thursday"
	name = "Lawyer"
	linkcolor = "#FF0000"
	wages = PAY_DOCTORATE
	access_string = "Lawyer"
	limit = 4
	receives_badge = TRUE
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Lawyer"


/datum/job/daily/tourist
	day = "Friday"
	name = "Tourist"
	limit = 100
	wages = 0
	linkcolor = "#FF99FF"
	slot_back = null
	slot_belt = list(/obj/item/storage/fanny)
	slot_jump = list(/obj/item/clothing/under/misc/tourist)
	slot_poc1 = list(/obj/item/camera_film)
	slot_poc2 = list(/obj/item/currency/spacecash/tourist) // Exact amount is randomized.
	slot_foot = list(/obj/item/clothing/shoes/tourist)
	slot_lhan = list(/obj/item/camera)
	slot_rhan = list(/obj/item/storage/photo_album)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Tourist"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/morph = null
		if(prob(33))
			morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian,/datum/mutantrace/blob,/datum/mutantrace/cow)

		if (morph && (morph == /datum/mutantrace/martian || morph == /datum/mutantrace/blob)) // doesn't wear human clothes
			M.equip_if_possible(new /obj/item/storage/backpack/empty(src), SLOT_BACK)
			var/obj/item/backpack = M.back

			var/obj/item/storage/fanny/belt_storage = M.belt
			if(istype(belt_storage))
				for(var/obj/item/I in belt_storage.storage.get_contents())
					belt_storage.storage.transfer_stored_item(I, backpack, TRUE, M)
			qdel(belt_storage)

			M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_IN_BACKPACK)

			M.stow_in_available(M.l_store, FALSE)
			M.stow_in_available(M.r_store, FALSE)

			var/obj/item/shirt = M.get_slot(SLOT_W_UNIFORM)
			M.drop_from_slot(shirt)
			qdel(shirt)

			var/obj/item/shoes = M.get_slot(SLOT_SHOES)
			M.drop_from_slot(shoes)
			qdel(shoes)

		else
			var/obj/item/clothing/lanyard/L = new /obj/item/clothing/lanyard(M.loc)
			var/obj/item/card/id = locate() in M
			if (id)
				L.storage.add_contents(id, M, FALSE)
			if (M.l_store)
				M.stow_in_available(M.l_store)
			M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_L_STORE)
			M.equip_if_possible(L, SLOT_WEAR_ID, TRUE)

		if(morph) // now that we've handled weird mutantrace cases, morph them
			M.set_mutantrace(morph)

/datum/job/daily/musician
	day = "Saturday"
	name = "Musician"
	limit = 3
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/suit/pinstripe)
	slot_head = list(/obj/item/clothing/head/flatcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/storage/briefcase/instruments)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Musician"

/datum/job/battler
	name = "Battler"
	limit = -1
	wiki_link = "https://wiki.ss13.co/Battler"

/datum/job/slasher
	name = "The Slasher"
	linkcolor = "#02020d"
	limit = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()
	wiki_link = "https://wiki.ss13.co/The_Slasher"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_antagonist(ROLE_SLASHER, source = ANTAGONIST_SOURCE_ADMIN)

ABSTRACT_TYPE(/datum/job/special/pod_wars)
/datum/job/special/pod_wars
	name = "Pod_Wars"
#ifdef MAP_OVERRIDE_POD_WARS
	limit = -1
	wages = 0 //Who needs cash when theres a battle to win
#else
	limit = 0
	wages = PAY_IMPORTANT
#endif
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	var/team = 0 //1 = NT, 2 = SY
	var/overlay_icon
	wiki_link = "https://wiki.ss13.co/Game_Modes#Pod_Wars"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if (!M.abilityHolder)
			M.abilityHolder = new /datum/abilityHolder/pod_pilot(src)
			M.abilityHolder.owner = src
		else if (istype(M.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/AH = M.abilityHolder
			AH.addHolder(/datum/abilityHolder/pod_pilot)

		//stuff for headsets
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			mode.setup_team_overlay(M.mind, overlay_icon)
			if (team == 1)
				M.mind.special_role = mode.team_NT?.name
				setup_headset(M.ears, mode.team_NT?.comms_frequency)
			else if (team == 2)
				M.mind.special_role = mode.team_SY?.name
				setup_headset(M.ears, mode.team_SY?.comms_frequency)

	proc/setup_headset(var/obj/item/device/radio/headset/headset, var/freq)
		if (istype(headset))
			headset.set_secure_frequency("g",freq)
			headset.secure_classes["g"] = RADIOCL_SYNDICATE
			headset.cant_self_remove = 0
			headset.cant_other_remove = 0

	nanotrasen
		name = "NanoTrasen Pod Pilot"
		linkcolor = "#3348ff"
		no_jobban_from_this_job = TRUE
		low_priority_job = TRUE
		cant_allocate_unwanted = TRUE
		access = list(access_heads, access_medical, access_medical_lockers)
		team = 1
		overlay_icon = "nanotrasen"

		faction = list(FACTION_NANOTRASEN)

		receives_implants = list(/obj/item/implant/pod_wars/nanotrasen)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_belt = list(/obj/item/device/pda2/pod_wars/nanotrasen)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/helmet/space/nanotrasen/pilot)
		slot_suit = list(/obj/item/clothing/suit/space/nanotrasen/pilot)
		slot_foot = list(/obj/item/clothing/shoes/swat)
		slot_card = /obj/item/card/id/pod_wars/nanotrasen
		slot_ears = list(/obj/item/device/radio/headset/pod_wars/nanotrasen)
		slot_mask = list(/obj/item/clothing/mask/gas/swat/NT)
		slot_glov = list(/obj/item/clothing/gloves/swat/NT)
		slot_poc1 = list(/obj/item/tank/emergency_oxygen/extended)
		slot_poc2 = list(/obj/item/requisition_token/podwars/NT)

		commander
			name = "NanoTrasen Commander"
#ifdef MAP_OVERRIDE_POD_WARS
			limit = 1
#else
			limit = 0
#endif
			no_jobban_from_this_job = FALSE
			high_priority_job = TRUE
			cant_allocate_unwanted = TRUE
			overlay_icon = "nanocomm"
			access = list(access_heads, access_captain, access_medical, access_medical_lockers, access_engineering_power)

			slot_head = list(/obj/item/clothing/head/NTberet/commander)
			slot_suit = list(/obj/item/clothing/suit/space/nanotrasen/pilot/commander)
			slot_card = /obj/item/card/id/pod_wars/nanotrasen/commander
			slot_ears = list(/obj/item/device/radio/headset/pod_wars/nanotrasen/commander)

	syndicate
		name = "Syndicate Pod Pilot"
		linkcolor = "#FF0000"
		no_jobban_from_this_job = TRUE
		low_priority_job = TRUE
		cant_allocate_unwanted = TRUE
		access = list(access_syndicate_shuttle, access_medical, access_medical_lockers)
		team = 2
		overlay_icon = "syndicate"
		add_to_manifest = FALSE

		faction = list(FACTION_SYNDICATE)

		receives_implants = list(/obj/item/implant/pod_wars/syndicate)
		slot_back = list(/obj/item/storage/backpack/syndie)
		slot_belt = list(/obj/item/device/pda2/pod_wars/syndicate)
		slot_jump = list(/obj/item/clothing/under/misc/syndicate)
		slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
		slot_suit = list(/obj/item/clothing/suit/space/syndicate)
		slot_foot = list(/obj/item/clothing/shoes/swat)
		slot_card = /obj/item/card/id/pod_wars/syndicate
		slot_ears = list(/obj/item/device/radio/headset/pod_wars/syndicate)
		slot_mask = list(/obj/item/clothing/mask/gas/swat)
		slot_glov = list(/obj/item/clothing/gloves/swat/syndicate)
		slot_poc1 = list(/obj/item/tank/emergency_oxygen/extended)
		slot_poc2 = list(/obj/item/requisition_token/podwars/SY)

		commander
			name = "Syndicate Commander"
#ifdef MAP_OVERRIDE_POD_WARS
			limit = 1
#else
			limit = 0
#endif
			no_jobban_from_this_job = FALSE
			high_priority_job = TRUE
			cant_allocate_unwanted = TRUE
			overlay_icon = "syndcomm"
			access = list(access_syndicate_shuttle, access_syndicate_commander, access_medical, access_medical_lockers, access_engineering_power)

			slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/commissar_cap)
			slot_suit = list(/obj/item/clothing/suit/space/syndicate/commissar_greatcoat)
			slot_card = /obj/item/card/id/pod_wars/syndicate/commander
			slot_ears = list(/obj/item/device/radio/headset/pod_wars/syndicate/commander)

/datum/job/football
	name = "Football Player"
	limit = -1
	wiki_link = "https://wiki.ss13.co/Game_Modes#Football"


/datum/job/special/gang_respawn
	name = "Gang Respawn"
	limit = 0
	wages = 0
	access_string = "Staff Assistant"
	slot_card = /obj/item/card/id/civilian
	slot_jump = list(/obj/item/clothing/under/rank/assistant)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	announce_on_join = FALSE
	add_to_manifest = FALSE

	special_setup(var/mob/living/carbon/human/M)
		..()
		SPAWN(0)
			var/obj/item/card/id/C = M.get_slot(SLOT_WEAR_ID)
			C.assignment = "Staff Assistant"
			C.name = "[C.registered]'s ID Card ([C.assignment])"

			var/obj/item/device/pda2/pda = locate() in M
			pda.assignment = "Staff Assistant"
			pda.ownerAssignment = "Staff Assistant"

/datum/job/special/pathologist
	name = "Pathologist"
	limit = 0
	wages = PAY_DOCTORATE
	access_string = "Pathologist"
	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_jump = list(/obj/item/clothing/under/rank/pathologist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_suit = list(/obj/item/clothing/suit/labcoat/pathology)
	slot_ears = list(/obj/item/device/radio/headset/medical)

/datum/job/special/performer
	name = "Performer"
	access_string = "Staff Assistant"
	limit = 0
	change_name_on_spawn = TRUE
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/black_wcoat)
	slot_foot = list(/obj/item/clothing/shoes/dress_shoes)
	slot_belt = list(/obj/item/device/pda2)
	items_in_backpack = list(/obj/item/storage/box/box_o_laughs, /obj/item/item_box/assorted/stickers/stickers_limited, /obj/item/currency/spacecash/twothousandfivehundred)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("accent_goodmin", magical=1)

/*---------------------------------------------------------------*/

/datum/job/created
	name = "Special Job"
	job_category = JOB_CREATED

	//handle special spawn location
	Write(F)
		. = ..()
		if(istext(src.special_spawn_location))
			F["special_spawn_location"] << src.special_spawn_location
		else if(ismovable(src.special_spawn_location) || isturf(src.special_spawn_location))
			var/atom/A = src.special_spawn_location
			var/turf/T = get_turf(A)
			F["special_spawn_location_coords"] << list(T.x, T.y, T.z)

	Read(F)
		. = ..()
		src.special_spawn_location = null
		var/maybe_spawn_loc = null
		F["special_spawn_location"] >> maybe_spawn_loc
		if(istext(maybe_spawn_loc))
			src.special_spawn_location = maybe_spawn_loc
		else
			var/list/maybe_coords = null
			F["special_spawn_location_coords"] >> maybe_coords
			if(islist(maybe_coords))
				src.special_spawn_location = locate(maybe_coords[1], maybe_coords[2], maybe_coords[3])
