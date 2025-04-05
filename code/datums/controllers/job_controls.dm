var/datum/job_controller/job_controls

/datum/job_controller/
	var/list/staple_jobs = list()
	var/list/special_jobs = list()
	var/list/hidden_jobs = list() // not visible to players, for admin stuff, like the respawn panel
	var/allow_special_jobs = 1 // hopefully this doesn't break anything!!
	var/datum/job/created/job_creator = null

	var/loaded_save = 0
	var/last_client = null

	New()
		..()
		if (world.load_intra_round_value("solarium_complete") == 1 || derelict_mode || global.master_mode == "disaster")
			src.staple_jobs = list(new /datum/job/command/captain/derelict {limit = 1;name = "NT-SO Commander";} (),
			new /datum/job/command/head_of_security/derelict {limit = 1; name = "NT-SO Special Operative";} (),
			new /datum/job/command/chief_engineer/derelict {limit = 1; name = "Salvage Chief";} (),
			new /datum/job/security/security_officer/derelict {limit = 6; name = "NT-SO Officer";} (),
			new /datum/job/medical/medical_doctor/derelict {limit = 8; name = "Salvage Medic";} (),
			new /datum/job/engineering/engineer/derelict {limit = 10; name = "Salvage Engineer";} (),
			new /datum/job/civilian/staff_assistant (),
			new /datum/job/civilian/chef (),
			new /datum/job/civilian/bartender (),
			new /datum/job/civilian/chaplain ())

		else
			for (var/A in concrete_typesof(/datum/job/command)) src.staple_jobs += new A(src)
			for (var/A in concrete_typesof(/datum/job/security)) src.staple_jobs += new A(src)
			for (var/A in concrete_typesof(/datum/job/research)) src.staple_jobs += new A(src)
			for (var/A in concrete_typesof(/datum/job/medical)) src.staple_jobs += new A(src)
			for (var/A in concrete_typesof(/datum/job/engineering)) src.staple_jobs += new A(src)
			for (var/A in concrete_typesof(/datum/job/civilian)) src.staple_jobs += new A(src)
			for (var/A in concrete_typesof(/datum/job/special)) src.special_jobs += new A(src)
		job_creator = new /datum/job/created(src)
		//Add special daily variety job
		for (var/datum/job/daily/variety_job_path as anything in concrete_typesof(/datum/job/daily))
			if (initial(variety_job_path.day) == time2text(world.realtime,"Day"))
				src.staple_jobs += new variety_job_path(src)
			else
				src.hidden_jobs += new variety_job_path(src)

		for (var/datum/job/J in src.staple_jobs)
			// Cull any of those nasty null jobs from the category heads
			if (!J.name)
				src.staple_jobs -= J
		for (var/datum/job/J in src.special_jobs)
			if (!J.name)
				src.special_jobs -= J

		#ifdef UPSCALED_MAP
		for (var/datum/job/J in staple_jobs)
			if (J.limit > 0)
				J.limit *= 4
				J.upper_limit = J.limit
		#endif

	proc/check_user_changed()//Since this is a 'public' window that everyone can get to, make sure we keep the user contained to their own savefile
		if (last_client != usr.client)
			src.last_client = usr.client
			src.loaded_save = 0
			return 1
		return 0

	/// Returns TRUE if a player is eligible to play a given job
	proc/check_job_eligibility(mob/new_player/player, datum/job/job, valid_categories = STAPLE_JOBS | SPECIAL_JOBS | HIDDEN_JOBS)
		if(!player?.client)
			logTheThing(LOG_DEBUG, null, "<b>Jobs:</b> check job eligibility error - [player.last_ckey] has no client.")
			return
		if (!job)
			logTheThing(LOG_DEBUG, null, "<b>Jobs:</b> check job eligibility error - [player.ckey] requested check with invalid job datum arg.")
			return
		if ((job.limit >= 0) && (job.assigned >= job.limit))
			return
		// prevent someone from trying to sneak their way into a job they shouldn't be able to choose
		var/list/valid_jobs = list()
		if (HAS_FLAG(valid_categories, STAPLE_JOBS))
			valid_jobs.Add(src.staple_jobs)
		if (HAS_FLAG(valid_categories, SPECIAL_JOBS))
			valid_jobs.Add(src.special_jobs)
		if (HAS_FLAG(valid_categories, HIDDEN_JOBS))
			valid_jobs.Add(src.hidden_jobs)
		if (!valid_jobs.Find(job))
			logTheThing(LOG_DEBUG, null, "<b>Jobs:</b> check job eligibility error - [player.ckey] requested [job.name], but it was not found in list of valid jobs! (Flag value: [valid_categories]).")
			return
		// antag job exemptions
		if(player.mind?.is_antagonist())
			if (!job.can_be_antag(player.mind.special_role))
				return
		// job ban check
		if (!job.no_jobban_from_this_job && jobban_isbanned(player, job.name))
			logTheThing(LOG_DEBUG, null, "<b>Jobs:</b> check job eligibility error - [player.ckey] requested [job.name], but is job banned.")
			return
		// trusted only job check
		if (job.trusted_only && (!(player.ckey in mentors) && !NT.Find(ckey(player.mind.key))))
			logTheThing(LOG_DEBUG, null, "<b>Jobs:</b> check job eligibility error - [player.ckey] requested [job.name], a mentor only job.")
			return
		// meant to prevent you from setting sec as fav and captain (or similar) as your only medium to ensure only captain traitor rounds
		if (!job.allow_antag_fallthrough && player.antag_fallthrough)
			return
		// all of the 'serious' check have passed, ignore the rest of the requirements for random job rounds.
		if (global.totally_random_jobs)
			return TRUE

		if (!job.has_rounds_needed(player.client.player))
			return
		if (job.needs_college && !player.has_medal("Unlike the director, I went to college"))
			return
		if (job.requires_whitelist && !NT.Find(ckey(player.mind.key)))
			return
		if (job.requires_supervisor_job && countJob(job.requires_supervisor_job) <= 0)
			return
		return TRUE

	/// attempts to assign a player to a job from a list of either job datums or job strings
	proc/try_assign_job_from_list(mob/player, list/jobs)
		PRIVATE_PROC(TRUE)
		RETURN_TYPE(/datum/job)
		shuffle_list(jobs)
		for(var/job_entry in jobs)
			var/datum/job/job
			if (istext(job_entry))
				job = find_job_in_controller_by_string(job_entry)
			else
				job = job_entry
			if (job && check_job_eligibility(player, job, STAPLE_JOBS))
				player.mind.assigned_role = job.name
				job.assigned++
				return job
		return

	/// Assigns a player a job based on their preferences and job availability
	proc/allocate_player_to_job_by_preference(mob/new_player/player)
		RETURN_TYPE(/datum/job)
		if (!player.client)
			return
		var/datum/preferences/player_preferences = player.client.preferences
		if (!player_preferences)
			return

		if (totally_random_jobs)
			var/datum/job/job = try_assign_job_from_list(player, staple_jobs)
			if (!job) // what are you like, banned from everything...?
				job = find_job_in_controller_by_path(/datum/job/civilian/staff_assistant) // very random
				player.mind.assigned_role = job.name
				job.assigned++
			logTheThing(LOG_DEBUG, player, "<b>Jobs:</b> Assigned job: [job.name] (random job)")
			return job

		if (player_preferences.job_favorite)
			var/datum/job/job = find_job_in_controller_by_string(player_preferences.job_favorite)
			if (job)
				// antag fall through flag set check
				if (!job.can_be_antag(player.mind.special_role))
					player.antag_fallthrough = TRUE
				// try to assign fav job
				if (check_job_eligibility(player, job, STAPLE_JOBS))
					player.mind.assigned_role = job.name
					job.assigned++
					logTheThing(LOG_DEBUG, player, "<b>Jobs:</b> Assigned job: [job.name] (favorite job)")
					return job

		// If favorite job isn't available, check medium priority jobs
		if (length(player_preferences.jobs_med_priority))
			var/datum/job/job =	try_assign_job_from_list(player, player_preferences.jobs_med_priority)
			if (job)
				logTheThing(LOG_DEBUG, player, "<b>Jobs:</b> Assigned job: [job.name] (medium priority job)")
				return job

		// If no medium priority jobs are available or suitable, check low priority jobs
		if (length(player_preferences.jobs_low_priority))
			var/datum/job/job =	try_assign_job_from_list(player, player_preferences.jobs_low_priority)
			if (job)
				logTheThing(LOG_DEBUG, player, "<b>Jobs:</b> Assigned job: [job.name] (low priority job)")
				return job

		// look, we tried ok? Just be happy you work here at all.
		var/list/low_priority_jobs = list()
		for(var/datum/job/job in job_controls.staple_jobs)
			if (job.low_priority_job)
				low_priority_jobs += job
		if (length(low_priority_jobs))
			var/datum/job/job = pick(low_priority_jobs)
			player.mind.assigned_role = job.name
			job.assigned++
			logTheThing(LOG_DEBUG, player, "<b>Jobs:</b> Assigned job: [job.name] (fallback job).")
			return job

		// staffie fallback
		var/datum/job/fallback_job = find_job_in_controller_by_path(/datum/job/civilian/staff_assistant)
		if(!fallback_job)
			CRASH("Unable to locate the default fallback job in job controller. [player] has not been assigned a job!")
		player.mind.assigned_role = fallback_job.name
		fallback_job.assigned++
		logTheThing(LOG_DEBUG, player, "<b>Jobs:</b> Assigned job: [fallback_job.name] (emergency fallback job)")
		return fallback_job

	proc/job_creator()
		src.convert_to_cloudsave(usr.client)
		src.check_user_changed()
		var/list/dat = list("<html><body><title>Job Creation</title>")
		dat += "<b><u>Job Creator</u></b><HR>"

		dat += "<A href='?src=\ref[src];EditName=1'>Job Name:</A> [src.job_creator.name]<br>"
		dat += "<A href='?src=\ref[src];EditWages=1'>Wages Per Payday:</A> [src.job_creator.wages]<br>"
		dat += "<A href='?src=\ref[src];EditLimit=1'>Job Limit:</A> [src.job_creator.limit]<br>"
		dat += "<A href='?src=\ref[src];ChangeName=1'>Can Change Name on Spawn:</A> [src.job_creator.change_name_on_spawn ? "Yes":"No"]<br>"
		dat += "<A href='?src=\ref[src];SetSpawnLoc=1'>Spawn Location:</A> [src.job_creator.special_spawn_location]<br>"
		dat += "<A href='?src=\ref[src];SpawnId=1'>Spawns with ID:</A> [src.job_creator.spawn_id ? "Yes" : "No"]<br>"
		dat += "<A href='?src=\ref[src];EditObjective=1'>Custom Objective:</A> [src.job_creator.objective][src.job_creator.objective ? (" (Crew Objective)") : ""]<br>"
		dat += "<A href='?src=\ref[src];ToggleAnnounce=1'>Head of Staff-style Announcement:</A> [src.job_creator.announce_on_join?"Yes":"No"]<br>"
		dat += "<A href='?src=\ref[src];ToggleRadioAnnounce=1'>Radio Announcement:</A> [src.job_creator.radio_announcement?"Yes":"No"]<br>"
		dat += "<A href='?src=\ref[src];ToggleManifest=1'>Add To Manifest:</A> [src.job_creator.add_to_manifest?"Yes":"No"]<br>"
		dat += "<A href='?src=\ref[src];EditMob=1'>Mob Type:</A> [src.job_creator.mob_type]<br>"
		dat += "<BR>"
		if (ispath(src.job_creator.mob_type, /mob/living/carbon/human))
			dat += "<A href='?src=\ref[src];EditMutantrace=1'>Mutantrace:</A> [src.job_creator.starting_mutantrace]<br>"
			dat += "<A href='?src=\ref[src];EditHeadgear=1'>Starting Headgear:</A> [english_list(src.job_creator.slot_head)]<br>"
			dat += "<A href='?src=\ref[src];EditMask=1'>Starting Mask:</A>  [english_list(src.job_creator.slot_mask)]<br>"
			dat += "<A href='?src=\ref[src];EditHeadset=1'>Starting Headset:</A> [english_list(src.job_creator.slot_ears)]<br>"
			dat += "<A href='?src=\ref[src];EditGlasses=1'>Starting Glasses:</A> [english_list(src.job_creator.slot_eyes)]<br>"
			dat += "<A href='?src=\ref[src];EditOvercoat=1'>Starting Overcoat:</A> [english_list(src.job_creator.slot_suit)]<br>"
			dat += "<A href='?src=\ref[src];EditJumpsuit=1'>Starting Jumpsuit:</A> [english_list(src.job_creator.slot_jump)]<br>"
			dat += "<A href='?src=\ref[src];EditIDCard=1'>Starting ID Card:</A> [src.job_creator.slot_card]<br>"
			dat += "<A href='?src=\ref[src];EditGloves=1'>Starting Gloves:</A> [english_list(src.job_creator.slot_glov)]<br>"
			dat += "<A href='?src=\ref[src];EditShoes=1'>Starting Shoes:</A> [english_list(src.job_creator.slot_foot)]<br>"
			dat += "<A href='?src=\ref[src];EditBack=1'>Starting Back Item:</A> [english_list(src.job_creator.slot_back)]<br>"
			dat += "<A href='?src=\ref[src];EditBelt=1'>Starting Belt Item:</A> [english_list(src.job_creator.slot_belt)]<br>"
			dat += "<A href='?src=\ref[src];EditPock1=1'>Starting 1st Pocket Item:</A> [english_list(src.job_creator.slot_poc1)]<br>"
			dat += "<A href='?src=\ref[src];EditPock2=1'>Starting 2nd Pocket Item:</A> [english_list(src.job_creator.slot_poc2)]<br>"
			dat += "<A href='?src=\ref[src];EditLhand=1'>Starting Left Hand Item:</A> [english_list(src.job_creator.slot_lhan)]<br>"
			dat += "<A href='?src=\ref[src];EditRhand=1'>Starting Right Hand Item:</A> [english_list(src.job_creator.slot_rhan)]<br>"
			dat += "<A href='?src=\ref[src];EditImpl=1'>Starting Implants:</A> [english_list(src.job_creator.receives_implants)]<br>"
			for(var/i in 1 to 7)
				dat += "<A href='?src=\ref[src];EditBpItem=[i]'>Starting Backpack Item [i]:</A> [length(src.job_creator.items_in_backpack) >= i ? src.job_creator.items_in_backpack[i] : null]<br>"
			for(var/i in 1 to 7)
				dat += "<A href='?src=\ref[src];EditBeltItem=[i]'>Starting Belt Item [i]:</A> [length(src.job_creator.items_in_belt) >= i ? src.job_creator.items_in_belt[i] : null]<br>"
			dat += "<A href='?src=\ref[src];GetAccess=1'>Set Access Permissions </A>"
			if (length(src.job_creator.access) > 1)
				dat += " "
				dat += "<A href='?src=\ref[src];AddAccess=1'>(Add More):</A>"
			dat += ":<BR>"
			for(var/X in src.job_creator.access)
				dat += "[X], "
			dat += "<BR>"
			dat += "<A href='?src=\ref[src];BioEffects=1'>Bio Effects:</A> [src.job_creator.bio_effects]<br>"
		else if (ispath(src.job_creator.mob_type, /mob/living/critter))
			dat += "<A href='?src=\ref[src];GetAccess=1'>Set Implanted Access Permissions</A>"
			if (length(src.job_creator.access) > 1)
				dat += " "
				dat += "<A href='?src=\ref[src];AddAccess=1'>(Add More):</A>"
				dat += ":<BR>"
				for(var/X in src.job_creator.access)
					dat += "[X], "
				dat += "<BR>"

		dat += "<BR>"
		dat += "<A href='?src=\ref[src];CreateJob=1;Hidden=1'><b>Create Hidden Job (for admin respawning)</b></A><BR><BR>"
		dat += "<A href='?src=\ref[src];CreateJob=1'><b>Create Job</b></A>"
		dat += "<BR><BR>"

		if (loaded_save)
			dat += "<b>Saved Jobs:</b>"
			dat += "<br><small>"
			var/list/job_names = src.savefile_get_job_names(usr.client)
			for (var/i in 1 to length(job_names))
				if(job_names[i])
					dat += " <a href='?src=\ref[src];Load=[i]'>[job_names[i]]</a>"
				else
					dat += " Empty slot ([i])"
				dat += "&nbsp;"
				dat += " <a href='?src=\ref[src];Save=[i]'>(Save here)</a>"
				dat += "<br>"
			dat += "</small><br>"
		else
			dat += "<A href='?src=\ref[src];SaveLoad=1'>Save/Load</A>"

		dat += "<br><A href='?src=\ref[src];Import=1'>Import</A> / <A href='?src=\ref[src];Export=1'>Export</A>"
		dat += "</body></html>"

		usr.Browse(dat.Join(),"window=jobcreator;size=500x650")

	Topic(href, href_list[])
		USR_ADMIN_ONLY
		// JOB CREATOR COMMANDS

		// I tweaked this section a little so you can actual search for certain items.
		// Scrolling through a list of ~2600 items wasn't exactly great (Convair880).

		if(href_list["EditName"])
			var/picker = input("What is this job's name?","Job Creator")
			src.job_creator.name = picker
			src.job_creator()

		if(href_list["EditWages"])
			var/picker = input("How much does this job get paid each payday?","Job Creator") as num
			src.job_creator.wages = picker
			src.job_creator()

		if(href_list["EditLimit"])
			var/picker = input("How many of this job can there be on the station?","Job Creator") as num
			src.job_creator.limit = picker
			src.job_creator()

		if(href_list["EditMob"])
			var/list/L = list()
			var/search_for = input(usr, "Search for mob (or leave blank for complete list)", "Select mob") as null|text
			if (search_for)
				for (var/R in typesof(/mob))
					if (findtext("[R]", search_for)) L += R
			else
				L = typesof(/mob)

			var/picker = null
			if (length(L) == 1)
				picker = L[1]
			else if (length(L) > 1)
				picker = input(usr,"Select mob:","Job Creator",null) as null|anything in L
			else
				usr.show_text("No mob matching that name", "red")
				return

			src.job_creator.mob_type = picker
			src.job_creator()

		if(href_list["EditMutantrace"])
			switch(alert("Clear or reselect mutantrace?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.starting_mutantrace = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for mutantrace (or leave blank for complete list)", "Select mutantrace") as null|text
					if (search_for)
						for (var/R in typesof(/datum/mutantrace))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/datum/mutantrace)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select mutantrace:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No mutantrace matching that name", "red")
						return

					src.job_creator.starting_mutantrace = picker

			src.job_creator()


		if(href_list["EditHeadgear"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_head = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for headgear (or leave blank for complete list)", "Select headgear") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/clothing/head))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/clothing/head)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select headgear:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No headgear matching that name", "red")
						return

					src.job_creator.slot_head = list(picker)

			src.job_creator()

		if(href_list["EditMask"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_mask = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for mask (or leave blank for complete list)", "Select mask") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/clothing/mask))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/clothing/mask)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select mask:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No mask matching that name", "red")
						return

					src.job_creator.slot_mask = list(picker)

			src.job_creator()

		if(href_list["EditHeadset"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_ears = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for headset (or leave blank for complete list)", "Select headset") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/device/radio/headset))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/device/radio/headset)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select headset:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No headset matching that name", "red")
						return

					src.job_creator.slot_ears = list(picker)

			src.job_creator()

		if(href_list["EditGlasses"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_eyes = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for glasses (or leave blank for complete list)", "Select glasses") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/clothing/glasses))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/clothing/glasses)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select glasses:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No glasses matching that name", "red")
						return

					src.job_creator.slot_eyes = list(picker)

			src.job_creator()

		if(href_list["EditOvercoat"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_suit = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for exosuit (or leave blank for complete list)", "Select exosuit") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/clothing/suit))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/clothing/suit)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select exosuit:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No exosuit matching that name", "red")
						return

					src.job_creator.slot_suit = list(picker)

			src.job_creator()

		if(href_list["EditJumpsuit"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_jump = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for jumpsuit (or leave blank for complete list)", "Select jumpsuit") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/clothing/under))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/clothing/under)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select jumpsuit:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No jumpsuit matching that name", "red")
						return

					src.job_creator.slot_jump = list(picker)

			src.job_creator()

		if(href_list["EditIDCard"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_card = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for ID card (or leave blank for complete list)", "Select ID card") as null|text
					if (search_for)
						for (var/R in (typesof(/obj/item/card) - list(/obj/item/card/emag, /obj/item/card/emag/fake, /obj/item/card/id/gauntlet)))
							if (findtext("[R]", search_for)) L += R
					else
						// These cards can't be worn on the ID slot and they're not compatible with the
						// job controller because they don't support access lists (Convair880).
						L = (typesof(/obj/item/card) - list(/obj/item/card/emag, /obj/item/card/emag/fake, /obj/item/card/id/gauntlet))

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select ID card:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No ID card matching that name", "red")
						return

					src.job_creator.slot_card = picker

			src.job_creator()

		if(href_list["EditGloves"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_glov = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for gloves (or leave blank for complete list)", "Select gloves") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/clothing/gloves))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/clothing/gloves)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select gloves:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No gloves matching that name", "red")
						return

					src.job_creator.slot_glov = list(picker)

			src.job_creator()

		if(href_list["EditShoes"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_foot = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for shoes (or leave blank for complete list)", "Select shoes") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/clothing/shoes))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/clothing/shoes)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select shoes:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No shoes matching that name", "red")
						return

					src.job_creator.slot_foot = list(picker)

			src.job_creator()

		if(href_list["EditBack"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_back = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for backslot item (or leave blank for complete list)", "Select backslot item") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select backslot item:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No backslot item matching that name", "red")
						return

					// I wish there would be a better way to filter this stuff, typesof() just doesn't cut it.
					// I suppose this is still slightly more elegant than the fixed (and outdated) list that
					// used to be here. Anway, the job controller will not spawn unsuitable items (Convair880).
					if (picker)
						var/obj/item/check = new picker
						if (!(check.c_flags & ONBACK))
							usr.show_text("This item cannot be worn on the back slot.", "red")
							qdel(check)
							return
						qdel(check)

					src.job_creator.slot_back = list(picker)

			src.job_creator()

		if(href_list["EditBelt"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_belt = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for beltslot item (or leave blank for complete list)", "Select beltslot item") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select beltslot item:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No beltslot item matching that name", "red")
						return

					// Ditto (Convair880).
					if (picker)
						var/obj/item/check = new picker
						if (!(check.c_flags & ONBELT))
							usr.show_text("This item cannot be worn on the belt slot.", "red")
							qdel(check)
							return
						qdel(check)

					src.job_creator.slot_belt = list(picker)

			src.job_creator()

		if(href_list["EditPock1"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_poc1 = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for item (or leave blank for complete list)", "Select pocket #1") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select item:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No item matching that name", "red")
						return

					// Ditto (Convair880).
					if (picker)
						var/obj/item/check = new picker
						if (check.w_class > W_CLASS_SMALL)
							usr.show_text("This item is too large to fit in a jumpsuit pocket.", "red")
							qdel(check)
							return
						qdel(check)

					src.job_creator.slot_poc1 = list(picker)

			src.job_creator()

		if(href_list["EditPock2"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_poc2 = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for item (or leave blank for complete list)", "Select pocket #2") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select item:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No item matching that name", "red")
						return

					// Ditto (Convair880).
					if (picker)
						var/obj/item/check = new picker
						if (check.w_class > W_CLASS_SMALL)
							usr.show_text("This item is too large to fit in a jumpsuit pocket.", "red")
							qdel(check)
							return
						qdel(check)

					src.job_creator.slot_poc2 = list(picker)

			src.job_creator()

		if(href_list["EditLhand"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_lhan = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for item (or leave blank for complete list)", "Select left hand") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select item:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No item matching that name", "red")
						return

					src.job_creator.slot_lhan = list(picker)

			src.job_creator()

		if(href_list["EditRhand"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.slot_rhan = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for item (or leave blank for complete list)", "Select right hand") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select item:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No item matching that name", "red")
						return

					src.job_creator.slot_rhan = picker

			src.job_creator()

		if(href_list["EditImpl"])
			switch(alert("Clear or reselect implant?","Job Creator","Clear","Add"))
				if("Clear")
					src.job_creator.receives_implants = null

				if("Add")
					var/list/L = list()
					var/search_for = input(usr, "Search for implants (or leave blank for complete list)", "Select implant") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/implant))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/implant)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select implant:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No implant matching that name", "red")
						return
					if(isnull(src.job_creator.receives_implants))
						src.job_creator.receives_implants = list()
					src.job_creator.receives_implants += picker


			src.job_creator()


		if(href_list["EditBpItem"])
			var/slot_num = text2num(href_list["EditBpItem"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					if(length(src.job_creator.items_in_backpack) >= slot_num)
						src.job_creator.items_in_backpack[slot_num] = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for item (or leave blank for complete list)", "Select backpack item [slot_num]") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select item:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No item matching that name", "red")
						return

					while(length(src.job_creator.items_in_backpack) < slot_num)
						src.job_creator.items_in_backpack += null
					src.job_creator.items_in_backpack[slot_num] = picker

			src.job_creator()


		if(href_list["EditBeltItem"])
			var/slot_num = text2num(href_list["EditBeltItem"])
			switch(alert("Clear or reselect slotted item?","Job Creator","Clear","Reselect"))
				if("Clear")
					if(length(src.job_creator.items_in_belt) >= slot_num)
						src.job_creator.items_in_belt[slot_num] = null

				if("Reselect")
					var/list/L = list()
					var/search_for = input(usr, "Search for item (or leave blank for complete list)", "Select belt item [slot_num]") as null|text
					if (search_for)
						for (var/R in typesof(/obj/item/))
							if (findtext("[R]", search_for)) L += R
					else
						L = typesof(/obj/item/)

					var/picker = null
					if (length(L) == 1)
						picker = L[1]
					else if (length(L) > 1)
						picker = input(usr,"Select item:","Job Creator",null) as null|anything in L
					else
						usr.show_text("No item matching that name", "red")
						return

					while(length(src.job_creator.items_in_belt) < slot_num)
						src.job_creator.items_in_belt += null
					src.job_creator.items_in_belt[slot_num] = picker

			src.job_creator()

		if(href_list["GetAccess"])
			var/picker = input("Make this job's access comparable to which job?","Job Creator") in list("Captain","Head of Security",
			"Head of Personnel","Chief Engineer","Research Director","Security Officer","Detective","Geneticist","Pathologist","Roboticist","Scientist",
			"Medical Doctor","Quartermaster","Miner","Engineer","Chef","Bartender","Botanist","Janitor","Chaplain","Staff Assistant","No Access")
			src.job_creator.access = get_access(picker)
			src.job_creator()

		if(href_list["AddAccess"])
			var/picker = input("Make this job's access comparable to which job?","Job Creator") in list("Captain","Head of Security",
			"Head of Personnel","Chief Engineer","Research Director","Security Officer","Detective","Geneticist","Pathologist","Roboticist","Scientist",
			"Medical Doctor","Quartermaster","Miner","Engineer","Chef","Bartender","Botanist","Janitor","Chaplain","Staff Assistant","No Access")
			src.job_creator.access |= get_access(picker)
			src.job_creator()

		if(href_list["BioEffects"])
			switch(alert("Clear or reselect bioeffects?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.bio_effects = null
				if("Reselect")
					var/pick = input("Which effect(s)? Enter IDs - seperate using semicolons.","["Give"] Bioeffects") as null|text
					if (!pick)
						src.job_creator.bio_effects = null
					else
						src.job_creator.bio_effects = pick
			src.job_creator()

		if(href_list["EditObjective"])
			switch(alert("Clear or redefine objective?","Job Creator","Clear","Redefine"))
				if("Clear")
					src.job_creator.objective = null
				if("Redefine")
					var/input = input("Enter a custom objective.","Enter Objective") as null|text
					src.job_creator.objective = input
			src.job_creator()

		if(href_list["ToggleAnnounce"])
			src.job_creator.announce_on_join = !src.job_creator.announce_on_join
			src.job_creator()

		if(href_list["ToggleRadioAnnounce"])
			src.job_creator.radio_announcement = !src.job_creator.radio_announcement
			src.job_creator()

		if(href_list["ToggleManifest"])
			src.job_creator.add_to_manifest = !src.job_creator.add_to_manifest
			src.job_creator()

		if(href_list["SpawnId"])
			src.job_creator.spawn_id = !src.job_creator.spawn_id
			src.job_creator()

		if(href_list["ChangeName"])
			src.job_creator.change_name_on_spawn = !src.job_creator.change_name_on_spawn
			src.job_creator()

		if(href_list["SetSpawnLoc"])
			switch(alert("Clear or reselect spawn location?","Job Creator","Clear","Reselect"))
				if("Clear")
					src.job_creator.special_spawn_location = null
				if("Reselect")
					alert("Please move to the target location and then press OK.")
					var/atom/trg = get_turf(usr)
					if(trg)
						src.job_creator.special_spawn_location = trg
			src.job_creator()

		if(href_list["CreateJob"])
			if (!length(src.job_creator.name))
				alert("You must give your job a name.")
				return
			var/datum/job/match_check
			try
				match_check = find_job_in_controller_by_string(src.job_creator.name)
			catch
				;
			if (match_check == src.job_creator)
				boutput(usr, SPAN_ALERT("<b>This job already exists. All is well.</b>"))
				return
			if (match_check)
				boutput(usr, SPAN_ALERT("<b>A job with this name already exists. It cannot be created.</b>"))
				return
			else
				var/hidden = FALSE
				if(href_list["Hidden"])
					hidden = TRUE

				src.create_job(hidden)

			src.job_creator()

		if(href_list["Save"])
			if (!src.check_user_changed())
				src.cloudsave_save(usr.client, (isnum(text2num(href_list["Save"])) ? text2num(href_list["Save"]) : 1))
				boutput(usr, SPAN_NOTICE("<b>Job saved to Slot [text2num(href_list["Save"])].</b>"))
			src.job_creator()

		if(href_list["Load"])
			if (!src.check_user_changed())
				if (!src.cloudsave_load(usr.client, (isnum(text2num(href_list["Load"])) ? text2num(href_list["Load"]) : 1)))
					alert(usr, "Loading failed.")
				else
					boutput(usr, SPAN_NOTICE("<b>Job loaded from Slot [text2num(href_list["Load"])].</b>"))
			src.job_creator()

		if(href_list["SaveLoad"])
			src.loaded_save = 1
			src.job_creator()

		if(href_list["Import"])
			if(src.savefile_import(usr.client))
				boutput(usr, SPAN_NOTICE("<b>Job imported from file.</b>"))
			src.job_creator()

		if(href_list["Export"])
			src.savefile_export(usr.client)
			boutput(usr, SPAN_NOTICE("<b>Job exporting.</b>"))
			src.job_creator()

///create job datum from job-creator job datum. todo just add a clone method to jobs?
/datum/job_controller/proc/create_job(hidden = FALSE)
	var/datum/job/created/JOB = new /datum/job/created(src)
	if(hidden)
		src.hidden_jobs += JOB
	else
		src.special_jobs += JOB

	JOB.name = src.job_creator.name
	JOB.wages = src.job_creator.wages
	JOB.limit = src.job_creator.limit
	JOB.mob_type = src.job_creator.mob_type
	JOB.slot_head = src.job_creator.slot_head
	JOB.slot_mask = src.job_creator.slot_mask
	JOB.slot_ears = src.job_creator.slot_ears
	JOB.slot_eyes = src.job_creator.slot_eyes
	JOB.slot_glov = src.job_creator.slot_glov
	JOB.slot_foot = src.job_creator.slot_foot
	JOB.slot_card = src.job_creator.slot_card
	JOB.slot_jump = src.job_creator.slot_jump
	JOB.slot_suit = src.job_creator.slot_suit
	JOB.slot_back = src.job_creator.slot_back
	JOB.slot_belt = src.job_creator.slot_belt
	JOB.slot_poc1 = src.job_creator.slot_poc1
	JOB.slot_poc2 = src.job_creator.slot_poc2
	JOB.slot_lhan = src.job_creator.slot_lhan
	JOB.slot_rhan = src.job_creator.slot_rhan
	JOB.access = JOB.access | src.job_creator.access
	JOB.change_name_on_spawn = src.job_creator.change_name_on_spawn
	JOB.special_spawn_location = src.job_creator.special_spawn_location
	JOB.bio_effects = src.job_creator.bio_effects
	JOB.objective = src.job_creator.objective
	JOB.announce_on_join = src.job_creator.announce_on_join
	JOB.radio_announcement = src.job_creator.radio_announcement
	JOB.add_to_manifest = src.job_creator.add_to_manifest
	JOB.receives_implants = src.job_creator.receives_implants
	JOB.items_in_backpack = src.job_creator.items_in_backpack
	JOB.items_in_belt = src.job_creator.items_in_belt
	JOB.spawn_id = src.job_creator.spawn_id
	JOB.starting_mutantrace = src.job_creator.starting_mutantrace
	message_admins("Admin [key_name(usr)] created special job [JOB.name]")
	logTheThing(LOG_ADMIN, usr, "created special job [JOB.name]")
	logTheThing(LOG_DIARY, usr, "created special job [JOB.name]", "admin")
	return JOB

///Soft supresses logging on failing to find a job
/proc/find_job_in_controller_by_string(var/string, var/staple_only = 0, var/soft = FALSE, var/case_sensitive = TRUE)
	RETURN_TYPE(/datum/job)
	if (!string || !istext(string))
		logTheThing(LOG_DEBUG, null, "<b>Job Controller:</b> Attempt to find job with bad string in controller detected")
		return null
	var/list/excluded_strings = list("Special Respawn","Custom Names","Everything Except Assistant",
	"Engineering Department","Security Department","Heads of Staff", "Pod_Wars", "Syndicate", "Construction Worker", "MODE", "Ghostdrone", "Animal")
	#ifndef MAP_OVERRIDE_MANTA
	excluded_strings += "Communications Officer"
	#endif
	if (string in excluded_strings)
		return null
	var/list/results = list()
	for (var/datum/job/J in job_controls.staple_jobs)
		if (J.match_to_string(string, case_sensitive))
			results += J
	if (!staple_only)
		for (var/datum/job/J in job_controls.special_jobs)
			if (J.match_to_string(string, case_sensitive))
				results += J
		for (var/datum/job/J in job_controls.hidden_jobs)
			if (J.match_to_string(string, case_sensitive))
				results += J
	if(length(results) == 1)
		return results[1]
	else if(length(results) > 1)
		stack_trace("Multiple jobs share the name '[string]'!")
		return results[1]
	if (!soft)
		logTheThing(LOG_DEBUG, null, "No job found with name '[string]'!")

/proc/find_job_in_controller_by_path(var/path)
	if (!path || !ispath(path) || !istype(path,/datum/job/))
		logTheThing(LOG_DEBUG, null, "<b>Job Controller:</b> Attempt to find job with bad path in controller detected")
		return null
	for (var/datum/job/J in job_controls.staple_jobs)
		if (J.type == path)
			return J
	for (var/datum/job/J in job_controls.special_jobs)
		if (J.type == path)
			return J
	logTheThing(LOG_DEBUG, null, "<b>Job Controller:</b> Attempt to find job by path \"[path]\" in controller failed")
	return null

/client/proc/cmd_job_controls()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Job Controls"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (isnull(src.holder.job_manager))
		src.holder.job_manager = new

	src.holder.job_manager.ui_interact(src.mob)
