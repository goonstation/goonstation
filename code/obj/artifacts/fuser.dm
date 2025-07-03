// an artifact black box that combines artifacts into each other
/obj/machinery/fuser
	name = "Fuser"
	desc = "A black box machine that utilizes unknown artifact technology to combine artifacts into each other. Quite nifty."
	icon = 'icons/obj/artifacts/fuser.dmi'
	icon_state = "reticulator"
	anchored = ANCHORED
	density = TRUE
	var/static/artifact_combinations_reference

	var/obj/receiver_art
	var/obj/sender_art

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Fuser")
			ui.open()

	ui_data(mob/user)
		. = list(
    		"canCombineArtifacts" = src.can_combine_arts(),
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		. = TRUE
		switch (action)
			if ("eject_receiver")
				src.eject_receiver()
			if ("eject_sender")
				src.eject_sender()
			if ("swap_artifacts")
				src.swap_arts()
			if ("view_combine_database")
				src.view_combine_database(usr)
			if ("combine_artifacts")
				src.combine_arts(usr)

	attack_hand(mob/user)
		if (..())
			return
		src.ui_interact(user)

	attackby(obj/item/I, mob/user)
		..()
		src.MouseDrop_T(I, user, I.loc, src.loc)

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		if (BOUNDS_DIST(src, over_location) > 0)
			return
		var/turf/T = get_turf(over_location)
		if (T.density)
			return
		src.receiver_art?.set_loc(T)
		src.receiver_art = null
		src.sender_art?.set_loc(T)
		src.sender_art = null

	MouseDrop_T(obj/dropped, user, src_location, over_location)
		..()
		if (BOUNDS_DIST(dropped, src) > 0)
			return
		if (!istype(dropped) || dropped.anchored)
			return
		if (!dropped.artifact || !dropped.artifact.activated || !dropped.artifact.can_combine_when_active)
			return
		if (src.sender_art && src.receiver_art)
			return

		if (!src.sender_art && src.receiver_art)
			if (ismob(src_location))
				var/mob/M = src_location
				M.drop_item(dropped)
			src.sender_art = dropped
			dropped.set_loc(src)
		else if (src.sender_art && !src.receiver_art)
			if (ismob(src_location))
				var/mob/M = src_location
				M.drop_item(dropped)
			src.receiver_art = dropped
			dropped.set_loc(src)
		else
			var/option = tgui_alert(user, "Load as receiver or sender?", "Load Artifact", list("Sender, Receiver, Cancel"))
			if (option == "Sender")
				if (ismob(src_location))
					var/mob/M = src_location
					M.drop_item(dropped)
				src.sender_art = dropped
				dropped.set_loc(src)
			else if (option == "Receiver")
				if (ismob(src_location))
					var/mob/M = src_location
					M.drop_item(dropped)
				src.receiver_art = dropped
				dropped.set_loc(src)

	verb/eject()
		set name = "Eject Storage"
		set src in oview(1)
		set category = "Local"

		src.eject_receiver()
		src.eject_sender()

	proc/eject_receiver()
		src.receiver_art?.set_loc(get_turf(src))
		src.receiver_art = null

	proc/eject_sender()
		src.sender_art?.set_loc(get_turf(src))
		src.sender_art = null

	proc/swap_arts()
		var/temp = src.receiver_art
		src.receiver_art = src.sender_art
		src.sender_art = temp

	proc/can_combine_arts()
		. = TRUE
		if (!src.receiver_art || !src.sender_art)
			return FALSE
		if (!src.receiver_art.can_combine_artifact(src.sender_art))
			return FALSE

	proc/combine_arts(mob/user)
		if (tgui_alert(user, "Are you sure you wish to combine [src.sender_art] into [src.receiver_art]? This can't be undone.", "Confirmation", list("Yes", "No")) != "Yes")
			return
		src.receiver_art.combine_artifact(src.sender_art)
		src.sender_art = null
		playsound(get_turf(src), 'sound/machines/fuser_create.ogg', 20, TRUE)
		if (length(src.receiver_art.combined_artifacts) > 1)
			return
		src.receiver_art.name_prefix("synthetic")
		src.receiver_art.UpdateName()

	proc/view_combine_database(mob/user)
		if (!src.artifact_combinations_reference)
			var/list/art_reference = list()
			var/list/combinations = list()
			for (var/datum/artifact/art as anything in concrete_typesof(/datum/artifact))
				var/art_flags = initial(art.combine_flags)
				if (art_flags & ARTIFACT_DOES_NOT_COMBINE)
					combinations += "does not combine"
				else
					if (art_flags & ARTIFACT_ACCEPTS_ANY_COMBINE)
						combinations += "accepts incoming combinations"
					if (art_flags & ARTIFACT_COMBINES_INTO_ANY)
						combinations += "combines into any"
					else if (art_flags & ARTIFACT_COMBINES_INTO_HANDHELD)
						combinations += "combines into handheld"
					else if (art_flags & ARTIFACT_COMBINES_INTO_LARGE)
						combinations += "combines into large"
				art_reference += "[initial(art.type_name)] - [capitalize(english_list(combinations))]"

				combinations = list()

			sortList(art_reference, /proc/cmp_text_asc)

			for (var/i in 1 to length(art_reference))
				src.artifact_combinations_reference += art_reference[i]
				if (i != length(art_reference))
					src.artifact_combinations_reference += "<br>"

		tgui_message(user, src.artifact_combinations_reference, "Artifact Combinations")
