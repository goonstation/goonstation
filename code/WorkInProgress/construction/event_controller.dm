/datum/construction_controller
	var/human_next_event

	var/next_event_type = null
	var/datum/construction_event/current_event = null
	var/datum/construction_event/next_event = null
	var/datum/construction_event/fallback_event = null
	var/list/all_events = list()
	var/list/possible_events = list()
	var/list/event_types = list()

	var/event_delay = 0
	var/choose_at = 0
	var/next_event_at = 0

	New()
		..()
		for (var/evtype in typesof(/datum/construction_event))
			var/datum/construction_event/E = new evtype()
			if (E.is_abstract)
				qdel(E)
			else
				all_events += E
				if (E.milestone == null)
					possible_events += E
		rebuild_event_types()

	proc/notify_milestone_complete(var/datum/progress/P)
		for (var/datum/construction_event/E in all_events)
			if (istype(P, E.milestone))
				possible_events += E
		rebuild_event_types()

	proc/notify_milestone_uncomplete(var/datum/progress/P)
		for (var/datum/construction_event/E in possible_events)
			if (istype(P, E.milestone))
				possible_events -= E
		rebuild_event_types()

	proc/rebuild_event_types()
		event_types.len = 0
		for (var/datum/construction_event/E in possible_events)
			if (!(E.event_type in event_types))
				event_types += E.event_type

	proc/process()
		if (!ticker)
			return
		if (!ticker.mode)
			return
		if (!istype(ticker.mode, /datum/game_mode/construction))
			return

		if (event_delay)
			if (ticker.round_elapsed_ticks < event_delay)
				if (current_event)
					current_event.process()
				return
			else
				if (current_event)
					current_event.tear_down()
					current_event = null
				event_delay = 0

		if (!next_event_type)
			next_event_type = pick(event_types)
			var/minutes = rand(15, 30)
			next_event_at = ticker.round_elapsed_ticks + minutes * 60 * 10 + rand(0, 59) * 10
			choose_at = ticker.round_elapsed_ticks + rand(5, round(minutes / 2)) * 60 * 10 + rand(0, 59) * 10
			for (var/datum/construction_event/E in possible_events)
				if (E.event_type == next_event_type)
					fallback_event = E
					break
			if (!fallback_event)
				next_event_type = null
			return

		if (choose_at)
			if (ticker.round_elapsed_ticks >= choose_at)
				var/list/type_events = list()
				for (var/datum/construction_event/E in possible_events)
					if (E.event_type == next_event_type)
						type_events += E
				if (type_events.len)
					next_event = pick(type_events)
				else
					next_event = fallback_event
				next_event.early_warning()
				fallback_event = null
				if (next_event.additional_prep_time)
					next_event_at += next_event.additional_prep_time
				choose_at = 0
			else
				return

		if (next_event_at)
			if (ticker.round_elapsed_ticks >= next_event_at)
				next_event.set_up()
				current_event = next_event
				next_event = null
				event_delay = ticker.round_elapsed_ticks + current_event.duration
				next_event_at = 0
				next_event_type = null
			else
				return

/datum/construction_event
	var/name = null
	var/early_warning_heading = "Anomaly alert"
	var/early_warning_text = "An anomaly is heading towards the station."
	var/warning_heading = "Anomaly alert"
	var/warning_text = "The anomaly has reached the station."
	var/datum/progress/milestone = null
	var/event_type = "Anomaly"
	var/duration = 600 // 1 min
	var/additional_prep_time = 0
	var/is_abstract = 1
	var/time_scaling = 0.167
	var/time_modifier = 0
	var/player_scaling = 0.1
	var/player_modifier = 0

	proc/early_warning()
		for_by_tcl(C, /obj/machinery/communications_dish)
			C.add_centcom_report(ALERT_GENERAL, early_warning_text)

		if (!early_warning_heading)
			command_alert(early_warning_text)
		else
			command_alert(early_warning_text, early_warning_heading)

	proc/set_up()
		for_by_tcl(C, /obj/machinery/communications_dish)
			C.add_centcom_report(ALERT_GENERAL, warning_text)

		if (!warning_heading)
			command_alert(warning_text)
		else
			command_alert(warning_text, warning_heading)

		calculate_player_modifier()
		calculate_time_modifier()

	proc/process()
		return
	proc/tear_down()
		return

	proc/calculate_player_modifier()
		player_modifier = 1

		for (var/client/C)
			if (C.mob && !isdead(C.mob))
				player_modifier += player_scaling

	proc/calculate_time_modifier()
		var/datum/game_mode/construction/C = ticker.mode
		var/elapsed_time = ticker.round_elapsed_ticks - C.starttime
		time_modifier = (1 + round(elapsed_time / 36000) * time_scaling)

/datum/construction_event/nothing
	duration = 600
	name = "Nothing"
	siege
		early_warning_heading = "Siege alert"
		early_warning_text = "A large attack force has been detected on collision course with the station."
		warning_heading = "Siege alert averted"
		warning_text = "The attacking force changed course towards a nearby planet."
		event_type = "Siege"

		syndicate
			event_type = "Syndicate Siege"

	anomaly
		early_warning_text = "Chunks from a nearby asteroid collision are headed towards the station from the"
		warning_text = "The gravitational field of a nearby planet diverted the meteors off collision course."
		event_type = "Cosmic Anomaly"

		early_warning()
			var/early_warning_orig = early_warning_heading
			early_warning_text = "[early_warning_heading] [pick("north!", "south!", "east!", "west!")]"
			..()
			early_warning_text = early_warning_orig

#define METHOD_TELEPORT 1
#define METHOD_SPAWN 2
//#define METHOD_TELEPORT_TO_SPACE 3
#define METHOD_EDGE_WANDER 4

/datum/construction_event/siege
	name = "Siege"
	early_warning_heading = "Siege alert"
	early_warning_text = "A large attack force has been detected on collision course with the station."
	warning_heading = "Siege alert"
	warning_text = "We are under attack!"
	event_type = "Siege"

	time_scaling = 0.33
	player_scaling = 0.2
	var/original_duration = 600
	var/spawn_delay = 2
	var/current_delay = 0
	var/max_attack_force_size = 50
	var/original_size = 50
	var/current_attack_force_size = 0
	var/list/attacker_types = list()
	var/list/bosses = list()
	var/current_bosses = 0
	var/difficulty_multiplier = 0
	var/original_bosses = 2
	var/max_bosses = 2
	var/method = METHOD_TELEPORT
	var/list/possible_target_turfs = list()
	var/per_process = 1

	var/x_min
	var/x_max
	var/y_min
	var/y_max

	set_up()
		..()
		player_modifier -= 1
		time_modifier -= 0.5
		difficulty_multiplier = time_modifier * player_modifier
		duration = original_duration * difficulty_multiplier
		max_attack_force_size = round(original_size * difficulty_multiplier)
		per_process = max(1, round(max_attack_force_size / 20))
		max_bosses = round(original_bosses * difficulty_multiplier)
		current_attack_force_size = 0
		current_delay = 0
		current_bosses = 0
		possible_target_turfs.len = 0

		var/area/shuttle/arrival/station/A = locate() in world
		var/turf/Q = A.find_middle(0)
		for (var/turf/simulated/floor/F in range(50, Q))
			if (!(F in A))
				possible_target_turfs += F

		if (method == METHOD_EDGE_WANDER)
			switch(rand(1,4))
				if (1)
					x_min = 50
					x_max = 250
					y_min = 295
					y_max = 297
				if (2)
					x_min = 50
					x_max = 250
					y_min = 3
					y_max = 5
				if (3)
					x_min = 295
					x_max = 297
					y_min = 50
					y_max = 250
				if (4)
					x_min = 3
					x_max = 5
					y_min = 50
					y_max = 250

	process()
		if (current_attack_force_size < max_attack_force_size)
			var/runs = 1
			if (per_process > 1)
				runs = rand(1, per_process)
			for (var/times = 1, times <= runs, times++)
				if (current_delay > 0)
					current_delay--
				else if (prob(25 * difficulty_multiplier))
					if (method == METHOD_TELEPORT || method == METHOD_SPAWN)
						var/valid = 0
						while (!valid)
							if (!possible_target_turfs.len)
								current_attack_force_size = max_attack_force_size
								break
							var/turf/target = pick(possible_target_turfs)
							if (target.density)
								possible_target_turfs -= target
								continue
							valid = 1
							for (var/obj/O in target)
								if (O.density)
									possible_target_turfs -= target
									valid = 0
									break
							if (!valid)
								continue
							var/attacker_type
							if (current_bosses < max_bosses && bosses.len && prob(5))
								attacker_type = pick(bosses)
								current_bosses++
							else
								attacker_type = pick(attacker_types)
							new attacker_type(target)
							current_attack_force_size++
							current_delay = spawn_delay
							if (method == METHOD_TELEPORT)
								showswirl(target)
					else if (method == METHOD_EDGE_WANDER)
						var/valid = 0
						while (!valid)
							if (!possible_target_turfs.len)
								current_attack_force_size = max_attack_force_size
								break
							var/turf/target = pick(possible_target_turfs)
							if (target.density)
								possible_target_turfs -= target
								continue
							valid = 1
							for (var/obj/O in target)
								if (O.density)
									possible_target_turfs -= target
									valid = 0
									break
							if (!valid)
								continue
							var/attacker_type
							if (current_bosses < max_bosses && bosses.len && prob(5))
								attacker_type = pick(bosses)
								current_bosses++
							else
								attacker_type = pick(attacker_types)
							var/obj/critter/CR = new attacker_type(locate(rand(x_min, x_max), rand(y_min, y_max), 1))
							current_attack_force_size++
							CR.task = "following path"
							CR.followed_path = findPath(CR.loc, target)
							CR.followed_path_retry_target = target
							if (prob(30 / difficulty_multiplier))
								CR.follow_path_blindly = 1

/datum/construction_event/siege/rockworm
	name = "Siege?"
	warning_text = "We are under attack by the Space Rock Worm Federation!"
	attacker_types = list(/obj/critter/rockworm)
	original_size = 20
	original_bosses = 0
	is_abstract = 0

/datum/construction_event/siege/hobo
	name = "Siege?"
	warning_text = "We are under attack by the Space Hobo Federation!"
	attacker_types = list(/mob/living/carbon/human/biker)
	original_size = 3
	original_bosses = 0
	is_abstract = 0

/datum/construction_event/siege/martian
	name = "Martian Siege"
	warning_text = "We are under attack by a martian siege force!"
	attacker_types = list(/obj/critter/martian/warrior, /obj/critter/martian/soldier)
	bosses = list(/obj/critter/martian/psychic/weak, /obj/critter/martian/sapper)
	original_size = 20
	original_bosses = 2
	is_abstract = 0

/datum/construction_event/siege/spirits
	name = "Spirit Siege"
	warning_text = "We are under siege from a dimensional fissure!"
	attacker_types = list(/obj/critter/spirit)
	bosses = list(/obj/critter/aberration)
	method = METHOD_SPAWN
	original_size = 15
	original_bosses = 1
	is_abstract = 0

/datum/construction_event/siege/animals
	name = "Animal Siege"
	warning_text = "A pack of animals have been teleported on board our station!"
	attacker_types = list(/obj/critter/wasp, /mob/living/critter/small_animal/mouse, /obj/critter/goose, /obj/critter/goose/swan, /obj/critter/owl, /obj/critter/bat/buff, /obj/critter/cat, /mob/living/critter/spider/nice, /mob/living/critter/spider/spacerachnid)
	bosses = list(/obj/critter/lion, /obj/critter/bear)
	original_size = 30
	original_bosses = 5
	is_abstract = 0

/datum/construction_event/siege/plants
	name = "Plant Siege"
	warning_text = "We are under attack by a group of sentient vegetables!"
	attacker_types = list(/obj/critter/killertomato)
	bosses = list(/obj/critter/maneater)
	original_size = 30
	original_bosses = 1
	is_abstract = 0

/datum/construction_event/siege/drones
	name = "Drone Siege"
	event_type = "Syndicate Siege"
	warning_text = "We are under siege from a small drone force!"
	attacker_types = list(/obj/critter/gunbot/drone)
	bosses = list(/obj/critter/gunbot/drone/buzzdrone)
	original_size = 8
	original_bosses = 1
	is_abstract = 0
	method = METHOD_EDGE_WANDER

/datum/construction_event/siege/drones_buzz
	name = "Buzz Drone Siege"
	event_type = "Syndicate Siege"
	warning_text = "We are under siege from a small drone force!"
	attacker_types = list(/obj/critter/gunbot/drone/buzzdrone)
	bosses = list(/obj/critter/gunbot/drone/buzzdrone)
	milestone = /datum/progress/pods/tier1
	original_size = 6
	original_bosses = 1
	is_abstract = 0
	method = METHOD_EDGE_WANDER

/datum/construction_event/siege/drones_heavy
	name = "Heavy Drone Siege"
	event_type = "Syndicate Siege"
	warning_text = "We are under siege from a small drone force!"
	attacker_types = list(/obj/critter/gunbot/drone/buzzdrone)
	bosses = list(/obj/critter/gunbot/drone/heavydrone)
	milestone = /datum/progress/pods/tier2
	original_size = 6
	original_bosses = 1
	is_abstract = 0
	method = METHOD_EDGE_WANDER

/datum/construction_event/meteors
	warning_text = "The meteor shower has reached the station."
	var/early_warning_original = "Chunks from a nearby asteroid collision are headed towards the station"
	event_type = "Cosmic Anomaly"

	var/direction = 0
	var/x_min = 0
	var/x_max = 0
	var/y_min = 0
	var/y_max = 0
	var/turf/around = null
	is_abstract = 1

	early_warning()
		direction = rand(1,4)
		switch (direction)
			if (1)
				early_warning_text = "[early_warning_original] from the north!"
			if (2)
				early_warning_text = "[early_warning_original] from the south!"
			if (3)
				early_warning_text = "[early_warning_original] from the east!"
			if (4)
				early_warning_text = "[early_warning_original] from the west!"
		..()

	set_up()
		..()
		player_modifier -= 1

		var/area/shuttle/arrival/station/A = locate() in world
		around = A.find_middle(0)
		if (!around)
			around = locate(150, 150, 1)
		switch(direction)
			if (1)
				x_min = 50
				x_max = 250
				y_min = 295
				y_max = 297
			if (2)
				x_min = 50
				x_max = 250
				y_min = 3
				y_max = 5
			if (3)
				x_min = 295
				x_max = 297
				y_min = 50
				y_max = 250
			if (4)
				x_min = 3
				x_max = 5
				y_min = 50
				y_max = 250

	process()
		if (prob(20 * player_modifier * time_modifier))
			var/turf/target = null
			var/retries = 0
			do
				if (retries > 5)
					return
				target = pick(range(50, around))
				retries++
			while (!target)
			if (!isturf(target))
				target = get_turf(target)
			if (!target)
				return
			create_meteor(locate(rand(x_min, x_max), rand(y_min, y_max), 1), target)

	proc/create_meteor(var/turf/from, var/turf/target)
		return

/datum/construction_event/meteors/small_meteor_storm
	name = "Small Meteor Shower"
	early_warning_original = "Chunks from a nearby asteroid collision are headed towards the station"
	is_abstract = 0

	create_meteor(var/turf/from, var/turf/target)
		new /obj/newmeteor/small(from, target)

/datum/construction_event/meteors/medium_meteor_storm
	name = "Medium Meteor Shower"
	milestone = /datum/progress/time/twohours
	early_warning_original = "Chunks from a nearby microplanet collision are headed towards the station"
	is_abstract = 0

	create_meteor(var/turf/from, var/turf/target)
		if (prob(80))
			new /obj/newmeteor/small(from, target)
		else
			new /obj/newmeteor/massive(from, target)

/datum/construction_event/meteors/massive_meteor_storm
	name = "Large Meteor Shower"
	milestone = /datum/progress/time/sixhours
	early_warning_original = "Chunks from a nearby planetary collision are headed towards the station"
	is_abstract = 0

	create_meteor(var/turf/from, var/turf/target)
		if (prob(30))
			new /obj/newmeteor/small(from, target)
		else
			new /obj/newmeteor/massive(from, target)

/datum/construction_event/radiation_storm
	name = "Radiation Storm"
	early_warning_text = "A large wave of radiation is approaching the station."
	warning_text = "The radiation wave is hitting the station!"
	event_type = "Cosmic Anomaly"
	is_abstract = 0

	var/sound/radsound = 'sound/weapons/ACgun2.ogg'
	var/list/possible_target_turfs = list()

	set_up()
		..()
		possible_target_turfs.len = 0
		var/area/shuttle/arrival/station/A = locate() in world
		var/turf/Q = A.find_middle(0)
		for (var/turf/simulated/floor/F in range(50, Q))
			if (!(F in A))
				possible_target_turfs += F

	process()
		if (prob(40))
			var/turf/target = pick(possible_target_turfs)
			if (!target)
				possible_target_turfs -= target
				return
			new /obj/anomaly/radioactive_burst(target,rand(30,70))

/proc/trigger_construction_event()
	if (!ticker)
		return
	if (!ticker.mode)
		return
	if (!istype(ticker.mode, /datum/game_mode/construction))
		return
	var/datum/game_mode/construction/C = ticker.mode
	var/datum/construction_controller/E = C.events
	E.event_delay = 1
	E.process()
	E.choose_at = 1
	E.process()
	E.next_event_at = 1
	E.process()

/proc/trigger_specific_construction_event()
	if (!ticker)
		return
	if (!ticker.mode)
		return
	if (!istype(ticker.mode, /datum/game_mode/construction))
		return
	var/datum/game_mode/construction/C = ticker.mode
	var/datum/construction_controller/E = C.events
	var/datum/construction_event/EV = input("Which event", "Event", null) in E.all_events
	E.event_delay = 1
	E.process()
	E.next_event_type = EV.type
	E.choose_at = 1
	E.process()
	E.next_event = EV
	E.next_event_at = 1
	E.process()
