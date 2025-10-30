TYPEINFO(/datum/random_event/major/find_planet)
	initialization_args = list(
		EVENT_INFO_EXT("generator", DATA_INPUT_LIST_CHILDREN_OF, "Generator To Use", /datum/map_generator),
		EVENT_INFO("planet_name", DATA_INPUT_TEXT, "Planet Name"),
		EVENT_INFO_EXT("width", DATA_INPUT_NUM, "Planet Width", 9, 250),
		EVENT_INFO_EXT("height", DATA_INPUT_NUM, "Planet Height", 9, 250),
		EVENT_INFO_EXT("prefabs", DATA_INPUT_NUM, "Prefabs to attempt to place", 0, 10),
		EVENT_INFO("generate_mobs", DATA_INPUT_BOOL, "Generate Mobs?"),
		EVENT_INFO("seed_ore", DATA_INPUT_BOOL, "Generate Ore in Rocks/Mountains"),
		EVENT_INFO("color", DATA_INPUT_COLOR, "Planet Color"),
		EVENT_INFO("slow_generation", DATA_INPUT_BOOL, "Slow generation?"),
		EVENT_INFO("delay_finalization", DATA_INPUT_BOOL, "Delay Finalization?")
	)


/datum/random_event/major/find_planet
	name = "Find Planet"
	required_elapsed_round_time = 28 MINUTES
	customization_available = 1
	weight = 10

	var/generate_mobs = TRUE
	var/add_lrt = TRUE
	var/delay_finalization = FALSE
	var/seed_ore = TRUE
	var/width = null
	var/height = null
	var/prefabs = 1
	var/generator = null
	var/planet_name = null
	var/admin_customized = FALSE
	var/slow_generation = TRUE
	var/color = null
	var/lock = FALSE

	admin_call(var/source)
		if (..())
			return

		var/datum/random_event_editor/E = new /datum/random_event_editor(usr, src)
		if(E)
			height = rand(80,130)
			width = rand(80,130)
			E.ui_interact(usr)
		else
			generator = tgui_input_list(usr, "Select a Generator type.", "Generator type", childrentypesof(/datum/map_generator))
			if(generator)
				height = tgui_input_number(usr, "Planet Height", "Planet Generation", rand(80,130), 250, 9)
				width = tgui_input_number(usr, "Planet Width", "Planet Generation", rand(80,130), 250, 9)
				prefabs = tgui_input_number(usr, "Prefabs to attempt to place", "Planet Generation", 1, 5, 0)

				generate_mobs = alert("Generate Mobs", "Planet Generation", "True", "False") == "True" ? TRUE : FALSE
				if(alert("Generate Ore in Rocks/Mountains","Planet Generation","Yes","No") == "No")
					seed_ore = FALSE
				color = input("Choose a color for the planet","Planet Generation", "#888888") as color

				planet_name = tgui_input_text(usr, "Planet name (Cancel for Random Name)", "Planet Generation", null)
				if(length(planet_name)<1)
					planet_name = null

				if(alert("Do you want to delay finalization for any customization?","Caution!","Yes","No") == "Yes")
					delay_finalization = TRUE

				admin_customized = TRUE

			if(generator && alert("Are you sure you want to generate this planet? [width]x[height] [generator] with [prefabs] prefab.","Generate Planet?","Yes","No") == "Yes")
				src.event_effect(source)
			else
				boutput(usr,SPAN_INTERNAL("Planet Generation Event cancelled."))


	event_effect()
		..()

		if (src.lock)
			message_admins("Previous Find Planet event hasn't finished yet, aborting.")
			return
		src.lock = TRUE

		SPAWN(0)
			var/blacklist_generators = list(/datum/map_generator/icemoon_generator,
											/datum/map_generator/mars_generator,
											/datum/map_generator/void_generator,
											/datum/map_generator/asteroids,
											/datum/map_generator/sea_caves,
											/datum/map_generator/storehouse_generator,
											/datum/map_generator/storehouse_generator/meaty,
											/datum/map_generator/room_maze_generator,
											/datum/map_generator/room_maze_generator/random,
											/datum/map_generator/room_maze_generator/spatial)

			if(isnull(generator))
				generator = pick(childrentypesof(/datum/map_generator)-blacklist_generators)

			if(!admin_customized)
				if(!color && prob(10))
					color = pick("#222", "#444", "#666", "#844", "#884", "#448", "#288")
				prefabs = rand(2, 3)

			if(!planet_name)
				planet_name = ""
				if (prob(50))
					planet_name += pick_string("station_name.txt", "greek")
				else
					planet_name += pick_string("station_name.txt", "militaryLetters")
				planet_name += " "

				if (prob(30))
					planet_name += pick_string("station_name.txt", "romanNum")
				else
					planet_name += "[rand(2, 99)]"

			var/flags = 0
			if(!generate_mobs)
				flags |= MAPGEN_IGNORE_FAUNA

			if(slow_generation)
				flags |= MAPGEN_SLOW_GENERATION

			if(delay_finalization && add_lrt)

				var/list/turf/turfs = GeneratePlanetChunk(src.width, src.height, prefabs_to_place=src.prefabs, generator=src.generator, color=src.color, name=planet_name, use_lrt=FALSE, seed_ore=src.seed_ore, mapgen_flags=flags)
				if(!length(turfs))
					message_admins("Planet Generation Failed!")

				tgui_alert(usr, "Continue when you are complete...","Ready?!?",list("Continue"))

				var/lrt_placed = FALSE
				var/maxTries = 80
				while(!lrt_placed)
					if(!maxTries)
						message_admins("Planet region failed to place LRT coordinates!!!")
						break

					var/turf/T = pick(turfs)
					if(!checkTurfPassable(T))
						maxTries--
						continue

					new /obj/landmark/lrt/planet(T, planet_name)
					new /obj/decal/teleport_mark(T)
					lrt_placed = TRUE
					special_places.Add(planet_name)
			else
				GeneratePlanetChunk(src.width, src.height, prefabs_to_place=src.prefabs, generator=src.generator, color=src.color, name=planet_name, use_lrt=src.add_lrt, seed_ore=src.seed_ore, mapgen_flags=flags)

			var/sound_to_play = 'sound/misc/announcement_1.ogg'
			var/title = pick("Planetary Data Received","URGENT - Exploration Mission","Exploration Mission to [planet_name]")
			var/list/reports = list("Unusual readings detected on [planet_name].  Investigate and bring back any relevant equipment or technology.", \
			"Our company has been granted permission to explore [planet_name], a nearby planet that has shown signs of potential habitability. The goals of the mission are to conduct a thorough survey of the planet's surface and search for signs of past or present life.", \
			"Urgent request has been made to explore [planet_name], a nearby planet that has shown signs of potential habitability. Due to the pressing nature of this request, please depart immediately. The goals of the mission are to conduct a quick survey of the planet's surface and search for any signs of life.", \
			"We have received approval to explore [planet_name], a nearby planet of great interest to us.  This is a highly secretive and sensitive mission, and I trust that all employees will maintain strict confidentiality.")

			if(generator == /datum/map_generator/void_generator)
				title = pick("Anamolous Data Received", "URGENT - Exploration Mission")
				reports = list("Unusual readings detected on [planet_name].  Investigate and bring back any relevant equipment or technology.")
			else if(generator == /datum/map_generator/asteroids)
				title = pick("Exploration Mission to [planet_name]", "URGENT - Exploration Mission")
				reports = list("Unusual readings detected on [planet_name].  Investigate and bring back any relevant equipment or technology.", \
			"Our company has been granted permission to explore [planet_name], a nearby cluster of asteroids. The goals of the mission are to conduct a thorough survey of the region and search for signs of past or present life.", \
			"Urgent request has been made to explore [planet_name], a nearby asteroid that has shown signs of valuable minerals. Due to the pressing nature of this request, please depart immediately. The goals of the mission are to conduct a quick survey of the region.", \
			"We have received approval to explore [planet_name], this group of asteroids if of great interest to us.  This is a highly secretive and sensitive mission, and I trust that all employees will maintain strict confidentiality.")

			var/command_report = pick(reports)
			command_report += "\n\nTarget data sent to the teleport computer."
			command_announcement(replacetext(command_report, "\n", "<br>"), title, sound_to_play, do_sanitize=0,alert_origin=ALERT_ANOMALY);

			post_event()

	proc/post_event()
		src.generate_mobs = initial(src.generate_mobs)
		src.add_lrt = initial(src.add_lrt)
		src.delay_finalization = initial(src.delay_finalization)
		src.width = initial(src.width)
		src.height = initial(src.height)
		src.prefabs = initial(src.prefabs)
		src.seed_ore = initial(src.seed_ore)
		src.planet_name = initial(src.planet_name)
		src.color = initial(src.color)
		src.generator = initial(src.generator)
		src.admin_customized = initial(src.admin_customized)
		src.lock = FALSE
		return
