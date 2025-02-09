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

/datum/component/assembly/trigger_applier_assembly
	to_combine_item = TOOL_ASSEMBLY_APPLIER
	valid_assembly_proc = null

/datum/component/assembly/trigger_applier_assembly/Initialize()
	if(!src.parent)
		return COMPONENT_INCOMPATIBLE
	. = ..(TOOL_ASSEMBLY_APPLIER, null, TRUE, FALSE, TRUE) //here, we use ignore_given_proc = TRUE in the parent because we want to create the assembly in src.override_combination

/datum/component/assembly/trigger_applier_assembly/try_combination(var/atom/checked_atom, var/mob/user)
	if(istype(checked_atom, src.parent.type))
		//We don't want something like a signaller-signaller assembly. That would be akward to use
		return FALSE
	// We check if one of our components has some special states that are not combineable, e.g. igniters being secured
	if(SEND_SIGNAL(checked_atom, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK, src.parent, user) || SEND_SIGNAL(src.parent, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK, checked_atom, user))
		return FALSE
	. = ..()

/datum/component/assembly/trigger_applier_assembly/override_combination(var/atom/checked_atom, var/mob/user)
	// here, we want to create our new assembly
	user.u_equip(checked_atom)
	user.u_equip(src.parent)
	var/obj/item/assembly/complete/product = new /obj/item/assembly/complete(get_turf(src.parent))
	//for the trigger, we set each variable accordingly
	product.trigger = src.parent
	product.trigger.master = product
	product.trigger.layer = initial(product.trigger.layer)
	product.trigger_icon_prefix = initial(product.trigger.icon_state)
	product.trigger.set_loc(product)
	product.trigger.add_fingerprint(user)
	// we do the same for the applier
	product.applier = checked_atom
	product.applier.master = product
	product.applier.layer = initial(product.applier.layer)
	product.applier.set_loc(product)
	product.applier.add_fingerprint(user)
	product.applier_icon_prefix = initial(product.applier.icon_state)
	//we call on the applier and the trigger to see if it needs additional setup
	SEND_SIGNAL(product.trigger, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, product, user, TRUE)
	SEND_SIGNAL(product.applier, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, product, user, TRUE)
	//last but not least, we set the proper variables on the assembly
	product.w_class = max(product.trigger.w_class, product.applier.w_class)
	product.UpdateIcon()
	product.UpdateName()
	//we finished the assembly, now we give it to its proud new owner
	product.add_fingerprint(user)
	user.put_in_hand_or_drop(product)
	boutput(user, SPAN_NOTICE("You finish the construction of [product.name]."))
	return TRUE
