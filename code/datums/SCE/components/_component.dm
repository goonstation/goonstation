/datum
	/**
	 *	An associative list of components registered to this datum, indexed by component type. \
	 *	Type structure: `/list<type, /datum/component>` or `/list<type, /list/datum/component>`
	 */
	var/list/datum_components = null


TYPEINFO(/datum/component)
	var/initialization_args = null

ABSTRACT_TYPE(/datum/component)
/**
 *	A component is a single standalone unit of functionality that works by receiving signals from its parent object in order to
 *	provide some single functionality. For example, a slippery component that makes the object it's attached to cause people to
 *	slip over.
 *
 *	Useful for when you want shared behaviour independent of type inheritance.
 */
/datum/component
	/// The datum that this component belongs to.
	var/datum/parent = null

	/**
	 *	Defines how duplicate existing components are handled when added to a datum.
	 *
	 *	See the `COMPONENT_DUPE_` defines for available options.
	 */
	var/dupe_mode = COMPONENT_DUPE_HIGHLANDER

	/**
	 *	The type to check for duplication.
	 *
	 *	A `null` value means an exact match on this component's type. Any other type means that and all subtypes.
	 */
	var/dupe_type = null

	/**
	 *	Only set to `TRUE` if this component can be properly transferred.
	 *
	 *	At a minimum `RegisterWithParent()` and `UnregisterFromParent()`should be used. Use `PostTransfer()` for any
	 *	post-transfer handling.
	 */
	var/can_transfer = FALSE

/**
 *	Create a new component.
 *
 *	Additional arguments are passed to `Initialize()`.
 *
 *	Arguments:
 *	- `datum/parent`: The parent datum that this component reacts to signals from.
 */
/datum/component/New(list/raw_args)
	. = ..()
	src.parent = raw_args[1]

	var/list/arguments = raw_args.Copy(2)
	if (src.Initialize(arglist(arguments)) == COMPONENT_INCOMPATIBLE)
		global.stack_trace("Incompatible [src.type] assigned to a [src.parent.type]! args: [json_encode(arguments)]")
		qdel(src.parent)

	src._JoinParent(src.parent)

/**
 *	Called during `New()` with the same arguments, excluding `parent`.
 *
 *	Do not call `qdel(src)` from this function, `return COMPONENT_INCOMPATIBLE` instead.
 */
/datum/component/proc/Initialize(...)
	SHOULD_CALL_PARENT(TRUE)
	return

/**
 *	Properly removes the component from `parent` and cleans up references.
 */
/datum/component/disposing()
	if (src.parent)
		src._RemoveFromParent()
		SEND_SIGNAL(src.parent, COMSIG_COMPONENT_REMOVING, src)

	src.parent = null
	. = ..()

/**
 *	Internal proc to handle behaviour when bring added to a parent.
 */
/datum/component/proc/_JoinParent()
	var/list/dc = (src.parent.datum_components ||= list())

	for (var/type as anything in src._GetInverseTypeList())
		var/list/looked_up = dc[type]

		// If nothing has been registered here yet, register the reference.
		if (isnull(looked_up))
			dc[type] = src
		// If only one other thing has been registered here, replace the reference with a list.
		else if (!length(looked_up))
			dc[type] = list(looked_up, src)
		// If many other things have been registered here, add us to the list.
		else
			dc[type] += src

	// Sort the list such that exact type matches take priority.
	var/list/datum/component/components_of_type = dc[type]
	var/list_length = length(components_of_type)
	for (var/i in 1 to list_length)
		// Do not take priority over other exact matches.
		if (istype_exact(components_of_type[i], src.type))
			continue

		components_of_type.Swap(i, list_length)
		break

	src.RegisterWithParent()

/**
 *	Internal proc to handle behaviour when being removed from a parent.
 */
/datum/component/proc/_RemoveFromParent()
	var/list/dc = src.parent.datum_components

	for (var/type as anything in src._GetInverseTypeList())
		var/list/looked_up = dc[type]

		switch (length(looked_up))
			// If only one other thing has been registered, replace the list with a reference to that other registree.
			if (2)
				dc[type] = (looked_up - src)[1]
			// If we're the only thing registered, remove the component type from the lookup.
			if (1, 0)
				dc -= type
			// If many other things have been registered here, remove us from the list.
			else
				looked_up -= src

	if (!length(dc))
		src.parent.datum_components = null

	src.UnregisterFromParent()

/**
 *	Register the component with the parent object.
 *
 *	Overridable proc that's called when added to a new parent.
 */
/datum/component/proc/RegisterWithParent()
	return

/**
 *	Unregister the component from the parent object.
 *
 *	Overridable proc that's called when removed from a parent.
 */
/datum/component/proc/UnregisterFromParent()
	return

/**
 *	Called on a component when a component of the same type was added to this component's parent. See `dupe_mode`.
 *
 *	`C`'s type will always be the same as that of the called component.
 */
/datum/component/proc/InheritComponent(datum/component/C, i_am_original)
	return

/**
 *	Called on a component when a component of the same type was added to this component's parent with `COMPONENT_DUPE_SELECTIVE`.
 *
 *	`C`'s type will always be the same as that of the called component.
 */
/datum/component/proc/CheckDupeComponent(datum/component/C, ...)
	return

/**
 *	Called before this component is transferred to a new parent.
 *
 *	Used for special cleanup before being deregistered from the parent object.
 */
/datum/component/proc/PreTransfer()
	return

/**
 *	Called after this component is transferred to a new parent.
 *
 *	Used for special setup after being registered to a new parent object.
 *
 *	Do not call `qdel(src)` from this function, `return COMPONENT_INCOMPATIBLE` instead.
 */
/datum/component/proc/PostTransfer()
	// Do not support transfer by default as you must properly support it.
	return COMPONENT_INCOMPATIBLE

/**
 *	Internal proc to create a list of our type and all parent types.
 */
/datum/component/proc/_GetInverseTypeList()
	var/datum/current_type = src.parent_type
	. = list(src.type, current_type)

	while (current_type != /datum/component)
		current_type = current_type::parent_type
		. += current_type


// The type arg is casted so initial works, you shouldn't be passing a real instance into this
/**
  * Return any component assigned to this datum of the given type
  *
  * This will throw an error if it's possible to have more than one component of that type on the parent
  *
  * Arguments:
  * * datum/component/c_type The typepath of the component you want to get a reference to
  */
/datum/proc/GetComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED || initial(c_type.dupe_mode) == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent was called to get a component of which multiple copies could be on an object. This can easily break and should be changed. Type: \[[c_type]\]")
	var/list/dc = datum_components
	if(!dc)
		return null
	. = dc[c_type]
	if(length(.))
		return .[1]

// The type arg is casted so initial works, you shouldn't be passing a real instance into this
/**
  * Return any component assigned to this datum of the exact given type
  *
  * This will throw an error if it's possible to have more than one component of that type on the parent
  *
  * Arguments:
  * * datum/component/c_type The typepath of the component you want to get a reference to
  */
/datum/proc/GetExactComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED || initial(c_type.dupe_mode) == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent was called to get a component of which multiple copies could be on an object. This can easily break and should be changed. Type: \[[c_type]\]")
	var/list/dc = datum_components
	if(!dc)
		return null
	var/datum/component/C = dc[c_type]
	if(C)
		if(length(C))
			var/list/component_list = C
			C = component_list[1]
		if(C.type == c_type)
			return C
	return null

/**
  * Get all components of a given type that are attached to this datum
  *
  * Arguments:
  * * c_type The component type path
  */
/datum/proc/GetComponents(c_type)
	var/list/components = datum_components?[c_type]
	if(!components)
		return list()
	return islist(components) ? components : list(components)

/**
  * Calls RemoveComponent on all components of a given type that are attached to this datum
  *
  * Arguments:
  * * c_type The component type path
  */

/datum/proc/RemoveComponentsOfType(c_type)
	var/list/datum/component/component_to_remove_list = src.GetComponents(c_type)
	for (var/datum/component/component_to_remove as anything in component_to_remove_list)
		component_to_remove.RemoveComponent()

/**
  * Creates an instance of `new_type` in the datum and attaches to it as parent
  *
  * Sends the [COMSIG_COMPONENT_ADDED] signal to the datum
  *
  * Returns the component that was created. Or the old component in a dupe situation where [COMPONENT_DUPE_UNIQUE] was set
  *
  * If this tries to add a component to an incompatible type, the component will be deleted and the result will be `null`. This is very unperformant, try not to do it
  *
  * Properly handles duplicate situations based on the `dupe_mode` var
  */
/datum/proc/_AddComponent(list/raw_args)
	var/new_type = raw_args[1]
	var/datum/component/nt = new_type

	if(src.disposed)
		CRASH("Attempted to add a new component of type \[[nt]\] to a qdeleting parent of type \[[type]\]!")

	var/dm = initial(nt.dupe_mode)
	var/dt = initial(nt.dupe_type)

	var/datum/component/old_comp
	var/datum/component/new_comp

	if(ispath(nt))
		if(nt == /datum/component)
			CRASH("[nt] attempted instantiation!")
	else
		new_comp = nt
		nt = new_comp.type

	raw_args[1] = src

	if(dm != COMPONENT_DUPE_ALLOWED && dm != COMPONENT_DUPE_SELECTIVE)
		if(!dt)
			old_comp = GetExactComponent(nt)
		else
			old_comp = GetComponent(dt)
		if(old_comp)
			switch(dm)
				if(COMPONENT_DUPE_UNIQUE)
					if(!new_comp)
						new_comp = new nt(raw_args)
					if(!QDELETED(new_comp))
						old_comp.InheritComponent(new_comp, TRUE)
						qdel(new_comp)
						new_comp = null
				if(COMPONENT_DUPE_HIGHLANDER)
					if(!new_comp)
						new_comp = new nt(raw_args)
					if(!QDELETED(new_comp))
						new_comp.InheritComponent(old_comp, FALSE)
						qdel(old_comp)
						old_comp = null
				if(COMPONENT_DUPE_UNIQUE_PASSARGS)
					if(!new_comp)
						var/list/arguments = raw_args.Copy(2)
						arguments.Insert(1, null, TRUE)
						old_comp.InheritComponent(arglist(arguments))
					else
						old_comp.InheritComponent(new_comp, TRUE)
		else if(!new_comp)
			new_comp = new nt(raw_args) // There's a valid dupe mode but there's no old component, act like normal
	else if(dm == COMPONENT_DUPE_SELECTIVE)
		var/list/arguments = raw_args.Copy()
		arguments[1] = new_comp
		var/make_new_component = TRUE
		for(var/datum/component/existing_component as anything in GetComponents(new_type))
			if(existing_component.CheckDupeComponent(arglist(arguments)))
				make_new_component = FALSE
				qdel(new_comp)
				new_comp = null
				break
		if(!new_comp && make_new_component)
			new_comp = new nt(raw_args)
	else if(!new_comp)
		new_comp = new nt(raw_args) // Dupes are allowed, act like normal

	if(!old_comp && !QDELETED(new_comp)) // Nothing related to duplicate components happened and the new component is healthy
		SEND_SIGNAL(src, COMSIG_COMPONENT_ADDED, new_comp)
		return new_comp
	return old_comp

/**
  * Get existing component of type, or create it and return a reference to it
  *
  * Use this if the item needs to exist at the time of this call, but may not have been created before now
  *
  * Arguments:
  * * component_type The typepath of the component to create or return
  * * ... additional arguments to be passed when creating the component if it does not exist
  */
/datum/proc/_LoadComponent(list/arguments)
	. = GetComponent(arguments[1])
	if(!.)
		return _AddComponent(arguments)

/**
  * Removes the component from parent, ends up with a null parent
  */
/datum/component/proc/RemoveComponent()
	if(!parent)
		return
	var/datum/old_parent = parent
	PreTransfer()
	_RemoveFromParent()
	parent = null
	SEND_SIGNAL(old_parent, COMSIG_COMPONENT_REMOVING, src)

/**
  * Transfer this component to another parent
  *
  * Component is taken from source datum
  *
  * Arguments:
  * * datum/component/target Target datum to transfer to
  */
/datum/proc/TakeComponent(datum/component/target)
	if(!target || target.parent == src)
		return
	if(target.parent)
		target.RemoveComponent()
	target.parent = src
	var/result = target.PostTransfer()
	switch(result)
		if(COMPONENT_INCOMPATIBLE)
			var/c_type = target.type
			qdel(target)
			CRASH("Incompatible [c_type] transfer attempt to a [type]!")

	if(target == AddComponent(target))
		target._JoinParent()

/**
  * Transfer all components to target
  *
  * All components from source datum are taken
  *
  * Arguments:
  * * /datum/target the target to move the components to
  */
/datum/proc/TransferComponents(datum/target)
	var/list/dc = datum_components
	if(!dc)
		return
	var/comps = dc[/datum/component]
	if(islist(comps))
		for(var/datum/component/I in comps)
			if(I.can_transfer)
				target.TakeComponent(I)
	else
		var/datum/component/C = comps
		if(C.can_transfer)
			target.TakeComponent(comps)

/**
 * Return the object that is the host of any UI's that this component has
 */
/datum/component/ui_host()
	return parent
