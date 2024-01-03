/datum/unit_test/action_id_uniqueness/Run()
	var/list/ids = list()
	for(var/action in concrete_typesof(/datum/action))
		var/datum/action/A = action
		var/id = initial(A.id)
		//ignore null ids as they are generated at runtime
		if(isnull(id))
			continue
		if(ids[id])
			Fail("Action id [id] has multiple associated action: [ids[id]] and [A].")
		else
			ids[id] = action
