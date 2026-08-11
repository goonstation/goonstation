/datum
	/// A list of element IDs registered to this datum.
	var/list/datum_elements = null

/**
 *	Looks up an element singleton of the given type and attaches it to this datum.
 */
/datum/proc/_AddElement(list/arguments)
	if (QDELETED(src))
		CRASH("Attempted to add element [arguments[1]] to a qdeleted datum.")

	var/datum/element/E = DCS.GetElement(arguments)
	if (!E)
		return

	arguments[1] = src
	if (E.Attach(arglist(arguments)) == DCS::ERR::ELEMENT_INCOMPATIBLE)
		CRASH("Incompatible element [E.type] was assigned to a [src.type]! args: [json_encode(args)]")

/**
 *	Looks up an element singleton of the given type and detaches it from this datum.
 *	Additional arguments beyond the type only need to be passed if a bespoke element is being removed.
 */
/datum/proc/_RemoveElement(list/arguments)
	var/datum/element/E = astype(arguments[1]) || DCS.GetElement(arguments, FALSE)
	E?.Detach(src)


TYPEINFO(/datum/element)
	var/initialization_args = null

ABSTRACT_TYPE(/datum/element)
/**
 *	An element, similar to a component, is a single standalone unit of functionality that works by receiving signals from
 *	registered datums to provide some single functionality. Unlike components, elements do not have a single parent datum
 *	and are instead shared between all datums that they've been added to.
 *
 *	Can be thought of as a component without the memory overhead.
 */
/datum/element
	/// The ID that uniquely identifies this element. Usually the typepath unless the element is a bespoke element.
	VAR_PRIVATE/id = null
	/// Option flags for element behaviour.
	var/element_flags = 0

/datum/element/New(id)
	. = ..()
	src.id = id

/datum/element/disposing()
	DCS._elements_by_id -= src.id
	. = ..()

/// Activates the functionality defined by the element on the given target datum.
/datum/element/proc/Attach(datum/target)
	SHOULD_CALL_PARENT(TRUE)
	var/list/de = (target.datum_elements ||= list())
	if (de[src.id])
		return

	de[src.id] = TRUE

	SEND_SIGNAL(target, COMSIG_ELEMENT_ATTACH, src)
	if (element_flags & DCS::ELEMENT_FLAG::DETACH_ON_PARENT_DISPOSE)
		src.RegisterSignal(target, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(OnTargetDelete), override = TRUE)

/// Deactivates the functionality defined by the element on the given target datum.
/datum/element/proc/Detach(datum/target)
	SHOULD_CALL_PARENT(TRUE)
	var/list/de = target.datum_elements
	if (!de?[src.id])
		return

	de -= src.id
	if (!length(de))
		target.datum_elements = null

	SEND_SIGNAL(target, COMSIG_ELEMENT_DETACH, src)
	src.UnregisterSignal(target, COMSIG_PARENT_PRE_DISPOSING)

/// Called when a datum registered to this element is qdeleted.
/datum/element/proc/OnTargetDelete(datum/target)
	src.Detach(target)


ABSTRACT_TYPE(/datum/element/bespoke)
/**
 *	Bespoke elements are special elements that aren't strictly singletons by type; element uniqueness takes into consideration
 *	the arguments passed to this element on registration. This means that bespoke elements are shared between datums that passed
 *	idential arguments into `AddElement()`.
 *
 *	Can be thought of as a halfway point between pure elements and pure components.
 */
/datum/element/bespoke

/// Using the arguments passed to this element when attached to a datum, create a hash to identify it.
/datum/element/bespoke/proc/HashArguments(...)
	return "{}"
