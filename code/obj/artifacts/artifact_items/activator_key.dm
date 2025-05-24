/obj/item/artifact/activator_key
	// can activate any artifact simply by smacking it. very very rare
	name = "artifact activator key"
	associated_datum = /datum/artifact/activator_key

/datum/artifact/activator_key
	associated_object = /obj/item/artifact/activator_key
	type_name = "Activator Key"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 200
	validtypes = list("lattice")
	automatic_activation = 1
	react_xray = list(12,80,95,8,"COMPLEX")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."
	var/universal = 0 // normally it only activates its own type, but sometimes it can do all
	var/activator = 1 // can also be a DEactivator key sometimes!
	var/corrupting = 0 // generates faults in activated artifacts
	var/activating_origin

	post_setup()
		. = ..()
		src.activating_origin = pick(list("ancient", "martian", "wizard", "eldritch", "precursor"))
		if (prob(33))
			src.universal = 1
		if (src.activating_origin == "eldritch")
			corrupting = 1
