/datum/movement_controller/pod
	var
		obj/machinery/vehicle/owner

		next_move = 0


		input_x = 0
		input_y = 0
		input_dir = 0

		velocity_x = 0
		velocity_y = 0
		velocity_dir = 0
		velocity_magnitude = 0

		velocity_max = 6
		velocity_max_no_input = 5
		accel = 2

		min_delay = 14

		matrix/M

		braking = 0
		brake_decel_mult = 0.3

		last_dir = 0

	New(owner)
		..()
		src.owner = owner
		M = matrix()

	disposing()
		owner = null
		..()

	keys_changed(mob/user, keys, changed)
		if (istype(src.owner, /obj/machinery/vehicle/escape_pod) || !owner)
			return

		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT|KEY_RUN))
			if (!owner.engine) // fuck it, no better place to put this, only triggers on presses
				boutput(user, "[owner.ship_message("WARNING! No engine detected!")]")
				return

			braking = keys & KEY_RUN

			input_x = 0
			input_y = 0
			if (keys & KEY_FORWARD)
				input_y += 1
			if (keys & KEY_BACKWARD)
				input_y -= 1
			if (keys & KEY_RIGHT)
				input_x += 1
			if (keys & KEY_LEFT)
				input_x -= 1

			var/input_magnitude = vector_magnitude(input_x, input_y)
			if (input_magnitude)
				input_x /= input_magnitude
				input_y /= input_magnitude
				input_dir = vector_to_dir(input_x,input_y)

			owner.set_dir(input_dir)
			owner.facing = input_dir

			if (input_magnitude)
				if (input_dir & (input_dir-1))
					owner.set_dir(NORTH)
					owner.transform = turn(M,arctan(input_y,input_x))
				else
					owner.transform = null
			last_dir = owner.dir

			if (input_x || input_y)
				user.attempt_move()


	update_owner_dir(var/atom/movable/ship) //after move, update dir
		owner.set_dir(last_dir)

	process_move(mob/user, keys)
		if (istype(src.owner, /obj/machinery/vehicle/escape_pod))
			return

		if (next_move > world.time)
			return next_move - world.time

		velocity_magnitude = 0
		if (user && user == owner.pilot && !user.getStatusDuration("stunned") && !user.getStatusDuration("weakened") && !user.getStatusDuration("paralysis") && !isdead(user))
			if (owner?.engine?.active)

				velocity_x	+= input_x * accel
				velocity_y  += input_y * accel

				//We're on autopilot before the warp, NO FUCKING IT UP!
				if (owner.engine.warp_autopilot)
					return 0

				if (owner.rcs && input_x == 0 && input_y == 0)
					braking = 1

				//braking
				if (braking)
					velocity_x = velocity_x * brake_decel_mult
					velocity_y = velocity_y * brake_decel_mult

					if (abs(velocity_x) + abs(velocity_y) < 1.3)
						velocity_x = 0
						velocity_y = 0

				//normalize and force speed cap
				velocity_magnitude = vector_magnitude(velocity_x, velocity_y)
				var/vel_max = velocity_max
				if (!input_x && !input_y)
					vel_max = velocity_max_no_input

				vel_max /= (owner.speed ? owner.speed : 1)

				if (velocity_magnitude > vel_max)
					velocity_x /= velocity_magnitude
					velocity_y /= velocity_magnitude

					velocity_x *= vel_max
					velocity_y *= vel_max

				velocity_dir = vector_to_dir(velocity_x,velocity_y)
				owner.flying = velocity_dir

		if (!velocity_magnitude)
			velocity_magnitude = vector_magnitude(velocity_x, velocity_y)


		var/delay = 0

		if (velocity_magnitude)
			delay = 10 / velocity_magnitude

		if (velocity_dir & (velocity_dir-1))
			delay *= DIAG_MOVE_DELAY_MULT

		delay = min(delay,min_delay)

		if (delay)
			var/target_turf = get_step(owner, velocity_dir)

			owner.glide_size = (32 / delay) * world.tick_lag
			for(var/mob/M in owner) //hey maybe move this somewhere better later. idk man its all chill thou, its all cool, dont worry about it buddy
				M.glide_size = owner.glide_size
				M.animate_movement = SYNC_STEPS

			step(owner, velocity_dir)
			owner.glide_size = (32 / delay) * world.tick_lag

			if (owner.loc != target_turf)
				velocity_x = 0
				velocity_y = 0
				velocity_magnitude = 0

			for(var/mob/M in owner) //hey maybe move this somewhere better later. idk man its all chill thou, its all cool, dont worry about it buddy
				M.glide_size = owner.glide_size
				M.animate_movement = SYNC_STEPS

		else
			delay = 1 // stopped

		next_move = world.time + delay
		return delay

	hotkey(mob/user, name)
		switch (name)
			if ("fire")
				owner.fire_main_weapon() // just, fuck it.

	modify_keymap(client/C)
		..()
		C.apply_keybind("pod")
