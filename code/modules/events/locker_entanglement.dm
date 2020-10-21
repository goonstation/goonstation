/datum/random_event/major/locker_entanglement
	name = "Locker Entanglement"
	centcom_headline = "Quantum Anomaly"
	centcom_message = {"A quantum anomaly has been detected on station. Locker dimensional subspaces might have become unstable. Enter lockers at your own risk."}
	disabled = !ASS_JAM

	event_effect()
		..()
		var/list/closets = list()
		var/n_closets = 0
		for_by_tcl(closet, /obj/storage/closet)
			if(isrestrictedz(closet.z))
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
