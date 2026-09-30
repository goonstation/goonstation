/datum/db_manager_menu/search_input

/datum/db_manager_menu/search_input/load()
	src.parent.print_text(src.parent.current_record_group.search_input_prompt)

/datum/db_manager_menu/search_input/input_text(text)
	var/search_text = ckey(strip_html(text))
	if (!search_text)
		return

	if (search_text == "0")
		src.parent.switch_menu_to(src.parent.current_record_group.main_menu)
		return

	var/list/datum/db_record/records = src.parent.current_record_group.get_records()
	var/list/datum/db_record/results = list()

	for (var/datum/db_record/record as anything in records)
		var/haystack = ""

		var/list/datum/db_record/linked_records = src.parent.current_record_group.get_linked_records(record)
		for (var/db_id as anything in linked_records)
			var/datum/db_record/db_record = linked_records[db_id]

			for (var/key as anything in src.parent.current_record_group.keys_to_search_by_db[db_id])
				haystack += ckey("[db_record[key]]") + " "

		if (findtext(haystack, search_text))
			results += record

	switch (length(results))
		if (0)
			src.parent.print_text("No results found.")
		if (1)
			src.parent.switch_menu_to("record_view", results[1])
		else
			src.parent.switch_menu_to("search_results", text, results)
