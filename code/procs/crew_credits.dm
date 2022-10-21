var/global/crew_creds = null

/chui/window/crew_credits
	name = "Crew Credits"
	windowSize = "500x500"
	GetBody()
		if(crew_creds)
			logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] returning already-generated crew credits")

			return crew_creds

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] starting crew credits generation")

		var/list/datum/mind/round_antags = list()
		var/list/datum/mind/round_captains = list()
		var/list/datum/mind/round_security = list()
		var/list/datum/mind/round_medical = list()
		var/list/datum/mind/round_science = list()
		var/list/datum/mind/round_engineering = list()
		var/list/datum/mind/round_civilian = list()
		var/list/datum/mind/round_other = list()

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] processing all minds...")
		for(var/datum/mind/M in ticker.minds)

			// Antagonist?
			if(M.special_role && !("Faustian" in M.special_role))
				round_antags.Add(M)
				continue
			if(!M.assigned_role)
				continue
			switch(M.assigned_role)
				// Captain?
				if("Captain")
					round_captains.Add(M)
					continue

				// Security?
				if("Head of Security","Security Officer","Detective","Vice Officer","Part-time Vice Officer","Security Assistant","Lawyer","Nanotrasen Security Consultant","Nanotrasen Special Operative")
					round_security.Add(M)
					continue

				// Medical?
				if("Medical Director","Medical Doctor","Roboticist","Geneticist","Pharmacist","Psychiatrist","Psychologist","Psychotherapist","Therapist","Counselor","Life Coach")
					round_medical.Add(M)
					continue

				// Science?
				if("Research Director","Scientist","Test Subject")
					round_science.Add(M)
					continue

				// Pathology?
				if("Pathologist")
					#ifdef SCIENCE_PATHO_MAP
					round_science.Add(M)
					#else
					round_medical.Add(M)
					#endif

				// Engineering?
				if("Chief Engineer","Engineer","Quartermaster","Miner","Mechanic","Construction Worker")
					round_engineering.Add(M)
					continue

				// Civilian?
				if("Head of Personnel","Communications Officer","Botanist","Apiculturist","Rancher","Bartender","Chef","Sous-Chef","Waiter","Clown","Mime","Chaplain","Mailman","Musician","Janitor","Coach","Boxer","Barber","Staff Assistant")
					round_civilian.Add(M)
					continue

				else // IDK who the fuck you are so just go here
					round_other.Add(M)

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done processing minds. info: A [round_antags.len] C [round_captains.len] S [round_security.len] M [round_medical.len] R [round_science.len] E [round_engineering.len] Cv [round_civilian.len] X [round_other.len]")

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] generating crew list")


		crew_creds = {"<B>Round Credits</B><BR>"}
		//generate_crew_photo('icons/turf/floors.dmi',"wooden",ticker.minds,"everyone_photo.png")
		//crew_creds += "<img style=\"-ms-interpolation-mode:nearest-neighbor;\" src=everyone_photo.png>"
		crew_creds += "<HR>"
		// Antagonists
		if(round_antags.len > 0)
			crew_creds += "<B>Antagonist[round_antags.len == 1 ? "" : "s"]:</B><BR>"
			for(var/datum/mind/M in round_antags)
				if(!M.current) continue
				crew_creds += "[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as \an [M.special_role]<BR>"
			crew_creds += "<HR>"

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done antags")

		// Captain
		if(round_captains.len > 0)
			crew_creds += "<H3>Captain[round_captains.len == 1 ? "" : "s"]:</H3>"
			for(var/datum/mind/M in round_captains)
				if(!M.current) continue
				crew_creds += "<H4>[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key])</H4>"
			//generate_crew_photo('icons/turf/floors.dmi',"greenchecker",round_captains,"captain_photo.png")
			//crew_creds += "<img style=\"-ms-interpolation-mode:nearest-neighbor;\" src=captain_photo.png>"
			crew_creds += "<HR>"

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done captains")

		// Security Department
		if(round_security.len > 0)
			crew_creds += "<H3>Security:</H3>"
			// HoS?
			for(var/datum/mind/M in round_security)
				if(!M.current) continue
				if(M.assigned_role == "Head of Security")
					crew_creds += "<H4>[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as the [M.assigned_role]<H4>"
					round_security.Remove(M)
			for(var/datum/mind/M in round_security)
				if(!M.current) continue
				crew_creds += "[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as [M.assigned_role]<BR>"
			crew_creds += "<HR>"

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done security")

		// Medical Department
		if(round_medical.len > 0)
			crew_creds += "<H3>Medical Department:</H3>"
			// MD?
			for(var/datum/mind/M in round_medical)
				if(!M.current) continue
				if(M.assigned_role == "Medical Director")
					crew_creds += "<H4>[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as the [M.assigned_role]<H4>"
					round_medical.Remove(M)
			for(var/datum/mind/M in round_medical)
				if(!M.current) continue
				crew_creds += "[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as [M.assigned_role]<BR>"
			crew_creds += "<HR>"

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done medical")

		// Science Department
		if(round_science.len > 0)
			crew_creds += "<H3>[prob(1) ? "Nerd" : "Research"] Department:</H3>"
			// RD?
			for(var/datum/mind/M in round_science)
				if(!M.current) continue
				if(M.assigned_role == "Research Director")
					crew_creds += "<H4>[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as the [M.assigned_role]<H4>"
					round_science.Remove(M)
			for(var/datum/mind/M in round_science)
				if(!M.current) continue
				crew_creds += "[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as [M.assigned_role]<BR>"
			crew_creds += "<HR>"

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done science")


		// Engineering Department
		if(round_engineering.len > 0)
			crew_creds += "<H3>Engineering Department:</H3>"
			// CE?
			for(var/datum/mind/M in round_engineering)
				if(!M.current) continue
				if(M.assigned_role == "Chief Engineer")
					crew_creds += "<H4>[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as the [M.assigned_role]<H4>"
					round_engineering.Remove(M)
			for(var/datum/mind/M in round_engineering)
				if(!M.current) continue
				crew_creds += "[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as [M.assigned_role]<BR>"
			crew_creds += "<HR>"

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done engineering")


		// Civilian Department
		if(round_civilian.len > 0)
			crew_creds += "<H3>Civilian Department:</H3>"
			// CE?
			for(var/datum/mind/M in round_civilian)
				if(!M.current) continue
				if(M.assigned_role == "Head of Personnel")
					crew_creds += "<H4>[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as the [M.assigned_role]</H4>"
					round_civilian.Remove(M)
			for(var/datum/mind/M in round_civilian)
				if(!M.current) continue
				crew_creds += "[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as [M.assigned_role]<BR>"
			crew_creds += "<HR>"

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done civilian")

		// Weirdoes
		if(round_other.len > 0)
			crew_creds += "<H3>Other:</H3>"
			for(var/datum/mind/M in round_other)
				if(!M.current) continue
				crew_creds += "[M.current.real_name][isdead(M.current) ? " \[["<span class='alert'>DEAD</span>"]\] " : ""] (played by [M.displayed_key]) as [M.assigned_role]<BR>"
			crew_creds += "<HR>"

		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done other - all finished")
		return crew_creds

proc/generate_crew_photo(var/background_icon, var/background_icon_state, var/list/datum/mind/chars, var/photo_name)
	var/icon/photo = icon(background_icon,background_icon_state)
	var/icon/background = icon(background_icon,background_icon_state)
	var/icon_side_size = ceil(sqrt(chars.len)) + 1
	var/chars_per_line = icon_side_size - 1
	photo.Scale(icon_side_size * 32,icon_side_size * 32)

	// Separate the chars into rows
	var/list/list/icon/photo_rows = split_into_photo_rows(chars,chars_per_line)
	// Tile the background
	for(var/i = 0, i < icon_side_size, i++)
		for(var/j = 0, j < icon_side_size, j++)
			photo.Blend(background,ICON_OVERLAY,j*32,i*32)

	// Place the subjects in the picture
	for(var/row = photo_rows.len, row > 0, row--) // Each row, back to front
		// For each character in this row
		var/row_y = 32*(row-1) + 16
		for(var/col = 1, col <= photo_rows[row].len, col++)
			var/col_x = 16 + 32*(col-1)
			photo.Blend(photo_rows[row][col],ICON_OVERLAY,col_x + rand(-5,5),row_y + rand(-5,5))

	for(var/mob/M in mobs)
		if(M.client)
			M.client << browse_rsc(photo,photo_name)
	return photo

proc/split_into_photo_rows(var/list/datum/mind/chars, var/max_per_row)
	var/list/list/arrangement = list()
	var/list/L = list()
	arrangement[++arrangement.len] = L
	var/row = 1
	var/list/heads = list("Captain","Head of Personnel","Chief Engieer","Medical Director","Head of Security","Research Director")

	// Heads in front
	for(var/datum/mind/M in chars)
		if(isdead(M.current) || inafterlife(M.current))
			continue
		if(M.assigned_role in heads)
			arrangement[row].Add(getFlatIcon(M.current,SOUTH))

	// Now the lucky survivors
	for(var/datum/mind/M in chars)
		if(isdead(M.current) || inafterlife(M.current))
			continue
		// Heads are going to be in the front row
		if(!(M.assigned_role in heads))
			arrangement[row].Add(getFlatIcon(M.current,SOUTH))

		// New row time?
		if(arrangement[row].len >= max_per_row) // NEW ROW
			L = list()
			arrangement[++arrangement.len] = L
			row++

	// Rear rows are the dead people
	for(var/datum/mind/M in chars)
		if(isdead(M.current) || inafterlife(M.current)) //  Add em!
			// Err do they have a death photo?
			//if(M.death_icon)
			//	arrangement[row].Add(M.death_icon)
			//else // ye gods what happened to you.
			//	arrangement[row].Add(pick(icon('icons/misc/halloween.dmi',"tombstone"),icon('icons/obj/large_storage.dmi',"coffin")))
		else // God job you managed to not die
			continue

		// New row time?
		if(arrangement[row].len >= max_per_row) // NEW ROW
			L = list()
			arrangement[++arrangement.len] = L
			row++

	return arrangement
