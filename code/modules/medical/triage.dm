/obj/item/sticker/postit/triage
	name = "triage tag"
	desc = "Patient has minor injuries."
	icon = 'icons/obj/items/triage.dmi'
	icon_state = "minor"
	contextLayout = new /datum/contextLayout/experimentalcircle

	var/list/datum/contextAction/contexts = list()

	get_desc()
		if(words)
			. = "<br>[SPAN_NOTICE("It says:")]<br><blockquote style='margin: 0 0 0 1em;'>[words]</blockquote>"

	attack_self(mob/user as mob)
		user.showContextActions(src.contexts, src, src.contextLayout)

	attack_hand(mob/user)
		if (!src.active)
			..()
			return
		user.showContextActions(src.contexts, src, src.contextLayout)

	remove_from_attached(do_loc = TRUE)
		..()
		qdel(src)

	mouse_drop(atom/over_object)
		if (!src.active)
			..()

	attackby(obj/item/W, mob/living/user)
		user.lastattacked = get_weakref(user)
		if (istype(W, /obj/item/pen))
			if(!user.literate)
				boutput(user, SPAN_ALERT("You don't know how to write."))
				return ..()
			var/obj/item/pen/pen = W
			pen.in_use = 1
			var/t = input(user, "What do you want to write?", null, null) as null|text
			if (!t)
				pen.in_use = 0
				return
			if ((length(src.words) + length(t)) > src.max_message)
				user.show_text("All that won't fit on [src]!", "red")
				pen.in_use = 0
				return
			logTheThing(LOG_STATION, user, "writes on [src] with [pen] at [log_loc(src)]: [t]")
			t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
			src.words += "[src.words ? "<br>" : ""][t]"
			tooltip_rebuild = TRUE
			pen.in_use = 0
			src.add_fingerprint(user)
			return

		if (src.attached)
			src.attached.Attackby(W, user)
			user.lastattacked = get_weakref(user)
		else
			..()

	New()
		..()
		for(var/actionType in childrentypesof(/datum/contextAction/triage_tag))
			src.contexts += new actionType()

	proc/set_level(level)
		switch(level)
			if (TRIAGE_REMOVE)
				remove_from_attached()
			if (TRIAGE_MINOR)
				src.name = "triage tag - minor"
				src.desc = "Patient has minor injuries."
				src.icon_state = "minor"
			if (TRIAGE_DELAYED)
				src.name = "triage tag - delayed"
				src.desc = "Patient has non-life-threatening injuries."
				src.icon_state = "delayed"
			if (TRIAGE_IMMEDIATE)
				src.name = "triage tag - immediate"
				src.desc = "Patient has life-threatening injuries."
				src.icon_state = "immediate"
			if (TRIAGE_DECEASED)
				src.name = "triage tag - deceased/expectant"
				src.desc = "Patient is deceased or is expected to die even with medical assistance."
				src.icon_state = "deceased"
			if (TRIAGE_UNREVIVABLE)
				src.name = "triage tag - unrevivable"
				src.desc = "Patient is deceased and cannot be cloned."
				src.icon_state = "unrevivable"
		src.tooltip_rebuild = TRUE

/obj/item/triage_tagger
	name = "triage tag box"
	flags = SUPPRESSATTACK
	icon = 'icons/obj/items/triage.dmi'
	icon_state = "box_minor"
	w_class = W_CLASS_TINY
	force = 0
	throwforce = 0

	contextLayout = new /datum/contextLayout/experimentalcircle

	var/triage_level = TRIAGE_MINOR
	var/list/datum/contextAction/contexts = list()

	New()
		..()
		src.set_level(TRIAGE_MINOR)
		for(var/actionType in childrentypesof(/datum/contextAction/triage_tag))
			src.contexts += new actionType()

	attack_self(mob/user as mob)
		user.showContextActions(src.contexts, src, src.contextLayout)

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		var/obj/item/sticker/postit/triage/tag
		if (istype(A, /obj/item/sticker/postit/triage))
			tag = A
		else if (!istype(A, /mob))
			return
		else
			var/mob/M = A
			for (var/obj/item/sticker/postit/triage/content in M.vis_contents)
				tag = content
				break
			if (!tag)
				tag = new /obj/item/sticker/postit/triage()
				tag.afterattack(A, user, reach, params)
		tag.set_level(src.triage_level)
		return TRUE

	proc/set_level(level)
		src.triage_level = level
		switch(level)
			if (TRIAGE_REMOVE)
				src.desc = "Removing triage tags."
				src.icon_state = "box_remove"
			if (TRIAGE_MINOR)
				src.desc = "Patient has minor injuries."
				src.icon_state = "box_minor"
			if (TRIAGE_DELAYED)
				src.desc = "Patient has non-life-threatening injuries."
				src.icon_state = "box_delayed"
			if (TRIAGE_IMMEDIATE)
				src.desc = "Patient has life-threatening injuries."
				src.icon_state = "box_immediate"
			if (TRIAGE_DECEASED)
				src.desc = "Patient is deceased or is expected to die even with medical assistance."
				src.icon_state = "box_deceased"
			if (TRIAGE_UNREVIVABLE)
				src.desc = "Patient is deceased and cannot be cloned."
				src.icon_state = "box_unrevivable"
		src.tooltip_rebuild = TRUE
