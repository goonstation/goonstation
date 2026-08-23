// A lightweight datum to create and manage animation steps (inspired by parallax_viewer.dm).
// Provides a simple API for creating, editing, reordering, serializing and previewing animation steps.

/client/proc/cmd_animviewer()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Animation Editor"
	set desc = "Animation Editor"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(holder)
		var/datum/animation_editor/E = new /datum/animation_editor(src.mob)
		E.ui_interact(mob)


/datum/animation_editor
	var/list/steps = list() // list of /datum/animation_step
	var/atom/target = null
	var/list/valid_keys = list(
		"alpha",
		"color",
		// "glide_size",
		"infra_luminosity",
		"layer",
		"maptext_width",
		"maptext_height",
		"maptext_x",
		"maptext_y",
		"luminosity",
		"pixel_x",
		"pixel_y",
		"pixel_w",
		"pixel_z",
		"transform",
		"dir",
		"icon",
		"icon_state",
		"invisibility",
		"maptext",
		"suffix",
	)


/datum/animation_editor/New()
		. = ..()


/datum/animation_editor/ui_state(mob/user)
	return tgui_admin_state


/datum/animation_editor/ui_static_data(mob/user)
	. = list()
	.["valid_keys"] = src.valid_keys
	.["easing_options"] = list(
		"LINEAR_EASING" = LINEAR_EASING,
		"CIRCULAR_EASING" = CIRCULAR_EASING,
		"SINE_EASING" = SINE_EASING,
		"QUAD_EASING" = QUAD_EASING,
		"CUBIC_EASING" = CUBIC_EASING,
		"BOUNCE_EASING" = BOUNCE_EASING,
		"ELASTIC_EASING" = ELASTIC_EASING,
		"JUMP_EASING" = JUMP_EASING
	)
	.["easing_flags"] = list(
		"EASE_IN" = EASE_IN,
		"EASE_OUT" = EASE_OUT
	)

	.["flags"] = list(
		"ANIMATION_END_NOW" = ANIMATION_END_NOW,
		"ANIMATION_LINEAR_TRANSFORM" = ANIMATION_LINEAR_TRANSFORM,
		"ANIMATION_PARALLEL" = ANIMATION_PARALLEL,
		"ANIMATION_RELATIVE" = ANIMATION_RELATIVE,
		"ANIMATION_CONTINUE" = ANIMATION_CONTINUE,
		"ANIMATION_SLICE" = ANIMATION_SLICE,
		"ANIMATION_END_LOOP" = ANIMATION_END_LOOP
	)


/datum/animation_editor/ui_data()
	. = list()
	.["steps"] = src.steps
	.["target"] = isatom(src.target) ? src.target.name : null


/datum/animation_editor/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	USR_ADMIN_ONLY
	if(.)
		return

	var/step_index
	if( !isnum(params["index"]) || params["index"] > length(src.steps) )
		step_index = null
	else
		step_index = params["index"]+1 // adjust for 1-based indexing

	. = TRUE
	switch(action)

		if("update_step")
			if(!step_index)
				return
			var/step = src.steps[step_index]
			if(!step)
				return

			switch(params["field"])
				if("name")
					step["name"] = params["value"]
				if("time", "loop", "easing", "flags")
					if(isnum(params["value"]))
						step[params["field"]] = params["value"]

		if("import_steps")
			if(!params["data"])
				return
			var/data = json_decode(params["data"])
			// validate the crap out of it
			if(!islist(data))
				return
			for(var/i = 1; i <= length(data); i++)
				var/step = data[i]
				if(!islist(step))
					return
				if(!("var_list" in step) || !("time" in step))
					return
				for(var/key in step["var_list"])
					if(!(key in src.valid_keys))
						return

			// if we made it here, it's probably fine
			src.steps = data

		if("update_step_var")
			if(!step_index)
				return
			var/step = src.steps[step_index]
			if(!step)
				return
			var/key = params["key"]
			if(!(key in src.valid_keys))
				return

			// Update var value
			step["var_list"][key] = params["value"]

		if("delete_step_var")
			if(!step_index)
				return
			var/step = src.steps[step_index]
			if(!step)
				return
			var/key = params["key"]
			if(!(key in step["var_list"]))
				return

			// Delete var
			step["var_list"] -= key

		if("move_step")
			if(!step_index)
				return
			var/step = src.steps[step_index]
			if(!step)
				return
			src.steps.Swap(step_index, params["new_index"]+1)

		if("add_step_var")
			if(!step_index)
				return
			var/step = src.steps[step_index]
			if(!step)
				return
			var/key = params["key"]
			if(!(key in src.valid_keys))
				return

			// Add var with default value
			step["var_list"][key] = 0

		if("modify_ref_value")
			var/atom/target = pick_ref(usr)
			if(!isatom(target))
				return
			src.target = target

		if("add_step")
			src.add_animation(steps.len + 1)

		if("delete_step")
			if(!step_index)
				return
			src.steps.Cut(step_index, step_index+1)

		if("play_animation")
			src.play()


/datum/animation_editor/proc/add_animation(step_index)
	var/new_animation = list(
		"name"="New Step",
		"var_list"=list("pixel_x"=0, "pixel_y"=0),
		"time"=1.0,
		"loop"=0,
		"easing"=0,
		"flags"=0
	)
	steps += list(new_animation)


/datum/animation_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnimationEditor")
		ui.open()


/datum/animation_editor/proc/play()
	if(istype(target))
		var/mob/M = target
		M.name = M.name

		var/is_first = TRUE
		for(var/step in src.steps)
			if(is_first)
				is_first = FALSE
				animate(src.target, time=step["time"], step["var_list"], loop=step["loop"], easing=step["easing"], flags=step["flags"])
			else
				animate(time=step["time"], step["var_list"], loop=step["loop"], easing=step["easing"], flags=step["flags"])
