/**
 * This is the datum tracker for each 23x23 tutorial box with a physical stage loaded inside it.
 *
 * Functions:
 * * Store the coordinates of its physical bottom left corner
 * *
 */
/datum/tutorial/box
	/// X coordinate for the bottom left of the tutorial box
	var/x
	/// Y coordinate for the bottom left of the tutorial box
	var/y
	/// The tutorial_group datum to which we belong
	var/datum/tutorial/group/group
	/// The current stage contained in the box
	var/datum/tutorial/stage/stage
	/// list of the turfs in the box
	var/list/box_turfs

	/// Params: Bottom left x and y coords of the box
	New(group, x_coord, y_coord)
		. = ..()
		group = group
		x = x_coord
		y = y_coord
		box_turfs = block(locate(x, y, Z_LEVEL_TUTORIAL), locate((x + TUTORIAL_BOX_SIZE - 1) , (y + TUTORIAL_BOX_SIZE - 1), Z_LEVEL_TUTORIAL))

	/// Loads in a given stage typepath
	proc/load_stage(stage_path)
		stage = new stage_path(src)
		. = stage
		var/prefab_path = "+secret/assets/tutorial/stages/tutorial_stage[stage.prefab_name].dmm"
		var/dmm_data = file2text(prefab_path)
		if(!dmm_data)
			return null

		var/dmm_suite/D = new/dmm_suite()
		D.read_map(dmm_data, x, y, Z_LEVEL_TUTORIAL, prefab_path, DMM_OVERWRITE_OBJS | DMM_OVERWRITE_MOBS)
		stage.after_load()

	/// Unloads the current stage, deleting all objects and replacing it with space
	proc/unload_stage()
		for(var/turf/T as anything in box_turfs)
			for (var/atom/movable/AM in T)
				if (ismob(AM))
					var/mob/M = AM
					if (M.client)
						continue // probably an observer
				qdel(AM)
			T.ReplaceWith("Unsimulated Floor", FALSE, FALSE, FALSE, force=1)
		return

	/// Called when a player is no longer inhabiting the current group (left, deleted)
	proc/cleanup()
		unload_stage()
		// TODO: more?

	/// Called when we're being deleted
	disposing()
		box_turfs = null
		group = null
		qdel(stage)
		stage = null
		. = ..()
