#ifndef UNDERWATER_MAP
#ifndef HALLOWEEN
/datum/random_event/major/pretty_space
	name = "Space Colors"
	customization_available = 1
	required_elapsed_round_time = 0 MINUTES

	admin_call(var/source)
		if (..())
			return

		var/color = usr.client?.input_data(list(DATA_INPUT_JSON), "Enter color matrix", null, null)?.output
		var/duration = usr.client?.input_data(list(DATA_INPUT_NUM), "Enter duration (in seconds)", null, null)?.output * 1 SECOND
		src.event_effect(source, duration, color)
		return

	event_effect(var/source, duration = null, list/color = null)
		..()
		if(!islist(color))
			color = list()
			for(var/i in 1 to 9)
				color.Add(0.15 + rand())
			for(var/i in 1 to 3)
				color.Add(rand()/10)
		if(!duration)
			duration = 30 SECONDS + rand() * 3 MINUTES

		command_alert("Navigational radar indicates that the [station_or_ship()] will shortly begin drifting through a molecular cloud. This poses no danger to structural integrity or personnel, so enjoy the view.", "Navigational Update", alert_origin = ALERT_WEATHER)
		for(var/turf/space/T in block(locate(1, 1, 1), locate(world.maxx, world.maxy, 1)))

			//T.add_filter("pretty_space", 1, color_matrix_filter(COLOR_MATRIX_IDENTITY))
			//T.transition_filter("pretty_space", 10 SECONDS, list("color"=color), LINEAR_EASING, FALSE)
			//T.color = null
			animate(T, 10 SECONDS, easing=LINEAR_EASING, color = color)
			LAGCHECK(LAG_HIGH)
		SPAWN(duration)
			for(var/turf/space/T in block(locate(1, 1, 1), locate(world.maxx, world.maxy, 1)))
				//T.transition_filter("pretty_space", 10 SECONDS, list("color"=COLOR_MATRIX_IDENTITY), LINEAR_EASING, FALSE)
				//T.remove_filter("pretty_space")
				//T.color = T.space_color
				animate(T, 10 SECONDS, easing=LINEAR_EASING, color = T.space_color)
				LAGCHECK(LAG_HIGH)
#endif
#endif