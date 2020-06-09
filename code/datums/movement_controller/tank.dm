/datum/movement_controller/tank
	var
		obj/machinery/vehicle/owner
		velocity_dir = SOUTH
		velocity = 0

		input_x = 0
		input_y = 0

		next_move = 0
		next_rot = 0

		can_turn_while_parked = 1
		reverse_gear = 0

		accel_pow = 2
		turn_delay = 3
		brake_pow = 2

		velocity_max = 7
		delay_divisor = 18 //this is what decides our base speed

		//flags read in vehicle/Move()
		squeal_sfx = 0
		accel_sfx = 0

	treads
		can_turn_while_parked = 1

	wheels
		can_turn_while_parked = 0
		delay_divisor = 12.5
		turn_delay = 2

	New(owner)
		src.owner = owner

	disposing()
		owner = null
		..()

	keys_changed(mob/user, keys, changed)
		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
			if (!owner.engine) // fuck it, no better place to put this, only triggers on presses
				boutput(user, "[owner.ship_message("WARNING! No engine detected!")]")
				return
			if (istype(owner,/obj/machinery/vehicle/tank) && !owner:locomotion)
				boutput(user, "[owner.ship_message("WARNING! No locomotion detected!")]")
				return

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

			if (input_x || input_y)
				user.attempt_move()

	process_move(mob/user, keys)
		var/accel = 0
		var/rot = 0
		if (user && user == owner.pilot && !user.getStatusDuration("stunned") && !user.getStatusDuration("weakened") && !user.getStatusDuration("paralysis") && !isdead(user))
			if (owner && owner.engine && owner.engine.active)
				accel = input_y * accel_pow * (reverse_gear ? -1 : 1)
				rot = input_x * turn_delay

		if (!can_turn_while_parked)
			if (velocity == 0)
				rot = 0
			else
				rot = (rot*0.5) + ((velocity_max/velocity) * (rot*0.5)) //you turn a little faster when you're going fast with tires. is this too weird?

		if (next_rot <= world.time && rot)
			owner.dir = turn(owner.dir,45 * (rot > 0 ? -1 : 1)  * ((reverse_gear && !can_turn_while_parked) ? -1 : 1))
			owner.facing = owner.dir
			owner.flying = owner.dir
			next_rot = world.time + abs(rot)

		if (!can_turn_while_parked && velocity_dir != owner.dir && (velocity + accel) > velocity_max)
			if (velocity >= velocity_max) //we are at max speed
				velocity -= accel_pow * 1.5
			else						  //we are at max speed AND the user is holding on the gas.
				velocity -= accel_pow * 2

			squeal_sfx = 1

		velocity_dir = owner.dir

		if (next_move > world.time)
			return min(next_rot-world.time, next_move - world.time)

		var/delay
		if (accel)
			if (velocity == 0)
				accel_sfx = 1

			if (accel > 0)
				if (velocity < 1)
					velocity = 1
				velocity += accel
				delay = delay_divisor / velocity
			else
				velocity -= brake_pow
				if (velocity <= 2)
					if (velocity <= 0)
						reverse_gear = !reverse_gear
						delay = 10
						velocity = 0
						return 10
					velocity = 0
				else
					delay = delay_divisor / velocity

		else if (velocity)
			delay = delay_divisor / velocity

		if (owner.dir & (owner.dir-1))
			delay *= 1.4 //sqrt(2)

		if (delay)
			velocity = min(velocity + accel * delay/delay_divisor, velocity_max)

			var/target_turf = get_step(owner,(reverse_gear ? turn(velocity_dir,180) : velocity_dir))
			owner.glide_size = (32 / delay) * world.tick_lag// * (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH)
			for(var/mob/M in owner) //hey maybe move this somewhere better later. idk man its all chill thou, its all cool, dont worry about it buddy
				M.glide_size = owner.glide_size
				M.animate_movement = SYNC_STEPS

			step(owner,(reverse_gear ? turn(velocity_dir,180) : velocity_dir))
			owner.glide_size = (32 / delay) * world.tick_lag// * (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH)
			owner.dir = owner.facing
			if (owner.loc != target_turf)
				velocity = 0
				//boutput(world,"[src.owner] crashed?")

			for(var/mob/M in owner) //hey maybe move this somewhere better later. idk man its all chill thou, its all cool, dont worry about it buddy
				M.glide_size = owner.glide_size
				M.animate_movement = SYNC_STEPS

		else
			delay = 1 // stopped

		next_move = world.time + delay
		return min(delay, next_rot-world.time)

	update_owner_dir(var/atom/movable/ship) //after move, update ddir
		if (owner.flying && owner.facing != owner.flying)
			owner.dir = owner.facing

	hotkey(mob/user, name)
		switch (name)
			if ("fire")
				owner.fire_main_weapon() // just, fuck it.

	modify_keymap(datum/keymap/keymap, client/C)
		keymap.merge(C.get_keymap("pod"))
