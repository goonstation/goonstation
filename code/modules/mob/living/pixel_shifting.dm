/mob/living/proc/pixel_shift(dir)
	if(ON_COOLDOWN(src, "pixel_shift_cooldown", 0.4 DECI SECONDS))
		return

	switch(dir)
		if(NORTH)
			if(pixel_y <= 16)
				pixel_y++
				pixel_shifted = TRUE
		if(EAST)
			if(pixel_x <= 16)
				pixel_x++
				pixel_shifted = TRUE
		if(SOUTH)
			if(pixel_y >= -16)
				pixel_y--
				pixel_shifted = TRUE
		if(WEST)
			if(pixel_x >= -16)
				pixel_x--
				pixel_shifted = TRUE

/mob/living/proc/pixel_shift_reset()
	if(!pixel_shifted)
		return
	pixel_shifted = FALSE
	pixel_x = 0
	pixel_y = 0
