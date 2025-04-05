TYPEINFO(/datum/component/assembly)
	initialization_args = list(
		ARG_INFO("to_combine_item", DATA_INPUT_TYPE, "path or list of items that will trigger this proc when used on. Can take tool-bitflags like TOOL_CUTTING."),
		ARG_INFO("proc_to_call", DATA_INPUT_REF, "The proc reference that will be called when the item can be assembled"),
		ARG_INFO("on_tool_attack", DATA_INPUT_BOOL, "Set this to TRUE if you want the component to fire if the construction should go two-ways.", FALSE),
		ARG_INFO("assembly_helper_datum", DATA_INPUT_TYPE, "A /datum/assembly_comp_helper you can add here to modify the behaviour of the assembly component. If none given, the standard one is created."),
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
	///The assembly component helper datum to control the behaviour of this component more finely. If none given, one is created
	var/datum/assembly_comp_helper/helper_datum = null



/datum/component/assembly/Initialize(var/required_item, var/called_proc, var/on_tool_attack = FALSE, var/datum/assembly_comp_helper/assembly_helper)
	if(!src.parent || !required_item || !called_proc)
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.to_combine_item = required_item
	src.valid_assembly_proc = called_proc
	if(assembly_helper)
		src.helper_datum = assembly_helper
	else
		src.helper_datum = new /datum/assembly_comp_helper
	RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(attackby))
	if(on_tool_attack)
		RegisterSignal(src.parent, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(on_pre_attack))

/datum/component/assembly/UnregisterFromParent()
	. = ..()
	qdel(src.helper_datum)
	src.helper_datum = null
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
	//At this point, we check the helper to see if anything else is off
	is_combinable = (is_combinable && src.helper_datum.check_valid_combination(src.parent, checked_atom, user))

	if(is_combinable)
		//if the assembly is valid, we go and call the proc
		//we need to return true so onattack does not trigger. Else we would still attack a completed assembly
		if(src.valid_assembly_proc)
			return call(src.parent, src.valid_assembly_proc)(checked_atom, user)
		else
			//if valid_assembly_proc is set to null, we call the replacement proc on the helper instead
			return src.helper_datum.replacement_proc(src.parent, checked_atom, user)


/// The assembly component-helper. This is a holder for multiple optional variables to modify an assembly component the way you want it to behave.
/datum/assembly_comp_helper
	var/allow_on_others = FALSE	//! If set to TRUE, the assembly component will skip the check if one of the items in question is in someone elses inventory
	var/check_for_removeability_on_parent = FALSE //! If set to TRUE, this component will return incompability if the parent is e.g. an item arm
	var/check_for_removeability_on_other = FALSE //! If set to TRUE, this component will return incompability if the other item is e.g. an item arm

/datum/assembly_comp_helper/proc/check_valid_combination(var/atom/parent_atom, var/atom/checked_atom, var/mob/user)
	if(!src.allow_on_others)
		for(var/obj/item/checked_item in list(parent_atom, checked_atom))
			if((ismob(checked_item.loc) && checked_item.loc != user))
				return FALSE
	//here we check if the item can be forcefully removed. E.g. this filters out walls or item arms and borg arms
	var/list/atoms_to_check = list()
	if(src.check_for_removeability_on_parent)
		atoms_to_check += parent_atom
	if(src.check_for_removeability_on_other)
		atoms_to_check += checked_atom
	if(length(atoms_to_check))
		for(var/atom/iterated_atom in atoms_to_check)
			if(isturf(iterated_atom))
				return FALSE
			if(isitem(iterated_atom))
				var/obj/item/checked_item = iterated_atom
				if((checked_item.temp_flags & IS_LIMB_ITEM) || checked_item.cant_drop)
					return FALSE
	// if the item came through all these checks, we can assume its alright.
	return TRUE

/// If no valid_assembly_proc is given to the assembly component, this will be called. Override this in these cases
/datum/assembly_comp_helper/proc/replacement_proc(var/atom/parent_atom, var/atom/checked_atom, var/mob/user)
	//i'm letting you know here you fucked up and didn't gave a valid proc for the component
	CRASH("Assembly-component: neither an assembly proc nor a replacement proc was given")

/datum/assembly_comp_helper/consumes_other
	check_for_removeability_on_other = TRUE

/datum/assembly_comp_helper/consumes_self
	check_for_removeability_on_parent = TRUE

/datum/assembly_comp_helper/consumes_all
	check_for_removeability_on_other = TRUE
	check_for_removeability_on_parent = TRUE
