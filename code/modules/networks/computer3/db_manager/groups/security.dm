/datum/db_record_group/security
	search_input_prompt = "Please enter target name, ID, DNA, rank, fingerprint, or criminal status:"
	field_data = alist(
		"gen" = list(
			alist(key = "name",			write = TRUE,	search = TRUE),
			alist(key = "id",			write = FALSE,	search = TRUE),
			alist(key = "full_name",	write = TRUE,	search = FALSE),
			alist(key = "sex",			write = TRUE,	search = FALSE),
			alist(key = "pronouns",		write = TRUE,	search = FALSE),
			alist(key = "age",			write = TRUE,	search = FALSE),
			alist(key = "rank",			write = TRUE,	search = TRUE),
			alist(key = "fprint_r",		write = TRUE,	search = TRUE),
			alist(key = "fprint_l",		write = TRUE,	search = TRUE),
			alist(key = "dna",			write = FALSE,	search = TRUE),
			alist(key = "photo",		write = TRUE,	search = FALSE),
			alist(key = "p_stat",		write = FALSE,	search = FALSE),
			alist(key = "m_stat",		write = FALSE,	search = FALSE),
		),
		"sec" = list(
			alist(key = "criminal",		write = TRUE,	search = TRUE),
			alist(key = "sec_flag",		write = TRUE,	search = FALSE),
			alist(key = "mi_crim",		write = TRUE,	search = FALSE),
			alist(key = "mi_crim_d",	write = TRUE,	search = FALSE),
			alist(key = "ma_crim",		write = TRUE,	search = FALSE),
			alist(key = "ma_crim_d",	write = TRUE,	search = FALSE),
			alist(key = "notes",		write = TRUE,	search = FALSE),
		),
	)

/datum/db_record_group/security/get_main_database()
	return global.data_core.general

/datum/db_record_group/security/get_all_databases()
	return alist(
		"gen" = global.data_core.general,
		"sec" = global.data_core.security,
	)
