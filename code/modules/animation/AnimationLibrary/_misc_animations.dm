/**
 *	Global Animation Namespace
 *
 *	Contains various generic animation sequences used throughout the codebase.
 */
CREATE_NAMESPACE(ANIMATE)


ADD_TO_NAMESPACE(ANIMATE)(proc/stop(atom/A))
	animate(A)

ADD_TO_NAMESPACE(ANIMATE)(proc/reset(atom/A))
	if (isclient(A))
		var/client/C = A
		C.set_color(COLOR_MATRIX_IDENTITY)
	A.color = COLOR_MATRIX_IDENTITY
	A.transform = null
	A.clear_filters()
	A.alpha = 255
	A.pixel_x = 0
	A.pixel_y = 0
	A.pixel_z = 0
	animate(A)

ADD_TO_NAMESPACE(ANIMATE)(proc/buff_in(atom/A))
	var/matrix/M = matrix(A.transform)
	A.transform = A.transform.Scale(0.001)
	A.alpha = 0
	animate(A, alpha = 255, transform = M, time = 10, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/buff_out(atom/A))
	var/matrix/M = matrix(A.transform)
	A.alpha = 255
	animate(A, alpha = 0, transform = A.transform.Scale(2, 2), time = 10, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
	animate(transform = M)

ADD_TO_NAMESPACE(ANIMATE)(proc/buff_out_time(atom/A, time = 10))
	var/matrix/M1 = matrix()
	var/matrix/M2 = matrix()
	M2.Scale(1.3,1.3)
	A.transform = M1
	A.alpha = 255
	animate(A, alpha = 0,  transform = M2, time = time, easing = CUBIC_EASING | EASE_IN)

ADD_TO_NAMESPACE(ANIMATE)(proc/angry_wibble(atom/A))
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(0.8), time = 1, easing = ELASTIC_EASING, loop = -1)
	animate(transform = M, time = 3, easing = ELASTIC_EASING, loop = -1)

ADD_TO_NAMESPACE(ANIMATE)(proc/melt_pixel(atom/A))
	if (!istype(A))
		return
	//A.alpha = 200
	animate(A, pixel_y = 0, time = 50 - A.pixel_y, alpha = 175, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, easing = LINEAR_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/explode_pixel(atom/A))
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	side = pick(-1, 1)
	animate(A, pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255, flags = ANIMATION_PARALLEL)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
	animate(pixel_x = A.pixel_x + rand(-32, 32), pixel_y = A.pixel_y + rand(-32, 32), transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = 7+rand(-1,4), alpha = 0, easing = SINE_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/weird(atom/A))
	if (!istype(A))
		return
	//A.alpha = 200
	animate(A, pixel_x = 20*sin(A.pixel_x), time = 30 + 20*sin(A.pixel_x), alpha = 175, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = A.pixel_x, time = 30 + 20*sin(A.pixel_x), alpha = 175, easing = ELASTIC_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/door_squeeze(atom/A))
	if (!istype(A))
		return
	//A.alpha = 200
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(0.6, 1), time = 3,easing = BOUNCE_EASING,flags=ANIMATION_PARALLEL)
	animate(transform = M, time = 3,easing = BOUNCE_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/smush(atom/A, y_scale = 0.9))
	if (!istype(A))
		return
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(1, y_scale), time = 2, easing = BOUNCE_EASING, flags=ANIMATION_PARALLEL)
	animate(transform = M, time = 2, easing = BOUNCE_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/flockdrone_item_absorb(atom/A))
	if(!istype(A))
		return
	var/matrix/first_matrix = matrix()
	first_matrix.Turn(-45)
	first_matrix.Scale(1.2, 0.6)
	var/matrix/second_matrix = matrix()
	first_matrix.Turn(45)
	first_matrix.Scale(0.6, 1.2)
	animate(A, loop=-1, color="#00ffd7", transform=first_matrix, time=20)
	animate(loop=-1, color="#ffffff", transform=second_matrix, time=20)

ADD_TO_NAMESPACE(ANIMATE)(proc/flock_convert_complete(atom/A))
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	A.color = col
	animate(A, color=null, time=5)

ADD_TO_NAMESPACE(ANIMATE)(proc/flock_drone_split(atom/A))
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	A.color = null
	animate(A, color=col, alpha=0, time=1)

ADD_TO_NAMESPACE(ANIMATE)(proc/flock_passthrough(atom/A))
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	var/matrix/M = matrix(A.transform)
	animate(A, color=col, transform=A.transform.Scale(0.4), time=3, easing=BOUNCE_EASING, flags=ANIMATION_PARALLEL)
	animate(color=null, transform=M, time=3, easing=BOUNCE_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/flock_floorrun_start(atom/A))
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	var/matrix/shrink = matrix()
	shrink.Scale(0.0, 0.0)
	animate(A, color=col, transform=shrink, time=5, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/flock_floorrun_end(atom/A))
	if(!istype(A))
		return
	animate(A, color=null, transform=null, time=5, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/tile_dropaway(atom/A))
	if(!istype(A))
		return
	if(prob(10))
		playsound(A, "sound/effects/creaking_metal[pick("1", "2")].ogg", 40, 1)
	var/image/underneath = image('icons/effects/white.dmi')
	underneath.appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA | PIXEL_SCALE
	A.underlays += underneath
	var/matrix/pivot = matrix()
	pivot.Scale(0.2, 1.0)
	pivot.Translate(-16, 0)
	var/matrix/shrink = matrix()
	shrink.Scale(0.0, 0.0)
	animate(A, color="#808080", transform=pivot, time=30, easing=BOUNCE_EASING)
	animate(color="#FFFFFF", alpha=0, transform=shrink, time=10, easing=SINE_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/float(atom/A, loopnum = -1, floatspeed = 20, random_side = 1))
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side) side = pick(-1, 1)

	SPAWN(rand(1,10))
		if (A)
			var/matrix/M = matrix(A.transform)
			animate(A, pixel_y = 32, transform = M.Multiply(matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE)), time = floatspeed, loop = loopnum, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
			animate(pixel_y = 0, transform = M.Multiply(matrix(floatdegrees * (side == 1 ? -1:1), MATRIX_ROTATE)), time = floatspeed, loop = loopnum, easing = SINE_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/levitate(atom/A, loopnum = -1, floatspeed = 20, random_side = 1))
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side) side = pick(-1, 1)

	SPAWN(rand(1,10))
		if (A)
			var/matrix/M = matrix(A.transform)
			var/initial_y = A.pixel_y
			animate(A, pixel_y = initial_y + 4, transform = A.transform.Multiply(matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE)), time = floatspeed, loop = loopnum, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
			animate(pixel_y = initial_y, transform = M, time = floatspeed, loop = loopnum, easing = SINE_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/lag(atom/A, steps = 15, loopnum = -1, magnitude = 10, step_time_low = 0.2 SECONDS, step_time_high = 0.25 SECONDS))
	if (!istype(A))
		return
	for (var/i in 1 to steps)
		if (i == 1)
			animate(A,
				pixel_x = rand(-magnitude, magnitude),
				pixel_y = rand(-magnitude, magnitude),
				time = randfloat(step_time_low, step_time_high),
				loop = loopnum,
				easing = JUMP_EASING,
				flags = ANIMATION_PARALLEL
			)
		else
			animate(
				pixel_x = rand(-magnitude, magnitude),
				pixel_y = rand(-magnitude, magnitude),
				time = randfloat(step_time_low, step_time_high),
				loop = loopnum,
				easing = JUMP_EASING,
				flags = ANIMATION_PARALLEL
			)

ADD_TO_NAMESPACE(ANIMATE)(proc/revenant_shockwave(atom/A, loopnum = -1, floatspeed = 20, random_side = 1))
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side) side = pick(-1, 1)

	SPAWN(rand(1,10))
		if (A)
			var/matrix/M = matrix(A.transform)
			animate(A, pixel_y = 8, transform = M.Multiply(matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE)), time = floatspeed, loop = loopnum, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
			animate(pixel_y = 0, transform = M.Multiply(matrix(floatdegrees * (side == 1 ? -1:1), MATRIX_ROTATE)), time = floatspeed, loop = loopnum, easing = SINE_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/glitchy_freakout(atom/A))
	if (!istype(A))
		return
	var/matrix/M = matrix(A.transform)
	var/looper = rand(3,5)
	while(looper > 0)
		looper--
		animate(A, transform = A.transform.Scale(rand(1,20), rand(1,20)), pixel_x = A.pixel_x + rand(-12,12), pixel_z = A.pixel_z + rand(-12,12), time = 3, loop = 1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		animate(transform = matrix(rand(-360,360), MATRIX_ROTATE), time = 3, loop = 1, easing = LINEAR_EASING)
		animate(transform = A.transform.Scale(1,1), pixel_x = 0, pixel_z = 0, time = 1, loop = 1, easing = LINEAR_EASING)
		animate(transform = M, time = 1, loop = 1, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/fading_leap_up(atom/A))
	if (!istype(A))
		return
	var/do_loops = 15
	while (do_loops > 0)
		do_loops--
		animate(A, transform = A.transform.Scale(1.2), pixel_z = A.pixel_z + 12, alpha = A.alpha - 17, time = 1, loop = 1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		sleep(0.1 SECONDS)
	A.alpha = 0

ADD_TO_NAMESPACE(ANIMATE)(proc/fading_leap_down(atom/A))
	if (!istype(A))
		return
	var/matrix/M = matrix(A.transform)
	var/do_loops = 15
	M.Scale(18,18)
	while (do_loops > 0)
		do_loops--
		animate(A, transform = A.transform.Scale(0.8), pixel_z = A.pixel_z - 12, alpha = A.alpha + 17, time = 1, loop = 1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		sleep(0.1 SECONDS)
	animate(A, transform = M, pixel_z = 0, alpha = 255, time = 1, loop = 1, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/shake(atom/A, amount = 5, x_severity = 2, y_severity = 2, return_x = 0, return_y = 0))
	// Wiggles the sprite around on its tile then returns it to normal
	if (!istype(A))
		return
	if (!isnum(amount) || !isnum(x_severity) || !isnum(y_severity))
		return
	amount = clamp(amount, 1, 50)
	x_severity = clamp(x_severity, -32, 32)
	y_severity = clamp(y_severity, -32, 32)

	var/x_severity_inverse = 0 - x_severity
	var/y_severity_inverse = 0 - y_severity

	animate(A, pixel_y = return_y+rand(y_severity_inverse,y_severity), pixel_x = return_x+rand(x_severity_inverse,x_severity),time = 1,loop = amount, easing = ELASTIC_EASING, flags=ANIMATION_PARALLEL)
	SPAWN(amount)
		if (A)
			animate(A, pixel_y = return_y, pixel_x = return_x,time = 1,loop = 1, easing = LINEAR_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/flubber(atom/A, jiggle_duration_start = 6, jiggle_duration_end = 12, amount = 3, severity = 1.5))
	//makes the person quickly increase it's y-size up and down
	if (!istype(A))
		return
	var/matrix/M = matrix(A.transform)
	var/current_jiggle_duration = jiggle_duration_start
	var/do_loops = amount
	SPAWN(0)
		while (do_loops > 0)
			do_loops--
			animate(A, transform = A.transform.Scale(1, severity), time = round(current_jiggle_duration / 2), easing = BOUNCE_EASING, flags=ANIMATION_PARALLEL)
			sleep(round(current_jiggle_duration / 2))
			animate(A, transform = M, time = round(current_jiggle_duration / 2), easing = BOUNCE_EASING, flags=ANIMATION_PARALLEL)
			sleep(round(current_jiggle_duration / 2) )
			//make the jiggling slower/faster towards the end
			current_jiggle_duration += (jiggle_duration_end - jiggle_duration_start) / min(1,(amount - 1))

ADD_TO_NAMESPACE(ANIMATE)(proc/clownspell(atom/A))
	if (!istype(A))
		return
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(1.3, 1.3), time = 5, color = "#00ff00", easing = BACK_EASING ,flags=ANIMATION_PARALLEL)
	animate(transform = M, time = 5, color = "#ffffff", easing = ELASTIC_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/wiggle_then_reset(atom/A, loops = 5, speed = 5, x_var = 3, y_var = 3))
	if (!istype(A) || !loops || !speed)
		return
	animate(A, pixel_x = rand(-x_var, x_var), pixel_y = rand(-y_var, y_var), time = speed * 2,loop = loops, easing = rand(2,7), flags = ANIMATION_PARALLEL)
	animate(pixel_x = 0, pixel_y = 0, time = speed, easing = rand(2,7))

ADD_TO_NAMESPACE(ANIMATE)(proc/blink(atom/A))
	if (!istype(A))
		return
	var/matrix/Orig = A.transform
	A.Scale(0.2,0.2)
	A.alpha = 50
	animate(A,transform = Orig, time = 3, alpha = 255, easing = CIRCULAR_EASING, flags = ANIMATION_PARALLEL)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/bullspellground(atom/A, spell_color = "#cccccc"))
	if (!istype(A))
		return
	animate(A, time = 5, color = spell_color)
	animate(time = 5, color = "#ffffff")
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/spin(atom/A, dir = "L", T = 1, looping = -1, parallel = TRUE))
	if (!istype(A))
		return

	var/matrix/M = A.transform
	var/turn = -90
	if (dir == "R")
		turn = 90

	var/flag = parallel ? ANIMATION_PARALLEL : null

	animate(A, transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping, flags = flag)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)

ADD_TO_NAMESPACE(ANIMATE)(proc/peel_slip(atom/A, dir, T = 0.55 SECONDS, height = 16, stun_duration = 2 SECONDS, n_flips = 1))
	if(!A.rest_mult)
		animate(A) // stop current animations, might be safe to remove later
		var/matrix/M = A.transform
		if(isnull(dir))
			if(A.dir == EAST)
				dir = "L"
			else if(A.dir == WEST)
				dir = "R"
			else
				dir = pick("L", "R")

		var/turn = -90
		if (dir == "R")
			turn = 90

		var/flip_anim_step_time = T / (1 + 4 * n_flips)
		animate(A, transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = flip_anim_step_time, flags = ANIMATION_PARALLEL)
		for(var/i in 1 to n_flips)
			animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = flip_anim_step_time)
			animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = flip_anim_step_time)
			animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = flip_anim_step_time)
			animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = flip_anim_step_time)
		var/matrix/M2 = A.transform
		animate(transform = matrix(M, 1.2, 0.7, MATRIX_SCALE | MATRIX_MODIFY), time = T/8)
		animate(transform = M2, time = T/8)

		animate(A, pixel_y=height, time=T/2, flags=ANIMATION_PARALLEL)
		animate(pixel_y=-4, time=T/2)

		A.rest_mult = turn / 90

	if(isliving(A))
		var/mob/living/L = A
		if(!A.hasStatus("knockdown"))
			L.changeStatus("knockdown", stun_duration)
			L.force_laydown_standup()
		if(!L.lying) // oh no, they didn't fall down actually, time to unflip them 😰
			ANIMATE.rest(L, TRUE)

ADD_TO_NAMESPACE(ANIMATE)(proc/handspider_flipoff(atom/A, dir = "L", T = 1, looping = -1))
	if (!istype(A))
		return

	var/matrix/M = A.transform
	var/turn = -180
	if (dir == "R")
		turn = 180

	var/opy = A.pixel_y
	//Total animation time will be T*9
	animate(A, transform = matrix(M, turn/3, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn/3, MATRIX_ROTATE | MATRIX_MODIFY), pixel_y = opy + 4, time = T, loop = looping)
	animate(transform = matrix(M, turn/3, MATRIX_ROTATE | MATRIX_MODIFY),pixel_y = opy, time = T, loop = looping)
	sleep(T*5)
	animate(A, transform = matrix(M, turn/3, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn/3, MATRIX_ROTATE | MATRIX_MODIFY), pixel_y = opy + 4, time = T, loop = looping)
	animate(transform = matrix(M, turn/3, MATRIX_ROTATE | MATRIX_MODIFY),pixel_y = opy, time = T, loop = looping)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/bumble(atom/A, loopnum = -1, floatspeed = 10, Y1 = 3, Y2 = -3, slightly_random = 1))
	if (!istype(A))
		return

	if (slightly_random)
		floatspeed = floatspeed * (rand(10,14) / 10)//rand_deci(1, 0, 1, 4)
	animate(A, pixel_y = Y1, time = floatspeed, loop = loopnum, easing = LINEAR_EASING)//, flags = ANIMATION_END_NOW) - enable this once we can compile with 511 maybe (I forgot to test it)
	animate(pixel_y = Y2, time = floatspeed, loop = loopnum, easing = LINEAR_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/beespin(atom/A, dir = 90, T = 1.5, loops = 1))
	if (!istype(A))
		return

	var/turndir
	var/matrix/turned

	if (isnum(dir) && dir > 0)
		A.set_dir(WEST)
		turndir = 90
		turned = matrix(A.transform, 90, MATRIX_ROTATE)

	else
		A.set_dir(EAST)
		turndir = -90
		turned = matrix(A.transform, -90, MATRIX_ROTATE)

	animate(A, pixel_y = (A.pixel_y + 4), pixel_x = (A.pixel_x + 4), transform = turned, time = T, loop = loops, dir = EAST, flags = ANIMATION_PARALLEL)
	animate(pixel_y = (A.pixel_y + 6), transform = turned.Turn(turndir), time = T, loop = loops, dir = EAST)
	animate(pixel_y = (A.pixel_y - 4), transform = turned.Turn(turndir), time = T, loop = loops, dir = EAST)
	animate(pixel_y = (A.pixel_y - 6), pixel_x = (A.pixel_x - 4), transform = turned.Turn(turndir), time = T, loop = loops, dir = EAST)

	animate(pixel_y = (A.pixel_y - 4), pixel_x = (A.pixel_x + 4), transform = turned.Turn(turndir), time = T, loop = loops, dir = EAST)
	animate(pixel_y = (A.pixel_y - 4), transform = turned.Turn(turndir), time = T, loop = loops, dir = EAST)
	animate(pixel_y = (A.pixel_y + 4), transform = turned.Turn(turndir), time = T, loop = loops, dir = EAST)
	animate(pixel_y = (A.pixel_y + 4), pixel_x = (A.pixel_x - 4), transform = turned.Turn(turndir), time = T, loop = loops, dir = EAST)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/emote(atom/A, emote))
	if (!istype(A))
		return
	var/obj/effect/E = new emote(A.loc)
	E.Scale(0.05, 0.05)
	E.alpha = 0
	animate(E,transform = matrix(0.5, MATRIX_SCALE), time = 20, alpha = 255, pixel_y = 27, easing = ELASTIC_EASING)
	animate(time = 5, alpha = 0, pixel_y = -16, easing = CIRCULAR_EASING)
	SPAWN(3 SECONDS) qdel(E)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/horizontal_wiggle(atom/A, loopnum = 5, speed = 10, X1 = 3, X2 = -3, slightly_random = 1))
	if (!istype(A))
		return

	if (slightly_random)
		var/rand_var = (rand(10, 14) / 10)
		DEBUG_MESSAGE("rand_var [rand_var]")
		speed = speed * rand_var
	animate(A, pixel_x = X1, time = speed, loop = loopnum, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = X2, time = speed, loop = loopnum, easing = LINEAR_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/slide(atom/A, px, py, T = 10, ease = SINE_EASING))
	if(!istype(A))
		return

	var/image/underlay
	if (isturf(A))
		underlay = image('icons/turf/floors.dmi', icon_state = "solid_black")
		underlay.appearance_flags |= RESET_TRANSFORM
		underlay.plane = PLANE_UNDERFLOOR
		A.underlays += underlay

	animate(A, transform = list(1, 0, px, 0, 1, py), time = T, easing = ease, flags=ANIMATION_PARALLEL)

	if (underlay)
		SPAWN(T)
			A.underlays -= underlay
			qdel(underlay)

ADD_TO_NAMESPACE(ANIMATE)(proc/rest(atom/A, stand))
	if(!istype(A))
		return
	if(stand)
		animate(A, pixel_x = 0, pixel_y = 0, transform = A.transform.Turn(A.rest_mult * -90), time = 3, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
		A.rest_mult = 0
	else if(!A.rest_mult)
		var/fall_left_or_right = pick(1, -1) //A multiplier of one makes the atom rotate to the right, negative makes them fall to the left.
		animate(A, pixel_x = 0, pixel_y = -4, transform = A.transform.Turn(fall_left_or_right * 90), time = 2, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
		A.rest_mult = fall_left_or_right

ADD_TO_NAMESPACE(ANIMATE)(proc/rest_180(atom/A, stand, pixel_y_offset = 5))
	if(!istype(A))
		return
	var/rest_mult = stand ? A.rest_mult : pick(1, -1)
	var/matrix/M1 = UNLINT(A.transform.Translate(0, pixel_y_offset).Turn(rest_mult * 90).Translate(0, -pixel_y_offset))
	var/matrix/M2 = UNLINT(A.transform.Translate(0, pixel_y_offset).Turn(rest_mult * 180).Translate(0, -pixel_y_offset))
	if(stand)
		animate(A, transform = M1, time = 1.5, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
		animate(transform = M2, time = 1.5, easing = LINEAR_EASING)
		A.rest_mult = 0
	else if(!A.rest_mult)
		animate(A, transform = M1, time = 1.2, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
		animate(transform = M2, time = 1.2, easing = LINEAR_EASING)
		A.rest_mult = rest_mult

ADD_TO_NAMESPACE(ANIMATE)(proc/flip(atom/A, T))
	animate(A, transform = matrix(A.transform, 90, MATRIX_ROTATE), time = T, flags=ANIMATION_PARALLEL)
	animate(transform = matrix(A.transform, 180, MATRIX_ROTATE), time = T)

ADD_TO_NAMESPACE(ANIMATE)(proc/offset_spin(atom/A, radius, laps, lap_start_t, lap_end_t))
	if(!laps || !radius || lap_start_t < 1 || lap_end_t < 1)
		return

	animate(A, transform = null, time = 1)
	var/time_diff = (lap_end_t - lap_start_t)	//How much should the lap time change overall ?
	var/T = lap_start_t		//Lap time starts at the set start time
	var/res = 8		//The resolution - how many points on the circle do we want to calculate?
	var/deg = 360 / res	//How much difference in degrees is there per point?
	for(var/J = 0 to res*laps)	//Step through the points
		animate(transform = matrix(A.transform, (J!=0)*deg, MATRIX_ROTATE), \
					 pixel_x = (radius * sin(deg*J)), \
					 pixel_y = (radius * cos(deg*J)), \
					 time = (T + (time_diff*J/(laps*res))) / res, \
					 flags = ANIMATION_PARALLEL)
		DEBUG_MESSAGE("Animating D: [deg], res: [res], px: [A.pixel_x], py: [A.pixel_y], T: [T], ActualTime:[(T + (time_diff*J/(laps*res)))], J/laps:[J/(laps*res)] TD:[(time_diff*J/(laps*res))]")
	//T += time_diff	//Modify the time with the calculated difference.
	animate(pixel_x = 0, pixel_y = 0, time = 2)

ADD_TO_NAMESPACE(ANIMATE)(proc/shockwave(atom/A))
	if (!istype(A))
		return
	var/punchstr = rand(10, 20)
	var/original_y = A.pixel_y
	var/matrix/M = A.transform
	animate(A, transform = A.transform.Multiply(matrix(punchstr, MATRIX_ROTATE)), pixel_y = 16, time = 2, color = "#eeeeee", easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = A.transform.Multiply(matrix(-punchstr, MATRIX_ROTATE)), pixel_y = original_y, time = 2, color = "#ffffff", easing = BOUNCE_EASING)
	animate(transform = M, time = 3, easing = BOUNCE_EASING)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/glitchy_fuckup1(atom/A))
	if (!istype(A))
		return

	animate(A, pixel_z = A.pixel_z + -128, time = 3, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_z = A.pixel_z + 128, time = 0, loop = -1, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/glitchy_fuckup2(atom/A))
	if (!istype(A))
		return

	animate(A, pixel_x = A.pixel_x + rand(-128,128), pixel_z = A.pixel_z + rand(-128,128), time = 2, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = 0, pixel_z = 0, time = 0, loop = -1, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/glitchy_fuckup3(atom/A))
	if (!istype(A))
		return
	var/matrix/M = matrix()
	var/matrix/MD = matrix()
	var/list/scaley_numbers = list(0.25,0.5,1,1.5,2)
	M.Scale(pick(scaley_numbers),pick(scaley_numbers))
	animate(A, transform = M, time = 1, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = MD, time = 1, loop = -1, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/showlightning_bolt(atom/target))
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	new /obj/decal/lightning_bolt(target_turf)

ADD_TO_NAMESPACE(ANIMATE)(proc/leavepurge(atom/target, current_increment, sword_direction))
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/e
	if(current_increment == 9)
		if (locate(/obj/decal/purge_beam_end) in target_turf)
			return
		e = new /obj/decal/purge_beam_end
	else
		if (locate(/obj/decal/purge_beam) in target_turf)
			return
		e = new /obj/decal/purge_beam
	e.set_loc(target_turf)
	e.dir = sword_direction
	SPAWN(7)
		if (e)
			qdel(e)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/leavescan(atom/target, scan_type))
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/e
	if(scan_type == 0)
		if (locate(/obj/decal/syndicate_destruction_scan_center) in target_turf)
			return
		e = new /obj/decal/syndicate_destruction_scan_center
	else
		if (locate(/obj/decal/syndicate_destruction_scan_side) in target_turf)
			return
		e = new /obj/decal/syndicate_destruction_scan_side
	e.set_loc(target_turf)
	SPAWN(7)
		if (e)
			qdel(e)
	return

ADD_TO_NAMESPACE(ANIMATE)(proc/sponge_size(atom/A, size = 1))
	var/matrix/M2 = matrix()
	M2.Scale(size,size)

	animate(A, transform = M2, time = 30, easing = ELASTIC_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/storage_rustle(atom/A))
	var/matrix/M1 = A.transform

	animate(A, transform = A.transform.Scale(1.2, 0.8), time = 3, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = M1, time = 2, easing = SINE_EASING)

ADD_TO_NAMESPACE(ANIMATE)(var/icon/scanline_icon = icon('icons/effects/scanning.dmi', "scanline"))
ADD_TO_NAMESPACE(ANIMATE)(proc/scanning(atom/target, color, time = 18, alpha_hex = "96"))
	var/fade_time = time / 2
	target.add_filter("scan lines", 1, layering_filter(blend_mode = BLEND_INSET_OVERLAY, icon = ANIMATE.scanline_icon, color = color + "00"))
	var/filter = target.get_filter("scan lines")
	if(!filter) return
	animate(filter, y = -28, easing = QUAD_EASING, time = time, flags = ANIMATION_PARALLEL)
	// animate(y = 0, easing = QUAD_EASING, time = time / 2) // TODO: add multiple passes option later
	animate(color = color + alpha_hex, time = fade_time, flags = ANIMATION_PARALLEL, easing = QUAD_EASING | EASE_IN)
	animate(color = color + "00", time = fade_time, easing = QUAD_EASING | EASE_IN)
	SPAWN(time)
		target.remove_filter("scan lines")

ADD_TO_NAMESPACE(ANIMATE)(proc/storage_thump(atom/A, wiggle = 6))
	if(!istype(A))
		return
	playsound(A, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)
	var/orig_x = A.pixel_x
	var/orig_y = A.pixel_y
	animate(A, pixel_x=orig_x, pixel_y=orig_y, flags=ANIMATION_PARALLEL, time=0.01 SECONDS)
	for(var/i in 1 to wiggle)
		animate(pixel_x=orig_x + rand(-3, 3), pixel_y=orig_y + rand(-3, 3), easing=JUMP_EASING, time=0.1 SECONDS)
	animate(pixel_x=orig_x, pixel_y=orig_y)

//size_max really can't go higher than 0.2 on 32x32 sprites that are sized about the same as humans. Can go higher on larger sprite resolutions or smaller sprites that are in the center, like cigarettes or coins.
ADD_TO_NAMESPACE(ANIMATE)(proc/anim_f_ghost_blur(atom/A, size_min = 0.075, size_max = 0.18))
	A.add_filter("ghost_blur", 0, gauss_blur_filter(size=size_min))
	animate(A.get_filter("ghost_blur"), time = 10, size=size_max, loop=-1,easing = SINE_EASING, flags=ANIMATION_PARALLEL)
	animate(time = 10, size=size_min, loop=-1,easing = SINE_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/bouncy(atom/A)) // little bouncy dance for admin and mentor mice, could be used for other stuff
	if (!istype(A))
		return
	var/initial_dir = (A.dir & (EAST|WEST)) ? A.dir : pick(EAST, WEST)
	var/opposite_dir = turn(initial_dir, 180)
	animate(A, pixel_y = (A.pixel_y + 4), time = 0.15 SECONDS, dir = initial_dir, flags=ANIMATION_PARALLEL)
	animate(pixel_y = (A.pixel_y - 4), time = 0.15 SECONDS, dir = initial_dir)
	animate(pixel_y = (A.pixel_y + 4), time = 0.15 SECONDS, dir = opposite_dir)
	animate(pixel_y = (A.pixel_y - 4), time = 0.15 SECONDS, dir = opposite_dir)

ADD_TO_NAMESPACE(ANIMATE)(proc/wave(atom/A, waves = 7)) // https://secure.byond.com/docs/ref/info.html#/{notes}/filters/wave
	if (!istype(A))
		return
	var/X,Y,rsq,i,f
	for(i=1, i<=waves, ++i)
		// choose a wave with a random direction and a period between 10 and 30 pixels
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)   // keep trying if we don't like the numbers
		// keep distortion (size) small, from 0.5 to 3 pixels
		// choose a random phase (offset)
		A.add_filter("wave-[i]", i, wave_filter(x=X, y=Y, size=rand()*2.5+0.5, offset=rand()))
	for(i=1, i<=waves, ++i)
		// animate phase of each wave from its original phase to phase-1 and then reset;
		// this moves the wave forward in the X,Y direction
		f = A.get_filter("wave-[i]")
		animate(f, offset=f:offset, time=0, loop=-1, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=rand()*20+10)

ADD_TO_NAMESPACE(ANIMATE)(proc/ripple(atom/A, ripples = 1))
	if (!istype(A))
		return
	var/filter,size
	for(var/i=1, i<=ripples, ++i)
		size=rand()*2.5+1
		A.add_filter("ripple-[i]", i, ripple_filter(x=0, y=0, size=size, repeat=rand()*2.5+1, radius=0))
		filter = A.get_filter("ripple-[i]")
		animate(filter, size=size, time=0, loop=-1, radius=0, flags=ANIMATION_PARALLEL)
		animate(size=0, radius=rand()*10+10, time=rand()*20+10)

ADD_TO_NAMESPACE(ANIMATE)(proc/stomp(atom/A, stomp_height = 8, stomps = 3, stomp_duration = 0.7 SECONDS))
	var/mob/M = A
	if(ismob(A))
		APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "hatstomp")
		M.update_canmove()
	var/one_anim_duration = stomp_duration / 2 / stomps
	for(var/i = 0 to stomps - 1)
		if(i == 0)
			animate(A, time=one_anim_duration, pixel_y=stomp_height, easing=SINE_EASING | EASE_OUT, flags=ANIMATION_PARALLEL)
		else
			animate(time=one_anim_duration, pixel_y=stomp_height, easing=SINE_EASING | EASE_OUT)
		animate(time=one_anim_duration, pixel_y=0, easing=SINE_EASING | EASE_IN)
	if(ismob(A))
		SPAWN(stomp_duration)
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "hatstomp")
			M.update_canmove()

/obj/decal/laserbeam
	anchored = ANCHORED
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Contain_F"

ADD_TO_NAMESPACE(ANIMATE)(proc/spawn_beam(atom/movable/AM))
	var/scale_x = 3
	var/scale_y = -15
	var/beam_time = 4 DECI SECONDS
	AM.alpha = 0
	var/turf/T = get_turf(AM)
	var/matrix/M = matrix()
	M.Scale(scale_x, scale_y)
	var/obj/decal/laserbeam/beam = new(T)
	beam.pixel_y =  abs(scale_y * 32)
	beam.Scale(scale_x, 1)
	beam.plane = PLANE_ABOVE_LIGHTING
	beam.layer = NOLIGHT_EFFECTS_LAYER_BASE
	playsound(T, 'sound/weapons/hadar_impact.ogg', 30, TRUE)
	animate(beam, time = beam_time / 2, pixel_y = abs(scale_y * 32 / 2 + 16), transform = M, flags = ANIMATION_PARALLEL)
	animate(time = beam_time / 2, transform = matrix(0,0,0,0,scale_y,0))
	SPAWN(beam_time / 2)
		AM.alpha = initial(AM.alpha)
		if (issimulatedturf(T))
			var/image/burn_overlay = image('icons/turf/floors.dmi',"floorscorched[rand(1,2)]")
			burn_overlay.alpha = 200
			T.AddOverlays(burn_overlay,"burn")
	SPAWN(beam_time)
		qdel(beam)

ADD_TO_NAMESPACE(ANIMATE)(proc/orbit(atom/orbiter, center_x = 0, center_y = 0, radius = 32, time = 8 SECONDS, loops = -1, clockwise = FALSE))
	orbiter.pixel_x = center_x + radius
	orbiter.pixel_y = center_y

	animate(orbiter,
		time = time/4,
		easing = SINE_EASING | EASE_IN,
		pixel_x = center_x,
		flags = ANIMATION_PARALLEL,
		loop = loops)
	animate(
		time = time/4,
		easing = SINE_EASING | EASE_OUT,
		pixel_x = center_x - radius)
	animate(
		time = time/4,
		easing = SINE_EASING | EASE_IN,
		pixel_x = center_x)
	animate(
		time = time/4,
		easing = SINE_EASING | EASE_OUT,
		pixel_x = center_x + radius)

	var/cw_factor = clockwise ? -1 : 1
	animate(orbiter,
		time = time/4,
		easing = SINE_EASING | EASE_OUT,
		pixel_y = center_y + radius * cw_factor,
		flags = ANIMATION_PARALLEL,,
		loop = loops)
	animate(
		time = time/4,
		easing = SINE_EASING | EASE_IN,
		pixel_y = center_y)
	animate(
		time = time/4,
		easing = SINE_EASING | EASE_OUT,
		pixel_y = center_y - radius * cw_factor)
	animate(
		time = time/4,
		easing = SINE_EASING | EASE_IN,
		pixel_y = center_y)

ADD_TO_NAMESPACE(ANIMATE)(proc/juggle(atom/thing, time = 0.7 SECONDS))
	animate(thing, time/3, pixel_x = -15, loop = -1)
	animate(time = time, pixel_x = 15, loop = -1)
	animate(thing, time = time/3, flags = ANIMATION_PARALLEL, loop = -1)
	animate(time = time/2, pixel_y = 45, easing = CUBIC_EASING | EASE_OUT, loop = -1)
	animate(time = time/2, pixel_y = 0, easing = CUBIC_EASING | EASE_IN, loop = -1)
	ANIMATE.spin(thing, parallel = TRUE)

ADD_TO_NAMESPACE(ANIMATE)(proc/psy_juggle(atom/thing, duration = 2 SECONDS))
	var/eighth_duration = duration / 8  // Divide the duration for each segment of the octagon
	var/distance = 24  // Max distance from the center in pixels
	animate(thing, pixel_x = distance, pixel_y = distance * 0.5, time=eighth_duration, easing = LINEAR_EASING, loop = -1)
	animate(pixel_x = distance * 0.5, pixel_y = distance, time=eighth_duration, easing = LINEAR_EASING, loop = -1)
	animate(pixel_x = -distance * 0.5, pixel_y = distance, time=eighth_duration, easing = LINEAR_EASING, loop = -1)
	animate(pixel_x = -distance, pixel_y = distance * 0.5, time=eighth_duration, easing = LINEAR_EASING, loop = -1)
	animate(pixel_x = -distance, pixel_y = -distance * 0.5, time=eighth_duration, easing = LINEAR_EASING, loop = -1)
	animate(pixel_x = -distance * 0.5, pixel_y = -distance, time=eighth_duration, easing = LINEAR_EASING, loop = -1)
	animate(pixel_x = distance * 0.5, pixel_y = -distance, time=eighth_duration, easing = LINEAR_EASING, loop = -1)
	animate(pixel_x = distance, pixel_y = -distance * 0.5, time=eighth_duration, easing = LINEAR_EASING, loop = -1)
	ANIMATE.spin(thing, parallel = TRUE, T = 2 SECONDS)

///Animate being stretched and spun around a point. Looks best when combined with a distortion map. Note that the resulting dummy object is added to center.vis_contents and deleted when done.
///atom/A is the thing to spaghettify. Note this proc does not delete A, you must handle that separately
///atom/center is the central atom around which to spin, usually the singulo
///spaget_time is how long to run the animation. Default 15 seconds.
///right_spinning is whether to go clockwise or anti-clockwise. Default true.
///client/C is to show the spaghetti to only one client, or null to show it to everybody. Default null.
ADD_TO_NAMESPACE(ANIMATE)(proc/spaghettification(atom/A, atom/center, spaget_time = 15 SECONDS, right_spinning = TRUE, client/C = null))
	var/obj/dummy/spaget_overlay = new()
	var/tmp = null
	if(istype(C, /client)) //if we're doing a client image, operate on the image instead of the object
		tmp = spaget_overlay
		spaget_overlay = image(loc = spaget_overlay)
	spaget_overlay.appearance = A.appearance
	spaget_overlay.appearance_flags = RESET_COLOR | RESET_ALPHA | PIXEL_SCALE
	spaget_overlay.pixel_x = A.pixel_x + (A.x - center.x + 0.5)*32
	spaget_overlay.pixel_y = A.pixel_y + (A.y - center.y + 0.5)*32
	spaget_overlay.plane = PLANE_DEFAULT
	spaget_overlay.mouse_opacity = 0
	spaget_overlay.transform = A.transform
	if(prob(0.1)) // easteregg
		spaget_overlay.icon = 'icons/obj/foodNdrink/food_meals.dmi'
		spaget_overlay.icon_state = "spag-dish"
		spaget_overlay.Scale(2, 2)
	if(istype(C, /client)) //if we're doing a client image, push that to the client and then continue operating on the object
		C << spaget_overlay
		spaget_overlay = tmp
		tmp = null
	var/angle = get_angle(A, center)
	var/matrix/flatten = matrix((A.x - center.x)*(cos(angle)), 0, -spaget_overlay.pixel_x, (A.y - center.y)*(sin(angle)), 0, -spaget_overlay.pixel_y)
	animate(spaget_overlay, spaget_time, FALSE, QUAD_EASING, 0, alpha=0, transform=flatten)
	var/obj/dummy/spaget_turner = new()
	spaget_turner.vis_contents += spaget_overlay
	spaget_turner.mouse_opacity = 0
	spaget_turner.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_TOGETHER
	ANIMATE.spin(spaget_turner, right_spinning ? "R" : "L", spaget_time / 8 + randfloat(-2, 2), looping=2, parallel=FALSE)
	if(!istype(center, /area))
		center:vis_contents += spaget_turner
	else
		throw EXCEPTION("Can't use /area as a center point in spaget animation")
	SPAWN(spaget_time + 1 SECOND)
		qdel(spaget_overlay)
		qdel(spaget_turner)

ADD_TO_NAMESPACE(ANIMATE)(proc/meltspark(atom/A))
	var/obj/effects/welding/spark = new(get_turf(A)) //I steal welding sparks hehehe
	spark.pixel_x = rand(-10, 10)
	spark.pixel_y = rand(-6, 0)
	spark.alpha = 0
	animate(spark, alpha = 255, time = 2 DECI SECONDS)
	animate(pixel_y = -16, time = 0.4 SECONDS, easing = QUAD_EASING)
	animate(spark, alpha = 0, time = 0.3 SECONDS, delay = 0.3 SECONDS)
	SPAWN(0.6 SECONDS)
		qdel(spark)

ADD_TO_NAMESPACE(ANIMATE)(proc/little_spark(atom/A))
	var/obj/effects/little_sparks/lit/spark = new(get_turf(A))
	spark.pixel_y = A.pixel_y + rand(-7, 7)
	spark.pixel_x = A.pixel_x + rand(-8, 8)
	spark.alpha = 0
	animate(spark, alpha = 255, time = 2 DECI SECONDS)
	SPAWN(0.6 SECONDS)
		qdel(spark)
