/datum/random_event/minor/appendicitis
	name = "Appendicitis Contraction"
	centcom_headline = "Medical Data Inbound"
	centcom_message = "The NanoTrasen Personnel Records Department has informed us that some crew members have the genetic indicators that they will very likely contract Appendicitis, they should report to medbay before their condition worsens."
	weight = 10

	event_effect(var/source)
		..()
		var/list/potential_victims = list()
		for (var/mob/living/carbon/human/H in mobs)
			if (H.stat == 2)
				continue
			potential_victims += H
		if (potential_victims.len)
			var/num = rand(2, 4)
			for (var/i = 0, i < num, i++)
				var/mob/living/carbon/human/patient = pick(potential_victims)
				if (!(isnpcmonkey(patient)) && patient.organHolder && patient.organHolder.appendix && !patient.organHolder.appendix.robotic)
					patient.contract_disease(/datum/ailment/disease/appendicitis,null,null,1)
