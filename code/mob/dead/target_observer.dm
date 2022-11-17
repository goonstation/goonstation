/mob/dead/target_observer
	density = 1
	name = "spooky ghost"
	icon = null
	event_handler_flags = 0
	var/atom/target

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_GHOST)
		START_TRACKING

	disposing()
		//If our target is a mob we should also clean ourselves up and leave their observer list without a null in it.
		var/mob/living/M = src.target
		if(istype(M))
			M.observers -= src

		if (isobj(target))
			src.UnregisterSignal(target, list(COMSIG_PARENT_PRE_DISPOSING))

		if (!src.ghost)
			src.ghost = new(src.corpse)

			if (!src.corpse)
				src.ghost.name = src.name
				src.ghost.real_name = src.real_name

		if (corpse)
			corpse.ghost = src.ghost
			src.ghost.corpse = corpse

		src.ghost.delete_on_logout = src.ghost.delete_on_logout_reset

		if (src.client)
			src.removeOverlaysClient(src.client)

		var/ASLoc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
		if (target)
			var/turf/T = get_turf(target)
			if (T && (!isghostrestrictedz(T.z) || (isghostrestrictedz(T.z) && (restricted_z_allowed(src, T) || (src.client && src.client.holder)))))
				src.ghost.set_loc(T)
			else
				if (ASLoc)
					src.ghost.set_loc(ASLoc)
				else
					src.ghost.z = 1
		else
			if (ASLoc)
				src.ghost.set_loc(ASLoc)
			else
				src.ghost.z = 1
		STOP_TRACKING
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
					qdel(src)
			else
				qdel(src)
#endif
		return

	process_move(keys)
		if(keys && src.move_dir)
			stop_observing()

	apply_camera(client/C)
		var/mob/living/M = src.target
		if (istype(M))
			M.apply_camera(C)
		else
			..()

	cancel_camera()
		set hidden = 1
		return

	proc/set_observe_target(target)
		//If there's an existing target we should clean up after ourselves
		if(src.target == target)
			return //No sense in doing all this if we're not changing targets
		if(src.target)
			var/mob/living/M = src.target
			src.target = null
			M.removeOverlaysClient(src.client)
			for (var/datum/hud/hud in M.huds)
				src.detach_hud(hud)
			if(istype(M))
				M.observers -= src

		if(!target) //Uh oh, something went wrong here. Act natural and return the user to a regular ghost.
			qdel(src)
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
			src.RegisterSignal(target, COMSIG_PARENT_PRE_DISPOSING, .verb/stop_observing)

	click(atom/target, params, location, control)
		if(!isnull(target) && (target.flags & TGUI_INTERACTIVE))
			if(ismob(src.target))
				var/mob/mob_target = src.target
				for(var/datum/tgui/ui in mob_target.tgui_open_uis)
					if(ui.src_object == target)
						return target.ui_interact(src)
		return ..()


	verb
		stop_observing()
			set name = "Stop Observing"
			set category = "Commands"

			qdel(src) //lol


/mob/dead/target_observer/slasher_ghost
	name = "spooky not-quite ghost"
	var/start_time

	New()
		..()
		start_time = world.time


	stop_observing()
		return

	proc/slasher_ghostize()
		RETURN_TYPE(/mob/dead/observer)
		if(src.key || src.client)
			var/mob/dead/observer/O = new/mob/dead/observer(src)
			O.bioHolder.CopyOther(src.bioHolder, copyActiveEffects = 0)
			if (client) client.set_color()
			setdead(O)

			src.mind?.transfer_to(O)
			src.ghost = O

			O.update_item_abilities()
			return O
		return null
