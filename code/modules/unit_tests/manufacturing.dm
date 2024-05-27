/// This is for making sure that every manufacturing requirement
/// Has a unique ID for use in the cache. Fails if any ids collide
/datum/unit_test/manufacturing_requirement_id_uniqueness

/datum/unit_test/manufacturing_requirement_id_uniqueness/Run()
	var/list/ids = list()
	for(var/datum/manufacturing_requirement/R in requirement_cache)
		var/id = R.id
		if(!istext(id))
			Fail("Manufacturing requirement [R.type] has non-text id: [id]")
		if(ids[id])
			Fail("manufacturing requirement id [id] has multiple associated requirements: [ids[id]] and [R.type].")
		else
			ids[id] = requirement

/// This is for making sure that every manufacturer's blueprint and every
/// Mechanic blueprint can be produced. Fails if it runtimes
/datum/unit_test/blueprint_sanity_check

/datum/unit_test/blueprint_sanity_check/Run()
	var/blueprints = concrete_typesof(/datum/manufacture)

	for (var/blueprint as anything in blueprints)
		var/datum/manufacture/M = new blueprint

		for (var/requirement in M.item_requirements)
			if (isnull(requirement))
				Fail("[M.name]/[M.type] has null requirement in list")
			if (!istype(requirement, /datum/manufacturing_requirement))
				Fail("[M.name]/[M.type] has requirement which is not instantiated or not of /datum/manufacturing_requirement")
			if (!isnum(M.item_requirements[requirement]))
				Fail("[M.name]/[M.type] has non-numeric amount requirement in list")

		if (length(M.item_requirements) != length(M.item_names))
			Fail("[M.name]/[M.type] item names list does not match item requirements list length")
		if (!M.item_outputs.len)
			Fail("[M.name]/[M.type] schematic output list has no contents")
