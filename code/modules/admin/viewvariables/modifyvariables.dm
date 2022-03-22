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
				L[val_result] = key_result.output
		L += val_result.output
	return TRUE


/client/proc/mod_list(var/list/L)
	ADMIN_ONLY

	if(!islist(L))
		boutput(src, "Not a List.")

	var/list/locked = list("vars", "key", "ckey", "client", "holder")

	var/list/names = sortList(L)

	var/list/fixedList = new/list()

	for(var/x in names)
		var/addNew = istext(x) ? (isnull(L[x]) ? "\ref[x] - ([x])" : "\ref[x] -> ([L[x]])") : "\ref[x] - ([x])"
		fixedList.Add(addNew)
		fixedList[addNew] = x

	var/variable = input("Which var?","Var") as null|anything in fixedList + "(ADD VAR)"

	if(variable == "(ADD VAR)")
		mod_list_add(L)
		return

	if(!variable)
		return

	variable = fixedList[variable]
	var/variable_index = L.Find(variable)

	if (locked.Find(variable) && !(src.holder.rank in list("Host", "Coder", "Administrator")))
		return

	var/default = suggest_input_type(variable)

	var/datum/data_input_result/result = input_data(list(DATA_INPUT_TEXT, DATA_INPUT_NUM, DATA_INPUT_TYPE, DATA_INPUT_JSON, DATA_INPUT_REF, DATA_INPUT_MOB_REFERENCE, \
													DATA_INPUT_TURF_BY_COORDS, DATA_INPUT_REFPICKER, DATA_INPUT_NEW_INSTANCE, DATA_INPUT_ICON, DATA_INPUT_FILE, \
													DATA_INPUT_COLOR, DATA_INPUT_LIST_EDIT, DATA_INPUT_LIST_BUILD, DATA_INPUT_LIST_DEL_FROM, DATA_INPUT_RESTORE, \
													default == DATA_INPUT_LIST_EDIT_ASSOCIATED ? DATA_INPUT_LIST_EDIT_ASSOCIATED : null))

	switch(result.output_type)

		if (null)
			return

		if(DATA_INPUT_LIST_EDIT_ASSOCIATED)
			modify_variables(L[variable])

		if (DATA_INPUT_RESTORE)
			L[variable_index] = initial(variable)

		if (DATA_INPUT_LIST_DEL_FROM)
			L -= variable

		else
			L[variable_index] = result.output

/client/proc/modify_variables(var/atom/O)
	var/list/locked = list("vars", "key", "ckey", "client", "holder")
	ADMIN_ONLY

	var/list/names = list()
	for (var/V in O.vars)
		names += V

	names = sortList(names)

	var/variable = input("Which var?","Var") as null|anything in names
	if(!variable)
		return
	var/default
	var/var_value = O.vars[variable]
	var/dir

	//Let's prevent people from promoting themselves, yes?
	var/list/locked_type = list(/datum/admins) //Short list
	if(!(src.holder.rank in list("Host", "Coder")) && (O.type in locked_type) )
		boutput(usr, "<span class='alert'>You're not allowed to edit [O.type] for security reasons!</span>")
		logTheThing("admin", usr, null, "tried to varedit [O.type] but was denied!")
		logTheThing("diary", usr, null, "tried to varedit [O.type] but was denied!", "admin")
		message_admins("[key_name(usr)] tried to varedit [O.type] but was denied.") //If someone tries this let's make sure we all know it.
		return


	if (locked.Find(variable) && !(src.holder.rank in list("Host", "Coder", "Administrator")))
		boutput(usr, "<span class='alert'>You lack access to modify the [variable]!</span>")
		return

	if (isnull(var_value))
		boutput(usr, "Unable to determine variable type.")

	else if (isnum(var_value))
		boutput(usr, "Variable appears to be <b>NUM</b>.")
		default = "num"
		dir = 1

	else if (is_valid_color_string(var_value))
		boutput(usr, "Variable appears to be <b>COLOR</b>.")
		default = "color"

	else if (istext(var_value))
		boutput(usr, "Variable appears to be <b>TEXT</b>.")
		default = "text"

	else if (ispath(var_value))
		boutput(usr, "Variable appears to be <B>TYPE</b>.")
		default = "type"

	else if (ismob(var_value))
		boutput(usr, "Variable appears to be <B>MOB REFERENCE</b>.")
		default = "mob reference"

	else if (isloc(var_value))
		boutput(usr, "Variable appears to be <b>REFERENCE</b>.")
		default = "reference"

	else if (isicon(var_value))
		boutput(usr, "Variable appears to be <b>ICON</b>.")
		//var_value = "[bicon(var_value)]" //Wire: Bug me if you want the entirely too long winded explanation of why this is commented out
		default = "icon"

	else if (isfile(var_value))
		boutput(usr, "Variable appears to be <b>FILE</b>.")
		default = "file"

	else if (islist(var_value))
		boutput(usr, "Variable appears to be <b>LIST</b>.")
		default = "list"

	else if (isclient(var_value))
		boutput(usr, "Variable appears to be <b>CLIENT</b>.")
		default = "cancel"

	else
		boutput(usr, "Variable appears to be <b>DATUM</b>.")
		default = "edit referenced object"

	boutput(usr, "Variable contains: [var_value]")
	if(dir)
		switch(var_value)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null
		if(dir)
			boutput(usr, "If a direction, direction is: [dir]")

	var/class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
		"num","num adjust","type","ref","reference","mob reference","turf by coordinates","reference picker","new instance of a type","icon","file","color","list","json","edit referenced object","create new list","restore to default")

	if(!class)
		return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	var/oldVal = O.vars[variable]
	switch(class)

		if("list")
			mod_list(O.vars[variable])
			return

		if("json")
			var/newval = input("Enter json:", "JSON", json_encode(O.vars[variable])) as text|null
			if(!isnull(newval))
				O.vars[variable] = json_decode(newval)
			return

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])

		if("edit referenced object")
			return .(O.vars[variable])

		if("create new list")
			O.vars[variable] = list()

		if("text")
			O.vars[variable] = input("Enter new text:","Text",\
				O.vars[variable]) as text

		if("num")
			O.vars[variable] = input("Enter new number:","Num",\
				O.vars[variable]) as num

		if("num adjust")
			if(!isnum(oldVal)) return
			O.vars[variable] += input("Enter value to adjust by:","Num Adjust",\
				O.vars[variable]) as null|num

		if("type")
			O.vars[variable] = input("Enter type:","Type",O.vars[variable]) \
				in typesof(/obj,/mob,/area,/turf)

		if("ref")
			var/input = input("Enter ref:") as null|text
			var/target = locate(input)
			if (!target) target = locate("\[[input]\]")
			O.vars[variable] = target

		if("reference")
			O.vars[variable] = input("Select reference:","Reference",\
				O.vars[variable]) as mob|obj|turf|area in world

		if("mob reference")
			O.vars[variable] = input("Select reference:","Reference",\
				O.vars[variable]) as mob in world

		if("turf by coordinates")
			var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", 1) as num
			var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", 1) as num
			var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", 1) as num
			var/turf/T = locate(x, y, z)
			if (istype(T))
				O.vars[variable] = T
			else
				boutput(usr, "<span class='alert'>Invalid coordinates!</span>")
				return


		if ("new instance of a type")
			boutput(usr, "<span class='notice'>Type part of the path of type of thing to instantiate.</span>")
			var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
			if (typename)
				var/basetype = /obj
				if (src.holder.rank in list("Host", "Coder", "Administrator"))
					basetype = /datum
				var/match = get_one_match(typename, basetype, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
				if (match)
					O.vars[variable] = new match(O)

		if("file")
			O.vars[variable] = input("Pick file:","File",O.vars[variable]) \
				as file

		if("icon")
			O.vars[variable] = input("Pick icon:","Icon",O.vars[variable]) \
				as icon

		if("color")
			O.vars[variable] = input("Pick color:","Color",O.vars[variable]) \
				as color

	logTheThing("admin", src, null, "modified [original_name]'s [variable] to [O.vars[variable]]")
	logTheThing("diary", src, null, "modified [original_name]'s [variable] to [O.vars[variable]]", "admin")
	message_admins("[key_name(src)] modified [original_name]'s [variable] to [O.vars[variable]]")
	SPAWN(0)
		O.onVarChanged(variable, oldVal, O.vars[variable])
