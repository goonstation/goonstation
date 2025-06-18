/datum/progress
	var/name = "Milestone"
	var/list/required = list()
	var/requirements_cache = null

	var/is_room = 0
	var/minimum_width = 0
	var/minimum_height = 0
	var/room_area = null

	var/announce_completion = 0
	var/announced_message = ""
	var/announce_uncompletion = 0
	var/uncompleted_message = ""

	var/completed = 0

	var/can_uncomplete = 0
	var/uncompletion = 0
	var/uncompleted_at = 0
	var/grace_period = 0
	var/periodical_check = 0
	var/datum/progress/parent = null

	var/is_abstract = 1

	var/list/completed_space = list()
	var/turf/completed_origin = null

	New()
		..()
		for (var/objt in required)
			var/obj/O = locate(objt)
			var/needs_deletion = 0
			if (!O)
				O = new objt(null)
				needs_deletion = 1
			var/req_string
			if (requirements_cache)
				req_string = ", [required[objt]] [O]"
			else
				req_string = "[required[objt]] [O]"
				requirements_cache = ""
			requirements_cache += req_string
			if (needs_deletion)
				qdel(O)

	proc/announce()
		if (announce_completion)
			boutput(world, "<B><font color='blue'>[announced_message]</font></B>")

	proc/set_complete()
		completed = 1
		logTheThing(LOG_DEBUG, null, "<B>Marquesas/Progress</B>: Milestone [name] complete.")
		var/datum/game_mode/construction/C = ticker.mode
		C.events.notify_milestone_complete(src)

	proc/uncomplete()
		if (is_room && room_area)
			var/area/AR = locate(room_area)
			for (var/turf/T in AR)
				new /area(T)
		if (announce_uncompletion)
			boutput(world, "<B><font color='red'>[uncompleted_message]</font></B>")
		var/datum/game_mode/construction/C = ticker.mode
		C.events.notify_milestone_uncomplete(src)
		logTheThing(LOG_DEBUG, null, "<B>Marquesas/Progress</B>: Milestone [name] uncompleted.")

	proc/check_uncompletion()
		if (is_abstract)
			return
		if (parent)
			if (completed && !parent.completed)
				uncomplete()
		if (!can_uncomplete)
			return
		var/is_complete = check_completion(completed_origin)
		if (completed && !uncompletion && !is_complete)
			uncompletion = 1
			uncompleted_at = ticker.round_elapsed_ticks
			logTheThing(LOG_DEBUG, null, "<B>Marquesas/Progress</B>: Milestone [name] uncompleting.")
		else if (completed && uncompletion && is_complete)
			uncompletion = 0
		else if (completed && uncompletion && ticker.round_elapsed_ticks > uncompleted_at + grace_period)
			completed = 0
			uncompletion = 0
			uncomplete()

	proc/check_completion(var/turf/T)
		if (is_abstract)
			return
		if (parent)
			if (!parent.completed)
				return
		if (!required.len)
			return 1
		if (istype(get_area(T), /area/shuttle))
			return 0
		if (is_room)
			var/list/temp = identify_room(T)
			var/minx = 300
			var/maxx = 0
			var/miny = 300
			var/maxy = 0
			if (temp)
				var/list/counted = list()
				for (var/objt in required)
					counted += objt
					counted[objt] = 0
				for (var/turf/Q in temp)
					if (minx > Q.x)
						minx = Q.x
					if (maxx < Q.x)
						maxx = Q.x
					if (miny > Q.y)
						miny = Q.y
					if (maxy < Q.y)
						maxy = Q.y
					for (var/atom/movable/O in Q)
						if (O.type in counted)
							counted[O.type]++
				for (var/objt in required)
					if (required[objt] > counted[objt])
						return 0
				if (maxx - minx + 1 < minimum_width)
					return 0
				if (maxy - miny + 1 < minimum_height)
					return 0
				if (!completed)
					completed_space = temp
					completed_origin = T
					set_complete()
					if (room_area)
						var/datum/game_mode/construction/CN = ticker.mode
						for (var/turf/Q in completed_space)
							var/area/AR = get_area(Q)
							if (AR.type != room_area)
								if (AR.type in CN.assigned_areas)
									var/datum/progress/assigned_progress = CN.assigned_areas[AR.type]
									if (assigned_progress.completed)
										assigned_progress.uncomplete()
								if (!istype(AR, /area/shuttle))
									new room_area(Q)
									if (!(room_area in CN.assigned_areas))
										CN.assigned_areas += room_area
										CN.assigned_areas[room_area] = src
					announce()
				return 1
			else
				return 0
		else
			var/list/counted = list()
			for (var/objt in required)
				counted += objt
				counted[objt] = 0
			for (var/atom/movable/O in world)
				LAGCHECK(LAG_LOW)
				if (O.type in counted)
					counted[O.type]++
			for (var/objt in required)
				if (required[objt] > counted[objt])
					return 0
			if (!completed)
				completed_origin = T
				set_complete()
				announce()
			return 1

	proc/identify_room(var/turf/T)
		var/list/affected = list()
		var/list/next = list()
		var/list/processed = list()

		next += T
		processed += T
		while (next.len)
			var/turf/C = next[1]
			next -= C

			affected += C

			if (C.density)
				continue

			var/dense = 0
			for (var/obj/O in C)
				if (istype(O, /obj/machinery/door) || istype(O, /obj/mesh/grille) || istype(O, /obj/window) || istype(O, /obj/table))
					dense = 1
					break
			if (dense)
				continue

			/*var/area/SP = get_area(C)
			if (SP.name != "Space") // i mean i can't just check for istype(SP, /area)
				return null*/

			if (istype(C, /turf/space))
				return null

			var/turf/N = get_step(C, NORTH)
			if (N && !(N in processed))
				next += N
				processed += N

			N = get_step(C, SOUTH)
			if (N && !(N in processed))
				next += N
				processed += N

			N = get_step(C, WEST)
			if (N && !(N in processed))
				next += N
				processed += N

			N = get_step(C, EAST)
			if (N && !(N in processed))
				next += N
				processed += N

		return affected

	proc/process()
		if (!periodical_check)
			return
		if (!completed)
			check_completion(null)
		else
			check_uncompletion()

/datum/progress/time
	periodical_check = 1
	var/elapsed_ticks = 1
	announce_completion = 1

	check_completion(var/turf/T)
		var/datum/game_mode/construction/C = ticker.mode
		if (ticker.round_elapsed_ticks - C.starttime >= elapsed_ticks)
			announce()
			set_complete()

/datum/progress/time/twohours
	elapsed_ticks = 90000
	is_abstract = 0
	name = "2 Hours"
	announced_message = "<B>10 hours left until construction reset.</B>"

/datum/progress/time/sixhours
	elapsed_ticks = 234000
	is_abstract = 0
	name = "6 Hours"
	announced_message = "<B>6 hours left until construction reset.</B>"

/datum/progress/time/ninehours
	elapsed_ticks = 342000
	is_abstract = 0
	name = "9 Hours"
	announced_message = "<B>3 hours left until construction reset.</B>"

/datum/progress/time/tenhours
	elapsed_ticks = 378000
	is_abstract = 0
	name = "10 Hours"
	announced_message = "<B>2 hours left until construction reset.</B>"

/datum/progress/time/elevenhours
	elapsed_ticks = 414000
	is_abstract = 0
	name = "11 Hours"
	announced_message = "<B>1 hours left until construction reset.</B>"

/datum/progress/time/almostover
	elapsed_ticks = 432000
	is_abstract = 0
	name = "11 Hours and 30 Minutes"
	announced_message = "<B>30 minutes left until construction reset.</B>"

/datum/progress/time/almostoverreally
	elapsed_ticks = 444000
	is_abstract = 0
	name = "11 Hours and 50 Minutes"
	announced_message = "<B>10 minutes left until construction reset.</B>"

/datum/progress/pods
	can_uncomplete = 1
	periodical_check = 1
	grace_period = 1800
	var/pod_score_required = 0

	check_completion(var/turf/T)
		if (parent)
			if (!parent.completed)
				return
		var/pod_score = 0
		for (var/obj/machinery/vehicle/pod_smooth/P in world)
			LAGCHECK(LAG_LOW)
			var/score = 0
			var/multiplier = P.armor_score_multiplier
			var/obj/item/shipcomponent/mainweapon/main_weapon = P.get_part(POD_PART_MAIN_WEAPON)
			if (main_weapon)
				score += main_weapon.weapon_score
			pod_score += score * multiplier
		for (var/obj/machinery/vehicle/miniputt/P in world)
			LAGCHECK(LAG_LOW)
			var/score = 0
			var/multiplier = P.armor_score_multiplier
			var/obj/item/shipcomponent/mainweapon/main_weapon = P.get_part(POD_PART_MAIN_WEAPON)
			if (main_weapon)
				score += main_weapon.weapon_score
			pod_score += score * multiplier * 0.5
		logTheThing(LOG_DEBUG, null, "<B>Marquesas/Progress</B>: Pod score is [pod_score].")
		if (pod_score >= pod_score_required)
			if (!completed)
				set_complete()
			return 1
		return 0

/datum/progress/pods/tier1
	name = "Pod Armaments Tier 1"
	is_abstract = 0
	pod_score_required = 1.7

/datum/progress/pods/tier2
	name = "Pod Armaments Tier 2"
	pod_score_required = 4.5
	is_abstract = 0
	parent = /datum/progress/pods/tier1

/datum/progress/pods/tier3
	name = "Pod Armaments Tier 3"
	pod_score_required = 9
	is_abstract = 0
	parent = /datum/progress/pods/tier2

/datum/progress/rooms
	is_room = 1
	can_uncomplete = 1
	announce_completion = 1
	grace_period = 600

/datum/progress/rooms/robotics
	name = "Robotics Lab"
	is_abstract = 0
	required = list(/obj/machinery/manufacturer/robotics = 1, /obj/machinery/optable = 1, /obj/machinery/recharge_station = 1)
	minimum_width = 7
	minimum_height = 7

	announced_message = "The station now has an operating Robotics lab."
	uncompleted_message = "The station no longer has an operation Robotics lab!"

	room_area = /area/station/medical/robotics

/datum/progress/rooms/genetics
	name = "Genetics Lab"
	is_abstract = 0
	required = list(/obj/machinery/computer/cloning = 1, /obj/machinery/computer/genetics = 1, /obj/machinery/genetics_scanner = 1, /obj/machinery/clone_scanner = 1, /obj/machinery/clonepod = 1, /obj/machinery/clonegrinder = 1)
	minimum_width = 7
	minimum_height = 7

	announced_message = "The station now has an operating Genetics lab."
	uncompleted_message = "The station no longer has an operation Genetics lab!"

	room_area = /area/station/medical/research

/datum/progress/rooms/chemistry
	name = "Chemistry Lab"
	is_abstract = 0
	required = list(/obj/machinery/chem_master = 2, /obj/machinery/chem_dispenser = 2, /obj/machinery/chem_heater = 2, /obj/submachine/chem_extractor = 1, /obj/machinery/vending/monkey = 1)
	minimum_width = 7
	minimum_height = 7

	announced_message = "The station now has an operating Chemistry lab."
	uncompleted_message = "The station no longer has an operation Chemistry lab!"

	room_area = /area/station/science/chemistry

/datum/progress/rooms/medbay
	name = "Medical Bay"
	is_abstract = 0
	required = list(/obj/machinery/optable = 1, /obj/machinery/vending/medical = 2)
	minimum_width = 9
	minimum_height = 9

	announced_message = "The station now has an operating Medical Bay. Additional supply kits are now available."
	uncompleted_message = "The station no longer has an operation Medical Bay! Related supply kits are no longer available."

	room_area = /area/station/medical/medbay

/datum/progress/rooms/mechanics
	name = "Mechanics Lab"
	is_abstract = 0
	required = list(/obj/machinery/rkit = 1, /obj/machinery/manufacturer/mechanic = 1, /obj/machinery/vending/mechanics = 1)
	minimum_width = 9
	minimum_height = 9

	announced_message = "The station now has an operating Mechanics lab."
	uncompleted_message = "The station no longer has an operation Mechanics lab!"

	room_area = /area/station/engine/elect

/datum/progress/rooms/aicore
	name = "AI Core"
	is_abstract = 0
	required = list(/mob/living/silicon/ai = 1, /obj/machinery/turret/construction = 2, /obj/machinery/turretid/computer = 1)
	minimum_width = 7
	minimum_height = 7

	announced_message = "The station now has an operating AI core."
	uncompleted_message = "The station no longer has an operation AI core!"

	room_area = /area/station/turret_protected/AIbasecore1

/datum/progress/rooms/cargo_bay
	name = "Cargo Bay"
	is_abstract = 0
	required = list(/obj/supply_pad/incoming = 1, /obj/supply_pad/outgoing = 1, /obj/machinery/computer/special_supply/commerce = 1, /obj/submachine/cargopad = 1)
	minimum_width = 11
	minimum_height = 11

	announced_message = "The station now has an operating Cargo Bay. Additional supply kits are now available."
	uncompleted_message = "The station no longer has an operation Cargo Bay! Related supply kits are no longer available."

	room_area = /area/station/quartermaster/office

/datum/progress/rooms/hydroponics
	name = "Hydroponics"
	is_abstract = 0
	required = list(/obj/machinery/plantpot = 6, /obj/machinery/vending/hydroponics = 1, /obj/submachine/chem_extractor = 1, /obj/submachine/seed_vendor = 1, /obj/submachine/seed_manipulator = 1)
	minimum_width = 9
	minimum_height = 9

	announced_message = "The station now has an operating Hydroponics lab."
	uncompleted_message = "The station no longer has an operation Hydroponics lab!"

	room_area = /area/station/hydroponics

