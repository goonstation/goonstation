#define LANDMARK_TUTORIAL_PLAYER_SPAWN "tutorial_player_spawn"

/**
 * This is the datum for an individual 'stage' in the tutorial with an associated map
 *
 * Functions:
 * * Keeps track of stage-specific data
 * * * Example: If you have farted yet or not
 * * Display text/sounds/whatever to the player when certain things are triggered
 */
/datum/tutorial/stage
	/// Name of the stage
	var/name = "GREEN HILLS ZONE"

	/// Unique name of the dmm to load
	var/prefab_name = "template"

	/// TODO: Description displayed on the UI resume screen
	var/desc = "GOTTAGOFAST"

	/// The box that we belong to
	var/datum/tutorial/box/box = null

	/// The current player completing this stage
	var/datum/tutorial/player_state/player = null

	/// The turf we spawn a player in on resume/start
	/// Only one pls and do not let the player delet this tile
	var/turf/spawn_location

	/// Our ordered list of our task typepaths - initalize all
	var/const/list/datum/tutorial/task/tasks = null

	/// Our current task index (byond starts at 1)
	var/current_task_idx = 1

	/// Our current task datum
	var/datum/tutorial/task/current_task = null

	/// numeric index of the task
	var/step_num = 0

	/// Current status of the stage
	var/status = FALSE

	/// Current tick number (used for [/datum/tutorial/task/var/check_frequency])
	var/tick_number = 0


	New(datum/tutorial/box/owner)
		. = ..()
		src.box = owner
		player = src.box.group.player_state

		// Find our player spawn location to store
		var/turf/SW_corner_turf = locate(box.x, box.y, Z_LEVEL_TUTORIAL)
		var/turf/NE_corner_turf = locate(box.x + TUTORIAL_BOX_SIZE - 1, box.y + TUTORIAL_BOX_SIZE - 1, Z_LEVEL_TUTORIAL)
		for (var/turf/unsimulated/floor/delivery/tutorial/T in block(SW_corner_turf, NE_corner_turf))
			spawn_location = T
			return
		message_coders("TUTORIAL/STAGE: fuck! no starting turf in [name]/[prefab_name] with player [player.client.ckey]")

	/// Takes in a player to transfer over and spawn in at the starting location
	proc/spawn_player(datum/tutorial/player_state/state)
		var/mob/living/carbon/human/normal/assistant/M = new(spawn_location)
		state.client.mob.mind.transfer_to(M)

		status = STAGE_INPROGRESS
		advance() // advance to the first task after player is here, do here because task could be time-sensitive

		boutput(M, "Welcome to da tutorial")

	/// Stub. Called after the dmm is loaded in, override for further setup.
	proc/after_load()
		return

	/// Main process loop for the stage
	/// TODO: more checks for error states
	proc/process()
		if (status == STAGE_FINISHED) // stage is finished - TODO: is this needed? should be letting group know next stage sometime
			return
		if (!current_task)
			message_coders("TUTORIAL/STAGE/PROC: No active task in [name]/[prefab_name] with player [player.client.ckey]")
			return
		if (isnull(player.client.mob))
			message_coders("TUTORIAL/STAGE/PROC: No player found for [name]/[prefab_name] with player [player.client.ckey]") //ckey?
			return
		if (isdead(player.client.mob))
			//TODO: better handling?
			message_coders("TUTORIAL/STAGE/PROC: Player dead in [name]/[prefab_name] with player [player.client.ckey]")
			reset()
			return
		tick_number++

		if (current_task.status == TASK_INPROGRESS)
			if (current_task.check_frequency && (tick_number % current_task.check_frequency == 0)) // Are we supposed to process on the task?
				if (!current_task.is_finished())
					return // Exit early if not finished

		switch(current_task.status)
			if (TASK_FINISHED)
				finish_or_advance()
			if (TASK_ERROR, TASK_NOTSTARTED)
				message_coders("TUTORIAL/STAGE/PROC: shit, current task gave code of [current_task.status] with data [json_encode(current_task)]")

	/// Finishes the stage or advances to the next task
	proc/finish_or_advance()
		if (tasks[length(tasks)] == current_task.type) // are we on the last task and finished
			status = STAGE_FINISHED
			return
		else // we still have more tasks
			advance()

	/// Advances to next task
	proc/advance()
		step_num++
		var/old_task = current_task
		var/task = tasks[step_num]
		current_task = new task(src)
		current_task.start()
		qdel(old_task)

	/// TODO: Reset the stage (aka delete/transfer), ideally triggered by players wanting to start over (maybe due to bug?)
	proc/reset()
		current_task_idx = 1
		box.unload_stage()
		box.load_stage(tutorial_manager.tutorial_stages[box.group.stage_index])
		// TODO: handle player properly (with player.client.mob)

	/// Called when we're being deleted, say the client logged out or left or moved on very further past
	disposing()
		. = ..()
		box = null
		player = null
		spawn_location = null
		current_task = null
		tasks = null
		// TODO: other stage cleanup??


// placeholder until we find a better way to mark where the player spawns
// landmarks are bad because we don't need any of their special behaivor
/turf/unsimulated/floor/delivery/tutorial
	desc = "hello yes this is where you spawn"
