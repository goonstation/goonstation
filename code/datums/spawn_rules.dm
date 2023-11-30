var/datum/spawn_rules_controller/spawn_rules_controller = new
/datum/spawn_rules_controller
	///Associative list of proc names to arg lists
	var/list/proc_calls = list()
	///Associative list of variables to values
	var/list/var_edits = list()
	//in a beautiful world these could all just be anonymous functions :pleading:

	ui_data(mob/user)
		return list(
			"proc_calls" = proc_calls,
			"var_edits" = var_edits,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		switch(action)
			if ("deleteVar")
				src.var_edits -= params["var_name"]
			if ("deleteProc")
				src.proc_calls -= params["proc_name"]
		return TRUE

	proc/apply_to(mob/target)
		for (var/proc_name in src.proc_calls)
			call(target, proc_name)(arglist(src.proc_calls[proc_name]))
		for (var/var_name in src.var_edits)
			if (hasvar(target, var_name))
				target.vars[var_name] = src.var_edits[var_name]

/mob/living/carbon/human/the_template
	real_name = "\improper The Template"
	onVarChanged(variable, oldval, newval)
		. = ..()
		spawn_rules_controller.var_edits[variable] = newval
		for_by_tcl(human, /mob/living/carbon/human)
			if (istype(human, src.type)) //no recursion allowed
				continue
			human.vars[variable] = newval
			human.onVarChanged(variable, oldval, newval)

	onProcCalled(procname, list/arglist)
		. = ..()
		spawn_rules_controller.proc_calls[procname] = arglist.Copy() //I'm sure this is safe
		for_by_tcl(human, /mob/living/carbon/human)
			if (istype(human, src.type)) //no recursion allowed
				continue
			call(human, procname)(arglist(arglist))
			human.onProcCalled(procname, arglist)
