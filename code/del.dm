var/datum/dynamicQueue/delete_queue = new /datum/dynamicQueue(100) //List of items that want to be deleted

var/list/datum/delete_queue_2[DELQUEUE_SIZE][0]
var/delqueue_pos = 1

/**
 * qdel
 *
 * queues a var for deletion by the delete queue processor.
 * if used on /world, /list, /client, or /savefile, it just skips the queue.
 */
proc/qdel(var/datum/D)
	if(!D)
		return
	if(isturf(D))
		var/turf/T = D
		T.ReplaceWithSpaceForce()
		return

	if (istype(D))
		D.dispose(qdel_instead = FALSE)

		if (ismovable(D) && length(D:contents) > 0)
			for (var/C in D:contents)
				qdel(C)

		/**
			* We'll assume here that the object will be GC'ed.
			* If the object is not GC'ed and must be explicitly deleted,
			* the delete queue process will decrement the gc counter and
			* increment the explicit delete counter for the type.
			*/
		#ifdef DELETE_QUEUE_DEBUG
		detailed_delete_gc_count[D.type]++
		#endif

		// In the delete queue, we need to check if this is actually supposed to be deleted.
		D.qdeled = 1

		/**
			* We will only enqueue the ref for deletion. This gives the GC time to work,
			* and makes less work for the delete queue to do.
			*/
		//if (!D.qdeltime)
		//	D.qdeltime = world.time

		// delete_queue.enqueue("\ref[O]")
		delete_queue_2[((delqueue_pos + DELQUEUE_WAIT) % DELQUEUE_SIZE) + 1] += "\ref[D]"
	else
		if(islist(D))
			D:len = 0
			del(D)
		else if(D == world)
			del(D)
			CRASH("Cannot qdel /world! Fuck you!")
		else if(isclient(D))
			del(D)
			CRASH("Cannot qdel /client! Fuck you!")
		else if(istype(D, /savefile))
			del(D)
			CRASH("Cannot qdel /savefile! Fuck you!")
		else
			CRASH("Cannot qdel this unknown type")

////////////
// drsinghs grand experiment vol 6
// this pattern might seem redundant but it ensures objects aren't disposed twice.
// it also proides a quick way to check if an object you're using was disposed but never deleted by the garbage collector because of your reference
// the point of this is to reduce code duplication. cleanup code only needs to exist one time in disposing() and it will be called whether the object is deleted with del() or dispose()
//

/* Wire note: Commenting this as I think it was causing bad ref bugs (also I moved every Del override to disposing())
/datum/Del()
	dispose()
	..()
*/

/datum/var/tmp/disposed = 0
/datum/var/tmp/qdeled = 0


// override this in children for your type specific disposing implementation, make sure to call ..() so the root disposing runs too
/datum/proc/disposing()
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	src.tag = null // not part of components but definitely should happen

	signal_enabled = FALSE
	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for (var/datum/component/C as anything in all_components)
				qdel(C, FALSE, TRUE)
		else
			var/datum/component/C = all_components
			qdel(C, FALSE, TRUE)
		dc.Cut()

	var/list/lookup = comp_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for (var/datum/component/comp as anything in comps)
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		UnregisterSignal(target, signal_procs[target])

/datum/Del()
	if(!disposed)
		disposing()
	..()

/client/Del()
	if(!disposed)
		disposing()
	..()

// don't override this one, just call it instead of delete to get rid of something cheaply
#ifdef DISPOSE_IS_QDEL
/datum/proc/dispose(qdel_instead = TRUE)
#else
/datum/proc/dispose(qdel_instead = FALSE)
#endif
	SHOULD_NOT_OVERRIDE(TRUE)
	if(qdel_instead)
		qdel(src)
		return
	if (!disposed)
		disposed = TRUE
		SEND_SIGNAL(src, COMSIG_PARENT_PRE_DISPOSING)
		disposing()
	else if (isatom(src))
		// Uh oh, we tried to delete something which is already deleted. Just send it to null if it's an atom so it doesn't hang around and fuck anything up.
		src:set_loc(null)
	// If it isn't an atom we don't care
