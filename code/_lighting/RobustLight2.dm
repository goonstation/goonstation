var/RL_Generation = 0
var/RL_Started = 0
var/RL_Suspended = 0

proc/RL_Start()
	global.RL_Started = 1
	for (var/datum/light/light)
		if (light.enabled)
			light.apply()
	for (var/turf/T in world)
		LAGCHECK_IF_LIVE(LAG_INIT)
		RL_UPDATE_LIGHT(T)

proc/RL_Suspend()
	global.RL_Suspended = 1
#ifdef DEBUG_LIGHT_STRIP_APPLY
	logTheThing(LOG_DEBUG, src, "<b>Light:</b> Suspended lighting.")
#endif
	//TODO

proc/RL_Resume()
	global.RL_Suspended = 0
#ifdef DEBUG_LIGHT_STRIP_APPLY
	logTheThing(LOG_DEBUG, src, "<b>Light:</b> Unsuspended lighting.")
#endif
	// TODO
	//I'm going to keep to my later statement for this and above: "for fucks sake tobba" -ZeWaka

//#define DEBUG_LIGHT_STRIP_APPLY
//#define DEBUG_MOVING_LIGHTS_STATS

#ifdef DEBUG_MOVING_LIGHTS_STATS
var/global/list/moving_lights_stats = list()
var/global/list/moving_lights_stats_by_first_attached = list()
var/global/list/color_changing_lights_stats = list()
var/global/list/color_changing_lights_stats_by_first_attached = list()

proc/get_moving_lights_stats()
	boutput(usr, json_encode(moving_lights_stats))
	boutput(usr, json_encode(moving_lights_stats_by_first_attached))
	boutput(usr, json_encode(color_changing_lights_stats))
	boutput(usr, json_encode(color_changing_lights_stats_by_first_attached))
#endif

#define D_BRIGHT 1
#define D_COLOR 2
#define D_HEIGHT 4
#define D_ENABLE 8
#define D_MOVE 16
						//only if lag				OR we already have stuff queued  OR lighting is suspeded 	also game needs to be started lol		and not doing a queue process currently
//#define SHOULD_QUEUE ((APPROX_TICK_USE > LIGHTING_MAX_TICKUSAGE || light_update_queue.cur_size) && current_state > GAME_STATE_SETTING_UP && !queued_run)
#define SHOULD_QUEUE (( light_update_queue.cur_size || APPROX_TICK_USE > LIGHTING_MAX_TICKUSAGE || RL_Suspended) && !queued_run && current_state > GAME_STATE_SETTING_UP)
/datum/light
	var/x
	var/y
	var/z

	var/x_des
	var/y_des
	var/z_des

	var/dir
	var/dir_des

	var/r = 1
	var/g = 1
	var/b = 1

	var/r_des = 1
	var/g_des = 1
	var/b_des = 1

	var/brightness = 1

	var/brightness_des = 1

	var/height = 1

	var/height_des = 1

	var/enabled = FALSE

	var/radius = 1
	var/premul_r = 1
	var/premul_g = 1
	var/premul_b = 1

	var/atom/attached_to = null
	var/attach_x = 0.5
	var/attach_y = 0.5

	var/dirty_flags = 0

#ifdef DEBUG_MOVING_LIGHTS_STATS
	var/atom/first_attached_to = null
#endif

#ifdef DEBUG_LIGHT_STRIP_APPLY
	var/apply_level = 0
#endif

/datum/light/New(x=0, y=0, z=0)
	..()
	src.x = x
	src.y = y
	src.z = z
	var/turf/T = locate(x, y, z)
	if (T)
		if (!T.RL_Lights)
			T.RL_Lights = list()
		T.RL_Lights |= src

/datum/light/disposing()
	src.disable(queued_run = 1) //dont queue... we wanna actually disable it before remove_from_turf etc
	src.remove_from_turf()
	src.detach()
	..()

/datum/light/proc/set_brightness(brightness, queued_run = FALSE)
	src.brightness_des = brightness
	if (src.brightness == brightness && !queued_run)
		return

	if (src.enabled)
		if (SHOULD_QUEUE)
			light_update_queue.queue(src)
			dirty_flags |= D_BRIGHT
			return

		var/strip_gen = ++global.RL_Generation
		var/list/affected = src.strip(strip_gen)

		src.brightness = brightness
		src.precalc()

		APPLY_AND_UPDATE
		if (global.RL_Started)
			for (var/turf/T as anything in affected)
				if (T.RL_UpdateGeneration <= strip_gen)
					RL_UPDATE_LIGHT(T)
	else
		src.brightness = brightness
		src.precalc()

/datum/light/proc/set_color(red, green, blue, queued_run = FALSE)
	if (src.r == red && src.g == green && src.b == blue && !queued_run)
		return
#ifdef DEBUG_MOVING_LIGHTS_STATS
	if (src.enabled)
		color_changing_lights_stats["[src.attached_to?.type]"]++
		color_changing_lights_stats_by_first_attached["[src.first_attached_to?.type]"]++
#endif

	if (src.enabled)
		if (SHOULD_QUEUE)
			global.light_update_queue.queue(src)
			src.dirty_flags |= D_COLOR
			src.r_des = red
			src.g_des = green
			src.b_des = blue
			return

		var/strip_gen = ++global.RL_Generation
		var/list/affected = src.strip(strip_gen)

		src.r = red
		src.g = green
		src.b = blue
		src.precalc()

		APPLY_AND_UPDATE
		if (global.RL_Started)
			for (var/turf/T as anything in affected)
				if (T.RL_UpdateGeneration <= strip_gen)
					RL_UPDATE_LIGHT(T)
	else
		src.r = red
		src.g = green
		src.b = blue
		src.precalc()

/datum/light/proc/set_height(height, queued_run = FALSE)
	src.height_des = height
	if (src.height == height && !queued_run)
		return

	if (src.enabled)
		if (SHOULD_QUEUE)
			global.light_update_queue.queue(src)
			src.dirty_flags |= D_HEIGHT
			return

		var/strip_gen = ++global.RL_Generation
		var/list/affected = src.strip(strip_gen)

		src.height = height
		src.precalc()

		APPLY_AND_UPDATE
		if (global.RL_Started)
			for (var/turf/T as anything in affected)
				if (T.RL_UpdateGeneration <= strip_gen)
					RL_UPDATE_LIGHT(T)
	else
		src.height = height
		src.precalc()

/datum/light/proc/enable(queued_run = FALSE)
	if (src.enabled)
		src.dirty_flags &= ~D_ENABLE
		return

	if (SHOULD_QUEUE)
		global.light_update_queue.queue(src)
		src.dirty_flags |= D_ENABLE
		return

	src.enabled = TRUE

	APPLY_AND_UPDATE

/datum/light/proc/disable(queued_run = FALSE)
	if (!src.enabled)
		src.dirty_flags &= ~D_ENABLE
		return

	if (SHOULD_QUEUE)
		global.light_update_queue.queue(src)
		src.dirty_flags |= D_ENABLE
		return

	src.enabled = FALSE

	if (global.RL_Started)
		for (var/turf/T as anything in src.strip(++global.RL_Generation))
			RL_UPDATE_LIGHT(T)

/datum/light/proc/detach()
	if (src.attached_to)
		src.attached_to.RL_Attached -= src
		src.attached_to = null

/datum/light/proc/attach(atom/A, offset_x = 0.5, offset_y = 0.5)
	if (src.attached_to)
		var/atom/old = src.attached_to
		old.RL_Attached -= src

	if (!A.RL_Attached)
		A.RL_Attached = list(src)
	else
		A.RL_Attached += src

	src.move(A.x + offset_x, A.y + offset_x, A.z, A.dir)
	src.attached_to = A
#ifdef DEBUG_MOVING_LIGHTS_STATS
	if(!src.first_attached_to)
		src.first_attached_to = A
#endif
	src.attach_x = offset_x
	src.attach_y = offset_y

// internals
/datum/light/proc/precalc()
	src.premul_r = src.r * src.brightness
	src.premul_g = src.g * src.brightness
	src.premul_b = src.b * src.brightness
	src.radius = min(round(sqrt(max((brightness * (RL_Atten_Quadratic - RL_Rad_QuadConstant)) / (-RL_Atten_Constant + RL_Rad_ConstConstant) - src.height**2, 0))), RL_MaxRadius)

/datum/light/proc/apply()
	if (!global.RL_Started)
		return list()
#ifdef DEBUG_LIGHT_STRIP_APPLY
	src.apply_level++
	if(src.apply_level != 1)
		logTheThing(LOG_DEBUG, src, "<b>Light:</b> [src] (at [src.x] [src.y] [src.z]) is at apply level [src.apply_level] after an apply.")
#endif
	return apply_internal(++global.RL_Generation, src.premul_r, src.premul_g, src.premul_b)

/datum/light/proc/strip(generation)
	if (!global.RL_Started)
		return list()
#ifdef DEBUG_LIGHT_STRIP_APPLY
	src.apply_level--
	if(src.apply_level != 0)
		logTheThing(LOG_DEBUG, src, "<b>Light:</b> [src] (at [src.x] [src.y] [src.z]) is at apply level [src.apply_level] after a strip.")
#endif
	return apply_internal(generation, -src.premul_r, -src.premul_g, -src.premul_b)

/datum/light/proc/remove_from_turf()
	var/turf/T = locate(src.x, src.y, src.z)
	if (T)
		if (T.RL_Lights && length(T.RL_Lights)) //ZeWaka: Fix for length(null)
			T.RL_Lights -= src
			if (!T.RL_Lights.len)
				T.RL_Lights = null
		else
			T.RL_Lights = null

/datum/light/proc/move(x, y, z, dir,queued_run = 0)
#ifdef DEBUG_MOVING_LIGHTS_STATS
	if (src.enabled)
		global.moving_lights_stats["[src.attached_to?.type]"]++
		global.moving_lights_stats_by_first_attached["[src.first_attached_to?.type]"]++
#endif

	src.x_des = x
	src.y_des = y
	src.z_des = z
	src.dir_des = dir

	if (SHOULD_QUEUE)
		global.light_update_queue.queue(src)
		src.dirty_flags |= D_MOVE
		return

	src.remove_from_turf()
	var/strip_gen = ++global.RL_Generation
	var/list/affected
	if (src.enabled)
		affected = src.strip(strip_gen)

	src.x = x
	src.y = y
	src.z = z
	src.dir = dir

	var/turf/new_turf = locate(x, y, z)
	if (new_turf)
		if (!new_turf.RL_Lights)
			new_turf.RL_Lights = list()
		new_turf.RL_Lights |= src

	if (src.enabled && global.RL_Started)
		APPLY_AND_UPDATE
		for (var/turf/T as anything in affected)
			if (T.RL_UpdateGeneration <= strip_gen)
				RL_UPDATE_LIGHT(T)

/datum/light/proc/move_defer(x, y, z) //not called anywhere! if we decide to use this later add it to queueing ok thx
	. = src.strip(++global.RL_Generation)
	src.x = x
	src.y = y
	src.z = z

	. |= src.apply()

/datum/light/proc/apply_to(turf/T)
	CRASH("Default apply_to called, did you mean to create a /datum/light/point and not a /datum/light?")

/datum/light/proc/apply_internal(generation, r, g, b) // per light type
	CRASH("Default apply_internal called, did you mean to create a /datum/light/point and not a /datum/light?")

#define ADDUPDATE(var) if (var.RL_UpdateGeneration < generation) {var.RL_UpdateGeneration = generation; . += var;}

/datum/light/point

/datum/light/point/apply_to(turf/T)
	RL_APPLY_LIGHT(T, src.x, src.y, src.brightness, src.height ** 2, r, g, b)

/datum/light/point/apply_internal(generation, r, g, b)
	. = list()
	var/height2 = src.height ** 2
	var/turf/middle = locate(src.x, src.y, src.z)
	var/atten
	for (var/turf/T in view(src.radius, middle))
		if (T.opacity)
			continue
		if (T.opaque_atom_count > 0)
			continue

		RL_APPLY_LIGHT_EXPOSED_ATTEN(T, src.x, src.y, src.brightness, height2, r, g, b)
		if (atten < RL_Atten_Threshold)
			continue
		T.RL_ApplyGeneration = generation
		T.RL_UpdateGeneration = generation
		. += T

	for (var/turf/T as anything in .)
		var/E_new = FALSE
		var/turf/E = get_step(T, EAST)
		if (E && E.RL_ApplyGeneration < generation)
			E_new = TRUE
			RL_APPLY_LIGHT_EXPOSED_ATTEN(E, src.x, src.y, src.brightness, height2, r, g, b)
			if(atten >= RL_Atten_Threshold)
				E.RL_ApplyGeneration = generation
				if(get_step(T, SOUTHEAST))
					ADDUPDATE(get_step(T, SOUTHEAST))
				ADDUPDATE(E)

		var/turf/N = get_step(T, NORTH)
		if (N && N.RL_ApplyGeneration < generation)
			RL_APPLY_LIGHT_EXPOSED_ATTEN(N, src.x, src.y, src.brightness, height2, r, g, b)
			if(atten >= RL_Atten_Threshold)
				N.RL_ApplyGeneration = generation
				if(get_step(T, NORTHWEST))
					ADDUPDATE(get_step(T, NORTHWEST))
				ADDUPDATE(N)

			// this if is a bit more complicated because we don't want to do NE
			// if the turf will get updated some other relevant turf's E or N
			// because we'd lose the south or west neighbour update this way
			// i.e. it should only get updated if both T.E and T.N are not added in the view() phase
			var/turf/NE = get_step(T, NORTHEAST)
			if (E_new && NE && NE.RL_ApplyGeneration < generation)
				RL_APPLY_LIGHT_EXPOSED_ATTEN(NE, src.x, src.y, src.brightness, height2, r, g, b)
				if(atten >= RL_Atten_Threshold)
					NE.RL_ApplyGeneration = generation
					ADDUPDATE(NE)

		if (get_step(T, WEST))
			ADDUPDATE(get_step(T, WEST))
		if (get_step(T, SOUTH))
			ADDUPDATE(get_step(T, SOUTH))
		if (get_step(T, SOUTHWEST))
			ADDUPDATE(get_step(T, SOUTHWEST))

/datum/light/line
	var/dist_cast = 0

/datum/light/line/precalc()
	src.premul_r = src.r * src.brightness
	src.premul_g = src.g * src.brightness
	src.premul_b = src.b * src.brightness
	src.radius = min(round(sqrt(max((brightness * (RL_Atten_Quadratic)) / -RL_Atten_Constant - src.height**2, 0))), RL_MaxRadius) * 0.6

/datum/light/line/apply_to(turf/T)
	RL_APPLY_LIGHT_LINE(T, src.x, src.y, src.dir, dist_cast, src.brightness, src.height**2, r, g, b)

/datum/light/line/apply_internal(generation, r, g, b)
	. = list()
	var/height2 = src.height ** 2

	var/vx = 0
	var/vy = 0
	if (src.dir == NORTH)
		vy = radius
	else if (src.dir == SOUTH)
		vy = -radius
	else if (src.dir & WEST)
		vx = -radius
	else if (src.dir & EAST)
		vx = radius
	else //blah i guess prefer south if no dir
		vy = -radius

	var/turf/middle = locate(src.x, src.y, src.z)
	var/list/turfline = global.getstraightlinewalled(middle,vx,vy)
	if (!turfline)
		return
	src.dist_cast = max(turfline.len,1)

	for (var/turf/T in turfline)
		RL_APPLY_LIGHT_LINE(T, src.x, src.y, src.dir, src.dist_cast, src.brightness, height2, r, g, b)
		T.RL_ApplyGeneration = generation
		T.RL_UpdateGeneration = generation
		. += T

	for (var/turf/T as anything in .)

		var/turf/E = get_step(T, EAST)
		if (E && E.RL_ApplyGeneration < generation)
			E.RL_ApplyGeneration = generation
			RL_APPLY_LIGHT_LINE(E, src.x, src.y, src.dir, src.dist_cast, src.brightness, height2, r, g, b)
			ADDUPDATE(E)
			if(get_step(T, SOUTHEAST))
				ADDUPDATE(get_step(T, SOUTHEAST))

		var/turf/N = get_step(T, NORTH)
		if (N && N.RL_ApplyGeneration < generation)
			N.RL_ApplyGeneration = generation
			RL_APPLY_LIGHT_LINE(N, src.x, src.y, src.dir, src.dist_cast, src.brightness, height2, r, g, b)
			ADDUPDATE(N)
			if(get_step(T, NORTHWEST))
				ADDUPDATE(get_step(T, NORTHWEST))

		var/turf/NE = get_step(T, NORTHEAST)
		if (NE && NE.RL_ApplyGeneration < generation)
			RL_APPLY_LIGHT_LINE(NE, src.x, src.y, src.dir, src.dist_cast, src.brightness, height2, r, g, b)
			NE.RL_ApplyGeneration = generation
			ADDUPDATE(NE)

		if(get_step(T, WEST))
			ADDUPDATE(get_step(T, WEST))
		if(get_step(T, SOUTH))
			ADDUPDATE(get_step(T, SOUTH))
		if(get_step(T, SOUTHWEST))
			ADDUPDATE(get_step(T, SOUTHWEST))

		//account for blocked visibility (try to worm me way around somethin) also lol this is shit and doesnt work. maybe fix later :)
		/*
		if (dist_cast < radius && length(turfline))
			var/turf/blockedturf = turfline[turfline.len]
			if (vx)
				if (vx > 0) vx -= dist_cast
				else vx += dist_cast
				var/turf/o1 = locate(blockedturf.x, blockedturf.y+1, blockedturf.z)
				var/turf/o2 = locate(blockedturf.x, blockedturf.y-1, blockedturf.z)
				turfline = getstraightlinewalled(o1,vx,vy,0) + getstraightlinewalled(o2,vx,vy,0)
			else
				if (vy > 0) vy -= dist_cast
				else vy += dist_cast
				var/turf/o1 = locate(blockedturf.x+1, blockedturf.y, blockedturf.z)
				var/turf/o2 = locate(blockedturf.x-1, blockedturf.y, blockedturf.z)
				turfline = getstraightlinewalled(o1,vx,vy,0) + getstraightlinewalled(o2,vx,vy,0)

			for (var/turf/T in turfline)
				if (T.RL_ApplyGeneration < generation)
					T.RL_ApplyGeneration = generation
					RL_APPLY_LIGHT_LINE(T, src.x, src.y, src.dir, dist_cast, src.brightness, height2, r, g, b)
				ADDUPDATE(T)
		*/

/datum/light/cone
	var/outer_angular_size = 90
	var/inner_angular_size = 80
	var/inner_radius = 1

/datum/light/cone/apply_to(turf/T)
	RL_APPLY_LIGHT(T, src.x, src.y, src.brightness, src.height**2, r, g, b)

/datum/light/cone/apply_internal(generation, r, g, b)
	. = list()
	var/height2 = src.height ** 2
	var/turf/middle = locate(src.x, src.y, src.z)
	var/atten

	#define ANGLE_CHECK(T) angle_inbetween(arctan(T.x - src.x, T.y - src.y), min_angle, max_angle)
	#define APPLY(T) RL_APPLY_LIGHT_EXPOSED_ATTEN(T, src.x, src.y, \
		src.brightness \
		* clamp(((src.x - T.x)*(src.x - T.x) + (src.y - T.y)*(src.y - T.y)) / inner_radius, 0, 1) \
		* clamp((outer_angular_size / 2 - abs(angledifference(arctan(T.x - src.x, T.y - src.y), center_angle))) / ((outer_angular_size - inner_angular_size) / 2), 0, 1) ** 2\
		, height2, r, g, b)

	// conversion from angles clock to normal angles
	var/center_angle = 90 - global.dir_to_angle(src.dir)
	var/min_angle = center_angle - src.outer_angular_size / 2
	var/max_angle = center_angle + src.outer_angular_size / 2
	for (var/turf/T in view(src.radius, middle))
		if (T.opacity)
			continue
		if(T.opaque_atom_count > 0)
			continue
		if (!ANGLE_CHECK(T))
			continue

		APPLY(T)
		if(atten < RL_Atten_Threshold)
			continue
		T.RL_ApplyGeneration = generation
		T.RL_UpdateGeneration = generation
		. += T

	for (var/turf/T as anything in .)
		var/E_new = FALSE
		var/turf/E = get_step(T, EAST)
		if (E && E.RL_ApplyGeneration < generation && ANGLE_CHECK(E))
			E_new = TRUE
			APPLY(E)
			if (atten >= RL_Atten_Threshold)
				E.RL_ApplyGeneration = generation
				if(get_step(T, SOUTHEAST))
					ADDUPDATE(get_step(T, SOUTHEAST))
				ADDUPDATE(E)

		var/turf/N = get_step(T, NORTH)
		if (N && N.RL_ApplyGeneration < generation && ANGLE_CHECK(N))
			APPLY(N)
			if (atten >= RL_Atten_Threshold)
				N.RL_ApplyGeneration = generation
				if (get_step(T, NORTHWEST))
					ADDUPDATE(get_step(T, NORTHWEST))
				ADDUPDATE(N)

			// this if is a bit more complicated because we don't want to do NE
			// if the turf will get updated some other relevant turf's E or N
			// because we'd lose the south or west neighbour update this way
			// i.e. it should only get updated if both T.E and T.N are not added in the view() phase
			var/turf/NE = get_step(T, NORTHEAST)
			if (E_new && NE && NE.RL_ApplyGeneration < generation && ANGLE_CHECK(NE))
				APPLY(NE)
				if(atten >= RL_Atten_Threshold)
					NE.RL_ApplyGeneration = generation
					ADDUPDATE(NE)

		if (get_step(T, WEST))
			ADDUPDATE(get_step(T, WEST))
		if (get_step(T, SOUTH))
			ADDUPDATE(get_step(T, SOUTH))
		if (get_step(T, SOUTHWEST))
			ADDUPDATE(get_step(T, SOUTHWEST))

	#undef ANGLE_CHECK
	#undef APPLY

/obj/overlay/tile_effect
	event_handler_flags = IMMUNE_SINGULARITY | IMMUNE_OCEAN_PUSH | IMMUNE_TRENCH_WARP
	appearance_flags = TILE_BOUND | PIXEL_SCALE

/*
	How Lighting Overlays Work:

	Succinctly, the RGBA channels of each pixel represent the influence that the lights on the parent tile, the east tile, the
	north tile, and the northeast tile have on that pixel on parent tile respectively, somewhat akin to a normal map. The exact
	effect that this will create depends on whether the overlay is additive or multiplicative (add / mul).

	The initial sprite, `no name` in all lighting overlay files, was programmatically generated using Python, from this initial
	sprite, five sprites were handcrafted and then passed into the `icon-cutter` tool to generate the remaining directional sprites.
*/
/obj/overlay/tile_effect/lighting
	icon = 'icons/effects/lighting_overlays/floors.dmi'
	appearance_flags = TILE_BOUND | PIXEL_SCALE | RESET_ALPHA | RESET_COLOR
	blend_mode = BLEND_ADD
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_BASE
	anchored = ANCHORED_ALWAYS

/obj/overlay/tile_effect/lighting/mul
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_ROBUST
	disposing()
		var/turf/T = src.loc
		if(T?.RL_MulOverlay == src)
			T.RL_MulOverlay = null
		..()

/obj/overlay/tile_effect/lighting/add
	plane = PLANE_SELFILLUM
	disposing()
		var/turf/T = src.loc
		if(T?.RL_AddOverlay == src)
			T.RL_AddOverlay = null
		..()

/turf
	var/RL_ApplyGeneration = 0
	var/RL_UpdateGeneration = 0
	var/obj/overlay/tile_effect/lighting/mul/RL_MulOverlay = null
	var/obj/overlay/tile_effect/lighting/add/RL_AddOverlay = null
	var/RL_LumR = 0
	var/RL_LumG = 0
	var/RL_LumB = 0
	var/RL_AddLumR = 0
	var/RL_AddLumG = 0
	var/RL_AddLumB = 0
	var/RL_NeedsAdditive = FALSE
	var/RL_OverlayIcon = 'icons/effects/lighting_overlays/floors.dmi'
	var/RL_OverlayState = ""
	var/list/datum/light/RL_Lights = null
	var/opaque_atom_count = 0
#ifdef DEBUG_LIGHTING_UPDATES
	var/obj/maptext_junk/RL_counter/counter = null
#endif

/turf/proc/RL_ApplyLight(lx, ly, brightness, height2, r, g, b) // use the RL_APPLY_LIGHT macro instead if at all possible!!!!
#ifdef DEBUG_LIGHTING_UPDATES
	if (!src.counter)
		src.counter = new(src)
	src.counter.tick(apply = 1, generation = global.RL_Generation)
#endif
	var/area/A = get_area(src)
	if (A.force_fullbright)
		return

	//MBC : this needed to be removed to fix construction. might be a bit slower but idk how else it would be fixed
	//basically , even though fullbright turfs like space do not have light overlays...
	//we still want them to keep track of how they would be affected by nearby lights, in case someone does build over them.
	//if (fullbright)
	//	return

	var/atten = (brightness * RL_Atten_Quadratic) / ((src.x - lx) ** 2 + (src.y - ly) ** 2 + height2) + RL_Atten_Constant
	if (atten < RL_Atten_Threshold)
		return
	src.RL_LumR += r * atten
	src.RL_LumG += g * atten
	src.RL_LumB += b * atten

	//Needed these to prevent a weird bug from the dark times where tiles went pitch black and couldn't be fixed - ZeWaka
	//I really want negative lights to be a thing so I'll just hope that this bandaid is no longer necessary. Feel free to uncomment if I'm wrong - pali
	//I was wrong - pali
	/*
	RL_LumR = max(RL_LumR, 0)
	RL_LumG = max(RL_LumG, 0)
	RL_LumB = max(RL_LumB, 0)
	*/

	src.RL_AddLumR = clamp((src.RL_LumR - 1) * 0.5, 0, 0.3)
	src.RL_AddLumG = clamp((src.RL_LumG - 1) * 0.5, 0, 0.3)
	src.RL_AddLumB = clamp((src.RL_LumB - 1) * 0.5, 0, 0.3)
	src.RL_NeedsAdditive = (src.RL_AddLumR > 0) || (src.RL_AddLumG > 0) || (src.RL_AddLumB > 0)

/turf/proc/RL_UpdateLight() // use the RL_UPDATE_LIGHT macro instead if at all possible!!!!
	if (!RL_Started)
		return
#ifdef DEBUG_LIGHTING_UPDATES
	if (!src.counter)
		counter = new(src)
	counter.tick(update = 1, generation = global.RL_Generation)
#endif
	RL_UPDATE_LIGHT(src)

/turf/proc/RL_SetSprite(state, icon)
	if (icon)
		src.RL_OverlayIcon = icon
	src.RL_OverlayState = state

	if (src.RL_MulOverlay)
		src.RL_MulOverlay.icon = src.RL_OverlayIcon
		src.RL_MulOverlay.icon_state = src.RL_OverlayState
	if (src.RL_AddOverlay)
		src.RL_AddOverlay.icon = src.RL_OverlayIcon
		src.RL_AddOverlay.icon_state = src.RL_OverlayState

// Approximate RGB -> Luma conversion formula.
/turf/proc/RL_GetBrightness()
	return max(0, ((src.RL_LumR * 0.33) + (src.RL_LumG * 0.5) + (src.RL_LumB * 0.16)))

/turf/proc/RL_Cleanup()
	if (src.RL_MulOverlay)
		qdel(src.RL_MulOverlay)
		src.RL_MulOverlay = null
	if (src.RL_AddOverlay)
		qdel(src.RL_AddOverlay)
		src.RL_AddOverlay = null

/turf/proc/RL_Reset()
	src.RL_ApplyGeneration = 0
	src.RL_UpdateGeneration = 0
	src.RL_MulOverlay = null
	src.RL_AddOverlay = null

	src.RL_LumR = 0
	src.RL_LumG = 0
	src.RL_LumB = 0
	src.RL_AddLumR = 0
	src.RL_AddLumG = 0
	src.RL_AddLumB = 0
	src.RL_NeedsAdditive = FALSE
	src.RL_OverlayState = ""
	src.RL_Lights = null

/turf/proc/RL_Init()
	if (!fullbright && !loc:force_fullbright)
		if(!src.RL_MulOverlay)
			src.RL_MulOverlay = new /obj/overlay/tile_effect/lighting/mul(src)
			src.RL_MulOverlay.icon = src.RL_OverlayIcon
			src.RL_MulOverlay.icon_state = src.RL_OverlayState
		if (RL_Started)
			RL_UPDATE_LIGHT(src)
	else
		if (src.RL_MulOverlay)
			qdel(src.RL_MulOverlay)
			src.RL_MulOverlay = null
		if (src.RL_AddOverlay)
			qdel(src.RL_AddOverlay)
			src.RL_AddOverlay = null

/atom
	var/RL_Attached = null
	var/old_dir = null //rl only right now
	var/next_light_dir_update = 0

/atom/movable

	Move(atom/target)
		var/old_loc = src.loc
		. = ..()
		if (src.loc != old_loc && src.RL_Attached)
			for (var/datum/light/light as anything in src.RL_Attached)
				light.move(src.x + light.attach_x, src.y + light.attach_y, src.z, src.dir)
		// commented out for optimization purposes, let's hope it doesn't matter too much
		/*
		if(src.opacity)
			var/turf/OL = old_loc
			if(istype(OL)) --OL.opaque_atom_count
			var/turf/NL = src.loc
			if(istype(NL)) ++NL.opaque_atom_count
		*/

	proc/update_directional_lights()
		if (src.dir != old_dir && src.RL_Attached && TIME > next_light_dir_update)
			next_light_dir_update = TIME + 0.2 SECONDS
			old_dir = src.dir
			for (var/datum/light/line/light in src.RL_Attached)
				light.move(src.x + light.attach_x, src.y + light.attach_y, src.z, src.dir)


	set_loc(atom/target)
		if (opacity)
			var/list/datum/light/lights = list()
			for (var/turf/T in view(RL_MaxRadius, get_turf(src)))
				if (T.RL_Lights)
					lights |= T.RL_Lights

			var/list/affected = list()
			for (var/datum/light/light as anything in lights)
				if (light.enabled)
					affected |= light.strip(++global.RL_Generation)

			var/turf/OL = src.loc
			if (istype(OL))
				--OL.opaque_atom_count
			var/turf/NL = target
			if (istype(NL))
				++NL.opaque_atom_count

			. = ..()

			for (var/datum/light/light as anything in lights)
				if (light.enabled)
					affected |= light.apply()
			if (RL_Started)
				for (var/turf/T as anything in affected)
					RL_UPDATE_LIGHT(T)
		else
			. = ..()

		if (src.RL_Attached) // TODO: defer updates and update all affected tiles at once?
			var/dont_queue = (loc == null) //if we are being thrown to a null loc, dont queue this move. we need it Now.
			for (var/datum/light/light as anything in src.RL_Attached)
				light.move(src.x+0.5, src.y+0.5, src.z, src.dir, queued_run = dont_queue)

	disposing()
		if (src.RL_Attached)
			for (var/datum/light/attached as anything in src.RL_Attached)
				attached.disable(queued_run = 1)
				// Detach the light from its holder so that it gets cleaned up right if
				// needed.
				attached.detach()
			src.RL_Attached:len = 0
			src.RL_Attached = null
		if (opacity)
			set_opacity(0)
		..()
