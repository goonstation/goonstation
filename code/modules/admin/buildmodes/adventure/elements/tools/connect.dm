/datum/puzzlewizard/connecttool
	name = "AB TOOL: Connections"
	var/selection

	var/obj/adventurepuzzle/triggerer/selected

	initialize()
		selection = new /obj/adventurepuzzle/marker
		boutput(usr, "<span class='notice'>Left click a triggerer to select it. Left click a triggerable while a triggerer is selected to assign, right click to unassign. Ctrl+click to finish.</span>")
		boutput(usr, "<span class='notice'>Valid triggerers: trigger, button, pressure pad, key, remote control</span>")
		boutput(usr, "<span class='notice'>Valid triggerables: door, spawn location, light emitter, sliding wall, traps</span>")

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		var/turf/T = get_turf(object)
		if ("left" in pa)
			if ("ctrl" in pa)
				finished = 1
				clear_markers()
				return
			// disregard the thing below this is the worst thing 2014
			var/use_as = null
			if (istype(object, /obj/adventurepuzzle/triggerable/triggerer))
				use_as = input("Use this object as a: ", "Use as", "triggerable") in list("triggerable", "triggerer")
			// fugliest hack shit 2014. someone will *eventually* decide to change one without mirroring it in the other and the game will break terribly
			if (istype(object, /obj/adventurepuzzle/triggerer) || istype(object, /obj/item/adventurepuzzle/triggerer) || use_as == "triggerer")
				clear_markers()
				selected = object
				boutput(user, "Selected [object]. Showing connections.")
				equip_markers()
			else if ((istype(object, /obj/adventurepuzzle/triggerable) || use_as == "triggerable") && selected)
				if (object in selected.triggered)
					var/act = selected.triggered[object]
					var/list/acts = object:trigger_actions()
					var/newname = input("Modify trigger action for [selected] on [object].", "Modify action", act) in acts
					selected.triggered[object] = acts[newname]
					selected.special_trigger_input(object)
				else
					var/list/acts = object:trigger_actions()
					var/act = acts[1]
					var/newname = input("Set trigger action for [selected] on [object].", "Set action", act) in acts
					selected.triggered += object
					selected.triggered[object] = acts[newname]
					selected.special_trigger_input(object)
					object.overlays += selection
			else if (istype(object, /obj/adventurepuzzle/triggerable) || use_as == "triggerable")
				boutput(user, "<span class='alert'>Select a triggerer first!</span>")
		else if ("right" in pa)
			if (T)
				if (istype(object, /obj/adventurepuzzle/triggerable))
					if (object in selected.triggered)
						selected.triggered -= object
						selected.special_trigger_remove(object)
						object.overlays -= selection

	disposing()
		clear_markers()
		qdel(selection)
		..()

	proc/clear_markers()
		if (!selected)
			return
		for (var/obj/O in selected.triggered)
			O.overlays -= selection

	proc/equip_markers()
		if (!selected)
			return
		for (var/obj/O in selected.triggered)
			O.overlays += selection
