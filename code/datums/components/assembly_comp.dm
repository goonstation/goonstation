TYPEINFO(/datum/component/assembly)
	initialization_args = list(
		ARG_INFO("to_combine_item", DATA_INPUT_TYPE, "path or list of items that will trigger this proc when used on. Can take tool-bitflags like TOOL_CUTTING."),
		ARG_INFO("proc_to_call", DATA_INPUT_REF, "The proc reference that will be called when the item can be assembled"),
		ARG_INFO("assembly_information", DATA_INPUT_TEXT, "This is a string is used to differentiate between the procs if multiple assembly-components are attached to an item"),
		ARG_INFO("on_tool_attack", DATA_INPUT_NUM, "Set this to TRUE if you want the component to fire if the construction should go two-ways.", FALSE),
	)

///This component calls a procref with a assembly_information string on the atom it was added to when it gets attacked with an object specified in the to_combine_item
///This component can be used to get the convulent if-then-else trees of assemblies under control

/datum/component/assembly
	///The item(s) that are used to combine with the atom this component is attached to
	///use a tool-bitflags like TOOL_CUTTING, if you want to go with groups of tools
	var/to_combine_item = null
	///The string that will get passed to differentiate between different assembly procs added to an object
	var/assembly_information = null
	///The Procref that will get called when the items are compatible
	var/valid_assembly_proc = null



/datum/component/assembly/Initialize(var/required_item, var/called_proc, var/passed_assembly_information, var/on_tool_attack = FALSE)
	if(!parent || !required_item || !called_proc || !passed_assembly_information)
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.to_combine_item = required_item
	src.assembly_information = passed_assembly_information
	src.valid_assembly_proc = called_proc
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(attackby))
	if(on_tool_attack)
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_POST, PROC_REF(on_after_attack))

/datum/component/assembly/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	UnregisterSignal(parent, COMSIG_ATTACKBY)


/datum/component/assembly/proc/on_after_attack(var/atom/to_combine_atom, var/mob/user, var/damage)
	return try_combination(to_combine_atom, user)

/datum/component/assembly/proc/attackby(var/atom/to_combine_atom, var/mob/user, var/params, var/is_special)
	return try_combination(to_combine_atom, user)

/datum/component/assembly/proc/try_combination(var/atom/checked_atom, var/mob/user)
	var/is_combineable = FALSE
	//if to_combine_item is a list, we look if we find the item in there
	if (islist(src.to_combine_item))
		var/list/combineable_items = src.to_combine_item
		if (checked_atom in combineable_items)
			is_combineable = TRUE
	//if it is a number, it most likely is a bitflag we passed
	else if (isnum_safe(src.to_combine_item))
		if (istool(checked_atom, src.to_combine_item))
			is_combineable = TRUE
	else if (istype(checked_atom, src.to_combine_item))
		is_combineable = TRUE

	if(is_combineable)
		//if the assembly is valid, we go and call the proc
		call(parent, src.valid_assembly_proc)(checked_atom, user)
	 //we need to return true so onattack does not trigger. Else we would still attack a completed assembly
	return is_combineable
