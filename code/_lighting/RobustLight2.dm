var/RL_Generation = 0

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

// TODO readd counters for debugging
#define RL_UPDATE_LIGHT(src) do { \
	if (src.fullbright || src.loc?:force_fullbright) { break } \
	var/turf/_N = get_step(src, NORTH); \
	var/turf/_E = get_step(src, EAST); \
	var/turf/_NE = get_step(src, NORTHEAST); \
	if(!_N || !_E || !_NE) { break }; \
	src.RL_MulOverlay?.color = list( \
		src.RL_LumR, src.RL_LumG, src.RL_LumB, 0, \
		_E.RL_LumR, _E.RL_LumG, _E.RL_LumB, 0, \
		_N.RL_LumR, _N.RL_LumG, _N.RL_LumB, 0, \
		_NE.RL_LumR, _NE.RL_LumG, _NE.RL_LumB, 0, \
		DLL, DLL, DLL, 1 \
		) ; \
	if (src.RL_NeedsAdditive || _E.RL_NeedsAdditive || _N.RL_NeedsAdditive || _NE.RL_NeedsAdditive) { \
		if(!src.RL_AddOverlay) { \
			src.RL_AddOverlay = new /obj/overlay/tile_effect/lighting/add ; \
			src.RL_AddOverlay.set_loc(src) ; \
			src.RL_AddOverlay.icon_state = src.RL_OverlayState ; \
		} \
		src.RL_AddOverlay.color = list( \
			src.RL_AddLumR, src.RL_AddLumG, src.RL_AddLumB, 0, \
			_E.RL_AddLumR, _E.RL_AddLumG, _E.RL_AddLumB, 0, \
			_N.RL_AddLumR, _N.RL_AddLumG, _N.RL_AddLumB, 0, \
			_NE.RL_AddLumR, _NE.RL_AddLumG, _NE.RL_AddLumB, 0, \
			0, 0, 0, 1) ; \
	} else { if(src.RL_AddOverlay) { qdel(src.RL_AddOverlay); src.RL_AddOverlay = null; } } \
	} while(false)


// requires atten to be defined outside
#define RL_APPLY_LIGHT_EXPOSED_ATTEN(src, lx, ly, brightness, height2, r, g, b) do { \
	if (src.loc?:force_fullbright) { break } \
	atten = (brightness*RL_Atten_Quadratic) / ((src.x - lx)*(src.x - lx) + (src.y - ly)*(src.y - ly) + height2) + RL_Atten_Constant ; \
	if (atten < RL_Atten_Threshold) { break } \
	src.RL_LumR += r*atten ; \
	src.RL_LumG += g*atten ; \
	src.RL_LumB += b*atten ; \
	src.RL_AddLumR = clamp((src.RL_LumR - 1) * 0.5, 0, 0.3) ; \
	src.RL_AddLumG = clamp((src.RL_LumG - 1) * 0.5, 0, 0.3) ; \
	src.RL_AddLumB = clamp((src.RL_LumB - 1) * 0.5, 0, 0.3) ; \
	src.RL_NeedsAdditive = src.RL_AddLumR + src.RL_AddLumG + src.RL_AddLumB ; \
	} while(false)

#define RL_APPLY_LIGHT(src, lx, ly, brightness, height2, r, g, b) do { \
	var/atten ; \
	 RL_APPLY_LIGHT_EXPOSED_ATTEN(src, lx, ly, brightness, height2, r, g, b) ; \
	} while(false)

#define RL_APPLY_LIGHT_LINE(src, lx, ly, dir, radius, brightness, height2, r, g, b) do { \
	if (src.loc?:force_fullbright) { break } \
	var/atten = (brightness*RL_Atten_Quadratic) / ((src.x - lx)*(src.x - lx) + (src.y - ly)*(src.y - ly) + height2) + RL_Atten_Constant ; \
	var/exponent = 3.5 ;\
	atten *= (max( abs(ly-src.y),abs(lx-src.x),0.85 )/radius)**exponent ;\
	if (radius <= 1) { atten *= 0.1 }\
	else if (radius <= 2) { atten *= 0.5 }\
	else if (radius == 3) { atten *= 0.8 }\
	else{\
		var/mult_atten = 1;\
		var/line_len = (abs(src.x - lx)+abs(src.y - ly));\
		if (line_len <= 1.1) { mult_atten = 4.6 } \
		else if (line_len<=1.5) { mult_atten = 3 } \
		else if (line_len<=2.5) { mult_atten = 2 } \
		switch(dir){ \
			if (NORTH){ if (round(ly) - src.y < 0){ atten *= mult_atten } }\
			if (WEST){ if (ceil(lx) - src.x > 0){ atten *= mult_atten } }\
			if (EAST){ if (round(lx) - src.x < 0){ atten *= mult_atten } }\
			if (SOUTH){ if (ceil(ly) - src.y > 0){ atten *= mult_atten } }\
		}\
		if (round(line_len) >= radius) { atten *= 0.4 } \
	}\
	if (atten < RL_Atten_Threshold) { break } \
	src.RL_LumR += r*atten ; \
	src.RL_LumG += g*atten ; \
	src.RL_LumB += b*atten ; \
	src.RL_AddLumR = clamp((src.RL_LumR - 1) * 0.5, 0, 0.3) ; \
	src.RL_AddLumG = clamp((src.RL_LumG - 1) * 0.5, 0, 0.3) ; \
	src.RL_AddLumB = clamp((src.RL_LumB - 1) * 0.5, 0, 0.3) ; \
	src.RL_NeedsAdditive = src.RL_AddLumR + src.RL_AddLumG + src.RL_AddLumB ; \
	} while(false)

#define APPLY_AND_UPDATE if (RL_Started) { for (var/turf in src.apply()) { var/turf/T = turf; RL_UPDATE_LIGHT(T) } }

#define RL_Atten_Quadratic 2.2 // basically just brightness scaling atm
#define RL_Atten_Constant -0.11 // constant subtracted at every point to make sure it goes <0 after some distance
#define RL_Atten_Threshold 2/256 // imperceptible change
#define RL_Rad_QuadConstant 0.9 //Subtracted from the quadratic constant for light.radius
#define RL_Rad_ConstConstant 0.03 //Added to the -linear constant for light.radius
#define RL_MaxRadius 6 // maximum allowed light.radius value. if any light ends up needing more than this it'll cap and look screwy
#define DLL 0 //Darkness Lower Limit, at 0 things can get absolutely pitch black.

#ifdef UPSCALED_MAP
#undef DLL
#define DLL 0.2
#endif

#define D_BRIGHT 1
#define D_COLOR 2
#define D_HEIGHT 4
#define D_ENABLE 8
#define D_MOVE 16
						//only if lag				OR we already have stuff queued  OR lighting is suspeded 	also game needs to be started lol		and not doing a queue process currently
//#define SHOULD_QUEUE ((APPROX_TICK_USE > LIGHTING_MAX_TICKUSAGE || light_update_queue.cur_size) && current_state > GAME_STATE_SETTING_UP && !queued_run)
#define SHOULD_QUEUE (( light_update_queue.cur_size || APPROX_TICK_USE > LIGHTING_MAX_TICKUSAGE || RL_Suspended) && !queued_run && current_state > GAME_STATE_SETTING_UP)
datum/light
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

	var/enabled = 0

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

	New(x=0, y=0, z=0)
		..()
		src.x = x
		src.y = y
		src.z = z
		var/turf/T = locate(x, y, z)
		if (T)
			if (!T.RL_Lights)
				T.RL_Lights = list()
			T.RL_Lights |= src


	disposing()
		disable(queued_run = 1) //dont queue... we wanna actually disable it before remove_from_turf etc
		remove_from_turf()
		detach()
		..()

	proc
		set_brightness(brightness, queued_run = 0)
			src.brightness_des = brightness
			if (src.brightness == brightness && !queued_run)
				return

			if (src.enabled)
				if (SHOULD_QUEUE)
					light_update_queue.queue(src)
					dirty_flags |= D_BRIGHT
					return

				var/strip_gen = ++RL_Generation
				var/list/affected = src.strip(strip_gen)

				src.brightness = brightness
				src.precalc()

				APPLY_AND_UPDATE
				if (RL_Started)
					for (var/turf/T as anything in affected)
						if (T.RL_UpdateGeneration <= strip_gen)
							RL_UPDATE_LIGHT(T)
			else
				src.brightness = brightness
				src.precalc()

		set_color(red, green, blue, queued_run = 0)

			if (src.r == red && src.g == green && src.b == blue && !queued_run)
				return
#ifdef DEBUG_MOVING_LIGHTS_STATS
			if(src.enabled)
				color_changing_lights_stats["[src.attached_to?.type]"]++
				color_changing_lights_stats_by_first_attached["[src.first_attached_to?.type]"]++
#endif

			if (src.enabled)
				if (SHOULD_QUEUE)
					light_update_queue.queue(src)
					dirty_flags |= D_COLOR
					r_des = red
					g_des = green
					b_des = blue
					return

				var/strip_gen = ++RL_Generation
				var/list/affected = src.strip(strip_gen)

				src.r = red
				src.g = green
				src.b = blue
				src.precalc()

				APPLY_AND_UPDATE
				if (RL_Started)
					for (var/turf/T as anything in affected)
						if (T.RL_UpdateGeneration <= strip_gen)
							RL_UPDATE_LIGHT(T)
			else
				src.r = red
				src.g = green
				src.b = blue
				src.precalc()

		set_height(height, queued_run = 0)
			src.height_des = height
			if (src.height == height && !queued_run)
				return

			if (src.enabled)
				if (SHOULD_QUEUE)
					light_update_queue.queue(src)
					dirty_flags |= D_HEIGHT
					return

				var/strip_gen = ++RL_Generation
				var/list/affected = src.strip(strip_gen)

				src.height = height
				src.precalc()

				APPLY_AND_UPDATE
				if (RL_Started)
					for (var/turf/T as anything in affected)
						if (T.RL_UpdateGeneration <= strip_gen)
							RL_UPDATE_LIGHT(T)
			else
				src.height = height
				src.precalc()

		enable(queued_run = 0)
			if (enabled)
				dirty_flags &= ~D_ENABLE
				return

			if (SHOULD_QUEUE)
				light_update_queue.queue(src)
				dirty_flags |= D_ENABLE
				return

			enabled = 1

			APPLY_AND_UPDATE

		disable(queued_run = 0)
			if (!enabled)
				dirty_flags &= ~D_ENABLE
				return

			if (SHOULD_QUEUE)
				light_update_queue.queue(src)
				dirty_flags |= D_ENABLE
				return

			enabled = 0

			if (RL_Started)
				for (var/turf/T as anything in src.strip(++RL_Generation))
					RL_UPDATE_LIGHT(T)

		detach()
			if (src.attached_to)
				src.attached_to.RL_Attached -= src
				src.attached_to = null

		attach(atom/A, offset_x=0.5, offset_y=0.5)
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
		precalc()
			src.premul_r = src.r * src.brightness
			src.premul_g = src.g * src.brightness
			src.premul_b = src.b * src.brightness
			src.radius = min(round(sqrt(max((brightness * (RL_Atten_Quadratic - RL_Rad_QuadConstant)) / (-RL_Atten_Constant + RL_Rad_ConstConstant) - src.height**2, 0))), RL_MaxRadius)

		apply()
			if (!RL_Started)
				return list()
#ifdef DEBUG_LIGHT_STRIP_APPLY
			src.apply_level++
			if(src.apply_level != 1)
				//CRASH("Light [src]'s apply level at [src.x], [src.y], [src.z] is [src.apply_level]")
				logTheThing(LOG_DEBUG, src, "<b>Light:</b> [src] (at [src.x] [src.y] [src.z]) is at apply level [src.apply_level] after an apply.")
#endif
			return apply_internal(++RL_Generation, src.premul_r, src.premul_g, src.premul_b)

		strip(generation)
			if (!RL_Started)
				return list()
#ifdef DEBUG_LIGHT_STRIP_APPLY
			src.apply_level--
			if(src.apply_level != 0)
				//CRASH("Light [src]'s apply level at [src.x], [src.y], [src.z] is [src.apply_level]")
				logTheThing(LOG_DEBUG, src, "<b>Light:</b> [src] (at [src.x] [src.y] [src.z]) is at apply level [src.apply_level] after a strip.")
#endif
			return apply_internal(generation, -src.premul_r, -src.premul_g, -src.premul_b)

		remove_from_turf()
			var/turf/T = locate(src.x, src.y, src.z)
			if (T)
				if (T.RL_Lights && length(T.RL_Lights)) //ZeWaka: Fix for length(null)
					T.RL_Lights -= src
					if (!T.RL_Lights.len)
						T.RL_Lights = null
				else
					T.RL_Lights = null

		move(x, y, z, dir,queued_run = 0)
#ifdef DEBUG_MOVING_LIGHTS_STATS
			if(src.enabled)
				moving_lights_stats["[src.attached_to?.type]"]++
				moving_lights_stats_by_first_attached["[src.first_attached_to?.type]"]++
#endif

			src.x_des = x
			src.y_des = y
			src.z_des = z

			src.dir_des = dir

			if (SHOULD_QUEUE)
				light_update_queue.queue(src)
				dirty_flags |= D_MOVE
				return

			remove_from_turf()

			var/strip_gen = ++RL_Generation
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

			if (src.enabled && RL_Started)
				APPLY_AND_UPDATE
				for (var/turf/T as anything in affected)
					if (T.RL_UpdateGeneration <= strip_gen)
						RL_UPDATE_LIGHT(T)

		move_defer(x, y, z) //not called anywhere! if we decide to use this later add it to queueing ok thx
			. = src.strip(++RL_Generation)
			src.x = x
			src.y = y
			src.z = z

			. |= src.apply()

		apply_to(turf/T)
			CRASH("Default apply_to called, did you mean to create a /datum/light/point and not a /datum/light?")

		apply_internal(generation, r, g, b) // per light type
			CRASH("Default apply_internal called, did you mean to create a /datum/light/point and not a /datum/light?")

	point
		apply_to(turf/T)
			RL_APPLY_LIGHT(T, src.x, src.y, src.brightness, src.height**2, r, g, b)

		#define ADDUPDATE(var) if (var.RL_UpdateGeneration < generation) { var.RL_UpdateGeneration = generation; . += var; }
		apply_internal(generation, r, g, b)
			. = list()
			var/height2 = src.height**2
			var/turf/middle = locate(src.x, src.y, src.z)
			var/atten
			for (var/turf/T in view(src.radius, middle))
				if (T.opacity)
					continue
				if(T.opaque_atom_count > 0)
					continue

				RL_APPLY_LIGHT_EXPOSED_ATTEN(T, src.x, src.y, src.brightness, height2, r, g, b)
				if(atten < RL_Atten_Threshold)
					continue
				T.RL_ApplyGeneration = generation
				T.RL_UpdateGeneration = generation
				. += T

			for (var/turf/T as anything in .)
				var/E_new = 0
				var/turf/E = get_step(T, EAST)
				if (E && E.RL_ApplyGeneration < generation)
					E_new = 1
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

				if(get_step(T, WEST))
					ADDUPDATE(get_step(T, WEST))
				if(get_step(T, SOUTH))
					ADDUPDATE(get_step(T, SOUTH))
				if(get_step(T, SOUTHWEST))
					ADDUPDATE(get_step(T, SOUTHWEST))

	line
		var/dist_cast = 0
		precalc()
			src.premul_r = src.r * src.brightness
			src.premul_g = src.g * src.brightness
			src.premul_b = src.b * src.brightness
			src.radius = min(round(sqrt(max((brightness * (RL_Atten_Quadratic)) / -RL_Atten_Constant - src.height**2, 0))), RL_MaxRadius) * 0.6


		apply_to(turf/T)
			RL_APPLY_LIGHT_LINE(T, src.x, src.y, src.dir, dist_cast, src.brightness, src.height**2, r, g, b)

		apply_internal(generation, r, g, b)
			. = list()
			var/height2 = src.height**2

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
			var/list/turfline = getstraightlinewalled(middle,vx,vy)
			if (!turfline)
				return
			dist_cast = max(turfline.len,1)

			for (var/turf/T in turfline)
				RL_APPLY_LIGHT_LINE(T, src.x, src.y, src.dir, dist_cast, src.brightness, height2, r, g, b)
				T.RL_ApplyGeneration = generation
				T.RL_UpdateGeneration = generation
				. += T

			for (var/turf/T as anything in .)

				var/turf/E = get_step(T, EAST)
				if (E && E.RL_ApplyGeneration < generation)
					E.RL_ApplyGeneration = generation
					RL_APPLY_LIGHT_LINE(E, src.x, src.y, src.dir, dist_cast, src.brightness, height2, r, g, b)
					ADDUPDATE(E)
					if(get_step(T, SOUTHEAST))
						ADDUPDATE(get_step(T, SOUTHEAST))

				var/turf/N = get_step(T, NORTH)
				if (N && N.RL_ApplyGeneration < generation)
					N.RL_ApplyGeneration = generation
					RL_APPLY_LIGHT_LINE(N, src.x, src.y, src.dir, dist_cast, src.brightness, height2, r, g, b)
					ADDUPDATE(N)
					if(get_step(T, NORTHWEST))
						ADDUPDATE(get_step(T, NORTHWEST))

				var/turf/NE = get_step(T, NORTHEAST)
				if (NE && NE.RL_ApplyGeneration < generation)
					RL_APPLY_LIGHT_LINE(NE, src.x, src.y, src.dir, dist_cast, src.brightness, height2, r, g, b)
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
var
	RL_Started = 0
	RL_Suspended = 0

proc
	RL_Start()
		RL_Started = 1
		/*
		for (var/turf/T in world)
			LAGCHECK(LAG_HIGH)
			T.RL_Init()
		*/
		for (var/datum/light/light)
			if (light.enabled)
				light.apply()
		for (var/turf/T in world)
			LAGCHECK(LAG_HIGH)
			RL_UPDATE_LIGHT(T)

	RL_Suspend()
		RL_Suspended = 1
#ifdef DEBUG_LIGHT_STRIP_APPLY
		logTheThing(LOG_DEBUG, src, "<b>Light:</b> Suspended lighting.")
#endif
		//TODO

	RL_Resume()
		RL_Suspended = 0
#ifdef DEBUG_LIGHT_STRIP_APPLY
		logTheThing(LOG_DEBUG, src, "<b>Light:</b> Unsuspended lighting.")
#endif
		// TODO
		//I'm going to keep to my later statement for this and above: "for fucks sake tobba" -ZeWaka

/obj/overlay/tile_effect
	event_handler_flags = IMMUNE_SINGULARITY
	appearance_flags = TILE_BOUND | PIXEL_SCALE

/obj/overlay/tile_effect/lighting
	icon = 'icons/effects/light_overlay.dmi'
	appearance_flags = TILE_BOUND | PIXEL_SCALE | RESET_ALPHA | RESET_COLOR
	blend_mode = BLEND_ADD
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_BASE
	anchored = 2

/obj/overlay/tile_effect/lighting/mul
	plane = PLANE_LIGHTING
	blend_mode = BLEND_DEFAULT // this maybe (???) fixes a bug where lighting doesn't render on clients when teleporting
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


turf
	var
		RL_ApplyGeneration = 0
		RL_UpdateGeneration = 0
		obj/overlay/tile_effect/lighting/mul/RL_MulOverlay = null
		obj/overlay/tile_effect/lighting/add/RL_AddOverlay = null
		RL_LumR = 0
		RL_LumG = 0
		RL_LumB = 0
		RL_AddLumR = 0
		RL_AddLumG = 0
		RL_AddLumB = 0
		RL_NeedsAdditive = 0
		RL_OverlayState = ""
		list/datum/light/RL_Lights = null
		opaque_atom_count = 0
#ifdef DEBUG_LIGHTING_UPDATES
		var/obj/maptext_junk/RL_counter/counter = null
#endif

	proc
		RL_ApplyLight(lx, ly, brightness, height2, r, g, b) // use the RL_APPLY_LIGHT macro instead if at all possible!!!!
#ifdef DEBUG_LIGHTING_UPDATES
			if (!src.counter)
				counter = new(src)
			counter.tick(apply = 1, generation = RL_Generation)
#endif
			var/area/A = loc
			if (A.force_fullbright)
				return

			//MBC : this needed to be removed to fix construction. might be a bit slower but idk how else it would be fixed
			//basically , even though fullbright turfs like space do not have light overlays...
			//we still want them to keep track of how they would be affected by nearby lights, in case someone does build over them.
			//if (fullbright)
			//	return

			var/atten = (brightness*RL_Atten_Quadratic) / ((src.x - lx)**2 + (src.y - ly)**2 + height2) + RL_Atten_Constant
			if (atten < RL_Atten_Threshold)
				return
			RL_LumR += r*atten
			RL_LumG += g*atten
			RL_LumB += b*atten

			//Needed these to prevent a weird bug from the dark times where tiles went pitch black and couldn't be fixed - ZeWaka
			//I really want negative lights to be a thing so I'll just hope that this bandaid is no longer necessary. Feel free to uncomment if I'm wrong - pali
			//I was wrong - pali
			/*
			RL_LumR = max(RL_LumR, 0)
			RL_LumG = max(RL_LumG, 0)
			RL_LumB = max(RL_LumB, 0)
			*/

			RL_AddLumR = clamp((RL_LumR - 1) * 0.5, 0, 0.3)
			RL_AddLumG = clamp((RL_LumG - 1) * 0.5, 0, 0.3)
			RL_AddLumB = clamp((RL_LumB - 1) * 0.5, 0, 0.3)
			RL_NeedsAdditive = (RL_AddLumR > 0) || (RL_AddLumG > 0) || (RL_AddLumB > 0)

		RL_UpdateLight() // use the RL_UPDATE_LIGHT macro instead if at all possible!!!!
			if (!RL_Started)
				return
#ifdef DEBUG_LIGHTING_UPDATES
			if (!src.counter)
				counter = new(src)
			counter.tick(update = 1, generation = RL_Generation)
#endif
			RL_UPDATE_LIGHT(src)

		RL_SetSprite(state)
			if (src.RL_MulOverlay)
				src.RL_MulOverlay.icon_state = state
			if (src.RL_AddOverlay)
				src.RL_AddOverlay.icon_state = state
			src.RL_OverlayState = state

		// Approximate RGB -> Luma conversion formula.
		RL_GetBrightness()
			var/BN = max(0, ((src.RL_LumR * 0.33) + (src.RL_LumG * 0.5) + (src.RL_LumB * 0.16)))
			return BN

		RL_Cleanup()
			/*
			if (src.RL_MulOverlay)
				src.RL_MulOverlay.set_loc(null)
				qdel(src.RL_MulOverlay)
				src.RL_MulOverlay = null
			if (src.RL_AddOverlay)
				src.RL_AddOverlay.set_loc(null)
				qdel(src.RL_AddOverlay)
				src.RL_AddOverlay = null
			// cirr effort to remove redundant overlays that still persist EVEN THOUGH they shouldn't
			for(var/obj/overlay/tile_effect/lighting/L in src.contents)
				L.set_loc(null)
				qdel(L)
			*/

		RL_Reset()
			// TODO
			//for fucks sake tobba - ZeWaka

		RL_Init()
			if (!fullbright && !loc:force_fullbright)
				if(!src.RL_MulOverlay)
					src.RL_MulOverlay = new /obj/overlay/tile_effect/lighting/mul
					src.RL_MulOverlay.set_loc(src)
					src.RL_MulOverlay.icon_state = src.RL_OverlayState
				if (RL_Started) RL_UPDATE_LIGHT(src)
			else
				if(src.RL_MulOverlay)
					qdel(src.RL_MulOverlay)
					src.RL_MulOverlay = null
				if(src.RL_AddOverlay)
					qdel(src.RL_AddOverlay)
					src.RL_AddOverlay = null

atom
	var
		RL_Attached = null

		old_dir = null //rl only right now
		next_light_dir_update = 0

	movable
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
				for (var/turf/T in view(RL_MaxRadius, src))
					if (T.RL_Lights)
						lights |= T.RL_Lights

				var/list/affected = list()
				for (var/datum/light/light as anything in lights)
					if (light.enabled)
						affected |= light.strip(++RL_Generation)

				var/turf/OL = src.loc
				if(istype(OL)) --OL.opaque_atom_count
				var/turf/NL = target
				if(istype(NL)) ++NL.opaque_atom_count

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
		..()
		if (src.RL_Attached)
			for (var/datum/light/attached as anything in src.RL_Attached)
				attached.disable(queued_run = 1)
				// Detach the light from its holder so that it gets cleaned up right if
				// needed.
				attached.detach()
			src.RL_Attached:len = 0
			src.RL_Attached = null
		if (opacity)
			RL_SetOpacity(0)

	proc
		RL_SetOpacity(new_opacity)
			if(src.disposed) return
			if (src.opacity == new_opacity)
				return
			if(!RL_Started)
				src.set_opacity(new_opacity)
				return

			var/list/datum/light/lights = list()
			for (var/turf/T in view(RL_MaxRadius, src))
				if (T.RL_Lights)
					lights |= T.RL_Lights

			var/list/affected = list()
			for (var/datum/light/light as anything in lights)
				if (light.enabled)
					affected |= light.strip(++RL_Generation)

			var/turf/L = get_turf(src)
			if(src.loc == L && L) L.opaque_atom_count += new_opacity ? 1 : -1

			src.set_opacity(new_opacity)
			for (var/datum/light/light as anything in lights)
				if (light.enabled)
					affected |= light.apply()
			if (RL_Started)
				for (var/turf/T as anything in affected)
					RL_UPDATE_LIGHT(T)
