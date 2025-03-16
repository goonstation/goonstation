/datum/pod_wars_team
	var/name = "NanoTrasen"
	var/comms_frequency = 0		//used in datum/job/pod_wars/proc/setup_headset (in Jobs.dm) to tune the radio as it's first equipped
	var/area/base_area = null		//base ship area
	var/datum/mind/commander = null
	var/list/members = list()		//list of minds
	var/team_num = 0

	var/points = 100
	var/max_points = 200
	var/list/mcguffins = list()		//Should have 4 AND ONLY 4
	var/commander_job_title			//for commander selection
	var/datum/game_mode/pod_wars/mode

	var/list/datum/resources = list(
		/obj/item/material_piece/mauxite = 20,
		/obj/item/material_piece/pharosium = 20,
		/obj/item/material_piece/molitz = 20) // List of material resources

	//These two are for playing sounds, they'll only play for the first death or system destruction.
	var/first_system_destroyed = 0
	var/first_commander_death = 0

	//sound line alt amounts for random selection based on what's in the voice line directory
	var/sl_amt_commander_dies
	var/sl_amt_crit_system_destroyed
	var/sl_amt_lose
	var/sl_amt_losing
	var/sl_amt_win
	var/sl_amt_roundstart
	var/sl_amt_objective_secured
	var/sl_amt_objective_lost_chucks
	var/sl_amt_objective_lost_fortuna
	var/sl_amt_objective_lost_reliant
	var/sl_amt_objective_lost_uvb67

	New(var/datum/game_mode/pod_wars/mode, team_num)
		..()
		src.mode = mode
		src.team_num = team_num
		switch(team_num)
			if (TEAM_NANOTRASEN)
				name = "NanoTrasen"
				commander_job_title = "NanoTrasen Pod Commander"
				base_area = /area/pod_wars/team1 //area north, NT crew
			if (TEAM_SYNDICATE)
				name = "Syndicate"
				commander_job_title = "Syndicate Pod Commander"
				base_area = /area/pod_wars/team2 //area south, Syndicate crew

		setup_voice_line_alt_amounts()
		set_comms(mode)

	proc/change_points(var/amt)
		points += amt
		mode.handle_point_change(src)


	proc/set_comms(var/datum/game_mode/pod_wars/mode)
		comms_frequency = rand(1360,1420)

		while(comms_frequency in mode.frequencies_used)
			comms_frequency = rand(1360,1420)

		mode.frequencies_used += comms_frequency
		protected_frequencies += comms_frequency


	proc/accept_initial_players(var/list/players)
		members = players
		if (!select_commander())
			message_admins("[src.name] could not rustle up a Commander. Oh no!")

		for (var/datum/mind/M in players)
			equip_player(M.current, TRUE)

	proc/select_commander()

		var/list/high_prio_commanders = get_possible_commanders(1)
		if(length(high_prio_commanders))
			commander = pick(high_prio_commanders)
			return 1

		var/list/med_prio_commanders = get_possible_commanders(2)
		if(length(med_prio_commanders))
			commander = pick(med_prio_commanders)
			return 1

		var/list/low_prio_commanders = get_possible_commanders(3)
		if(length(low_prio_commanders))
			commander = pick(low_prio_commanders)
			return 1

		return 0

	//Really stolen from gang, But this basically just picks everyone who is ready and not jobbanned from Command or Captain
	//priority values 1=favorite,2=medium,3=low job priorities
	proc/get_possible_commanders(var/priority)
		var/list/candidates = list()
		for(var/datum/mind/mind in members)
			var/mob/new_player/M = mind.current
			if (!istype(M)) continue
			if(jobban_isbanned(M, "Captain")) continue //If you can't captain a Space Station, you probably can't command a starship either...
			if(jobban_isbanned(M, "NanoTrasen Pod Commander")) continue
			if(jobban_isbanned(M, "Syndicate Pod Commander")) continue

			if ((M.ready) && !candidates.Find(M.mind))
				switch(priority)
					if (1)
						if (M.client.preferences.job_favorite == commander_job_title)
							candidates += M.mind
					if (2)
						if (M.client.preferences.jobs_med_priority == commander_job_title)
							candidates += M.mind
					if (3)
						if (M.client.preferences.jobs_low_priority == commander_job_title)
							candidates += M.mind
				candidates += M.mind

		if(!length(candidates))
			return null
		else
			return candidates

	//this initializes the player with all their equipment, edits to their mind, showing antag popup, and initializing player_stats
	//if show_popup is TRUE, then show them the tips popup
	proc/equip_player(var/mob/M, var/show_popup = FALSE)
		var/mob/living/carbon/human/H = M
		var/datum/job/special/pod_wars/JOB

		if (team_num == TEAM_NANOTRASEN)
			if (M.mind == commander)
				JOB = new /datum/job/special/pod_wars/nanotrasen/commander
			else
				JOB = new /datum/job/special/pod_wars/nanotrasen
		else if (team_num == TEAM_SYNDICATE)
			if (M.mind == commander)
				JOB = new /datum/job/special/pod_wars/syndicate/commander
			else
				JOB = new /datum/job/special/pod_wars/syndicate

		//This first bit is for the round start player equipping
		if (istype(M, /mob/new_player))
			var/mob/new_player/N = M
			if (team_num == TEAM_NANOTRASEN)
				if (M.mind == commander)
					H.mind.assigned_role = "NanoTrasen Pod Commander"
				else
					H.mind.assigned_role = "NanoTrasen Pod Pilot"
				H.mind.special_role = "NanoTrasen"

			else if (team_num == TEAM_SYNDICATE)
				if (M.mind == commander)
					H.mind.assigned_role = "Syndicate Pod Commander"
				else
					H.mind.assigned_role = "Syndicate Pod Pilot"
				H.mind.special_role = "Syndicate"
			H = N.create_character(JOB)

		//This second bit is for the in-round player equipping (when cloned)
		else if (istype(H))
			SPAWN(0)
				H.JobEquipSpawned(H.mind.assigned_role)

		H.set_clothing_icon_dirty()
		boutput(H, "<h3 class='hint'>You're in the <b>[name]</b> faction!</b>")
		if (show_popup)
			H.show_antag_popup("podwars")
		if (istype(mode))
			mode.stats_manager?.add_player(H.mind, H.real_name, team_num, (H.mind == commander ? "Commander" : "Pilot"))

	//set the amounts of files for each type of line based on the team and amount of voice line files for that line.
	//files are in sound\voice\pod_wars_voices
	proc/setup_voice_line_alt_amounts()
		switch(team_num)
			if (TEAM_NANOTRASEN)
				sl_amt_commander_dies = 2
				sl_amt_crit_system_destroyed = 2
				sl_amt_lose = 4
				sl_amt_losing = 3
				sl_amt_win = 2
				sl_amt_roundstart = 2
				sl_amt_objective_secured = 3
				sl_amt_objective_lost_chucks = 3
				sl_amt_objective_lost_fortuna = 3
				sl_amt_objective_lost_reliant = 4
				sl_amt_objective_lost_uvb67 = 1
			if (TEAM_SYNDICATE)
				sl_amt_commander_dies = 1
				sl_amt_crit_system_destroyed = 1
				sl_amt_lose = 2
				sl_amt_losing = 0
				sl_amt_win = 2
				sl_amt_roundstart = 1
				sl_amt_objective_secured = 2
				sl_amt_objective_lost_chucks = 2
				sl_amt_objective_lost_fortuna = 2
				sl_amt_objective_lost_reliant = 2
				sl_amt_objective_lost_uvb67 = 2
