/datum/random_event/major/magnetic
	name = "Bio-Magnetic Field"
	centcom_headline = "Bio-Magnetic Field"
	centcom_message = {"Strong bio-magnetic fields have been detected manifesting on the station. Personnel are advised to avoid anybody charged with the opposite magnetic charge. The fields should dissipate within a few minutes."}
	centcom_origin = ALERT_ANOMALY
	var/list/positive_mobs = list()
	var/list/negative_mobs = list()
	var/list/eligible_mobs = list()

	event_effect()
		..()
		eligible_mobs = list()
		positive_mobs = list()
		negative_mobs = list()

		for (var/mob/living/carbon/human/H in mobs)
			if (isdead(H))
				continue
			if (!H.bioHolder || H.bioHolder.HasEffect("resist_electric") || H.traitHolder.hasTrait("unionized")) // a pun!
				continue
			eligible_mobs += H

		if (!eligible_mobs.len)
			message_admins("Magnetic random event could not find enough mobs to proceed")
			return

		var/division = round(eligible_mobs.len * 0.5)

		var/mob/living/carbon/human/selected = null
		while (division > 0)
			division--
			selected = pick(eligible_mobs)
			positive_mobs += selected
			eligible_mobs -= selected

		for (var/mob/living/carbon/human/H in eligible_mobs)
			negative_mobs += H
			eligible_mobs -= H

		SPAWN(5 SECONDS)
			var/duration = rand(2 MINUTES, 3 MINUTES)
			for (var/mob/living/carbon/human/H in positive_mobs)
				H.changeStatus("magnetized", duration, "magnets_pos")
			for (var/mob/living/carbon/human/H in negative_mobs)
				H.changeStatus("magnetized", duration, "magnets_neg")
