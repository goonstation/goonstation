#define QUEUE_WAIT_TIME 300

// hi i fucked up this file p bad. if it ends up being as bad as
// it looks pls do "git revert (whatever hash this has)"
// otherwise this will stink up everything forever

datum/controller/process/delete_queue
	var/tmp/delcount = 0
	var/tmp/gccount = 0
	var/tmp/deleteChunkSize = MIN_DELETE_CHUNK_SIZE
#ifdef DELETE_QUEUE_DEBUG
	var/tmp/datum/dynamicQueue/delete_queue = 0
#endif
	var/log_hard_deletions = 0

	setup()
		name = "DeleteQueue"
		schedule_interval = 5
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

			if (log_hard_deletions == 1)
				if (D.type == /obj/overlay)
					var/obj/overlay/O = D
					logTheThing("debug", text="HardDel of [D.type] -- iconstate [O.icon_state]")
				else
					logTheThing("debug", text="HardDel of [D.type]")

			delcount++
			D.qdeled = 0
			del(D)

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

			// Delete that bitch

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

	tickDetail()
		#ifdef DELETE_QUEUE_DEBUG
		if (detailed_delete_count && detailed_delete_count.len)
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
