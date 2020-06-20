var/datum/dynamicQueue/delete_queue = new /datum/dynamicQueue(100) //List of items that want to be deleted

var/list/datum/delete_queue_2[DELQUEUE_SIZE][0]
var/datum/delqueue_pos = 1

// hi i fucked up this file p bad. if it ends up being as bad as
// it looks pls do "git revert (whatever hash this has)"
// otherwise this will stink up everything forever

/**
 * qdel
 *
 * queues a var for deletion by the delete queue processor.
 * if used on /world, /list, /client, or /savefile, it just skips the queue.
 */
proc/qdel(var/datum/O)
	if(!O)
		return

	/*
	// debugging is a nightmare and i want to die
	var/mob/fuck = O
	if (istype(fuck))
		if (fuck.client)
			Z_LOG_ERROR("qdel", "Hey asshole you're trying to qdel a mob (\ref[fuck] [fuck]) that still has a client ([fuck.client])! What the fuck do you think you're doing???")
			CRASH("Trying to qdel a mob ([fuck]) that still has a client ([fuck.client])")
		else
			Z_LOG_WARN("qdel", "Deleting a mob (\ref[fuck] [fuck]) (no client)")
			spawn(-1)
				CRASH("Deleting a mob (\ref[fuck] [fuck]) (no client)")
	*/

	if (istype(O))
		// only queue deletions if the round is running, otherwise the queue isn't being processed
		if (current_state >= GAME_STATE_PLAYING)
			O.dispose(qdel_instead=0)
			if (istype(O, /atom/movable))
				O:loc = null

			if (isloc(O) && O:contents:len > 0)
				for (var/C in O:contents)
					qdel(C)

			/**
			 * We'll assume here that the object will be GC'ed.
			 * If the object is not GC'ed and must be explicitly deleted,
			 * the delete queue process will decrement the gc counter and
			 * increment the explicit delete counter for the type.
			 */
			#ifdef DELETE_QUEUE_DEBUG
			detailed_delete_gc_count[O.type]++
			#endif

			// In the delete queue, we need to check if this is actually supposed to be deleted.
			O.qdeled = 1

			/**
			 * We will only enqueue the ref for deletion. This gives the GC time to work,
			 * and makes less work for the delete queue to do.
			 */
			//if (!O.qdeltime)
			//	O.qdeltime = world.time

			// delete_queue.enqueue("\ref[O]")
			delete_queue_2[((delqueue_pos + DELQUEUE_WAIT) % DELQUEUE_SIZE) + 1] += "\ref[O]"
		else
			del(O)
	else
		if(islist(O))
			O:len = 0
			del(O)
		else if(O == world)
			del(O)
			CRASH("Cannot qdel /world! Fuck you!")
		else if(isclient(O))
			del(O)
			CRASH("Cannot qdel /client! Fuck you!")
		else if(istype(O, /savefile))
			del(O)
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

	src.tag = null // not part of components but definitely should happen

	signal_enabled = FALSE
	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for(var/I in all_components)
				var/datum/component/C = I
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
				for(var/i in comps)
					var/datum/component/comp = i
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		UnregisterSignal(target, signal_procs[target])

// don't override this one, just call it instead of delete to get rid of something cheaply
#ifdef DISPOSE_IS_QDEL
/datum/proc/dispose(qdel_instead=1)
#else
/datum/proc/dispose(qdel_instead=0)
#endif
	SHOULD_NOT_OVERRIDE(TRUE)
	if(qdel_instead)
		qdel(src)
		return
	if (!disposed)
		disposed = 1
		SEND_SIGNAL(src, COMSIG_PARENT_PRE_DISPOSING)
		disposing()
