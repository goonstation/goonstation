/// Dummy datum used for holding onto global signals, initialized in preMapLoad.
/datum/signal_holder
var/datum/signal_holder/global_signal_holder = null


/datum
	/**
	 *	An associative list of datums registered to receive signals from this datum, indexed by signal type. \
	 *	Type structure: `/list<sigtype, /datum>` or `/list<sigtype, /list/datum>`
	 */
	var/tmp/list/comp_lookup = null
	/**
	 *	An associative list of signal types and the associated proc that is run when this datum receives that signal, indexed by signal source datum. \
	 *	Type structure: `/list</datum, /list<sigtype, procname>>`
	 */
	var/tmp/list/list/signal_procs = null

/**
 *	Internal proc to handle most of the signaling procedure.
 *
 *	Will runtime if used on datums with an empty component list.
 *
 *	Use the `SEND_SIGNAL()` define instead.
 */
/datum/proc/_SendSignal(sigtype, list/arguments)
	var/target = src.comp_lookup[sigtype]
	if (!length(target))
		var/datum/listening_datum = target
		return 0 | call(listening_datum, listening_datum.signal_procs[src][sigtype])(arglist(arguments))

	// This exists so that even if one of the signal receivers unregisters the signal, all the objects that are receiving the
	// signal get the signal this final time.
	// AKA: No you can't cancel the signal reception of another object by doing an unregister in the same signal.
	var/list/queued_calls = list()

	// This should be faster than doing a `for (var/datum/listening_datum as anything in target)` loop as it does not implicitly copy the list.
	for (var/i in 1 to length(target))
		var/datum/listening_datum = target[i]
		queued_calls.Add(listening_datum, listening_datum.signal_procs[src][sigtype])

	. = 0
	for (var/i in 1 to length(queued_calls) step 2)
		. |= call(queued_calls[i], queued_calls[i + 1])(arglist(arguments))

/**
 *	Register to listen for a signal from the specified target datum.
 *
 *	This sets up a listening relationship such that when the target object emits a signal, the source datum will receive a
 *	callback to the given proctype.
 *	Return values from procs registered must be a bitfield.
 *
 *	Arguments:
 *	- `datum/target`: The target to listen for signals from.
 *	- `signal_type`: The signal to listen for.
 *	- `proctype`: The proc to call back when the signal is emitted. Use the `PROC_REF(procname)`, `TYPE_PROC_REF(type, procname)`, or `GLOBAL_PROC_REF(procname)` macros here.
 *	- `override`: If a previous registration exists you must explicitly set this.
 *	- `...`: Additional arguments get passed to `/datum/component/complexsignal/register()` in the case of a complex signal.
 */
/datum/proc/RegisterSignal(datum/target, signal_type, proctype, override = FALSE, ...)
	if (QDELETED(src) || QDELETED(target))
		return

	if (islist(signal_type))
		var/list/signal_types = signal_type
		global.stack_trace("([target.type]) is registering [signal_types.Join(", ")] as a list. Use RegisterSignals.")
		src.RegisterSignals(target, signal_types, proctype, override, args.Copy(5))
		return

	if (IS_COMPLEX_SIGNAL(signal_type))
		var/datum/xsig/xsignal = signal_type
		var/datum/component/complexsignal/comp = target.LoadComponent(xsignal::component)
		var/list/register_args = args.Copy()
		register_args[1] = src // The first argument of `comp.register` is the listener, not the target.
		comp.register(arglist(register_args))
		return

	var/list/procs = (src.signal_procs ||= list())
	var/list/target_procs = (procs[target] ||= list())
	var/list/lookup = (target.comp_lookup ||= list())

	if (!override && target_procs[signal_type])
		global.stack_trace("[signal_type] overridden. Use override = TRUE to suppress this warning.\nTarget: [global.identify_object(target)] Proc: [proctype]")

	target_procs[signal_type] = proctype
	var/list/looked_up = lookup[signal_type]

	// If nothing has been registered here yet, register the reference.
	if (isnull(looked_up))
		lookup[signal_type] = src
	// If we're already registered here, return.
	else if (looked_up == src)
		return
	// If only one other thing has been registered here, replace the reference with a list.
	else if (!length(looked_up))
		lookup[signal_type] = list((looked_up) = TRUE, (src) = TRUE)
	// If many other things have been registered here, add us to the list.
	else
		looked_up[src] = TRUE

/// Registers multiple signals to the same proc.
/datum/proc/RegisterSignals(datum/target, list/signal_types, proctype, override = FALSE, ...)
	for (var/signal_type as anything in signal_types)
		src.RegisterSignal(target, signal_type, proctype, override, args.Copy(5))

/**
 *	Stop listening to a given signal from a specified target datum.
 *
 *	Breaks the relationship between the target and source datums, removing the callback when the signal fires.
 *
 *	Doesn't care if a registration exists or not.
 *
 *	Arguments:
 *	- `datum/target`: The target to stop listening for signals from.
 *	- `signal_type`: The signal to stop listening for.
 */
/datum/proc/UnregisterSignal(datum/target, signal_type)
	if (!src || src.qdeled || !src.signal_procs || !target)
		return

	if (islist(signal_type))
		src.UnregisterSignals(target, signal_type)
		return

	if (IS_COMPLEX_SIGNAL(signal_type))
		var/datum/xsig/xsignal = signal_type
		var/datum/component/complexsignal/comp = target.GetComponent(xsignal::component)
		if (isnull(comp))
			CRASH("Unregistering a complex signal [xsignal] without its component existing.")

		comp.unregister(src, xsignal)
		return

	var/list/procs = src.signal_procs
	var/list/target_procs = procs[target]
	var/list/lookup = target.comp_lookup
	if (!target_procs || !lookup)
		return

	if (!target_procs[signal_type])
		if (!istext(signal_type))
			global.stack_trace("Unregistering something that isn't a valid signal \[[signal_type]\].")

		return

	// Remove the signal type from `src.signal_procs[target]`.
	target_procs -= signal_type
	if (!length(target_procs))
		procs -= target

	var/list/looked_up = lookup[signal_type]
	switch (length(looked_up))
		// If only one other thing has been registered, replace the list with a reference to that other registree.
		if (2)
			lookup[signal_type] = (looked_up - src)[1]
			return

		// If we're the only thing registered and we're in a list, remove the signal type from the lookup. This should never occur.
		if (1)
			global.stack_trace("[identify_object(target)] somehow has single length list inside comp_lookup")
			if (src in looked_up)
				lookup -= signal_type

		// If the looked up regristree is a reference and we're the reference, remove the signal type from the lookup.
		if (0)
			if (looked_up == src)
				lookup -= signal_type

		// If many other things have been registered here, remove us from the list.
		else
			looked_up -= src
			return

	if (!length(lookup))
		target.comp_lookup = null

/// Stop listening to multiple signals from a target.
/datum/proc/UnregisterSignals(datum/target, list/signal_types)
	for (var/signal_type as anything in signal_types)
		src.UnregisterSignal(target, signal_type)
