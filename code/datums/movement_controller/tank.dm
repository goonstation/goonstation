/datum/movement_controller/tank
	var/obj/machinery/vehicle/owner
	var/velocity_dir = SOUTH
	var/velocity_magnitude = 0

	var/input_x = 0
	var/input_y = 0

	var/next_move = 0
	var/next_rot = 0

	var/can_turn_while_parked = 1
	var/reverse_gear = 0

	var/accel_pow = 2
	var/turn_delay = 3
	var/brake_pow = 2

	var/velocity_max = 7
	var/delay_divisor = 18 //this is what decides our base speed

	//flags read in vehicle/Move()
	var/squeal_sfx = 0
	var/accel_sfx = 0

	var/shooting = FALSE

	treads
		can_turn_while_parked = 1

	wheels
		can_turn_while_parked = 0
		delay_divisor = 12.5
		turn_delay = 2

	New(owner)
		..()
		src.owner = owner

	disposing()
		owner = null
		..()

	keys_changed(mob/user, keys, changed)
		if (istype(src.owner, /obj/machinery/vehicle/tank/minisub/escape_sub) || !owner)
			return
		if(user != src.owner.pilot)
			return
		if(changed & KEY_SHOCK)
			shooting = keys & KEY_SHOCK
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
				attempt_move(user)

	process_move(mob/user, keys)
		if (istype(src.owner, /obj/machinery/vehicle/tank/minisub/escape_sub))
			return

		if(user != src.owner.pilot)
			return

		var/can_user_act = user && user == owner.pilot && !is_incapacitated(user) && !isdead(user)

		if(shooting && owner.m_w_system?.active && can_user_act && !GET_COOLDOWN(owner.m_w_system, "fire"))
			owner.fire_main_weapon(user)

		var/accel = 0
		var/rot = 0
		if (can_user_act)
			if (owner?.engine?.active)
				accel = input_y * accel_pow * (reverse_gear ? -1 : 1)
				rot = input_x * turn_delay

				//We're on autopilot before the warp, NO FUCKING IT UP!
				if (owner.engine.warp_autopilot)
					return 0

		if (!can_turn_while_parked)
			if (velocity_magnitude == 0)
				rot = 0
			else
				rot = (rot*0.5) + ((velocity_max/velocity_magnitude) * (rot*0.5)) //you turn a little faster when you're going fast with tires. is this too weird?

		if (next_rot <= world.time && rot)
			owner.set_dir(turn(owner.dir,45 * (rot > 0 ? -1 : 1)  * ((reverse_gear && !can_turn_while_parked) ? -1 : 1)))
			owner.facing = owner.dir
			owner.flying = owner.dir
			next_rot = world.time + abs(rot)
			owner.update_mdir_light_visibility(owner.dir)

		if (!can_turn_while_parked && velocity_dir != owner.dir && (velocity_magnitude + accel) > velocity_max)
			if (velocity_magnitude >= velocity_max) //we are at max speed
				velocity_magnitude -= accel_pow * 1.5
			else						  //we are at max speed AND the user is holding on the gas.
				velocity_magnitude -= accel_pow * 2

			squeal_sfx = 1

		velocity_dir = owner.dir

		if (next_move > world.time)
			return min(next_rot-world.time, next_move - world.time)

		if (owner.rcs && input_x == 0 && input_y == 0)
			accel = -brake_pow

		var/delay
		if (accel)
			if (velocity_magnitude == 0)
				accel_sfx = 1

			if (accel > 0)
				if (velocity_magnitude < 1)
					velocity_magnitude = 1
				velocity_magnitude += accel
				delay = delay_divisor / velocity_magnitude
			else
				velocity_magnitude -= brake_pow
				if (velocity_magnitude <= 2)
					if (velocity_magnitude <= 0)
						reverse_gear = !reverse_gear
						delay = 10
						velocity_magnitude = 0
						return 10
					velocity_magnitude = 0
				else
					delay = delay_divisor / velocity_magnitude

		else if (velocity_magnitude)
			delay = delay_divisor / velocity_magnitude

		if (owner.dir & (owner.dir-1))
			delay *= DIAG_MOVE_DELAY_MULT

		if (delay)
			velocity_magnitude = min(velocity_magnitude + accel * delay/delay_divisor, velocity_max)

			var/target_turf = get_step(owner,(reverse_gear ? turn(velocity_dir,180) : velocity_dir))
			owner.glide_size = (32 / delay) * world.tick_lag// * (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH)
			for(var/mob/M in owner) //hey maybe move this somewhere better later. idk man its all chill thou, its all cool, dont worry about it buddy
				M.glide_size = owner.glide_size
				M.animate_movement = SYNC_STEPS

			step(owner,(reverse_gear ? turn(velocity_dir,180) : velocity_dir))
			owner.glide_size = (32 / delay) * world.tick_lag// * (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH)
			owner.set_dir(owner.facing)
			if (owner.loc != target_turf)
				velocity_magnitude = 0
				//boutput(world,"[src.owner] crashed?")

			for(var/mob/M in owner) //hey maybe move this somewhere better later. idk man its all chill thou, its all cool, dont worry about it buddy
				M.glide_size = owner.glide_size
				M.animate_movement = SYNC_STEPS

		else
			delay = 1 // stopped

		next_move = world.time + delay
		return min(delay, next_rot-world.time)

	update_owner_dir() //after move, update ddir
		if (owner.flying && owner.facing != owner.flying)
			owner.set_dir(owner.facing)

	modify_keymap(client/C)
		..()
		C.apply_keybind("pod")
