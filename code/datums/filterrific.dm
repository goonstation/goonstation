/**
* @file
* @copyright 2020
* @author actioninja  (https://github.com/actioninja )
* @license MIT
*/

#define COLOR_HALF_TRANSPARENT_BLACK    "#0000007A"
#define COLOR_BLACK						"#000"
#define COLOR_WHITE						"#FFF"

/atom
	var/list/list/filter_data

	proc/add_filter(name, priority, list/filter_params)
		LAZYLISTINIT(src.filter_data)
		filter_params["priority"] = priority
		src.filter_data[name] = filter_params
		update_filters()

	proc/transition_filter(name, time, list/new_params, easing, loop)
		var/filter = get_filter(name)
		if(!filter)
			return

		var/list/old_filter_data = filter_data[name]

		var/list/params = old_filter_data.Copy()
		for(var/thing in new_params)
			params[thing] = new_params[thing]

		animate(filter, new_params, time = time, easing = easing, loop = loop)
		for(var/param in params)
			filter_data[name][param] = params[param]

	proc/remove_filter(name_or_names)
		if(!filter_data)
			return

		var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

		for(var/name in names)
			if(filter_data[name])
				filter_data -= name
		update_filters()

	proc/get_filter(name)
		if(filter_data && filter_data[name])
			var/i = filter_data.Find(name)
			. = filters[i]

	proc/update_filters()
		filters = null
		//need to reorder based on priority
		for(var/i = 1; i <= length(filter_data); i++)
			for(var/j = i+1; j <= length(filter_data); j++)
				if(filter_data[filter_data[i]]["priority"] > filter_data[filter_data[j]]["priority"])
					filter_data.Swap(i, j)
		for(var/filter in filter_data)
			var/list/params = filter_data[filter].Copy()
			//Ommit priority as that is just used for ordering filters for desired effect
			params -= "priority"
			filters += filter(arglist(params))
		return

	proc/change_filter_priority(name, new_priority)
		if(!filter_data || !filter_data[name])
			return

		filter_data[name]["priority"] = new_priority
		update_filters()

/datum/filter_editor
	var/atom/target

/datum/filter_editor/New(atom/target)
	. = ..()
	src.target = target

/datum/filter_editor/ui_state(mob/user)
	return tgui_admin_state

/datum/filter_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Filteriffic")
		ui.open()

/datum/filter_editor/ui_static_data(mob/user)
	var/list/data = list()
	data["filter_info"] = master_filter_info
	return data

/datum/filter_editor/ui_data()
	var/list/data = list()
	data["target_name"] = target.name
	data["target_filter_data"] = target.filter_data
	return data

/datum/filter_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_filter")
			var/target_name = params["name"]
			while(target.filter_data && target.filter_data[target_name])
				target_name = "[target_name]-dupe"
			target.add_filter(target_name, params["priority"], list("type" = params["type"]))
			. = TRUE
		if("remove_filter")
			target.remove_filter(params["name"])
			. = TRUE
		if("rename_filter")
			var/list/filter_data = target.filter_data[params["name"]]
			target.remove_filter(params["name"])
			target.add_filter(params["new_name"], filter_data["priority"], filter_data)
			. = TRUE
		if("edit_filter")
			target.remove_filter(params["name"])
			target.add_filter(params["name"], params["priority"], params["new_filter"])
			. = TRUE
		if("change_priority")
			var/new_priority = params["new_priority"]
			target.change_filter_priority(params["name"], new_priority)
			. = TRUE
		if("transition_filter_value")
			target.transition_filter(params["name"], 4, params["new_data"])
			. = TRUE
		if("modify_filter_value")
			var/list/old_filter_data = target.filter_data[params["name"]]
			var/list/new_filter_data = old_filter_data.Copy()
			for(var/entry in params["new_data"])
				new_filter_data[entry] = params["new_data"][entry]
			for(var/entry in new_filter_data)
				if(entry == master_filter_info[old_filter_data["type"]]["defaults"][entry])
					new_filter_data.Remove(entry)
			target.remove_filter(params["name"])
			target.add_filter(params["name"], old_filter_data["priority"], new_filter_data)
			. = TRUE
		if("modify_color_value")
			var/new_color = input(usr, "Pick new filter color", "Filteriffic Colors!") as color|null
			if(new_color)
				target.transition_filter(params["name"], 4, list("color" = new_color))
				. = TRUE
		if("modify_icon_value")
			var/icon/new_icon = input("Pick icon:", "Icon") as null|icon
			if(new_icon)
				target.filter_data[params["name"]]["icon"] = new_icon
				target.update_filters()
				. = TRUE
		if("mass_apply")
			// if(!check_rights_for(usr.client, R_FUN))
			// 	to_chat(usr, "<span class='userdanger>Stay in your lane, jannie.</span>'")
			// 	return
			var/target_path = text2path(params["path"])
			if(!target_path)
				return
			var/filters_to_copy = target.filters
			var/filter_data_to_copy = target.filter_data
			var/count = 0
			for(var/thing in world.contents)
				if(istype(thing, target_path))
					var/atom/thing_at = thing
					thing_at.filters = filters_to_copy
					thing_at.filter_data = filter_data_to_copy
					count += 1
			//message_admins("LOCAL CLOWN [usr.ckey] JUST MASS FILTER EDITED [count] WITH PATH OF [params["path"]]!")
			//log_admin("LOCAL CLOWN [usr.ckey] JUST MASS FILTER EDITED [count] WITH PATH OF [params["path"]]!")

#define ICON_NOT_SET "Not Set"

//This is stored as a nested list instead of datums or whatever because it json encodes nicely for usage in tgui
var/static/master_filter_info = list(
	"alpha" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"icon" = ICON_NOT_SET,
			"render_source" = "",
			"flags" = 0
		),
		"flags" = list(
			"MASK_INVERSE" = MASK_INVERSE,
			"MASK_SWAP" = MASK_SWAP
		)
	),
	"angular_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1
		)
	),
	/* Not supported because making a proper matrix editor on the frontend would be a huge dick pain.
		Uncomment if you ever implement it
	"color" = list(
		"defaults" = list(
			"color" = matrix(),
			"space" = FILTER_COLOR_RGB
		)
	),
	*/
	"displace" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = null,
			"icon" = ICON_NOT_SET,
			"render_source" = ""
		)
	),
	"drop_shadow" = list(
		"defaults" = list(
			"x" = 1,
			"y" = -1,
			"size" = 1,
			"offset" = 0,
			"color" = COLOR_HALF_TRANSPARENT_BLACK
		)
	),
	"blur" = list(
		"defaults" = list(
			"size" = 1
		)
	),
	"layer" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"icon" = ICON_NOT_SET,
			"render_source" = "",
			"flags" = FILTER_OVERLAY,
			"color" = "",
			"transform" = null,
			"blend_mode" = BLEND_DEFAULT
		)
	),
	"motion_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0
		)
	),
	"outline" = list(
		"defaults" = list(
			"size" = 0,
			"color" = COLOR_BLACK,
			"flags" = 0
		),
		"flags" = list(
			"OUTLINE_SHARP" = OUTLINE_SHARP,
			"OUTLINE_SQUARE" = OUTLINE_SQUARE
		)
	),
	"radial_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 0.01
		)
	),
	"rays" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 16,
			"color" = COLOR_WHITE,
			"offset" = 0,
			"density" = 10,
			"threshold" = 0.5,
			"factor" = 0,
			"flags" = FILTER_OVERLAY | FILTER_UNDERLAY
		),
		"flags" = list(
			"FILTER_OVERLAY" = FILTER_OVERLAY,
			"FILTER_UNDERLAY" = FILTER_UNDERLAY
		)
	),
	"ripple" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1,
			"repeat" = 2,
			"radius" = 0,
			"falloff" = 1,
			"flags" = 0
		),
		"flags" = list(
			"WAVE_BOUNDED" = WAVE_BOUNDED
		)
	),
	"wave" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1,
			"offset" = 0,
			"flags" = 0
		),
		"flags" = list(
			"WAVE_SIDEWAYS" = WAVE_SIDEWAYS,
			"WAVE_BOUNDED" = WAVE_BOUNDED
		)
	)
)

#undef ICON_NOT_SET

//Helpers to generate lists for filter helpers
//This is the only practical way of writing these that actually produces sane lists
/proc/alpha_mask_filter(x, y, icon/icon, render_source, flags)
	. = list("type" = "alpha")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(flags))
		.["flags"] = flags

/proc/angular_blur_filter(x, y, size)
	. = list("type" = "angular_blur")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size

/proc/color_matrix_filter(matrix/in_matrix, space)
	. = list("type" = "color")
	.["color"] = in_matrix
	if(!isnull(space))
		.["space"] = space

/proc/displacement_map_filter(icon, render_source, x, y, size = 32)
	. = list("type" = "displace")
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size

/proc/drop_shadow_filter(x, y, size, offset, color)
	. = list("type" = "drop_shadow")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(color))
		.["color"] = color

/proc/gauss_blur_filter(size)
	. = list("type" = "blur")
	if(!isnull(size))
		.["size"] = size

/proc/layering_filter(icon, render_source, x, y, flags, color, transform, blend_mode)
	. = list("type" = "layer")
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(color))
		.["color"] = color
	if(!isnull(flags))
		.["flags"] = flags
	if(!isnull(transform))
		.["transform"] = transform
	if(!isnull(blend_mode))
		.["blend_mode"] = blend_mode

/proc/motion_blur_filter(x, y)
	. = list("type" = "motion_blur")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/outline_filter(size, color, flags)
	. = list("type" = "outline")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(color))
		.["color"] = color
	if(!isnull(flags))
		.["flags"] = flags

/proc/radial_blur_filter(size, x, y)
	. = list("type" = "radial_blur")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/rays_filter(size, color, offset, density, threshold, factor, x, y, flags)
	. = list("type" = "rays")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(color))
		.["color"] = color
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(density))
		.["density"] = density
	if(!isnull(threshold))
		.["threshold"] = threshold
	if(!isnull(factor))
		.["factor"] = factor
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(flags))
		.["flags"] = flags

/proc/ripple_filter(radius, size, falloff, repeat, x, y, flags)
	. = list("type" = "ripple")
	if(!isnull(radius))
		.["radius"] = radius
	if(!isnull(size))
		.["size"] = size
	if(!isnull(falloff))
		.["falloff"] = falloff
	if(!isnull(repeat))
		.["repeat"] = repeat
	if(!isnull(flags))
		.["flags"] = flags
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/wave_filter(x, y, size, offset, flags)
	. = list("type" = "wave")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(flags))
		.["flags"] = flags

/proc/apply_wibbly_filters(atom/in_atom, length)
	for(var/i in 1 to 7)
		//This is a very baffling and strange way of doing this but I am just preserving old functionality
		var/X
		var/Y
		var/rsq
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900) // Yeah let's just loop infinitely due to bad luck what's the worst that could happen?
		var/random_roll = rand()
		in_atom.add_filter("wibbly-[i]", 5, wave_filter(x = X, y = Y, size = rand() * 2.5 + 0.5, offset = random_roll))
		var/filter = in_atom.get_filter("wibbly-[i]")
		animate(filter, offset = random_roll, time = 0, loop = -1, flags = ANIMATION_PARALLEL)
		animate(offset = random_roll - 1, time = rand() * 20 + 10)

/proc/remove_wibbly_filters(atom/in_atom)
	var/filter
	for(var/i in 1 to 7)
		filter = in_atom.get_filter("wibbly-[i]")
		animate(filter)
		in_atom.remove_filter("wibbly-[i]")
