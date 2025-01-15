/obj/item/artifact/activator_key
	// can activate any artifact simply by smacking it. very very rare
	name = "artifact activator key"
	associated_datum = /datum/artifact/activator_key

/datum/artifact/activator_key
	associated_object = /obj/item/artifact/activator_key
	type_name = "Activator Key"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 200
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	automatic_activation = 1
	react_xray = list(12,80,95,8,"COMPLEX")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."
	shard_reward = ARTIFACT_SHARD_OMNI
	combine_flags = ARTIFACT_DOES_NOT_COMBINE
	var/universal = 0 // normally it only activates its own type, but sometimes it can do all
	var/activator = 1 // can also be a DEactivator key sometimes!
	var/corrupting = 0 // generates faults in activated artifacts

	post_setup()
		. = ..()
		if (prob(33))
			src.universal = 1
		if (src.artitype.name == "eldritch")
			corrupting = 1
