/datum/forced_antagonist
	/// Selected antagonist as type path.
	var/antagonist_path = null
	/// Selected antagonist display name.
	var/display_name = ""
	/// Selected antagonist id.
	var/id = ""
	var/do_equipment = FALSE
	var/do_objectives = FALSE
	/// Text for custom antag objective.
	var/custom_objective = "Fuck shit up."

/datum/forced_antagonist/New(antagonist_path_input, do_equipment_input, do_objectives_input, custom_objective_input)
	. = ..()
	if (!ispath(antagonist_path_input, /datum/antagonist))
		qdel(src)
	src.antagonist_path = antagonist_path_input
	var/datum/antagonist/antagonist_instance = src.antagonist_path
	src.display_name = initial(antagonist_instance.display_name)
	src.id = initial(antagonist_instance.id)
	if (istext(do_equipment_input))
		src.do_equipment = do_equipment_input == "Yes" ? TRUE : FALSE
	if (istext(do_objectives_input))
		src.do_objectives = do_objectives_input == "Yes" ? TRUE : FALSE
	if (istext(custom_objective_input))
		src.custom_objective = custom_objective_input
