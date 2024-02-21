/datum/antagonist/mob/intangible/blob
	id = ROLE_BLOB
	display_name = "blob"
	antagonist_icon = "blob"
	mob_path = /mob/living/intangible/blob_overmind
	uses_pref_name = FALSE

	/// All mobs absorbed by this blob.
	var/list/mob/absorbed_victims = list()

	give_equipment()
		. = ..()

		SPAWN(0)
			var/newname = tgui_input_text(src.owner.current, "You are a blob. Please choose a name for yourself, it will show in the form: <name> the Blob", "Name Change", max_length = 25)
			if (newname)
				phrase_log.log_phrase("name-blob", newname, no_duplicates = TRUE)

				if (length(newname) >= 26)
					newname = copytext(newname, 1, 26)

				newname = strip_html(newname) + " the Blob"
				src.owner.current.real_name = newname
				src.owner.current.name = newname
				src.owner.current.UpdateName()

	remove_equipment()
		if (isblob(src.owner.current))
			var/mob/living/intangible/blob_overmind/overmind = src.owner.current
			overmind.remove_all_abilities()
			overmind.remove_all_upgrades()

		. = ..()

	relocate()
		var/mob/M = src.owner.current
		M.set_loc(pick_landmark(LANDMARK_BLOBSTART))

	assign_objectives()
		new /datum/objective_set/blob(src.owner, src)

	announce()
		. = ..()
		boutput(src.owner.current, SPAN_ALERT("<b>Your hivemind will cease to exist if your body is entirely destroyed.</b>"))
		boutput(src.owner.current, SPAN_ALERT("<b>Use the question mark button in the lower right corner to get help on your abilities.</b>"))

	get_statistics()
		var/list/absorbed_lifeforms = list()
		for (var/mob/living/carbon/human/H in src.absorbed_victims)
			if(!H.last_client?.key)
				absorbed_lifeforms += "[H.real_name] (NPC)"

			else
				absorbed_lifeforms += "[H.real_name] (played by [H.last_client?.key])"

		return list(
			list(
				"name" = "Absorbed Lifeforms",
				"value" = "[english_list(absorbed_lifeforms, nothing_text = "No-one.")]",
			)
		)
