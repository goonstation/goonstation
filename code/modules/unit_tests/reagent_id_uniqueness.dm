/datum/unit_test/reagent_id_uniqueness/Run()
	var/list/ids = list()
	for(var/reagent in concrete_typesof(/datum/reagent))
		var/datum/reagent/R = reagent
		var/id = initial(R.id)
		if(!istext(id))
			Fail("Reagent [R] has non-text id: [id]")
		if(ids[id])
			Fail("Reagent id [id] has multiple associated reagents: [ids[id]] and [R].")
		else
			ids[id] = reagent
