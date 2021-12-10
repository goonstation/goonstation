//debug message macros
#define DEBUG_MESSAGE(x) if (debug_messages) message_coders(x)
#define DEBUG_MESSAGE_VARDBG(x,d) if (debug_messages) message_coders_vardbg(x,d)

/proc/stack_trace(var/thing_to_crash)
	CRASH(thing_to_crash)

/datum/proc/AdminAddComponent(...)
	_AddComponent(args)
