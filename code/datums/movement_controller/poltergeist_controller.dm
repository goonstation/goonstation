/datum/movement_controller/poltergeist
	var/input_x = 0
	var/input_y = 0
	var/const/spd = 12
	var/delay = 1
	var/const/maxx_dist = 160 //pixels. turfs are 32px, this means 7 turf radius.
	var/const/maxy_dist = 160 //

	keys_changed(mob/owner, keys, changed)
		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
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
			// owner.client.pixel_x += input_x * spd
			// owner.client.pixel_y += input_y * spd
			var/temp_x = owner.client.pixel_x + input_x * spd
			var/temp_y = owner.client.pixel_y + input_y * spd

			if (temp_x >= maxx_dist)
				temp_x = maxx_dist
			else if (temp_x <= -maxx_dist)
				temp_x = -maxx_dist
			if (temp_y >= maxy_dist)
				temp_y = maxy_dist
			else if (temp_y <= -maxy_dist)
				temp_y = -maxy_dist


			animate(owner.client, pixel_x = temp_x, pixel_y = temp_y, time = delay, flags = ANIMATION_END_NOW)

		return 0.5
