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

/client/proc/mod_list_add_ass(var/list/L, var/index) //haha
	var/class = input("What kind of variable?","Variable Type") as null|anything in list("text",
	"num", "type", "reference", "mob reference", "turf by coordinates", "reference picker", "new instance of a type", "icon", "file", "color")

	if (!class)
		return

	if (!holder || holder.level < LEVEL_PA)
		return

	var/var_value = null

	switch(class)

		if ("text")
			var_value = input("Enter new text:","Text") as null|text

		if ("num")
			var_value = input("Enter new number:","Num") as null|num

		if ("type")
			var_value = input("Enter type:","Type") in null|typesof(/obj,/mob,/area,/turf)

		if ("reference")
			var_value = input("Select reference:","Reference") as null|mob|obj|turf|area in world

		if ("mob reference")
			var_value = input("Select reference:","Reference") as null|mob in world

		if ("file")
			var_value = input("Pick file:","File") as null|file

		if ("icon")
			var_value = input("Pick icon:","Icon") as null|icon

		if ("color")
			var_value = input("Pick color:","Color") as null|color

		if ("turf by coordinates")
			var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", 1) as null|num
			var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", 1) as null|num
			var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", 1) as null|num
			var/turf/T = locate(x, y, z)
			if (istype(T))
				var_value = T
			else
				boutput(usr, "<span class='alert'>Invalid coordinates!</span>")
				return

		if ("reference picker")
			boutput(usr, "<span class='notice'>Click the mob, object or turf to use as a reference.</span>")
			var/mob/M = usr
			if (istype(M))
				var/datum/targetable/listrefpicker/R = new()
				R.target = L
				R.varname = index
				M.targeting_ability = R
				M.update_cursor()
			return

		if ("new instance of a type")
			boutput(usr, "<span class='notice'>Type part of the path of type of thing to instantiate.</span>")
			var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
			if (typename)
				var/basetype = /obj
				if (src.holder.rank in list("Host", "Coder", "Administrator"))
					basetype = /datum
				var/match = get_one_match(typename, basetype, use_concrete_types = FALSE)
				if (match)
					var_value = new match()

	if (!var_value) return

	return var_value


/client/proc/mod_list_add(var/list/L)
	var/class = input("What kind of variable?","Variable Type") as null|anything in list("text",
	"num", "type", "reference", "mob reference", "turf by coordinates", "reference picker", "new instance of a type", "icon", "file", "color")

	if (!class)
		return

	if (!holder || holder.level < LEVEL_PA)
		return

	var/var_value = null

	switch(class)

		if ("text")
			var_value = input("Enter new text:","Text") as null|text

		if ("num")
			var_value = input("Enter new number:","Num") as null|num

		if ("type")
			var_value = input("Enter type:","Type") in null|typesof(/obj,/mob,/area,/turf)

		if ("reference")
			var_value = input("Select reference:","Reference") as null|mob|obj|turf|area in world

		if ("mob reference")
			var_value = input("Select reference:","Reference") as null|mob in world

		if ("file")
			var_value = input("Pick file:","File") as null|file

		if ("icon")
			var_value = input("Pick icon:","Icon") as null|icon

		if ("color")
			var_value = input("Pick color:","Color") as null|color

		if ("turf by coordinates")
			var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", 1) as null|num
			var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", 1) as null|num
			var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", 1) as null|num
			var/turf/T = locate(x, y, z)
			if (istype(T))
				var_value = T
			else
				boutput(usr, "<span class='alert'>Invalid coordinates!</span>")
				return

		if ("reference picker")
			boutput(usr, "<span class='notice'>Click the mob, object or turf to use as a reference.</span>")
			var/mob/M = usr
			if (istype(M))
				var/datum/targetable/addtolistrefpicker/R = new()
				R.target = L
				M.targeting_ability = R
				M.update_cursor()
			return

		if ("new instance of a type")
			boutput(usr, "<span class='notice'>Type part of the path of type of thing to instantiate.</span>")
			var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
			if (typename)
				var/basetype = /obj
				if (src.holder.rank in list("Host", "Coder", "Administrator"))
					basetype = /datum
				var/match = get_one_match(typename, basetype, use_concrete_types = FALSE)
				if (match)
					var_value = new match()

	if (!var_value) return

	switch(alert("Would you like to associate a var with the list entry?",,"Yes","No"))
		if("Yes")
			L += var_value
			L[var_value] = mod_list_add_ass(L, var_value) //haha
		if("No")
			L += var_value


/client/proc/mod_list(var/list/L)
	if(!islist(L)) boutput(src, "Not a List.")

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
	var/default

	var/dir

	if (locked.Find(variable) && !(src.holder.rank in list("Host", "Coder", "Administrator")))
		return

	if (isnull(variable))
		boutput(usr, "Unable to determine variable type.")

	else if (L[variable] != null)
		boutput(usr, "Variable appears to be an associated list entry.")
		default = "associated"
		dir = 1

	else if (isnum(variable))
		boutput(usr, "Variable appears to be <b>NUM</b>.")
		default = "num"
		dir = 1

	else if (is_valid_color_string(variable))
		boutput(usr, "Variable appears to be <b>COLOR</b>.")
		default = "color"

	else if (istext(variable))
		boutput(usr, "Variable appears to be <b>TEXT</b>.")
		default = "text"

	else if (isloc(variable))
		boutput(usr, "Variable appears to be <b>REFERENCE</b>.")
		default = "reference"

	else if (isicon(variable))
		boutput(usr, "Variable appears to be <b>ICON</b>.")
		//variable = "[bicon(variable)]" //Wire: Bug me if you want the entirely too long winded explanation of why this is commented out
		default = "icon"

	else if (istype(variable,/atom) || istype(variable,/datum))
		boutput(usr, "Variable appears to be <b>TYPE</b>.")
		default = "type"

	else if (islist(variable))
		boutput(usr, "Variable appears to be <b>LIST</b>.")
		default = "list"

	else if (isclient(variable))
		boutput(usr, "Variable appears to be <b>CLIENT</b>.")
		default = "cancel"

	else
		boutput(usr, "Variable appears to be <b>FILE</b>.")
		default = "file"

	boutput(usr, "Variable contains: [variable]")
	if(dir)
		switch(variable)
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
		"num","type","reference","mob reference","turf by coordinates","reference picker","new instance of a type", "icon","file","color","list","number","edit referenced object", default == "associated" ? "associated" : null, "(DELETE FROM LIST)","restore to default")

	if(!class)
		return

	switch(class)

		if("associated")
			modify_variables(L[variable])

		if("list")
			mod_list(variable)

		if("restore to default")
			L[variable_index] = initial(variable)

		if("edit referenced object")
			modify_variables(L[variable_index])

		if("(DELETE FROM LIST)")
			L -= variable
			return

		if("text")
			L[variable_index] = input("Enter new text:","Text",\
				variable) as text

		if("num")
			L[variable_index] = input("Enter new number:","Num",\
				variable) as num

		if("type")
			boutput(usr, "<span class='notice'>Type part of the path of the type.</span>")
			var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
			if (typename)
				var/match = get_one_match(typename, /datum, use_concrete_types = FALSE)
				if (match)
					L[variable_index] = match

		if("reference")
			L[variable_index] = input("Select reference:","Reference",\
				variable) as mob|obj|turf|area in world

		if("mob reference")
			L[variable_index] = input("Select reference:","Reference",\
				variable) as mob in world

		if("turf by coordinates")
			var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", 1) as num
			var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", 1) as num
			var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", 1) as num
			var/turf/T = locate(x, y, z)
			if (istype(T))
				L[variable_index] = T
			else
				boutput(usr, "<span class='alert'>Invalid coordinates!</span>")
				return

		if("reference picker")
			boutput(usr, "<span class='notice'>Click the mob, object or turf to use as a reference.</span>")
			var/mob/M = usr
			if (istype(M))
				var/datum/targetable/listrefpicker/R = new()
				R.target = L
				R.varname = variable_index
				M.targeting_ability = R
				M.update_cursor()
				return

		if ("new instance of a type")
			boutput(usr, "<span class='notice'>Type part of the path of type of thing to instantiate.</span>")
			var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
			if (typename)
				var/basetype = /obj
				if (src.holder.rank in list("Host", "Coder", "Administrator"))
					basetype = /datum
				var/match = get_one_match(typename, basetype, use_concrete_types = FALSE)
				if (match)
					L[variable_index] = new match()

		if("file")
			L[variable_index] = input("Pick file:","File",variable) \
				as file

		if("icon")
			L[variable_index] = input("Pick icon:","Icon",variable) \
				as icon

		if("color")
			L[variable_index] = input("Pick color:","Color",variable) \
				as color


/datum/targetable/addtolistrefpicker
	var/list/target = null
	target_anything = 1
	targeted = 1
	max_range = 3000

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/selected)
		boutput(usr, "<span class='notice'>Added [selected] to [target]</span>")
		target += selected

/datum/targetable/listrefpicker
	var/list/target = null
	var/varname = null
	target_anything = 1
	targeted = 1
	max_range = 3000

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/selected)
		boutput(usr, "<span class='notice'>Set [target]\[[varname]\] to [selected]</span>")
		target[varname] = selected

/datum/targetable/refpicker
	var/datum/target = null
	var/varname = null
	target_anything = 1
	targeted = 1
	max_range = 3000

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/selected)
		boutput(usr, "<span class='notice'>Set [target]/var/[varname] to [selected]</span>")
		if(target == "GLOB")
			global.vars[varname] = selected
		else
			target.vars[varname] = selected
		logTheThing("admin", src, null, "modified [target]'s [varname] to [target.vars[varname]]")
		logTheThing("diary", src, null, "modified [target]'s [varname] to [target.vars[varname]]", "admin")
		message_admins("[key_name(src)] modified [target]'s [varname] to [target.vars[varname]]")

	global
		handleCast(var/atom/selected)
			boutput(usr, "<span class='notice'>Set [target]/var/[varname] to [selected] on all entities of the same type.</span>")
			for (var/datum/V in world)
				LAGCHECK(LAG_LOW)
				if (istype(V, target.type))
					V.vars[varname] = selected
			logTheThing("admin", src, null, "modified [target]'s [varname] to [target.vars[varname]] on all entities of the same type")
			logTheThing("diary", src, null, "modified [target]'s [varname] to [target.vars[varname]] on all entities of the same type", "admin")
			message_admins("[key_name(src)] modified [target]'s [varname] to [target.vars[varname]] on all entities of the same type")


/client/proc/modify_variables(var/atom/O)
	var/list/locked = list("vars", "key", "ckey", "client", "holder")
	admin_only

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

		if("reference picker")
			boutput(usr, "<span class='notice'>Click the mob, object or turf to use as a reference.</span>")
			var/mob/M = usr
			if (istype(M))
				var/datum/targetable/refpicker/R = new()
				R.target = O
				R.varname = variable
				M.targeting_ability = R
				M.update_cursor()
				return

		if ("new instance of a type")
			boutput(usr, "<span class='notice'>Type part of the path of type of thing to instantiate.</span>")
			var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
			if (typename)
				var/basetype = /obj
				if (src.holder.rank in list("Host", "Coder", "Administrator"))
					basetype = /datum
				var/match = get_one_match(typename, basetype, use_concrete_types = FALSE)
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
	SPAWN_DBG(0)
		O.onVarChanged(variable, oldVal, O.vars[variable])
