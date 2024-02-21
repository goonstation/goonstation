ABSTRACT_TYPE(/datum/spawn_rule)
///Represents a "rule" applied to a human or something they are wearing on spawn
/datum/spawn_rule
	///The slot this rule applies to, a null slot means it applies to the human directly. See clothing.dm for defines
	var/slot = null

	///Apply the rule to a human mob, returns the atom to target
	proc/apply_to(mob/living/carbon/human/target)
		if (src.slot)
			return target.get_slot(src.slot)
		else
			return target
	///Return a string representation of this rule to be used to identify it in the removal UI (must be unique)
	proc/as_string()
		return

	///Determine if a given rule should override this one, ie they edit the same var or call the same proc
	proc/is_equal(datum/spawn_rule/other)
		return FALSE

///A proc call, complete with arguments list
/datum/spawn_rule/proc_call
	var/proc_name = ""
	/// Arguments list, can be associative or not
	var/list/arglist = null

	New(proc_name, list/arglist)
		..()
		src.proc_name = proc_name
		src.arglist = arglist

	apply_to(mob/living/carbon/human/target)
		target = ..()
		call(target, src.proc_name)(arglist(src.arglist))

	as_string()
		var/arg_string = ""
		for (var/arg in src.arglist) //have to account for associative arglists
			if (src.arglist[arg])
				arg_string += "[arg] = [src.arglist[arg]]"
			else
				arg_string += "[arg]"
			if (src.arglist.Find(arg) < length(src.arglist))
				arg_string += ", "
		return "\[[src.slot || "self"]\] [src.proc_name]([arg_string])"

	is_equal(datum/spawn_rule/proc_call/rule)
		return istype(rule) && rule.proc_name == src.proc_name //we're just going to not check argument equality because like, nah

///A var edit, var name and value to set it to
/datum/spawn_rule/var_edit
	var/var_name = ""
	var/value = null

	New(var_name, value)
		..()
		src.var_name = var_name
		src.value = value

	apply_to(mob/living/carbon/human/target)
		target = ..()
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

	///Apply all current rules to the target mob
	proc/apply_to(mob/living/carbon/human/target)
		for (var/datum/spawn_rule/rule as anything in src.rules)
			rule.apply_to(target)

	///Remove any rules the new rule should override, add it to the list and apply it to all humans
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

///A template human, varedit or proc call this to generate rules
/mob/living/carbon/human/normal/assistant/the_template
	New()
		..()
		real_name = "\improper The Template"
		src.equip_new_if_possible(/obj/item/clothing/suit/jean_jacket, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(/obj/item/clothing/head/frog_hat, SLOT_HEAD)
		src.equip_new_if_possible(/obj/item/clothing/glasses/toggleable/atmos, SLOT_GLASSES)
		src.equip_new_if_possible(/obj/item/clothing/gloves/yellow, SLOT_GLOVES)
		spawn_rules_controller.apply_to(src) //apply all currently existing rules
		for (var/slot in all_slots)
			var/obj/item/equipped = src.get_slot(slot)
			if (equipped)
				RegisterSignal(equipped, COMSIG_VARIABLE_CHANGED, PROC_REF(var_changed))
				RegisterSignal(equipped, COMSIG_PROC_CALLED, PROC_REF(proc_called))

	get_help_message(dist, mob/user)
		if (isadmin(user))
			return "All varedits done to me or my equipment will apply to all humans and all humans who join or spawn. Click me to remove previously set rules."

	disposing()
		for (var/slot in all_slots)
			var/obj/item/equipped = src.get_slot(slot)
			if (equipped)
				UnregisterSignal(equipped, COMSIG_VARIABLE_CHANGED)
				UnregisterSignal(equipped, COMSIG_PROC_CALLED)
		. = ..()

	///Called when a var is manually edited on this mob or its equipment
	proc/var_changed(atom/thing, variable, oldval, newval)
		var/datum/spawn_rule/var_edit/rule = new(variable, newval)
		rule.slot = src.get_slot_from_item(thing)
		spawn_rules_controller.add_rule(rule)

	///Called when a proc is manually called on this mob or its equipment (also called by trait and bioeffect admin editors for ease of use)
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

	///Show admins a list of rules to delete
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

