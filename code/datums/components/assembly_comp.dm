TYPEINFO(/datum/component/assembly)
	initialization_args = list(
		ARG_INFO("to_combine_item", DATA_INPUT_TYPE, "path or list of items that will trigger this proc when used on. Can take tool-bitflags like TOOL_CUTTING."),
		ARG_INFO("proc_to_call", DATA_INPUT_REF, "The proc reference that will be called when the item can be assembled"),
		ARG_INFO("on_tool_attack", DATA_INPUT_BOOL, "Set this to TRUE if you want the component to fire if the construction should go two-ways.", FALSE),
	)

///This component calls a procref with a assembly_information string on the atom it was added to when it gets attacked with an object specified in the to_combine_item
///This component can be used to get the convulent if-then-else trees of assemblies under control
///Make the proc you call on sucessfull assembly return TRUE. Else the attack will go through!

/datum/component/assembly
	dupe_mode = COMPONENT_DUPE_ALLOWED //We want to have multiple differnt assembly types on an item for different assembly steps
	///The item(s) that are used to combine with the atom this component is attached to
	///use a tool-bitflags like TOOL_CUTTING, if you want to go with groups of tools
	var/to_combine_item = null
	///The Procref that will get called when the items are compatible
	var/valid_assembly_proc = null



/datum/component/assembly/Initialize(var/required_item, var/called_proc, var/on_tool_attack = FALSE)
	if(!src.parent || !required_item || !called_proc)
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.to_combine_item = required_item
	src.valid_assembly_proc = called_proc
	RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(attackby))
	if(on_tool_attack)
		RegisterSignal(src.parent, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(on_pre_attack))

/datum/component/assembly/UnregisterFromParent()
	. = ..()
	UnregisterSignal(src.parent, COMSIG_ITEM_ATTACKBY_PRE)
	UnregisterSignal(src.parent, COMSIG_ATTACKBY)


/datum/component/assembly/proc/on_pre_attack(var/atom/affected_parent, var/atom/to_combine_atom, var/mob/user, var/damage)
	return try_combination(to_combine_atom, user)

/datum/component/assembly/proc/attackby(var/atom/affected_parent, var/atom/to_combine_atom, var/mob/user, var/params, var/is_special)
	return try_combination(to_combine_atom, user)

/datum/component/assembly/proc/try_combination(var/atom/checked_atom, var/mob/user)
	var/is_combinable = FALSE
	//if to_combine_item is a list, we look if we find the item in there
	if (islist(src.to_combine_item))
		var/list/combinable_items = src.to_combine_item
		for(var/to_checked_type in combinable_items)
			if(istype(checked_atom, to_checked_type))
				is_combinable = TRUE
	//if it is a number, it most likely is a bitflag we passed
	else if (isnum_safe(src.to_combine_item))
		if (istool(checked_atom, src.to_combine_item))
			is_combinable = TRUE
	else if (istype(checked_atom, src.to_combine_item))
		is_combinable = TRUE

	if(is_combinable)
		//if the assembly is valid, we go and call the proc
		//we need to return true so onattack does not trigger. Else we would still attack a completed assembly
		return call(src.parent, src.valid_assembly_proc)(checked_atom, user)
