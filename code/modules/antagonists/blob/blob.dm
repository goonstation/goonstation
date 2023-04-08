/datum/antagonist/intangible/blob
	id = ROLE_BLOB
	display_name = "blob"
	intangible_mob_path = /mob/living/intangible/blob_overmind

	/// All mobs absorbed by this blob.
	var/list/mob/absorbed_victims = list()

	give_equipment()
		. = ..()

		SPAWN(0)
			var/newname = tgui_input_text(src.owner.current, "You are a blob. Please choose a name for yourself, it will show in the form: <name> the Blob", "Name Change", max_length = 26)
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


	assign_objectives()
		new /datum/objective_set/blob(src.owner, src)

	announce()
		. = ..()
		boutput(src.owner.current, "<span class='alert'><b>Your hivemind will cease to exist if your body is entirely destroyed.</b></span>")
		boutput(src.owner.current, "<span class='alert'><b>Use the question mark button in the lower right corner to get help on your abilities.</b></span>")

	handle_round_end(log_data)
		var/list/dat = ..()
		if (length(dat))
			var/num_of_victims = length(src.absorbed_victims)
			if (num_of_victims)
				var/absorbed_lifeforms = "<br><b>Absorbed Lifeforms:</b> "
				for (var/mob/living/carbon/human/H in src.absorbed_victims)
					if(!H.last_client || !H.last_client.key)
						absorbed_lifeforms += "[H.real_name](NPC), "
					else
						absorbed_lifeforms += "<span class='success'>[H.real_name]([H.last_client?.key])</span>, "
				dat.Insert(2, "They absorbed a total of [num_of_victims] lifeform[s_es(num_of_victims)] during this shift.[absorbed_lifeforms]")
			else
				dat.Insert(2, "Not a single lifeform was absorbed by them during this shift.")
		return dat
