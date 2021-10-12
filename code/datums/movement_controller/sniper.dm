/datum/movement_controller/sniper_look
	var/input_x = 0
	var/input_y = 0
	var/const/spd = 12
	var/delay = 1

	keys_changed(mob/owner, keys, changed)
		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT|KEY_RUN))
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner

				if (!owner.client.check_key(KEY_RUN) || !(H.special_sprint & SPRINT_SNIPER))
					for (var/obj/item/gun/kinetic/sniper/S in owner.equipped_list(check_for_magtractor = 0))
						S.just_stop_snipe(owner)

					if (owner.use_movement_controller && istype(owner.use_movement_controller, /obj/item/gun/kinetic/sniper))
						var/obj/item/gun/kinetic/sniper/S = owner.use_movement_controller
						S.just_stop_snipe(owner)

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
			owner.client.pixel_x += input_x * spd
			owner.client.pixel_y += input_y * spd

			animate(owner.client, pixel_x = owner.client.pixel_x + input_x * spd, pixel_y = owner.client.pixel_y + input_y * spd, time = delay, flags = ANIMATION_END_NOW)

		return 0.5

/datum/movement_controller/designator_look //Stolen for the nukeop laser designator
	var/input_x = 0
	var/input_y = 0
	var/const/spd = 12
	var/delay = 1

	keys_changed(mob/owner, keys, changed)
		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT|KEY_RUN))
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner

				if (!owner.client.check_key(KEY_RUN) || !(H.special_sprint & SPRINT_DESIGNATOR))
					for (var/obj/item/device/laser_designator/S in owner.equipped_list(check_for_magtractor = 0))
						S.just_stop_designating(owner)

					if (owner.use_movement_controller && istype(owner.use_movement_controller, /obj/item/device/laser_designator))
						var/obj/item/device/laser_designator/S = owner.use_movement_controller
						S.just_stop_designating(owner)

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
			owner.client.pixel_x += input_x * spd
			owner.client.pixel_y += input_y * spd

			animate(owner.client, pixel_x = owner.client.pixel_x + input_x * spd, pixel_y = owner.client.pixel_y + input_y * spd, time = delay, flags = ANIMATION_END_NOW)

		return 0.5
