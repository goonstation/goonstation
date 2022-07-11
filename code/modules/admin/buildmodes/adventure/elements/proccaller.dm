/// Adventure puzzle thing - calls set proc on a linked object (via .name or .interesting)
/obj/adventurepuzzle/triggerable/targetable/proccall
	name = "proccaller"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "proc_caller"
	density = 0
	opacity = 0
	anchored = 1
	target = null
	var/procpath = ""
	var/arg = null
	var/list/arguments = null
	var/object_to_call = "usr"

	var/static/list/triggeracts = list("Trigger" = "trigger")

	New(loc, var/to_set)
		..()
		if (to_set)
			object_to_call = to_set
		SPAWN(2 SECONDS) // let the world load
			for (var/atom/A as anything in get_turf(src))
				if (src.object_to_call == A.name || src.object_to_call == A.interesting) // oh boo hoo, sue me for misuse of variables
					object_to_call = A
					break

	trigger_actions()
		return triggeracts

	proc/process_argument(arg)
		if(arg == "usr")
			return usr
		else if(length(arg) > 3 && copytext(arg, 1, 5) == "usr.")
			. = usr
			for(var/variable in splittext(copytext(arg, 5), "."))
				if(isnull(.))
					return
				. = (.):vars[variable]
			return
		return arg

	trigger(act)
		switch(act)
			if ("trigger")
				var/list/proc_args = src.arguments
				if(islist(proc_args))
					proc_args = proc_args.Copy()
				else if(isnull(proc_args))
					proc_args = list(src.arg)
				for(var/i in 1 to length(proc_args))
					proc_args[i] = process_argument(proc_args[i])
				if (object_to_call)
					var/actual_object = process_argument(object_to_call)
					call(actual_object, procpath)(arglist(proc_args))
				else
					call(procpath)(arglist(proc_args))
				return
