/client/proc/cmd_ambient_viewer()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Ambient Viewer"
	set desc = "Ambient Viewer"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(holder)
		var/datum/ambient_lightning_viewer/E = new /datum/ambient_lightning_viewer(src.mob)
		E.ui_interact(mob)


/datum/ambient_lightning_viewer
	var/effects = list("Sunrise"=list(list("#222", "#444","#ca2929", "#c4b91f", "#AAA", ), list(0, 10 SECONDS, 20 SECONDS, 15 SECONDS, 25 SECONDS)),
						"Day"=list(list("#666666"), list(10 SECONDS)),
						"Sunset"=list(list("#AAA", "#c53a8b", "#b13333", "#444","#222"), list(0, 25 SECONDS, 25 SECONDS, 20 SECONDS, 25 SECONDS)),
						"Night"=list(list("#222222"), list(10 SECONDS))
						)


/datum/ambient_lightning_viewer/ui_state(mob/user)
	return tgui_admin_state

/datum/ambient_lightning_viewer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AmbientViewer")
		ui.open()

/datum/ambient_lightning_viewer/ui_static_data(mob/user)
	. = list()

/datum/ambient_lightning_viewer/ui_data(mob/user)
	. = list()
	.["controllers"] = list()
	for( var/controller_id in daynight_controllers )
		var/datum/daynight_controller/DC = daynight_controllers[controller_id]
		if(istype(DC))
			.["controllers"][controller_id] = list(
				"id" = controller_id,
				"byondRef" = "[ref(DC)]",
				"active" = DC.active,
				"speed" = DC.speed,
				"cycle" = DC.cycle / (1 MINUTE),
				"time" = DC.time / (1 MINUTE),
				"color" = DC.current_color,
				"advanced" = null,
				"samples" = DC.generate_color_samples()
			)
			if(istype(DC, /datum/daynight_controller/terrainify))
				var/datum/daynight_controller/terrainify/DC_terrain = DC
				.["controllers"][controller_id]["advanced"] = list(
					"color1" = DC_terrain.color1,
					"color2" = DC_terrain.color2
				)

	return

/datum/ambient_lightning_viewer/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!daynight_controllers)
		return

	var/datum/daynight_controller/DC = locate(params["byondRef"])
	if(!istype(DC))
		return

	. = TRUE
	switch(action)
		if("effect")
			var/effect_name = tgui_input_list(usr, "Select an effect to play:", "Ambient Lighting", effects)
			if(effects[effect_name])
				var/list/colors = effects[effect_name][1]
				var/list/durations = effects[effect_name][2]
				DC.active = FALSE
				color_shift_lights(DC, colors, durations)
			else
				. = FALSE

		if("modify_color")
			var/current_color = params["value"]
			var/new_color = tgui_color_picker(usr, "Please select a color.", "Ambient Lighting", current_color)
			if(!new_color)
				return
			switch(params["type"])
				if("color1")
					if(istype(DC, /datum/daynight_controller/terrainify))
						var/datum/daynight_controller/terrainify/DC_terrain = DC
						DC_terrain.color1 = new_color
						DC.process()

				if("color2")
					if(istype(DC, /datum/daynight_controller/terrainify))
						var/datum/daynight_controller/terrainify/DC_terrain = DC
						DC_terrain.color2 = new_color
						DC.process()

				if("color_picker")
					DC.update_color(new_color)

		if("modify")
			switch(params["type"])
				if("speed")
					var/new_speed = params["value"]
					if(new_speed && new_speed > 0)
						DC.speed = new_speed

				if("cycle")
					var/new_cycle = params["value"]
					if(new_cycle && new_cycle > 0)
						DC.cycle = new_cycle MINUTES
						DC.time = DC.time % DC.cycle
					DC.process()

				if("time")
					var/new_time = params["value"]
					if(new_time && new_time >= 0)
						DC.time = (new_time MINUTES) % DC.cycle
					DC.process()

				if("active")
					DC.active = params["value"]
					if(DC.active)
						DC.process()

				else
					. = FALSE

/datum/ambient_lightning_viewer/proc/color_shift_lights(datum/daynight_controller/DC, list/colors, list/durations)
	if(istype(DC) && length(colors) && length(durations))
		var/iterations = min(length(colors), length(durations))

		if(istype(DC.light))
			for(var/i in 1 to iterations)
				if(i==1)
					animate(DC.light, color=colors[i], time=durations[i])
				else
					animate(color=colors[i], time=durations[i])

		if(istype(DC.ambient_screen))
			for(var/i in 1 to iterations)
				if(i==1)
					animate(DC.ambient_screen, color=colors[i], time=durations[i])
				else
					animate(color=colors[i], time=durations[i])


