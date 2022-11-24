// Double clicking turfs to move to nearest camera

/turf/proc/move_camera_by_click()
	if (usr.stat || !isAI(usr))
		return
	//try to find the closest working camera in the same area, switch to it

	var/area/A = get_area(src)
	if (A && area_space_nopower(A)) return //lol @ dumping you at the mining magnet every fucking time. (or interrupting a track, wow rude)
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/anAI = usr
		if(anAI.tracker.tracking)
			return

	var/best_dist = INFINITY //infinity
	var/best_cam = null

	for(var/obj/machinery/camera/C in A)
		if(usr:network != C.network)
			continue	//	different network (syndicate)
		if(C.z != usr.z)
			continue	//	different viewing plane
		if(!C.camera_status)
			continue	//	ignore disabled cameras
		var/dist = GET_DIST(src, C)
		if(dist < best_dist)
			best_dist = dist
			best_cam = C

	if(!best_cam)
		return
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/anAI = usr
		anAI.tracker.cease_track()
	usr:switchCamera(best_cam)

/mob/living/silicon/ai/proc/ai_camera_list()
	set category = "AI Commands"
	set name = "Show Camera List"

	if(isdead(src))
		boutput(get_message_mob(), "You can't track with camera because you are dead!")
		return

	attack_ai(get_message_mob())

/mob/living/silicon/ai/proc/ai_camera_track()
	set category = "AI Commands"
	set name = "Track With Camera"
	if(isdead(usr))
		boutput(usr, "You can't track with camera because you are dead!")
		return

	var/list/creatures = sortList(get_mobs_trackable_by_AI(), /proc/cmp_text_asc)

	var/target_name = tgui_input_list(usr, "Which creature should you track?", "Track", creatures)

	if (!target_name)
		//usr:cameraFollow = null
		src.tracker.cease_track()
		return

	var/mob/target = creatures[target_name]

	ai_actual_track(target)


/mob/living/silicon/proc/ai_name_track(var/heard_name)
	if(isdead(usr))
		boutput(usr, "You can't track with camera because you are dead!")
		return

	var/list/mob/creatures = sortList(get_mobs_trackable_by_AI(), /proc/cmp_text_asc)
	var/list/candidates = list()

	for(var/C in creatures)
		var/name = creatures[C].name
		if (name == heard_name)
			candidates += C
			candidates[C] = creatures[C]

	var/target_name = null
	var/mob/target = null

	if(length(candidates))
		if(length(candidates) == 1)
			target = candidates[candidates[1]]
			ai_actual_track(target)
		else
			target_name = tgui_input_list(usr, "Which creature should you track?", "Track", candidates)
			target = candidates[target_name]
			ai_actual_track(target)
	else
		boutput(usr, "Not able to locate a creature by the name of \"[heard_name]\" on camera.")

/mob/living/silicon/proc/ai_actual_track(mob/target as mob)
	if (isnull(target) || !ismob(target) || !isAIControlled(src))
		return
	if (!src.mainframe)
		return
	src.mainframe.return_to(src)
	src.mainframe.tracker.begin_track(target)

/mob/living/silicon/ai/ai_actual_track(mob/target as mob)
	if (isnull(target) || !ismob(target))
		return
	src.tracker.begin_track(target)

/proc/camera_sort(var/list/L, var/start=1, var/end=-1)
	if(!L || !length(L)) return //Fucka you
	if(end == -1) end = L.len	//Called without start / end parameters
	if( start < end)
		var/obj/machinery/camera/C
		var/obj/machinery/camera/P

		var/pivot = start + round(abs(end - start) / 2 )
		P = L[pivot]
		L.Swap(end, pivot)
		pivot = start
		if (!istype(P)) CRASH("Fuck you, this list does not contain only cameras!")

		for(var/i = start; i < end; i++)
			C = L[i]
			if (!istype(C)) CRASH("Fuck you, this list does not contain only cameras!")

			//Okay, sort on c_tag_order then c_tag
			if(C.c_tag_order != P.c_tag_order)
				if(C.c_tag_order < P.c_tag_order)
					L.Swap(i, pivot)
					pivot++
			else
				if(sorttext(C.c_tag, P.c_tag) > 0)
					L.Swap(i, pivot)
					pivot++

		L.Swap(pivot, end)

		L = .(L, start, pivot - 1)
		L = .(L, pivot + 1, end)

	return L

/mob/living/silicon/ai/attack_ai(var/mob/user as mob)
	if (user != src && user != src.eyecam)
		return

	if (isdead(src) || !src.classic_move)
		return

	var/list/L = list()
	for_by_tcl(C, /obj/machinery/camera)
		L.Add(C)

	L = camera_sort(L)

	var/list/D = list()
	var/counter = 1
	for (var/obj/machinery/camera/C in L)
		if (C.network == src.network)
			var/T = text("[][]", C.c_tag, (C.camera_status ? null : " (Deactivated)"))
			if(D[T])
				D["[T] #[counter++]"] = C
			else
				D[T] = C
				counter = 1

	var/t = tgui_input_list(user, "Which camera should you change to?", "View Camera", D)

	if (!t)
		src.tracker.cease_track()
		src.switchCamera(null)
		return 0

	var/obj/machinery/camera/C = D[t]

	switchCamera(C)

	return


/datum/ai_camera_tracker
	var/mob/tracking = null
	var/mob/living/silicon/ai/owner = null

	var/last_track = 0	//When did we do the last tracking attempt?
	var/delay = 10		//How long should we wait between attempts?

	var/success_delay = 10	//How long between refreshes if we succeeded in tracking someone?
	var/fail_delay = 50		// Same but in case we failed

	New(var/mob/living/silicon/ai/A)
		..()
		owner = A
		global.tracking_list += src

	disposing()
		owner = null
		tracking = null
		global.tracking_list -= src
		..()

	proc/begin_track(mob/target as mob)
		if(!owner || !target)
			return

		tracking = target

		if (!owner.deployed_to_eyecam)
			if (!owner.deployed_to_eyecam)
				owner.eye_view()

		boutput(owner.eyecam, "Tracking...")
		process() //Process now!!!

	proc/cease_track()
		owner.eyecam.stopObserving()
		tracking = null
		delay = success_delay
		owner.hud?.update_tracking()

	proc/cease_track_temporary()
		owner.eyecam.stopObserving()

	proc/process()
		if(!tracking || !owner || ( ( (last_track + delay) > world.timeofday ) && (world.timeofday > last_track) ) )
			return


		var/failedToTrack = 0
		if (!can_track(tracking))
			failedToTrack = 1

		#ifndef UPSCALED_MAP
		if(!failedToTrack) //We don't have a premature failure
			failedToTrack = 1 //Assume failure
			var/turf/T = get_turf(tracking)
			if (T.camera_coverage_emitters && length(T.camera_coverage_emitters))
				failedToTrack = 0
		#endif

		if (failedToTrack)
			cease_track_temporary()
			//owner.show_text("Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the Cancel-Camera-View verb).")
			delay = fail_delay
		else
			delay = success_delay
			owner.eyecam.observeMob(tracking)

		owner.hud.update_tracking()
		owner.eyecam.update_statics()

		last_track = world.timeofday

	proc/can_track(mob/target as mob)
		//Allow tracking of cyborgs & mobcritters, however
		//Track autofails if:
		//Target is wearing a syndicate ID
		//Target is inside a dummy
		//Target is not at a turf
		//Target is not on station level
		return (target.loc?.z == 1) \
				&& ((issilicon(target) && istype(target.loc, /turf) ) \
				|| (ismobcritter(target) && istype(target.loc, /turf) ) \
				|| !((ishuman(target) \
				&& istype(target:wear_id, /obj/item/card/id/syndicate)) \
				|| (hasvar(target, "wear_id") && istype(target:wear_id, /obj/item/device/pda2) && target:wear_id:ID_card && istype(target:wear_id:ID_card, /obj/item/card/id/syndicate)) \
				||  !istype(target.loc, /turf)))
