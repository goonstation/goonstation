/*
	For when you want to have a mob control an object's movement.
	Used by the controlled_by_mob component.
*/

/datum/movement_controller/obj_control
	var/obj/master
	var/move_dir = 0
	var/move_delay = 1
	var/running = 0
	var/next_move = 0

	New(master)
		..()
		src.master = master

	disposing()
		master = null
		..()

	keys_changed(mob/user, keys, changed)
		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT|KEY_RUN))
			src.move_dir = 0
			src.running = 0
			if (keys & KEY_FORWARD)
				move_dir |= NORTH
			if (keys & KEY_BACKWARD)
				move_dir |= SOUTH
			if (keys & KEY_RIGHT)
				move_dir |= EAST
			if (keys & KEY_LEFT)
				move_dir |= WEST
			if (keys & KEY_RUN)
				src.running = 1
			if(src.move_dir)
				attempt_move(user)

	process_move(mob/user, keys)
		if(!src.move_dir)
			return 0
		if(TIME < src.next_move)
			return src.next_move - TIME
		var/delay = src.running ? src.move_delay / 2 : src.move_delay
		src.master.set_dir(src.move_dir)
		var/turf/T = src.master.loc
		if(istype(T))
			// this is what pod.dm does, don't look at me!!!
			src.master.glide_size = (32 / delay) * world.tick_lag
			user.glide_size = src.master.glide_size
			user.animate_movement = SYNC_STEPS
			step(src.master, src.move_dir)
			src.master.glide_size = (32 / delay) * world.tick_lag
			user.glide_size = src.master.glide_size
			user.animate_movement = SYNC_STEPS
		src.next_move = TIME + delay
		return delay

	hotkey(mob/user, name)
		..()
		switch (name)
			if("exit")
				user.use_movement_controller = null
				user.set_loc(get_turf(src.master))
				user.reset_keymap()
				user.client.eye = user

	modify_keymap(client/C)
		..()
		C.apply_keybind("just exit")
