/datum/unit_test/job_name_uniqueness/Run()
	var/list/names = list()
	for(var/entry in concrete_typesof(/datum/job))
		var/datum/job/J = entry
		var/id = J::name
		if(id == null) continue
		if(names[id])
			Fail("Job name [id] has multiple associated jobs: [names[id]] and [J].")
		else
			names[id] = J
