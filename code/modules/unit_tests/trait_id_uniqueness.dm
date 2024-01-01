/datum/unit_test/trait_id_uniqueness/Run()
	var/list/ids = list()
	for(var/trait in concrete_typesof(/datum/trait))
		var/datum/trait/T = trait
		var/id = initial(T.id)
		if(ids[id])
			Fail("Trait id [id] has multiple associated traits: [ids[id]] and [T].")
		else
			ids[id] = trait
