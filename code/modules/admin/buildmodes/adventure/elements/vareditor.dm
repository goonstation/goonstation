/// Adventure puzzle thing - edits set var (via .name or .interesting)
/obj/adventurepuzzle/triggerable/targetable/varedit
	name = "vareditor"
	invisibility = 20
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "var_editor"
	density = 0
	opacity = 0
	anchored = 1
	target = null
	var/var_name = ""
	var/var_value = null
	var/var_object = "usr"

	var/static/list/triggeracts = list("Trigger" = "trigger")

	New(loc, var/to_set)
		..()
		if (to_set)
			var_object = to_set
		SPAWN_DBG(2 SECONDS) // let the world load
			for (var/atom/A as anything in get_turf(src))
				if (src.var_object == A.name || src.var_object == A.interesting) // oh boo hoo, sue me for misuse of variables
					var_object = A
					break

	trigger_actions()
		return triggeracts

	trigger(act)
		switch(act)
			if ("trigger")
				var/datum/actual_object = var_object
				if(actual_object == "usr")
					actual_object = usr
				var_object.vars[var_name] = var_value
