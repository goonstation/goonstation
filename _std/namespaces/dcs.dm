/// Namespace for the datum component system (DCS); our implementation of an entity component system (ECS).
CREATE_NAMESPACE(DCS)

/// An associative list of all instantiated elements, indexed by their ID.
ADD_TO_NAMESPACE(DCS)(var/alist/_elements_by_id = alist())

/// Returns the instance of the element of the given type, with arguments also being considered if the element is bespoke.
ADD_TO_NAMESPACE(DCS)(proc/GetElement(list/arguments, init_element = TRUE))
	RETURN_TYPE(/datum/element)
	var/datum/element/element_type = arguments[1]
	var/id = "[element_type]"

	if (ispath(element_type, /datum/element/bespoke))
		var/datum/element/bespoke/E = (src._elements_by_id[id] ||= new element_type(id))
		id += E.HashArguments(arglist(arguments.Copy(2)))

	if (init_element)
		return (src._elements_by_id[id] ||= new element_type(id))
	else
		return src._elements_by_id[id]


//------------ Element Flags ------------//
/// Bitflags for modifying element behaviour.
CREATE_NAMESPACE(DCS, ELEMENT_FLAG)
/// Automatically call the `Detach()` proc when a datum registered to this element qdeletes.
ADD_TO_NAMESPACE(DCS, ELEMENT_FLAG)(var/const/DETACH_ON_PARENT_DISPOSE = (1 << 0))


//------------ DCS Errors ------------//
/// Various errors that components and elements can return.
CREATE_NAMESPACE(DCS, ERR)
/// Cancel attaching this element.
ADD_TO_NAMESPACE(DCS, ERR)(var/const/ELEMENT_INCOMPATIBLE = 1)
