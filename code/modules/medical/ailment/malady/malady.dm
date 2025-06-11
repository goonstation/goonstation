ABSTRACT_TYPE(/datum/ailment/malady)
/datum/ailment/malady
	name = "Malady"
	scantype = "Malady"
	cure_flags = CURE_UNKNOWN
	strain_type = /datum/ailment_data/malady

/datum/ailment_data/malady
	var/robo_restart = 0 // used for cyberheart stuff
	var/affected_area = null // used for bloodclots, can be chest (heart, eventually lung), head (brain), limb

	copy_other(datum/ailment_data/malady/other)
		..()
		src.affected_area = other.affected_area

	New()
		..()
		master = get_disease_from_path(/datum/ailment/malady)
