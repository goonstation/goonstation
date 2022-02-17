/datum/puzzlewizard/portal
	name = "AB TOOL: Portals"
	var/turf/target = null
	var/selection

	initialize()
		selection = new /obj/adventurepuzzle/marker
		boutput(usr, "<span class='notice'>Select a target location with right click, then left click to place portals. Ctrl+click anywhere to finish.</span>")

	proc/clear_selection()
		if (!selection)
			return
		target.overlays -= selection
		qdel(selection)
		selection = null

	disposing()
		clear_selection()
		..()

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			if (!target)
				boutput(user, "<span class='alert'>Select a target first!</span>")
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				clear_selection()
				return
			if (T)
				var/obj/perm_portal/P = new /obj/perm_portal(T)
				P.target = target
		else if ("right" in pa)
			var/turf/T = get_turf(object)
			if (T)
				if (target)
					target.overlays -= selection
				target = T
				target.overlays += selection
				boutput(user, "<span class='notice'>Target set.</span>")

/obj/perm_portal
	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		var/blx = sandbox.context["min_x"]
		var/bly = sandbox.context["min_y"]
		var/trfx = sandbox.context["max_x"]
		var/trfy = sandbox.context["max_y"]
		var/pz = sandbox.context["z"]
		if (!blx || !bly || !trfx || !trfy || !pz)
			return // errrrorrrz
		var/turf/T = target
		if (!isturf(T))
			return // nope
		..()
		var/tt = 0
		if (T.z == pz && T.x >= blx && T.x <= trfx && T.y >= bly && T.y <= trfy)
			target = "ser:\ref[target]"
		else
			target = "x=[T.x];y=[T.y];z=[T.z]"
			tt = 1
		F["[path].absolute"] << tt
		F["[path].target"] << target

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		var/target_t
		var/target_s
		F["[path].absolute"] >> target_t
		F["[path].target"] >> target_s
		if (target_t)
			var/list/pa = params2list(target_s)
			var/tx = text2num(pa["x"])
			var/ty = text2num(pa["y"])
			var/tz = text2num(pa["z"])
			var/turf/T = locate(tx, ty, tz)
			if (T)
				target = T
		else
			. |= DESERIALIZE_NEED_POSTPROCESS
			target = target_s

	deserialize_postprocess()
		if (istext(target))
			target = locate(target)
		if (!target)
			qdel(src) // no nullzone portals pls
