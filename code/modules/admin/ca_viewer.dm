/client/proc/cmd_caviewer()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "CA Viewer"
	set desc = "Cellular Automata Viewer"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(holder)
		var/datum/ca_viewer/E = new /datum/ca_viewer(src.mob)
		E.ui_interact(mob)

ABSTRACT_TYPE(/datum/ca_type)
/datum/ca_type
	var/name = "Unknown"
	var/description = "Description Goes Here?"
	var/function = "foo()"
	var/options = list()
	var/defaults = list()
	var/big_text = FALSE

	proc/generate(params)
		for(var/option in src.options)
			if(!params[option])
				return FALSE
		return TRUE

	proc/get_width(params)
		return 0

	cnoise
		name = "Noise"
		function = "rustg_cnoise_generate"
		description = "Cellular Automata Noise Grid"
		options = list("percentage", "iterations", "birth limit", "dead limit", "size_x", "size_y")
		defaults = list("percentage"=50, "iterations"=5, "birth limit"=6, "dead limit"=3, "size_x"=300, "size_y"=300)

		generate(params)
			. = ..()
			if(.)
				return rustg_cnoise_generate("[params["percentage"]]", "[params["iterations"]]", "[params["birth limit"]]", "[params["dead limit"]]", "[params["size_x"]]", "[params["size_y"]]")

		get_width(params)
			return params["size_x"]

	perlin_grid
		name = "Perlin Noise Grid"
		description = "Perlin Noise Grid"
		function = "rustg_dbp_generate"
		options = list("seed", "accuracy", "stamp_size", "world_size", "lower_range", "upper_range")
		defaults = list("seed"=42069, "accuracy"=4, "stamp_size"=16, "world_size"=300, "lower_range"=0.1, "upper_range"=0.8)

		generate(params)
			. = ..()
			if(.)
				return rustg_dbp_generate("[params["seed"]]", "[params["accuracy"]]", "[params["stamp_size"]]", "[params["world_size"]]", "[params["lower_range"]]", "[params["upper_range"]]")

		get_width(params)
			return params["world_size"]
	worley
		name = "Worley Noise"
		description = "Worley Noise"
		function = "rustg_worley_generate"
		options = list("region_size", "threshold", "node_per_region_chance", "maxx", "node_min", "node_max")
		defaults = list("region_size"=32, "threshold"=10, "node_per_region_chance"=50, "maxx"=300, "node_min"=1, "node_max"=8)

		generate(params)
			. = ..()
			if(.)
				return rustg_worley_generate("[params["region_size"]]", "[params["threshold"]]", "[params["node_per_region_chance"]]", "[params["maxx"]]", "[params["node_min"]]", "[params["node_max"]]")

		get_width(params)
			return params["maxx"]

	bst_viewer
		name = "Binary Spatial Partioning"
		description = "Not A CA BSP"
		options = list("x", "y", "width", "height", "min_width", "min_height" )
		defaults = list("x"=1, "y"=1, "width"=300, "height"=300, "min_width"=10, "min_height"=10 )
		big_text = TRUE

		function = "var/datum/bsp_tree/tree = new"

		generate(params)
			. = ..()
			if(.)
				var/datum/bsp_tree/our_tree = new(x=params["x"],y=params["y"], width=params["width"], height=params["height"],min_width=params["min_width"],min_height=params["min_height"])
				. = our_tree.tree_to_string()

		get_width(params)
			return params["width"]

	bst_viewer/maze
		name = "BSP Maze"
		description = "Not A CA BSP"

		function = "var/datum/bsp_tree/maze/tree = new"

		generate(params)
			. = ..()
			if(.)
				var/datum/bsp_tree/maze/our_tree = new(x=params["x"],y=params["y"], width=params["width"], height=params["height"],min_width=params["min_width"],min_height=params["min_height"])
				. = our_tree.tree_to_string()

/datum/ca_viewer
	var/datum/ca_type/active_ca_type
	var/settings
	var/big_text
	var/ca_cache
	var/width = 300
	var/ca_types = list()

/datum/ca_viewer/New()
	..()
	if(!length(ca_types))
		var/list/L = concrete_typesof(/datum/ca_type)
		for(var/T in L)
			LAZYLISTADD(ca_types, new T())
	src.active_ca_type = src.ca_types[1]
	src.settings = src.active_ca_type.defaults
	src.ca_cache = active_ca_type.generate(src.settings)


/datum/ca_viewer/proc/get_defaults(type)
	var/list/default = list("")
	. = default[type]

/datum/ca_viewer/ui_state(mob/user)
	return tgui_admin_state

/datum/ca_viewer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CAViewer")
		ui.open()

/datum/ca_viewer/ui_static_data(mob/user)
	. = list()
	.["CAType"] = src.active_ca_type.name
	.["CAData"] = src.ca_cache
	.["typeData"] = list()
	.["settings"] = src.settings
	.["bigText"] = src.active_ca_type.big_text
	.["viewWidth"] = src.active_ca_type.get_width(src.settings)
	for(var/datum/ca_type/T as anything in ca_types)
		.["typeData"][T.name] += list(
			"name" = T.name,
			"function" = T.function,
			"description" = T.description,
			"options"=T.options)

/datum/ca_viewer/ui_data()
	. = list()
	.["bigText"] = src.active_ca_type.big_text
	.["viewWidth"] = src.active_ca_type.get_width(src.settings)

/datum/ca_viewer/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("generate")
			src.ca_cache = active_ca_type.generate(src.settings)
			var/tgui_data = list()
			tgui_data["CAData"] = src.ca_cache
			tgui_data["viewWidth"] = src.active_ca_type.get_width(src.settings)
			tgui_data["bigText"] = src.active_ca_type.big_text
			ui.send_update(tgui_data)
			. = TRUE

		if("set_ca")
			for(var/datum/ca_type/T as anything in ca_types)
				if(T.name == params["type"])
					src.active_ca_type = T
					src.settings = src.active_ca_type.defaults
					src.ca_cache = active_ca_type.generate(src.settings)
					update_static_data(usr, ui)


		if("settings")
			if(params["name"] && params["data"])
				settings[params["name"]] = params["data"]

			var/tgui_data = list()
			tgui_data["settings"] = src.settings
			ui.send_update(tgui_data)
			. = TRUE
