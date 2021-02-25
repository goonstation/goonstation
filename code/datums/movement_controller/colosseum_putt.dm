/datum/movement_controller/colosseum_putt
	var/obj/machinery/colosseum_putt/master

	var/next_move = 0
	New(master)
		..()
		src.master = master

	disposing()
		master = null
		..()

	keys_changed(mob/user, keys, changed)
		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
			var/move_dir = 0
			if (keys & changed & KEY_FORWARD)
				move_dir = NORTH
			else if (keys & changed & KEY_BACKWARD)
				move_dir = SOUTH
			else if (keys & changed & KEY_RIGHT)
				move_dir = EAST
			else if (keys & changed & KEY_LEFT)
				move_dir = WEST
			else
				switch (move_dir)
					if (NORTH)
						if (keys & KEY_FORWARD)
							return
					if (SOUTH)
						if (keys & KEY_BACKWARD)
							return
					if (EAST)
						if (keys & KEY_RIGHT)
							return
					if (WEST)
						if (keys & KEY_LEFT)
							return
				if (keys & KEY_FORWARD)
					move_dir = NORTH
				else if (keys & KEY_BACKWARD)
					move_dir = SOUTH
				else if (keys & KEY_RIGHT)
					move_dir = EAST
				else if (keys & KEY_LEFT)
					move_dir = WEST
				else
					move_dir = 0

			if (move_dir)
				master.set_dir(move_dir)
				master.facing = move_dir
				user.attempt_move()

	process_move(mob/owner, keys)
		// stub
		if (owner.stat || !istype(master))
			return next_move - world.time

		if(next_move > world.time) return next_move - world.time
		var/move_dir = 0
		if (keys & KEY_FORWARD)
			move_dir = NORTH
		else if (keys & KEY_BACKWARD)
			move_dir = SOUTH
		else if (keys & KEY_RIGHT)
			move_dir = EAST
		else if (keys & KEY_LEFT)
			move_dir = WEST
		else
			move_dir = 0

		var/delay = clamp(10 - master.speed, 1, 10)

		if ((owner in master) && (owner == master.piloting))
			master.facing = move_dir
			if (master.dir == move_dir)
				if(master.flying == turn(master.dir,180))
					//walk(master, 0)
					master.flying = 0
				else
					if(step(master, master.dir))
						next_move = world.time + delay
					master.flying = master.dir
			else
				master.set_dir(move_dir)
		return delay

	hotkey(mob/user, name)
		..()
		if (master.piloting != user)
			return
		switch (name)
			if("fire")
				master.fire_primary()
			if("alt_fire")
				master.fire_secondary()
			if("stop")
				walk(master, 0)
				master.flying = 0

	modify_keymap(client/C)
		..()
		C.apply_keybind("colputt")
		if (!C.preferences.use_wasd)
			C.apply_keybind("colputt_arrow")
