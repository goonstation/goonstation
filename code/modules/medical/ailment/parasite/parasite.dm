ABSTRACT_TYPE(/datum/ailment/parasite)
/datum/ailment/parasite
	name = "Parasite"
	scantype = "Parasite"
	cure_flags = CURE_SURGERY
	strain_type = /datum/ailment_data/parasite

/datum/ailment_data/parasite
	var/surgery_prob = 50
	var/mob/living/critter/changeling/headspider/source = null // for headspiders

	copy_other(datum/ailment_data/parasite/other)
		..()
		src.surgery_prob = other.surgery_prob
