/datum/random_event/start/poisoning
	name = "Food Poisoning"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()
		var/list/potential_victims = list()

		for_by_tcl(H, /mob/living/carbon/human)
			if (isdead(H)) continue // alive
			if (isnpc(H)) continue // player
			if (isvirtual(H)) continue
			if (inafterlife(H)) continue
			var/datum/db_record/record = data_core.general.find_record("name", H.real_name)
			if (!record || record["pstat"] == "*Deceased*") continue
			if (istype(H.loc, /obj/cryotron)) continue
			potential_victims += H
		if (length(potential_victims))
			var/num = rand(1, 8)
			for (var/i in 1 to num)
				if (!length(potential_victims))
					break
				var/mob/living/carbon/human/patient = pick(potential_victims)
				potential_victims -= patient
				patient?.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1)
