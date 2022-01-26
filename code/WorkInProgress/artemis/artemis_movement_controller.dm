/datum/movement_controller/artemis

	var/obj/artemis/ship

	New(var/obj/artemis/A)
		..()
		ship = A

	keys_changed(mob/owner, keys, changed)
		owner.attempt_move()
		..()

	process_move(mob/owner, keys)
		var/mob/user = ship.my_pilot

		if (is_incapacitated(user))
			return

		if(ship.control_lock)
			user.show_message("<span class='alert'>The controls are locked!</span>")
			return

		if (ship.engine_check()) // ENGINE CHECK HERE LATER

			if((keys & KEY_FORWARD) && !(keys & KEY_BACKWARD))

				if(!ship.accelerating)

					var/new_mag = null

					var/new_angle = null

					if(ship.vel_mag <= 0)
						new_angle = ship.ship_angle
						new_mag = ship.accel
					else
						new_mag = sqrt(ship.vel_mag**2 + ship.accel**2 + 2*ship.vel_mag*ship.accel*cos(ship.ship_angle-ship.vel_angle))
						new_mag = min(ship.max_speed,new_mag)

						var/arctan_result = (ship.ship_angle == ship.vel_angle) ? 0 : arctan(((ship.accel*sin(ship.ship_angle-ship.vel_angle))/(ship.vel_mag + ship.accel*cos(ship.ship_angle-ship.vel_angle))))

						new_angle = ship.vel_angle + arctan_result

					ship.vel_mag = new_mag

					ship.vel_angle = new_angle

					ship.accelerating = 1

					ship.update_my_stuff()

					if(ship.back)
						flick("[ship.icon_base]_thruster_back",ship.back)

					if(ship.back_right)
						flick("[ship.icon_base]_thruster_back_r",ship.back_right)

					if(ship.back_left)
						flick("[ship.icon_base]_thruster_back_l",ship.back_left)

					spawn(ship.animation_speed)
						ship.accelerating = 0

			if(!(keys & KEY_FORWARD) && (keys & KEY_BACKWARD))

				if(!ship.accelerating)

					ship.vel_mag -= (ship.accel*2)
					ship.vel_mag = max(ship.vel_mag,0)
					if(ship.vel_mag == 0)
						ship.vel_angle = 0

					ship.accelerating = 1

					ship.update_my_stuff()

					if(ship.front_left)
						flick("[ship.icon_base]_thruster_front_l",ship.front_left)
					if(ship.front_right)
						flick("[ship.icon_base]_thruster_front_r",ship.front_right)

					spawn(ship.animation_speed)
						ship.accelerating = 0

			if(!(keys & KEY_LEFT) && (keys & KEY_RIGHT))

				if(!ship.rotating)

					ship.rotating = 1

					ship.rot_mag += ship.rot_accel

					if(ship.rot_mag>0)
						ship.rot_mag = min(ship.rot_mag,ship.rot_max_speed)
					else if (ship.rot_mag<0)
						ship.rot_mag = max(ship.rot_mag,-ship.rot_max_speed)

					if(!ship.rot_loop_on)
						spawn(0)
							ship.rotate_ship()

					if(ship.back_left)
						flick("[ship.icon_base]_thruster_back_l",ship.back_left)

					if(ship.front_right)
						flick("[ship.icon_base]_thruster_front_r",ship.front_right)

					spawn(ship.animation_speed)
						ship.rotating = 0


			if((keys & KEY_LEFT) && !(keys & KEY_RIGHT))

				if(!ship.rotating)
					ship.rotating = 1

					ship.rot_mag -= ship.rot_accel

					if(ship.rot_mag>0)
						ship.rot_mag = min(ship.rot_mag,ship.rot_max_speed)
					else if (ship.rot_mag<0)
						ship.rot_mag = max(ship.rot_mag,-ship.rot_max_speed)

					if(!ship.rot_loop_on)
						spawn(0)
							ship.rotate_ship()

					if(ship.front_left)
						flick("[ship.icon_base]_thruster_front_l",ship.front_left)

					if(ship.back_right)
						flick("[ship.icon_base]_thruster_back_r",ship.back_right)

					spawn(ship.animation_speed)
					ship.rotating = 0

		return ship.animation_speed

/datum/movement_controller/artemis/manta

	New(var/obj/artemis/manta/M)
		..()
		ship = M

	keys_changed(mob/owner, keys, changed)
		..()

	process_move(mob/owner, keys)
		var/mob/user = ship.my_pilot
		var/obj/artemis/manta/M = ship
		if(!istype(M))
			return

		if (is_incapacitated(user))
			return

		if (M.engine_check()) // ENGINE CHECK TO BE EXPANDED LATER

			if(keys & KEY_FORWARD)

				if(!M.accelerating)

					var/new_mag = null

					var/new_angle = null

					if(M.vel_mag <= 0)
						new_angle = M.ship_angle
						new_mag = M.accel
					else
						new_mag = sqrt(M.vel_mag**2 + M.accel**2 + 2*M.vel_mag*M.accel*cos(M.ship_angle-M.vel_angle))
						new_mag = min(M.max_speed,new_mag)

						var/arctan_result = (M.ship_angle == M.vel_angle) ? 0 : arctan(((M.accel*sin(M.ship_angle-M.vel_angle))/(M.vel_mag + M.accel*cos(M.ship_angle-M.vel_angle))))

						new_angle = M.vel_angle + arctan_result

					M.vel_mag = new_mag

					M.vel_angle = new_angle

					M.accelerating = 1

					M.update_my_stuff()

					spawn(M.animation_speed)
						M.accelerating = 0

			if(keys & KEY_BACKWARD)

				if(!M.accelerating)

					M.vel_mag -= (M.accel*2)
					M.vel_mag = max(M.vel_mag,0)
					if(M.vel_mag == 0)
						M.vel_angle = 0

					M.accelerating = 1

					M.update_my_stuff()

					spawn(M.animation_speed)
						M.accelerating = 0

			if(!M.vel_mag)
				return

			if(!(keys & KEY_LEFT) && (keys & KEY_RIGHT))

				if(!M.rotating)

					M.rotating = 1

					M.rot_mag += M.rot_accel

					if(M.rot_mag>0)
						M.rot_mag = min(M.rot_mag,M.rot_max_speed)
					else if (M.rot_mag<0)
						M.rot_mag = max(M.rot_mag,-M.rot_max_speed)

					if(!M.rot_loop_on)
						spawn(0)
							M.rotate_ship()

					spawn(M.animation_speed)
						M.rotating = 0


			if((keys & KEY_LEFT) && !(keys & KEY_RIGHT))

				if(!M.rotating)
					M.rotating = 1

					M.rot_mag -= M.rot_accel

					if(M.rot_mag>0)
						M.rot_mag = min(M.rot_mag,M.rot_max_speed)
					else if (M.rot_mag<0)
						M.rot_mag = max(M.rot_mag,-M.rot_max_speed)

					if(!M.rot_loop_on)
						spawn(0)
							M.rotate_ship()

					if(M.front_left)
						flick("[M.icon_base]_thruster_front_l",M.front_left)

					if(M.back_right)
						flick("[M.icon_base]_thruster_back_r",M.back_right)

					spawn(M.animation_speed)
					M.rotating = 0

		return ship.animation_speed
