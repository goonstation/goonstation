ABSTRACT_TYPE(/datum/spawn_rule)
/datum/spawn_rule
	var/slot = null

	proc/apply_to(mob/living/carbon/human/target)
		return

	proc/as_string()
		return

	proc/is_equal(datum/spawn_rule/other)
		return FALSE

/datum/spawn_rule/proc_call
	var/proc_name = ""
	var/list/arglist = null

	New(proc_name, list/arglist)
		..()
		src.proc_name = proc_name
		src.arglist = arglist

	apply_to(mob/living/carbon/human/target)
		if (src.slot)
			target = target.get_slot(src.slot)
		call(target, src.proc_name)(arglist(src.arglist))

	as_string()
		return "\[[src.slot || "self"]\] [src.proc_name]([jointext(src.arglist, ", ")])"

	is_equal(datum/spawn_rule/proc_call/rule)
		return istype(rule) && rule.proc_name == src.proc_name //we're just going to not check argument equality because like, nah

/datum/spawn_rule/var_edit
	var/var_name = ""
	var/value = null

	New(var_name, value)
		..()
		src.var_name = var_name
		src.value = value

	apply_to(mob/living/carbon/human/target)
		if (src.slot)
			target = target.get_slot(src.slot)
		if (hasvar(target, var_name))
			target.onVarChanged(var_name, target.vars[var_name], value)
			target.vars[var_name] = value

	as_string()
		return "\[[src.slot || "self"]\] [src.var_name] = [src.value]"

	is_equal(datum/spawn_rule/var_edit/rule)
		return istype(rule) && rule.var_name == src.var_name

var/datum/spawn_rules_controller/spawn_rules_controller = new
/datum/spawn_rules_controller
	var/list/datum/spawn_rule/rules = list()

	proc/apply_to(mob/target)
		for (var/datum/spawn_rule/rule as anything in src.rules)
			rule.apply_to(target)

	proc/add_rule(datum/spawn_rule/new_rule)
		for (var/datum/spawn_rule/rule as anything in src.rules)
			if (rule.is_equal(new_rule))
				src.rules -= rule //let the garbage collector take ye
				break //there should only ever be one match
		src.rules += new_rule
		for_by_tcl(human, /mob/living/carbon/human)
			if (istype(human, /mob/living/carbon/human/normal/assistant/the_template)) //no recursion allowed
				continue
			new_rule.apply_to(human)

/mob/living/carbon/human/normal/assistant/the_template
	New()
		..()
		real_name = "\improper The Template"
		src.equip_new_if_possible(/obj/item/clothing/suit/jean_jacket, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(/obj/item/clothing/head/frog_hat, SLOT_HEAD)
		src.equip_new_if_possible(/obj/item/clothing/glasses/toggleable/atmos, SLOT_GLASSES)
		src.equip_new_if_possible(/obj/item/clothing/gloves/yellow, SLOT_GLOVES)
		for (var/slot in all_slots)
			var/obj/item/equipped = src.get_slot(slot)
			if (equipped)
				RegisterSignal(equipped, COMSIG_VARIABLE_CHANGED, PROC_REF(var_changed))
				RegisterSignal(equipped, COMSIG_PROC_CALLED, PROC_REF(proc_called))

	get_help_message(dist, mob/user)
		if (isadmin(user))
			return "All varedits done to me or my equipment will apply to all humans and all humans who join or spawn. Click me to remove previously set rules."

	disposing()
		. = ..()
		for (var/slot in all_slots)
			var/obj/item/equipped = src.get_slot(slot)
			if (equipped)
				UnregisterSignal(equipped, COMSIG_VARIABLE_CHANGED)
				UnregisterSignal(equipped, COMSIG_PROC_CALLED)

	proc/var_changed(atom/thing, variable, oldval, newval)
		var/datum/spawn_rule/var_edit/rule = new(variable, newval)
		rule.slot = src.get_slot_from_item(thing)
		spawn_rules_controller.add_rule(rule)

	proc/proc_called(atom/thing, procname, list/arglist)
		var/datum/spawn_rule/proc_call/rule = new(procname, arglist.Copy())
		rule.slot = src.get_slot_from_item(thing)
		spawn_rules_controller.add_rule(rule)

	onVarChanged(variable, oldval, newval)
		. = ..()
		src.var_changed(src, variable, oldval, newval)

	onProcCalled(procname, list/arglist)
		. = ..()
		src.proc_called(src, procname, arglist)

	Click(location, control, params)
		var/list/paramslist = params2list(params)
		if (isadmin(usr) && !("alt" in paramslist))
			var/list/rule_strings = list()
			for (var/datum/spawn_rule/rule in (spawn_rules_controller.rules))
				rule_strings[rule.as_string()] = rule
			var/chosen = tgui_input_list(usr, "Choose rule to delete", "Spawn rules", rule_strings)
			if (!chosen || !(chosen in rule_strings))
				return
			var/datum/spawn_rule/rule = rule_strings[chosen]
			spawn_rules_controller.rules -= rule

