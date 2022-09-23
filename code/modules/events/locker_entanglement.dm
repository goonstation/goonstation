/datum/random_event/major/locker_entanglement
	name = "Locker Entanglement"
	centcom_headline = "Quantum Anomaly"
	centcom_message = {"A quantum anomaly has been detected on station. Locker dimensional subspaces might have become unstable. Enter lockers at your own risk."}
	centcom_origin = ALERT_ANOMALY
	weight = 20
	var/time = null

	admin_call(var/source)
		if (..())
			return

		src.time = input(usr, "Remove entanglement after some number of deciseconds?", src.name, 0) as num|null

		event_effect(source)

	event_effect()
		..()
		var/list/closets = list()
		for_by_tcl(closet, /obj/storage/closet)
			var/area/area = get_area(closet)
			if(isrestrictedz(closet.z) || istype(closet, /obj/storage/closet/port_a_sci) || istype(area, /area/listeningpost))
				continue
			closets += closet
		shuffle_list(closets)
		for(var/i = 1, i < length(closets), i+=2)
			var/obj/storage/A = closets[i]
			var/obj/storage/B = closets[i + 1]
			A.entangled = B
			B.entangled = A

		if(isnull(src.time))
			src.time = rand(1 MINUTE, 5 MINUTES)
		SPAWN(src.time)
			for(var/obj/storage/closet/closet as anything in closets)
				closet.entangled = null
			command_alert("Locker quantum stability restored.", src.centcom_headline)
