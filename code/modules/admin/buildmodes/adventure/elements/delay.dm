/datum/puzzlewizard/delay
	name = "AB CREATE: Delay"
	var/time_delay = 10
	var/periodic = 0
	var/list/selected_triggerable = list()
	var/selection

	initialize()
		selection = new /obj/adventurepuzzle/marker
		time_delay = input("Timing amount (in 1/10 seconds)", "Timing amount", 5) as num
		var/per = input("Is this periodic? (Repeatedly triggers until aborted if started.)", "Periodic", "yes") in list("yes", "no")
		periodic = (per == "yes") ? 1 : 0
		boutput(usr, "<span class='notice'>Left click to place timers, right click triggerables to (de)select them for automatic assignment to the timers. Ctrl+click anywhere to finish.</span>")
		boutput(usr, "<span class='notice'>Right click delays to launch them immediately. (Useful for triggering periodic delays)</span>")
		boutput(usr, "<span class='notice'>NOTE: Select stuff first, then make buttons for extra comfort!</span>")

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
				var/obj/adventurepuzzle/triggerable/triggerer/delay/timer = new /obj/adventurepuzzle/triggerable/triggerer/delay(T)
				timer.time_delay = time_delay
				timer.periodic = periodic
				timer.triggered = selected_triggerable.Copy()
		else if ("right" in pa)
			if (istype(object, /obj/adventurepuzzle/triggerable/triggerer/delay))
				var/obj/adventurepuzzle/triggerable/triggerer/delay/timer = object
				timer.trigger("start")
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

/obj/adventurepuzzle/triggerable/triggerer/delay
	name = "delay"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/obj/items/device.dmi'
	icon_state = "timer0"
	density = 0
	opacity = 0
	anchored = ANCHORED
	var/time_delay = 10
	var/curr_time
	var/aborted = 1
	var/periodic = 0

	var/static/list/triggeracts = list("Abort timing" = "abort", "Do nothing" = "nop", "Start timing" = "start")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("abort")
				aborted = 1
			if ("start")
				if (!aborted)
					return
				aborted = 0
				curr_time = time_delay
				SPAWN(0)
					while (1)
						if (aborted)
							return
						curr_time--
						if (curr_time <= 0)
							post_trigger()
							if (periodic)
								curr_time = time_delay
							else
								aborted = 1
								return
						sleep(0.1 SECONDS)

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].time_delay"] << time_delay
		F["[path].periodic"] << periodic

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].time_delay"] >> time_delay
		F["[path].periodic"] >> periodic
