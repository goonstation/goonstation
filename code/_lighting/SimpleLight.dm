/atom/var/ignore_simple_light_updates = 0 //to avoid double-updating on diagonal steps when we are really only taking a single step

/atom/movable/light/simple_light
	icon = 'icons/effects/overlays/simplelight.dmi'
	icon_state = "3x3"
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART // PIXELSCALE omitted on purpose
	pixel_x = -32
	pixel_y = -32
	text = ""

/atom/var/list/simple_light_rgbas = null
/atom/var/atom/movable/light/simple_light/simple_light = null

/atom/proc/add_simple_light(var/id, var/list/rgba)
	if (!simple_light_rgbas)
		simple_light_rgbas = list()

	simple_light_rgbas[id] = rgba

	show_simple_light()

	if (length(simple_light_rgbas) == 1) //dont loop/average if list only contains 1 thing
		simple_light.color = rgb(rgba[1], rgba[2], rgba[3], rgba[4])
	else
		update_simple_light_color()


/atom/proc/remove_simple_light(var/id)
	if (!simple_light_rgbas)
		return

	if (id)
		if (id in simple_light_rgbas)
			//simple_light_rgbas -= simple_light_rgbas[id]
			simple_light_rgbas.Remove(id)
	else
		simple_light_rgbas.len = 0

	if (length(simple_light_rgbas) <= 0)
		hide_simple_light()
	else
		update_simple_light_color()

/atom/proc/update_simple_light_color()
	var/avg_r = 0
	var/avg_g = 0
	var/avg_b = 0
	var/sum_a = 0

	for (var/id in simple_light_rgbas)
		avg_r += simple_light_rgbas[id][1]
		avg_g += simple_light_rgbas[id][2]
		avg_b += simple_light_rgbas[id][3]
		sum_a += simple_light_rgbas[id][4]

	avg_r /= length(simple_light_rgbas)
	avg_g /= length(simple_light_rgbas)
	avg_b /= length(simple_light_rgbas)
	sum_a = min(255,sum_a)

	simple_light.color = rgb(avg_r, avg_g, avg_b, sum_a)

/atom/proc/show_simple_light()
	if(!length(simple_light_rgbas))
		return
	if (!simple_light)
		simple_light = new()
		// guess what, vis_contents is defined for /turf + /atom/movable
		// I can either duplicate all this code, or add type checks with runtime overhead
		// or use :
		// if anyone tries to add a simple light to an area it will crash but WHY WOULD YOU EVER DO THAT
		src:vis_contents += simple_light
	src.simple_light.invisibility = INVIS_NONE

/atom/proc/hide_simple_light()
	if (src.simple_light)
		src.simple_light.invisibility = INVIS_ALWAYS

/atom/proc/destroy_simple_light()
	if (length(simple_light_rgbas))
		hide_simple_light()
	src:vis_contents -= simple_light
	simple_light_rgbas = null
	qdel(simple_light)
	simple_light = null

/atom/disposing()
	..()
	if (simple_light)
		destroy_simple_light()


/obj/overlay/simple_light/medium
	icon_state = "medium_dir"
	New(loc, dir=0)
		..()
		src.dir = dir //nothing will care about whether or not light rotates, so why spend precious time calling set_dir()?
		switch(dir)
			if(NORTH)
				pixel_y += 32
			if(SOUTH)
				pixel_y -= 32
			if(EAST)
				pixel_x += 32
			if(WEST)
				pixel_x -= 32
			if(0)
				icon_state = "medium_center"

/atom/var/list/medium_light_rgbas = null
/atom/var/list/obj/overlay/simple_light/medium/medium_lights
/atom/var/static/list/medium_light_dirs = list(0, NORTH, SOUTH, EAST, WEST)

// for medium lights the light intensity keeps increasing as you increase alpha past 255
// the upper limit is 510 but some stuff will look a bit weird
/atom/proc/add_medium_light(var/id, var/list/rgba)
	if (!medium_light_rgbas)
		medium_light_rgbas = list()

	medium_light_rgbas[id] = rgba

	show_medium_light()

	if (length(medium_light_rgbas) == 1) //dont loop/average if list only contains 1 thing
		var/alpha = rgba[4]
		var/alpha_scaled = min(255, alpha / 2) // divided by two because the directional sprites are brighter
		for(var/atom/movable/light/simple_light/medium/medium_light as anything in src.medium_lights)
			if(medium_light.icon_state == "medium_center")
				rgba[4] = min(255, alpha)
			else
				rgba[4] = alpha_scaled
			medium_light.color = rgba
	else
		update_medium_light_color()


/atom/proc/remove_medium_light(var/id)
	if (!medium_light_rgbas)
		return

	if (id)
		if (id in medium_light_rgbas)
			//medium_light_rgbas -= medium_light_rgbas[id]
			medium_light_rgbas.Remove(id)
	else
		medium_light_rgbas.len = 0

	if (length(medium_light_rgbas))
		update_medium_light_color()
	else
		hide_medium_light()

/atom/proc/update_medium_light_color()
	var/avg_r = 0
	var/avg_g = 0
	var/avg_b = 0
	var/sum_a = 0

	for (var/id in medium_light_rgbas)
		avg_r += medium_light_rgbas[id][1]
		avg_g += medium_light_rgbas[id][2]
		avg_b += medium_light_rgbas[id][3]
		sum_a += medium_light_rgbas[id][4]

	avg_r /= length(medium_light_rgbas)
	avg_g /= length(medium_light_rgbas)
	avg_b /= length(medium_light_rgbas)
	var/list/unscaled = list(avg_r, avg_g, avg_b, min(255, sum_a))
	var/list/scaled = list(avg_r, avg_g, avg_b, min(255, sum_a / 2)) // divided by two because the directional sprites are brighter
	for(var/obj/overlay/simple_light/medium/medium_light in src.medium_lights)
		if(medium_light.icon_state == "medium_center")
			medium_light.color = unscaled
		else
			medium_light.color = scaled

/atom/proc/show_medium_light()
	if(!length(medium_light_rgbas))
		return
	if (!medium_lights)
		medium_lights = list()
		for(var/light_dir in src.medium_light_dirs)
			var/obj/overlay/simple_light/medium/light = new(null, light_dir)
			src:vis_contents += light
			src.medium_lights += light
	for(var/obj/overlay/simple_light/medium/light as anything in src.medium_lights)
		light.invisibility = INVIS_NONE
	update_medium_light_visibility()

/atom/proc/hide_medium_light()
	for(var/obj/overlay/simple_light/medium/light as anything in src.medium_lights)
		light.invisibility = INVIS_ALWAYS

/atom/proc/destroy_medium_light()
	for(var/obj/overlay/simple_light/medium/light as anything in src.medium_lights)
		src:vis_contents -= light
		qdel(light)
	medium_light_rgbas = null
	src.medium_lights.len = 0

/atom/disposing()
	..()
	if (src.medium_lights)
		destroy_medium_light()

/atom/proc/update_medium_light_visibility()
	if(src.medium_lights[1].invisibility == INVIS_ALWAYS) // toggled off
		return
	if(!isturf(src.loc) && !isturf(src))
		for (var/obj/overlay/simple_light/medium/light as anything in src.medium_lights)
			src:vis_contents -= light
		return
	for (var/obj/overlay/simple_light/medium/light as anything in src.medium_lights)
		if(light.icon_state == "medium_center")
			src:vis_contents += light
			continue
		var/turf/T = get_step(get_turf(src), light.dir)
		if(T?.opacity || T?.opaque_atom_count)
			src:vis_contents -= light
		else
			src:vis_contents += light





/obj/overlay/simple_light/medium/directional
	icon_state = "medium_dir"
	var/dist = 0


/atom/var/list/mdir_light_rgbas = null
/atom/var/list/obj/overlay/simple_light/medium/directional/mdir_lights
/atom/var/static/list/mdir_light_dists = list(0, 2.5, 5)

// for medium lights the light intensity keeps increasing as you increase alpha past 255
// the upper limit is 510 but some stuff will look a bit weird
/atom/proc/add_mdir_light(var/id, var/list/rgba)
	if (!mdir_light_rgbas)
		mdir_light_rgbas = list()

	mdir_light_rgbas[id] = rgba

	show_mdir_light()

	if (length(mdir_light_rgbas) == 1) //dont loop/average if list only contains 1 thing
		for(var/obj/overlay/simple_light/medium/directional/mdir_light in src.mdir_lights)
			if(mdir_light.dist == mdir_light_dists[mdir_light_dists.len])
				mdir_light.color = rgb(rgba[1], rgba[2], rgba[3], min(255, rgba[4]))
			else
				// divided by two because the directional sprites are brighter
				mdir_light.color = rgb(rgba[1], rgba[2], rgba[3], min(255, rgba[4] * 0.4))
	else
		update_mdir_light_color()


/atom/proc/remove_mdir_light(var/id)
	if (!mdir_light_rgbas)
		return

	if (id)
		if (id in mdir_light_rgbas)
			//medium_light_rgbas -= medium_light_rgbas[id]
			mdir_light_rgbas.Remove(id)
	else
		mdir_light_rgbas.len = 0

	if (length(mdir_light_rgbas) <= 0)
		hide_mdir_light()
	else
		update_mdir_light_color()

/atom/proc/update_mdir_light_color()
	var/avg_r = 0
	var/avg_g = 0
	var/avg_b = 0
	var/sum_a = 0

	for (var/id in mdir_light_rgbas)
		avg_r += mdir_light_rgbas[id][1]
		avg_g += mdir_light_rgbas[id][2]
		avg_b += mdir_light_rgbas[id][3]
		sum_a += mdir_light_rgbas[id][4]

	avg_r /= length(mdir_light_rgbas)
	avg_g /= length(mdir_light_rgbas)
	avg_b /= length(mdir_light_rgbas)

	for(var/obj/overlay/simple_light/medium/directional/mdir_light in src.mdir_lights)
		if(mdir_light.dist == mdir_light_dists[mdir_light_dists.len])
			mdir_light.color = rgb(avg_r, avg_g, avg_b, min(255, sum_a))
		else
			// divided by two because the directional sprites are brighter
			mdir_light.color = rgb(avg_r, avg_g, avg_b, min(255, sum_a  * 0.4))

/atom/proc/show_mdir_light()
	if(!length(mdir_light_rgbas))
		return
	if (!mdir_lights)
		mdir_lights = list()
		for(var/light_dist in src.mdir_light_dists)
			var/obj/overlay/simple_light/medium/directional/light = new(null, null)
			light.dist = light_dist
			src:vis_contents += light
			src.mdir_lights += light
	for(var/obj/overlay/simple_light/medium/directional/light in src.mdir_lights)
		light.invisibility = INVIS_NONE
	update_mdir_light_visibility(src.dir)

/atom/proc/hide_mdir_light()
	for(var/obj/overlay/simple_light/medium/directional/light in src.mdir_lights)
		light.invisibility = INVIS_ALWAYS

/atom/proc/destroy_mdir_light()
	if (length(mdir_light_rgbas))
		hide_mdir_light()
	for(var/obj/overlay/simple_light/medium/directional/light in src.mdir_lights)
		src:vis_contents -= light
		qdel(light)
	mdir_light_rgbas = null
	src.mdir_lights = null

/atom/disposing()
	..()
	if (src.mdir_lights)
		destroy_mdir_light()

/atom/proc/update_mdir_light_visibility(direct)
	if(!length(src.mdir_lights) || src.mdir_lights[1].invisibility == 101) // toggled off
		return
	if(!isturf(src.loc))
		for (var/obj/overlay/simple_light/medium/directional/light as anything in src.mdir_lights)
			src:vis_contents -= light
		return
	if (!direct)
		return

	//optimize
	var/vx = 0
	var/vy = 0
	switch(direct)
		if (NORTH)
			vx = 0
			vy = 1
		if (NORTHEAST)
			vx = 0.7071
			vy = 0.7071
		if (EAST)
			vx = 1
			vy = 0
		if (SOUTHEAST)
			vx = 0.7071
			vy = -0.7071
		if (SOUTH)
			vx = 0
			vy = -1
		if (SOUTHWEST)
			vx = -0.7071
			vy = -0.7071
		if (WEST)
			vx = -1
			vy = 0
		if (NORTHWEST)
			vx = -0.7071
			vy = 0.7071

	var/turf/T = get_steps(src, direct, 5)
	if (!src || !T)
		return
	var/turf/TT = getlineopaqueblocked(src,T)
	var/dist = GET_DIST(src,TT)-1

	for (var/obj/overlay/simple_light/medium/directional/light as anything in src.mdir_lights)
		if(light.icon_state == "medium_center" && light.dist == 0)
			src:vis_contents += light
			continue

		////light.pixel_x = (vx * min(dist,light.dist) * 32) - 32
		//light.pixel_y = (vy * min(dist,light.dist) * 32) - 32

		animate(light,pixel_x = ((vx * min(dist,light.dist) * 32) - 32), pixel_y = ((vy * min(dist,light.dist) * 32) - 32), time = 1, easing = EASE_IN)

		src:vis_contents += light


/atom/proc/add_sm_light(id, list/rgba, medium=null, directional=null)
	if(isnull(medium)) // medium = choose automatically whether to use simple or medium
		// this is a completely arbitrary untested placeholder, please replace this with a proper code
		medium = 0
		if(rgba[4] > 140)
			rgba[4] -= 70
			medium = 1
		if(medium == 0)
			src.remove_medium_light(id)
		else
			src.remove_simple_light(id)

	if (directional)
		src.add_mdir_light(id, rgba)
	else if(medium)
		src.add_medium_light(id, rgba)
	else
		src.add_simple_light(id, rgba)

/atom/proc/remove_sm_light(id)
	src.remove_simple_light(id)
	src.remove_medium_light(id)
	src.remove_mdir_light(id)

/atom/proc/toggle_sm_light(turn_on)
	if(turn_on)
		src.show_medium_light()
		src.show_simple_light()
		src.show_mdir_light()
	else
		src.hide_medium_light()
		src.hide_simple_light()
		src.hide_mdir_light()

// update_medium_light_visibility() is called in /atom/Move and /atom/set_loc
// see atom.dm for details

/turf/proc/contains_simple_light()
	for (var/atom/thing as anything in src.contents)
		if (thing.simple_light?.invisibility == INVIS_NONE)
			return TRUE
		for(var/obj/overlay/simple_light/medium/light in thing.medium_lights)
			if (light.invisibility == INVIS_NONE)
				return TRUE

///An approximation of "is there a simple light shining on this turf", it's slow and bad but that's the price we pay for simple lights
/turf/proc/SL_lit()
	//first we check our own turf
	if (src.contains_simple_light())
		return TRUE
	//then neighbouring turfs
	for (var/turf/T in block(locate(src.x + 1, src.y + 1, src.z), locate(src.x - 1, src.y - 1, src.z)))
		if (T.contains_simple_light())
			return TRUE
	//finally we check in compass directions for directional lights shining on us
	for (var/scan_dir in alldirs)
		var/list/turf/turfs = list() //build a list of the three lines of turfs in this direction to check for light sources
		for (var/i in -1 to 1)
			var/turf/start_turf = get_steps(src, turn(scan_dir, 90), i)
			if (start_turf?.opacity)
				continue
			var/turf/target_turf = get_steps(src, scan_dir, 5) //apparently all directional lights are exactly 5 tiles long??
			if(target_turf)
				var/turf/reached_turf = getlineopaqueblocked(src,target_turf)
				turfs += block(start_turf, reached_turf)

		for (var/turf/T in turfs)
			for (var/atom/movable/thing in T.contents) //find something with a directional light
				for (var/obj/overlay/simple_light/medium/directional/light in thing.mdir_lights)
					if (light.invisibility != INVIS_NONE)
						continue
					//this assumes that lights always point in the same direction as their parent object, but lights don't seem to store dir so :iiam:
					var/turf/light_target = locate(T.x + round((light.pixel_x + 32)/32), T.y + round((light.pixel_y + 32)/32), T.z)
					var/dist = GET_DIST(src, light_target)
					if (dist <= 1)
						return TRUE
