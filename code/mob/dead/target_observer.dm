var/list/observers = list()

/mob/dead/target_observer
	invisibility = 10
	density = 1
	name = "spooky ghost"
	icon = null
	event_handler_flags = 0
	var/atom/target
	var/mob/corpse = null
	var/mob/dead/observer/my_ghost = null

	New()
		..()
		observers += src
		mobs += src
		//set_observe_target(target)

	unpooled()
		..()
		observers += src
		mobs += src

	pooled()
		mobs -= src
		//Remove ourselves from the global observer list
		observers -= src
		//If our target is a mob we should also clean ourselves up and leave their observer list without a null in it.
		var/mob/living/M = src.target
		if(istype(M))
			M.observers -= src

		if (my_ghost )
			my_ghost.set_loc(get_turf(src))
		my_ghost = null
		target = null


		for (var/datum/hud/H in huds)
			for (var/obj/screen/hud/S in H.objects)
				if (S:master == src)
					S:master = null
			detach_hud(H)
			H.mobs -= src
		huds.len = 0

		..()

	disposing()
		//Remove ourselves from the global observer list
		observers -= src
		//If our target is a mob we should also clean ourselves up and leave their observer list without a null in it.
		var/mob/living/M = src.target
		if(istype(M))
			M.observers -= src

		if (my_ghost)
			my_ghost.set_loc(get_turf(src))
		my_ghost = null
		target = null

		..()

	// Observer Life() only runs for admin ghosts (Convair880).
	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (src.client && src.client.holder)
			src.antagonist_overlay_refresh(0, 0)

#ifdef TWITCH_BOT_ALLOWED
		if (IS_TWITCH_CONTROLLED(src))
			if (ismob(target))
				var/mob/M = target
				if (isdead(M))
					stop_observing()
			else
				stop_observing()
#endif
		return

	process_move(keys)
		src.stop_observing()

	apply_camera(client/C)
		var/mob/living/M = src.target
		if (istype(M))
			M.apply_camera(C)
		else
			..()

	cancel_camera()
		set hidden = 1
		return

	//Alias ghostize() to stop_observing() so that a target observer is correctly ghostified.
	ghostize()
		stop_observing()

	proc/set_observe_target(target)
		//If there's an existing target we should clean up after ourselves
		if(src.target == target) return //No sense in doing all this if we're not changing targets
		if(src.target)
			var/mob/living/M = src.target
			src.target = null
			M.removeOverlaysClient(src.client)
			for (var/datum/hud/hud in M.huds)
				src.detach_hud(hud)
			if(istype(M))
				M.observers -= src



		if(!target) //Uh oh, something went wrong here. Act natural and return the user to a regular ghost.
			stop_observing()
			return
		//Let's have a proc so as to make it easier to reassign an observer.
		src.target = target
		src.set_loc(target)

		set_eye(target)

		var/mob/living/M = target
		if (istype(M))
			M.observers += src
			if(src.client)
				M.updateOverlaysClient(src.client)
			for (var/datum/hud/hud in M.huds)
				src.attach_hud(hud)

		if (isobj(target))
			src.RegisterSignal(target, list(COMSIG_PARENT_PRE_DISPOSING), .verb/stop_observing)


	verb
		stop_observing()
			set name = "Stop Observing"
			set category = "Commands"

			if (isobj(target))
				src.UnregisterSignal(target, list(COMSIG_PARENT_PRE_DISPOSING))

			if (!my_ghost)
				my_ghost = new(src.corpse)

				if (!src.corpse)
					my_ghost.name = src.name
					my_ghost.real_name = src.real_name

			if (corpse)
				corpse.ghost = my_ghost
				my_ghost.corpse = corpse

			my_ghost.delete_on_logout = my_ghost.delete_on_logout_reset

			if (src.client)
				src.removeOverlaysClient(src.client)
				client.mob = my_ghost

			if (src.mind)
				mind.transfer_to(my_ghost)

			var/ASLoc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (target)
				var/turf/T = get_turf(target)
				if (T && (!isghostrestrictedz(T.z) || (isghostrestrictedz(T.z) && (restricted_z_allowed(my_ghost, T) || (my_ghost.client && my_ghost.client.holder)))))
					my_ghost.set_loc(T)
				else
					if (ASLoc)
						my_ghost.set_loc(ASLoc)
					else
						my_ghost.z = 1
			else
				if (ASLoc)
					my_ghost.set_loc(ASLoc)
				else
					my_ghost.z = 1

			src.my_ghost = null
			pool(src)


