ADD_TO_NAMESPACE(ANIMATE)(proc/attack_twitch(atom/A, move_multiplier = 1, angle_multiplier = 1))
	if (!istype(A) || islivingobject(A))
		return		//^ possessed objects use an animate loop that is important for readability. let's not interrupt that with this dumb animation
	if(ON_COOLDOWN(A, "attack_twitch", 0.1 SECONDS))
		return
	var/which = A.dir

	var/ipx = A.pixel_x
	var/ipy = A.pixel_y
	var/movepx = 0
	var/movepy = 0
	switch(which)
		if (NORTH)
			movepy = 3
		if (WEST)
			movepx = -3
		if (SOUTH)
			movepy = -3
		if (EAST)
			movepx = 3
		if (NORTHEAST)
			movepx = 3
		if (NORTHWEST)
			movepy = 3
		if (SOUTHEAST)
			movepy = -3
		if (SOUTHWEST)
			movepx = -3
		else
			return

	movepx *= move_multiplier
	movepy *= move_multiplier

	var/x = movepx + ipx
	var/y = movepy + ipy
	//Shift pixel offset
	animate(A, pixel_x = x, pixel_y = y, time = 0.6,easing = EASE_OUT,flags=ANIMATION_PARALLEL)
	var/matrix/M = matrix(A.transform)
	animate(transform = turn(A.transform, (movepx - movepy) / move_multiplier * angle_multiplier * 4), time = 0.6, easing = EASE_OUT)
	animate(pixel_x = ipx, pixel_y = ipy, time = 0.6,easing = EASE_IN)
	animate(transform = M, time = 0.6, easing = EASE_IN)

ADD_TO_NAMESPACE(ANIMATE)(proc/hit_twitch(atom/A))
	if (!A || islivingobject(A)|| ON_COOLDOWN(A, "hit_twitch", 0.1 SECONDS))
		return
	var/which = 0
	if (usr)
		which = get_dir(usr,A)
	else
		which = pick(alldirs)

	if (!which)
		which = pick(alldirs)

	var/ipx = A.pixel_x
	var/ipy = A.pixel_y
	var/movepx = 0
	var/movepy = 0
	switch(which)
		if (NORTH)			movepy = 3
		if (WEST)			movepx = -3
		if (SOUTH)			movepy = -3
		if (EAST)			movepx = 3
		if (NORTHEAST)
			movepx = 2
			movepy = 2
		if (NORTHWEST)
			movepx = -2
			movepy = 2
			movepy = -2
		if (SOUTHEAST)
			movepx = 2
			movepy = -2
		if (SOUTHWEST)
			movepx = -2
			movepy = -2
		else
			return

	var/x = movepx + ipx
	var/y = movepy + ipy

	animate(A, pixel_x = x, pixel_y = y, time = 2,easing = EASE_IN,flags=ANIMATION_PARALLEL)
	animate(pixel_x = ipx, pixel_y = ipy, time = 2,easing = EASE_IN)

//only call this from disorient. ITS NOT YOURS DAD
ADD_TO_NAMESPACE(ANIMATE)(proc/violent_twitch(atom/A))
	SPAWN(0)
		var/matrix/target = matrix(A.transform)
		var/deg = rand(-45,45)
		target.Turn(deg)

		A.transform = target
		var/old_x = A.pixel_x
		var/old_y = A.pixel_y
		A.pixel_x += rand(-3,3)
		A.pixel_y += rand(-1,1)

		sleep(0.2 SECONDS)

		A.transform = A.transform.Turn(-deg)
		A.pixel_x = old_x
		A.pixel_y = old_y

// for vampire standup :)
ADD_TO_NAMESPACE(ANIMATE)(proc/violent_standup_twitch(atom/A))
	SPAWN(-1)
		var/offx
		var/offy
		var/angle
		for (var/i = 0, (i < 7 && A), i++)
			offx = rand(-3,3)
			offy = rand(-2,2)
			angle = rand(-45,45)
			animate(A, time = 0.5, transform = matrix().Turn(angle), easing = JUMP_EASING, pixel_x = offx, pixel_y = offy, flags = ANIMATION_PARALLEL|ANIMATION_RELATIVE)
			animate(time = 0.5, transform = matrix().Turn(-angle), easing = JUMP_EASING, pixel_x = -offx, pixel_y = -offy, flags = ANIMATION_RELATIVE)
			sleep(0.1 SECONDS)

ADD_TO_NAMESPACE(ANIMATE)(proc/violent_standup_twitch_parametrized(atom/A, off_x = 3, off_y = 2, input_angle = 45, iterations = 7, sleep_length = 0.1 SECONDS, effect_scale = 1))
	SPAWN(-1)
		var/offx = off_x
		var/offy = off_y
		var/angle = input_angle
		for (var/i = 0, (i < iterations && A), i++)
			offx = rand(-off_x, off_x) * effect_scale
			offy = rand(-off_y, off_y) * effect_scale
			angle = rand(-angle, angle) * effect_scale
			animate(A, time = 0.5, transform = matrix().Turn(angle), easing = JUMP_EASING, pixel_x = offx, pixel_y = offy, flags = ANIMATION_PARALLEL|ANIMATION_RELATIVE)
			animate(time = 0.5, transform = matrix().Turn(-angle), easing = JUMP_EASING, pixel_x = -offx, pixel_y = -offy, flags = ANIMATION_RELATIVE)
			sleep(sleep_length)

ADD_TO_NAMESPACE(ANIMATE)(proc/eat_twitch(atom/A))
	var/matrix/squish_matrix = matrix(A.transform)
	squish_matrix.Scale(1,0.92)
	var/matrix/M = matrix(A.transform)
	var/ipy = A.pixel_y

	animate(A, transform = squish_matrix, time = 1,easing = EASE_OUT, flags=ANIMATION_PARALLEL)
	animate(pixel_y = -1, time = 1,easing = EASE_OUT)
	animate(transform = M, time = 1, easing = EASE_IN)
	animate(pixel_y = ipy, time = 1,easing = EASE_IN)
