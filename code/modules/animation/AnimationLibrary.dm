//Collection of animations we can reuse for stuff.
//Try to isolate animations you create an put them in here.
/proc/animate_buff_in(var/atom/A)
	var/matrix/M = matrix(A.transform)
	A.transform = A.transform.Scale(0.001)
	A.alpha = 0
	animate(A, alpha = 255, transform = M, time = 10, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_buff_out(var/atom/A)
	var/matrix/M = matrix(A.transform)
	A.alpha = 255
	animate(A, alpha = 0, transform = A.transform.Scale(2, 2), time = 10, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
	animate(transform = M)

/proc/animate_angry_wibble(atom/A)
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(0.8), time = 1, easing = ELASTIC_EASING, loop = -1)
	animate(transform = M, time = 3, easing = ELASTIC_EASING, loop = -1)

/proc/animate_fade_grayscale(var/atom/A, var/time=5)
	var/start = COLOR_MATRIX_IDENTITY
	var/end = list(0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0,0,0,1, 0,0,0,0)
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_fade_from_grayscale(var/atom/A, var/time=5)
	var/start = list(0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0,0,0,1, 0,0,0,0)
	var/end = COLOR_MATRIX_IDENTITY
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_fade_from_drug_1(var/atom/A, var/time=5) //This smoothly fades from animated_fade_drug_inbetween_1 to normal colors
	var/start = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	var/end = COLOR_MATRIX_IDENTITY
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_fade_from_drug_2(var/atom/A, var/time=5) //This smoothly fades from animated_fade_drug_inbetween_2 to normal colors
	var/start = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)
	var/end = COLOR_MATRIX_IDENTITY
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_fade_drug_inbetween_1(var/atom/A, var/time=5) //This fades from red being green, green being blue and blue being red to red being blue, green being red and blue being green
	var/start = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	var/end = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_fade_drug_inbetween_2(var/atom/A, var/time=5) //This fades from rred being blue, green being red and blue being green to red being green, green being blue and blue being red
	var/start = list(0,1,0,0, 0,0,1,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)
	var/end = list(0,0,1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,0,0)
	if (isclient(A))
		var/client/C = A
		C.set_color(start)
		C.animate_color(end, time=time, easing=SINE_EASING)
	else
		A.color = start
		animate(A, color=end, time=time, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_melt_pixel(var/atom/A)
	if (!istype(A))
		return
	//A.alpha = 200
	animate(A, pixel_y = 0, time = 50 - A.pixel_y, alpha = 175, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, easing = LINEAR_EASING)
	return

/proc/animate_explode_pixel(var/atom/A)
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


// TODO: a more descriptive name
/proc/animate_weird(var/atom/A)
	if (!istype(A))
		return
	//A.alpha = 200
	animate(A, pixel_x = 20*sin(A.pixel_x), time = 30 + 20*sin(A.pixel_x), alpha = 175, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = A.pixel_x, time = 30 + 20*sin(A.pixel_x), alpha = 175, easing = ELASTIC_EASING)
	return

/proc/animate_door_squeeze(var/atom/A)
	if (!istype(A))
		return
	//A.alpha = 200
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(0.6, 1), time = 3,easing = BOUNCE_EASING,flags=ANIMATION_PARALLEL)
	animate(transform = M, time = 3,easing = BOUNCE_EASING)
	return

/proc/animate_smush(var/atom/A, var/y_scale = 0.9)
	if (!istype(A))
		return
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(1, y_scale), time = 2, easing = BOUNCE_EASING, flags=ANIMATION_PARALLEL)
	animate(transform = M, time = 2, easing = BOUNCE_EASING)
	return

/proc/animate_flockdrone_item_absorb(var/atom/A)
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

/proc/animate_flock_convert_complete(var/atom/A)
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	A.color = col
	animate(A, color=null, time=5)

/proc/animate_flock_drone_split(var/atom/A)
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	A.color = null
	animate(A, color=col, alpha=0, time=1)

/proc/animate_flock_passthrough(var/atom/A)
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	var/matrix/M = matrix(A.transform)
	animate(A, color=col, transform=A.transform.Scale(0.4), time=3, easing=BOUNCE_EASING, flags=ANIMATION_PARALLEL)
	animate(color=null, transform=M, time=3, easing=BOUNCE_EASING)
	return

/proc/animate_flock_floorrun_start(var/atom/A)
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	var/matrix/shrink = matrix()
	shrink.Scale(0.0, 0.0)
	animate(A, color=col, transform=shrink, time=5, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_flock_floorrun_end(var/atom/A)
	if(!istype(A))
		return
	animate(A, color=null, transform=null, time=5, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_tile_dropaway(var/atom/A)
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


// Attack & Sprint Particles

/mob/New()
	..()
	src.attack_particle = new /obj/particle/attack //don't use pooling for these particles
	src.attack_particle.appearance_flags = TILE_BOUND | PIXEL_SCALE
	src.attack_particle.add_filter("attack blur", 1, gauss_blur_filter(size=0.2))
	src.attack_particle.add_filter("attack drop shadow", 2, drop_shadow_filter(x=1, y=-1, size=0.7))

	src.sprint_particle = new /obj/particle/attack/sprint //don't use pooling for these particles

/mob/disposing()
	QDEL_NULL(src.attack_particle)
	QDEL_NULL(src.sprint_particle)
	. = ..()

/mob/var/obj/particle/attack/attack_particle
/mob/var/obj/particle/attack/sprint/sprint_particle

/obj/particle/attack

/obj/particle/attack/sprint
	icon = 'icons/mob/mob.dmi'
	icon_state = "sprint_cloud"
	layer = MOB_LAYER_BASE - 0.1
	appearance_flags = TILE_BOUND | PIXEL_SCALE

/obj/particle/attack/muzzleflash
	icon = 'icons/mob/mob.dmi'
	alpha = 255
	plane = PLANE_OVERLAY_EFFECTS
	appearance_flags = TILE_BOUND | PIXEL_SCALE

/obj/particle/attack/bot_hit
	icon = 'icons/mob/mob.dmi'


///obj/attackby(var/obj/item/I, mob/user)
//	attack_particle(user,src)
//	..()

/proc/attack_particle(var/mob/M, var/atom/target)
	if (!M || !target || !M.attack_particle) return
	if(istype(M, /mob/dead))
		return
	var/diff_x = target.x - M.x
	var/diff_y = target.y - M.y

	M.attack_particle.invisibility = M.invisibility

	if (target) //I want these to be recent, but sometimes they can be deleted during course of a spawn
		diff_x = target.x - M.x
		diff_y = target.y - M.y

	M.last_interact_particle = world.time

	var/obj/item/I = M.equipped()
	if (I && !isgrab(I))
		M.attack_particle.icon = I.icon
		M.attack_particle.icon_state = I.icon_state
	else
		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "[M.a_intent]"

	M.attack_particle.alpha = 180
	M.attack_particle.loc = M.loc
	M.attack_particle.pixel_x = 0
	M.attack_particle.pixel_y = 0

	var/matrix/start = matrix()
	start.Scale(0.3,0.3)
	start.Turn(rand(-80,80))
	M.attack_particle.transform = start
	var/matrix/t_size = matrix()

	//animate(M.attack_particle, alpha = 200, time = 1, easing = SINE_EASING)

	//animate(M.attack_particle, pixel_x = diff_x*32, pixel_y = diff_y*32, time = 2, easing = CUBIC_EASING)
	//animate(transform = t_size, time = 6, easing = BOUNCE_EASING,  flags = ANIMATION_PARALLEL)

	animate(M.attack_particle, transform = t_size, time = 6, easing = BOUNCE_EASING)
	animate(pixel_x = diff_x*32, pixel_y = diff_y*32, time = 2, easing = BOUNCE_EASING,  flags = ANIMATION_PARALLEL)
	SPAWN(0.5 SECONDS)
		//animate(M.attack_particle, alpha = 0, time = 2, flags = ANIMATION_PARALLEL)
		M.attack_particle?.alpha = 0

/mob/var/last_interact_particle = 0

/proc/interact_particle(var/mob/M, var/atom/target)
	if(istype(M, /mob/dead))
		return
	if (!M || !target) return
	if (world.time <= M.last_interact_particle + M.combat_click_delay) return
	var/diff_x = target.x - M.x
	var/diff_y = target.y - M.y
	SPAWN(0)
		if (!M || !M.attack_particle) //ZeWaka: Fix for Cannot modify null.icon.
			return

		M.attack_particle.invisibility = M.invisibility

		if (target) //I want these to be recent, but sometimes they can be deleted during course of a spawn
			diff_x = target.x - M.x
			diff_y = target.y - M.y

		M.last_interact_particle = world.time

		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "interact"

		M.attack_particle.alpha = 180
		M.attack_particle.loc = M.loc
		M.attack_particle.pixel_x = 0
		M.attack_particle.pixel_y = 0

		var/matrix/start = matrix()
		start.Scale(0.3,0.3)
		start.Turn(rand(-80,80))
		M.attack_particle.transform = start
		var/matrix/t_size = matrix()

		//animate(M.attack_particle, alpha = 200, time = 1, easing = SINE_EASING)

		//animate(M.attack_particle, pixel_x = diff_x*32, pixel_y = diff_y*32, time = 2, easing = CUBIC_EASING)
		//animate(transform = t_size, time = 6, easing = BOUNCE_EASING,  flags = ANIMATION_PARALLEL)

		animate(M.attack_particle, transform = t_size, time = 6, easing = BOUNCE_EASING)
		animate(pixel_x = (diff_x*32) + target.pixel_x, pixel_y = (diff_y*32)  + target.pixel_y, time = 2, easing = BOUNCE_EASING,  flags = ANIMATION_PARALLEL)
		sleep(0.5 SECONDS)
		//animate(M.attack_particle, alpha = 0, time = 2, flags = ANIMATION_PARALLEL)
		M.attack_particle.alpha = 0



/proc/pickup_particle(var/atom/thing, var/atom/target)
	if (!thing || !target) return
	var/diff_x = target.x
	var/diff_y = target.y
	if (target && thing) //I want these to be recent, but sometimes they can be deleted during course of a spawn
		diff_x = diff_x - thing.x
		diff_y = diff_y - thing.y

	if (ismob(thing))
		var/mob/M = thing

		if (!M || !M.attack_particle) //ZeWaka: Fix for Cannot modify null.icon.
			return

		var/obj/item/I = target
		if (I && !isgrab(I))
			M.attack_particle.icon = I.icon
			M.attack_particle.icon_state = I.icon_state
		else
			M.attack_particle.icon = 'icons/mob/mob.dmi'
			M.attack_particle.icon_state = "[M.a_intent]"

		M.attack_particle.alpha = 200
		M.attack_particle.loc = thing.loc
		M.attack_particle.pixel_x = I.pixel_x + (diff_x*32)
		M.attack_particle.pixel_y = I.pixel_y + (diff_y*32)

		var/matrix/start = matrix()//(I.transform)
		M.attack_particle.transform = start
		var/matrix/t_size = matrix()
		t_size.Scale(0.3,0.3)
		t_size.Turn(rand(-40,40))

		animate(M.attack_particle, pixel_x = M.get_hand_pixel_x(), pixel_y = M.get_hand_pixel_y(), time = 1, easing = LINEAR_EASING)
		animate(transform = t_size, time = 1, easing = LINEAR_EASING,  flags = ANIMATION_PARALLEL)
		animate(alpha = 0, time = 1)


/proc/pull_particle(var/mob/M, var/atom/target)
	if (!M || !target) return
	if (world.time <= M.last_interact_particle + M.combat_click_delay) return

	var/diff_x = target.x
	var/diff_y = target.y
	SPAWN(0)
		if (target && M) //I want these to be recent, but sometimes they can be deleted during course of a spawn
			diff_x = diff_x - M.x
			diff_y = diff_y - M.y

		M.last_interact_particle = world.time

		if (!M || !M.attack_particle) //ZeWaka: Fix for Cannot modify null.icon.
			return

		var/atom/I = target

		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "pull"

		M.attack_particle.alpha = 200
		M.attack_particle.loc = M.loc
		M.attack_particle.pixel_x = I.pixel_x + (diff_x*32)
		M.attack_particle.pixel_y = I.pixel_y + (diff_y*32)

		var/matrix/start = matrix()//(I.transform)
		M.attack_particle.transform = start
		var/matrix/t_size = matrix()
		t_size.Scale(0.3,0.3)
		t_size.Turn(rand(-40,40))

		animate(M.attack_particle, pixel_x = M.get_hand_pixel_x(), pixel_y = M.get_hand_pixel_y(), time = 2, easing = LINEAR_EASING)
		sleep(0.5 SECONDS)
		M.attack_particle.alpha = 0



/proc/unpull_particle(var/mob/M, var/atom/target)
	if (!M || !target) return
	if (world.time <= M.last_interact_particle + M.combat_click_delay) return

	var/diff_x = target.x
	var/diff_y = target.y
	SPAWN(0)
		if (target && M) //I want these to be recent, but sometimes they can be deleted during course of a spawn
			diff_x = diff_x - M.x
			diff_y = diff_y - M.y

		M.last_interact_particle = world.time

		if (!M || !M.attack_particle) //ZeWaka: Fix for Cannot modify null.icon.
			return

		var/atom/I = target

		M.attack_particle.icon = 'icons/mob/mob.dmi'
		M.attack_particle.icon_state = "unpull"

		M.attack_particle.alpha = 200
		M.attack_particle.loc = M.loc
		M.attack_particle.pixel_x = M.get_hand_pixel_x()
		M.attack_particle.pixel_y = M.get_hand_pixel_y()

		var/matrix/start = matrix()//(I.transform)
		M.attack_particle.transform = start
		var/matrix/t_size = matrix()
		t_size.Scale(0.3,0.3)
		t_size.Turn(rand(-40,40))

		animate(M.attack_particle, pixel_x = I.pixel_x + (diff_x*32), pixel_y = I.pixel_y + (diff_y*32), time = 2, easing = LINEAR_EASING)
		sleep(0.5 SECONDS)
		M.attack_particle.alpha = 0


/proc/block_begin(var/mob/M)
	if (!M || !M.attack_particle) return

	M.attack_particle.invisibility = M.invisibility
	M.last_interact_particle = world.time

	M.attack_particle.icon = 'icons/mob/mob.dmi'
	M.attack_particle.icon_state = "block"

	M.attack_particle.alpha = 255
	M.attack_particle.loc = M.loc
	M.attack_particle.pixel_x = 0
	M.attack_particle.pixel_y = 0

	var/matrix/start = matrix()
	start.Scale(0.3,0.3)
	start.Turn(rand(-45,45))
	M.attack_particle.transform = start
	var/matrix/t_size = matrix()

	animate(M.attack_particle, transform = t_size, time = 2, easing = BOUNCE_EASING)
	SPAWN(0.5 SECONDS)
		M.attack_particle.alpha = 0

/proc/block_spark(var/mob/M, armor = 0)
	if (!M || !M.attack_particle) return
	var/state_string = ""
	if(armor)
		state_string = "block_spark_armor"
	else
		state_string = "block_spark"

	M.attack_particle.invisibility = M.invisibility
	M.last_interact_particle = world.time

	M.attack_particle.icon = 'icons/mob/mob.dmi'
	if (M.attack_particle.icon_state == state_string)
		FLICK(state_string,M.attack_particle)
	M.attack_particle.icon_state = state_string

	M.attack_particle.alpha = 255
	M.attack_particle.loc = M.loc
	M.attack_particle.pixel_x = 0
	M.attack_particle.pixel_y = 0

	M.attack_particle.transform.Turn(rand(0,360))

	SPAWN(1 SECOND)
		M.attack_particle?.alpha = 0

proc/fuckup_attack_particle(var/mob/M)
	SPAWN(0.1 SECONDS)
		if (!M || !M.attack_particle) return
		var/r = rand(0,360)
		var/x = cos(r)
		var/y = sin(r)
		x *= 22
		y *= 22
		animate(M.attack_particle, pixel_x = M.attack_particle.pixel_x + x , pixel_y = M.attack_particle.pixel_y + y, time = 5, easing = BOUNCE_EASING, flags = ANIMATION_END_NOW)

var/global/obj/overlay/simple_light/muzzle_simple_light = new	/obj/overlay/simple_light{appearance_flags = RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART}

var/global/list/default_muzzle_flash_colors = list(
	"muzzle_flash" = "#FFEE9980",
	"muzzle_flash_laser" = "#FF333380",
	"muzzle_flash_elec" = "#FFC80080",
	"muzzle_flash_bluezap" = "#00FFFF80",
	"muzzle_flash_plaser" = "#00A9FB80",
	"muzzle_flash_phaser" = "#F41C2080",
	"muzzle_flash_launch" = "#FFFFFF50",
	"muzzle_flash_wavep" = "#B3234E80",
	"muzzle_flash_waveg" = "#33CC0080",
	"muzzle_flash_waveb" = "#87BBE380"
)

proc/muzzle_flash_attack_particle(var/mob/M, var/turf/origin, var/turf/target, var/muzzle_anim, var/muzzle_light_color=null, var/offset=25)
	if (!M || !origin || !target || !muzzle_anim) return
	var/firing_angle = get_angle(origin, target)
	muzzle_flash_any(M, firing_angle, muzzle_anim, muzzle_light_color, offset)

proc/muzzle_flash_any(var/atom/movable/A, var/firing_angle, var/muzzle_anim, var/muzzle_light_color, var/offset=25, var/horizontal_offset=0)
	if (!A || firing_angle == null || !muzzle_anim) return

	var/obj/particle/attack/muzzleflash/muzzleflash = new /obj/particle/attack/muzzleflash

	if(isnull(muzzle_light_color))
		muzzle_light_color = default_muzzle_flash_colors[muzzle_anim]
	muzzleflash.overlays.Cut()
	if(muzzle_light_color)
		muzzle_simple_light.color = muzzle_light_color
		muzzleflash.overlays += muzzle_simple_light

	var/matrix/mat = new
	mat.Translate(horizontal_offset, offset)
	mat.Turn(firing_angle)
	muzzleflash.transform = mat
	muzzleflash.layer = A.layer
	muzzleflash.set_loc(A)
	A.vis_contents.Add(muzzleflash)
	if (muzzleflash.icon_state == muzzle_anim)
		FLICK(muzzle_anim,muzzleflash)
	muzzleflash.icon_state = muzzle_anim

	animate(muzzleflash, time=0.4 SECONDS)
	animate(alpha=0, easing=SINE_EASING, time=0.2 SECONDS)

	SPAWN(0.6 SECONDS)
		A.vis_contents.Remove(muzzleflash)
		qdel(muzzleflash)



/proc/sprint_particle(var/mob/M, var/turf/T = null)
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.set_dir(null)
	if (M.sprint_particle.icon_state == "sprint_cloud")
		FLICK("sprint_cloud",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud"

	SPAWN(0.6 SECONDS)
		if (M.sprint_particle?.loc == T)
			M.sprint_particle.loc = null

/proc/sprint_particle_small(var/mob/M, var/turf/T = null, var/direct = null)
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.set_dir(direct)
	if (M.sprint_particle.icon_state == "sprint_cloud_small")
		FLICK("sprint_cloud_small",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud_small"

	SPAWN(0.4 SECONDS)
		if (M.sprint_particle?.loc == T)
			M.sprint_particle.loc = null

/proc/sprint_particle_tiny(var/mob/M, var/turf/T = null, var/direct = null)
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.set_dir(direct)
	if (M.sprint_particle.icon_state == "sprint_cloud_tiny")
		FLICK("sprint_cloud_tiny",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud_tiny"

	SPAWN(0.3 SECONDS)
		if (M.sprint_particle?.loc == T)
			M.sprint_particle.loc = null

/obj/particle/chemical_reaction
	icon = 'icons/effects/chemistry_effects.dmi'
	plane = PLANE_OVERLAY_EFFECTS

/obj/particle/chemical_shine
	icon = 'icons/effects/chemistry_effects.dmi'
	icon_state = "shine"
	plane = PLANE_OVERLAY_EFFECTS

/obj/particle/cryo_sparkle
	icon = 'icons/effects/chemistry_effects.dmi'
	icon_state = "cryo-1"
	plane = PLANE_OVERLAY_EFFECTS

	New()
		icon_state = pick("cryo-1", "cryo-2", "cryo-3", "cryo-4") //slightly different timings on these to give a less static look
		..()

/obj/particle/fire_puff
	icon = 'icons/effects/chemistry_effects.dmi'
	icon_state = "flame-1"
	plane = PLANE_OVERLAY_EFFECTS

	New()
		icon_state = pick("flame-1", "flame-2", "flame-3", "flame-4")
		..()

/obj/particle/heat_swirl
	icon = 'icons/effects/chemistry_effects.dmi'
	icon_state = "heat-1"
	plane = PLANE_OVERLAY_EFFECTS

	New()
		icon_state = pick("heat-1", "heat-2", "heat-3", "heat-4")
		..()

/proc/chemistry_particle(var/datum/reagents/holder, var/datum/chemical_reaction/reaction)
	if(!istype(holder.my_atom, /obj) || !holder.my_atom.loc)
		return
	var/obj/holder_object = holder.my_atom

	var/obj/particle/chemical_reaction/chemical_reaction = new /obj/particle/chemical_reaction
	var/y_offset = 0

	if(!reaction.reaction_icon_color)
		chemical_reaction.color = holder.get_average_rgb()
	else
		chemical_reaction.color = reaction.reaction_icon_color

	y_offset = holder_object.get_chemical_effect_position()
	chemical_reaction.set_loc(holder_object.loc)
	chemical_reaction.icon_state = pick(reaction.reaction_icon_state)
	chemical_reaction.pixel_x = holder_object.pixel_x
	chemical_reaction.pixel_y = holder_object.pixel_y + y_offset

	SPAWN(2 SECONDS)
		qdel(chemical_reaction)

/proc/attack_twitch(var/atom/A, move_multiplier=1, angle_multiplier=1)
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




/proc/hit_twitch(var/atom/A)
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
/proc/violent_twitch(var/atom/A)
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
/proc/violent_standup_twitch(var/atom/A)
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

/proc/violent_standup_twitch_parametrized(var/atom/A, var/off_x = 3, var/off_y = 2, var/input_angle = 45, var/iterations = 7, var/sleep_length = 0.1 SECONDS, var/effect_scale = 1)
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

/proc/eat_twitch(var/atom/A)
	var/matrix/squish_matrix = matrix(A.transform)
	squish_matrix.Scale(1,0.92)
	var/matrix/M = matrix(A.transform)
	var/ipy = A.pixel_y

	animate(A, transform = squish_matrix, time = 1,easing = EASE_OUT, flags=ANIMATION_PARALLEL)
	animate(pixel_y = -1, time = 1,easing = EASE_OUT)
	animate(transform = M, time = 1, easing = EASE_IN)
	animate(pixel_y = ipy, time = 1,easing = EASE_IN)

/proc/animate_portal_appear(var/atom/A)
	var/matrix/M = matrix(A.transform)
	A.transform = A.transform.Scale(0.6, 0.05)
	animate(A, transform = M, time = 30, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_portal_tele(var/atom/A)
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(0.95, 0.7), time = 1, easing = EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(transform = M, time = 10, easing = ELASTIC_EASING)

/proc/animate_float(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
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
	return

/proc/animate_levitate(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
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

/proc/animate_lag(atom/A, steps=15, loopnum=-1, magnitude=10, step_time_low=0.2 SECONDS, step_time_high = 0.25 SECONDS)
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

/proc/animate_revenant_shockwave(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
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

/proc/animate_glitchy_freakout(var/atom/A)
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

/proc/animate_fading_leap_up(var/atom/A)
	if (!istype(A))
		return
	var/do_loops = 15
	while (do_loops > 0)
		do_loops--
		animate(A, transform = A.transform.Scale(1.2), pixel_z = A.pixel_z + 12, alpha = A.alpha - 17, time = 1, loop = 1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		sleep(0.1 SECONDS)
	A.alpha = 0

/proc/animate_fading_leap_down(var/atom/A)
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

/proc/animate_shake(var/atom/A,var/amount = 5,var/x_severity = 2,var/y_severity = 2, var/return_x = 0, var/return_y = 0)
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

/proc/animate_flubber(var/atom/A, var/jiggle_duration_start = 6, var/jiggle_duration_end = 12, var/amount = 3, var/severity = 1.5)
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
	return

/proc/animate_teleport(var/atom/A)
	if (!istype(A))
		return
	var/matrix/original = matrix(A.transform)
	var/matrix/M = A.transform.Scale(1, 3)
	animate(A, transform = M, pixel_y = 32, time = 10, alpha = 50, easing = CIRCULAR_EASING, flags=ANIMATION_PARALLEL)
	M.Scale(0,4)
	animate(transform = M, time = 5, color = "#1111ff", alpha = 0, easing = CIRCULAR_EASING)
	animate(transform = original, time = 5, color = "#ffffff", alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)
	return

/proc/animate_teleport_wiz(var/atom/A)
	if (!istype(A))
		return
	var/matrix/original = matrix(A.transform)
	var/matrix/M = A.transform.Scale(0, 4)
	animate(A, color = "#ddddff", time = 20, alpha = 70, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
	animate(transform = M, pixel_y = 32, time = 20, color = "#2222ff", alpha = 0, easing = CIRCULAR_EASING)
	animate(time = 8, transform = M, alpha = 5) //Do nothing, essentially
	animate(transform = original, time = 5, color = "#ffffff", alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)
	return

/proc/animate_rainbow_glow_old(var/atom/A)
	if (!istype(A))
		return
	animate(A, color = "#FF0000", time = rand(5,10), loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(color = "#00FF00", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#0000FF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	return

/proc/animate_rainbow_glow(var/atom/A, min_time = 5, max_time = 10)
	if (!istype(A) && !isclient(A) && !istype(A, /image/maptext))
		return
	animate(A, color = "#FF0000", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(color = "#FFFF00", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FF00", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FFFF", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	animate(color = "#0000FF", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	animate(color = "#FF00FF", time = rand(min_time,max_time), loop = -1, easing = LINEAR_EASING)
	return

/proc/oscillate_colors(var/atom/A, var/list/colors_to_swap)
	if (!istype(A) && !isclient(A) && !istype(A, /image/maptext))
		return
	for(var/the_color in colors_to_swap)
		if(the_color == colors_to_swap[1])
			animate(A, color = the_color, time = rand(5,10), loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		else
			animate(color = the_color, time = rand(5,10), loop = -1, easing = LINEAR_EASING)

/proc/animate_fade_to_color_fill(var/atom/A,var/the_color,var/time)
	if (!istype(A) || !the_color || !time)
		return
	animate(A, color = the_color, time = time, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)

/proc/animate_flash_color_fill(var/atom/A,var/the_color,var/loops,var/time)
	if (!istype(A) || !the_color || !time || !loops)
		return
	animate(A, color = the_color, time = time, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(color = "#FFFFFF", time = 5, loop = loops, easing = LINEAR_EASING)

/proc/animate_flash_color_fill_inherit(var/atom/A,var/the_color,var/loops,var/time)
	if (!istype(A) || !the_color || !time || !loops)
		return
	var/color_old = A.color
	animate(A, color = the_color, time = time, loop = loops, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(color = color_old, time = time, loop = loops, easing = LINEAR_EASING)

/proc/animate_clownspell(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix(A.transform)
	animate(A, transform = A.transform.Scale(1.3, 1.3), time = 5, color = "#00ff00", easing = BACK_EASING ,flags=ANIMATION_PARALLEL)
	animate(transform = M, time = 5, color = "#ffffff", easing = ELASTIC_EASING)

/proc/animate_wiggle_then_reset(var/atom/A, var/loops = 5, var/speed = 5, var/x_var = 3, var/y_var = 3)
	if (!istype(A) || !loops || !speed)
		return
	animate(A, pixel_x = rand(-x_var, x_var), pixel_y = rand(-y_var, y_var), time = speed * 2,loop = loops, easing = rand(2,7), flags = ANIMATION_PARALLEL)
	animate(pixel_x = 0, pixel_y = 0, time = speed, easing = rand(2,7))

/proc/animate_blink(var/atom/A)
	if (!istype(A))
		return
	var/matrix/Orig = A.transform
	A.Scale(0.2,0.2)
	A.alpha = 50
	animate(A,transform = Orig, time = 3, alpha = 255, easing = CIRCULAR_EASING, flags = ANIMATION_PARALLEL)
	return

/proc/animate_bullspellground(var/atom/A, var/spell_color = "#cccccc")
	if (!istype(A))
		return
	animate(A, time = 5, color = spell_color)
	animate(time = 5, color = "#ffffff")
	return

/proc/animate_spin(var/atom/A, var/dir = "L", var/T = 1, var/looping = -1, var/parallel = TRUE)
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
	return

/proc/animate_peel_slip(atom/A, dir=null, T=0.55 SECONDS, height=16, stun_duration = 2 SECONDS, n_flips=1)
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
			animate_rest(L, TRUE)

/proc/animate_handspider_flipoff(var/atom/A, var/dir = "L", var/T = 1, var/looping = -1)
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

/proc/animate_bumble(var/atom/A, var/loopnum = -1, floatspeed = 10, Y1 = 3, Y2 = -3, var/slightly_random = 1)
	if (!istype(A))
		return

	if (slightly_random)
		floatspeed = floatspeed * (rand(10,14) / 10)//rand_deci(1, 0, 1, 4)
	animate(A, pixel_y = Y1, time = floatspeed, loop = loopnum, easing = LINEAR_EASING)//, flags = ANIMATION_END_NOW) - enable this once we can compile with 511 maybe (I forgot to test it)
	animate(pixel_y = Y2, time = floatspeed, loop = loopnum, easing = LINEAR_EASING)
	return

/proc/animate_beespin(var/atom/A, var/dir = 90, var/T = 1.5, var/loops = 1)
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

/proc/animate_emote(var/atom/A, emote)
	if (!istype(A))
		return
	var/obj/effect/E = new emote(A.loc)
	E.Scale(0.05, 0.05)
	E.alpha = 0
	animate(E,transform = matrix(0.5, MATRIX_SCALE), time = 20, alpha = 255, pixel_y = 27, easing = ELASTIC_EASING)
	animate(time = 5, alpha = 0, pixel_y = -16, easing = CIRCULAR_EASING)
	SPAWN(3 SECONDS) qdel(E)
	return

/proc/animate_horizontal_wiggle(var/atom/A, var/loopnum = 5, speed = 10, X1 = 3, X2 = -3, var/slightly_random = 1)
	if (!istype(A))
		return

	if (slightly_random)
		var/rand_var = (rand(10, 14) / 10)
		DEBUG_MESSAGE("rand_var [rand_var]")
		speed = speed * rand_var
	animate(A, pixel_x = X1, time = speed, loop = loopnum, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = X2, time = speed, loop = loopnum, easing = LINEAR_EASING)
	return

/proc/animate_slide(var/atom/A, var/px, var/py, var/T = 10, var/ease = SINE_EASING)
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

/proc/animate_rest(var/atom/A, var/stand)
	if(!istype(A))
		return
	if(stand)
		animate(A, pixel_x = 0, pixel_y = 0, transform = A.transform.Turn(A.rest_mult * -90), time = 3, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
		A.rest_mult = 0
	else if(!A.rest_mult)
		var/fall_left_or_right = pick(1, -1) //A multiplier of one makes the atom rotate to the right, negative makes them fall to the left.
		animate(A, pixel_x = 0, pixel_y = -4, transform = A.transform.Turn(fall_left_or_right * 90), time = 2, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
		A.rest_mult = fall_left_or_right

/proc/animate_180_rest(atom/A, stand, pixel_y_offset=5)
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

/proc/animate_flip(var/atom/A, var/T)
	animate(A, transform = matrix(A.transform, 90, MATRIX_ROTATE), time = T, flags=ANIMATION_PARALLEL)
	animate(transform = matrix(A.transform, 180, MATRIX_ROTATE), time = T)


/proc/animate_offset_spin(var/atom/A, var/radius, var/laps, var/lap_start_t, var/lap_end_t)
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

/*
/mob/verb/offset_spin(var/radius as num, var/laps as num, var/s_time as num, var/e_time as num)
	set category = "Debug"
	set name = "Test Offset Spin"
	set desc = "(radius,laps,s_time,e_time)Holy balls!"
	set usr = src
	animate_offset_spin(src, radius, laps, s_time, e_time)
*/

/proc/animate_shockwave(var/atom/A)
	if (!istype(A))
		return
	var/punchstr = rand(10, 20)
	var/original_y = A.pixel_y
	var/matrix/M = A.transform
	animate(A, transform = A.transform.Multiply(matrix(punchstr, MATRIX_ROTATE)), pixel_y = 16, time = 2, color = "#eeeeee", easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = A.transform.Multiply(matrix(-punchstr, MATRIX_ROTATE)), pixel_y = original_y, time = 2, color = "#ffffff", easing = BOUNCE_EASING)
	animate(transform = M, time = 3, easing = BOUNCE_EASING)
	return

/proc/animate_glitchy_fuckup1(var/atom/A)
	if (!istype(A))
		return

	animate(A, pixel_z = A.pixel_z + -128, time = 3, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_z = A.pixel_z + 128, time = 0, loop = -1, easing = LINEAR_EASING)

/proc/animate_glitchy_fuckup2(var/atom/A)
	if (!istype(A))
		return

	animate(A, pixel_x = A.pixel_x + rand(-128,128), pixel_z = A.pixel_z + rand(-128,128), time = 2, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = 0, pixel_z = 0, time = 0, loop = -1, easing = LINEAR_EASING)

/proc/animate_glitchy_fuckup3(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix()
	var/matrix/MD = matrix()
	var/list/scaley_numbers = list(0.25,0.5,1,1.5,2)
	M.Scale(pick(scaley_numbers),pick(scaley_numbers))
	animate(A, transform = M, time = 1, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = MD, time = 1, loop = -1, easing = LINEAR_EASING)

// these don't use animate but they're close enough, idk
/proc/showswirl(var/atom/target, var/play_sound = TRUE)
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl
	swirl.set_loc(target_turf)
	swirl.pixel_y = 10
	if (play_sound)
		playsound(target_turf, 'sound/effects/teleport.ogg', 50, TRUE)
	SPAWN(1.5 SECONDS)
		if (swirl)
			swirl.pixel_y = 0
			qdel(swirl)
	return

/proc/showswirl_out(var/atom/target, var/play_sound = TRUE)
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/teleport_swirl/swirl/ = new /obj/decal/teleport_swirl/out
	swirl.set_loc(target_turf)
	swirl.pixel_y = 10
	if (play_sound)
		playsound(target_turf, 'sound/effects/teleport.ogg', 50, TRUE)
	SPAWN(1.5 SECONDS)
		if (swirl)
			swirl.pixel_y = 0
			qdel(swirl)
	return

/proc/showswirl_error(var/atom/target, var/play_sound = TRUE)
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/teleport_swirl/swirl/ = new /obj/decal/teleport_swirl/error
	swirl.set_loc(target_turf)
	swirl.pixel_y = 10
	if (play_sound)
		playsound(target_turf, 'sound/effects/teleport.ogg', 50, TRUE)
	SPAWN(1.5 SECONDS)
		if (swirl)
			swirl.pixel_y = 0
			qdel(swirl)
	return

/proc/leaveresidual(var/atom/target)
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	if (locate(/obj/decal/residual_energy) in target_turf)
		return
	var/obj/decal/residual_energy/e = new /obj/decal/residual_energy
	e.set_loc(target_turf)
	SPAWN(10 SECONDS)
		if (e)
			qdel(e)
	return

/proc/showlightning_bolt(var/atom/target)
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	new /obj/decal/lightning_bolt(target_turf)

/proc/leavepurge(var/atom/target, var/current_increment, var/sword_direction)
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

/proc/leavescan(var/atom/target, var/scan_type)
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

/proc/sponge_size(var/atom/A, var/size = 1)
	var/matrix/M2 = matrix()
	M2.Scale(size,size)

	animate(A, transform = M2, time = 30, easing = ELASTIC_EASING)

/proc/animate_storage_rustle(var/atom/A)
	var/matrix/M1 = A.transform

	animate(A, transform = A.transform.Scale(1.2, 0.8), time = 3, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = M1, time = 2, easing = SINE_EASING)

/proc/shrink_teleport(var/atom/teleporter)
	var/matrix/M = teleporter.transform
	animate(teleporter, transform = teleporter.transform.Scale(0.1), pixel_y = 6, time = 4, alpha = 255, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	sleep(0.2 SECONDS)
	animate(teleporter, transform = M, time = 9, alpha = 255, pixel_y = 0, easing = ELASTIC_EASING, flags = ANIMATION_PARALLEL)
	//HAXXX sorry - kyle
	if (istype(teleporter, /mob/dead/observer))
		SPAWN(1 SECOND)
			animate_bumble(teleporter)


/proc/spawn_animation1(var/atom/A)
	var/matrix/M = A.transform
	A.transform = A.transform.Scale(0.1)
	A.pixel_y = 300

	animate(A, time = 10, pixel_y = -16, alpha = 255, easing = QUAD_EASING, flags = ANIMATION_PARALLEL)

	animate(transform = A.transform.Scale(10,1), time = 2, easing = SINE_EASING)


	animate(transform = A.transform.Scale(1,10), time = 2, pixel_y = 0, easing = SINE_EASING)
	animate(transform = M)

/proc/leaving_animation(var/atom/A)
	animate(A, transform = A.transform.Scale(0.1, 1), time = 5, alpha = 255, easing = QUAD_EASING, flags = ANIMATION_PARALLEL)
	animate(time = 10, pixel_y = 512, easing = CUBIC_EASING)
	sleep(1.5 SECONDS)

/proc/heavenly_spawn(var/atom/movable/A, reverse = FALSE)
	var/obj/effects/heavenly_light/lightbeam = new /obj/effects/heavenly_light
	lightbeam.set_loc(A.loc)
	var/was_anchored = A.anchored
	var/oldlayer = A.layer
	var/old_canbegrabbed = null
	A.layer = EFFECTS_LAYER + 1
	A.anchored = ANCHORED
	if (!reverse)
		A.alpha = 0
		A.pixel_y = 176
	lightbeam.alpha = 0
	if (ismob(A))
		var/mob/M = A
		if (isliving(M))
			var/mob/living/living = M
			old_canbegrabbed = living.canbegrabbed
			living.canbegrabbed = FALSE
		APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, M.type)
	playsound(A.loc, 'sound/voice/heavenly3.ogg', 50,0)
	animate(lightbeam, alpha=255, time=45)
	animate(A,alpha=255,time=45)
	sleep(4.5 SECONDS)
	animate(A, pixel_y = reverse ? 176 : 0, time = 120, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	sleep(12 SECONDS)
	A.anchored = was_anchored
	A.layer = oldlayer
	animate(lightbeam,alpha = 0, time=15)
	if (reverse)
		animate(A,alpha=0,time=15)
	sleep(1.5 SECONDS)
	qdel(lightbeam)
	if (ismob(A))
		var/mob/M = A
		if (isliving(M))
			var/mob/living/living = M
			living.canbegrabbed = old_canbegrabbed
		REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, M.type)
	if (reverse)
		if (ismob(A))
			var/mob/M = A
			M.ghostize()
			M.set_loc(null)
			M.death()
		qdel(A)

/obj/effects/heavenly_light
	icon = 'icons/obj/large/32x192.dmi'
	icon_state = "heavenlight"
	layer = EFFECTS_LAYER
	blend_mode = BLEND_ADD

/proc/demonic_spawn(var/atom/movable/A, var/size = 1, var/play_sound = TRUE)
	if (!A) return
	var/was_anchored = A.anchored
	var/original_plane = A.plane
	var/original_density = A.density
	var/matrix/M1 = matrix()
	A.transform = M1.Scale(0,0)
	var/turf/center = get_turf(A)
	if (!center) return

	A.plane = PLANE_UNDERFLOOR
	A.anchored = ANCHORED
	A.density = FALSE
	if (ismob(A))
		var/mob/M = A
		APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, M.type)
	if (play_sound)
		playsound(center, 'sound/effects/darkspawn.ogg', 50,FALSE)
	SPAWN(5 SECONDS)
		var/turf/TA = locate(A.x - size, A.y - size, A.z)
		var/turf/TB = locate(A.x + size, A.y + size, A.z)
		if (!TA || !TB) return

		var/list/fake_hells = list()
		for (var/turf/T in block(TA, TB))
			fake_hells += new /obj/fake_hell(T)
			var/x_modifier = (T.x - center.x)
			var/y_modifier = (T.y - center.y)
			if (x_modifier || y_modifier)
				animate(T, pixel_x = ((32 * (x_modifier / max(1, abs(x_modifier)))) * (size - abs(x_modifier) + 1)), pixel_y = ((32 * (y_modifier / max(1, abs(y_modifier)))) * (size - abs(y_modifier) + 1)), 7.5 SECONDS, easing = SINE_EASING)
			else // center tile
				animate(T, transform = M1.Scale(0,0), 5 SECONDS, easing = SINE_EASING)
		sleep(7.5 SECONDS)
		animate(A, transform = null, time=20, easing = SINE_EASING)
		A.plane = original_plane
		A.anchored = was_anchored
		A.density = original_density
		if (ismob(A))
			var/mob/M = A
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, M.type)
		for (var/turf/T in block(TA, TB))
			animate(T, transform = null, pixel_x = 0, pixel_y = 0, 7.5 SECONDS, easing = SINE_EASING)
		sleep(7.5 SECONDS)
		for (var/obj/fake_hell/O in fake_hells)
			qdel(O)

/obj/fake_hell //for use with /proc/demonic_spawn
	name = "???"
	desc = "just standing next to it burns your very soul."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "lava_floor"
	anchored = ANCHORED
	plane = PLANE_UNDERFLOOR
	layer = -100

	New()
		. = ..()
		src.icon_state = pick("lava_floor", "lava_floor_bubbling", "lava_floor_bubbling2")

	Crossed(atom/movable/AM)
		. = ..()
		if (isliving(AM))
			var/mob/living/M = AM
			M.update_burning(10)

	meteorhit()
		return

	ex_act()
		return

var/global/icon/scanline_icon = icon('icons/effects/scanning.dmi', "scanline")
/proc/animate_scanning(var/atom/target, var/color, var/time=18, var/alpha_hex="96")
	var/fade_time = time / 2
	target.add_filter("scan lines", 1, layering_filter(blend_mode = BLEND_INSET_OVERLAY, icon = scanline_icon, color = color + "00"))
	var/filter = target.get_filter("scan lines")
	if(!filter) return
	animate(filter, y = -28, easing = QUAD_EASING, time = time, flags = ANIMATION_PARALLEL)
	// animate(y = 0, easing = QUAD_EASING, time = time / 2) // TODO: add multiple passes option later
	animate(color = color + alpha_hex, time = fade_time, flags = ANIMATION_PARALLEL, easing = QUAD_EASING | EASE_IN)
	animate(color = color + "00", time = fade_time, easing = QUAD_EASING | EASE_IN)
	SPAWN(time)
		target.remove_filter("scan lines")

/proc/animate_storage_thump(var/atom/A, wiggle=6)
	if(!istype(A))
		return
	playsound(A, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)
	var/orig_x = A.pixel_x
	var/orig_y = A.pixel_y
	animate(A, pixel_x=orig_x, pixel_y=orig_y, flags=ANIMATION_PARALLEL, time=0.01 SECONDS)
	for(var/i in 1 to wiggle)
		animate(pixel_x=orig_x + rand(-3, 3), pixel_y=orig_y + rand(-3, 3), easing=JUMP_EASING, time=0.1 SECONDS)
	animate(pixel_x=orig_x, pixel_y=orig_y)

/obj/overlay/tile_effect/fake_fullbright
	icon = 'icons/effects/white.dmi'
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_FULLBRIGHT
	blend_mode = BLEND_OVERLAY

/obj/overlay/tile_effect/sliding_turf
	mouse_opacity = 0
	New(turf/T)
		. = ..()
		src.icon = T.icon
		src.icon_state = T.icon_state
		src.set_dir(T.dir)
		src.color = T.color
		src.layer = T.layer - 1
		src.plane = T.plane


/proc/animate_turf_slideout(turf/T, new_turf_type, dir, time)
	var/image/orig = image(T.icon, T.icon_state, dir=T.dir)
	var/was_fullbright = T.fullbright
	orig.color = T.color
	orig.appearance_flags |= RESET_TRANSFORM
	T.ReplaceWith(new_turf_type)
	T.layer--
	switch(dir)
		if(WEST)
			T.transform = list(1, 0, 32, 0, 1, 0)
		if(EAST)
			T.transform = list(1, 0, -32, 0, 1, 0)
		if(SOUTH)
			T.transform = list(1, 0, 0, 0, 1, 32)
		if(NORTH)
			T.transform = list(1, 0, 0, 0, 1, -32)
	animate(T, transform=list(1, 0, 0, 0, 1, 0), time=time)
	if(was_fullbright) // eww
		var/obj/full_light = new/obj/overlay/tile_effect/fake_fullbright(T)
		full_light.color = orig.color
		var/list/trans
		switch(dir)
			if(WEST)
				trans = list(0, 0, -16, 0, 1, 0)
			if(EAST)
				trans = list(0, 0, 16, 0, 1, 0)
			if(SOUTH)
				trans = list(1, 0, 0, 0, 0, -16)
			if(NORTH)
				trans = list(1, 0, 0, 0, 0, 16)
		animate(full_light, transform=trans, time=time)

/proc/animate_turf_slideout_cleanup(turf/T)
	T.layer++
	T.underlays.Cut()
	var/obj/overlay/tile_effect/fake_fullbright/full_light = locate() in T
	if(full_light)
		qdel(full_light)


/proc/animate_turf_slidein(turf/T, new_turf_type, dir, time)
	var/obj/overlay/tile_effect/sliding_turf/slide = new(T)
	var/had_fullbright = T.fullbright
	if(station_repair.station_generator && T.z == Z_LEVEL_STATION)
		station_repair.repair_turfs(list(T))
	else
		T.ReplaceWith(new_turf_type)
	T.layer -= 2
	var/list/tr
	switch(dir)
		if(WEST)
			tr = list(1, 0, -32, 0, 1, 0)
		if(EAST)
			tr = list(1, 0, 32, 0, 1, 0)
		if(SOUTH)
			tr = list(1, 0, 0, 0, 1, -32)
		if(NORTH)
			tr = list(1, 0, 0, 0, 1, 32)
	animate(slide, transform=tr, time=time)
	if(!had_fullbright && T.fullbright) // eww
		T.fullbright = 0
		T.ClearSpecificOverlays("fullbright")
		T.RL_Init() // turning off fullbright
		var/obj/full_light = new/obj/overlay/tile_effect/fake_fullbright(T)
		full_light.color = T.color
		switch(dir)
			if(WEST)
				full_light.transform = list(0, 0, 16, 0, 1, 0)
			if(EAST)
				full_light.transform = list(0, 0, -16, 0, 1, 0)
			if(SOUTH)
				full_light.transform = list(1, 0, 0, 0, 0, 16)
			if(NORTH)
				full_light.transform = list(1, 0, 0, 0, 0, -16)
		animate(full_light, transform=matrix(), time=time)

/proc/animate_turf_slidein_cleanup(turf/T)
	T.layer += 2
	T.underlays.Cut()
	var/obj/overlay/tile_effect/fake_fullbright/full_light = locate() in T
	if(full_light)
		qdel(full_light)
	var/obj/overlay/tile_effect/sliding_turf/slide = locate() in T
	if(slide)
		qdel(slide)
	if(initial(T.fullbright))
		T.fullbright = 1
		T.AddOverlays(new /image/fullbright, "fullbright")
		T.RL_Init()

/proc/animate_open_from_floor(atom/A, time=1 SECOND, self_contained=1)
	A.add_filter("alpha white", 200, alpha_mask_filter(icon='icons/effects/white.dmi', x=16))
	A.add_filter("alpha black", 201, alpha_mask_filter(icon='icons/effects/black.dmi', x=-16)) // has to be a different dmi because byond
	animate(A.get_filter("alpha black"), x=0, time=time, easing=CUBIC_EASING | EASE_IN)
	animate(A.get_filter("alpha white"), x=0, time=time, easing=CUBIC_EASING | EASE_IN, flags=ANIMATION_PARALLEL)
	if(self_contained) // assume we're starting from being invisible
		A.alpha = 255
	if(self_contained)
		SPAWN(time)
			A.remove_filter(list("alpha white", "alpha black"))

/proc/animate_close_into_floor(atom/A, time=1 SECOND, self_contained=1)
	A.add_filter("alpha white", 200, alpha_mask_filter(icon='icons/effects/white.dmi', x=0))
	A.add_filter("alpha black", 201, alpha_mask_filter(icon='icons/effects/black.dmi', x=0)) // has to be a different dmi because byond
	animate(A.get_filter("alpha black"), x=-16, time=time, easing=CUBIC_EASING | EASE_IN)
	animate(A.get_filter("alpha white"), x=16, time=time, easing=CUBIC_EASING | EASE_IN, flags=ANIMATION_PARALLEL)
	if(self_contained)
		SPAWN(time)
			A.remove_filter(list("alpha white", "alpha black"))
			A.alpha = 0

//size_max really can't go higher than 0.2 on 32x32 sprites that are sized about the same as humans. Can go higher on larger sprite resolutions or smaller sprites that are in the center, like cigarettes or coins.
/proc/anim_f_ghost_blur(atom/A, var/size_min = 0.075 as num, var/size_max=0.18 as num)
	A.add_filter("ghost_blur", 0, gauss_blur_filter(size=size_min))
	animate(A.get_filter("ghost_blur"), time = 10, size=size_max, loop=-1,easing = SINE_EASING, flags=ANIMATION_PARALLEL)
	animate(time = 10, size=size_min, loop=-1,easing = SINE_EASING)

/proc/animate_bouncy(atom/A) // little bouncy dance for admin and mentor mice, could be used for other stuff
	if (!istype(A))
		return
	var/initial_dir = (A.dir & (EAST|WEST)) ? A.dir : pick(EAST, WEST)
	var/opposite_dir = turn(initial_dir, 180)
	animate(A, pixel_y = (A.pixel_y + 4), time = 0.15 SECONDS, dir = initial_dir, flags=ANIMATION_PARALLEL)
	animate(pixel_y = (A.pixel_y - 4), time = 0.15 SECONDS, dir = initial_dir)
	animate(pixel_y = (A.pixel_y + 4), time = 0.15 SECONDS, dir = opposite_dir)
	animate(pixel_y = (A.pixel_y - 4), time = 0.15 SECONDS, dir = opposite_dir)

/proc/animate_wave(atom/A, waves=7) // https://secure.byond.com/docs/ref/info.html#/{notes}/filters/wave
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

/proc/animate_ripple(atom/A, ripples=1)
	if (!istype(A))
		return
	var/filter,size
	for(var/i=1, i<=ripples, ++i)
		size=rand()*2.5+1
		A.add_filter("ripple-[i]", i, ripple_filter(x=0, y=0, size=size, repeat=rand()*2.5+1, radius=0))
		filter = A.get_filter("ripple-[i]")
		animate(filter, size=size, time=0, loop=-1, radius=0, flags=ANIMATION_PARALLEL)
		animate(size=0, radius=rand()*10+10, time=rand()*20+10)

/proc/animate_stomp(atom/A, stomp_height=8, stomps=3, stomp_duration=0.7 SECONDS)
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

/proc/spawn_beam(atom/movable/AM)
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

proc/animate_orbit(atom/orbiter, center_x = 0, center_y = 0, radius = 32, time=8 SECONDS, loops=-1, clockwise=FALSE)
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

/proc/animate_juggle(atom/thing, time = 0.7 SECONDS)
	animate(thing, time/3, pixel_x = -15, loop = -1)
	animate(time = time, pixel_x = 15, loop = -1)
	animate(thing, time = time/3, flags = ANIMATION_PARALLEL, loop = -1)
	animate(time = time/2, pixel_y = 45, easing = CUBIC_EASING | EASE_OUT, loop = -1)
	animate(time = time/2, pixel_y = 0, easing = CUBIC_EASING | EASE_IN, loop = -1)
	animate_spin(thing, parallel = TRUE)

/proc/animate_psy_juggle(atom/thing, duration = 2 SECONDS)
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
	animate_spin(thing, parallel = TRUE, T = 2 SECONDS)

///Animate being stretched and spun around a point. Looks best when combined with a distortion map. Note that the resulting dummy object is added to center.vis_contents and deleted when done.
///atom/A is the thing to spaghettify. Note this proc does not delete A, you must handle that separately
///atom/center is the central atom around which to spin, usually the singulo
///spaget_time is how long to run the animation. Default 15 seconds.
///right_spinning is whether to go clockwise or anti-clockwise. Default true.
///client/C is to show the spaghetti to only one client, or null to show it to everybody. Default null.
/proc/animate_spaghettification(atom/A, atom/center, spaget_time = 15 SECONDS, right_spinning = TRUE, client/C = null)
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
	animate_spin(spaget_turner, right_spinning ? "R" : "L", spaget_time / 8 + randfloat(-2, 2), looping=2, parallel=FALSE)
	if(!istype(center, /area))
		center:vis_contents += spaget_turner
	else
		throw EXCEPTION("Can't use /area as a center point in spaget animation")
	SPAWN(spaget_time + 1 SECOND)
		qdel(spaget_overlay)
		qdel(spaget_turner)

/proc/animate_meltspark(atom/A)
	var/obj/effects/welding/spark = new(get_turf(A)) //I steal welding sparks hehehe
	spark.pixel_x = rand(-10, 10)
	spark.pixel_y = rand(-6, 0)
	spark.alpha = 0
	animate(spark, alpha = 255, time = 2 DECI SECONDS)
	animate(pixel_y = -16, time = 0.4 SECONDS, easing = QUAD_EASING)
	animate(spark, alpha = 0, time = 0.3 SECONDS, delay = 0.3 SECONDS)
	SPAWN(0.6 SECONDS)
		qdel(spark)

/proc/animate_little_spark(atom/A)
	var/obj/effects/little_sparks/lit/spark = new(get_turf(A))
	spark.pixel_y = A.pixel_y + rand(-7, 7)
	spark.pixel_x = A.pixel_x + rand(-8, 8)
	spark.alpha = 0
	animate(spark, alpha = 255, time = 2 DECI SECONDS)
	SPAWN(0.6 SECONDS)
		qdel(spark)
