/// Adventure puzzle thing - calls set proc on a linked object (via .name or .interesting)
/obj/adventurepuzzle/triggerable/targetable/proccall
	name = "proccaller"
	invisibility = 20
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "proc_caller"
	density = 0
	opacity = 0
	anchored = 1
	target = null
	var/procpath = ""
	var/arg = null
	var/object_to_call = null

	var/static/list/triggeracts = list("Trigger" = "trigger")

	New(loc, var/to_set)
		..()
		if (to_set)
			object_to_call = to_set
		SPAWN_DBG(2 SECONDS) // let the world load
			for (var/atom/A as() in get_turf(src))
				if (src.object_to_call == A.name || src.object_to_call == A.interesting) // oh boo hoo, sue me for misuse of variables
					object_to_call = A
					break

	trigger_actions()
		return triggeracts

	trigger(act)
		switch(act)
			if ("trigger")
				call(object_to_call, procpath)(arg) //want more arguments? code it yourself
				return
