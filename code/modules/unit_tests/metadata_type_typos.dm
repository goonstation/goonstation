/datum/unit_test/metadata_type_typos

/datum/unit_test/metadata_type_typos/proc/check_type(base_type, name)
	var/base_type_len = length("[base_type]")
	for(var/decl in childrentypesof(base_type))
		var/the_type = text2path(copytext("[decl]", base_type_len + 1))
		if(!ispath(the_type))
			Fail("[name] [decl] does not mark a valid type.")


/datum/unit_test/metadata_type_typos/Run()
	check_type(/_is_abstract, "Abstract type")
	check_type(/typeinfo, "Typeinfo")

