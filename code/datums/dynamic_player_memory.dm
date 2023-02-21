/datum/dynamic_player_memory
	var/datum/mind/owner
	var/memory_text

	New(datum/mind/owner, memory_text)
		if (!istype(owner))
			return

		. = ..()
		src.owner = owner
		src.memory_text = memory_text
		RegisterSignal(src.owner, COMSIG_MIND_UPDATE_MEMORY, .proc/update_memory)
		src.update_memory()

	proc/update_memory()
		return

/datum/dynamic_player_memory/conspirator_list
	var/datum/antagonist/conspirator/antag_datum

	New(datum/mind/owner)
		if (!istype(owner) || !owner.get_antagonist(ROLE_CONSPIRATOR))
			return

		src.owner = owner
		src.antag_datum = src.owner.get_antagonist(ROLE_CONSPIRATOR)
		. = ..()

	update_memory()
		src.memory_text = "The conspiracy consists of: "

		for (var/datum/mind/conspirator in src.antag_datum.conspirators)
			if (conspirator.assigned_role == "Clown")
				src.memory_text += "<b>a Clown</b>, "
			else
				src.memory_text += "<b>[conspirator.current.real_name]</b>, "
