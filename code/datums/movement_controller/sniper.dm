/datum/movement_controller/sniper_scope
	var/input_x = 0
	var/input_y = 0
	var/speed = 12
	var/max_range = 3200
	var/delay = 1

	New(speed = 12, max_range = 3200)
		..()
		src.speed = speed
		src.max_range = max_range

	keys_changed(mob/owner, keys, changed)
		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT|KEY_RUN))
			if (ishuman(owner))

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

				//normalized vector
				var/input_magnitude = vector_magnitude(input_x, input_y)
				if (input_magnitude)
					input_x /= input_magnitude
					input_y /= input_magnitude

					attempt_move(owner)

	process_move(mob/owner, keys)
		if (owner.client)
			var/delta_x = owner.client.pixel_x
			var/delta_y = owner.client.pixel_y
			owner.client.pixel_x += input_x * speed
			owner.client.pixel_y += input_y * speed

			//maximum range limits
			if(src.max_range)
				var/current_magnitude = vector_magnitude(owner.client.pixel_x, owner.client.pixel_y)
				if(current_magnitude >= src.max_range)
					owner.client.pixel_x *= src.max_range / current_magnitude
					owner.client.pixel_y *= src.max_range / current_magnitude
			else
				animate(owner.client, pixel_x = owner.client.pixel_x + input_x * speed, pixel_y = owner.client.pixel_y + input_y * speed, time = delay, flags = ANIMATION_END_NOW)
			delta_x = owner.client.pixel_x - delta_x
			delta_y = owner.client.pixel_y - delta_y
			if(delta_x || delta_y)
				SEND_SIGNAL(owner, COMSIG_MOB_SCOPE_MOVED, delta_x, delta_y)

		return 0.5
//When this movement controller starts being used
/datum/movement_controller/sniper_scope/proc/start()
//When this movement controller stops being used
/datum/movement_controller/sniper_scope/proc/stop()

//A lightweight scope, better suited for medium-range sniping.
/datum/movement_controller/sniper_scope/light
	speed = 64
	max_range = 320
	delay = 2
	var/offset_total_x = 0
	var/offset_total_y = 0

	New(speed = 64, max_range = 320)
		..()
		src.speed = speed
		src.max_range = max_range

	process_move(mob/owner, keys)
		if (owner.client)
			var/target_x = input_x * src.max_range
			var/target_y = input_y * src.max_range
			//maximum range limits
			var/diff_x = (target_x - offset_total_x)
			var/diff_y = (target_y - offset_total_y)
			var/distance = vector_magnitude(diff_x,diff_y)
			if(input_x || input_y)
				owner.set_dir(vector_to_dir(input_x,input_y))
			if (distance > 0)
				var/moved_total = min(1,speed/distance)
				var/delta_x = floor(diff_x * moved_total)
				var/delta_y = floor(diff_y * moved_total)
				offset_total_x += delta_x
				offset_total_y += delta_y
				animate(owner.client, pixel_x = delta_x, pixel_y = delta_y, 0.5, flags = ANIMATION_RELATIVE)
				if(delta_x || delta_y)
					SEND_SIGNAL(owner, COMSIG_MOB_SCOPE_MOVED, delta_x, delta_y)


		return 0.5
	stop()
		offset_total_x = 0
		offset_total_y = 0
