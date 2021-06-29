/client/proc/cmd_mass_modify_object_variables(obj/O as obj|mob|turf|area in world)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Mass Edit Variables"
	set desc="(target) Edit all instances of a target item's variables"
	set popup_menu = 0 // goddamn we have view variables already we don't need this in the damned right click menu FUCK'S SAKE
	src.massmodify_variables(O)

/proc/massmodify_general_set(var/atom/O, var/variable, var/oldVal, var/val)
	O.onVarChanged(variable, oldVal, val)

	if(ismob(O))
		for(var/mob/M in mobs)
			if (M.type == O.type)
				M.vars[variable] = val
				M.onVarChanged(variable, oldVal, val)
			LAGCHECK(LAG_LOW)

	else if(istype(O, /obj))
		for(var/obj/A in world)
			if (A.type == O.type)
				A.vars[variable] = val
				A.onVarChanged(variable, oldVal, val)
			LAGCHECK(LAG_LOW)

	else if(istype(O, /turf))
		for(var/turf/T in world)
			if (T.type == O.type)
				T.vars[variable] = val
				T.onVarChanged(variable, oldVal, val)
			LAGCHECK(LAG_LOW)

/client/proc/massmodify_variables(var/atom/O)
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

	if (locked.Find(variable) && !(src.holder.rank in list("Host", "Coder", "Administrator")))
		return

	//Let's prevent people from promoting themselves, yes?
	var/list/locked_type = list(/datum/admins) //Short list
	if(!(src.holder.rank in list("Host", "Coder")) && (O.type in locked_type) )
		boutput(usr, "<span class='alert'>You're not allowed to edit [O.type] for security reasons!</span>")
		logTheThing("admin", usr, null, "tried to varedit [O.type] but was denied!")
		logTheThing("diary", usr, null, "tried to varedit [O.type] but was denied!", "admin")
		message_admins("[key_name(usr)] tried to varedit [O.type] but was denied.") //If someone tries this let's make sure we all know it.
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

	else if (isloc(var_value))
		boutput(usr, "Variable appears to be <b>REFERENCE</b>.")
		default = "reference"

	else if (isicon(var_value))
		boutput(usr, "Variable appears to be <b>ICON</b>.")
		//var_value = "[bicon(var_value)]"
		default = "icon"

	else if (istype(var_value,/atom) || istype(var_value,/datum))
		boutput(usr, "Variable appears to be <b>TYPE</b>.")
		default = "type"

	else if (islist(var_value))
		boutput(usr, "Variable appears to be <b>LIST</b>.")
		default = "list"

	else if (isclient(var_value))
		boutput(usr, "Variable appears to be <b>CLIENT</b>.")
		default = "cancel"

	else
		boutput(usr, "Variable appears to be <b>FILE</b>.")
		default = "file"

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
		"num","num adjust","type","icon","file","color","json","ref","edit referenced object","restore to default")

	if(!class)
		return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	var/oldVal = O.vars[variable]
	switch(class)

		/*Probably cause a lot of bugs, so leaving it out
		if("list")
			mod_list(O.vars[variable])
			for (var\O.type\A in world)
			return
		*/

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])

		if("json")
			var/newval = input("Enter json:", "JSON", json_encode(O.vars[variable])) as text|null
			if(!isnull(newval))
				O.vars[variable] = json_decode(newval)

		if("ref")
			O.vars[variable] = locate(input("Enter ref:") as text|null)

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			O.vars[variable] = input("Enter new text:","Text",\
				O.vars[variable]) as null|text

		if("num")
			O.vars[variable] = input("Enter new number:","Num",\
				O.vars[variable]) as null|num

		if("num adjust")
			if(!isnum(oldVal)) return
			O.vars[variable] += input("Enter value to adjust by:","Num Adjust",\
				O.vars[variable]) as null|num

		if("type")
			O.vars[variable] = input("Enter type:","Type",O.vars[variable]) \
				in null|typesof(/obj,/mob,/area,/turf)

		/*////////////////////these too
		if("reference")
			O.vars[variable] = input("Select reference:","Reference",\
				O.vars[variable]) as mob|obj|turf|area in world

		if("mob reference")
			O.vars[variable] = input("Select reference:","Reference",\
				O.vars[variable]) as mob in world
		*/

		if("file")
			O.vars[variable] = input("Pick file:","File",O.vars[variable]) \
				as null|file

		if("icon")
			O.vars[variable] = input("Pick icon:","Icon",O.vars[variable]) \
				as null|icon

		if("color")
			O.vars[variable] = input("Pick color:","Color",O.vars[variable]) \
				as null|color

	if(!O.vars[variable]) return

	logTheThing("admin", src, null, "mass modified [original_name]'s [variable] from [oldVal] to [O.vars[variable]]")
	logTheThing("diary", src, null, "mass modified [original_name]'s [variable] from [oldVal] to [O.vars[variable]]", "admin")
	message_admins("[key_name(src)] mass modified [original_name]'s [variable] from [oldVal] to [O.vars[variable]]")
	massmodify_general_set(O, variable, oldVal, O.vars[variable])
