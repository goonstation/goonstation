#define HARD_DELETIONS_DISABLED

#define QUEUE_WAIT_TIME 300

// hi i fucked up this file p bad. if it ends up being as bad as
// it looks pls do "git revert (whatever hash this has)"
// otherwise this will stink up everything forever
var/global/harddel_count = 0

/// The process controller for queued deletion
/datum/controller/process/delete_queue
	var/tmp/delcount = 0
	var/tmp/gccount = 0
	var/tmp/deleteChunkSize = MIN_DELETE_CHUNK_SIZE
#ifdef DELETE_QUEUE_DEBUG
	var/tmp/datum/dynamicQueue/delete_queue = 0
#endif

#if defined(LOG_HARD_DELETE_REFERENCES) || defined(AUTO_REFERENCE_TRACKING_ON_HARD_DEL) || defined(LOG_HARD_DELETE_REFERENCES_2_ELECTRIC_BOOGALOO)
	var/log_hard_deletions = 2
#else

	#ifdef HARD_DELETIONS_DISABLED
	var/log_hard_deletions = 1
	#else
	var/log_hard_deletions = 0 // 1 = log them, 2 =  attempt to find references (requires LOG_HARD_DELETE_REFERENCES)
	#endif

#endif

	setup()
		name = "DeleteQueue"

#ifdef HARD_DELETIONS_DISABLED
		schedule_interval = 1 SECOND //ha ha whatever
#else
		schedule_interval = 0.5 SECONDS
#endif

		tick_allowance = 25

	doWork()
		/*
		if(!global.delete_queue)
			boutput(world, "Error: there is no delete queue!")
			return 0
		*/
		if (!global.delete_queue_2)
			boutput(world, "Error: there is no delete queue!")
			return 0

#ifdef DELETE_QUEUE_DEBUG
		if (!src.delete_queue)
			src.delete_queue = global.delete_queue
#endif

		//var/t_gccount = gccount
		//var/t_delcount = delcount
		for (var/r in global.delete_queue_2[global.delqueue_pos])
			scheck()

			var/datum/D = locate(r)
			if (!istype(D) || !D.qdeled)
				// If we can't locate it, it got garbage collected.
				// If it isn't disposed, it got garbage collected and then a new thing used its ref.
				gccount++
				continue

#ifdef HARD_DELETIONS_DISABLED
			var/harddel_msg = "Didn't GC: \ref[D]"
#else
			var/harddel_msg = "HardDel of"
#endif
			if (log_hard_deletions)
				if (D.type == /image)
					var/image/I = D
					logTheThing(LOG_DEBUG, text="[harddel_msg] [I.type] -- iconstate [I.icon_state], icon [I.icon]")
				else if(istype(D, /atom))
					var/atom/A = D
					logTheThing(LOG_DEBUG, text="[harddel_msg] [D.type] -- name [A.name], iconstate [A.icon_state], icon [A.icon]")
					boutput(world, "[harddel_msg] [D.type] -- name [A.name], iconstate [A.icon_state], icon [A.icon]")
				else
					logTheThing(LOG_DEBUG, text="[harddel_msg] [D.type]")
#ifdef LOG_HARD_DELETE_REFERENCES
				if (log_hard_deletions >= 2)
					for(var/x in find_all_references_to(D))
						logTheThing(LOG_DEBUG, text=x)
#endif
#ifdef LOG_HARD_DELETE_REFERENCES_2_ELECTRIC_BOOGALOO
				if (log_hard_deletions >= 2)
					var/list/result = list()
					ref_visit_list_2(all_references, D, result)
					for(var/x in result)
						logTheThing(LOG_DEBUG, text=x)
#endif
#ifdef AUTO_REFERENCE_TRACKING_ON_HARD_DEL
				if (log_hard_deletions >= 2)
					for(var/client/C)
						if(C.holder && C.holder.level >= LEVEL_CODER)
							C.view_references(D)
#endif

			delcount++
			harddel_count++
#ifndef AUTO_REFERENCE_TRACKING_ON_HARD_DEL
			D.qdeled = 0

	#ifndef HARD_DELETIONS_DISABLED
			del(D)
	#else
			if(isliving(D))
				gimmick_ungcd_mob_stuff(D)
	#endif

#endif
		//if (t_gccount != gccount || t_delcount != delcount)
		//	boutput(world, "Delqueue update: buf [delqueue_pos]/[DELQUEUE_SIZE] ... [gccount - t_gccount] gc, [delcount - t_delcount] del")
		global.delete_queue_2[global.delqueue_pos].len = 0
		global.delqueue_pos = (global.delqueue_pos % DELQUEUE_SIZE) + 1

		/*
		//var/datum/dynamicQueue/queue =
		if(global.delete_queue.isEmpty())
			return

		var/list/toDeleteRefs = delete_queue.dequeueMany(deleteChunkSize)
		var/numItems = delete_queue.count()
		#ifdef DELETE_QUEUE_DEBUG
		var/t
		#endif
		for(var/r in toDeleteRefs)
			LAGCHECK(LAG_REALTIME)
			var/datum/D = locate(r)

			scheck()

			if (!istype(D) || !D.qdeled)
				// If we can't locate it, it got garbage collected.
				// If it isn't disposed, it got garbage collected and then a new thing used its ref.
				gccount++
				continue

			if (world.time <= D.qdeltime + QUEUE_WAIT_TIME)
				delete_queue.enqueue(r)
				continue

			#ifdef DELETE_QUEUE_DEBUG
			t = D.type
			// If we have been forced to delete the object, we do the following:
			detailed_delete_count[t]++
			detailed_delete_gc_count[t]--
			// Because we have already logged it into the gc count in qdel.
			#endif

			// Delete that

/*
			// fuck
			var/mob/fuck = D
			if (istype(fuck))
				if (fuck.client)
					Z_LOG_ERROR("DelQueue", "TRYING TO DELETE MOB WITH CLIENT (\ref[fuck] [fuck]) / ([fuck.client])!!!")
					continue
				else
					Z_LOG_INFO("DelQueue", "Deleting mob (\ref[fuck] [fuck]) (no client)")

			var/client/fuck2 = D
			if (istype(fuck2))
				Z_LOG_ERROR("DelQueue", "NO WE ARE NOT GOING TO FUCKING DELETE THE CLIENT (\ref[fuck2] [fuck2]) FUCK YOU")
				continue
*/
			delcount++
			D.qdeled = 0
			del(D)
		// The amount of time taken for this run is recorded only if
		// the number of items considered is equal to the chunk size
		if(numItems > deleteChunkSize * 10 && deleteChunkSize < MAX_DELETE_CHUNK_SIZE)
			deleteChunkSize++
		else
			if (deleteChunkSize > MIN_DELETE_CHUNK_SIZE)
				deleteChunkSize--
		*/

	proc/gimmick_ungcd_mob_stuff(mob/living/L)

		#ifdef UPSCALED_MAP //this causes a ton of lag. no clue why.
		return
		#endif

		L.lying = FALSE
		L.dir = SOUTH
		L.invisibility = INVIS_NONE
		L.update_lying()
		put_mob_in_centcom_cloner(L, indirect=TRUE)

	tickDetail()
		#ifdef DELETE_QUEUE_DEBUG
		var/stats = "<b>Delete Stats:</b><br>"
		var/count
		for (var/thing in detailed_delete_count)
			count = detailed_delete_count[thing]
			stats += "[thing] deleted [count] times.<br>"
		for (var/thing in detailed_delete_gc_count)
			count = detailed_delete_gc_count[thing]
			stats += "[thing] gracefully deleted [count] times.<br>"
		boutput(usr, "<br>[stats]")
		#endif
		boutput(usr, "<b>Current Queue Length:</b> [delete_queue.count()]")
		boutput(usr, "<b>Total Items Deleted:</b> [delcount] (Explictly) [gccount] (Gracefully GC'd)")


// diagnostics

#ifdef LOG_HARD_DELETE_REFERENCES
/datum/var/ref_tracker_visited = 0
/client/var/ref_tracker_visited = 0
var/global/ref_tracker_generation = 0

proc/ref_visit_list(var/list/L, var/list/next, var/datum/target, var/list/result, var/list/stack=null)
	var/i = 0
	var/top_level = isnull(stack)
	if(isnull(stack))
		stack = list()
	for(var/x in L)
		i += 1
		var/key_name = "[i]"
		if(top_level && !istext(x))
			key_name = "[x] \ref[x] [x:type]"
			if(istype(x, /atom/movable))
				key_name += " [x:loc]"
			if(istype(x, /atom) || istype(x, /image))
				key_name += " [x:icon] [x:icon_state]"
			x = x:vars
		if(x == "vars")
			continue
		if(x && x == target)
			result += jointext(stack + key_name, " - ")
		if(istype(x, /list))
			ref_visit_list(x, next, target, result, stack + key_name)
		else if(istype(x, /client) || istype(x, /datum))
			if(x:ref_tracker_visited != ref_tracker_generation)
				x:ref_tracker_visited = ref_tracker_generation
				next.Add(x)
		var/y = null
		try
			y = L[x]
		catch
		if(y)
			if(y && y == target)
				result += jointext(stack + "[x]", " - ")
			if(istype(y, /list))
				ref_visit_list(y, next, target, result, stack + "[x]")
			else if(istype(y, /client) || istype(y, /datum))
				if(y:ref_tracker_visited != ref_tracker_generation)
					y:ref_tracker_visited = ref_tracker_generation
					next.Add(y)

proc/find_all_references_to(var/datum/D)
	var/list/current = null
	var/list/next = world.contents + global.vars
	. = list()
	ref_tracker_generation++
	while(length(next))
		current = next
		next = list()
		ref_visit_list(current, next, D, .)
#endif

#ifdef LOG_HARD_DELETE_REFERENCES_2_ELECTRIC_BOOGALOO
var/global/list/all_references
/datum/New()
	if(!all_references) all_references = list("GLOB")
	all_references["\ref[src]"] = 1
	..()

/datum/Del()
	all_references.Remove("\ref[src]")
	..()

/client/New()
	if(!all_references) all_references = list("GLOB")
	all_references["\ref[src]"] = 1
	..()

/client/Del()
	all_references.Remove("\ref[src]")
	..()

proc/ref_visit_list_2(var/list/L, var/datum/target, var/list/result, var/list/stack=null)
	var/i = 0
	var/top_level = isnull(stack)
	if(isnull(stack))
		stack = list()
	for(var/x in L)
		i += 1
		var/key_name = "[i]"
		if(top_level && x == "GLOB")
			x = global.vars
		else if(top_level)
			x = locate(x)
			if(!x)
				continue
			key_name = "[x] \ref[x] [x:type]"
			if(istype(x, /atom/movable))
				key_name += " [x:loc]"
			if(istype(x, /atom) || istype(x, /image))
				key_name += " [x:icon] [x:icon_state]"
			x = x:vars
		if(x == "vars")
			continue
		if(x && x == target)
			result += jointext(stack + key_name, " - ")
		if(istype(x, /list))
			ref_visit_list_2(x, target, result, stack + key_name)
		var/y = null
		try
			y = L[x]
		catch
		if(y)
			if(y && y == target)
				result += jointext(stack + "[x]", " - ")
			if(istype(y, /list))
				ref_visit_list_2(y, target, result, stack + "[x]")
#endif
