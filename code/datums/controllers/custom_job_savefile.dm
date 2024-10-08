/datum/job_controller/proc/convert_to_cloudsave(client/user)
	if(!user || IsGuestKey( user.key ))
		return FALSE
	//convert cloudsave save to cloudsave data a a a a aaaaaaaaaa
	for(var/i in 1 to CUSTOMJOB_SAVEFILE_PROFILES_MAX)
		var/save = user.player.cloudSaves.getSave("custom_job_[i]")
		if(save)
			user.player.cloudSaves.putData("custom_job_[i]", save)
			user.player.cloudSaves.deleteSave("custom_job_[i]")

	//convert old savefiles to cloudsave
	var/path = "data/admin_custom_job_saves/[user.ckey].sav"
	if (!fexists(path))
		return FALSE

	var/savefile/F = new /savefile(path, -1)
	for(var/i in 1 to CUSTOMJOB_SAVEFILE_PROFILES_MAX)
		var/saved = null
		var/datum/job/created/converter = new()
		F["[i]_saved"] >> saved
		if(saved)//there's a job to convert here.
			F["[i]_job_name"] >> converter.name
			F["[i]_wages"] >> converter.wages
			F["[i]_limit"] >> converter.limit
			F["[i]_mob_type"] >> converter.mob_type
			F["[i]_slot_head"] >> converter.slot_head
			F["[i]_slot_mask"] >> converter.slot_mask
			F["[i]_slot_ears"] >> converter.slot_ears
			F["[i]_slot_eyes"] >> converter.slot_eyes
			F["[i]_slot_glov"] >> converter.slot_glov
			F["[i]_slot_foot"] >> converter.slot_foot
			F["[i]_slot_card"] >> converter.slot_card
			F["[i]_slot_jump"] >> converter.slot_jump
			F["[i]_slot_suit"] >> converter.slot_suit
			F["[i]_slot_back"] >> converter.slot_back
			F["[i]_slot_belt"] >> converter.slot_belt
			F["[i]_slot_poc1"] >> converter.slot_poc1
			F["[i]_slot_poc2"] >> converter.slot_poc2
			F["[i]_slot_lhan"] >> converter.slot_lhan
			F["[i]_slot_rhan"] >> converter.slot_rhan
			F["[i]_access"] >> converter.access
			F["[i]_change_name_on_spawn"] >> converter.change_name_on_spawn
			converter.special_spawn_location = null
			var/maybe_spawn_loc = null
			F["[i]_special_spawn_location"] >> maybe_spawn_loc
			if(istext(maybe_spawn_loc))
				converter.special_spawn_location = maybe_spawn_loc
			else
				var/list/maybe_coords = null
				F["[i]_special_spawn_location_coords"] >> maybe_coords
				if(islist(maybe_coords))
					converter.special_spawn_location = locate(maybe_coords[1], maybe_coords[2], maybe_coords[3])
				else
					F["[i]_special_spawn_location"] << null
			F["[i]_bio_effects"] >> converter.bio_effects
			F["[i]_objective"] >> converter.objective
			// backwards compatibility
			if(F["[i]_receives_implant"])
				var/obj/item/implant/I = null
				F["[i]_receives_implant"] >> I
				converter.receives_implants = list(I)
			if(F["[i]_receives_implants"])
				F["[i]_receives_implants"] >> converter.receives_implants
			F["[i]_items_in_backpack"] >> converter.items_in_backpack
			if(isnull(converter.items_in_backpack))
				converter.items_in_backpack = list()
			F["[i]_items_in_belt"] >> converter.items_in_belt
			if(isnull(converter.items_in_belt))
				converter.items_in_belt = list()
			F["[i]_announce_on_join"] >> converter.announce_on_join
			F["[i]_add_to_manifest"] >> converter.add_to_manifest
			F["[i]_radio_announcement"] >> converter.radio_announcement
			F["[i]_spawn_id"] >> converter.spawn_id
			F["[i]_starting_mutantrace"] >> converter.starting_mutantrace

			//build new savefile
			var/savefile/F2 = savefile_save(converter)
			F2["profile_number"] << i
			var/exported = F2.ExportText()
			user.player.cloudSaves.putData("custom_job_[i]", exported)
	fdel(path) //once we're in cloudland, nuke it



/datum/job_controller/proc/savefile_save(datum/job/created/toSave)
	RETURN_TYPE(/savefile)
	var/savefile/out = new/savefile
	out["version"] << CUSTOMJOB_SAVEFILE_VERSION_MAX
	out["name"] << toSave.name
	out["job"] << toSave
	return out

/datum/job_controller/proc/savefile_load(client/user, savefile/SF)
	RETURN_TYPE(/datum/job/created)
	var/datum/job/created/loaded = new
	SF["job"] >> loaded
	return loaded

/datum/job_controller/proc/savefile_export(client/user)
	var/savefile/message = src.savefile_save(src.job_creator)
	var/fname
	message["name"] >> fname
	fname = "[user.ckey]_[fname].sav"
	if(fexists(fname))
		fdel(fname)
	var/F = file(fname)
	message.ExportText("/", F)
	user << ftp(F, fname)
	SPAWN(15 SECONDS)
		var/tries = 0
		while((fdel(fname) == 0) && tries++ < 10)
			sleep(30 SECONDS)


/datum/job_controller/proc/savefile_import(client/user)
	var/F = input(user) as file|null
	if(!F)
		return FALSE
	var/savefile/message = new()
	message.ImportText("/", file2text(F))
	job_creator = savefile_load(user, message)
	return TRUE


/datum/job_controller/proc/cloudsave_save(client/user, profileNum)
	if (user)
		if (IsGuestKey( user.key ))
			return FALSE

	var/savefile/save = src.savefile_save(src.job_creator)
	save["profile_number"] << profileNum
	var/exported = save.ExportText()

	user.player.cloudSaves.putData("custom_job_[profileNum]", exported)
	return TRUE


/datum/job_controller/proc/cloudsave_load(client/user, profileNum)
	if (user)
		if (IsGuestKey(user.key))
			return FALSE

	var/cloudSaveData = user.player.cloudSaves.getData("custom_job_[profileNum]")

	var/savefile/save = new
	save.ImportText( "/", cloudSaveData )
	var/datum/job/created/loaded = src.savefile_load(user, save)
	if(loaded)
		src.job_creator = loaded
		return TRUE
	else
		return FALSE

/datum/job_controller/proc/savefile_get_job_names(client/user)
	RETURN_TYPE(/list)
	var/savefile/F = new /savefile

	var/list/job_names = list()
	for(var/i in 1 to CUSTOMJOB_SAVEFILE_PROFILES_MAX)
		var/save = user.player.cloudSaves.getData("custom_job_[i]")
		if(save)
			F.ImportText("/", save)
			var/job_name = null
			F["name"] >> job_name
			job_names += job_name
		else
			job_names += null
	return job_names
