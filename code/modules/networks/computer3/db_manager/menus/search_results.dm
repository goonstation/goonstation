/datum/db_manager_menu/search_results
	VAR_PRIVATE/list/datum/db_record/results = null

/datum/db_manager_menu/search_results/load(search_text, list/datum/db_record/results)
	src.results = results
	var/text = "Multiple results found for \"[search_text]\". Please select a record:"

	var/record_count = length(src.results)
	var/leading_zero_count = length("[record_count]")
	for (var/i in 1 to record_count)
		text += "<br><b>\[[global.add_zero(i, leading_zero_count)]\]</b>"

		var/datum/db_record/R = src.results[i]
		if (istype(R))
			text += R.to_display_string()
		else
			text += "<font color=red>ERR: CORRUPTED</font>"

	text += "<br><br>Enter record number, or 0 to return."
	src.parent.print_text(text)

/datum/db_manager_menu/search_results/unload()
	src.results = null

/datum/db_manager_menu/search_results/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		src.parent.switch_menu_to("main")
		return

	if (index_number > length(src.results))
		src.parent.print_text("<b>Error:</b> Invalid record.")
		return

	var/datum/db_record/record = src.results[index_number]
	if (!istype(record))
		src.parent.print_text("<b>Error:</b> Record data invalid.")
		return

	src.parent.switch_menu_to("record_view", record["id"])
