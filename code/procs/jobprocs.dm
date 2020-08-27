/proc/SetupOccupationsList()
	set background = 1

	var/list/new_occupations = list()

	for(var/occupation in occupations)
		if (!(new_occupations.Find(occupation)))
			new_occupations[occupation] = 1
		else
			new_occupations[occupation] += 1
	occupations = new_occupations
	return

/proc/FindOccupationCandidates(list/unassigned, job, level)
	set background = 1

	var/list/candidates = list()

	var/datum/job/J = find_job_in_controller_by_string(job)
	if(!J)
		CRASH("FindOccupationCandidates called with invalid job name: [job] at level: [level]")
	for (var/mob/new_player/player in unassigned)
		if(!player.client || !player.client.preferences) //Well shit.
			continue
		var/datum/preferences/P  = player.client.preferences
		if(checktraitor(player))
			if ((ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution)) && J.cant_spawn_as_rev)
				// Fixed AI, security etc spawning as rev heads. The special job picker doesn't care about that var yet,
				// but I'm not gonna waste too much time tending to a basically abandoned game mode (Convair880).
				continue
			else if((ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/gang)) && (job != "Staff Assistant"))
				continue

		if (!J.allow_traitors && player.mind.special_role || !J.allow_spy_theft && player.mind.special_role == "spy_thief")
			continue
		if (J.needs_college && !player.has_medal("Unlike the director, I went to college"))
			continue
		if (J.requires_whitelist && !NT.Find(ckey(player.mind.key)))
			continue
		if (jobban_isbanned(player, job) || P.jobs_unwanted.Find(J.name) )
			continue
		if (level == 1 && P.job_favorite == J.name)
			candidates += player
		else if (level == 2 && P.jobs_med_priority.Find(J.name))
			candidates += player
		else if (level == 3 && P.jobs_low_priority.Find(J.name))
			candidates += player

	return candidates

/proc/DivideOccupations()
	set background = 1

	var/list/unassigned = list()

	for (var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue
		if (player.ready && !player.mind.assigned_role)
			unassigned += player

	if (unassigned.len == 0)
		return 0

	// If the mode is construction, ignore all this shit and sort everyone into the construction worker job.
	if (master_mode == "construction")
		for (var/mob/new_player/player in unassigned)
			player.mind.assigned_role = "Construction Worker"
		return

	var/list/pick1 = list()
	var/list/pick2 = list()
	var/list/pick3 = list()

	// Stick all the available jobs into its own list so we can wiggle the fuck outta it
	var/list/available_job_roles = list()
	// Apart from ones in THIS list, which are jobs we want to assign before any others
	var/list/high_priority_jobs = list()
	// This list is for jobs like staff assistant which have no limits, or other special-case
	// shit to hand out to people who didn't get one of the main limited slot jobs
	var/list/low_priority_jobs = list()

	var/list/medical_staff = list()
	var/list/engineering_staff = list()
	var/list/research_staff = list()


	for(var/datum/job/JOB in job_controls.staple_jobs)
		// If it's hi-pri, add it to that list. Simple enough
		if (JOB.high_priority_job)
			high_priority_jobs.Add(JOB)
		// If we've got a job with the low priority var set or no limit, chuck it in the
		// low-pri list and move onto the next job - if we don't do this, the first time
		// it hits a limitless job it'll get stuck on it and hand it out to everyone then
		// boot the game up resulting in ~WEIRD SHIT~
		else if (JOB.low_priority_job)
			low_priority_jobs += JOB.name
			continue
		// otherwise it's a normal role so it goes in that list instead
		else
			available_job_roles.Add(JOB)

	// Wiggle it like a pissy caterpillar
	shuffle_list(available_job_roles)
	// Wiggle the players too so that priority isn't determined by key alphabetization
	shuffle_list(unassigned)

	// First we deal with high-priority jobs like Captain or AI which generally will always
	// be present on the station - we want these assigned first just to be sure
	// Though we don't want to do this in sandbox mode where it won't matter anyway
	if(master_mode != "sandbox")
		for(var/datum/job/JOB in high_priority_jobs)
			if (unassigned.len == 0) break

			if (JOB.limit > 0 && JOB.assigned >= JOB.limit) continue

			// get all possible candidates for it
			pick1 = FindOccupationCandidates(unassigned,JOB.name,1)
			pick2 = FindOccupationCandidates(unassigned,JOB.name,2)
			pick3 = FindOccupationCandidates(unassigned,JOB.name,3)

			// now assign them - i'm not hardcoding limits on these because i don't think any
			// of us are quite stupid enough to edit the AI's limit to -1 preround and have a
			// horrible multicore PC station round.. (i HOPE anyway)
			for(var/mob/new_player/candidate in pick1)
				if (JOB.assigned >= JOB.limit || unassigned.len == 0) break
				logTheThing("debug", null, null, "<b>I Said No/Jobs:</b> [candidate] took [JOB.name] from High Priority Job Picker Lv1")
				candidate.mind.assigned_role = JOB.name
				logTheThing("debug", candidate, null, "assigned job: [candidate.mind.assigned_role]")
				unassigned -= candidate
				JOB.assigned++
			for(var/mob/new_player/candidate in pick2)
				if (JOB.assigned >= JOB.limit || unassigned.len == 0) break
				logTheThing("debug", null, null, "<b>I Said No/Jobs:</b> [candidate] took [JOB.name] from High Priority Job Picker Lv2")
				candidate.mind.assigned_role = JOB.name
				logTheThing("debug", candidate, null, "assigned job: [candidate.mind.assigned_role]")
				unassigned -= candidate
				JOB.assigned++
			for(var/mob/new_player/candidate in pick3)
				if (JOB.assigned >= JOB.limit || unassigned.len == 0) break
				logTheThing("debug", null, null, "<b>I Said No/Jobs:</b> [candidate] took [JOB.name] from High Priority Job Picker Lv3")
				candidate.mind.assigned_role = JOB.name
				logTheThing("debug", candidate, null, "assigned job: [candidate.mind.assigned_role]")
				unassigned -= candidate
				JOB.assigned++
	else
		// if we are in sandbox mode just roll the hi-pri jobs back into the regular list so
		// people can still get them if they chose them
		available_job_roles = available_job_roles | high_priority_jobs

	// Next we go through each player and see if we can get them into their favorite jobs
	// If we don't do this loop then the main loop below might get to a job they have in their
	// medium or low priority lists first and give them that one rather than their favorite
	for (var/mob/new_player/player in unassigned)
		// If they don't have a favorite, skip em
		if (derelict_mode) // stop freaking out at the weird jobs
			continue
		if (!player.client.preferences || player.client.preferences.job_favorite == null)
			continue
		// Now get the in-system job via the string
		var/datum/job/JOB = find_job_in_controller_by_string(player.client.preferences.job_favorite)
		// Do a few checks to make sure they're allowed to have this job
		if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution))
			if(checktraitor(player) && JOB.cant_spawn_as_rev)
				// Fixed AI, security etc spawning as rev heads. The special job picker doesn't care about that var yet,
				// but I'm not gonna waste too much time tending to a basically abandoned game mode (Convair880).
				continue
		if (!JOB || jobban_isbanned(player,JOB.name))
			continue
		if (JOB.needs_college && !player.has_medal("Unlike the director, I went to college"))
			continue
		if (JOB.requires_whitelist && !NT.Find(ckey(player.mind.key)))
			continue
		if (!JOB.allow_traitors && player.mind.special_role ||  !JOB.allow_spy_theft && player.mind.special_role == "spy_thief")
			continue
		// If there's an open job slot for it, give the player the job and remove them from
		// the list of unassigned players, hey presto everyone's happy (except clarks probly)
		if (JOB.limit < 0 || !(JOB.assigned >= JOB.limit))
			if (istype(JOB, /datum/job/engineering/engineer))
				engineering_staff += player
			else if (istype(JOB, /datum/job/research/scientist))
				research_staff += player
			else if (istype(JOB, /datum/job/research/medical_doctor))
				medical_staff += player

			logTheThing("debug", null, null, "<b>I Said No/Jobs:</b> [player] took [JOB.name] from favorite selector")
			player.mind.assigned_role = JOB.name
			logTheThing("debug", player, null, "assigned job: [player.mind.assigned_role]")
			unassigned -= player
			JOB.assigned++

	// Do this loop twice - once for med priority and once for low priority, because elsewise
	// it was causing weird shit to happen where having something in low priority would
	// sometimes cause you to get that instead of a higher prioritized job
	for(var/datum/job/JOB in available_job_roles)
		// If we've got everyone a job, then stop wasting cycles and get on with the show
		if (unassigned.len == 0) break
		// If there's no more slots for this job available, move onto the next one
		if (JOB.limit > 0 && JOB.assigned >= JOB.limit) continue
		// First, rebuild the lists of who wants to be this job
		pick2 = FindOccupationCandidates(unassigned,JOB.name,2)
		// Now loop through the candidates in order of priority, and elect them to the
		// job position if possible - if at any point the job is filled, break the loops
		for(var/mob/new_player/candidate in pick2)
			if (istype(JOB, /datum/job/engineering/engineer))
				engineering_staff += candidate
			else if (istype(JOB, /datum/job/research/scientist))
				research_staff += candidate
			else if (istype(JOB, /datum/job/research/medical_doctor))
				medical_staff += candidate

			if (JOB.assigned >= JOB.limit || unassigned.len == 0)
				break
			logTheThing("debug", null, null, "<b>I Said No/Jobs:</b> [candidate] took [JOB.name] from Level 2 Job Picker")
			candidate.mind.assigned_role = JOB.name
			logTheThing("debug", candidate, null, "assigned job: [candidate.mind.assigned_role]")
			unassigned -= candidate
			JOB.assigned++

	// And then again for low priority
	for(var/datum/job/JOB in available_job_roles)
		if (unassigned.len == 0)
			break

		if (JOB.limit == 0)
			continue

		if (JOB.limit > 0 && JOB.assigned >= JOB.limit)
			continue

		pick3 = FindOccupationCandidates(unassigned,JOB.name,3)
		for(var/mob/new_player/candidate in pick3)
			if (istype(JOB, /datum/job/engineering/engineer))
				engineering_staff += candidate
			else if (istype(JOB, /datum/job/research/scientist))
				research_staff += candidate
			else if (istype(JOB, /datum/job/research/medical_doctor))
				medical_staff += candidate

			if (JOB.assigned >= JOB.limit || unassigned.len == 0) break
			logTheThing("debug", null, null, "<b>I Said No/Jobs:</b> [candidate] took [JOB.name] from Level 3 Job Picker")
			candidate.mind.assigned_role = JOB.name
			logTheThing("debug", candidate, null, "assigned job: [candidate.mind.assigned_role]")
			unassigned -= candidate
			JOB.assigned++

	/////////////////////////////////////////////////
	///////////COMMAND PROMOTIONS////////////////////
	/////////////////////////////////////////////////

	//Find the command jobs, if they are unfilled, pick a random person from within that department to be that command officer
	for(var/datum/job/JOB in available_job_roles)
		//cheaper to discout this first than type check here *I think*
		if (JOB.limit > 0 && JOB.assigned < JOB.limit)
			//Promote Chief Engineer
			if (istype(JOB, /datum/job/command/chief_engineer))
				var/list/picks = FindPromotionCandidates(engineering_staff, JOB)
				if (!picks || !picks.len)
					continue
				var/mob/new_player/candidate = pick(picks)
				logTheThing("debug", null, null, "<b>kyle:</b> [candidate] took [JOB.name] from Job Promotion Picker")
				candidate.mind.assigned_role = JOB.name
				logTheThing("debug", candidate, null, "reassigned job: [candidate.mind.assigned_role]")
				JOB.assigned++
			//Promote Research Director
			else if (istype(JOB, /datum/job/command/research_director))
				var/list/picks = FindPromotionCandidates(research_staff, JOB)
				if (!picks || !picks.len)
					continue
				var/mob/new_player/candidate = pick(picks)
				logTheThing("debug", null, null, "<b>kyle:</b> [candidate] took [JOB.name] from Job Promotion Picker")
				candidate.mind.assigned_role = JOB.name
				logTheThing("debug", candidate, null, "reassigned job: [candidate.mind.assigned_role]")
				JOB.assigned++
			//Promote Medical Director
			else if (istype(JOB, /datum/job/command/medical_director))
				var/list/picks = FindPromotionCandidates(medical_staff, JOB)
				if (!picks || !picks.len)
					continue
				var/mob/new_player/candidate = pick(picks)
				logTheThing("debug", null, null, "<b>kyle:</b> [candidate] took [JOB.name] from Job Promotion Picker")
				candidate.mind.assigned_role = JOB.name
				logTheThing("debug", candidate, null, "reassigned job: [candidate.mind.assigned_role]")
				JOB.assigned++


	// If there's anyone left without a job after this, lump them with a randomly
	// picked low priority role and be done with it
	if (!low_priority_jobs.len)
		// we really need to fix this or it'll be some kinda weird inf loop shit
		low_priority_jobs += "Staff Assistant"
	for (var/mob/new_player/player in unassigned)
		logTheThing("debug", null, null, "<b>I Said No/Jobs:</b> [player] given a low priority role")
		player.mind.assigned_role = pick(low_priority_jobs)
		logTheThing("debug", player, null, "assigned job: [player.mind.assigned_role]")

	return 1

//Given a list of candidates returns candidates that are acceptable to be promoted based on their medium/low priorities
//ideally JOB should only be a command position. eg. CE, RD, MD
/proc/FindPromotionCandidates(list/staff, var/datum/job/JOB)
	var/list/picks = FindOccupationCandidates(staff,JOB.name,2)

	//If there are no acceptable candidates (no inappropriate antags, no job bans) who have it in their medium priority list
	if (!picks.len)
		picks = FindOccupationCandidates(staff,JOB.name,3)
	return picks

//hey i changed this from a /human/proc to a /living/proc so that critters (from the job creator) would latejoin properly	-- MBC
/mob/living/proc/Equip_Rank(rank, joined_late, no_special_spawn)

	var/datum/job/JOB = find_job_in_controller_by_string(rank)
	if (!JOB)
		boutput(src, "<span class='alert'><b>Something went wrong setting up your rank and equipment! Report this to a coder.</b></span>")
		return

	if (JOB.announce_on_join)
		SPAWN_DBG(1 SECOND)
			boutput(world, "<b>[src.name] is the [JOB.name]!</b>")
	boutput(src, "<B>You are the [JOB.name].</B>")
	src.job = JOB.name
	src.mind.assigned_role = JOB.name

	if (!joined_late)
		if (ticker?.mode && !istype(ticker.mode, /datum/game_mode/construction))
			if (job_start_locations && islist(job_start_locations[JOB.name]))
				var/tries = 8
				var/turf/T
				do
					T = pick(job_start_locations[JOB.name])
				while((locate(/mob) in T) && tries--)
				src.set_loc(T)
		else
			src.set_loc(pick_landmark(LANDMARK_LATEJOIN))
	else
		src.unlock_medal("Fish", 1)

	if (time2text(world.realtime, "MM DD") == "12 25")
		src.unlock_medal("A Holly Jolly Spacemas")

	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		H.Equip_Job_Slots(JOB)

	var/possible_new_mob = JOB.special_setup(src, no_special_spawn) //If special_setup creates a new mob for us, it should return the new mob!

	if (possible_new_mob && possible_new_mob != src)
		// ok so all the below shit checks if you're a human.
		// that's well and good but we need to be operating on possible_new_mob now,
		// because that's what the player is, not the one we were initially given.

		src = possible_new_mob // let's hope this breaks nothing


	if (ishuman(src) && JOB.add_to_manifest)
		// Manifest stuff
		var/sec_note = ""
		var/med_note = ""
		if(src.client && src.client.preferences)
			sec_note = src.client.preferences.security_note
			med_note = src.client.preferences.medical_note
		data_core.addManifest(src, sec_note, med_note)

	SPAWN_DBG(0)
		if (ishuman(src))
			if (src.traitHolder && !src.traitHolder.hasTrait("immigrant"))
				src:spawnId(rank)
			else if (src.traitHolder)
				//Has the immigrant trait - they're hiding in a random locker
				var/list/obj/storage/SL = list()
				for(var/obj/storage/S in by_type[/obj/storage])
					// Only closed, unsecured lockers/crates on Z1 that are not inside the listening post
					if(S.z == 1 && !S.open && !istype(S, /obj/storage/secure) && !istype(S, /obj/storage/crate/loot) && !istype(get_area(S), /area/listeningpost))
						var/turf/simulated/T = S.loc
						//Simple checks done, now do some environment checks to make sure it's survivable
						if(istype(T) && T.air && T.air.oxygen >= (MOLES_O2STANDARD - 1) && T.air.temperature >= T0C)
							SL.Add(S)

				if(SL.len > 0)
					src.set_loc(pick(SL))

			if (prob(10) && islist(random_pod_codes) && random_pod_codes.len)
				var/obj/machinery/vehicle/V = pick(random_pod_codes)
				random_pod_codes -= V
				if (V && V.lock && V.lock.code)
					boutput(src, "<span class='notice'>The unlock code to your pod ([V]) is: [V.lock.code]</span>")
					if (src.mind)
						src.mind.store_memory("The unlock code to your pod ([V]) is: [V.lock.code]")

			if (istraitor(src) && src.mind.late_special_role == 1)
				//put this here because otherwise it's called before they have a PDA
				equip_traitor(src)

		set_clothing_icon_dirty()
		sleep(0.1 SECONDS)
		update_icons_if_needed()

		if (joined_late == 1 && map_settings && map_settings.arrivals_type != MAP_SPAWN_CRYO && JOB.radio_announcement)
			if (src.mind && src.mind.assigned_role) //ZeWaka: I'm adding this back here because hell if I know where it goes.
				for (var/obj/machinery/computer/announcement/A in machine_registry[MACHINES_ANNOUNCEMENTS])
					if (!A.status && A.announces_arrivals)
						if (src.mind.assigned_role == "MODE") //ZeWaka: Fix for alien invasion dudes. Possibly not needed now.
							return
						else
							A.announce_arrival(src.real_name, src.mind.assigned_role)

		//Equip_Bank_Purchase AFTER special_setup() call, because they might no longer be a human after that
		if (possible_new_mob)
			var/mob/living/newmob = possible_new_mob
			newmob.Equip_Bank_Purchase(newmob.mind.purchased_bank_item)
		else
			src.Equip_Bank_Purchase(src.mind.purchased_bank_item)

	return

/mob/living/carbon/human/proc/Equip_Job_Slots(var/datum/job/JOB)
	if (JOB.slot_back)
		src.equip_new_if_possible(JOB.slot_back, slot_back)
		if (istype(src.back, /obj/item/storage))
			for (var/X in JOB.items_in_backpack)
				if(ispath(X))
					src.equip_new_if_possible(X, slot_in_backpack)
			if(JOB.receives_disk)
				var/obj/item/disk/data/floppy/D = new /obj/item/disk/data/floppy(src)
				src.equip_if_possible(D, slot_in_backpack)
				var/datum/computer/file/clone/R = new
				R.fields["ckey"] = ckey(src.key)
				R.fields["name"] = src.real_name
				R.fields["id"] = copytext(md5(src.real_name), 2, 6)

				var/datum/bioHolder/B = new/datum/bioHolder(null)
				B.CopyOther(src.bioHolder)

				R.fields["holder"] = B

				R.fields["abilities"] = null
				if (src.abilityHolder)
					var/datum/abilityHolder/A = src.abilityHolder.deepCopy()
					R.fields["abilities"] = A

				R.fields["traits"] = list()
				if(src.traitHolder && src.traitHolder.traits.len)
					R.fields["traits"] = src.traitHolder.traits.Copy()

				R.fields["imp"] = null
				R.fields["mind"] = src.mind
				R.name = "CloneRecord-[ckey(src.real_name)]"
				D.root.add_file(R)
				D.name = "data disk - '[src.real_name]'"

			if(JOB.receives_badge)
				var/obj/item/clothing/suit/security_badge/B = new /obj/item/clothing/suit/security_badge(src)
				src.equip_if_possible(B, slot_in_backpack)
				B.badge_owner_name = src.real_name
				B.badge_owner_job = src.job

	if (JOB.slot_jump)
		src.equip_new_if_possible(JOB.slot_jump, slot_w_uniform)

	if (JOB.slot_belt)
		if (src.bioHolder && src.bioHolder.HasEffect("fat"))
			src.equip_new_if_possible(JOB.slot_belt, slot_in_backpack)
		else
			src.equip_new_if_possible(JOB.slot_belt, slot_belt)
			if (src.traitHolder && src.traitHolder.hasTrait("immigrant") && istype(src.belt, /obj/item/device/pda2))
				del(src.belt) //UGHUGHUGHUGUUUUUUUU
		if (JOB?.items_in_belt.len && istype(src.belt, /obj/item/storage))
			for (var/X in JOB.items_in_belt)
				if(ispath(X))
					src.equip_new_if_possible(X, slot_in_belt)

	if (JOB.slot_foot)
		src.equip_new_if_possible(JOB.slot_foot, slot_shoes)
	if (JOB.slot_suit)
		src.equip_new_if_possible(JOB.slot_suit, slot_wear_suit)
	if (JOB.slot_ears)
		if (!(src.traitHolder && src.traitHolder.hasTrait("allears") && ispath(JOB.slot_ears,/obj/item/device/radio/headset)))
			src.equip_new_if_possible(JOB.slot_ears, slot_ears)
	if (JOB.slot_mask)
		src.equip_new_if_possible(JOB.slot_mask, slot_wear_mask)
	if (JOB.slot_glov)
		src.equip_new_if_possible(JOB.slot_glov, slot_gloves)
	if (JOB.slot_eyes)
		src.equip_new_if_possible(JOB.slot_eyes, slot_glasses)
	if (JOB.slot_head)
		src.equip_new_if_possible(JOB.slot_head, slot_head)
	if (JOB.slot_poc1)
		if (src.bioHolder && src.bioHolder.HasEffect("fat"))
			src.equip_new_if_possible(JOB.slot_poc1, slot_in_backpack)
		else
			src.equip_new_if_possible(JOB.slot_poc1, slot_l_store)
	if (JOB.slot_poc2)
		if (src.bioHolder && src.bioHolder.HasEffect("fat"))
			src.equip_new_if_possible(JOB.slot_poc2, slot_in_backpack)
		else
			src.equip_new_if_possible(JOB.slot_poc2, slot_r_store)
	if (JOB.slot_rhan)
		src.equip_new_if_possible(JOB.slot_rhan, slot_r_hand)
	if (JOB.slot_lhan)
		src.equip_new_if_possible(JOB.slot_lhan, slot_l_hand)

	var/T = pick(trinket_safelist)
	var/obj/item/trinket = null
	var/random_lunchbox_path = pick(childrentypesof(/obj/item/storage/lunchbox))

	if (src.traitHolder && src.traitHolder.hasTrait("pawnstar"))
		trinket = null //You better stay null, you hear me!
	else if (src.traitHolder && src.traitHolder.hasTrait("loyalist"))
		trinket = new/obj/item/clothing/head/NTberet(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("petasusaphilic"))
		var/picked = pick(childrentypesof(/obj/item/clothing/head) - (typesof(/obj/item/clothing/head/bighat))) //IM A MONSTER DONT LOOK AT ME. NOOOOOOOOOOO
		trinket = new picked(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("conspiracytheorist"))
		trinket = new/obj/item/clothing/head/tinfoil_hat
	else if (src.traitHolder && src.traitHolder.hasTrait("beestfriend"))
		if (prob(15))
			trinket = new/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy(src)
		else
			trinket = new/obj/item/reagent_containers/food/snacks/ingredient/egg/bee(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("smoker"))
		trinket = new/obj/item/device/light/zippo(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("lunchbox"))
		trinket = new random_lunchbox_path(src)
	else
		trinket = new T(src)

	if (trinket) // rewrote this a little bit so hopefully people will always get their trinket
		src.trinket = trinket
		src.trinket.event_handler_flags |= IS_TRINKET
		trinket.name = "[src.real_name][pick_string("trinkets.txt", "modifiers")] [trinket.name]"
		trinket.quality = rand(5,80)
		var/equipped = 0
		if (istype(src.back, /obj/item/storage) && src.equip_if_possible(trinket, slot_in_backpack))
			equipped = 1
		else if (istype(src.belt, /obj/item/storage) && src.equip_if_possible(trinket, slot_in_belt))
			equipped = 1
		if (!equipped)
			if (!src.l_store && src.equip_if_possible(trinket, slot_l_store))
				equipped = 1
			else if (!src.r_store && src.equip_if_possible(trinket, slot_r_store))
				equipped = 1
			else if (!src.l_hand && src.equip_if_possible(trinket, slot_l_hand))
				equipped = 1
			else if (!src.r_hand && src.equip_if_possible(trinket, slot_r_hand))
				equipped = 1

			if (!equipped) // we've tried most available storage solutions here now so uh just put it on the ground
				trinket.set_loc(get_turf(src))

	return

/mob/living/carbon/human/proc/spawnId(rank)
	var/obj/item/card/id/C = null
	if(istype(get_area(src),/area/afterlife))
		rank = "Captain"
	var/datum/job/JOB = find_job_in_controller_by_string(rank)
	if (!JOB || !JOB.slot_card)
		return null

	C = new JOB.slot_card(src)

	if(C)
		var/realName = src.real_name

		if(src.traitHolder && src.traitHolder.hasTrait("clericalerror"))
			realName = replacetext(realName, "a", "o")
			realName = replacetext(realName, "e", "i")
			realName = replacetext(realName, "u", pick("a", "e"))
			if(prob(50)) realName = replacetext(realName, "n", "m")
			if(prob(50)) realName = replacetext(realName, "t", pick("d", "k"))
			if(prob(50)) realName = replacetext(realName, "p", pick("b", "t"))

			var/datum/data/record/B = FindBankAccountByName(src.real_name)
			if (B && B.fields["name"])
				B.fields["name"] = realName

		C.registered = realName
		C.assignment = JOB.name
		C.name = "[C.registered]'s ID Card ([C.assignment])"
		C.access = JOB.access.Copy()

		if(src.bioHolder && src.bioHolder.HasEffect("fat"))
			src.equip_if_possible(C, slot_in_backpack)
		else
			src.equip_if_possible(C, slot_wear_id)

		if(src.pin)
			C.pin = src.pin

	for (var/obj/item/device/pda2/PDA in src.contents)
		PDA.owner = src.real_name
		PDA.ownerAssignment = JOB.name
		PDA.name = "PDA-[src.real_name]"

	boutput(src, "<span class='notice'>Your pin to your ID is: [C.pin]</span>")
	if (src.mind)
		src.mind.store_memory("Your pin to your ID is: [C.pin]")

	if (wagesystem.jobs[JOB.name])
		var/cashModifier = 1.0
		if (src.traitHolder && src.traitHolder.hasTrait("pawnstar"))
			cashModifier = 1.25

		var/obj/item/spacecash/S = unpool(/obj/item/spacecash)
		S.setup(src,wagesystem.jobs[JOB.name] * cashModifier)

		src.equip_if_possible(S, slot_r_store)
	else
		var/shitstore = rand(1,3)
		switch(shitstore)
			if(1)
				src.equip_new_if_possible(/obj/item/pen, slot_r_store)
			if(2)
				src.equip_new_if_possible(/obj/item/reagent_containers/food/drinks/water, slot_r_store)


/mob/living/carbon/human/proc/JobEquipSpawned(rank, no_special_spawn)
	var/datum/job/JOB = find_job_in_controller_by_string(rank)
	if (!JOB)
		boutput(src, "<span class='alert'><b>UH OH, the game couldn't find your job to set it up! Report this to a coder.</b></span>")
		return

	if (JOB.slot_back)
		src.equip_new_if_possible(JOB.slot_back, slot_back)
	if (JOB.slot_back && JOB?.items_in_backpack.len)
		for (var/X in JOB.items_in_backpack)
			if(ispath(X))
				src.equip_new_if_possible(X, slot_in_backpack)
	if (JOB.slot_jump)
		src.equip_new_if_possible(JOB.slot_jump, slot_w_uniform)
	if (JOB.slot_belt)
		src.equip_new_if_possible(JOB.slot_belt, slot_belt)
	if (JOB.slot_foot)
		src.equip_new_if_possible(JOB.slot_foot, slot_shoes)
	if (JOB.slot_suit)
		src.equip_new_if_possible(JOB.slot_suit, slot_wear_suit)
	if (JOB.slot_ears)
		if (!(src.traitHolder && src.traitHolder.hasTrait("allears") && ispath(JOB.slot_ears,/obj/item/device/radio/headset)))
			src.equip_new_if_possible(JOB.slot_ears, slot_ears)
	if (JOB.slot_mask)
		src.equip_new_if_possible(JOB.slot_mask, slot_wear_mask)
	if (JOB.slot_glov)
		src.equip_new_if_possible(JOB.slot_glov, slot_gloves)
	if (JOB.slot_eyes)
		src.equip_new_if_possible(JOB.slot_eyes, slot_glasses)
	if (JOB.slot_head)
		src.equip_new_if_possible(JOB.slot_head, slot_head)
	if (JOB.slot_poc1)
		src.equip_new_if_possible(JOB.slot_poc1, slot_l_store)
	if (JOB.slot_poc2)
		src.equip_new_if_possible(JOB.slot_poc2, slot_r_store)
	if (JOB.slot_rhan)
		src.equip_new_if_possible(JOB.slot_rhan, slot_r_hand)
	if (JOB.slot_lhan)
		src.equip_new_if_possible(JOB.slot_lhan, slot_l_hand)

	if (ishuman(src) && JOB.spawn_id)
		src.spawnId(rank)

	JOB.special_setup(src, no_special_spawn)

	update_clothing()
	update_inhands()

	return

// this proc is shit, make a better one 2day
proc/bad_traitorify(mob/H, traitor_role="hard-mode traitor")
	var/list/eligible_objectives = typesof(/datum/objective/regular/) + typesof(/datum/objective/escape/) - /datum/objective/regular/
	var/num_objectives = rand(1,3)
	var/datum/objective/new_objective = null
	for(var/i = 0, i < num_objectives, i++)
		var/select_objective = pick(eligible_objectives)
		new_objective = new select_objective
		new_objective.owner = H.mind
		new_objective.set_up()
		H.mind.objectives += new_objective

	H.mind.special_role = traitor_role
	H << browse(grabResource("html/traitorTips/traitorhardTips.html"),"window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0")
	if(!(H.mind in ticker.mode.traitors))
		ticker.mode.traitors += H.mind
	if (H.mind.current)
		H.mind.current.antagonist_overlay_refresh(1, 0)

//////////////////////////////////////////////
// cogwerks - personalized trinkets project //
/////////////////////////////////////////////

var/list/trinket_safelist = list(/obj/item/basketball,/obj/item/instrument/bikehorn, /obj/item/brick, /obj/item/clothing/glasses/eyepatch,
/obj/item/clothing/glasses/regular, /obj/item/clothing/glasses/sunglasses, /obj/item/clothing/gloves/boxing,
/obj/item/clothing/mask/horse_mask, /obj/item/clothing/mask/clown_hat, /obj/item/clothing/head/cowboy, /obj/item/clothing/shoes/cowboy, /obj/item/clothing/shoes/moon,
/obj/item/clothing/suit/sweater, /obj/item/clothing/suit/sweater/red, /obj/item/clothing/suit/sweater/green, /obj/item/clothing/suit/sweater/grandma, /obj/item/clothing/under/shorts,
/obj/item/clothing/under/suit/pinstripe, /obj/item/cigpacket, /obj/item/coin, /obj/item/crowbar, /obj/item/pen/crayon/lipstick,
/obj/item/dice, /obj/item/dice/d20, /obj/item/device/light/flashlight, /obj/item/device/key/random, /obj/item/extinguisher, /obj/item/firework,
/obj/item/football, /obj/item/material_piece/gold, /obj/item/instrument/harmonica, /obj/item/horseshoe,
/obj/item/kitchen/utensil/knife, /obj/item/raw_material/rock, /obj/item/pen/fancy, /obj/item/pen/odd, /obj/item/plant/herb/cannabis/spawnable,
/obj/item/razor_blade,/obj/item/rubberduck, /obj/item/instrument/saxophone, /obj/item/scissors, /obj/item/screwdriver, /obj/item/skull, /obj/item/stamp,
/obj/item/instrument/vuvuzela, /obj/item/wrench, /obj/item/device/light/zippo, /obj/item/reagent_containers/food/drinks/bottle/beer, /obj/item/reagent_containers/food/drinks/bottle/vintage,
/obj/item/reagent_containers/food/drinks/bottle/vodka, /obj/item/reagent_containers/food/drinks/bottle/rum, /obj/item/reagent_containers/food/drinks/bottle/hobo_wine/safe,
/obj/item/reagent_containers/food/snacks/burger, /obj/item/reagent_containers/food/snacks/burger/cheeseburger,
/obj/item/reagent_containers/food/snacks/burger/moldy,/obj/item/reagent_containers/food/snacks/candy/chocolate, /obj/item/reagent_containers/food/snacks/chips,
/obj/item/reagent_containers/food/snacks/cookie,/obj/item/reagent_containers/food/snacks/ingredient/egg,
/obj/item/reagent_containers/food/snacks/ingredient/egg/bee,/obj/item/reagent_containers/food/snacks/plant/apple,
/obj/item/reagent_containers/food/snacks/plant/banana, /obj/item/reagent_containers/food/snacks/plant/potato, /obj/item/reagent_containers/food/snacks/sandwich/pb,
/obj/item/reagent_containers/food/snacks/sandwich/cheese, /obj/item/reagent_containers/syringe/krokodil, /obj/item/reagent_containers/syringe/morphine,
/obj/item/reagent_containers/patch/LSD, /obj/item/reagent_containers/patch/nicotine, /obj/item/reagent_containers/glass/bucket, /obj/item/reagent_containers/glass/beaker,
/obj/item/reagent_containers/food/drinks/drinkingglass, /obj/item/reagent_containers/food/drinks/drinkingglass/shot,/obj/item/storage/pill_bottle/bathsalts,
/obj/item/storage/pill_bottle/catdrugs, /obj/item/storage/pill_bottle/crank, /obj/item/storage/pill_bottle/cyberpunk, /obj/item/storage/pill_bottle/methamphetamine,
/obj/item/spraybottle,/obj/item/staple_gun,/obj/item/clothing/head/NTberet,/obj/item/clothing/head/biker_cap, /obj/item/clothing/head/black, /obj/item/clothing/head/blue,
/obj/item/clothing/head/chav, /obj/item/clothing/head/det_hat, /obj/item/clothing/head/green, /obj/item/clothing/head/helmet/hardhat, /obj/item/clothing/head/merchant_hat,
/obj/item/clothing/head/mj_hat, /obj/item/clothing/head/red, /obj/item/clothing/head/that, /obj/item/clothing/head/wig, /obj/item/clothing/head/turban, /obj/item/dice/magic8ball,
/obj/item/reagent_containers/food/drinks/mug/random_color, /obj/item/reagent_containers/food/drinks/skull_chalice, /obj/item/pen/marker/random, /obj/item/pen/crayon/random,
/obj/item/clothing/gloves/yellow/unsulated, /obj/item/reagent_containers/food/snacks/fortune_cookie, /obj/item/instrument/triangle, /obj/item/instrument/tambourine, /obj/item/instrument/cowbell,
/obj/item/toy/plush/small/bee, /obj/item/paper/book/the_trial, /obj/item/paper/book/deep_blue_sea, /obj/item/clothing/suit/bedsheet/cape/red, /obj/item/disk/data/cartridge/clown,
/obj/item/clothing/mask/cigarette/cigar, /obj/item/device/light/sparkler, /obj/item/toy/sponge_capsule, /datum/plant/fruit/pear, /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm,
/obj/item/seed/alien)
