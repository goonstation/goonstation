atom
	var
		list/simple_light_rgbas = null

		mutable_appearance/simple_light = null

	proc/add_simple_light(var/id, var/list/rgba)
		if (!simple_light_rgbas)
			simple_light_rgbas = list()

		simple_light_rgbas[id] = rgba

		show_simple_light()

		if (simple_light_rgbas.len == 1) //dont loop/average if list only contains 1 thing
			simple_light.color = rgb(rgba[1], rgba[2], rgba[3], rgba[4])
		else
			update_simple_light_color()


	proc/remove_simple_light(var/id)
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

	proc/update_simple_light_color()
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

	proc/show_simple_light()
		if (!simple_light)
			simple_light = image('icons/effects/overlays/simplelight.dmi', src, "3x3")
			simple_light.loc = src

			simple_light.icon_state = "3x3"
			simple_light.plane = PLANE_LIGHTING
			simple_light.blend_mode = BLEND_ADD
			simple_light.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | TILE_BOUND | NO_CLIENT_COLOR | KEEP_APART
			simple_light.pixel_x = -32
			simple_light.pixel_y = -32
			simple_light.layer = LIGHTING_LAYER_BASE
			simple_light.mouse_opacity = 0

		addGlobalImage(simple_light, "simplelight_\ref[src]")
		if(istype(src, /mob))
			var/mob/M = src
			if(M.client)
				M.client << simple_light

	proc/hide_simple_light()
		if (simple_light)
			removeGlobalImage("simplelight_\ref[src]")

	proc/destroy_simple_light()
		if (simple_light_rgbas && simple_light_rgbas.len)
			hide_simple_light()
		simple_light.loc = null
		simple_light_rgbas = null
		qdel(simple_light)
		simple_light = null

	disposing()
		..()
		if (simple_light)
			destroy_simple_light()
