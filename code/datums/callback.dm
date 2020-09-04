/*
    Wire note: I copied and adapted this from MSO's (urgh) published code here: http://www.byond.com/forum/?post=2191707

    USAGE:

        var/datum/callback/C = new(object|null, /proc/type/path|"procstring", arg1, arg2, ... argn)
        var/timerid = addtimer(C, time, timertype)
        OR
        var/timerid = addtimer(CALLBACK(object|null, /proc/type/path|procstring, arg1, arg2, ... argn), time, timertype)

        Note: proc strings can only be given for datum proc calls, global procs must be proc paths
        Also proc strings are strongly advised against because they don't compile error if the proc stops existing
        See the note on proc typepath shortcuts

    INVOKING THE CALLBACK:
        var/result = C.Invoke(args, to, add) //additional args are added after the ones given when the callback was created
        OR
        var/result = C.InvokeAsync(args, to, add) //Sleeps will not block, returns . on the first sleep (then continues on in the "background" after the sleep/block ends), otherwise operates normally.

    PROC TYPEPATH SHORTCUTS (these operate on paths, not types, so to these shortcuts, datum is NOT a parent of atom, etc...)

        proc defined on current(src) object OR overridden at src or any of it's parents:
            .procname
            Example:
                CALLBACK(src, .some_proc_here)

        proc defined on parent(of src) object (when the above doesn't apply):
            .proc/procname
            Example:
                CALLBACK(src, .proc/some_proc_here)

        global proc while in another global proc:
            .procname
            Example:
                CALLBACK(GLOBAL_PROC, .some_proc_here)

        Other wise you will have to do the full typepath of the proc (/type/of/thing/proc/procname)

*/

/datum/callback
    var/datum/object = GLOBAL_PROC
    var/delegate
    var/list/arguments

    New(thingToCall, procToCall, ...)
        ..()
        if (thingToCall)
            src.object = thingToCall

        src.delegate = procToCall

        if (length(args) > 2)
            src.arguments = args.Copy(3)

    proc/Invoke(...)
        if (!src.object)
            CRASH("Cannot call null. [src.delegate]")

        var/list/callingArguments = src.arguments

        if (length(args))
            if (length(src.arguments))
                callingArguments = callingArguments + args //not += so that it creates a new list so the arguments list stays clean
            else
                callingArguments = args

        if (src.object == GLOBAL_PROC)
            return call(src.delegate)(arglist(callingArguments))

        return call(src.object, src.delegate)(arglist(callingArguments))

    proc/InvokeAsync(...)
        set waitfor = 0
        if (!src.object)
            CRASH("Cannot call null. [src.delegate]")

        var/list/callingArguments = src.arguments

        if (length(args))
            if (length(src.arguments))
                callingArguments = callingArguments + args //not += so that it creates a new list so the arguments list stays clean
            else
                callingArguments = args

        if (src.object == GLOBAL_PROC)
            return call(src.delegate)(arglist(callingArguments))

        return call(src.object, src.delegate)(arglist(callingArguments))
