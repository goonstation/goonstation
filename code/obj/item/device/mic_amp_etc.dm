TYPEINFO(/obj/item/device/microphone)
	start_listen_effects = list(LISTEN_EFFECT_MICROPHONE)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD_RANGE_1)
	start_listen_languages = list(LANGUAGE_ALL)

/obj/item/device/microphone
	name = "microphone"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "mic"
	item_state = "mic"
	HELP_MESSAGE_OVERRIDE("Turn on or off by <b>using in-hand</b>.<br>Only picks up sound in your <b>active hand</b>.")

	var/max_font = 4
	var/font_amp = 1
	var/on = 0

	get_desc()
		..()
		. += "It's currently [src.on ? "on" : "off"]."

	attack_self(mob/user as mob)
		src.on = !(src.on)
		tooltip_rebuild = TRUE
		user.show_text("You switch [src] [src.on ? "on" : "off"].")
		if (src.on && prob(5))
			if (locate(/obj/machinery/loudspeaker) in range(2, user))
				for_by_tcl(S, /obj/machinery/loudspeaker)
					if(!IN_RANGE(S, user, 7)) continue
					S.visible_message(SPAN_ALERT("[S] lets out a horrible [pick("shriek", "squeal", "noise", "squawk", "screech", "whine", "squeak")]!"))
					playsound(S.loc, 'sound/items/mic_feedback.ogg', 30, 1)

	attack_hand(mob/user)
		if (user.find_in_hand(src) && src.on)
			playsound(user, 'sound/misc/miccheck.ogg', 30, TRUE)
			user.visible_message(SPAN_EMOTE("[user] taps [src] with [his_or_her(user)] hand."))
		else
			return ..()


TYPEINFO(/obj/mic_stand)
	analyser_flags = parent_type::analyser_flags | ANALYSER_ELECTRONIC
	mats = 10

/obj/mic_stand
	name = "microphone stand"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "micstand"
	layer = FLY_LAYER
	var/obj/item/device/microphone/myMic = null

	New()
		SPAWN(1 DECI SECOND)
			if (!myMic)
				myMic = new(src)
		return ..()

	attack_hand(mob/user)
		if (!myMic)
			return ..()
		user.put_in_hand_or_drop(myMic)
		myMic = null
		src.UpdateIcon()
		return ..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/microphone))
			if (myMic)
				user.show_text("There's already a microphone on [src]!", "red")
				return
			user.show_text("You place [W] on [src].", "blue")
			myMic = W
			user.u_equip(W)
			W.set_loc(src)
			src.UpdateIcon()
		else
			return ..()

	update_icon()
		if (myMic)
			switch (myMic.icon_state)
				if ("radio_mic1")
					src.icon_state = "micstand-b"
				if ("radio_mic2")
					src.icon_state = "micstand-r"
				else
					src.icon_state = "micstand"
		else
			src.icon_state = "micstand-empty"

TYPEINFO(/obj/machinery/loudspeaker)
	mats = 15

/obj/machinery/loudspeaker
	name = "loudspeaker"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "loudspeaker"
	anchored = ANCHORED
	density = 1
	object_flags = NO_BLOCK_TABLE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL

	HELP_MESSAGE_OVERRIDE("Speech into nearby microphones will be played over this loudspeaker.")

/obj/machinery/loudspeaker/New()
	. = ..()
	START_TRACKING
	src.AddComponent(/datum/component/obj_projectile_damage)
	src.UnsubscribeProcess()

/obj/machinery/loudspeaker/disposing()
	. = ..()
	STOP_TRACKING

/obj/machinery/loudspeaker/set_broken()
	. = ..()
	if(.) return
	src.SubscribeToProcess()
	AddComponent(/datum/component/equipment_fault/elecflash, tool_flags = TOOL_SCREWING | TOOL_WIRING | TOOL_SNIPPING)
	src.visible_message(SPAN_ALERT("[src] sparks and pops, shorting out!"))
	playsound(src, 'sound/effects/screech_tone.ogg', 70, 2, pitch=0.5)
	for (var/mob/living/M in hearers(5, src))
		M.do_disorient(50, target_type = DISORIENT_EAR, remove_stamina_below_zero = TRUE)

/obj/machinery/loudspeaker/ex_act(severity)
	. = ..()
	if(QDELETED(src))
		return
	switch(severity)
		if (2)
			changeHealth(rand(-25, -35))
		if (3)
			changeHealth(rand(-5, -15))

/obj/machinery/loudspeaker/process(mult)
	. = ..()
	if (!(src.status & BROKEN))
		src.UnsubscribeProcess()

/obj/machinery/loudspeaker/changeHealth(change)
	. = ..()
	if(prob(100*(src._health/src._max_health)))
		src.set_broken()

TYPEINFO(/obj/machinery/loudspeaker/positional_multi_emitter_demo)
	admin_procs = list(
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_play,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_stop,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_pause_or_resume,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_set_song,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_set_volume,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_set_pitch,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_toggle_repeat,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_refresh_emitters,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_toggle_hand_controls,
		/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_debug_managed_sound,
	)

/// Demo loudspeaker that plays one managed positional sound through nearby passive demo speakers.
/obj/machinery/loudspeaker/positional_multi_emitter_demo
	name = "positional multi-emitter demo speaker"
	desc = "A loudspeaker playing a synchronized positional test sound from nearby demo emitters."

	/// Sound file used by this demo speaker.
	var/loop_sound = 'sound/ambience/station/Machinery_Computers1.ogg'
	/// Base volume before distance falloff and listener volume preferences.
	var/loop_volume = 60
	/// Pitch/frequency multiplier used by the demo loop.
	var/loop_pitch = 1
	/// Whether the demo sound repeats on the client.
	var/loop_repeat = TRUE
	/// Extra range added to MAX_SOUND_RANGE for this demo.
	var/loop_extrarange = 0
	/// Volume channel used by the demo loop.
	var/loop_volume_channel = VOLUME_CHANNEL_INSTRUMENTS
	/// Managed positional sound behavior flags.
	var/loop_flags = 0
	/// Maximum interval between managed positional sound updates.
	var/loop_update_interval = MANAGED_POSITIONAL_SOUND_DEFAULT_UPDATE_INTERVAL
	/// Whether the demo starts playing when spawned.
	var/starts_on = TRUE
	/// If FALSE, hand controls do nothing. Admin-interact controls still work.
	var/hand_controls_enabled = TRUE
	/// Maximum distance to search for passive demo emitters when starting.
	var/emitter_search_range = 15
	/// Weak handle to this demo speaker's active managed positional sound.
	var/datum/weakref/managed_sound_loop = null

/obj/machinery/loudspeaker/positional_multi_emitter_demo/New()
	. = ..()
	if (src.starts_on)
		SPAWN(1 DECI SECOND)
			if (!QDELETED(src))
				src.start_sound_loop()

/obj/machinery/loudspeaker/positional_multi_emitter_demo/disposing()
	src.stop_sound_loop()
	. = ..()

/obj/machinery/loudspeaker/positional_multi_emitter_demo/attack_hand(mob/user)
	if (!src.can_use_demo_controls(user))
		user?.show_text("[src]'s controls are locked.", "red")
		return

	src.clear_inactive_sound_loop()
	var/datum/managed_positional_sound/managed_sound = src.get_managed_sound_loop()
	if (!managed_sound)
		if (tgui_alert(user, "What would you like to do with [src]?", "Speaker Controls", list("Play", "Cancel")) == "Play")
			if (src.start_sound_loop())
				user?.show_text("Started [src].")
			else
				user?.show_text("[src] doesn't respond. Check that a managed positional sound channel is available.", "red")
		return

	var/pause_choice = managed_sound.paused ? "Resume" : "Pause"
	var/repeat_choice = src.loop_repeat ? "Repeat Off" : "Repeat On"
	switch (tgui_input_list(user, "What would you like to do with [src]?", "Speaker Controls", list(pause_choice, repeat_choice, "Stop", "Cancel")))
		if ("Pause", "Resume")
			var/paused = !managed_sound.paused
			managed_sound.set_paused(paused)
			user?.show_text("[paused ? "Paused" : "Resumed"] [src].")
		if ("Repeat Off", "Repeat On")
			src.set_loop_repeat(!src.loop_repeat)
			user?.show_text("Turned [src]'s repeat [src.loop_repeat ? "on" : "off"].")
		if ("Stop")
			src.stop_sound_loop()
			user?.show_text("Stopped [src].")
	return

/obj/machinery/loudspeaker/positional_multi_emitter_demo/set_broken()
	. = ..()
	if (!.)
		src.stop_sound_loop()

/// Starts this demo speaker's looping managed positional sound and attaches passive demo speakers as emitters.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/start_sound_loop()
	src.clear_inactive_sound_loop()
	if (src.get_managed_sound_loop() || (src.status & BROKEN) || !src.loop_sound)
		return FALSE

	var/datum/managed_positional_sound/managed_sound = play_managed_positional_sound(src, src.loop_sound, src.loop_volume, FALSE, src.loop_extrarange, src.loop_pitch, 0, src.loop_volume_channel, src.loop_flags, src.loop_update_interval, src.loop_repeat)
	if (!managed_sound)
		return FALSE

	src.managed_sound_loop = get_weakref(managed_sound)
	src.refresh_emitters()
	return TRUE

/// Rebuilds this demo sound's passive emitter list.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/refresh_emitters()
	var/datum/managed_positional_sound/managed_sound = src.get_managed_sound_loop()
	if (!managed_sound)
		return 0

	var/emitters_added = 0
	var/turf/source_turf = get_turf(src)
	managed_sound.clear_emitters()
	managed_sound.add_emitter(src)
	for_by_tcl(emitter, /obj/machinery/loudspeaker/positional_multi_emitter_demo/passive)
		var/turf/emitter_turf = get_turf(emitter)
		if (!source_turf || !emitter_turf || emitter_turf.z != source_turf.z || !IN_RANGE(src, emitter, src.emitter_search_range))
			continue
		if (emitter.status & BROKEN)
			continue
		managed_sound.add_emitter(emitter)
		emitters_added++

	return emitters_added

/// Stops this demo speaker's active managed positional sound.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/stop_sound_loop()
	var/datum/managed_positional_sound/managed_sound = src.get_managed_sound_loop()
	if (!managed_sound)
		src.managed_sound_loop = null
		return FALSE

	managed_sound.stop()
	src.managed_sound_loop = null
	return TRUE

/// Returns TRUE if a user may use the demo's normal hand controls.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/can_use_demo_controls(mob/user)
	return src.hand_controls_enabled

/// Returns this demo speaker's active managed sound, if it still exists.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/get_managed_sound_loop()
	RETURN_TYPE(/datum/managed_positional_sound)
	var/datum/managed_positional_sound/managed_sound = src.managed_sound_loop?.deref()
	if (managed_sound?.active)
		return managed_sound
	return null

/// Clears this demo's owner reference after a managed sound self-disposes or finishes.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/clear_inactive_sound_loop()
	var/datum/managed_positional_sound/managed_sound = src.get_managed_sound_loop()
	if (!src.managed_sound_loop)
		return FALSE
	if (!managed_sound)
		src.managed_sound_loop = null
		return TRUE
	if (managed_sound.is_finished())
		src.stop_sound_loop()
		return TRUE
	return FALSE

/// Sets whether this demo's current and future managed sound should repeat.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/set_loop_repeat(repeat)
	src.loop_repeat = repeat ? TRUE : FALSE
	src.clear_inactive_sound_loop()
	src.get_managed_sound_loop()?.set_repeat(src.loop_repeat)

/// Admin-interact: start playback.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_play()
	set name = "Managed Positional Demo: Play"
	USR_ADMIN_ONLY
	var/mob/user = usr
	if (src.start_sound_loop())
		user?.show_text("Started [src].")
	else
		user?.show_text("[src] is already playing or could not start.", "red")

/// Admin-interact: stop playback.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_stop()
	set name = "Managed Positional Demo: Stop"
	USR_ADMIN_ONLY
	var/mob/user = usr
	if (src.stop_sound_loop())
		user?.show_text("Stopped [src].")
	else
		user?.show_text("[src] is not playing.", "red")

/// Admin-interact: pause or resume playback without losing the synchronized timeline.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_pause_or_resume()
	set name = "Managed Positional Demo: Pause/Resume"
	USR_ADMIN_ONLY
	var/mob/user = usr
	src.clear_inactive_sound_loop()
	var/datum/managed_positional_sound/managed_sound = src.get_managed_sound_loop()
	if (!managed_sound)
		user?.show_text("[src] is not playing.", "red")
		return

	var/paused = !managed_sound.paused
	managed_sound.set_paused(paused)
	user?.show_text("[paused ? "Paused" : "Resumed"] [src].")

/// Admin-interact: change the sound file used by the demo loop. Restarts active playback.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_set_song()
	set name = "Managed Positional Demo: Set Song"
	USR_ADMIN_ONLY
	var/mob/user = usr
	var/new_sound = input(user, "Choose the sound file for this demo speaker.", "Set Song", src.loop_sound) as sound|null
	if (isnull(new_sound))
		return

	src.clear_inactive_sound_loop()
	var/datum/managed_positional_sound/managed_sound = src.get_managed_sound_loop()
	var/was_playing = managed_sound ? TRUE : FALSE
	var/was_paused = managed_sound?.paused
	src.loop_sound = new_sound
	if (was_playing)
		src.stop_sound_loop()
		if (src.start_sound_loop() && was_paused)
			src.get_managed_sound_loop()?.set_paused(TRUE)

	user?.show_text("Set [src]'s sound to [src.loop_sound].")

/// Admin-interact: change the base managed positional volume.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_set_volume()
	set name = "Managed Positional Demo: Set Volume"
	USR_ADMIN_ONLY
	var/mob/user = usr
	var/new_volume = tgui_input_number(user, "Base volume before distance falloff.", "Set Volume", default = clamp(src.loop_volume, 0, 200), max_value = 200, min_value = 0, round_input = FALSE)
	if (isnull(new_volume))
		return

	src.loop_volume = clamp(new_volume, 0, 200)
	src.clear_inactive_sound_loop()
	src.get_managed_sound_loop()?.set_volume(src.loop_volume)
	user?.show_text("Set [src]'s volume to [src.loop_volume].")

/// Admin-interact: change the pitch/frequency multiplier.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_set_pitch()
	set name = "Managed Positional Demo: Set Pitch"
	USR_ADMIN_ONLY
	var/mob/user = usr
	var/default_pitch = clamp(src.loop_pitch, -4, 4)
	if (!default_pitch)
		default_pitch = 1
	var/new_pitch = tgui_input_number(user, "Pitch/frequency multiplier. Negative values play backwards.", "Set Pitch", default = default_pitch, max_value = 4, min_value = -4, round_input = FALSE)
	if (isnull(new_pitch))
		return

	if (!new_pitch)
		new_pitch = 1
	src.loop_pitch = new_pitch
	src.clear_inactive_sound_loop()
	src.get_managed_sound_loop()?.set_pitch(src.loop_pitch)
	user?.show_text("Set [src]'s pitch to [src.loop_pitch].")

/// Admin-interact: toggle whether this demo sound loops.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_toggle_repeat()
	set name = "Managed Positional Demo: Toggle Repeat"
	USR_ADMIN_ONLY
	var/mob/user = usr
	src.set_loop_repeat(!src.loop_repeat)
	user?.show_text("Turned [src]'s repeat [src.loop_repeat ? "on" : "off"].")

/// Admin-interact: relink passive demo emitters in range.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_refresh_emitters()
	set name = "Managed Positional Demo: Refresh Emitters"
	USR_ADMIN_ONLY
	var/mob/user = usr
	src.clear_inactive_sound_loop()
	if (!src.get_managed_sound_loop())
		user?.show_text("[src] is not playing.", "red")
		return

	var/emitters_added = src.refresh_emitters()
	user?.show_text("Linked [emitters_added] passive emitter[s_es(emitters_added)].")

/// Admin-interact: toggle whether normal hand controls do anything.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_toggle_hand_controls()
	set name = "Managed Positional Demo: Toggle Hand Controls"
	USR_ADMIN_ONLY
	var/mob/user = usr
	src.hand_controls_enabled = !src.hand_controls_enabled
	user?.show_text("[src]'s hand controls are now [src.hand_controls_enabled ? "enabled" : "disabled"].")

/// Admin-interact: dumps managed positional sound state for this speaker and the invoking client's channel.
/obj/machinery/loudspeaker/positional_multi_emitter_demo/proc/admin_debug_managed_sound()
	set name = "Managed Positional Demo: Debug Sound"
	USR_ADMIN_ONLY
	var/mob/user = usr
	var/client/C = user?.client
	if (!C)
		return

	var/list/debug_lines = list()
	debug_lines += "Managed positional demo debug"
	debug_lines += "world.time=[world.time]"
	debug_lines += "speaker=\ref[src] loc=([src.x], [src.y], [src.z]) status=[src.status]"
	debug_lines += "client=[C] mob=\ref[C.mob] mob_type=[C.mob?.type] mob_loc=([C.mob?.x], [C.mob?.y], [C.mob?.z])"
	var/atom/client_eye = C.eye
	debug_lines += "client.eye=\ref[client_eye] eye_type=[client_eye?.type] eye_loc=([client_eye?.x], [client_eye?.y], [client_eye?.z]) perspective=[C.perspective]"
	if (istype(C.mob, /mob/dead/target_observer))
		var/mob/dead/target_observer/target_observer = C.mob
		var/atom/observe_target = target_observer.target
		debug_lines += "target_observer_target=\ref[observe_target] target_type=[observe_target?.type] target_loc=([observe_target?.x], [observe_target?.y], [observe_target?.z])"

	var/datum/controller/process/managed_positional_sounds/process = global.managed_positional_sound_process
	debug_lines += "process=\ref[process]"
	if (process)
		var/mob/tracked_mob = process.client_listener_mobs?[C]
		var/list/tracked_sounds = process.client_sounds?[C]
		var/dirty_client = process.dirty_clients?[C] ? TRUE : FALSE
		var/needs_prime = process.dirty_clients_need_prime?[C] ? TRUE : FALSE
		debug_lines += "process.tracked_mob=\ref[tracked_mob] tracked_mob_type=[tracked_mob?.type] tracked_mob_loc=([tracked_mob?.x], [tracked_mob?.y], [tracked_mob?.z])"
		debug_lines += "process.client_sounds_len=[length(tracked_sounds)] dirty_client=[dirty_client] needs_prime=[needs_prime]"

	var/datum/managed_positional_sound/managed_sound = src.get_managed_sound_loop()
	debug_lines += "managed_sound=\ref[managed_sound]"
	if (managed_sound)
		var/managed_channel = managed_sound.sound_channel
		var/listeners_has_client = (C in managed_sound.listeners)
		var/client_stored_volume = managed_sound.client_stored_volumes[C]
		var/client_sound_pan = managed_sound.client_sound_pan[C]
		var/client_sound_x = managed_sound.client_sound_x[C]
		var/client_sound_z = managed_sound.client_sound_z[C]
		var/client_environment = managed_sound.client_environment[C]
		var/client_echo = managed_sound.client_echo[C]
		debug_lines += "active=[managed_sound.active] paused=[managed_sound.paused] repeat=[managed_sound.repeat] channel=[managed_channel] volume=[managed_sound.volume] pitch=[managed_sound.pitch]"
		debug_lines += "duration=[managed_sound.sound_duration] elapsed=[managed_sound.get_elapsed_seconds()] offset=[managed_sound.get_sound_offset()] start_time=[managed_sound.start_time] pause_started_time=[managed_sound.pause_started_time]"
		debug_lines += "listeners_has_client=[listeners_has_client] listeners_len=[length(managed_sound.listeners)] emitters_len=[length(managed_sound.emitters)]"
		debug_lines += "client_stored_volume=[client_stored_volume] client_pan=[client_sound_pan] client_x=[client_sound_x] client_z=[client_sound_z] client_env=[client_environment] client_echo=[client_echo]"

		var/list/channel_state = C.sound_playing[managed_channel]
		if (islist(channel_state))
			var/channel_stored_volume = channel_state[1]
			var/channel_volume_channel = channel_state[2]
			debug_lines += "client.sound_playing channel [managed_channel]: stored_volume=[channel_stored_volume] volume_channel=[channel_volume_channel]"
		else
			var/channel_state_text = isnull(channel_state) ? "null" : "[channel_state]"
			debug_lines += "client.sound_playing channel [managed_channel]: [channel_state_text]"

		var/emitter_number = 0
		for (var/datum/managed_positional_sound_emitter/emitter as anything in managed_sound.emitters)
			emitter_number++
			var/turf/emitter_turf = get_turf(emitter.source)
			debug_lines += "emitter#[emitter_number]=\ref[emitter] source=\ref[emitter.source] source_type=[emitter.source?.type] loc=([emitter_turf?.x], [emitter_turf?.y], [emitter_turf?.z])"

		var/found_sound_query_channel = FALSE
		var/sound_query_count = 0
		for (var/sound/S as anything in C.SoundQuery())
			sound_query_count++
			if (S.channel != managed_channel)
				continue
			found_sound_query_channel = TRUE
			debug_lines += "SoundQuery managed channel: file=[S.file] volume=[S.volume] status=[S.status] repeat=[S.repeat] len=[S.len] offset=[S.offset] frequency=[S.frequency] pan=[S.pan] xyz=([S.x], [S.y], [S.z]) env=[S.environment] echo=[S.echo]"
		debug_lines += "SoundQuery total=[sound_query_count] found_managed_channel=[found_sound_query_channel]"

	boutput(user, "<pre>[html_encode(jointext(debug_lines, "\n"))]</pre>")

TYPEINFO(/obj/machinery/loudspeaker/positional_multi_emitter_demo/passive)
	admin_procs = null

/// Passive multi-emitter demo node. Place these near a multi-emitter demo speaker. Toggle it on and off and they should link up
/obj/machinery/loudspeaker/positional_multi_emitter_demo/passive
	name = "positional multi-emitter demo node"
	desc = "A passive loudspeaker used as an extra emitter for a nearby multi-emitter demo speaker."
	starts_on = FALSE

	New()
		. = ..()
		START_TRACKING
	disposing()
		STOP_TRACKING
		. = ..()

/obj/machinery/loudspeaker/positional_multi_emitter_demo/passive/attack_hand(mob/user)
	user?.show_text("[src] is a passive emitter node.")
	return
