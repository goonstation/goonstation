/**
 * This is the 2x2 player box group for each player.
 *
 * Functions:
 * * Map each physical tutorial box to the datum structure representation
 * * Keep track of when a player exits/completes a stage
 * * Load new stages in its member boxes as needed
 */
/datum/tutorial/group
	/// Map of Box Direction -> Box datum
	var/list/datum/tutorial/box/boxes = null
	/// Our player (non-null if we have one)
	var/datum/tutorial/player_state/player_state = null
	/// The index of the stage currently in use by the player
	var/stage_index = 0
	/// The current instantiated stage in use by the player
	var/datum/tutorial/stage/current_stage =  null

	/// Params: Bottom left x, and bottom left y of the group (NOT INCLUDING CORDONS, GIVE WALL COORD)
	New(bottom_left_x, bottom_left_y)
		. = ..()
		boxes = list()
		initalize_boxes(bottom_left_x, bottom_left_y)
		advance_stage()

	/// Initalizes the tutorial box structures given the bottom left x and y of the group
	proc/initalize_boxes(bottom_left_x, bottom_left_y)
		// +1/+2 for the walls (coords also start at 1,1,1 in DM)
		boxes[NORTHWEST] = new /datum/tutorial/box(src, bottom_left_x + 1, bottom_left_y + TUTORIAL_BOX_SIZE + 2)
		boxes[NORTHEAST] = new /datum/tutorial/box(src, bottom_left_x + TUTORIAL_BOX_SIZE + 2, bottom_left_y + TUTORIAL_BOX_SIZE + 2)
		boxes[SOUTHWEST] = new /datum/tutorial/box(src, bottom_left_x + 1, bottom_left_y + 1)
		boxes[SOUTHEAST] = new /datum/tutorial/box(src, bottom_left_x + TUTORIAL_BOX_SIZE + 2, bottom_left_y + 1)

	/// Adds a player to this group
	/// TODO: more?
	proc/add_player(datum/tutorial/player_state/player)
		player_state = player
		// TODO: load initial stages (1,2,3,4)
		// todo: current_stage = 1st

	/// Called when the client logged out or left
	/// TODO: more?
	proc/remove_player()
		for (var/datum/tutorial/box/box as anything in boxes)
			box.cleanup()
		boxes = null
		stage_index = 0
		player_state = null // might want to wait on this, so everything has a chance to clean up (this is how we signify if group is available)

	/// Process this player group, each stage in the boxes
	/// TODO: more? unloading/loading of stages?
	proc/process()
		for (var/datum/tutorial/box/box as anything in boxes)
			box.stage.process()
		if (player_state.current_stage.status == STAGE_FINISHED)
			advance_stage()
			current_stage.spawn_player(player_state)


	/// load in the next stage to the next box in seqeunce
	proc/advance_stage()
		if (stage_index >= length(tutorial_manager.tutorial_stages))
			return
		stage_index++
		switch (stage_index % 4)
			if (1)
				current_stage = boxes[NORTHWEST].load_stage(tutorial_manager.tutorial_stages[stage_index])
			if (2)
				current_stage = boxes[NORTHEAST].load_stage(tutorial_manager.tutorial_stages[stage_index])
			if (3)
				current_stage = boxes[SOUTHEAST].load_stage(tutorial_manager.tutorial_stages[stage_index])
			if (0)
				current_stage = boxes[SOUTHWEST].load_stage(tutorial_manager.tutorial_stages[stage_index])
		// TODO: transfer player or elsewhere figure out when they go to new stage


	/// Called when we're being deleted
	disposing()
		. = ..()
		tutorial_manager = null
		for (var/datum/tutorial/box/box as anything in boxes)
			qdel(box)
		boxes = null
		player_state = null

