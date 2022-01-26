/datum/buildmode/varedit
	name = "Variable Edit (single)"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set variable details<br>
Left Mouse Button on turf/mob/obj      = Set variable to value<br>
Right Mouse Button                     = Reset variable to initial value<br>
Hold down CTRL, ALT or SHIFT to modify, call or reset variable bound to those keys.<br>
***********************************************************"}
	icon_state = "buildmode3"
	var/is_refpicking = 0

	// no modifier key held down
	var/varname_n = null
	var/varvalue_n = null
	var/newinst_n = 0

	// ctrl held down
	var/varname_c = null
	var/varvalue_c = null
	var/newinst_c = 0

	// alt held down
	var/varname_a = null
	var/varvalue_a = null
	var/newinst_a = 0

	// shift held down
	var/varname_s = null
	var/varvalue_s = null
	var/newinst_s = 0

	click_mode_right(var/ctrl, var/alt, var/shift)
		var/newvn = input("Enter variable name[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]:", "Variable Name[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]", ctrl ? varname_c : alt ? varname_a : shift ? varname_s : varname_n) as text|null
		if (!newvn)
			return

		var/vartype = input("Choose variable type[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]:","Variable Type[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]") as null|anything in list("text", "num", "type", "reference", "mob reference", "turf by coordinates", "reference picker", "new instance of a type", "icon", "file", "color", "json", "ref")
		is_refpicking = 0
		var/newvalue = null
		var/is_newinst = 0
		switch (vartype)
			if ("text")
				newvalue = input("Enter new text:","Text") as null|text

			if ("num")
				newvalue = input("Enter new number:","Num") as null|num

			if ("type")
				newvalue = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

			if ("reference")
				newvalue = input("Select reference:","Reference") as null|mob|obj|turf|area in world

			if ("mob reference")
				newvalue = input("Select reference:","Reference") as null|mob in world

			if ("file")
				newvalue = input("Pick file:","File") as null|file

			if ("icon")
				newvalue = input("Pick icon:","Icon") as null|icon

			if ("color")
				newvalue = input("Pick color:","Color") as null|color

			if ("json")
				newvalue = json_decode(input("Enter json:") as text|null)

			if ("ref")
				var/inp = input("Enter ref:","Ref") as null|text
				newvalue = locate(inp)
				if(isnull(newvalue))
					newvalue = locate("\[inp\]")

			if ("turf by coordinates")
				var/x = input("X coordinate", "Set to turf at \[_, ?, ?\]", 1) as num
				var/y = input("Y coordinate", "Set to turf at \[[x], _, ?\]", 1) as num
				var/z = input("Z coordinate", "Set to turf at \[[x], [y], _\]", 1) as num
				var/turf/T = locate(x, y, z)
				if (istype(T))
					newvalue = T
				else
					boutput(usr, "<span class='alert'>Invalid coordinates!</span>")
					return

			if ("reference picker")
				boutput(usr, "<span class='notice'>Click the mob, object or turf to use as a reference.</span>")
				is_refpicking = 1

			if ("new instance of a type")
				boutput(usr, "<span class='notice'>Type part of the path of type of thing to instantiate.</span>")
				var/typename = input("Part of type path.", "Part of type path.", "/obj") as null|text
				if (typename)
					var/basetype = /obj
					if (holder.owner.holder.rank in list("Host", "Coder", "Administrator"))
						basetype = /datum
					var/match = get_one_match(typename, basetype, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
					if (match)
						newvalue = match
						is_newinst = 1
		if (ctrl)
			varname_c = newvn
			newinst_c = is_newinst
			if (!isnull(newvalue))
				varvalue_c = newvalue
		else if (alt)
			varname_a = newvn
			newinst_a = is_newinst
			if (!isnull(newvalue))
				varvalue_a = newvalue
		else if (shift)
			varname_s = newvn
			newinst_s = is_newinst
			if (!isnull(newvalue))
				varvalue_s = newvalue
		else
			varname_n = newvn
			newinst_n = is_newinst
			if (!isnull(newvalue))
				varvalue_n = newvalue

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (is_refpicking)
			boutput(usr, "<span class='notice'>Reference grabbed from [object].</span>")
			var/newvalue = object
			if (ctrl)
				varname_c = newvalue
			else if (alt)
				varname_a = newvalue
			else if (shift)
				varname_s = newvalue
			else
				varname_n = newvalue
			is_refpicking = 0
			return

		var/varn2use = null
		var/varv2use = null
		var/is_newinst = 0
		if (ctrl && varname_c)
			varn2use = varname_c
			varv2use = varvalue_c
			is_newinst = newinst_c
		else if (alt && varname_a)
			varn2use = varname_a
			varv2use = varvalue_a
			is_newinst = newinst_a
		else if (shift && varname_s)
			varn2use = varname_s
			varv2use = varvalue_s
			is_newinst = newinst_s
		else if (varname_n)
			varn2use = varname_n
			varv2use = varvalue_n
			is_newinst = newinst_n

		if (varn2use in object.vars)
			var/ov = object.vars[varn2use]
			if (is_newinst)
				object.vars[varn2use] = new varv2use()
			else
				object.vars[varn2use] = varv2use
			object.onVarChanged(varn2use, ov, object.vars[varn2use])
			boutput(usr, "<span class='notice'>Set [object].[varn2use] to [varv2use].</span>")
			blink(get_turf(object))
		else
			boutput(usr, "<span class='alert'>[object] has no var named [varn2use].</span>")

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (is_refpicking)
			return

		var/varn2use = null
		if (ctrl && varname_c)
			varn2use = varname_c
		else if (alt && varname_a)
			varn2use = varname_a
		else if (shift && varname_s)
			varn2use = varname_s
		else if (!ctrl && !alt && !shift && varname_n)
			varn2use = varname_n

		if (!varn2use)
			boutput(usr, "<span class='alert'>No var name defined[ctrl ? " for CTRL" : alt ? " for ALT" : shift ? " for SHIFT" : null]!</span>")
			return
		if (varn2use in object.vars)
			var/ov = object.vars[varn2use]
			object.vars[varn2use] = initial(object.vars[varn2use])
			object.onVarChanged(varn2use, ov, object.vars[varn2use])
			boutput(usr, "<span class='notice'>Reset [object].[varn2use] to initial value ([object.vars[varn2use]]).</span>")
			blink(get_turf(object))
		else
			boutput(usr, "<span class='alert'>[object] has no var named [varn2use].</span>")
