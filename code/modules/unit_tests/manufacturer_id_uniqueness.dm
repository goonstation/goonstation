/datum/unit_test/material_id_uniqueness/Run()
	var/list/ids = list()
	for(var/requirement in concrete_typesof(/datum/manufacturing_requirement))
		var/datum/manufacturing_requirement/R = new requirement
		var/id = R.id
		if(!istext(id))
			Fail("Manufacturing requirement [R.type] has non-text id: [id]")
		if(ids[id])
			Fail("manufacturing requirement id [id] has multiple associated requirements: [ids[id]] and [R.type].")
		else
			ids[id] = requirement
