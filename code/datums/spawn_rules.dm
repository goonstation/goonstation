ABSTRACT_TYPE(/datum/spawn_rule)
/datum/spawn_rule
	var/slot = null

	proc/apply_to(mob/living/carbon/human/target)
		return

	proc/as_string()
		return

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
		return "\[[src.slot]\] [src.proc_name]([jointext(src.arglist, ", ")])"

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
		return "\[[src.slot]\] [src.var_name] = [src.value]"

var/datum/spawn_rules_controller/spawn_rules_controller = new
/datum/spawn_rules_controller
	var/list/datum/spawn_rule/proc_call/proc_rules = list()
	var/list/datum/spawn_rule/var_edit/var_rules = list()

	proc/apply_to(mob/target)
		for (var/datum/spawn_rule/rule in (src.proc_rules + src.var_rules))
			rule.apply_to(target)

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
		var/slot = src.get_slot_from_item(thing)
		for (var/datum/spawn_rule/var_edit/rule in spawn_rules_controller.var_rules)
			if (rule.var_name == variable && rule.slot == slot)
				spawn_rules_controller.var_rules -= rule
				break
		var/datum/spawn_rule/var_edit/rule = new(variable, newval)
		rule.slot = slot
		spawn_rules_controller.var_rules += rule
		for_by_tcl(human, /mob/living/carbon/human)
			if (istype(human, src.type)) //no recursion allowed
				continue
			rule.apply_to(human)

	proc/proc_called(atom/thing, procname, list/arglist)
		var/slot = src.get_slot_from_item(thing)
		for (var/datum/spawn_rule/proc_call/rule in spawn_rules_controller.proc_rules)
			if (rule.proc_name == procname && rule.slot == slot)
				spawn_rules_controller.proc_rules -= rule
				break
		var/datum/spawn_rule/proc_call/rule = new(procname, arglist.Copy())
		rule.slot = slot
		spawn_rules_controller.proc_rules += rule
		for_by_tcl(human, /mob/living/carbon/human)
			if (istype(human, src.type)) //no recursion allowed
				continue
			rule.apply_to(human)

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
			for (var/datum/spawn_rule/rule in (spawn_rules_controller.proc_rules + spawn_rules_controller.var_rules))
				rule_strings[rule.as_string()] = rule
			var/chosen = tgui_input_list(usr, "Choose rule to delete", "Spawn rules", rule_strings)
			if (!chosen || !(chosen in rule_strings))
				return
			var/datum/spawn_rule/rule = rule_strings[chosen]
			if (istype(rule, /datum/spawn_rule/var_edit))
				spawn_rules_controller.var_rules -= rule
			else
				spawn_rules_controller.proc_rules -= rule

