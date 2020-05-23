/obj/overlay/simple_light
	event_handler_flags = IMMUNE_SINGULARITY
	anchored = 2
	mouse_opacity = 0
	layer = LIGHTING_LAYER_BASE
	plane = PLANE_LIGHTING
	blend_mode = BLEND_ADD
	icon = 'icons/effects/overlays/simplelight.dmi'
	icon_state = "3x3"
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART
	pixel_x = -32
	pixel_y = -32

/atom/var/list/simple_light_rgbas = null
/atom/var/obj/overlay/simple_light/simple_light = null

/atom/proc/add_simple_light(var/id, var/list/rgba)
	if (!simple_light_rgbas)
		simple_light_rgbas = list()

	simple_light_rgbas[id] = rgba

	show_simple_light()

	if (simple_light_rgbas.len == 1) //dont loop/average if list only contains 1 thing
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

	if (simple_light_rgbas.len <= 0)
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

	avg_r /= simple_light_rgbas.len
	avg_g /= simple_light_rgbas.len
	avg_b /= simple_light_rgbas.len
	sum_a = min(255,sum_a)

	simple_light.color = rgb(avg_r, avg_g, avg_b, sum_a)

/atom/proc/show_simple_light()
	if (!simple_light)
		simple_light = new()
		// guess what, vis_contents is defined for /turf + /atom/movable
		// I can either duplicate all this code, or add type checks with runtime overhead
		// or use :
		// if anyone tries to add a simple light to an area it will crash but WHY WOULD YOU EVER DO THAT
		src:vis_contents += simple_light
	src.simple_light.invisibility = 0

/atom/proc/hide_simple_light()
	src.simple_light.invisibility = 101

/atom/proc/destroy_simple_light()
	if (simple_light_rgbas && simple_light_rgbas.len)
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
		src.dir = dir
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

	if (medium_light_rgbas.len == 1) //dont loop/average if list only contains 1 thing
		for(var/obj/overlay/simple_light/medium/medium_light in src.medium_lights)
			if(medium_light.icon_state == "medium_center")
				medium_light.color = rgb(rgba[1], rgba[2], rgba[3], min(255, rgba[4]))
			else
				// divided by two because the directional sprites are brighter
				medium_light.color = rgb(rgba[1], rgba[2], rgba[3], min(255, rgba[4] / 2))
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

	if (medium_light_rgbas.len <= 0)
		hide_medium_light()
	else
		update_medium_light_color()

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

	avg_r /= medium_light_rgbas.len
	avg_g /= medium_light_rgbas.len
	avg_b /= medium_light_rgbas.len

	for(var/obj/overlay/simple_light/medium/medium_light in src.medium_lights)
		if(medium_light.icon_state == "medium_center")
			medium_light.color = rgb(avg_r, avg_g, avg_b, min(255, sum_a))
		else
			// divided by two because the directional sprites are brighter
			medium_light.color = rgb(avg_r, avg_g, avg_b, min(255, sum_a / 2))

/atom/proc/show_medium_light()
	if (!medium_lights)
		medium_lights = list()
		for(var/light_dir in src.medium_light_dirs)
			var/obj/overlay/simple_light/medium/light = new(null, light_dir)
			src:vis_contents += light
			src.medium_lights += light
	for(var/obj/overlay/simple_light/medium/light in src.medium_lights)
		light.invisibility = 0
	update_medium_light_visibility()

/atom/proc/hide_medium_light()
	for(var/obj/overlay/simple_light/medium/light in src.medium_lights)
		light.invisibility = 101

/atom/proc/destroy_medium_light()
	if (medium_light_rgbas && medium_light_rgbas.len)
		hide_medium_light()
	for(var/obj/overlay/simple_light/medium/light in src.medium_lights)
		src:vis_contents -= light
		qdel(light)
	medium_light_rgbas = null
	src.medium_lights = null

/atom/disposing()
	..()
	if (src.medium_lights)
		destroy_medium_light()

/atom/proc/update_medium_light_visibility()
	if(src.medium_lights[1].invisibility == 101) // toggled off
		return
	if(!istype(src.loc, /turf))
		for(var/obj/overlay/simple_light/medium/light in src.medium_lights)
			light.invisibility = 102
		return
	for(var/obj/overlay/simple_light/medium/light in src.medium_lights)
		if(light.icon_state == "medium_center")
			light.invisibility = 0
			continue
		var/turf/T = get_step(get_turf(src), light.dir)
		if(T.opacity || T.opaque_atom_count)
			light.invisibility = 102
		else
			light.invisibility = 0

/atom/proc/add_sm_light(id, list/rgba, medium=null)
	if(isnull(medium)) // medium = choose automatically whether to use simple or medium
		// this is a completely arbitrary untested placeholder, please replace this with a proper code
		medium = 0
		if(rgba[4] > 140)
			rgba[4] -= 70
			medium = 1
	if(medium)
		src.add_medium_light(id, rgba)
	else
		src.add_simple_light(id, rgba)

/atom/proc/remove_sm_light(id)
	src.remove_simple_light(id)
	src.remove_medium_light(id)

/atom/proc/toggle_sm_light(turn_on)
	if(turn_on)
		src.show_medium_light()
		src.show_simple_light()
	else
		src.hide_medium_light()
		src.hide_simple_light()

// update_medium_light_visibility() is called in /atom/Move and /atom/set_loc
// see atom.dm for details
