/datum/random_event/major/player_spawn/crew
	disabled = TRUE
	targetable = TRUE
	customization_available = TRUE
	always_custom = TRUE
	name = "Crew respawn"
	var/ghost_confirmation_delay = 20 SECONDS // time to acknowledge or deny respawn offer.
	var/datum/job/respawn_job = null
	var/num_crew = 1
	var/objective_text = ""

	admin_call(var/source)
		if (..())
			return
		var/list/jobs = list()
		for (var/datum/job/job in (job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs))
			jobs[job.name] = job
		src.respawn_job = tgui_input_list(usr, "Pick a job", src.name, jobs)
		if (!src.respawn_job)
			return
		src.respawn_job = jobs[src.respawn_job]
		src.num_crew = input(usr, "How many crew to spawn?", src.name, 0) as num|null
		if (!src.num_crew || src.num_crew < 1)
			src.cleanup()
			return

		src.objective_text = tgui_input_text(usr, "Custom objective text.", "Objectives", src.objective_text, multiline=TRUE, allowEmpty=TRUE)

		//confirmation
		if (alert(usr, "You have chosen to spawn [src.num_crew] [src.respawn_job.name]s. Is this correct?", src.name, "Yes", "No") == "Yes")
			event_effect(source)
		else
			src.cleanup()

	event_effect(var/source)
		..()

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as [src.num_crew > 1 ? "part of a group of" : "a"] [src.respawn_job.name][src.num_crew > 1 ? "s" : ""]?")
		text_messages.Add("You are eligible to be respawned as a [src.respawn_job.name]. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of respawns. Please wait...")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(TRUE, src.ghost_confirmation_delay, text_messages, allow_dead_antags = TRUE, require_client = TRUE)

		for (var/i = 1 to src.num_crew)
			if (!length(candidates))
				return
			var/datum/mind/mind = candidates[1]
			log_respawn_event(mind, src.respawn_job, source)
			src.spawn_as_job(src.respawn_job, mind.current, src.custom_spawn_turf || pick_landmark(LANDMARK_LATEJOIN))
			candidates -= mind
			if (src.objective_text)
				new /datum/objective/crew/custom(src.objective_text, mind)
				boutput(mind.current, "<span style='font-size:24px'>You have respawned as a [src.respawn_job.name].</span>")
				boutput(mind.current, "<span style='font-size:24px'>Your objective is: [src.objective_text]</span>")
				SPAWN(0)
					tgui_alert(mind.current, "You have respawned as a [src.respawn_job.name]. Your objective is: [src.objective_text]", "Respawned", list("Ok"))
		SPAWN(1)
			src.cleanup()

	proc/spawn_as_job(datum/job/job, mob/player, turf/location)
		var/mob/living/carbon/human/normal/M = new/mob/living/carbon/human/normal(location)
		SPAWN(0)
			M.JobEquipSpawned(job.name)

		if(!player.mind)
			player.mind = new (player)
		player.mind.assigned_role = job.name
		M.job = job.name
		player.mind.transfer_to(M)
		remove_antag(M, usr, 1, 1)
		SPAWN(5 SECONDS)
			if(player && !player:client)
				qdel(player)

	cleanup()
		..()
		src.ghost_confirmation_delay = initial(src.ghost_confirmation_delay)
		src.respawn_job = null
		src.objective_text = initial(src.objective_text)
		src.num_crew = initial(src.num_crew)
