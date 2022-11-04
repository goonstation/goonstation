/datum/buildmode/varedit
	name = "Variable Edit (single)"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set variable details<br>
Left Mouse Button on turf/mob/obj      = Set variable to value<br>
Right Mouse Button                     = Reset variable to initial value<br>
Hold down CTRL, ALT or SHIFT to modify, call or reset variable bound to those keys.<br>
***********************************************************"}
	icon_state = "buildmode3"

	// no modifier key held down
	var/varname_n = null
	var/tmp/varvalue_n = null
	var/tmp/newinst_n = 0

	// ctrl held down
	var/varname_c = null
	var/tmp/varvalue_c = null
	var/tmp/newinst_c = 0

	// alt held down
	var/varname_a = null
	var/tmp/varvalue_a = null
	var/tmp/newinst_a = 0

	// shift held down
	var/varname_s = null
	var/tmp/varvalue_s = null
	var/tmp/newinst_s = 0

	click_mode_right(var/ctrl, var/alt, var/shift)
		var/newvn = input("Enter variable name[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]:", "Variable Name[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]", \
						ctrl ? varname_c : alt ? varname_a : shift ? varname_s : varname_n) as text|null
		if (!newvn)
			return

		var/datum/data_input_result/result = src.holder.owner.input_data(list(DATA_INPUT_TEXT, DATA_INPUT_NUM, DATA_INPUT_TYPE, DATA_INPUT_MOB_REFERENCE, DATA_INPUT_TURF_BY_COORDS, DATA_INPUT_REFPICKER, \
									DATA_INPUT_NEW_INSTANCE, DATA_INPUT_ICON, DATA_INPUT_FILE, DATA_INPUT_COLOR, DATA_INPUT_JSON, DATA_INPUT_REF, DATA_INPUT_MATRIX), \
									custom_type_title = "Variable Type[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]", \
									custom_type_message = "Choose variable type[ctrl ? " (CTRL)" : alt ? " (ALT)" : shift ? " (SHIFT)" : null]:")
		var/is_newinst = FALSE

		switch (result.output_type)
			if (null)
				return

			if (DATA_INPUT_NEW_INSTANCE)
				is_newinst = TRUE

		if (ctrl)
			varname_c = newvn
			newinst_c = is_newinst
			varvalue_c = result.output
		else if (alt)
			varname_a = newvn
			newinst_a = is_newinst
			varvalue_a = result.output
		else if (shift)
			varname_s = newvn
			newinst_s = is_newinst
			varvalue_s = result.output
		else
			varname_n = newvn
			newinst_n = is_newinst
			varvalue_n = result.output

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/varn2use = null
		var/varv2use = null
		var/is_newinst = FALSE
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
