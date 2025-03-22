ABSTRACT_TYPE(/datum/random_event/minor/fault)
/datum/random_event/minor/fault
	name = "Equipment Fault"
	disabled = TRUE
	var/minimum_engineer_count = 1

	is_event_available(var/ignore_time_lock)
		. = ..()

		if(.)
			var/engineering_count = 0
			for(var/datum/mind/mind as anything in ticker.minds)
				if (QDELETED(mind) || !mind.current)
					continue

				if ((mind.assigned_role in engineering_jobs) || (mind.assigned_role in engineering_gimmicks))
					engineering_count++
			. = engineering_count >= src.minimum_engineer_count

	proc/pda_msg(event_string, sender_name, group)

		var/datum/signal/signal = get_free_signal()
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = sender_name
		signal.data["group"] = group
		signal.data["message"] = "Notice: [event_string]"
		signal.data["sender"] = "00000000"
		signal.data["address_1"] = "00000000"

		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

	proc/build_fault_bits(required, list/pool, count)
		. = required

		if(islist(pool) && count)
			for(var/i in 1 to count)
				. = . | pick(pool)

/datum/random_event/minor/fault/camera
	name = "Camera Failure"

	event_effect(source, amount)
		..()

		if(!amount)
			amount = pick(2,4)

		var/obj/machinery/camera/C
		var/list/obj/machinery/camera/possible_cameras = list()
		for(var/i=1 to amount*3)
			C = pick(camnets["SS13"])

			if(istype(C, /obj/machinery/camera/television))
				continue
			else if (C.reinforced)
				continue
			else if (!C.camera_status)
				continue
			possible_cameras |= C

		var/areas = list()
		if(length(possible_cameras) >= amount)
			for(var/j=1 to amount)
				C = pick(possible_cameras)
				possible_cameras -= C
				C.set_camera_status(FALSE)
				elecflash(get_turf(C))
				areas += get_area(C)

			SPAWN(rand(30 SECONDS, 70 SECONDS))
				pda_msg( "Camera failure(s) detected.  Investigate: [jointext(areas, ", ")]", sender_name="CAMERA-DAEMON", group=list(MGO_AI, MGO_SILICON))


/datum/random_event/minor/fault/door
	name = "Door Failure"

	event_effect(source, amount)
		..()

		if(!amount)
			amount = pick(1,3)

		var/obj/machinery/door/airlock/D
		var/list/obj/machinery/door/airlock/possible_doors = list()

		for(var/i=1 to amount*3)
			D = pick(by_type[/obj/machinery/door/airlock])
			if(D.z != Z_LEVEL_STATION)
				continue
			if(istype(D, /obj/machinery/door/airlock/pyro/external))
				continue
			possible_doors |= D

		var/areas = list()
		if(length(possible_doors) >= amount)
			for(var/j=1 to amount)
				D = pick(possible_doors)
				possible_doors -= D

				D.AddComponent(/datum/component/equipment_fault/faulty_wiring, build_fault_bits(TOOL_PULSING, list(TOOL_CUTTING, TOOL_PRYING, TOOL_SCREWING, TOOL_WELDING, TOOL_WRENCHING), 2))
				areas += get_area(D)

			SPAWN(rand(30 SECONDS, 70 SECONDS))
				pda_msg( "Door failure(s) detected. Investigate: [jointext(areas, ", ")]", sender_name="EQUIPMENT-DAEMON", group=list(MGO_SILICON, MGD_STATIONREPAIR))
