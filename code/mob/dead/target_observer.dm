TYPEINFO(/mob/dead/target_observer)
	start_listen_modifiers = null
	start_listen_inputs = list(LISTEN_INPUT_DEADCHAT)
	start_listen_languages = null
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_DEADCHAT_GHOST)

/mob/dead/target_observer
	density = 1
	name = "spooky ghost"
	icon = null
	event_handler_flags = 0
	use_speech_bubble = FALSE
	var/atom/target
	var/is_respawnable = TRUE
	/// Is this observer locked to one particular owner?
	var/locked = FALSE

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_GHOST)
		START_TRACKING

	disposing()
		//If our target is a mob we should also clean ourselves up and leave their observer list without a null in it.
		var/mob/living/M = src.target
		if(istype(M))
			LAZYLISTREMOVE(M.observers, src)
			src.UnregisterSignal(M, list(COMSIG_TGUI_WINDOW_OPEN))

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

		STOP_TRACKING
		..()

	// Observer Life() only runs for admin ghosts (Convair880).
	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

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

	/// Let's have a proc so as to make it easier to reassign an observer.
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
				LAZYLISTREMOVE(M.observers, src)

		if(!target) //Uh oh, something went wrong here. Act natural and return the user to a regular ghost.
			qdel(src)
			return

		src.target = target
		src.set_loc(target)
		if(src.ghost?.auto_tgui_open)
			RegisterSignal(target, COMSIG_TGUI_WINDOW_OPEN, PROC_REF(open_tgui_if_interactive))
		set_eye(target)

		var/mob/living/M = target
		if (istype(M))
			LAZYLISTADD(M.observers, src)
			if(src.client)
				M.updateOverlaysClient(src.client)
			for (var/datum/hud/hud in M.huds)
				src.attach_hud(hud)

		if (isobj(target))
			src.RegisterSignal(target, COMSIG_PARENT_PRE_DISPOSING, VERB_REF(stop_observing))

	click(atom/target, params, location, control)
		if(!isnull(target) && (target.flags & TGUI_INTERACTIVE))
			if(ismob(src.target))
				var/mob/mob_target = src.target
				for(var/datum/tgui/ui in mob_target.tgui_open_uis)
					if(ui.src_object == target)
						return target.ui_interact(src)
		return ..()

	/// Checks if the tgui window being created is from an object with TGUI_INTERACTIVE, and opens the window for the observer if true
	proc/open_tgui_if_interactive(mob/sender, datum/tgui/observe_window)
		if(istype(observe_window.src_object, /atom))
			var/atom/atom_object = observe_window.src_object
			if(atom_object.flags & TGUI_INTERACTIVE)
				return observe_window.src_object.ui_interact(src)

	verb
		stop_observing()
			set name = "Stop Observing"
			set category = "Commands"

			qdel(src) //lol


TYPEINFO(/mob/dead/target_observer/slasher_ghost)
	start_listen_modifiers = null
	start_listen_inputs = list(LISTEN_INPUT_EARS)
	start_listen_languages = list(LANGUAGE_ENGLISH)
	start_speech_modifiers = null
	start_speech_outputs = null

/mob/dead/target_observer/slasher_ghost
	name = "spooky not-quite ghost"
	is_respawnable = FALSE
	locked = TRUE
	default_speech_output_channel = null

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


/mob/dead/target_observer/verb/ghostjump(x as num, y as num, z as num)
	set name = ".ghostjump"
	set hidden = TRUE

	if(src.type != /mob/dead/target_observer)
		return // ugh, bad inheritance :whelm:

	var/turf/T = locate(x, y, z)
	if (!can_ghost_be_here(src, T))
		return

	if(isnull(src.ghost))
		src.ghost = new(src.corpse)

		if (!src.corpse)
			src.ghost.name = src.name
			src.ghost.real_name = src.real_name

	var/mob/dead/observer/ghost = src.ghost
	qdel(src)
	ghost.set_loc(T)
