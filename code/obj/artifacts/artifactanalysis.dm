/obj/item/sticker/postit/artifact_paper
	name = "artifact analysis form"
	icon = 'icons/obj/writing.dmi'
	icon_state = "artifact_form"
	desc = "A standardized form for classifying different alien artifacts, with some extra strong adhesive on the back."
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	var/artifactName = ""
	var/artifactOrigin = ""
	var/artifactType = ""
	var/artifactTriggers = ""
	var/artifactFaults = ""
	var/artifactDetails = ""
	var/lastAnalysis = 0

	proc/checkArtifactVars(obj/O)
		if(!O.artifact)
			return FALSE
		var/datum/artifact/A = O.artifact

		lastAnalysis = 0

		// check origin
		if(A.artitype.type_name == src.artifactOrigin)
			lastAnalysis++

		// check type
		if(A.type_name == src.artifactType)
			lastAnalysis++

		// check if trigger is one of the correct ones
		for(var/datum/artifact_trigger/T as anything in A.triggers)
			if(T.type_name == src.artifactTriggers)
				lastAnalysis++
				break
		// if a trigger would e redundant, let's just say it's cool!
		if(!length(A.triggers) || A.automatic_activation)
			lastAnalysis++

		// ok, let's make a name
		// start with obscured name
		src.artifactName = O.real_name
		// get an instance of the artifact origin
		for(var/datum/artifact_origin/origin as() in artifact_controls.artifact_origins)
			if(origin.type_name == src.artifactOrigin)
				// have we already generated a name for that origin?
				// the actual name with the actual origin should be in the list by default
				if(!A.used_names[src.artifactOrigin])
					// no, generate new one and store it
					src.artifactName = origin.generate_name()
					A.used_names[src.artifactOrigin] = src.artifactName
				else
					// yes, use it
					src.artifactName = A.used_names[src.artifactOrigin]
				break

		// all correct, let's set the name!
		O.real_name = src.artifactName
		O.UpdateName()

	attack_hand(mob/user)
		user.lastattacked = src.attached
		if(src.attached)
			src.attached.attack_hand(user)
			user.lastattacked = src.attached

	stick_to(atom/A, pox, poy)
		. = ..()
		if(isobj(A))
			checkArtifactVars(A)

	attackby(obj/item/W, mob/living/user)
		if(istype(W, /obj/item/pen))
			ui_interact(user)
		else if((iscuttingtool(W) || issnippingtool(W)) && user.a_intent == INTENT_HELP)
			boutput(user, "You manage to scrape \the [src] off of \the [src.attached].")
			src.remove_from_attached()
			src.add_fingerprint(user)
			user.put_in_hand_or_drop(src)
		else if (src.attached)
			src.attached.attackby(W, user)
			user.lastattacked = user

	get_desc()
		. = src.artifactType!=""?"This one seems to be describing a [src.artifactType] type artifact.":""

	examine(mob/user)
		. = ..()
		ui_interact(user)

	attack_self(mob/user)
		ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ArtifactPaper")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"allArtifactOrigins" = artifact_controls.artifact_origin_names,
			"allArtifactTypes" = artifact_controls.artifact_type_names,
			"allArtifactTriggers" = artifact_controls.artifact_trigger_names
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		if (!params["hasPen"])
			boutput(usr, "You can't write without a pen!")
			return FALSE
		switch(action)
			if("origin")
				artifactOrigin = params["newOrigin"]
			if("type")
				artifactType = params["newType"]
			if("trigger")
				artifactTriggers = params["newTriggers"]
			if("fault")
				artifactFaults = params["newFaults"]
			if("detail")
				artifactDetails = params["newDetail"]
		. = TRUE
		if(isobj(src.loc))
			src.checkArtifactVars(src.loc)

	ui_data(mob/user)
		var/obj/item/pen/P = user.find_type_in_hand(/obj/item/pen)
		. = list(
			"artifactName" = artifactName,
			"artifactOrigin" = artifactOrigin,
			"artifactType" = artifactType,
			"artifactTriggers" = artifactTriggers,
			"artifactFaults" = artifactFaults,
			"artifactDetails" = artifactDetails,
			"hasPen" = P
		)

/obj/artifact_paper_dispenser
	name = "artifact analysis form tray"
	icon = 'icons/obj/writing.dmi'
	icon_state = "artifact_form_tray"
	desc = "A tray full of forms for classifying alien artifacts."

	attack_hand(mob/user)
		user.put_in_hand_or_drop(new /obj/item/sticker/postit/artifact_paper())
