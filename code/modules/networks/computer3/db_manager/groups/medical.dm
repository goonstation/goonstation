/datum/db_record_group/medical
	search_input_prompt = "Please enter target name, ID, DNA, rank, or fingerprint:"
	field_data = alist(
		"gen" = list(
			alist(key = "name",			write = TRUE,	search = TRUE),
			alist(key = "id",			write = FALSE,	search = TRUE),
			alist(key = "full_name",	write = TRUE,	search = FALSE),
			alist(key = "sex",			write = TRUE,	search = FALSE),
			alist(key = "pronouns",		write = TRUE,	search = FALSE),
			alist(key = "age",			write = TRUE,	search = FALSE),
			alist(key = "rank",			write = FALSE,	search = TRUE),
			alist(key = "fprint_r",		write = TRUE,	search = TRUE),
			alist(key = "fprint_l",		write = TRUE,	search = TRUE),
			alist(key = "dna",			write = TRUE,	search = TRUE),
			alist(key = "photo",		write = FALSE,	search = FALSE),
			alist(key = "p_stat",		write = TRUE,	search = FALSE),
			alist(key = "m_stat",		write = TRUE,	search = FALSE),
		),
		"med" = list(
			alist(key = "h_imp",		write = FALSE,	search = FALSE),
			alist(key = "blood_type",	write = TRUE,	search = FALSE),
			alist(key = "mi_dis",		write = TRUE,	search = FALSE),
			alist(key = "mi_dis_d",		write = TRUE,	search = FALSE),
			alist(key = "ma_dis",		write = TRUE,	search = FALSE),
			alist(key = "ma_dis_d",		write = TRUE,	search = FALSE),
			alist(key = "alg",			write = TRUE,	search = FALSE),
			alist(key = "alg_d",		write = TRUE,	search = FALSE),
			alist(key = "cdi",			write = TRUE,	search = FALSE),
			alist(key = "cdi_d",		write = TRUE,	search = FALSE),
			alist(key = "cl_def",		write = TRUE,	search = FALSE),
			alist(key = "cl_def_d",		write = TRUE,	search = FALSE),
			alist(key = "notes",		write = TRUE,	search = FALSE),
		),
	)

/datum/db_record_group/medical/get_main_database()
	return global.data_core.general

/datum/db_record_group/medical/get_all_databases()
	return alist(
		"gen" = global.data_core.general,
		"med" = global.data_core.medical,
	)
