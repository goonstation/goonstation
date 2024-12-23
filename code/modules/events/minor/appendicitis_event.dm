/datum/random_event/minor/appendicitis
	name = "Appendicitis Contraction"
	centcom_headline = "Medical Records Notice"
	centcom_message = "The NanoTrasen Personnel Records Department has informed us that some crew members have genetic indicators of increased Appendicitis risk and should seek medical care before their condition worsens."
	weight = 10

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
			if (!H.organHolder?.appendix) continue // with appendix
			if (H.organHolder?.appendix?.robotic) continue // that isn't robotic
			potential_victims += H
		if (length(potential_victims))
			var/num = rand(2, 4)
			for (var/i in 1 to num)
				if (!length(potential_victims))
					break
				var/mob/living/carbon/human/patient = pick(potential_victims)
				potential_victims -= patient
				patient?.contract_disease(/datum/ailment/disease/appendicitis, null, null, 1)
