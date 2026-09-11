/datum/random_event/minor/third_shift_syndrome
	name = "Third Shift Syndrome"

	event_effect()
		..()
		var/list/potential_victims = list()

		for_by_tcl(H, /mob/living/carbon/human) //stolen from appendicitis
			if (isdead(H)) continue
			if (isnpc(H)) continue
			if (isvirtual(H)) continue
			if (inafterlife(H)) continue
			var/datum/db_record/record = data_core.general.find_record("name", H.real_name)
			if (!record || record["pstat"] == "*Deceased*") continue
			if (istype(H.loc, /obj/cryotron)) continue
			potential_victims += H

		if (!length(potential_victims))
			return

		var/target_count = max(1, ceil(length(potential_victims) * 0.1))
		for (var/i in 1 to target_count)
			var/mob/living/carbon/human/patient = pick(potential_victims)
			potential_victims -= patient
			patient.contract_disease(/datum/ailment/disease/third_shift_syndrome, null, null, TRUE)
