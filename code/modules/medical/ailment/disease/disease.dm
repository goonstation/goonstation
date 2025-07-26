ABSTRACT_TYPE(/datum/ailment/disease)
/datum/ailment/disease
	name = "Disease"
	scantype = "Virus"
	cure_flags = CURE_UNKNOWN
	strain_type = /datum/ailment_data/disease
	high_temeprature_cure = 406
	var/virulence = 100
	var/develop_resist = 0
	var/associated_reagent = null // associated reagent, duh

	setup_strain()
		var/datum/ailment_data/disease/strain = ..()
		if (prob(5) && src.can_be_asymptomatic)
			strain.state = AILMENT_STATE_ASYMPTOMATIC
			// carrier - will spread it but won't suffer from it
		strain.virulence = src.virulence
		strain.develop_resist = src.develop_resist
		return strain

/datum/ailment_data/disease
	var/virulence = 100    // how likely is this disease to spread
	var/develop_resist = 0 // can you develop a resistance to this?
	var/list/strain_data = list()  // Used for Rhinovirus, basically arbitrary data storage

	copy_other(datum/ailment_data/disease/other)
		..()
		src.virulence = other.virulence
		src.develop_resist = other.develop_resist
		src.strain_data = other.strain_data.Copy() //hopefully this is good enough?

	disposing()
		strain_data = null
		..()
