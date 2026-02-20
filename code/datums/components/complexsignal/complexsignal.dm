/**
 * Handler for a complex singal, that is a signal that requires some additional handling.
 * You define such signal for example as:
 * `#define XSIG_OUTERMOST_MOVABLE_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_outermost_changed")`
 * When this signal gets registered at least once once to a datum the appropriate complex signal component will get registered to it.
 * When all instances of this signal get unregistered then the component will qdel itself unless [qdel_when_unneeded] is unset.
 * The intended use is for this component to keep some more complex and resource intensive handling (possibly using other signals) and then send the
 * actual complex signal when some conditions are met. That signal should be set to `src` like this:
 * `SEND_COMPLEX_SIGNAL(src, X_OUTERMOST_MOVABLE_CHANGED, old_outermost, new_outermost)`
 *
 * A single component type can be used for handling of multiple signals.
 *
 * Check [/datum/component/complexsignal/outermost_movable] for an example.
 */
/datum/component/complexsignal
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The complex signal types registered to this datum
	var/list/registered_signals = list()
	/// Whether the component should qdel itself when the number of registered signals drops to zero
	var/qdel_when_unneeded = TRUE

/datum/component/complexsignal/proc/register(datum/listener, xsignal, proctype, override = FALSE, ...)
	SHOULD_NOT_OVERRIDE(TRUE)
	src.registered_signals += xsignal[2]
	. = src._register(arglist(args))

/**
 * Override this to add code which happens when a complex signal is registered. If RegisterSignal is passed additional arguments those get passed
 * after `override`. Other arguments are the same as for .RegisterSignal.
 * Complex signal definitions are of the form list(component_path, string_id, ...). The `xsignal` var contains this full multiple-element list.
 */
/datum/component/complexsignal/proc/_register(datum/listener, xsignal, proctype, override = FALSE, ...)
	listener.RegisterSignal(src, xsignal[2], proctype, override)

/datum/component/complexsignal/proc/unregister(datum/listener, xsignal)
	SHOULD_NOT_OVERRIDE(TRUE)
	. = src._unregister(listener, xsignal)
	src.registered_signals -= xsignal[2]
	if(length(registered_signals) <= 0 && qdel_when_unneeded)
		qdel(src)

/**
 * Override to add code which happens on unregistering a signal.
 */
/datum/component/complexsignal/proc/_unregister(datum/listener, xsignal)
	listener.UnregisterSignal(src, xsignal[2])
