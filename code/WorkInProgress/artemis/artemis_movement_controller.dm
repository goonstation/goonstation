#ifdef ENABLE_ARTEMIS

/datum/movement_controller/artemis

	var/obj/artemis/ship

	New(var/obj/artemis/A)
		..()
		ship = A

	keys_changed(mob/owner, keys, changed)
		attempt_move(owner)
		..()

	process_move(mob/owner, keys)
		var/mob/user = ship.my_pilot

		if (is_incapacitated(user))
			return

		if(ship.control_lock && keys)
			user.show_message(SPAN_ALERT("The controls are locked!"))
			return

		if (ship.engine_check()) // ENGINE CHECK HERE LATER

			if( keys & KEY_THROW )
				if(!ship.full_throttle)
					ship.full_throttle = TRUE
					ship.accel *= 2
					src.ship.controls.myhud.throttle_stick.icon_state = "throttle_up"

					if(ship.back)
						animate(ship.back, transform=matrix().Scale(1.2), loop=-1, time=3)
						animate(transform=matrix(), loop=-1, time=4)
						ship.back.color = "#f0f"
			else
				if(ship.full_throttle)
					ship.full_throttle = FALSE
					ship.accel = initial(ship.accel)
					src.ship.controls.myhud.throttle_stick.icon_state = "throttle_down"
					if(ship.back)
						animate(ship.back, transform=matrix(), loop=0, time=6)
						ship.back.color = "#fff"

			if((keys & KEY_FORWARD) && !(keys & KEY_BACKWARD))

				if(!ship.accelerating)

					var/new_mag = null

					var/new_angle = null

					if(ship.vel_mag <= 0)
						new_angle = ship.ship_angle
						new_mag = ship.accel
					else
						var/arctan_result
						new_mag = sqrt(ship.vel_mag**2 + ship.accel**2 + 2*ship.vel_mag*ship.accel*cos(ship.ship_angle-ship.vel_angle))
						new_mag = min(ship.max_speed,new_mag)

						if(new_mag) //check for div/0
							arctan_result = (ship.ship_angle == ship.vel_angle) ? 0 : arctan(((ship.accel*sin(ship.ship_angle-ship.vel_angle))/(ship.vel_mag + ship.accel*cos(ship.ship_angle-ship.vel_angle))))

						new_angle = ship.vel_angle + arctan_result

					ship.vel_mag = new_mag

					ship.vel_angle = new_angle

					ship.accelerating = 1

					ship.update_my_stuff()

					if(ship.back)
						FLICK("[ship.icon_base]_thruster_back",ship.back)

					if(ship.back_right)
						FLICK("[ship.icon_base]_thruster_back_r",ship.back_right)

					if(ship.back_left)
						FLICK("[ship.icon_base]_thruster_back_l",ship.back_left)
					ship.engines.use_power(list("sw", "se", "s"), ship.full_throttle)


					SPAWN(ship.animation_speed)
						ship.accelerating = 0

			if(!(keys & KEY_FORWARD) && (keys & KEY_BACKWARD))

				if(!ship.accelerating)

					ship.vel_mag -= (ship.accel*2)
					ship.vel_mag = max(ship.vel_mag,0)
					if(ship.vel_mag == 0)
						ship.vel_angle = 0

						if(keys & KEY_RUN)
							ship.vel_mag += (ship.accel)
							ship.vel_angle = ship.ship_angle + 180

					ship.accelerating = 1

					ship.update_my_stuff()

					if(ship.front_left)
						FLICK("[ship.icon_base]_thruster_front_l",ship.front_left)
					if(ship.front_right)
						FLICK("[ship.icon_base]_thruster_front_r",ship.front_right)
					ship.engines.use_power(list("nw", "ne"))

					SPAWN(ship.animation_speed)
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
						SPAWN(0)
							ship.rotate_ship()

					if(ship.back_left)
						FLICK("[ship.icon_base]_thruster_back_l",ship.back_left)

					if(ship.front_right)
						FLICK("[ship.icon_base]_thruster_front_r",ship.front_right)
					ship.engines.use_power(list("ne", "sw"))

					SPAWN(ship.animation_speed)
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
						SPAWN(0)
							ship.rotate_ship()

					if(ship.front_left)
						FLICK("[ship.icon_base]_thruster_front_l",ship.front_left)

					if(ship.back_right)
						FLICK("[ship.icon_base]_thruster_back_r",ship.back_right)
					ship.engines.use_power(list("nw", "se"))

					SPAWN(ship.animation_speed)
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
					M.engines.use_power(list("s"))

					SPAWN(M.animation_speed)
						M.accelerating = 0

			if(keys & KEY_BACKWARD)

				if(!M.accelerating)

					M.vel_mag -= (M.accel*2)
					M.vel_mag = max(M.vel_mag,0)
					if(M.vel_mag == 0)
						M.vel_angle = 0

					M.accelerating = 1

					M.update_my_stuff()
					M.engines.use_power(list("nw", "ne"))

					SPAWN(M.animation_speed)
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
						SPAWN(0)
							M.rotate_ship()

					SPAWN(M.animation_speed)
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
						SPAWN(0)
							M.rotate_ship()

					if(M.front_left)
						FLICK("[M.icon_base]_thruster_front_l",M.front_left)

					if(M.back_right)
						FLICK("[M.icon_base]_thruster_back_r",M.back_right)

					SPAWN(M.animation_speed)
						M.rotating = 0

		return ship.animation_speed

#endif
