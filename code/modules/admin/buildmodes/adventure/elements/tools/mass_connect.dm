/datum/puzzlewizard/massconnecttool
	name = "AB TOOL: Mass Connections"
	var/selection

	var/obj/adventurepuzzle/triggerer/selected
	var/list/additional = list()

	var/typesel = null
	var/namesel = null
	var/trigger_act = null
	var/list/add_acts = list()

	var/turf/A

	initialize()
		selection = new /obj/adventurepuzzle/marker
		boutput(usr, "<span class='notice'>First, left click a triggerer to select it. Then left click an existing triggerable to select its type and trigger actions.</span>")
		boutput(usr, "<span class='notice'>Finally, use right click to select a rectangular area (as in wide spawn mode) to assign ALL triggerables of that type with the same name to the selected triggerer. Ctrl+click to finish.</span>")
		boutput(usr, "<span class='notice'>Right clicking a triggerer will clear all of its connections.</span>")
		boutput(usr, "<span class='notice'>Valid triggerers: trigger, button, pressure pad, key, remote control</span>")
		boutput(usr, "<span class='notice'>Valid triggerables: door, spawn location, light emitter, sliding wall, traps</span>")

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		var/turf/T = get_turf(object)
		if ("left" in pa)
			if ("ctrl" in pa)
				finished = 1
				clear_markers()
				return
			// fugliest hack shit 2014. someone will *eventually* decide to change one without mirroring it in the other and the game will break terribly
			if (istype(object, /obj/adventurepuzzle/triggerer) || istype(object, /obj/item/adventurepuzzle/triggerer))
				clear_markers()
				selected = object
				boutput(user, "Selected [object].")
				equip_markers()
				typesel = null
				namesel = null
				trigger_act = null
				add_acts = null
				if (A)
					A.overlays -= selection
					A = null
			else if (istype(object, /obj/adventurepuzzle/triggerable) && selected)
				if (A)
					A.overlays -= selection
					A = null
				typesel = object.type
				namesel = object:name
				var/list/acts = object:trigger_actions()
				var/act = acts[1]
				var/newname = input("Set trigger action for [selected] on [typesel].", "Set action", act) in acts
				trigger_act = acts[newname]

				var/add = selected.special_triggers_required()
				if (add && islist(add))
					for (var/actname in add)
						newname = input("Set [actname] action for [selected] on [typesel].", "Set action", act) in acts
						add_acts += acts[newname]
				boutput(user, "Triggerable type set.")
			else if (istype(object, /obj/adventurepuzzle/triggerable))
				boutput(user, "<span class='alert'>You must select a triggerer first!</span>")
		else if ("right" in pa)
			if (istype(object, /obj/adventurepuzzle/triggerer) || istype(object, /obj/item/adventurepuzzle/triggerer))
				var/obj/adventurepuzzle/triggerer/Tr = object //hack
				Tr.triggered.len = 0 // hack hack hack
				Tr.special_trigger_clear() // HACK HACK HACK
			if (!selected || !typesel)
				boutput(user, "<span class='alert'>Select a triggerer and a triggerable type first!</span>")
			if (A && T == A)
				A.overlays -= selection
				A = null
			else if (A)
				var/turf/B = T
				if (!B)
					return
				var/count = 0
				for (var/turf/V in block(A,B))
					for (var/obj/adventurepuzzle/triggerable/W in V)
						// NOTE: only checking for exact types!
						if (W.type == typesel && W.name == namesel)
							count++
							if (!(W in selected.triggered))
								selected.triggered += W
							selected.triggered[W] = trigger_act
							selected.special_trigger_set(W, add_acts)
				A.overlays -= selection
				A = null
				boutput(user, "<span class='notice'>[count] objects added to [selected].</span>")
			else
				A = T
				A.overlays += selection

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
