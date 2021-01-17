/datum/random_event/major/locker_entanglement
	name = "Locker Entanglement"
	centcom_headline = "Quantum Anomaly"
	centcom_message = {"A quantum anomaly has been detected on station. Locker dimensional subspaces might have become unstable. Enter lockers at your own risk."}
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
		var/n_closets = 0
		for_by_tcl(closet, /obj/storage/closet)
			if(isrestrictedz(closet.z) || istype(closet, /obj/storage/closet/port_a_sci))
				continue
			closets += closet
			n_closets++
		for(var/i = 1, i < n_closets, i+=2)
			var/obj/storage/A = pick(closets)
			var/obj/storage/B = pick(closets)
			closets -= A
			closets -= B
			A.entangled = B
			B.entangled = A

		if(isnull(src.time))
			src.time = rand(1 MINUTE, 5 MINUTES)
		SPAWN_DBG(src.time)
			for(var/obj/storage/closet/closet as() in closets)
				closet.entangled = null
			command_alert("Locker quantum stability restored.", src.centcom_headline)
