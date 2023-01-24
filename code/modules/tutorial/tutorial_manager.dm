/**
 * This is the global controller for the tutorial.
 *
 * Functions:
 * * Map each physical tutorial group to the datum structure representation
 * * Keep track of players in the tutorial and their status datums
 */
/datum/tutorial/manager
	/// List of all groups, wrapped on row end
	var/list/datum/tutorial/group/groups[TUTORIAL_GROUP_NUM_ROWS * TUTORIAL_GROUP_NUM_COLS]
	/// Non-nullable mapping of ckey:/datum/tutorial/player_state
	var/list/player_to_state = list()
	/// Ordered list of our stage typepaths
	var/list/datum/tutorial/stage/tutorial_stages = list(
		/datum/tutorial/stage/examine
	)

	New()
		. = ..()
		initalize_groups()

	/// Initalizes all the groups with the necessary data (lower left corner coords)
	proc/initalize_groups()
		PRIVATE_PROC(TRUE)
		for (var/i in 1 to TUTORIAL_GROUP_NUM_ROWS)
			for (var/j in 1 to TUTORIAL_GROUP_NUM_COLS)
				// Wrapping
				var/x_coord = (i+1)+((TUTORIAL_GROUP_SIZE)*(i-1))
				var/y_coord = (j+1)+((TUTORIAL_GROUP_SIZE)*(j-1))

				groups[i*j] = new /datum/tutorial/group(x_coord, y_coord)


	/// Gets an empty group not currently assigned to a player.
	/// Screams loudly if all are full and returns null
	proc/get_empty_group()
		PRIVATE_PROC(TRUE)
		for (var/datum/tutorial/group/group in groups)
			if (isnull(group.player_state)) // No player present
				return group

		message_coders("TUTORIAL/MANAGE: fuck! no empty group found with groups: [json_encode(groups)]")
		return null


	/// Adds a player to the manager
	proc/add_player(client/client)
		// TODO: if player has state saved on cloud, fetch, deserialize, and use for the later bit
		var/datum/tutorial/group/group = get_empty_group()
		var/datum/tutorial/player_state/state = new(client, group)
		player_to_state[client.ckey] = state

	/// Removes a player from the manager and subsequent tutorial bits
	proc/remove_player(client/client)
		var/datum/tutorial/player_state/player_state = player_to_state[client.ckey] // last_ckey necessary?
		qdel(player_state)
		player_to_state.Remove(client.ckey)

	/// Processes groups loaded for each player
	proc/process()
		for (var/ckey in player_to_state)
			var/datum/tutorial/player_state/state = player_to_state[ckey]
			state.group.process()
		// TODO: other global state stuff?


// Hooks

// We hook here to capture the client logging in and add them to the manager
/client/New()
	. = ..()
	tutorial_manager.add_player(src)

// We hook here to ensure we properly dispose of tutorial zones and players
/client/Del()
	tutorial_manager.remove_player(src)
	. = ..()

// Interfaces


// TODO: Joining - available only on outside server

// Status/Leaving - available only on inside server

/datum/tutorial/manager/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "tutorial_status")
		ui.open()

/datum/tutorial/manager/ui_data(mob/user)
	var/datum/tutorial/player_state/state = player_to_state[user.client.ckey]

	// Format the data to be "name of stage":completion_bool
	var/stagename_complete_map = list()
	for (var/stage_idx in state.finished_stages)
		var/datum/tutorial/stage/stage = tutorial_stages[stage_idx]
		stagename_complete_map[initial(stage.name)] = state.finished_stages

	. = list(
		"stages" = stagename_complete_map,
		"current_stage" = state.current_stage.name,
		"return_link" = state.return_server,
	)

/datum/tutorial/manager/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch(action)
		if("return")
			var/datum/tutorial/player_state/state = player_to_state[usr.ckey]
			// remove player and shit
			usr << link(state.return_server)
		if("reset_stage")
			return
			// reset current stage to initial
