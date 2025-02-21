
#define GLOBAL_PROC "THIS_IS_A_GLOBAL_PROC_CALLBACK" //used instead of null because clients can be callback targets and then go null from disconnect before invoked, and we need to be able to differentiate when that happens or when it's just a global proc.

#define CALLBACK new /datum/callback
#define INVOKE_ASYNC(proc_owner, proc_path, proc_arguments...) \
	if ((proc_owner) == GLOBAL_PROC) { \
		SPAWN(-1) { \
			call(proc_path)(##proc_arguments); \
		}; \
	} \
	else { \
		SPAWN(-1) {\
			call(proc_owner, proc_path)(##proc_arguments); \
		}; \
	}

//supposedly for direct arg instertion. whatever that means??
#define CONCALL(OBJ, TYPE, CALL, VARNAME) var##TYPE/##VARNAME=OBJ;if(istype(##VARNAME)) ##VARNAME.##CALL

/// returns early if x is an overlay or effect
#define return_if_overlay_or_effect(x) if (istype(x, /obj/overlay) || istype(x, /obj/effects) || istype(x, /obj/effect) || istype(x, /obj/itemspecialeffect)) return

/proc/CallAsync(datum/object, delegate, list/callingArguments) // Adapted from /datum/callback/proc/InvokeAsync, which is PD, unlike this proc on tg
	set waitfor = 0
	if (isnull(object))
		CRASH("Cannot call null. [delegate]")
	return call(object, delegate)(arglist(callingArguments))
