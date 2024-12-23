/datum/antagonist/mob/intangible/blob
	id = ROLE_BLOB
	display_name = "blob"
	antagonist_icon = "blob"
	mob_path = /mob/living/intangible/blob_overmind
	uses_pref_name = FALSE
	has_info_popup = FALSE

	/// All mobs absorbed by this blob.
	var/list/mob/absorbed_victims = list()
	var/mob/living/intangible/blob_overmind/bovermind

	give_equipment()
		. = ..()

		SPAWN(0)
			bovermind = src.owner.current
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
		var/list/upgrades = list()
		for (var/mob/living/carbon/human/H in src.absorbed_victims)
			if(!H.last_client?.key)
				absorbed_lifeforms += "[H.real_name] (NPC)"

			else
				absorbed_lifeforms += "[H.real_name] (played by [H.last_client?.key])"

		for (var/datum/blob_upgrade/upgrade in bovermind.upgrades)
			var/repeater = ""
			if (upgrade.repeatable)
				repeater += " x[upgrade.purchased_times]"
			upgrades += list(
				list(
					"iconBase64" = "[icon2base64(icon(initial(upgrade.icon), initial(upgrade.icon_state), frame = 1, dir = 0))]",
					"name" = "[upgrade.name][repeater]",
				)
			)

		return list(
			list(
				"name" = "Unlocked Upgrades",
				"type" = "itemList",
				"value" = upgrades,
			),
			list(
				"name" = "Absorbed Lifeforms",
				"value" = "[english_list(absorbed_lifeforms, nothing_text = "No-one.")]",
			),
			list(
				"name" = "Living Nuclei",
				"value" = "[length(bovermind.nuclei)]"
			),
			list(
				"name" = "Total Spreads",
				"value" = "[bovermind.total_placed]"
			),
			list(
				"name" = "Final Size",
				"value" = "[length(bovermind.blobs)]"
			),
			list(
				"name" = "Final Generation Rate",
				"value" = "[bovermind.base_gen_rate + bovermind.gen_rate_bonus - bovermind.gen_rate_used]/[bovermind.base_gen_rate + bovermind.gen_rate_bonus] BP"
				// This calculation is copied right from blob_overmind.dm
			),
			list(
				"name" = "Unused Evo Points",
				"value" = "[bovermind.evo_points]"
			)

		)
