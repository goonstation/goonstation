/client/proc/cmd_modify_ticker_variables()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Edit Ticker Variables"

	if (ticker == null)
		boutput(src, "Game hasn't started yet.")
	else
		src.debug_variables(ticker)

/client/proc/cmd_modify_controller_variables()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Edit Main Loop Variables"

	if (processScheduler == null)
		boutput(src, "Main loop hasn't started yet.")
	else
		src.debug_variables(processScheduler)

/client/proc/cmd_modify_respawn_variables()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Edit Respawn Controller Variables"

	if(!respawn_controller)
		boutput(src, "Respawn controller not initialized yet.")
	else
		src.debug_variables(respawn_controller)

#ifdef ENABLE_SPAWN_DEBUG
/client/proc/cmd_modify_spawn_dbg_list()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Edit Spawn Debug List"
	set desc = "Directly varedit the spawn debug list, edit its length to 0 to wipe it"

	if (global_spawn_dbg == null)
		boutput(src, "Spawn sebug list is null!")
	else
		src.debug_variables(global_spawn_dbg)
#endif

/client/proc/mod_list_add(var/list/L, var/header = null)
	ADMIN_ONLY

	var/datum/data_input_result/val_result = src.input_data(list(DATA_INPUT_TEXT, DATA_INPUT_NUM, DATA_INPUT_TYPE, DATA_INPUT_JSON, DATA_INPUT_REF, DATA_INPUT_MOB_REFERENCE, \
								  DATA_INPUT_FILE, DATA_INPUT_ICON, DATA_INPUT_COLOR, DATA_INPUT_TURF_BY_COORDS, DATA_INPUT_REFPICKER, DATA_INPUT_NEW_INSTANCE), \
								  custom_type_title = header)

	if (isnull(val_result.output))
		return FALSE

	if (islist(val_result.output))
		//embed the list inside rather than combining the two
		L += list(val_result.output)
	else
		if(alert("Would you like to associate a value with the list entry and use the previously entered value as the key?",null,"Yes","No") == "Yes")
			//RIP mod_list_add_ass, initial commit - March 2022
			var/datum/data_input_result/key_result = src.input_data(list(DATA_INPUT_TEXT, DATA_INPUT_NUM, DATA_INPUT_TYPE, DATA_INPUT_JSON, DATA_INPUT_REF, DATA_INPUT_MOB_REFERENCE, \
								  DATA_INPUT_FILE, DATA_INPUT_ICON, DATA_INPUT_COLOR, DATA_INPUT_TURF_BY_COORDS, DATA_INPUT_REFPICKER, DATA_INPUT_NEW_INSTANCE, DATA_INPUT_LIST_BUILD))
			if (!isnull(key_result.output))
				L[val_result.output] = key_result.output
		else
			L += val_result.output
	return TRUE


/client/proc/mod_list(var/list/L)
	ADMIN_ONLY

	if(!islist(L))
		boutput(src, "<span class='alert'>That's not a List!</span>")
		return

	var/list/names = sortList(L, /proc/cmp_text_asc)

	var/list/fixedList = list()

	for(var/x in names)
		var/addNew = istext(x) ? (isnull(L[x]) ? "\ref[x] - ([x])" : "\ref[x] -> ([L[x]])") : "\ref[x] - ([x])"

		fixedList[addNew] = x

	var/variable = input("Which var?","Var") as null|anything in fixedList + "(ADD VAR)"

	if(variable == "(ADD VAR)")
		mod_list_add(L)
		return

	if(!variable)
		return

	variable = fixedList[variable]
	var/variable_index = L.Find(variable)

	var/default = suggest_input_type(variable)

	var/datum/data_input_result/result = input_data(list(DATA_INPUT_TEXT, DATA_INPUT_NUM, DATA_INPUT_TYPE, DATA_INPUT_JSON, DATA_INPUT_REF, DATA_INPUT_MOB_REFERENCE, \
													DATA_INPUT_TURF_BY_COORDS, DATA_INPUT_REFPICKER, DATA_INPUT_NEW_INSTANCE, DATA_INPUT_ICON, DATA_INPUT_FILE, \
													DATA_INPUT_COLOR, DATA_INPUT_LIST_EDIT, DATA_INPUT_LIST_BUILD, DATA_INPUT_LIST_DEL_FROM, DATA_INPUT_RESTORE, \
													default_type = default, default = variable))

	switch(result.output_type)

		if (null)
			return

		if (DATA_INPUT_RESTORE)
			L[variable_index] = initial(variable)

		if (DATA_INPUT_LIST_DEL_FROM)
			L -= variable

		else
			L[variable_index] = result.output
