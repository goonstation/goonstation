// For component defines which apply to all components, or are integral to the component system.


/// Used to trigger signals and call procs registered for that signal
/// The datum hosting the signal is automaticaly added as the first argument
/// Returns a bitfield gathered from all registered procs
/// Arguments given here are packaged in a list and given to _SendSignal
#define SEND_SIGNAL(target, sigtype, arguments...) ( !target?.comp_lookup || !target.comp_lookup[sigtype] ? 0 : target._SendSignal(sigtype, list(target, ##arguments)) )

#define SEND_COMPLEX_SIGNAL(target, sigtype, arguments...) SEND_SIGNAL(target, sigtype[2], ##arguments)

#define GLOBAL_SIGNAL global_signal_holder // dummy datum that exclusively exists to hold onto global signals

/**
	* `target` to use for signals that are global and not tied to a single datum.
	*
	* Note that this does NOT work with SEND_SIGNAL because of preprocessor weirdness.
	* Use SEND_GLOBAL_SIGNAL instead.
	*/
#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( !global_signal_holder.comp_lookup || !global_signal_holder.comp_lookup[sigtype] ? 0 : global_signal_holder._SendSignal(sigtype, list(global_signal_holder, ##arguments)) )

/// A wrapper for _AddComponent that allows us to pretend we're using normal named arguments
#define AddComponent(arguments...) _AddComponent(list(##arguments))

/// A wrapper for _LoadComponent that allows us to pretend we're using normal named arguments
#define LoadComponent(arguments...) _LoadComponent(list(##arguments))

/// Checks if a signal is "complex", i.e. it is handled by adding a special component and registering may have side effects and overhead
#define IS_COMPLEX_SIGNAL(x) (length(x) == 2 && ispath(x[1], /datum/component/complexsignal))

/**
	* Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it's applied to an incorrect type.
	*
	* `parent` must not be modified if this is to be returned.
	* This will be noted in the runtime logs.
	*/

#define COMPONENT_INCOMPATIBLE 1
/// Returned in PostTransfer to prevent transfer, similar to `COMPONENT_INCOMPATIBLE`
#define COMPONENT_NOTRANSFER 2


/// arginfo handling TODO: document
#define ARG_INFO(name, type, desc, default...)\
	list(name, type, desc, ##default)

// How multiple components of the exact same type are handled in the same datum

/// old component is deleted (default)
#define COMPONENT_DUPE_HIGHLANDER		0
/// duplicates allowed
#define COMPONENT_DUPE_ALLOWED			1
/// new component is deleted
#define COMPONENT_DUPE_UNIQUE			2
/// old component is given the initialization args of the new
#define COMPONENT_DUPE_UNIQUE_PASSARGS	4
/// each component of the same type is consulted as to whether the duplicate should be allowed
#define COMPONENT_DUPE_SELECTIVE		5
