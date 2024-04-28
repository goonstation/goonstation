/datum/unit_test/bioeffect_id_uniqueness/Run()
	var/list/ids = list()
	for(var/effect in concrete_typesof(/datum/bioEffect))
		var/datum/bioEffect/BE = effect
		var/id = initial(BE.id)
		if(!istext(id))
			Fail("Bioeffect [BE] has non-text id: [id]")
		if(ids[id])
			Fail("Bioeffect id [id] has multiple associated bioeffects: [ids[id]] and [BE].")
		else
			ids[id] = effect
