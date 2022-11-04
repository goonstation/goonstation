//some of this stuff is shamelessly based from savefile.dm. yay!! blame MBC if it breaks.

datum/job_controller/proc/savefile_path(key)
	return "data/admin_custom_job_saves/[src.load_another_ckey ? src.load_another_ckey : ckey(key)].sav"

datum/job_controller/proc/savefile_path_exists(key)
	var/path = savefile_path(key)
	if (!fexists(path))
		return 0
	return path

datum/job_controller/proc/savefile_delete(key, profileNum=1)
	fdel(savefile_path(key))

datum/job_controller/proc/savefile_unlock(client/user)
	if (savefile_path_exists(user.ckey))
		var/savefile/F = new /savefile(src.savefile_path(user.ckey), -1)
		F.Unlock()

datum/job_controller/proc/savefile_version_pass(client/user)
	var/version = null
	var/savefile/F = new /savefile(src.savefile_path(user.ckey), -1)
	F["version"] >> version
	if (isnull(version) || version < CUSTOMJOB_SAVEFILE_VERSION_MIN || version > CUSTOMJOB_SAVEFILE_VERSION_MAX)
		if (!src.load_another_ckey)
			src.savefile_delete(user)
		return 0
	return 1

datum/job_controller/proc/savefile_save(client/user, profileNum=1)
	profileNum = clamp(profileNum, 1, CUSTOMJOB_SAVEFILE_PROFILES_MAX)
	var/savefile/F = new /savefile(src.savefile_path(user.ckey), -1)
	F.Lock(-1)

	F["version"] << CUSTOMJOB_SAVEFILE_VERSION_MAX
	F["[profileNum]_saved"] << 1
	F["[profileNum]_job_name"] << src.job_creator.name
	F["[profileNum]_wages"] << src.job_creator.wages
	F["[profileNum]_limit"] << src.job_creator.limit
	F["[profileNum]_mob_type"] << src.job_creator.mob_type
	F["[profileNum]_slot_head"] << src.job_creator.slot_head
	F["[profileNum]_slot_mask"] << src.job_creator.slot_mask
	F["[profileNum]_slot_ears"] << src.job_creator.slot_ears
	F["[profileNum]_slot_eyes"] << src.job_creator.slot_eyes
	F["[profileNum]_slot_glov"] << src.job_creator.slot_glov
	F["[profileNum]_slot_foot"] << src.job_creator.slot_foot
	F["[profileNum]_slot_card"] << src.job_creator.slot_card
	F["[profileNum]_slot_jump"] << src.job_creator.slot_jump
	F["[profileNum]_slot_suit"] << src.job_creator.slot_suit
	F["[profileNum]_slot_back"] << src.job_creator.slot_back
	F["[profileNum]_slot_belt"] << src.job_creator.slot_belt
	F["[profileNum]_slot_poc1"] << src.job_creator.slot_poc1
	F["[profileNum]_slot_poc2"] << src.job_creator.slot_poc2
	F["[profileNum]_slot_lhan"] << src.job_creator.slot_lhan
	F["[profileNum]_slot_rhan"] << src.job_creator.slot_rhan
	F["[profileNum]_access"] << src.job_creator.access
	F["[profileNum]_change_name_on_spawn"] << src.job_creator.change_name_on_spawn
	F["[profileNum]_special_spawn_location"] << src.job_creator.special_spawn_location
	F["[profileNum]_bio_effects"] << src.job_creator.bio_effects
	F["[profileNum]_objective"] << src.job_creator.objective
	F["[profileNum]_receives_implant"] << src.job_creator.receives_implant
	F["[profileNum]_items_in_backpack"] << src.job_creator.items_in_backpack
	F["[profileNum]_items_in_belt"] << src.job_creator.items_in_belt
	F["[profileNum]_announce_on_join"] << src.job_creator.announce_on_join
	F["[profileNum]_add_to_manifest"] << src.job_creator.add_to_manifest
	F["[profileNum]_radio_announcement"] << src.job_creator.radio_announcement
	F["[profileNum]_spawn_id"] << src.job_creator.spawn_id
	F["[profileNum]_starting_mutantrace"] << src.job_creator.starting_mutantrace

	return 1

datum/job_controller/proc/savefile_load(client/user, var/profileNum = 1)
	if (!savefile_path_exists(user.ckey))
		return 0

	if (!src.savefile_version_pass(user))
		return 0

	var/path = savefile_path(user.ckey)

	profileNum = clamp(profileNum, 1, CUSTOMJOB_SAVEFILE_PROFILES_MAX)

	var/savefile/F = new /savefile(path, -1)

	var/sanity_check = null
	F["[profileNum]_saved"] >> sanity_check
	if (isnull(sanity_check))
		for (var/i=1, i <= CUSTOMJOB_SAVEFILE_PROFILES_MAX, i++)
			F["[i]_saved"] >> sanity_check
			if (!isnull(sanity_check))
				break
		if (isnull(sanity_check))
			fdel(path)
		return 0

	F["[profileNum]_job_name"] >> src.job_creator.name
	F["[profileNum]_wages"] >> src.job_creator.wages
	F["[profileNum]_limit"] >> src.job_creator.limit
	F["[profileNum]_mob_type"] >> src.job_creator.mob_type
	F["[profileNum]_slot_head"] >> src.job_creator.slot_head
	F["[profileNum]_slot_mask"] >> src.job_creator.slot_mask
	F["[profileNum]_slot_ears"] >> src.job_creator.slot_ears
	F["[profileNum]_slot_eyes"] >> src.job_creator.slot_eyes
	F["[profileNum]_slot_glov"] >> src.job_creator.slot_glov
	F["[profileNum]_slot_foot"] >> src.job_creator.slot_foot
	F["[profileNum]_slot_card"] >> src.job_creator.slot_card
	F["[profileNum]_slot_jump"] >> src.job_creator.slot_jump
	F["[profileNum]_slot_suit"] >> src.job_creator.slot_suit
	F["[profileNum]_slot_back"] >> src.job_creator.slot_back
	F["[profileNum]_slot_belt"] >> src.job_creator.slot_belt
	F["[profileNum]_slot_poc1"] >> src.job_creator.slot_poc1
	F["[profileNum]_slot_poc2"] >> src.job_creator.slot_poc2
	F["[profileNum]_slot_lhan"] >> src.job_creator.slot_lhan
	F["[profileNum]_slot_rhan"] >> src.job_creator.slot_rhan
	F["[profileNum]_access"] >> src.job_creator.access
	F["[profileNum]_change_name_on_spawn"] >> src.job_creator.change_name_on_spawn
	F["[profileNum]_special_spawn_location"] >> src.job_creator.special_spawn_location
	F["[profileNum]_bio_effects"] >> src.job_creator.bio_effects
	F["[profileNum]_objective"] >> src.job_creator.objective
	F["[profileNum]_receives_implant"] >> src.job_creator.receives_implant
	F["[profileNum]_items_in_backpack"] >> src.job_creator.items_in_backpack
	if(isnull(src.job_creator.items_in_backpack))
		src.job_creator.items_in_backpack = list()
	F["[profileNum]_items_in_belt"] >> src.job_creator.items_in_belt
	if(isnull(src.job_creator.items_in_belt))
		src.job_creator.items_in_belt = list()
	F["[profileNum]_announce_on_join"] >> src.job_creator.announce_on_join
	F["[profileNum]_add_to_manifest"] >> src.job_creator.add_to_manifest
	F["[profileNum]_radio_announcement"] >> src.job_creator.radio_announcement
	F["[profileNum]_spawn_id"] >> src.job_creator.spawn_id
	F["[profileNum]_starting_mutantrace"] >> src.job_creator.starting_mutantrace




	return 1

datum/job_controller/proc/savefile_get_job_name(client/user, var/profileNum = 1)

	if (!savefile_path_exists(user.ckey))
		return 0

	var/path = savefile_path(user.ckey)
	profileNum = clamp(profileNum, 1, CUSTOMJOB_SAVEFILE_PROFILES_MAX)

	var/savefile/F = new /savefile(path, -1)

	var/job_name = null
	F["[profileNum]_job_name"] >> job_name

	if (isnull(job_name))
		return 0

	return job_name
