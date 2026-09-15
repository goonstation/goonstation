/datum/db_record_group/bank
	search_input_prompt = "Please enter target name, ID, DNA, rank, or fingerprint:"
	field_data = alist(
		"gen" = list(
			alist(key = "name",			write = TRUE,	search = TRUE),
			alist(key = "id",			write = FALSE,	search = TRUE),
			alist(key = "full_name",	write = TRUE,	search = FALSE),
			alist(key = "sex",			write = TRUE,	search = FALSE),
			alist(key = "pronouns",		write = TRUE,	search = FALSE),
			alist(key = "age",			write = TRUE,	search = FALSE),
			alist(key = "rank",			write = TRUE,	search = TRUE),
			alist(key = "fprint_r",		write = FALSE,	search = TRUE),
			alist(key = "fprint_l",		write = FALSE,	search = TRUE),
			alist(key = "dna",			write = FALSE,	search = TRUE),
			alist(key = "photo",		write = FALSE,	search = FALSE),
			alist(key = "p_stat",		write = FALSE,	search = FALSE),
			alist(key = "m_stat",		write = FALSE,	search = FALSE),
		),
		"bnk" = list(
			alist(key = "wage",				write = TRUE,	search = FALSE),
			alist(key = "current_money",	write = TRUE,	search = FALSE),
			alist(key = "unionized",		write = FALSE,	search = FALSE),
			alist(key = "notes",			write = TRUE,	search = FALSE),
		),
	)

/datum/db_record_group/bank/get_main_database()
	return global.data_core.general

/datum/db_record_group/bank/get_all_databases()
	return alist(
		"gen" = global.data_core.general,
		"bnk" = global.data_core.bank,
	)
