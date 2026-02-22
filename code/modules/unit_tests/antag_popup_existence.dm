/datum/unit_test/antag_popup_existence/Run()
	for(var/A in concrete_typesof(/datum/antagonist))
		var/datum/antagonist/antag = A
		var/popup_name = antag.popup_name_override ? antag.popup_name_override : antag.id
		if (antag.has_info_popup && !rustg_file_exists("tgui/packages/tgui/interfaces/AlertContentWindows/acw/[popup_name].AlertContentWindow.tsx"))
			Fail("Missing antag popup for antag type: [antag.type] with popup_name: [popup_name]")
