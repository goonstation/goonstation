TYPEINFO(/datum/component/assembly)
	initialization_args = list(
		ARG_INFO("to_combine_item", DATA_INPUT_TYPE, "path or list of items that will trigger this proc when used on. Can take tool-bitflags like TOOL_CUTTING."),
		ARG_INFO("proc_to_call", DATA_INPUT_REF, "The proc reference that will be called when the item can be assembled"),
		ARG_INFO("on_tool_attack", DATA_INPUT_BOOL, "Set this to TRUE if you want the component to fire if the construction should go two-ways.", FALSE),
		ARG_INFO("allow_on_others", DATA_INPUT_BOOL, "Set this to TRUE if you want the component to fire even though one of the items is on someone else. Sneaky.", FALSE),
		ARG_INFO("ignore_given_proc", DATA_INPUT_BOOL, "Set this to TRUE if you want the component to ignore that proc_to_call isn't given and instead call src.override_combination. This is only usefull for children of this component.", FALSE),
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
	///Set to TRUE if you want this combination to work while one of the items is on another person
	var/allow_apply_on_others = FALSE



/datum/component/assembly/Initialize(var/required_item, var/called_proc, var/on_tool_attack = FALSE, var/allow_on_others = FALSE, var/ignore_given_proc = FALSE)
	if(!src.parent || !required_item || (!called_proc && !ignore_given_proc))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.to_combine_item = required_item
	if(!ignore_given_proc)
		src.valid_assembly_proc = called_proc
	src.allow_apply_on_others = allow_on_others
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

/datum/component/assembly/proc/override_combination(var/atom/checked_atom, var/mob/user)
	//! If you set ignore_given_proc in Initialize() to true, this will be called. Override this proc to have assembly behaviour that can be applied to multiple item types.
	return FALSE

/datum/component/assembly/proc/try_combination(var/atom/checked_atom, var/mob/user)
	var/is_combinable = FALSE
	if(isghostcritter(user)) //just no
		return FALSE
	if(isitem(checked_atom))
		var/obj/item/other_item = checked_atom
		if (other_item.cant_drop)
			return FALSE
	if(isitem(src.parent))
		var/obj/item/our_item = src.parent
		if (our_item.cant_drop)
			return FALSE
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
	//if you try to combine items on someone else, set allow_apply_on_others to true
	if(!src.allow_apply_on_others)
		for(var/obj/item/checked_item in list(src.parent, checked_atom))
			if((ismob(checked_item.loc) && checked_item.loc != user))
				is_combinable = FALSE

	if(is_combinable)
		//if the assembly is valid, we go and call the proc
		//we need to return true so onattack does not trigger. Else we would still attack a completed assembly
		if (valid_assembly_proc)
			return call(src.parent, src.valid_assembly_proc)(checked_atom, user)
		else
			return src.override_combination(checked_atom, user)

/// This component handles the creation of modular trigger-applier-assemblies
TYPEINFO(/datum/component/assembly)
	initialization_args = list(
		ARG_INFO("override_component", DATA_INPUT_TYPE, "path or list of items that will trigger this proc when used on. This is an override special assemblies for e.g. flash/cell assemblies"),
	)

/datum/component/assembly/trigger_applier_assembly
	to_combine_item = TOOL_ASSEMBLY_APPLIER
	valid_assembly_proc = null

/datum/component/assembly/trigger_applier_assembly/Initialize(var/override_component = null)
	if(!src.parent)
		return COMPONENT_INCOMPATIBLE
	. = ..(override_component ? override_component : TOOL_ASSEMBLY_APPLIER, null, TRUE, FALSE, TRUE) //here, we use ignore_given_proc = TRUE in the parent because we want to create the assembly in src.override_combination

/datum/component/assembly/trigger_applier_assembly/attackby(var/atom/affected_parent, var/atom/to_combine_atom, var/mob/user, var/params, var/is_special)
	if((length(to_combine_atom.GetComponents(/datum/component/assembly/trigger_applier_assembly)) > 0) && isassemblyapplier(src.parent))
		//If the item used to attack you can also be trigger and a applier for an assembly, we don't continue here.
		//At this point, the component of to_combine_atom should already turned this item into an assembly
		//this guarantees that the item you use in your hand for an assembly will always turn out to be the trigger
		return FALSE
	return try_combination(to_combine_atom, user)

/datum/component/assembly/trigger_applier_assembly/try_combination(var/atom/checked_atom, var/mob/user)
	if(istype(checked_atom, src.parent.type))
		//We don't want something like a signaller-signaller assembly. That would be akward to use
		return FALSE
	// We check if one of our components has some special states that are not combineable, e.g. igniters being secured
	if(SEND_SIGNAL(checked_atom, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK, src.parent, user) || SEND_SIGNAL(src.parent, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK, checked_atom, user))
		return FALSE
	. = ..()

/datum/component/assembly/trigger_applier_assembly/override_combination(var/atom/checked_atom, var/mob/user)
	var/obj/item/item_to_be_trigger = src.parent
	var/obj/item/item_to_be_applier = checked_atom
	// Here, we take care of the special case that both items can be triggers and appliers. In that case, we open a context menu and ask how we want to build the assembly
	if((length(checked_atom.GetComponents(/datum/component/assembly/trigger_applier_assembly)) > 0) && isassemblyapplier(src.parent))
		var/input_action = input(user, "Which item do you want to be the trigger of the assembly?") in list("[src.parent]","[checked_atom]","Never Mind")
		if(!input_action || input_action == "Never Mind" || !src.delayed_combination_valid_check(checked_atom, user))
			return TRUE
		// if our checked atom was selected, we have to swap the components places in the assembly. Else, just continue with what we were trying to do.
		if(input_action == "[checked_atom]")
			item_to_be_trigger = checked_atom
			item_to_be_applier = src.parent
	// here, we want to create our new assembly
	user.u_equip(checked_atom)
	user.u_equip(src.parent)
	var/obj/item/assembly/product = new /obj/item/assembly(get_turf(src.parent))
	//we set up the new assembly with its corresponding proc
	product.set_up_new(user, item_to_be_trigger, item_to_be_applier)
	//Some Admin logging/messaging
	logTheThing(LOG_BOMBING, user, "A [product.name] was created at [log_loc(product)]. Created by: [key_name(user)];[product.get_additional_logging_information(user)]")
	if(product.requires_admin_messaging())
		message_admins("A [product.name] was created at [log_loc(product)]. Created by: [key_name(user)]")
	//we finished the assembly, now we give it to its proud new owner
	product.add_fingerprint(user)
	user.put_in_hand_or_drop(product)
	boutput(user, SPAN_NOTICE("You finish the construction of [product.name]."))
	return TRUE


/datum/component/assembly/trigger_applier_assembly/proc/delayed_combination_valid_check(var/obj/item/checked_item, var/mob/user)
	// we check here if we can still reach both items and they weren't build into assemblies at a different point
	var/obj/item/checked_parent = src.parent
	return (checked_parent && checked_item && !QDELETED(checked_item) && !QDELETED(checked_parent) && can_reach(user, checked_item) && can_reach(user, checked_parent) && !istype(checked_item.loc, /obj/item/assembly) && !istype(checked_parent.loc, /obj/item/assembly))
