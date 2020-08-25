//Collection of animations we can reuse for stuff.
//Try to isolate animations you create an put them in here.
/proc/animate_buff_in(var/atom/A)
	var/matrix/M1 = matrix()
	M1.Scale(0,0)
	var/matrix/M2 = matrix()
	A.transform = M1
	A.alpha = 0
	animate(A, alpha = 255,  transform = M2, time = 10, easing = ELASTIC_EASING)

/proc/animate_buff_out(var/atom/A)
	var/matrix/M1 = matrix()
	var/matrix/M2 = matrix()
	M2.Scale(2,2)
	A.transform = M1
	A.alpha = 255
	animate(A, alpha = 0,  transform = M2, time = 10, easing = LINEAR_EASING)

/proc/animate_fade_grayscale(var/atom/A, var/time=5)
	if (!istype(A) && !isclient(A))
		return
	A.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
	animate(A, color=list(0.33, 0.33, 0.33, 0, 0.33, 0.33, 0.33, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 1), time=time, easing=SINE_EASING)
	return

/proc/animate_fade_from_grayscale(var/atom/A, var/time=5)
	if (!istype(A) && !isclient(A))
		return
	A.color = list(0.33, 0.33, 0.33, 0, 0.33, 0.33, 0.33, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 1)
	animate(A, color=list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1), time=time, easing=SINE_EASING)
	return

/proc/animate_melt_pixel(var/atom/A)
	if (!istype(A))
		return
	//A.alpha = 200
	animate(A, pixel_y = 0, time = 50 - A.pixel_y, alpha = 175, easing = BOUNCE_EASING)
	animate(alpha = 0, easing = LINEAR_EASING)
	return

/proc/animate_explode_pixel(var/atom/A)
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	side = pick(-1, 1)
	animate(A, pixel_x = A.pixel_x + rand(-1, 1), pixel_y = A.pixel_y + rand(-1, 1), time = 5, alpha = 255)
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
	animate(A, pixel_x = 20*sin(A.pixel_x), time = 30 + 20*sin(A.pixel_x), alpha = 175, easing = ELASTIC_EASING)
	animate(pixel_x = A.pixel_x, time = 30 + 20*sin(A.pixel_x), alpha = 175, easing = ELASTIC_EASING)
	return

/proc/animate_door_squeeze(var/atom/A)
	if (!istype(A))
		return
	//A.alpha = 200
	var/matrix/M = matrix()
	M.Scale(0.6, 1)
	animate(A, transform=M, time = 3,easing = BOUNCE_EASING)
	animate(transform=null, time = 3,easing = BOUNCE_EASING)
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
	var/matrix/shrink = matrix()
	shrink.Scale(0.4, 0.4)
	animate(A, color=col, transform=shrink, time=3, easing=BOUNCE_EASING)
	animate(color=null, transform=null, time=3, easing=BOUNCE_EASING)

/proc/animate_flock_floorrun_start(var/atom/A)
	if(!istype(A))
		return
	var/list/col = list(1,0,0, 0,1,0, 0,0,1, 0.15,0.77,0.66)
	var/matrix/shrink = matrix()
	shrink.Scale(0.0, 0.0)
	animate(A, color=col, transform=shrink, time=5, easing=SINE_EASING)

/proc/animate_flock_floorrun_end(var/atom/A)
	if(!istype(A))
		return
	animate(A, color=null, transform=null, time=5, easing=SINE_EASING)

/proc/animate_tile_dropaway(var/atom/A)
	if(!istype(A))
		return
	if(prob(10))
		playsound(get_turf(A), "sound/effects/creaking_metal[pick("1", "2")].ogg", 40, 1)
	var/image/underneath = image('icons/effects/white.dmi')
	underneath.appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	A.underlays += underneath
	var/matrix/pivot = matrix()
	pivot.Scale(0.2, 1.0)
	pivot.Translate(-16, 0)
	var/matrix/shrink = matrix()
	shrink.Scale(0.0, 0.0)
	animate(A, color="#808080", transform=pivot, time=30, easing=BOUNCE_EASING)
	animate(color="#FFFFFF", alpha=0, transform=shrink, time=10, easing=SINE_EASING)

/mob/New()
	..()
	src.attack_particle = new /obj/particle/attack //don't use pooling for these particles
	src.attack_particle.appearance_flags = TILE_BOUND
	src.attack_particle.filters = filter (type="blur", size=0.2)
	src.attack_particle.filters += filter (type="drop_shadow", x=1, y=-1, size=0.7)

	src.sprint_particle = new /obj/particle/attack/sprint //don't use pooling for these particles

/obj/particle/attack

	disposing() //kinda slow but whatever, block that gc ok
		for (var/mob/M in mobs)
			if (M.attack_particle == src)
				M.attack_particle = null
			if (M.sprint_particle == src)
				M.sprint_particle = null
		..()

	sprint
		icon = 'icons/mob/mob.dmi'
		icon_state = "sprint_cloud"
		layer = MOB_LAYER_BASE - 0.1
		appearance_flags = TILE_BOUND

	muzzleflash
		icon = 'icons/mob/mob.dmi'
		alpha = 255
		plane = PLANE_OVERLAY_EFFECTS

		unpooled()
			..()
			src.alpha = 255

		pooled()
			..()



/mob/var/obj/particle/attack/attack_particle
/mob/var/obj/particle/attack/sprint/sprint_particle




///obj/attackby(var/obj/item/I as obj, mob/user as mob)
//	attack_particle(user,src)
//	..()
/proc/attack_particle(var/mob/M, var/atom/target)
	if (!M || !target || !M.attack_particle) return
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
	SPAWN_DBG(5)
		//animate(M.attack_particle, alpha = 0, time = 2, flags = ANIMATION_PARALLEL)
		M.attack_particle.alpha = 0

/mob/var/last_interact_particle = 0

/proc/interact_particle(var/mob/M, var/atom/target)
	if (!M || !target) return
	if (world.time <= M.last_interact_particle + M.combat_click_delay) return
	var/diff_x = target.x - M.x
	var/diff_y = target.y - M.y
	SPAWN_DBG(0)
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
	SPAWN_DBG(0)
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
	SPAWN_DBG(0)
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
	SPAWN_DBG(5)
		M.attack_particle.alpha = 0

/proc/block_spark(var/mob/M)
	if (!M || !M.attack_particle) return

	M.attack_particle.invisibility = M.invisibility
	M.last_interact_particle = world.time

	M.attack_particle.icon = 'icons/mob/mob.dmi'
	if (M.attack_particle.icon_state == "block_spark")
		flick("block_spark",M.attack_particle)
	M.attack_particle.icon_state = "block_spark"

	M.attack_particle.alpha = 255
	M.attack_particle.loc = M.loc
	M.attack_particle.pixel_x = 0
	M.attack_particle.pixel_y = 0

	M.attack_particle.transform.Turn(rand(0,360))

	SPAWN_DBG(10)
		M.attack_particle.alpha = 0

proc/fuckup_attack_particle(var/mob/M)
	SPAWN_DBG(1)
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

proc/muzzle_flash_any(var/atom/movable/A, var/firing_angle, var/muzzle_anim, var/muzzle_light_color, var/offset=25)
	if (!A || firing_angle == null || !muzzle_anim) return

	var/obj/particle/attack/muzzleflash/muzzleflash = unpool(/obj/particle/attack/muzzleflash)

	if(isnull(muzzle_light_color))
		muzzle_light_color = default_muzzle_flash_colors[muzzle_anim]
	muzzleflash.overlays.Cut()
	if(muzzle_light_color)
		muzzle_simple_light.color = muzzle_light_color
		muzzleflash.overlays += muzzle_simple_light

	var/matrix/mat = new
	mat.Translate(0, offset)
	mat.Turn(firing_angle)
	muzzleflash.transform = mat
	muzzleflash.layer = A.layer
	muzzleflash.set_loc(A)
	A.vis_contents.Add(muzzleflash)
	if (muzzleflash.icon_state == muzzle_anim)
		flick(muzzle_anim,muzzleflash)
	muzzleflash.icon_state = muzzle_anim

	animate(muzzleflash, time=0.4 SECONDS)
	animate(alpha=0, easing=SINE_EASING, time=0.2 SECONDS)

	SPAWN_DBG(0.6 SECONDS)
		A.vis_contents.Remove(muzzleflash)
		pool(muzzleflash)



/proc/sprint_particle(var/mob/M, var/turf/T = null)
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.dir = null
	if (M.sprint_particle.icon_state == "sprint_cloud")
		flick("sprint_cloud",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud"


	SPAWN_DBG(6)
		if (M.sprint_particle.loc == T)
			M.sprint_particle.loc = null

/proc/sprint_particle_small(var/mob/M, var/turf/T = null, var/direct = null)
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.dir = direct
	if (M.sprint_particle.icon_state == "sprint_cloud_small")
		flick("sprint_cloud_small",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud_small"

	SPAWN_DBG(4)
		if (M.sprint_particle.loc == T)
			M.sprint_particle.loc = null

/proc/sprint_particle_tiny(var/mob/M, var/turf/T = null, var/direct = null)
	if (!M || !M.sprint_particle) return
	if (T)
		M.sprint_particle.loc = T
	else
		M.sprint_particle.loc = M.loc

	M.sprint_particle.dir = direct
	if (M.sprint_particle.icon_state == "sprint_cloud_tiny")
		flick("sprint_cloud_tiny",M.sprint_particle)
	M.sprint_particle.icon_state = "sprint_cloud_tiny"

	SPAWN_DBG(3)
		if (M.sprint_particle.loc == T)
			M.sprint_particle.loc = null

/proc/attack_twitch(var/atom/A)
	if (!istype(A) || istype(A, /mob/living/object))
		return		//^ possessed objects use an animate loop that is important for readability. let's not interrupt that with this dumb animation
	var/which = A.dir

	SPAWN_DBG(0)
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

		var/x = movepx + ipx
		var/y = movepy + ipy
		//Shift pixel offset
		animate(A, pixel_x = x, pixel_y = y, time = 0.6,easing = EASE_OUT)
		var/matrix/M = matrix(A.transform)
		animate(transform = turn(A.transform, (movepx - movepy) * 4), time = 0.6, easing = EASE_OUT)
		animate(pixel_x = ipx, pixel_y = ipy, time = 0.6,easing = EASE_IN)
		animate(transform = M, time = 0.6, easing = EASE_IN)




/proc/hit_twitch(var/atom/A)
	if (!A || istype(A, /mob/living/object))
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

	animate(A, pixel_x = x, pixel_y = y, time = 2,easing = EASE_IN)
	animate(A, pixel_x = ipx, pixel_y = ipy, time = 2,easing = EASE_IN)

//only call this from disorient. ITS NOT YOURS DAD
/proc/violent_twitch(var/atom/A)
	SPAWN_DBG(0)
		var/matrix/start = matrix(A.transform)
		var/matrix/target = matrix(A.transform)
		target.Scale(1,1)
		target.Turn(rand(-45,45))


		A.transform = target
		var/old_x = A.pixel_x
		var/old_y = A.pixel_y
		A.pixel_x += rand(-3,3)
		A.pixel_y += rand(-1,1)

		sleep(0.2 SECONDS)

		//Look i know this check looks janky. that's because IT IS. violent_twitch is ONLY called for disorient. okay. this stops it fucking up rest animation
		if (!A.hasStatus(list("weakened", "paralysis")))
			A.transform = start
		A.pixel_x = old_x
		A.pixel_y = old_y

// for vampire standup :)
/proc/violent_standup_twitch(var/atom/A)
	SPAWN_DBG(-1)
		var/matrix/start = matrix(A.transform)
		var/matrix/target = matrix(A.transform)
		target.Scale(1,1)
		target.Turn(rand(-45,45))
		A.transform = target

		for (var/i = 0, (i < 7 && A), i++)
			target = matrix(start)
			target.Turn(rand(-45,45))
			A.transform = target

			A.pixel_x = rand(-3,3)
			A.pixel_y = rand(-2,2)
			sleep(0.1 SECONDS)

		animate(A, pixel_x = 0, pixel_y = 0, transform = null, time = 1, easing = LINEAR_EASING)

/proc/eat_twitch(var/atom/A)
	var/matrix/squish_matrix = matrix(A.transform)
	squish_matrix.Scale(1,0.92)
	var/matrix/M = matrix(A.transform)
	squish_matrix.Scale(1,1)
	var/ipy = A.pixel_y

	animate(A, transform = squish_matrix, time = 1,easing = EASE_OUT)
	animate(pixel_y = -1, time = 1,easing = EASE_OUT)
	animate(transform = M, time = 1, easing = EASE_IN)
	animate(pixel_y = ipy, time = 1,easing = EASE_IN)

/proc/animate_portal_appear(var/atom/A)
	var/matrix/M1 = matrix()
	M1.Scale(0.6,0.05)
	var/matrix/M2 = matrix()

	A.transform = M1
	animate(A, transform = M2, time = 30, easing = ELASTIC_EASING)

/proc/animate_portal_tele(var/atom/A)
	var/matrix/M1 = matrix()
	M1.Scale(0.95,0.7)
	var/matrix/M2 = matrix()

	A.transform = M2
	animate(A, transform = M1, time = 1, easing = EASE_OUT)
	animate(transform = M2, time = 10, easing = ELASTIC_EASING)

/proc/animate_float(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side) side = pick(-1, 1)

	SPAWN_DBG(rand(1,10))
		if (A)
			animate(A, pixel_y = 32, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(floatdegrees * (side == 1 ? -1:1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
	return

/proc/animate_levitate(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side) side = pick(-1, 1)

	SPAWN_DBG(rand(1,10))
		if (A)
			var/initial_y = A.pixel_y
			animate(A, pixel_y = initial_y + 4, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
			animate(pixel_y = initial_y, transform = null, time = floatspeed, loop = loopnum, easing = SINE_EASING)
	return

/proc/animate_revenant_shockwave(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side) side = pick(-1, 1)

	SPAWN_DBG(rand(1,10))
		if (A)
			animate(A, pixel_y = 8, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(floatdegrees * (side == 1 ? -1:1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
	return

/proc/animate_glitchy_freakout(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix()
	var/looper = rand(3,5)
	while(looper > 0)
		looper--
		M.Scale(rand(1,4),rand(1,4))
		animate(A, transform = M, pixel_x = A.pixel_x + rand(-12,12), pixel_z = A.pixel_z + rand(-12,12), time = 3, loop = 1, easing = LINEAR_EASING)
		animate(transform = matrix(rand(-360,360), MATRIX_ROTATE), time = 3, loop = 1, easing = LINEAR_EASING)
		M.Scale(1,1)
		animate(transform = M, pixel_x = 0, pixel_z = 0, time = 1, loop = 1, easing = LINEAR_EASING)
		animate(transform = null, time = 1, loop = 1, easing = LINEAR_EASING)

/proc/animate_fading_leap_up(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix()
	var/do_loops = 15
	while (do_loops > 0)
		do_loops--
		animate(A, transform = M, pixel_z = A.pixel_z + 12, alpha = A.alpha - 17, time = 1, loop = 1, easing = LINEAR_EASING)
		M.Scale(1.2,1.2)
		sleep(0.1 SECONDS)
	A.alpha = 0

/proc/animate_fading_leap_down(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix()
	var/do_loops = 15
	M.Scale(18,18)
	while (do_loops > 0)
		do_loops--
		animate(A, transform = M, pixel_z = A.pixel_z - 12, alpha = A.alpha + 17, time = 1, loop = 1, easing = LINEAR_EASING)
		M.Scale(0.8,0.8)
		sleep(0.1 SECONDS)
	animate(A, transform = M, pixel_z = 0, alpha = 255, time = 1, loop = 1, easing = LINEAR_EASING)

/proc/animate_shake(var/atom/A,var/amount = 5,var/x_severity = 2,var/y_severity = 2, var/return_x = 0, var/return_y = 0)
	// Wiggles the sprite around on its tile then returns it to normal
	if (!istype(A))
		return
	if (!isnum(amount) || !isnum(x_severity) || !isnum(y_severity))
		return
	amount = max(1,min(amount,50))
	x_severity = max(-32,min(x_severity,32))
	y_severity = max(-32,min(y_severity,32))

	var/x_severity_inverse = 0 - x_severity
	var/y_severity_inverse = 0 - y_severity

	animate(A, transform = null, pixel_y = rand(y_severity_inverse,y_severity), pixel_x = rand(x_severity_inverse,x_severity),time = 1,loop = amount, easing = ELASTIC_EASING)
	SPAWN_DBG(amount)
		if (A)
			animate(A, transform = null, pixel_y = return_y, pixel_x = return_x,time = 1,loop = 1, easing = LINEAR_EASING)
	return

/proc/animate_teleport(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix(1, 3, MATRIX_SCALE)
	animate(A, transform = M, pixel_y = 32, time = 10, alpha = 50, easing = CIRCULAR_EASING)
	M.Scale(0,4)
	animate(transform = M, time = 5, color = "#1111ff", alpha = 0, easing = CIRCULAR_EASING)
	animate(transform = null, time = 5, color = "#ffffff", alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)
	return

/proc/animate_teleport_wiz(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix(0, 4, MATRIX_SCALE)
	animate(A, color = "#ddddff", time = 20, alpha = 70, easing = LINEAR_EASING)
	animate(transform = M, pixel_y = 32, time = 20, color = "#2222ff", alpha = 0, easing = CIRCULAR_EASING)
	animate(time = 8, transform = M, alpha = 5) //Do nothing, essentially
	animate(transform = null, time = 5, color = "#ffffff", alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)
	return

/proc/animate_rainbow_glow_old(var/atom/A)
	if (!istype(A))
		return
	animate(A, color = "#FF0000", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FF00", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#0000FF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	return

/proc/animate_rainbow_glow(var/atom/A)
	if (!istype(A))
		return
	animate(A, color = "#FF0000", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#FFFF00", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FF00", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#00FFFF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#0000FF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	animate(color = "#FF00FF", time = rand(5,10), loop = -1, easing = LINEAR_EASING)
	return

/proc/animate_fade_to_color_fill(var/atom/A,var/the_color,var/time)
	if (!istype(A) || !the_color || !time)
		return
	animate(A, color = the_color, time = time, easing = LINEAR_EASING)

/proc/animate_flash_color_fill(var/atom/A,var/the_color,var/loops,var/time)
	if (!istype(A) || !the_color || !time || !loops)
		return
	animate(A, color = the_color, time = time, easing = LINEAR_EASING)
	animate(color = "#FFFFFF", time = 5, loop = loops, easing = LINEAR_EASING)

/proc/animate_flash_color_fill_inherit(var/atom/A,var/the_color,var/loops,var/time)
	if (!istype(A) || !the_color || !time || !loops)
		return
	var/color_old = A.color
	animate(A, color = the_color, time = time, loop = loops, easing = LINEAR_EASING)
	animate(A, color = color_old, time = time, loop = loops, easing = LINEAR_EASING)

/proc/animate_clownspell(var/atom/A)
	if (!istype(A))
		return
	animate(A, transform = matrix(1.3, MATRIX_SCALE), time = 5, color = "#00ff00", easing = BACK_EASING)
	animate(transform = null, time = 5, color = "#ffffff", easing = ELASTIC_EASING)
	return

/proc/animate_wiggle_then_reset(var/atom/A, var/loops = 5, var/speed = 5, var/x_var = 3, var/y_var = 3)
	if (!istype(A) || !loops || !speed)
		return
	animate(A, pixel_x = rand(-x_var, x_var), pixel_y = rand(-y_var, y_var), time = speed * 2,loop = loops, easing = rand(2,7))
	animate(pixel_x = 0, pixel_y = 0, time = speed, easing = rand(2,7))

/proc/animate_blink(var/atom/A)
	if (!istype(A))
		return
	var/matrix/Orig = A.transform
	A.Scale(0.2,0.2)
	A.alpha = 50
	animate(A,transform = Orig, time = 3, alpha = 255, easing = CIRCULAR_EASING)
	return

/proc/animate_bullspellground(var/atom/A, var/spell_color = "#cccccc")
	if (!istype(A))
		return
	animate(A, time = 5, color = spell_color)
	animate(time = 5, color = "#ffffff")
	return

/proc/animate_spin(var/atom/A, var/dir = "L", var/T = 1, var/looping = -1)
	if (!istype(A))
		return

	var/matrix/M = A.transform
	var/turn = -90
	if (dir == "R")
		turn = 90

	animate(A, transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = T, loop = looping)
	return

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
		A.dir = WEST
		turndir = 90
		turned = matrix(A.transform, 90, MATRIX_ROTATE)

	else
		A.dir = EAST
		turndir = -90
		turned = matrix(A.transform, -90, MATRIX_ROTATE)

	animate(A, pixel_y = (A.pixel_y + 4), pixel_x = (A.pixel_x + 4), transform = turned, time = T, loop = loops, dir = EAST)
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
	SPAWN_DBG(3 SECONDS) qdel(E)
	return

/proc/animate_horizontal_wiggle(var/atom/A, var/loopnum = 5, speed = 10, X1 = 3, X2 = -3, var/slightly_random = 1)
	if (!istype(A))
		return

	if (slightly_random)
		var/rand_var = (rand(10, 14) / 10)
		DEBUG_MESSAGE("rand_var [rand_var]")
		speed = speed * rand_var
	animate(A, pixel_x = X1, time = speed, loop = loopnum, easing = LINEAR_EASING)
	animate(pixel_x = X2, time = speed, loop = loopnum, easing = LINEAR_EASING)
	return

/proc/animate_slide(var/atom/A, var/px, var/py, var/T = 10, var/ease = SINE_EASING)
	if(!istype(A))
		return

	animate(A, pixel_x = px, pixel_y = py, time = T, easing = ease)

/proc/animate_rest(var/atom/A, var/stand)
	if(!istype(A))
		return

	var/matrix/M = matrix()
	if (A.shrunk)
		M *= (0.75 ** A.shrunk)

	if(stand)
		animate(A, pixel_x = 0, pixel_y = 0, transform = M, time = 3, easing = LINEAR_EASING)
	else
		animate(A, pixel_x = 0, pixel_y = -4, transform = M.Turn(90), time = 2, easing = LINEAR_EASING)

/proc/animate_flip(var/atom/A, var/T)
	animate(A, transform = matrix(A.transform, 90, MATRIX_ROTATE), time = T)
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
					 time = (T + (time_diff*J/(laps*res))) / res )
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
	animate(A, transform = matrix(punchstr, MATRIX_ROTATE), pixel_y = 16, time = 2, color = "#eeeeee", easing = BOUNCE_EASING)
	animate(transform = matrix(-punchstr, MATRIX_ROTATE), pixel_y = original_y, time = 2, color = "#ffffff", easing = BOUNCE_EASING)
	animate(transform = null, time = 3, easing = BOUNCE_EASING)
	return

/proc/animate_glitchy_fuckup1(var/atom/A)
	if (!istype(A))
		return

	animate(A, pixel_z = A.pixel_z + -128, time = 3, loop = -1, easing = LINEAR_EASING)
	animate(pixel_z = A.pixel_z + 128, time = 0, loop = -1, easing = LINEAR_EASING)

/proc/animate_glitchy_fuckup2(var/atom/A)
	if (!istype(A))
		return

	animate(A, pixel_x = A.pixel_x + rand(-128,128), pixel_z = A.pixel_z + rand(-128,128), time = 2, loop = -1, easing = LINEAR_EASING)
	animate(pixel_x = 0, pixel_z = 0, time = 0, loop = -1, easing = LINEAR_EASING)

/proc/animate_glitchy_fuckup3(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix()
	var/matrix/MD = matrix()
	var/list/scaley_numbers = list(0.25,0.5,1,1.5,2)
	M.Scale(pick(scaley_numbers),pick(scaley_numbers))
	animate(A, transform = M, time = 1, loop = -1, easing = LINEAR_EASING)
	animate(transform = MD, time = 1, loop = -1, easing = LINEAR_EASING)

// these don't use animate but they're close enough, idk
/proc/showswirl(var/atom/target)
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	var/obj/decal/teleport_swirl/swirl = unpool(/obj/decal/teleport_swirl)
	swirl.set_loc(target_turf)
	swirl.pixel_y = 10
	playsound(target_turf, "sound/effects/teleport.ogg", 50, 1)
	SPAWN_DBG(1.5 SECONDS)
		if (swirl)
			swirl.pixel_y = 0
			pool(swirl)
	return

/proc/leaveresidual(var/atom/target)
	if (!target)
		return
	var/turf/target_turf = get_turf(target)
	if (!target_turf)
		return
	if (locate(/obj/decal/residual_energy) in target_turf)
		return
	var/obj/decal/residual_energy/e = unpool(/obj/decal/residual_energy)
	e.set_loc(target_turf)
	SPAWN_DBG(10 SECONDS)
		if (e)
			pool(e)
	return

/proc/sponge_size(var/atom/A, var/size = 1)
	var/matrix/M2 = matrix()
	M2.Scale(size,size)

	animate(A, transform = M2, time = 30, easing = ELASTIC_EASING)

/proc/animate_storage_rustle(var/atom/A)
	var/matrix/M1 = A.transform
	var/matrix/M2 = matrix()
	M2.Scale(1.2,0.8)

	animate(A, transform = M2, time = 30, easing = ELASTIC_EASING, flags = ANIMATION_END_NOW)
	animate(A, transform = M1, time = 20, easing = ELASTIC_EASING)

/proc/shrink_teleport(var/atom/teleporter)
	var/matrix/M = matrix(0.1, 0.1, MATRIX_SCALE)
	animate(teleporter, transform = M, pixel_y = 6, time = 4, alpha = 255, easing = SINE_EASING|EASE_OUT)
	sleep(0.2 SECONDS)
	animate(teleporter, transform = null, time = 9, alpha = 255, pixel_y = 0, easing = ELASTIC_EASING)
	//HAXXX sorry - kyle
	if (istype(teleporter, /mob/dead/observer))
		SPAWN_DBG(1 SECOND)
			animate_bumble(teleporter)


/proc/spawn_animation1(var/atom/A)
	var/matrix/M1 = matrix(0.1, 0.1, MATRIX_SCALE)
	A.transform = M1
	A.pixel_y = 300

	animate(A, transform = M1, time = 10, pixel_y = -16, alpha = 255, easing = QUAD_EASING)

	M1.Scale(10, 1)
	animate(transform = M1, time = 2, easing = SINE_EASING)


	M1.Scale(1, 10)
	animate(transform = null, time = 2, pixel_y = 0, easing = SINE_EASING)

/proc/leaving_animation(var/atom/A)
	animate(A, transform = matrix(0.1, 1, MATRIX_SCALE), time = 5, alpha = 255, easing = QUAD_EASING)
	animate(time = 10, pixel_y = 512, easing = CUBIC_EASING)
	sleep(1.5 SECONDS)

/proc/heavenly_spawn(var/obj/A)
	var/obj/heavenly_light/lightbeam = new /obj/heavenly_light
	lightbeam.set_loc(A.loc)
	var/was_anchored = A.anchored
	var/oldlayer = A.layer
	A.layer = EFFECTS_LAYER + 1
	A.anchored = 1
	A.alpha = 0
	A.pixel_y = 176
	lightbeam.alpha = 0
	playsound(A.loc,"sound/voice/heavenly3.ogg",50,0)
	animate(lightbeam, alpha=255, time=45)
	animate(A,alpha=255,time=45)
	SPAWN_DBG(45)
		animate(A, pixel_y = 0, time = 120, easing = SINE_EASING)
		sleep(12 SECONDS)
		A.anchored = was_anchored
		A.layer = oldlayer
		animate(lightbeam,alpha = 0, time=15)
		sleep(1.5 SECONDS)
		qdel(lightbeam)

/obj/heavenly_light
	icon = 'icons/obj/32x192.dmi'
	icon_state = "heavenlight"
	layer = EFFECTS_LAYER
	blend_mode = BLEND_ADD

var/global/icon/scanline_icon = icon('icons/effects/scanning.dmi', "scanline")
/proc/animate_scanning(var/atom/target, var/color, var/time=18, var/alpha_hex="96")
	var/fade_time = time / 2
	target.filters += filter(type = "layer", blend_mode = BLEND_INSET_OVERLAY, icon = scanline_icon, color = color + "00")
	var/filter = target.filters[target.filters.len]
	if(!filter) return
	animate(filter, y = -28, easing = QUAD_EASING, time = time)
	// animate(y = 0, easing = QUAD_EASING, time = time / 2) // TODO: add multiple passes option later
	animate(color = color + alpha_hex, time = fade_time, flags = ANIMATION_PARALLEL, easing = QUAD_EASING | EASE_IN)
	animate(color = color + "00", time = fade_time, easing = QUAD_EASING | EASE_IN)
	SPAWN_DBG(time)
		target.filters -= filter

/proc/animate_storage_thump(var/atom/A)
	if(!istype(A))
		return
	playsound(get_turf(A), "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 50, 1)
	var/wiggle = 6
	SPAWN_DBG(-1)
		while(wiggle > 0)
			wiggle--
			A.pixel_x = rand(-3,3)
			A.pixel_y = rand(-3,3)
			sleep(0.1 SECONDS)
		A.pixel_x = 0
		A.pixel_y = 0

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
		src.dir = T.dir
		src.color = T.color
		src.layer = T.layer - 1
		src.plane = T.plane


/proc/animate_turf_slideout(turf/T, new_turf_type, dir, time)
	var/image/orig = image(T.icon, T.icon_state, dir=T.dir)
	var/was_fullbright = T.fullbright
	orig.color = T.color
	orig.appearance_flags |= RESET_TRANSFORM
	T.ReplaceWith(new_turf_type)
	T.underlays += orig
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
		T.overlays -= /image/fullbright
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
		T.overlays += /image/fullbright
		T.RL_Init()

/proc/animate_open_from_floor(atom/A, time=1 SECOND, self_contained=1)
	A.filters += filter(type="alpha", icon='icons/effects/white.dmi', x=16)
	A.filters += filter(type="alpha", icon='icons/effects/black.dmi', x=-16) // has to be a different dmi because byond
	animate(A.filters[A.filters.len], x=0, time=time, easing=CUBIC_EASING | EASE_IN)
	animate(A.filters[A.filters.len - 1], x=0, time=time, easing=CUBIC_EASING | EASE_IN, flags=ANIMATION_PARALLEL)
	if(self_contained) // assume we're starting from being invisible
		A.alpha = 255
	if(self_contained)
		SPAWN_DBG(time)
			A.filters.len -= 2

/proc/animate_close_into_floor(atom/A, time=1 SECOND, self_contained=1)
	A.filters += filter(type="alpha", icon='icons/effects/white.dmi', x=0)
	A.filters += filter(type="alpha", icon='icons/effects/black.dmi', x=0) // has to be a different dmi because byond
	animate(A.filters[A.filters.len], x=-16, time=time, easing=CUBIC_EASING | EASE_IN)
	animate(A.filters[A.filters.len - 1], x=16, time=time, easing=CUBIC_EASING | EASE_IN, flags=ANIMATION_PARALLEL)
	if(self_contained)
		SPAWN_DBG(time)
			A.filters.len -= 2
			A.alpha = 0
