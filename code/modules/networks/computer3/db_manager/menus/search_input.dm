/datum/db_manager_menu/search_input

/datum/db_manager_menu/search_input/load()
	src.parent.print_text(src.parent.current_record_group.search_input_prompt)

/datum/db_manager_menu/search_input/input_text(text)
	var/search_text = ckey(strip_html(text))
	if (!search_text)
		return

	var/datum/record_database/main_database = src.parent.current_record_group.get_main_database()
	var/alist/databases = src.parent.current_record_group.get_all_databases()

	var/list/datum/db_record/results = list()
	for (var/datum/db_record/record as anything in main_database.records)
		var/record_id = record["id"]
		var/haystack = ""
		for (var/db_id as anything in src.parent.current_record_group.keys_to_search_by_db)
			var/datum/record_database/db = databases[db_id]
			var/datum/db_record/R = db.find_record("id", record_id)
			if (!istype(R))
				continue

			for (var/key as anything in src.parent.current_record_group.keys_to_search_by_db[db_id])
				haystack += ckey(R[key]) + " "

		if (findtext(haystack, search_text))
			results += record

	switch (length(results))
		if (0)
			src.parent.print_text("No results found.")
			src.wait(2 SECONDS)
			src.parent.switch_menu_to("main")
		if (1)
			src.parent.switch_menu_to("record_view", results[1]["id"])
		else
			src.parent.switch_menu_to("search_results", text, results)
