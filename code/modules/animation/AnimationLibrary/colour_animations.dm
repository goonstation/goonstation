ADD_TO_NAMESPACE(ANIMATE)(proc/fade_grayscale(atom/A, time = 5))
	var/start = COLOR_MATRIX_IDENTITY
	var/end = list(0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0,0,0,1, 0,0,0,0)
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/fade_from_grayscale(atom/A, time = 5))
	var/start = list(0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0,0,0,1, 0,0,0,0)
	var/end = COLOR_MATRIX_IDENTITY
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/fade_from_drug_1(atom/A, time = 5)) //This smoothly fades from animated_fade_drug_inbetween_1 to normal colors
	var/start = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	var/end = COLOR_MATRIX_IDENTITY
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/fade_from_drug_2(atom/A, time = 5)) //This smoothly fades from animated_fade_drug_inbetween_2 to normal colors
	var/start = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)
	var/end = COLOR_MATRIX_IDENTITY
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/fade_drug_inbetween_1(atom/A, time = 5)) //This fades from red being green, green being blue and blue being red to red being blue, green being red and blue being green
	var/start = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	var/end = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/fade_drug_inbetween_2(atom/A, time = 5)) //This fades from rred being blue, green being red and blue being green to red being green, green being blue and blue being red
	var/start = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)
	var/end = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/rainbow_glow_old(atom/A))
	if (!istype(A))
		return
	animate(A, color = "#FF0000", time = rand(5,10), loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(color = "#00FF00", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#0000FF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/rainbow_glow(atom/A, min_time = 5, max_time = 10))
	if (!istype(A) && !isclient(A) && !istype(A, /image/maptext))
		return
	animate(A, color = "#FF0000", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(color = "#FFFF00", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FF00", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FFFF", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	animate(color = "#0000FF", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	animate(color = "#FF00FF", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/oscillate_colors(atom/A, list/colors_to_swap))
	if (!istype(A) && !isclient(A) && !istype(A, /image/maptext))
		return
	for(var/the_color in colors_to_swap)
		if(the_color == colors_to_swap[1])
			animate(A, color = the_color, time = rand(5,10), loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		else
			animate(color = the_color, time = rand(5,10), loop = -1, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/fade_to_color_fill(atom/A,the_color, time))
	if (!istype(A) || !the_color || !time)
		return
	animate(A, color = the_color, time = time, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)

ADD_TO_NAMESPACE(ANIMATE)(proc/flash_color_fill(atom/A, the_color, loops, time))
	if (!istype(A) || !the_color || !time || !loops)
		return
	animate(A, color = the_color, time = time, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(color = "#FFFFFF", time = 5, loop = loops, easing = LINEAR_EASING)

ADD_TO_NAMESPACE(ANIMATE)(proc/flash_color_fill_inherit(atom/A, the_color, loops, time))
	if (!istype(A) || !the_color || !time || !loops)
		return
	var/color_old = A.color
	animate(A, color = the_color, time = time, loop = loops, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(color = color_old, time = time, loop = loops, easing = LINEAR_EASING)
