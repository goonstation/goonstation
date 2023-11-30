ABSTRACT_TYPE(/datum/spawn_rule)
/datum/spawn_rule
	var/slot = null

	proc/apply_to(mob/target)
		return

/datum/spawn_rule/proc_call
	var/proc_name = ""
	var/list/arglist = null

	New(proc_name, list/arglist)
		..()
		src.proc_name = proc_name
		src.arglist = arglist

	apply_to(mob/target)
		if (!src.slot)
			call(target, src.proc_name)(arglist(src.arglist))

/datum/spawn_rule/var_edit
	var/var_name = ""
	var/value = null

	New(var_name, value)
		..()
		src.var_name = var_name
		src.value = value

	apply_to(mob/target)
		if (!src.slot)
			if (hasvar(target, var_name))
				target.onVarChanged(var_name, target.vars[var_name], value)
				target.vars[var_name] = value

var/datum/spawn_rules_controller/spawn_rules_controller = new
/datum/spawn_rules_controller
	var/list/datum/spawn_rule/proc_call/proc_rules = list()
	var/list/datum/spawn_rule/var_edit/var_rules = list()

	// ui_data(mob/user)
	// 	return list(
	// 		"proc_calls" = proc_calls,
	// 		"var_edits" = var_edits,
	// 	)

	// ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// 	switch(action)
	// 		if ("deleteVar")
	// 			src.var_edits -= params["var_name"]
	// 		if ("deleteProc")
	// 			src.proc_calls -= params["proc_name"]
	// 	return TRUE

	proc/apply_to(mob/target)
		for (var/datum/spawn_rule/rule in (src.proc_rules + src.var_rules))
			rule.apply_to(target)

/mob/living/carbon/human/the_template
	real_name = "\improper The Template"

	onVarChanged(variable, oldval, newval)
		. = ..()
		for (var/datum/spawn_rule/var_edit/rule in spawn_rules_controller.var_rules)
			if (rule.var_name == variable)
				spawn_rules_controller.var_rules -= rule
				break
		var/datum/spawn_rule/var_edit/rule = new(variable, newval)
		spawn_rules_controller.var_rules += rule
		for_by_tcl(human, /mob/living/carbon/human)
			if (istype(human, src.type)) //no recursion allowed
				continue
			rule.apply_to(human)

	onProcCalled(procname, list/arglist)
		. = ..()
		for (var/datum/spawn_rule/proc_call/rule in spawn_rules_controller.proc_rules)
			if (rule.proc_name == procname)
				spawn_rules_controller.proc_rules -= rule
				break
		var/datum/spawn_rule/proc_call/rule = new(procname, arglist.Copy())
		spawn_rules_controller.proc_rules += rule
		for_by_tcl(human, /mob/living/carbon/human)
			if (istype(human, src.type)) //no recursion allowed
				continue
			rule.apply_to(human)
