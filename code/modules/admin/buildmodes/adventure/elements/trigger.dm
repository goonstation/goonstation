/datum/puzzlewizard/trigger
	name = "AB CREATE: Invisible trigger"
	var/trigger_count = 1
	var/list/selected_triggerable = list()
	var/selection

	initialize()
		selection = new /obj/adventurepuzzle/marker
		trigger_count = input("How many times should this trigger work? (-1 = infinite)", "Trigger count", 1) as num
		boutput(usr, "<span class='notice'>Left click to place triggers, right click triggerables to (de)select them for automatic assignment to the triggers. Ctrl+click anywhere to finish.</span>")
		boutput(usr, "<span class='notice'>NOTE: Select stuff first, then make triggers for extra comfort!</span>")

	proc/clear_selections()
		for (var/obj/O in selected_triggerable)
			O.overlays -= selection
		selected_triggerable.len = 0

	disposing()
		clear_selections()
		qdel(selection)
		..()

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				clear_selections()
				return
			if (T)
				var/obj/adventurepuzzle/triggerer/trigger/trigger = new /obj/adventurepuzzle/triggerer/trigger(T)
				trigger.icon_state = "trigger"
				trigger.triggered = selected_triggerable.Copy()
				trigger.trigger_count = trigger_count
		else if ("right" in pa)
			if (istype(object, /obj/adventurepuzzle/triggerable))
				if (object in selected_triggerable)
					object.overlays -= selection
					selected_triggerable -= object
				else
					var/list/actions = object:trigger_actions()
					if (islist(actions) && length(actions))
						var/act_name = input("Do what?", "Do what?", actions[1]) in actions
						var/act = actions[act_name]
						object.overlays += selection
						selected_triggerable += object
						selected_triggerable[object] = act
					else
						boutput(user, "<span class='alert'>ERROR: Missing actions definition for triggerable [object].</span>")

/obj/adventurepuzzle/triggerer/trigger
	name = "invisible trigger"
	invisibility = INVIS_ADVENTURE
	icon_state = "trigger"
	density = 0
	opacity = 0
	anchored = 1
	var/trigger_count = 1

	Crossed(atom/movable/O)
		..()
		if (isliving(O) && trigger_count)
			if (trigger_count > 0)
				trigger_count--
			post_trigger()

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].trigger_count"] << trigger_count

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].trigger_count"] >> trigger_count
