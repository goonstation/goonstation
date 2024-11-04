/client/proc/cmd_paraviewer()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Parallax Viewer"
	set desc = "Parallax Viewer"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(holder)
		var/datum/parallax_viewer/E = new /datum/parallax_viewer(src.mob)
		E.ui_interact(mob)

/datum/parallax_viewer

/datum/parallax_viewer/New()
	..()

/datum/parallax_viewer/ui_state(mob/user)
	return tgui_admin_state

/datum/parallax_viewer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ParallaxViewer")
		ui.open()

/datum/parallax_viewer/ui_static_data(mob/user)
	. = list()

/datum/parallax_viewer/ui_data()
	. = list()
	var/key
	var/datum/parallax_render_source_group/p_group
	var/atom/movable/screen/parallax_render_source/p_source

	.["z_level"] = list()
	for(key in z_level_parallax_render_source_groups)
		p_group = z_level_parallax_render_source_groups[key]
		.["z_level"][key] = list("sources"=list())
		for (p_source in p_group.parallax_render_sources)
			.["z_level"][key]["sources"]["[p_source.type]"] = list(
				"byondRef"="[ref(p_source)]",
				"icon"=p_source.parallax_icon,
				"icon_state"=p_source.parallax_icon_state,
				"value"=p_source.parallax_value,
				"scroll_speed"=p_source.scroll_speed,
				"scroll_angle"=p_source.scroll_angle,
				"x"=p_source.initial_x_coordinate,
				"y"=p_source.initial_y_coordinate,
				"static_color"=p_source.static_colour,
				"color"=p_source.color
				)

	.["areas"] = list()
	for(key in area_parallax_render_source_groups)
		p_group = area_parallax_render_source_groups[key]
		.["areas"][key] = list("sources"=list())
		for (p_source in p_group.parallax_render_sources)
			.["areas"][key]["sources"]["[p_source.type]"] = list(
				"byondRef"="[ref(p_source)]",
				"icon"=p_source.parallax_icon,
				"icon_state"=p_source.parallax_icon_state,
				"value"=p_source.parallax_value,
				"scroll_speed"=p_source.scroll_speed,
				"scroll_angle"=p_source.scroll_angle,
				"x"=p_source.initial_x_coordinate,
				"y"=p_source.initial_y_coordinate,
				"static_color"=p_source.static_colour,
				"color"=p_source.color
				)

	.["planets"] = list()
	for(key in planet_parallax_render_source_groups)
		p_group = planet_parallax_render_source_groups[key]
		.["areas"][key] = list("sources"=list())
		for (p_source in p_group.parallax_render_sources)
			.["areas"][key]["sources"]["[p_source.type]"] = list(
				"byondRef"="[ref(p_source)]",
				"icon"=p_source.parallax_icon,
				"icon_state"=p_source.parallax_icon_state,
				"value"=p_source.parallax_value,
				"scroll_speed"=p_source.scroll_speed,
				"scroll_angle"=p_source.scroll_angle,
				"x"=p_source.initial_x_coordinate,
				"y"=p_source.initial_y_coordinate,
				"static_color"=p_source.static_colour,
				"color"=p_source.color
				)

	// .["areas"] = list()
	// for(key in area_parallax_render_source_groups)
	// 	p_group = z_level_parallax_render_source_groups[key]
	// 	.["areas"][key] = list("byondRef"="[ref(p_group)]", "sources"=list())
	// 	for (p_source in p_group)

	// .["planets"] = list()
	// for(key in planet_parallax_render_source_groups)
	// 	p_group = z_level_parallax_render_source_groups[key]
	// 	.["planets"][key] = list("byondRef"="[ref(p_group)]", "sources"=list())
	// 	for (p_source in p_group)

/datum/parallax_viewer/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/datum/parallax_render_source_group/source_group
	if( length(params["group"])==1 )
		source_group = get_parallax_render_source_group( text2num_safe(params["group"]) )
	else
		source_group = area_parallax_render_source_groups[ text2path(params["group"]) ]

	var/atom/movable/screen/parallax_render_source/render_source = locate(params["byondRef"])
	var/icon/new_icon

	if(!source_group && !render_source)
		return

	var/source_type
	if(params["source"])
		source_type = text2path(params["source"])

	. = TRUE
	switch(action)
		if("default")
			source_group?.restore_parallax_render_sources_to_default()

		if("add")
			var/type = tgui_input_list(ui.user, "Add Parallax Type to [params["group"]]", "Add Parallax", concrete_typesof(/atom/movable/screen/parallax_render_source/))
			source_group?.add_parallax_render_source(type, 10 SECONDS)

		if("delete")
			source_group?.remove_parallax_render_source(source_type, 10 SECONDS)

		if("modify_icon")
			new_icon = input("Pick icon:", "Icon") as null|icon
			if(new_icon)
				render_source.parallax_icon = new_icon
				if(isnull(render_source.parallax_icon_state))
					render_source.parallax_icon_state = ""
				new_icon = icon(render_source.parallax_icon, render_source.parallax_icon_state)
				if(new_icon)
					render_source.icon_width = new_icon.Width()
					render_source.icon_height = new_icon.Height()
					source_group?.update_parallax_render_source(render_source.type)
				else
					. = FALSE

		if("modify_color")
			var/new_color = input(usr, "Pick new color", "Parallax Colors") as color|null
			if(new_color)
				render_source.color = new_color

		if("modify")
			switch(params["type"])
				if("icon_state")
					render_source.parallax_icon_state = params["value"]
					new_icon = icon(render_source.parallax_icon, render_source.parallax_icon_state)
					if(new_icon)
						render_source.icon_width = new_icon.Width()
						render_source.icon_height = new_icon.Height()
					else
						. = FALSE


				if("value")
					render_source.parallax_value = params["value"]

				if("scroll_speed")
					render_source.scroll_speed = params["value"]

				if("scroll_angle")
					render_source.scroll_angle = params["value"]

				if("initial_x")
					render_source.initial_x_coordinate = params["value"]

				if("initial_y")
					render_source.initial_y_coordinate = params["value"]

				if("static_color")
					render_source.static_colour = params["value"]

				if("color")
					render_source.color = params["value"]

				else
					. = FALSE

			if(.)
				source_group?.update_parallax_render_source(render_source.type)
