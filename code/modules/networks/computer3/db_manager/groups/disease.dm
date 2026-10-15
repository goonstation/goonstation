/datum/db_record_group/disease
	search_input_prompt = ""
	can_add_and_remove_records = FALSE
	field_data = alist(
		"dis" = list(
			alist(key = "name",			write = FALSE,	search = FALSE),
			alist(key = "stages",		write = FALSE,	search = FALSE),
			alist(key = "spread",		write = FALSE,	search = FALSE),
			alist(key = "cure",			write = FALSE,	search = FALSE),
			alist(key = "affected",		write = FALSE,	search = FALSE),
			alist(key = "severity",		write = FALSE,	search = FALSE),
			alist(key = "notes",		write = FALSE,	search = FALSE),
		),
	)

/datum/db_record_group/disease/get_main_database()
	return global.data_core.disease

/datum/db_record_group/disease/get_all_databases()
	return alist(
		"dis" = global.data_core.disease,
	)
