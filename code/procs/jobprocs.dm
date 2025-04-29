var/global/totally_random_jobs = FALSE

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

/proc/FindOccupationCandidates(list/unassigned, job, level, set_antag_fallthrough = FALSE)
	set background = 1

	var/list/candidates = list()

	var/datum/job/J = find_job_in_controller_by_string(job)
	if(!J)
		CRASH("FindOccupationCandidates called with invalid job name: [job] at level: [level]")
	for (var/mob/new_player/player in unassigned)
		if (!job_controls.check_job_eligibility(player, J))
			continue

		var/datum/preferences/P  = player.client.preferences
		if (level == 1 && P.job_favorite == J.name)
			candidates += player
		else if (level == 2 && P.jobs_med_priority.Find(J.name))
			candidates += player
		else if (level == 3 && P.jobs_low_priority.Find(J.name))
			candidates += player

	return candidates

#define ASSIGN_STAFF_LISTS(JOB, player) if (istype(JOB, /datum/job/engineering/engineer))\
	{engineering_staff += player}\
else if (istype(JOB, /datum/job/research/scientist))\
	{research_staff += player}\
else if (istype(JOB, /datum/job/medical/medical_doctor))\
	{medical_staff += player}\
else if (istype(JOB, /datum/job/security/security_officer))\
	{security_officers += player}

/proc/DivideOccupations()
	set background = 1

	var/list/unassigned = list()

	for (var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player) || !player.mind) continue
		if ((player.mind.special_role == ROLE_WRAITH) || (player.mind.special_role == ROLE_BLOB) || (player.mind.special_role == ROLE_FLOCKMIND) || (player.mind.special_role == ROLE_MINDEATER))
			continue //If they aren't spawning in as crew they shouldn't take a job slot.
		if (player.ready && !player.mind.assigned_role)
			unassigned += player

	var/percent_readied_up = length(clients) ? (length(unassigned)/length(clients)) * 100 : 0
	logTheThing(LOG_DEBUG, null, "<b>Aloe</b>: roughly [percent_readied_up]% of players were readied up at roundstart (blobs and wraiths don't count).")

	if (!length(unassigned))
		return 0

	// If the mode is construction, ignore all this shit and sort everyone into the construction worker job.
	if (master_mode == "construction")
		for (var/mob/new_player/player in unassigned)
			player.mind.assigned_role = "Construction Worker"
		return

	#ifdef I_WANNA_BE_THE_JOB
	for (var/mob/new_player/player in unassigned)
		player.mind.assigned_role = I_WANNA_BE_THE_JOB
	UNLINT(return)
	#endif

	var/list/pick1 = list()
	var/list/pick2 = list()
	var/list/pick3 = list()

	// jobs we want to assign before any others
	var/list/high_priority_jobs = list()

	var/list/medical_staff = list()
	var/list/engineering_staff = list()
	var/list/research_staff = list()
	var/list/security_officers = list()


	for(var/datum/job/JOB in job_controls.staple_jobs)
		if (JOB.variable_limit)
			JOB.recalculate_limit(length(unassigned))
		// If it's hi-pri, add it to that list. Simple enough
		if (JOB.high_priority_job)
			high_priority_jobs.Add(JOB)

	// Wiggle the players too so that priority isn't determined by key alphabetization
	shuffle_list(unassigned)

	//Shuffle them and *then* sort them according to their order priority
	sortList(high_priority_jobs, GLOBAL_PROC_REF(cmp_job_order_priority))

	// First we deal with high-priority jobs like Captain or AI which generally will always
	// be present on the station - we want these assigned first just to be sure
	// Though we don't want to do this in sandbox mode where it won't matter anyway
	if(master_mode != "sandbox")
		for(var/datum/job/JOB in high_priority_jobs)
			if (!length(unassigned)) break

			if (JOB.limit > 0 && JOB.assigned >= JOB.limit)
				continue

			//single digit pop rounds can be exempt from more than one high priority assignment per role
			if (length(unassigned) < 10)
				JOB.high_priority_limit = 1

			// get all possible candidates for it
			pick1 = FindOccupationCandidates(unassigned,JOB.name,1)
			pick2 = FindOccupationCandidates(unassigned,JOB.name,2)
			pick3 = FindOccupationCandidates(unassigned,JOB.name,3)

			// now assign them - i'm not hardcoding limits on these because i don't think any
			// of us are quite stupid enough to edit the AI's limit to -1 preround and have a
			// horrible multicore PC station round.. (i HOPE anyway)
			for(var/mob/new_player/candidate in pick1)
				if(!candidate.client) continue
				if (JOB.assigned >= JOB.limit || JOB.assigned >= JOB.high_priority_limit || !length(unassigned)) break
				logTheThing(LOG_DEBUG, null, "<b>I Said No/Jobs:</b> [candidate] took [JOB.name] from High Priority Job Picker Lv1")
				ASSIGN_STAFF_LISTS(JOB, candidate)
				candidate.mind.assigned_role = JOB.name
				logTheThing(LOG_DEBUG, candidate, "assigned job: [candidate.mind.assigned_role]")
				unassigned -= candidate
				JOB.assigned++
			for(var/mob/new_player/candidate in pick2)
				if(!candidate.client) continue
				if (JOB.assigned >= JOB.limit || JOB.assigned >= JOB.high_priority_limit || !length(unassigned)) break
				logTheThing(LOG_DEBUG, null, "<b>I Said No/Jobs:</b> [candidate] took [JOB.name] from High Priority Job Picker Lv2")
				ASSIGN_STAFF_LISTS(JOB, candidate)
				candidate.mind.assigned_role = JOB.name
				logTheThing(LOG_DEBUG, candidate, "assigned job: [candidate.mind.assigned_role]")
				unassigned -= candidate
				JOB.assigned++
			for(var/mob/new_player/candidate in pick3)
				if(!candidate.client) continue
				if (JOB.assigned >= JOB.limit || JOB.assigned >= JOB.high_priority_limit || !length(unassigned)) break
				logTheThing(LOG_DEBUG, null, "<b>I Said No/Jobs:</b> [candidate] took [JOB.name] from High Priority Job Picker Lv3")
				ASSIGN_STAFF_LISTS(JOB, candidate)
				candidate.mind.assigned_role = JOB.name
				logTheThing(LOG_DEBUG, candidate, "assigned job: [candidate.mind.assigned_role]")
				unassigned -= candidate
				JOB.assigned++

	// allocate the remaining players to jobs by preference
	for (var/mob/new_player/player as anything in unassigned)
		var/datum/job/job = job_controls.allocate_player_to_job_by_preference(player)
		ASSIGN_STAFF_LISTS(job, player)

	/////////////////////////////////////////////////
	///////////COMMAND PROMOTIONS////////////////////
	/////////////////////////////////////////////////

	//Find the command jobs, if they are unfilled, pick a random person from within that department to be that command officer
	//if they had the command job in their medium or low priority jobs
	for(var/datum/job/command/command_job in job_controls.staple_jobs)
		if ((command_job.limit > 0) && (command_job.assigned < command_job.limit))
			var/list/picks
			if (istype(command_job, /datum/job/command/chief_engineer))
				picks = FindPromotionCandidates(engineering_staff, command_job)
			else if (istype(command_job, /datum/job/command/research_director))
				picks = FindPromotionCandidates(research_staff, command_job)
			else if (istype(command_job, /datum/job/command/medical_director))
				picks = FindPromotionCandidates(medical_staff, command_job)
			else if (istype(command_job, /datum/job/command/head_of_security))
				picks = FindPromotionCandidates(security_officers, command_job)
			if (!length(picks))
				continue
			var/mob/new_player/candidate = pick(picks)
			logTheThing(LOG_DEBUG, null, "<b>kyle:</b> [candidate] took [command_job.name] from Job Promotion Picker")
			candidate.mind.assigned_role = command_job.name
			logTheThing(LOG_DEBUG, candidate, "reassigned job: [candidate.mind.assigned_role]")
			command_job.assigned++
	return TRUE

//Given a list of candidates returns candidates that are acceptable to be promoted based on their medium/low priorities
//ideally JOB should only be a command position. eg. CE, RD, MD
/proc/FindPromotionCandidates(list/staff, var/datum/job/JOB)
	for (var/level in 1 to 3) //favourite, med prio, low prio in that order
		var/list/picks = FindOccupationCandidates(staff,JOB.name,level)
		if (length(picks))
			return picks
	return list()

/proc/equip_job_items(var/datum/job/JOB, var/mob/living/carbon/human/H)
	// Jumpsuit - Important! Must be equipped early to provide valid slots for other items
	if (JOB.slot_jump && length(JOB.slot_jump) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_jump), SLOT_W_UNIFORM)
	else if (length(JOB.slot_jump))
		H.equip_new_if_possible(JOB.slot_jump[1], SLOT_W_UNIFORM)
	// Backpack and contents
	if (JOB.slot_back && length(JOB.slot_back) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_back), SLOT_BACK)
	else if (length(JOB.slot_back))
		H.equip_new_if_possible(JOB.slot_back[1], SLOT_BACK)
	if (JOB.slot_back && length(JOB.items_in_backpack))
		for (var/X in JOB.items_in_backpack)
			if(ispath(X))
				H.equip_new_if_possible(X, SLOT_IN_BACKPACK)
	// Belt and contents
	if (JOB.slot_belt && length(JOB.slot_belt) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_belt), SLOT_BELT)
	else if (length(JOB.slot_belt))
		H.equip_new_if_possible(JOB.slot_belt[1], SLOT_BELT)
	if (JOB.slot_belt && length(JOB.items_in_belt) && H.belt?.storage)
		for (var/X in JOB.items_in_belt)
			if(ispath(X))
				H.equip_new_if_possible(X, SLOT_IN_BELT)
	// Footwear
	if (JOB.slot_foot && length(JOB.slot_foot) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_foot), SLOT_SHOES)
	else if (length(JOB.slot_foot))
		H.equip_new_if_possible(JOB.slot_foot[1], SLOT_SHOES)
	// Suit
	if (JOB.slot_suit && length(JOB.slot_suit) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_suit), SLOT_WEAR_SUIT)
	else if (length(JOB.slot_suit))
		H.equip_new_if_possible(JOB.slot_suit[1], SLOT_WEAR_SUIT)
	// Ears
	if (JOB.slot_ears && length(JOB.slot_ears) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_ears), SLOT_EARS)
	else if (length(JOB.slot_ears))
		if (!(H.traitHolder && H.traitHolder.hasTrait("allears") && ispath(JOB.slot_ears[1],
	/obj/item/device/radio/headset)))
			H.equip_new_if_possible(JOB.slot_ears[1], SLOT_EARS)
	// Mask
	if (JOB.slot_mask && length(JOB.slot_mask) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_mask), SLOT_WEAR_MASK)
	else if (length(JOB.slot_mask))
		H.equip_new_if_possible(JOB.slot_mask[1], SLOT_WEAR_MASK)
	// Gloves
	if (JOB.slot_glov && length(JOB.slot_glov) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_glov), SLOT_GLOVES)
	else if (length(JOB.slot_glov))
		H.equip_new_if_possible(JOB.slot_glov[1], SLOT_GLOVES)
	// Eyes
	if (JOB.slot_eyes && length(JOB.slot_eyes) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_eyes), SLOT_GLASSES)
	else if (length(JOB.slot_eyes))
		H.equip_new_if_possible(JOB.slot_eyes[1], SLOT_GLASSES)
	// Head
	if (JOB.slot_head && length(JOB.slot_head) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_head), SLOT_HEAD)
	else if (length(JOB.slot_head))
		H.equip_new_if_possible(JOB.slot_head[1], SLOT_HEAD)
	// Left pocket
	if (JOB.slot_poc1 && length(JOB.slot_poc1) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_poc1), SLOT_L_STORE)
	else if (length(JOB.slot_poc1))
		H.equip_new_if_possible(JOB.slot_poc1[1], SLOT_L_STORE)
	// Right pocket
	if (JOB.slot_poc2 && length(JOB.slot_poc2) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_poc2), SLOT_R_STORE)
	else if (length(JOB.slot_poc2))
		H.equip_new_if_possible(JOB.slot_poc2[1], SLOT_R_STORE)
	// Left hand
	if (JOB.slot_lhan && length(JOB.slot_lhan) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_poc1), SLOT_L_HAND)
	else if (length(JOB.slot_lhan))
		H.equip_new_if_possible(JOB.slot_lhan[1], SLOT_L_HAND)
	// Right hand
	if (JOB.slot_rhan && length(JOB.slot_rhan) > 1)
		H.equip_new_if_possible(weighted_pick(JOB.slot_poc1), SLOT_R_HAND)
	else if (length(JOB.slot_rhan))
		H.equip_new_if_possible(JOB.slot_rhan[1], SLOT_R_HAND)

	//#ifdef APRIL_FOOLS
	//H.back?.setMaterial(getMaterial("jean"))
	//H.gloves?.setMaterial(getMaterial("jean"))
	//H.wear_suit?.setMaterial(getMaterial("jean"))
	//H.wear_mask?.setMaterial(getMaterial("jean"))
	//H.w_uniform?.setMaterial(getMaterial("jean"))
	//H.shoes?.setMaterial(getMaterial("jean"))
	//H.head?.setMaterial(getMaterial("jean"))
	//#endif

//hey i changed this from a /human/proc to a /living/proc so that critters (from the job creator) would latejoin properly	-- MBC
/mob/living/proc/Equip_Rank(rank, joined_late, no_special_spawn, skip_manifest = FALSE)
	var/datum/job/JOB = find_job_in_controller_by_string(rank)
	if (!JOB)
		boutput(src, SPAN_ALERT("<b>Something went wrong setting up your rank and equipment! Report this to a coder.</b>"))
		return

	if (JOB.announce_on_join)
		SPAWN(1 SECOND)
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

	if (time2text(world.realtime + 0.5 DAYS, "MM DD") == "12 25" || time2text(world.realtime - 0.5 DAYS, "MM DD") == "12 25")
		src.unlock_medal("A Holly Jolly Spacemas")

	if (ishuman(src))
		var/mob/living/carbon/human/H = src

		//remove problem traits from people on pod_wars
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/trait_name = H.traitHolder.getTraitWithCategory("background")
			H.traitHolder.removeTrait(trait_name)
			H.traitHolder.removeTrait("puritan")

		H.Equip_Job_Slots(JOB)

	var/possible_new_mob = JOB.special_setup(src, no_special_spawn) //If special_setup creates a new mob for us, it should return the new mob!

	if (possible_new_mob && possible_new_mob != src)
		// ok so all the below shit checks if you're a human.
		// that's well and good but we need to be operating on possible_new_mob now,
		// because that's what the player is, not the one we were initially given.

		src = possible_new_mob // let's hope this breaks nothing


	if (!skip_manifest && ishuman(src) && JOB.add_to_manifest)
		// Manifest stuff
		var/sec_note = ""
		var/med_note = ""
		var/synd_int_note = ""
		if(src.client?.preferences && !src.client.preferences.be_random_name)
			sec_note = src.client.preferences.security_note
			med_note = src.client.preferences.medical_note
			synd_int_note = src.client.preferences.synd_int_note
		var/obj/item/device/pda2/pda = locate() in src
		data_core.addManifest(src, sec_note, med_note, pda?.net_id, synd_int_note)

	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		H.spawnId(JOB)
		if (src.traitHolder && src.traitHolder.hasTrait("pilot"))		//Has the Pilot trait - they're drifting off-station in a pod. Note that environmental checks are not needed here.
			SPAWN(0) //pod creation sleeps for... reasons
				#define MAX_ALLOWED_ITERATIONS 300
				var/turf/pilotSpawnLocation = null

				var/valid_z_levels
				#ifdef UNDERWATER_MAP
				valid_z_levels = list(Z_LEVEL_MINING)
				#else
				valid_z_levels = list(Z_LEVEL_MINING, Z_LEVEL_DEBRIS)
				#endif

				// Counter to prevent infinite looping, in case space has been fully replaced
				var/safety = 0
				while(!istype(pilotSpawnLocation, /turf/space) && safety < MAX_ALLOWED_ITERATIONS)		//Trying to find a valid spawn location.
					pilotSpawnLocation = locate(rand(1, world.maxx), rand(1, world.maxy), pick(valid_z_levels))
					safety++
				// If it isn't a space turf just skip this all, we didn't find one
				if (istype(pilotSpawnLocation, /turf/space))								//Sanity check.
					src.set_loc(pilotSpawnLocation)
					var/obj/machinery/vehicle/V
					if (istype(pilotSpawnLocation, /turf/space/fluid))
						V = new/obj/machinery/vehicle/tank/minisub/pilot(pilotSpawnLocation)
					else											//This part of the code executes only if the map is a space one.
						V = new/obj/machinery/vehicle/miniputt/pilot(pilotSpawnLocation)
					if (V)
						for(var/obj/critter/gunbot/drone/snappedDrone in V.loc)	//Spawning onto a drone doesn't sound fun so the spawn location gets cleaned up.
							qdel(snappedDrone)
						V.finish_board_pod(src)
						V.life_support?.activate()

				#undef MAX_ALLOWED_ITERATIONS

		if (src.traitHolder && src.traitHolder.hasTrait("sleepy"))
			var/datum/trait/T = src.traitHolder.getTrait("sleepy")
			logTheThing(LOG_STATION, src, "has the Heavy Sleeper trait and is trying to spawn")
			var/list/valid_beds = list()
			for_by_tcl(bed, /obj/stool/bed)
				if (bed.z == Z_LEVEL_STATION && istype(get_area(bed), /area/station)) //believe it or not there are station areas on nonstation z levels
					if (!(locate(/mob/living/carbon/human) in get_turf(bed))) //this is slow but it's Probably worth it
						valid_beds += bed

			logTheThing(LOG_STATION, src, "has the Heavy Sleeper trait and has finished iterating through beds.")
			if (length(valid_beds) > 0)
				var/obj/stool/bed/picked = pick(valid_beds)
				src.set_loc(get_turf(picked))
				logTheThing(LOG_STATION, src, "has the Heavy Sleeper trait and spawns in a bed at [log_loc(picked)]")
				src.l_hand?.AddComponent(/datum/component/glued, src, T.spawn_delay, T.spawn_delay / 2)
				src.r_hand?.AddComponent(/datum/component/glued, src, T.spawn_delay, T.spawn_delay / 2)

				src.setStatus("resting", INFINITE_STATUS)
				src.setStatus("unconscious", T.spawn_delay)
				src.force_laydown_standup()

		if (src.traitHolder && src.traitHolder.hasTrait("partyanimal"))
			var/datum/trait/T = src.traitHolder.getTrait("partyanimal")
			var/typeinfo/datum/trait/partyanimal/typeinfo = T.get_typeinfo()
			logTheThing(LOG_STATION, H, "has the Party Animal trait and is trying to spawn")

			if (isnull(typeinfo.num_bar_turfs)) // Sometimes the bar is called a cafe and sometimes the cafe is called a bar so we'll just do both :)
				typeinfo.num_bar_turfs = length(get_area_turfs(/area/station/crew_quarters/bar, 1)) + length(get_area_turfs(/area/station/crew_quarters/cafeteria, 1))

			var/list/valid_stools = list()

			// We iterate through stools in the bar to have more natural feeling spawn positions
			for_by_tcl(stool, /obj/stool)
				if (stool.z != Z_LEVEL_STATION)
					continue
				var/area/stool_area = get_area(stool)
				var/is_bar = istype(stool_area, /area/station/crew_quarters/bar) || istype(stool_area, /area/station/crew_quarters/cafeteria)
				if (!is_bar)
					continue
				valid_stools+= stool

			logTheThing(LOG_STATION, src, "has the Party Animal trait and has finished iterating through spots.")

			if(!joined_late && length(valid_stools) > 0) // We got special late-join handling
				var/obj/stool/stool = pick(valid_stools)
				if (stool)
					var/list/spawn_range = orange(1, get_turf(stool)) // Skip the actual stool
					for (var/turf/spot in spawn_range)
						if (!jpsTurfPassable(spot, source=get_turf(stool), passer=H)) // Make sure we can walk there
							continue
						if (locate(/mob/living/carbon/human) in spot)
							continue
						src.set_loc(spot)
						logTheThing(LOG_STATION, src, "has the Party Animal trait and spawns at [log_loc(spot)]")
						break

				// Place clutter near the rascal
				for (var/turf/spot in range(1, H))
					if (typeinfo.clutter_count >= nround(typeinfo.num_bar_turfs * 0.5))
						break
					if (!jpsTurfPassable(spot, source=get_turf(H), passer=H)) // Make sure we can walk there
						continue
					if (prob(50)) // Roll for random items
						var/picked = pick(typeinfo.allowed_items)
						if(picked)
							new picked(spot)
							typeinfo.clutter_count++
					if (prob(50)) // Roll for random debris
						var/picked = pick(typeinfo.allowed_debris)
						if (picked)
							new picked(spot)
							typeinfo.clutter_count++

			// Do the alcohol stuff
			var/alcohol_amount = rand(0, 60)
			H.reagents.add_reagent("ethanol", alcohol_amount) // Party hardy

			if (alcohol_amount >= 20 || joined_late) // Chance to spawn HAMMERED
				H.l_hand?.AddComponent(/datum/component/glued, H, T.spawn_delay, T.spawn_delay / 2)
				H.r_hand?.AddComponent(/datum/component/glued, H, T.spawn_delay, T.spawn_delay / 2)
				H.setStatus("resting", INFINITE_STATUS)
				H.setStatus("unconscious", T.spawn_delay)
				H.force_laydown_standup()

			if (H.head)
				H.stow_in_available(H.head)
			H.equip_if_possible(new /obj/item/clothing/head/party/random(H), SLOT_HEAD) // hehehe funny hat

		// This should be here (overriding most other things), probably? - #11215
		// Vampires spawning in the chapel is bad. :(
		if (istype(src.loc.loc, /area/station/chapel) && (src.mind.special_role == ROLE_VAMPIRE))
			src.set_loc(pick_landmark(LANDMARK_LATEJOIN))

		if (prob(10) && islist(random_pod_codes) && length(random_pod_codes))
			var/obj/machinery/vehicle/V = pick(random_pod_codes)
			random_pod_codes -= V
			if (V?.lock?.code)
				boutput(src, SPAN_NOTICE("The unlock code to your pod ([V]) is: [V.lock.code]"))
				if (src.mind)
					src.mind.store_memory("The unlock code to your pod ([V]) is: [V.lock.code]")

		var/mob/current_mob = src // this proc does the sin of overwriting src, but it turns out that SPAWN doesn't care and uses the OG src, hence this
		SPAWN(0)
			if(!QDELETED(current_mob))
				current_mob.set_clothing_icon_dirty()
			sleep(0.1 SECONDS)
			if(!QDELETED(current_mob))
				current_mob.update_icons_if_needed()

		if (src.traitHolder?.hasTrait("jailbird"))
			create_jailbird_wanted_poster(H)

		if (joined_late == 1 && map_settings && map_settings.arrivals_type != MAP_SPAWN_CRYO && JOB.radio_announcement)
			if (src.mind && src.mind.assigned_role) //ZeWaka: I'm adding this back here because hell if I know where it goes.
				for (var/obj/machinery/computer/announcement/A as anything in machine_registry[MACHINES_ANNOUNCEMENTS])
					if (!A.status && A.announces_arrivals)
						if (src.mind.assigned_role == "MODE") //ZeWaka: Fix for alien invasion dudes. Possibly not needed now.
							return
						else
							A.announce_arrival(src)

		//Equip_Bank_Purchase AFTER special_setup() call, because they might no longer be a human after that
	//this was previously indented in the ishuman() block, but I don't think it needs to be - Amylizzle
	SPAWN(0)
		if (possible_new_mob)
			var/mob/living/newmob = possible_new_mob
			newmob.Equip_Bank_Purchase(newmob.mind.purchased_bank_item)
		else
			src.Equip_Bank_Purchase(src.mind?.purchased_bank_item)

	return

/// Equip items from sensory traits
/mob/living/carbon/human/proc/equip_sensory_items()
	if (src.traitHolder.hasTrait("blind"))
		if (src.glasses)
			src.stow_in_available(src.glasses)
		src.equip_if_possible(new /obj/item/clothing/glasses/visor(src), SLOT_GLASSES)
	else // if you're blind and have missing eyes, you don't get a cool patch sorry
		var/missing_left = src.traitHolder.hasTrait("eye_missing_left")
		var/missing_right =  src.traitHolder.hasTrait("eye_missing_right")
		if (src.glasses && (missing_left || missing_right))
			src.stow_in_available(src.glasses)
		if (missing_left && missing_right)
			src.equip_if_possible(new /obj/item/clothing/glasses/blindfold(src), SLOT_GLASSES)
		else if (missing_left)
			var/obj/item/clothing/glasses/eyepatch/eyepatch = new(src)
			eyepatch.icon_state = "eyepatch-L"
			eyepatch.block_eye = "L"
			src.equip_if_possible(eyepatch, SLOT_GLASSES)
		else if (missing_right)
			src.equip_if_possible(new /obj/item/clothing/glasses/eyepatch(src), SLOT_GLASSES)

	if (src.traitHolder.hasTrait("shortsighted"))
		if (src.glasses)
			src.stow_in_available(src.glasses)
		src.equip_if_possible(new /obj/item/clothing/glasses/regular(src), SLOT_GLASSES)
	if (src.traitHolder.hasTrait("deaf"))
		if (src.ears)
			src.stow_in_available(src.ears)
		src.equip_if_possible(new /obj/item/device/radio/headset/deaf(src), SLOT_EARS)

/**
Equip items from body traits.

 * @param extended_tank - If TRUE, the mob will spawn with a pocket extended tank instead of a mini tank.

**/
/mob/living/carbon/human/proc/equip_body_traits(extended_tank=FALSE)
	if (src.traitHolder && src.traitHolder.hasTrait("plasmalungs"))
		if (src.wear_mask && !(src.wear_mask.c_flags & MASKINTERNALS)) //drop non-internals masks
			src.stow_in_available(src.wear_mask)

		if(!src.wear_mask)
			src.equip_if_possible(new /obj/item/clothing/mask/breath(src), SLOT_WEAR_MASK)
		var/obj/item/tank/good_air
		if (extended_tank)
			good_air = new /obj/item/tank/pocket/extended/plasma(src)
			// TODO: antagonists spawn tanks in the left pocket by practice(copy/paste), not pattern
			if (istype(src.l_store, /obj/item/tank/pocket/extended/oxygen))
				qdel(src.l_store)
			src.equip_if_possible(good_air, SLOT_L_STORE)
		else
			good_air = new /obj/item/tank/mini/plasma(src)
			src.put_in_hand_or_stow(good_air, delete_item=FALSE)
		if (!good_air.using_internal())//set tank ON
			good_air.toggle_valve()

/mob/living/carbon/human/proc/Equip_Job_Slots(var/datum/job/JOB)
	equip_job_items(JOB, src)
	if (JOB.slot_back)
		if (src.back?.storage)
			if(JOB.receives_disk)
				var/obj/item/disk/data/floppy/D
				if(ispath(JOB.receives_disk))
					D = new JOB.receives_disk(src)
				else
					D = new /obj/item/disk/data/floppy(src)
				src.equip_if_possible(D, SLOT_IN_BACKPACK)
				var/datum/computer/file/clone/R = new
				R.fields["ckey"] = ckey(src.key)
				R.fields["name"] = src.real_name
				R.fields["id"] = copytext("\ref[src.mind]", 4, 12)

				var/datum/bioHolder/B = new/datum/bioHolder(null)
				B.CopyOther(src.bioHolder)

				R.fields["holder"] = B

				R.fields["abilities"] = null
				if (src.abilityHolder)
					var/datum/abilityHolder/A = src.abilityHolder.deepCopy()
					R.fields["abilities"] = A

				R.fields["defects"] = src.cloner_defects.copy()

				SPAWN(0)
					if(!isnull(src.traitHolder))
						R.fields["traits"] = src.traitHolder.copy()

				R.fields["imp"] = null
				R.fields["mind"] = src.mind
				D.root.add_file(R)

				D.name = "data disk - '[src.real_name]'"

			if(JOB.badge)
				var/obj/item/clothing/suit/security_badge/badge = new JOB.badge(src)
				if (!src.equip_if_possible(badge, SLOT_WEAR_SUIT))
					src.equip_if_possible(badge, SLOT_IN_BACKPACK)
				badge.badge_owner_name = src.real_name
				badge.badge_owner_job = src.job

	if (src.traitHolder?.hasTrait("pilot"))
		var/obj/item/tank/extra_air
		if (src.traitHolder.hasTrait("plasmalungs"))
			extra_air = new /obj/item/tank/mini/plasma(src.loc)
		else
			extra_air = new /obj/item/tank/mini/oxygen(src.loc)
		src.force_equip(extra_air, SLOT_IN_BACKPACK, TRUE)
		#ifdef UNDERWATER_MAP
		var/obj/item/clothing/suit/space/diving/civilian/SSW = new /obj/item/clothing/suit/space/diving/civilian(src.loc)
		src.force_equip(SSW, SLOT_IN_BACKPACK, TRUE)
		var/obj/item/clothing/head/helmet/space/engineer/diving/civilian/SHW = new /obj/item/clothing/head/helmet/space/engineer/diving/civilian(src.loc)
		src.force_equip(SHW, SLOT_IN_BACKPACK, TRUE)
		#else
		var/obj/item/clothing/suit/space/emerg/SSS = new /obj/item/clothing/suit/space/emerg(src.loc)
		src.force_equip(SSS, SLOT_IN_BACKPACK, TRUE)
		var/obj/item/clothing/head/emerg/SHS = new /obj/item/clothing/head/emerg(src.loc)
		src.force_equip(SHS, SLOT_IN_BACKPACK, TRUE)
		#endif

		if (src.wear_mask && !(src.wear_mask.c_flags & MASKINTERNALS)) //drop non-internals masks
			src.stow_in_available(src.wear_mask)
		if(!src.wear_mask)
			src.equip_new_if_possible(/obj/item/clothing/mask/breath, SLOT_WEAR_MASK)

		var/obj/item/device/gps/GPSDEVICE = new /obj/item/device/gps(src.loc)
		src.force_equip(GPSDEVICE, SLOT_IN_BACKPACK, TRUE)
		var/obj/item/device/pda2/pda = locate() in src
		src.u_equip(pda)
		qdel(pda)

	var/T = pick(trinket_safelist)
	var/obj/item/trinket = null

	if (src.traitHolder && src.traitHolder.hasTrait("pawnstar"))
		trinket = null //You better stay null, you hear me!
	else if (src.traitHolder && src.traitHolder.hasTrait("bald"))
		trinket = src.create_wig()
	else if (src.traitHolder && src.traitHolder.hasTrait("loyalist"))
		trinket = new/obj/item/clothing/head/NTberet(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("petasusaphilic"))
		var/picked = pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats))
		trinket = new picked(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("conspiracytheorist"))
		trinket = new/obj/item/clothing/head/tinfoil_hat
	else if (src.traitHolder && src.traitHolder.hasTrait("beestfriend"))
		if (prob(15))
			trinket = new/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy(src)
		else
			trinket = new/obj/item/reagent_containers/food/snacks/ingredient/egg/bee(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("petperson"))
		var/obj/item/pet_carrier/carrier = new/obj/item/pet_carrier(src)
		var/picked = pick(filtered_concrete_typesof(/mob/living/critter/small_animal/, GLOBAL_PROC_REF(filter_carrier_pets)))
		var/mob/living/critter/small_animal/pet = new picked(src)
		pet.ai_type = /datum/aiHolder/wanderer
		pet.ai = new pet.ai_type(pet)
		pet.aggressive = FALSE
		pet.randomize_name()
		pet.ai_retaliate_persistence = RETALIATE_ONCE
		carrier.trap_mob(pet, src)
		trinket = carrier
	else if (src.traitHolder && src.traitHolder.hasTrait("lunchbox"))
		var/random_lunchbox_path = pick(childrentypesof(/obj/item/storage/lunchbox))
		trinket = new random_lunchbox_path(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("allergic"))
		trinket = new/obj/item/reagent_containers/emergency_injector/epinephrine(src)
	else if (src.traitHolder && src.traitHolder.hasTrait("wheelchair"))
		var/obj/stool/chair/comfy/wheelchair/the_chair = new /obj/stool/chair/comfy/wheelchair(get_turf(src))
		trinket = the_chair
		the_chair.buckle_in(src, src)
	else
		trinket = new T(src)

	var/list/obj/item/trinkets_to_equip = list()

	if (trinket)
		src.trinket = get_weakref(trinket)
		trinket.name = "[src.real_name][pick_string("trinkets.txt", "modifiers")] [trinket.name]"
		trinket.quality = rand(5,80)
		trinkets_to_equip += trinket

	// fake trinket-like zippo lighter for the smoker trait
	if (src.traitHolder && src.traitHolder.hasTrait("smoker"))
		var/obj/item/device/light/zippo/smoker_zippo = new(src)
		smoker_zippo.name = "[src.real_name][pick_string("trinkets.txt", "modifiers")] [smoker_zippo.name]"
		smoker_zippo.quality = rand(5,80)
		trinkets_to_equip += smoker_zippo

	for (var/obj/item/I in trinkets_to_equip)
		var/equipped = 0
		if (src.back?.storage && src.equip_if_possible(I, SLOT_IN_BACKPACK))
			equipped = 1
		else if (src.belt?.storage && src.equip_if_possible(I, SLOT_IN_BELT))
			equipped = 1
		if (!equipped)
			if (!src.l_store && src.equip_if_possible(I, SLOT_L_STORE))
				equipped = 1
			else if (!src.r_store && src.equip_if_possible(I, SLOT_R_STORE))
				equipped = 1
			else if (!src.l_hand && src.equip_if_possible(I, SLOT_L_HAND))
				equipped = 1
			else if (!src.r_hand && src.equip_if_possible(I, SLOT_R_HAND))
				equipped = 1

			if (!equipped) // we've tried most available storage solutions here now so uh just put it on the ground
				I.set_loc(get_turf(src))

	src.equip_body_traits()

	// Special mutantrace items
	if (src.traitHolder && src.traitHolder.hasTrait("pug"))
		src.put_in_hand_or_stow(new /obj/item/reagent_containers/food/snacks/cookie/dog, delete_item = FALSE)
	else if (src.traitHolder && src.traitHolder.hasTrait("skeleton"))
		src.put_in_hand_or_stow(new /obj/item/joint_wax, delete_item = FALSE)

	src.equip_sensory_items()

/mob/living/carbon/human/proc/spawnId(var/datum/job/JOB)
#ifdef DEBUG_EVERYONE_GETS_CAPTAIN_ID
	JOB = new /datum/job/command/captain
#endif
	var/obj/item/card/id/C = null
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

			var/datum/db_record/B = FindBankAccountByName(src.real_name)
			if (B?["name"])
				B["name"] = realName

		C.registered = realName
		C.assignment = JOB.name
		C.name = "[C.registered]'s ID Card ([C.assignment])"
		C.access = JOB.access.Copy()
		C.pronouns = src.get_pronouns()

		if(!src.equip_if_possible(C, SLOT_WEAR_ID))
			src.equip_if_possible(C, SLOT_IN_BACKPACK)

		if(src.pin)
			C.pin = src.pin

	for (var/obj/item/device/pda2/PDA in src.contents)
		PDA.owner = src.real_name
		PDA.ownerAssignment = JOB.name
		PDA.name = "PDA-[src.real_name]"

		if(src.mind)
			src.mind.originalPDA = PDA

	boutput(src, SPAN_NOTICE("Your pin to your ID is: [C.pin]"))
	if (src.mind)
		src.mind.store_memory("Your pin to your ID is: [C.pin]")
	src.mind?.remembered_pin = C.pin

	if (JOB.wages > 0)
		var/cashModifier = 1
		if (src.traitHolder && src.traitHolder.hasTrait("pawnstar"))
			cashModifier = 1.25

		var/obj/item/currency/spacecash/S = new /obj/item/currency/spacecash
		S.setup(src,round(JOB.wages * cashModifier))

		if (isnull(src.get_slot(SLOT_R_STORE)))
			src.equip_if_possible(S, SLOT_R_STORE)
		else if (isnull(src.get_slot(SLOT_L_STORE)))
			src.equip_if_possible(S, SLOT_L_STORE)
		else
			src.equip_if_possible(S, SLOT_IN_BACKPACK)
	else
		var/shitstore = rand(1,3)
		switch(shitstore)
			if(1)
				src.equip_new_if_possible(/obj/item/pen, SLOT_R_STORE)
			if(2)
				src.equip_new_if_possible(/obj/item/reagent_containers/food/drinks/water, SLOT_R_STORE)


/mob/living/carbon/human/proc/JobEquipSpawned(rank, no_special_spawn)
	var/datum/job/JOB = find_job_in_controller_by_string(rank)
	if (!JOB)
		boutput(src, SPAN_ALERT("<b>UH OH, the game couldn't find your job to set it up! Report this to a coder.</b>"))
		return

	equip_job_items(JOB, src)

	if (ishuman(src) && JOB.spawn_id)
		src.spawnId(JOB)

	JOB.special_setup(src, no_special_spawn)

	update_clothing()
	update_inhands()

	return

//////////////////////////////////////////////
// cogwerks - personalized trinkets project //
/////////////////////////////////////////////

var/list/trinket_safelist = list(
	/obj/item/basketball,
	/obj/item/instrument/bikehorn,
	/obj/item/brick,
	/obj/item/clothing/glasses/eyepatch,
	/obj/item/clothing/glasses/regular,
	/obj/item/clothing/glasses/sunglasses/tanning,
	/obj/item/clothing/gloves/boxing,
	/obj/item/clothing/mask/horse_mask,
	/obj/item/clothing/mask/clown_hat,
	/obj/item/clothing/head/cowboy,
	/obj/item/clothing/shoes/cowboy,
	/obj/item/clothing/shoes/moon,
	/obj/item/clothing/suit/sweater,
	/obj/item/clothing/suit/sweater/red,
	/obj/item/clothing/suit/sweater/green,
	/obj/item/clothing/suit/sweater/grandma,
	/obj/item/clothing/under/shorts,
	/obj/item/clothing/under/suit/pinstripe,
	/obj/item/cigpacket,
	/obj/item/coin,
	/obj/item/crowbar,
	/obj/item/pen/crayon/lipstick,
	/obj/item/dice,
	/obj/item/dice/d20,
	/obj/item/device/light/flashlight,
	/obj/item/device/key/random,
	/obj/item/extinguisher,
	/obj/item/firework,
	/obj/item/football,
	/obj/item/stamped_bullion,
	/obj/item/instrument/harmonica,
	/obj/item/horseshoe,
	/obj/item/kitchen/utensil/knife,
	/obj/item/raw_material/rock,
	/obj/item/pen/fancy,
	/obj/item/pen/odd,
	/obj/item/plant/herb/cannabis/spawnable,
	/obj/item/razor_blade,
	/obj/item/rubberduck,
	/obj/item/instrument/saxophone,
	/obj/item/scissors,
	/obj/item/screwdriver,
	/obj/item/skull,
	/obj/item/stamp,
	/obj/item/instrument/vuvuzela,
	/obj/item/wrench,
	/obj/item/device/light/zippo,
	/obj/item/device/speech_pro,
	/obj/item/reagent_containers/food/drinks/bottle/beer,
	/obj/item/reagent_containers/food/drinks/bottle/vintage,
	/obj/item/reagent_containers/food/drinks/bottle/vodka,
	/obj/item/reagent_containers/food/drinks/bottle/rum,
	/obj/item/reagent_containers/food/drinks/bottle/hobo_wine/safe,
	/obj/item/reagent_containers/food/snacks/burger,
	/obj/item/reagent_containers/food/snacks/burger/cheeseburger,
	/obj/item/reagent_containers/food/snacks/burger/moldy,
	/obj/item/reagent_containers/food/snacks/candy/chocolate,
	/obj/item/reagent_containers/food/snacks/chips,
	/obj/item/reagent_containers/food/snacks/cookie,
	/obj/item/reagent_containers/food/snacks/ingredient/egg,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/bee,
	/obj/item/reagent_containers/food/snacks/plant/apple,
	/obj/item/reagent_containers/food/snacks/plant/banana,
	/obj/item/reagent_containers/food/snacks/plant/potato,
	/obj/item/reagent_containers/food/snacks/sandwich/pb,
	/obj/item/reagent_containers/food/snacks/sandwich/cheese,
	/obj/item/reagent_containers/syringe/krokodil,
	/obj/item/reagent_containers/syringe/morphine,
	/obj/item/reagent_containers/patch/LSD,
	/obj/item/reagent_containers/patch/lsd_bee,
	/obj/item/reagent_containers/patch/nicotine,
	/obj/item/reagent_containers/glass/bucket,
	/obj/item/reagent_containers/glass/beaker,
	/obj/item/reagent_containers/food/drinks/drinkingglass,
	/obj/item/reagent_containers/food/drinks/drinkingglass/shot,
	/obj/item/storage/pill_bottle/bathsalts,
	/obj/item/storage/pill_bottle/catdrugs,
	/obj/item/storage/pill_bottle/crank,
	/obj/item/storage/pill_bottle/cyberpunk,
	/obj/item/storage/pill_bottle/methamphetamine,
	/obj/item/spraybottle,
	/obj/item/staple_gun,
	/obj/item/clothing/head/NTberet,
	/obj/item/clothing/head/biker_cap,
	/obj/item/clothing/head/black,
	/obj/item/clothing/head/blue,
	/obj/item/clothing/head/chav,
	/obj/item/clothing/head/det_hat,
	/obj/item/clothing/head/green,
	/obj/item/clothing/head/helmet/hardhat,
	/obj/item/clothing/head/merchant_hat,
	/obj/item/clothing/head/mj_hat,
	/obj/item/clothing/head/red,
	/obj/item/clothing/head/that,
	/obj/item/clothing/head/wig,
	/obj/item/clothing/head/turban,
	/obj/item/dice/magic8ball,
	/obj/item/reagent_containers/food/drinks/mug/random_color,
	/obj/item/reagent_containers/food/drinks/skull_chalice,
	/obj/item/pen/marker/random,
	/obj/item/pen/crayon/random,
	/obj/item/clothing/gloves/yellow/unsulated,
	/obj/item/reagent_containers/food/snacks/fortune_cookie,
	/obj/item/instrument/triangle,
	/obj/item/instrument/tambourine,
	/obj/item/instrument/cowbell,
	/obj/item/toy/plush/small/bee,
	/obj/item/paper/book/from_file/the_trial,
	/obj/item/paper/book/from_file/deep_blue_sea,
	/obj/item/clothing/suit/bedsheet/cape/red,
	/obj/item/disk/data/cartridge/clown,
	/obj/item/clothing/mask/cigarette/cigar,
	/obj/item/device/light/sparkler,
	/obj/item/toy/sponge_capsule,
	/obj/item/reagent_containers/food/snacks/plant/pear,
	/obj/item/reagent_containers/food/snacks/donkpocket/honk/warm,
	/obj/item/seed/alien,
	/obj/item/boarvessel,
	/obj/item/boarvessel/forgery
)
