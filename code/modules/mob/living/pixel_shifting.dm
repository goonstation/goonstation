#define PIXEL_TOTAL_MAX 22
#define PIXEL_ONEDIR_MAX 14

/mob/living/proc/pixel_shift(dir)
	if(ON_COOLDOWN(src, "pixel_shift_cooldown", 0.4 DECI SECONDS))
		return

	switch(dir)
		if(NORTH)
			if(pixel_y <= PIXEL_ONEDIR_MAX && (abs(pixel_x) + abs(pixel_y + 1) <= PIXEL_TOTAL_MAX))
				pixel_y++
				pixel_shifted = TRUE
		if(EAST)
			if(pixel_x <= PIXEL_ONEDIR_MAX && (abs(pixel_x + 1) + abs(pixel_y) <= PIXEL_TOTAL_MAX))
				pixel_x++
				pixel_shifted = TRUE
		if(SOUTH)
			if(pixel_y >= -PIXEL_ONEDIR_MAX && (abs(pixel_x) + abs(pixel_y - 1) <= PIXEL_TOTAL_MAX))
				pixel_y--
				pixel_shifted = TRUE
		if(WEST)
			if(pixel_x >= -PIXEL_ONEDIR_MAX && (abs(pixel_x - 1) + abs(pixel_y) <= PIXEL_TOTAL_MAX))
				pixel_x--
				pixel_shifted = TRUE

/mob/living/proc/pixel_shift_reset()
	if(!pixel_shifted)
		return
	pixel_shifted = FALSE
	pixel_x = 0
	pixel_y = 0

#undef PIXEL_TOTAL_MAX
#undef PIXEL_ONEDIR_MAX
