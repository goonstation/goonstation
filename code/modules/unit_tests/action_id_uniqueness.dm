/datum/unit_test/action_id_uniqueness/Run()
	var/list/ids = list()
	for(var/action in concrete_typesof(/datum/action))
		var/datum/action/A = new action
		var/id = initial(A.id)
		if(isnull(id))
			continue
		LAZYLISTADD(ids[id], action)

	for(var/id in ids)
		if(length(ids[id]) > 1)
			Fail("action id [id] has multiple associated action: [json_encode(ids[id])].")