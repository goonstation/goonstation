/// Managed positional sounds are for sounds whose audible volume and pan need to keep following listeners after playback starts.
///
/// Basic use:
/// - Call `play_managed_positional_sound(source, sound_file, volume, ..., repeat = TRUE/FALSE)`.
/// - Store a weakref to the returned `/datum/managed_positional_sound` on the owning object when you only need a control handle.
/// - Call `stop()` or qdel the datum when the owner is done with it. Non-repeating sounds self-dispose after their length is known and elapsed.
/// - Use the public owner controls on the datum for runtime changes:
///   `set_volume()`, `set_pitch()`, `set_repeat()`, `set_paused()`, `set_update_interval()`, `add_emitter()`, `remove_emitter()`, and `clear_emitters()`.
///
/// Implementation example using a weakref:
/// ```
/// var/datum/weakref/managed_sound = null
///
/// proc/start_sound()
/// 	var/datum/managed_positional_sound/sound = play_managed_positional_sound(src, 'sound/path.ogg', 60, channel = VOLUME_CHANNEL_GAME, repeat = TRUE)
/// 	src.managed_sound = get_weakref(sound)
///
/// proc/get_sound()
/// 	RETURN_TYPE(/datum/managed_positional_sound)
/// 	return src.managed_sound?.deref()
///
/// proc/stop_sound()
/// 	src.get_sound()?.stop()
/// 	src.managed_sound = null
/// ```
///
///
/// Multi-emitter model:
/// - One datum is one playback identity, one BYOND channel, and one synchronized timeline.
/// - For grouped sounds, store the weakref on a controller/owning object that should outlive individual emitters.
/// - Add extra emitters with `add_emitter(atom)`. All emitters share the same sound and repeat/offset state.
/// - Listener volume comes from the loudest effective emitter so grouped speakers do not stack volume at midpoints.
/// - Listener pan is blended from nearby emitters as a soft field to avoid hard left/right handoffs.
///
/// Multi-emitter implementation example:
/// ```
/// var/datum/weakref/managed_sound = null
///
/// proc/start_alarm(list/atom/emitters)
/// 	if (!length(emitters))
/// 		return
///
/// 	var/datum/managed_positional_sound/sound = play_managed_positional_sound(emitters[1], 'sound/path.ogg', 60, channel = VOLUME_CHANNEL_GAME, repeat = TRUE)
/// 	if (!sound)
/// 		return
///
/// 	src.managed_sound = get_weakref(sound)
/// 	for (var/atom/emitter as anything in emitters)
/// 		sound.add_emitter(emitter)
///
/// proc/refresh_alarm_emitters(list/atom/emitters)
/// 	var/datum/managed_positional_sound/sound = src.managed_sound?.deref()
/// 	if (!sound)
/// 		return
///
/// 	sound.clear_emitters()
/// 	for (var/atom/emitter as anything in emitters)
/// 		sound.add_emitter(emitter)
/// ```

/// Maps reserved managed positional sound channels to the datum currently owning them.
var/global/list/managed_positional_sound_channels = list()

/// Registers a managed positional sound with the process scheduler, or queues it until the scheduler exists.
/proc/register_managed_positional_sound(datum/managed_positional_sound/managed_sound)
	if (!managed_sound)
		return

	if (global.managed_positional_sound_process)
		global.managed_positional_sound_process.register_sound(managed_sound)
	else
		global.pending_managed_positional_sounds[managed_sound] = TRUE

/// Removes a managed positional sound from both the pending queue and the active process scheduler.
/proc/unregister_managed_positional_sound(datum/managed_positional_sound/managed_sound)
	if (!managed_sound)
		return

	global.pending_managed_positional_sounds -= managed_sound
	global.managed_positional_sound_process?.unregister_sound(managed_sound)

/// Plays a positional sound whose volume and relative position are managed after the initial send.
/// Returns a datum owned by the caller. Hold onto it and call stop(), set_volume(), add_emitter(), or qdel() as needed.
/// The source argument is the first emitter only; it does not become special ownership for multi-emitter sounds.
/// Non-repeating sounds are automatically disposed by the process after their sound length elapses, if BYOND reports one.
/proc/play_managed_positional_sound(atom/source, soundin, vol, vary = FALSE, extrarange = 0, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0, update_interval = MANAGED_POSITIONAL_SOUND_DEFAULT_UPDATE_INTERVAL, repeat = FALSE)
	RETURN_TYPE(/datum/managed_positional_sound)
	if(isarea(source))
		CRASH("play_managed_positional_sound(): source is an area [source.name], sound is [soundin]")

	var/datum/managed_positional_sound/managed_sound = new /datum/managed_positional_sound(source, soundin, vol, vary, extrarange, pitch, ignore_flag, channel, flags, update_interval, repeat)
	if (!managed_sound.sound_channel)
		qdel(managed_sound)
		return null

	return managed_sound

/// Reserves a private BYOND sound channel for a managed positional sound datum.
/proc/acquire_managed_positional_sound_channel(datum/managed_positional_sound/managed_sound)
	if (!global.managed_positional_sound_channels)
		global.managed_positional_sound_channels = list()

	for (var/sound_channel = SOUNDCHANNEL_MANAGED_POSITIONAL_LOW to SOUNDCHANNEL_MANAGED_POSITIONAL_HIGH)
		var/channel_key = "[sound_channel]"
		if (global.managed_positional_sound_channels[channel_key])
			continue

		global.managed_positional_sound_channels[channel_key] = managed_sound
		return sound_channel

	return null

/// Releases a channel previously reserved by a managed positional sound datum.
/proc/release_managed_positional_sound_channel(datum/managed_positional_sound/managed_sound)
	if (!managed_sound?.sound_channel || !global.managed_positional_sound_channels)
		return

	var/channel_key = "[managed_sound.sound_channel]"
	if (global.managed_positional_sound_channels[channel_key] == managed_sound)
		global.managed_positional_sound_channels -= channel_key

/// Uses the standard positional sound falloff curve so managed positional sounds fade before hard range/space edges.
/proc/get_managed_positional_sound_falloff_multiplier(dist, max_range)
	if (max_range <= 0)
		return 0

	var/scaled_dist = clamp(dist / max_range, 0, 1)
	if (scaled_dist <= 0)
		return 1

	return 1 - ((MANAGED_POSITIONAL_SOUND_FALLOFF_SHAPE * (MANAGED_POSITIONAL_SOUND_FALLOFF_MIDPOINT ** MANAGED_POSITIONAL_SOUND_FALLOFF_EXPONENT)) / ((scaled_dist ** MANAGED_POSITIONAL_SOUND_FALLOFF_EXPONENT) + (MANAGED_POSITIONAL_SOUND_FALLOFF_MIDPOINT ** MANAGED_POSITIONAL_SOUND_FALLOFF_EXPONENT)))

/// Returns the broad spatial query range needed to find potentially audible managed positional listeners.
/proc/get_managed_positional_sound_query_range(vol, max_range)
	if (vol <= TOO_QUIET || max_range <= 0)
		return 0

	return max_range

/// Smoothly fades an emitter's blend influence as it approaches the edge of its audible range.
/proc/get_managed_positional_sound_blend_edge_fade(dist, max_range)
	if (max_range <= 0)
		return 0

	var/edge_width = max(MANAGED_POSITIONAL_SOUND_BLEND_MIN_EDGE_WIDTH, max_range * MANAGED_POSITIONAL_SOUND_BLEND_EDGE_FRACTION)
	var/scaled_edge_dist = clamp((max_range - dist) / edge_width, 0, 1)
	return scaled_edge_dist * scaled_edge_dist * (3 - (2 * scaled_edge_dist))

/// Returns multi-emitter pan blend weight. Square-root volume keeps quieter emitters relevant enough to avoid abrupt pan field handoffs.
/// The edge fade is squared so emitters entering their outer audible range do not immediately pull the pan field hard.
/proc/get_managed_positional_sound_pan_blend_weight(stored_volume, edge_fade)
	if (stored_volume <= 0 || edge_fade <= 0)
		return 0

	return sqrt(stored_volume) * edge_fade * edge_fade

/// Converts computed managed positional x intent into the explicit sound.pan value stored for the client and sent to BYOND.
/proc/get_managed_positional_sound_output_pan(sound_x)
	return clamp(sound_x * MANAGED_POSITIONAL_SOUND_EXPLICIT_PAN_PER_TILE, -MANAGED_POSITIONAL_SOUND_MAX_EXPLICIT_PAN, MANAGED_POSITIONAL_SOUND_MAX_EXPLICIT_PAN)

/// Applies the finalized managed positional output to a BYOND sound.
/// Normal managed sounds use explicit sound.pan; space echo/environment uses BYOND 3D offsets because those effects require 3D sounds.
/proc/apply_managed_positional_sound_output(sound/S, sound_pan, sound_x = null, sound_z = null, use_3d_output = FALSE)
	if (!S)
		return

	if (use_3d_output)
		S.x = sound_x
		S.z = sound_z
		S.y = 0
	else
		S.x = 0
		S.z = 0
		S.y = 0
		S.pan = sound_pan

/// Returns the BYOND space environment settings for a managed positional listener update.
/// Space echo is intentionally preserved even though BYOND echo/reverb interferes with explicit sound.pan.
/proc/get_managed_positional_sound_effects(atom/source, mob/M, spaced_env, flags)
	RETURN_TYPE(/list)
	var/environment = null
	var/echo = null

	if (spaced_env && !(flags & SOUND_IGNORE_SPACE) && (isturf(source) || ismob(source) || !(M in source)))
		environment = SPACED_ENV
		echo = SPACED_ECHO

	return list(
		"environment" = environment,
		"echo" = echo,
	)

/// Applies space environment settings, or clears a previously-applied space environment.
/proc/apply_managed_positional_sound_effects(sound/S, environment, echo)
	if (!S)
		return

	S.environment = isnull(environment) ? -1 : environment
	if (!isnull(echo))
		S.echo = echo

/// Explicitly clears BYOND environment/echo state from a managed positional sound channel.
/proc/clear_managed_positional_sound_effects(sound/S)
	if (!S)
		return

	S.environment = -1
	S.echo = ECHO_CLOSE
	S.x = 0
	S.y = 0
	S.z = 0

/// One physical emitter for a managed positional sound token.
/datum/managed_positional_sound_emitter
	/// Sound token that owns this emitter.
	var/datum/managed_positional_sound/managed_sound
	/// Atom this emitter follows.
	var/atom/source

/datum/managed_positional_sound_emitter/New(datum/managed_positional_sound/managed_sound, atom/source)
	. = ..()
	src.managed_sound = managed_sound
	src.source = source
	src.register_source_signals(src.source)

/datum/managed_positional_sound_emitter/disposing()
	src.unregister_source_signals(src.source)
	global.managed_positional_sound_process?.unregister_emitter(src)
	src.managed_sound = null
	src.source = null
	. = ..()

/// Moves this emitter to a new source atom.
/datum/managed_positional_sound_emitter/proc/set_source(atom/source)
	src.unregister_source_signals(src.source)
	src.source = source
	src.register_source_signals(src.source)
	global.managed_positional_sound_process?.update_emitter_source(src)

/// Registers source deletion and movement signals that should force managed sound updates.
/datum/managed_positional_sound_emitter/proc/register_source_signals(atom/source)
	PRIVATE_PROC(TRUE)
	if (!source)
		return

	src.RegisterSignal(source, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(source_disposing))
	if (ismovable(source))
		src.RegisterSignal(source, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(source_moved))

/// Unregisters all source signals owned by this emitter.
/datum/managed_positional_sound_emitter/proc/unregister_source_signals(atom/source)
	PRIVATE_PROC(TRUE)
	if (!source)
		return

	src.UnregisterSignal(source, COMSIG_PARENT_PRE_DISPOSING)
	if (ismovable(source))
		src.UnregisterSignal(source, XSIG_MOVABLE_TURF_CHANGED)

/// Source deletion callback.
/datum/managed_positional_sound_emitter/proc/source_disposing()
	PRIVATE_PROC(TRUE)
	src.managed_sound?.remove_emitter(src)

/// Source movement callback.
/datum/managed_positional_sound_emitter/proc/source_moved()
	PRIVATE_PROC(TRUE)
	src.managed_sound?.emitter_moved(src)

/// Runtime controller for a positional sound token that needs listener/emitter updates after playback starts.
/datum/managed_positional_sound
	/// Physical emitters sharing this sound token's channel and timeline.
	var/list/datum/managed_positional_sound_emitter/emitters = list()
	/// Generated source sound used as the file and property template for all client sends.
	var/sound/sound_template
	/// Base stored volume before listener preferences are applied.
	var/volume = 100
	/// Extra distance beyond MAX_SOUND_RANGE.
	var/extrarange = 0
	/// Base pitch/frequency multiplier.
	var/pitch = 1
	/// Client sound ignore flag checked before sending.
	var/ignore_flag = 0
	/// volume channel used for client-side volume preferences.
	var/volume_channel = VOLUME_CHANNEL_GAME
	/// playsound()-style behavior flags, such as SOUND_IGNORE_DEAF or SOUND_DO_LOS.
	var/flags = 0
	/// Whether the sound should loop on the client. One-shot sounds are the default.
	var/repeat = FALSE
	/// Whether playback is currently paused on listener clients.
	var/paused = FALSE
	/// Maximum periodic update delay. Movement signals can still force earlier updates.
	var/update_interval = MANAGED_POSITIONAL_SOUND_DEFAULT_UPDATE_INTERVAL
	/// Minimum stored-volume change needed before an update packet is worth sending.
	var/update_volume_threshold = 1
	/// Maximum stored-volume change per second when smoothing existing listeners.
	var/volume_slew_per_second = 30
	/// Reserved BYOND channel used by this managed sound.
	var/sound_channel = null
	/// Whether this datum is still registered and sending updates.
	var/active = FALSE
	/// world.time when playback conceptually began, used to synchronize late listeners.
	var/start_time = 0
	/// world.time when the current pause began, used to preserve synchronized offsets while paused.
	var/pause_started_time = 0
	/// Earliest world.time this sound should receive its next periodic update.
	var/next_update_time = 0
	/// Cached BYOND sound length. Zero means BYOND did not report one.
	var/sound_duration = 0

	/// Clients that have received this managed sound and need updates or muting.
	var/list/listeners = list()
	/// Last stored, pre-client-preference volume sent for each listener.
	var/list/client_stored_volumes = list()
	/// Last explicit sound.pan value sent for each listener.
	var/list/client_sound_pan = list()
	/// Last x positional offset sent while BYOND 3D output was active for a listener.
	var/list/client_sound_x = list()
	/// Last z positional offset sent while BYOND 3D output was active for a listener.
	var/list/client_sound_z = list()
	/// Last BYOND environment sent for each listener.
	var/list/client_environment = list()
	/// Last echo settings sent for each listener.
	var/list/client_echo = list()

/datum/managed_positional_sound/New(atom/source, soundin, vol, vary = FALSE, extrarange = 0, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0, update_interval = MANAGED_POSITIONAL_SOUND_DEFAULT_UPDATE_INTERVAL, repeat = FALSE)
	. = ..()

	src.sound_template = generate_sound(source, soundin, vol, vary, extrarange, pitch)
	if (!src.sound_template)
		logTheThing(LOG_DEBUG, null, "<b>Sounds:</b> Unable to create managed positional sound: [soundin]")
		return

	src.sound_channel = acquire_managed_positional_sound_channel(src)
	if (!src.sound_channel)
		logTheThing(LOG_DEBUG, null, "<b>Sounds:</b> Unable to reserve a managed positional sound channel for [soundin]")
		return

	src.volume = vol
	src.extrarange = extrarange
	src.pitch = pitch
	src.ignore_flag = ignore_flag
	src.volume_channel = channel
	src.flags = flags
	src.repeat = repeat
	src.update_interval = max(update_interval, MANAGED_POSITIONAL_SOUND_MIN_UPDATE_INTERVAL)
	src.start_time = world.time
	src.next_update_time = world.time + src.update_interval
	src.sound_duration = src.sound_template.len
	src.active = TRUE

	src.sound_template.channel = src.sound_channel
	src.sound_template.repeat = src.repeat
	src.sound_template.wait = FALSE

	src.add_emitter(source, FALSE)

	register_managed_positional_sound(src)

/// Stops playback for all listeners and releases signal registrations and the reserved sound channel.
/datum/managed_positional_sound/disposing()
	src.active = FALSE

	for (var/datum/managed_positional_sound_emitter/emitter as anything in src.emitters?.Copy())
		qdel(emitter)

	for (var/client/C as anything in src.listeners.Copy())
		src.stop_client(C)

	unregister_managed_positional_sound(src)
	release_managed_positional_sound_channel(src)

	src.emitters = null
	src.sound_template = null
	src.listeners = null
	src.client_stored_volumes = null
	src.client_sound_pan = null
	src.client_sound_x = null
	src.client_sound_z = null
	src.client_environment = null
	src.client_echo = null

	. = ..()

/// Public stop helper for owners that hold the managed sound datum.
/datum/managed_positional_sound/proc/stop()
	qdel(src)

/// Sets the base volume and schedules an immediate managed update.
/datum/managed_positional_sound/proc/set_volume(vol)
	src.volume = vol
	src.mark_dirty()

/// Sets the pitch/frequency multiplier for future starts and current listeners.
/datum/managed_positional_sound/proc/set_pitch(pitch)
	if (!pitch)
		pitch = 1
	src.pitch = pitch
	if (src.sound_template)
		src.sound_template.frequency = src.pitch
	src.send_control_update_to_listeners()
	src.mark_dirty()

/// Toggles client-side repeat behavior for current and future listeners.
/datum/managed_positional_sound/proc/set_repeat(repeat)
	repeat = repeat ? TRUE : FALSE
	if (src.repeat == repeat)
		return FALSE

	if (!src.sound_duration)
		src.refresh_sound_duration_from_listeners()
	var/restart_listeners = repeat && (!src.sound_duration || src.is_finished())
	if (!repeat && src.repeat && src.sound_duration)
		var/current_offset = src.get_sound_offset()
		if (!isnull(current_offset))
			var/reference_time = src.paused ? src.pause_started_time : world.time
			src.start_time = reference_time - (current_offset * (1 SECOND))

	src.repeat = repeat
	if (src.sound_template)
		src.sound_template.repeat = src.repeat
	if (restart_listeners)
		src.start_time = world.time
		if (src.paused)
			src.pause_started_time = world.time
		src.restart_listener_channels()
	else
		src.send_control_update_to_listeners()
	src.mark_dirty()
	return TRUE

/// Pauses or resumes current listener channels while preserving this token's synchronized timeline.
/datum/managed_positional_sound/proc/set_paused(paused)
	paused = paused ? TRUE : FALSE
	if (src.paused == paused)
		return FALSE

	src.paused = paused
	if (src.paused)
		src.pause_started_time = world.time
	else
		src.start_time += world.time - src.pause_started_time
		src.pause_started_time = 0

	src.send_control_update_to_listeners()
	src.mark_dirty()
	return TRUE

/// Adds a physical emitter to this managed sound.
/datum/managed_positional_sound/proc/add_emitter(atom/source, register = TRUE)
	RETURN_TYPE(/datum/managed_positional_sound_emitter)
	if (!source)
		return null

	for (var/datum/managed_positional_sound_emitter/existing_emitter as anything in src.emitters)
		if (existing_emitter.source == source)
			return existing_emitter

	var/datum/managed_positional_sound_emitter/emitter = new(src, source)
	src.emitters ||= list()
	src.emitters[emitter] = TRUE

	if (register)
		global.managed_positional_sound_process?.register_emitter(emitter)
		src.mark_dirty()

	return emitter

/// Removes an emitter from this managed sound.
/datum/managed_positional_sound/proc/remove_emitter(datum/managed_positional_sound_emitter/emitter)
	if (!emitter || !(emitter in src.emitters))
		return

	src.emitters -= emitter

	global.managed_positional_sound_process?.unregister_emitter(emitter)
	qdel(emitter)

	if (!length(src.emitters))
		qdel(src)
	else
		src.mark_dirty()

/// Removes every emitter from this managed sound without stopping the token.
/datum/managed_positional_sound/proc/clear_emitters()
	for (var/datum/managed_positional_sound_emitter/emitter as anything in src.emitters?.Copy())
		src.emitters -= emitter
		global.managed_positional_sound_process?.unregister_emitter(emitter)
		qdel(emitter)

/// Source movement callback from an owned emitter.
/datum/managed_positional_sound/proc/emitter_moved(datum/managed_positional_sound_emitter/emitter)
	global.managed_positional_sound_process?.update_emitter_source(emitter)

/// Sets the periodic update interval while preserving the global minimum cadence.
/datum/managed_positional_sound/proc/set_update_interval(update_interval)
	src.update_interval = max(update_interval, MANAGED_POSITIONAL_SOUND_MIN_UPDATE_INTERVAL)
	src.next_update_time = min(src.next_update_time, world.time + src.update_interval)
	src.mark_dirty()

/// Returns TRUE once a non-repeating sound with a known length has elapsed.
/datum/managed_positional_sound/proc/is_finished()
	if (!src.repeat && !src.sound_duration)
		src.refresh_sound_duration_from_listeners()
	return !src.repeat && src.sound_duration && (src.get_elapsed_seconds() >= src.sound_duration)

/// Returns elapsed wall-clock playback time in seconds, matching BYOND sound len/offset units.
/datum/managed_positional_sound/proc/get_elapsed_seconds()
	var/reference_time = src.paused ? src.pause_started_time : world.time
	if (!reference_time)
		reference_time = world.time
	return max((reference_time - src.start_time) / (1 SECOND), 0)

/// Returns the expected BYOND sound offset for the current world time, or null if the sound length is unknown.
/datum/managed_positional_sound/proc/get_sound_offset()
	if (!src.sound_duration)
		return null

	var/elapsed_seconds = src.get_elapsed_seconds()
	if (src.repeat)
		return elapsed_seconds % src.sound_duration
	return min(elapsed_seconds, src.sound_duration)

/// Returns the broad spatial query range needed to find potential listeners for this sound.
/datum/managed_positional_sound/proc/get_query_range()
	return get_managed_positional_sound_query_range(src.volume, MAX_SOUND_RANGE + src.extrarange)

/// Returns an emitter turf on a z-level, used for silent repeat priming.
/datum/managed_positional_sound/proc/get_emitter_turf_on_z(z)
	RETURN_TYPE(/turf)
	for (var/datum/managed_positional_sound_emitter/emitter as anything in src.emitters)
		var/turf/source_turf = get_turf(emitter.source)
		if (source_turf?.z == z)
			return source_turf

	return null

/// Schedules this sound to update on the next process tick, bypassing its normal periodic interval.
/datum/managed_positional_sound/proc/mark_dirty()
	PRIVATE_PROC(TRUE)
	if (!src.active)
		return

	src.next_update_time = min(src.next_update_time, world.time)
	global.managed_positional_sound_process?.mark_sound_dirty(src)

/// Recomputes nearby clients around all emitters, updates audible clients, and mutes listeners that left range.
/datum/managed_positional_sound/proc/update_nearby_clients(force = FALSE)
	if (!src.active || !src.sound_template)
		return

	if (!length(src.emitters))
		src.mute_all(force)
		return
	if (!global.client_hashmap)
		src.mute_all(force)
		return

	var/list/current_clients = list()
	var/list/emitters_by_client = list()
	for (var/datum/managed_positional_sound_emitter/emitter as anything in src.emitters)
		var/turf/source_turf = get_turf(emitter.source)
		if (!source_turf)
			continue

		for (var/client/C as anything in global.client_hashmap.exact_supremum(source_turf, src.get_query_range()))
			emitters_by_client[C] ||= list()
			emitters_by_client[C] += emitter

	for (var/client/C as anything in emitters_by_client)
		var/list/candidate = src.get_blended_candidate_for_client(C, C?.mob, emitters_by_client[C])
		if (!candidate)
			continue

		src.update_client_from_candidate(C, C?.mob, candidate, force)
		current_clients[C] = TRUE

	for (var/client/C as anything in src.listeners.Copy())
		if (!C?.mob)
			src.stop_client(C)
			continue

		if (current_clients[C])
			continue

		src.mute_client(C, force)

/// Helper for callers that need a full emitter-centred update.
/datum/managed_positional_sound/proc/update_all(force = FALSE)
	src.update_nearby_clients(force)

/// Updates every client already tracked by this sound.
/datum/managed_positional_sound/proc/update_current_listeners(force = FALSE)
	for (var/client/C as anything in src.listeners.Copy())
		if (!C?.mob)
			src.stop_client(C)
			continue

		src.update_for_client(C, C.mob, force)

/// Updates this managed sound for one listener candidate, blending all nearby effective emitters.
/datum/managed_positional_sound/proc/update_for_client(client/C, mob/M, force = FALSE)
	if (global.managed_positional_sound_process)
		return global.managed_positional_sound_process.process_sound_for_client(src, C, M, force)

	var/list/candidate = src.get_blended_candidate_for_client(C, M, src.emitters)
	if (!candidate)
		if (C in src.listeners)
			src.mute_client(C, force)
		return FALSE

	src.update_client_from_candidate(C, M, candidate, force)
	return TRUE

/// Returns one listener candidate using loudest-emitter volume and blended multi-emitter pan.
/datum/managed_positional_sound/proc/get_blended_candidate_for_client(client/C, mob/M, list/emitters)
	RETURN_TYPE(/list)
	if (!length(emitters))
		return null

	var/list/candidates = list()
	var/list/loudest_candidate = null
	var/loudest_volume = 0
	for (var/datum/managed_positional_sound_emitter/emitter as anything in emitters)
		var/list/candidate = src.get_candidate_for_client(C, M, emitter)
		if (!candidate)
			continue

		candidates += list(candidate)
		var/stored_volume = candidate["stored_volume"]
		if (!loudest_candidate || stored_volume > loudest_volume)
			loudest_candidate = candidate
			loudest_volume = stored_volume

	if (!loudest_candidate)
		return null

	if (length(candidates) == 1)
		return loudest_candidate

	// Grouped emitters are one logical sound, not multiple sounds stacking together. Volume therefore follows the loudest
	// contributing emitter, while final pan is blended as a soft field from every audible emitter.
	var/weighted_pan = 0
	var/total_pan_weight = 0

	for (var/list/candidate as anything in candidates)
		var/stored_volume = candidate["stored_volume"]
		var/edge_fade = get_managed_positional_sound_blend_edge_fade(candidate["dist"], candidate["max_range"])
		// Blend bounded per-emitter pan values, not raw tile offsets. If we blend raw offsets first, far-apart
		// emitters can saturate to opposite pan extremes and jump when the loudest emitter changes.
		var/pan_weight = get_managed_positional_sound_pan_blend_weight(stored_volume, edge_fade)
		if (pan_weight > 0)
			weighted_pan += get_managed_positional_sound_output_pan(candidate["sound_x"] * MANAGED_POSITIONAL_SOUND_MULTI_EMITTER_PAN_SCALE) * pan_weight
			total_pan_weight += pan_weight

	var/sound_pan = get_managed_positional_sound_output_pan(loudest_candidate["sound_x"] * MANAGED_POSITIONAL_SOUND_MULTI_EMITTER_PAN_SCALE)
	if (total_pan_weight > 0)
		sound_pan = weighted_pan / total_pan_weight

	return list(
		"emitter" = loudest_candidate["emitter"],
		"source" = loudest_candidate["source"],
		"stored_volume" = loudest_volume,
		"Mloc" = loudest_candidate["Mloc"],
		"source_turf" = loudest_candidate["source_turf"],
		"spaced_env" = loudest_candidate["spaced_env"],
		"sound_x" = loudest_candidate["sound_x"],
		"sound_pan" = sound_pan,
	)

/// Returns one debug-only sound field contribution at a turf, ignoring client preferences and mob hearing checks.
/datum/managed_positional_sound/proc/get_debug_blended_field_for_turf(turf/listener_turf, list/emitters)
	RETURN_TYPE(/list)
	if (!listener_turf || !length(emitters))
		return null

	var/list/candidates = list()
	var/list/loudest_candidate = null
	var/loudest_volume = 0
	for (var/datum/managed_positional_sound_emitter/emitter as anything in emitters)
		var/list/candidate = src.get_debug_candidate_for_turf(listener_turf, emitter)
		if (!candidate)
			continue

		candidates += list(candidate)
		var/stored_volume = candidate["stored_volume"]
		if (!loudest_candidate || stored_volume > loudest_volume)
			loudest_candidate = candidate
			loudest_volume = stored_volume

	if (!loudest_candidate)
		return null

	if (length(candidates) == 1)
		return list(
			"emitter" = loudest_candidate["emitter"],
			"source" = loudest_candidate["source"],
			"stored_volume" = loudest_volume,
			"volume_cap" = max(src.volume, loudest_volume),
			"emitter_count" = 1,
			"source_turf" = loudest_candidate["source_turf"],
			"sound_pan" = get_managed_positional_sound_output_pan(loudest_candidate["sound_x"]),
		)

	var/volume_cap = max(src.volume, loudest_volume)
	var/weighted_pan = 0
	var/total_pan_weight = 0

	for (var/list/candidate as anything in candidates)
		var/stored_volume = candidate["stored_volume"]
		var/edge_fade = get_managed_positional_sound_blend_edge_fade(candidate["dist"], candidate["max_range"])

		var/pan_weight = get_managed_positional_sound_pan_blend_weight(stored_volume, edge_fade)
		if (pan_weight > 0)
			weighted_pan += get_managed_positional_sound_output_pan(candidate["sound_x"] * MANAGED_POSITIONAL_SOUND_MULTI_EMITTER_PAN_SCALE) * pan_weight
			total_pan_weight += pan_weight

	var/sound_pan = get_managed_positional_sound_output_pan(loudest_candidate["sound_x"] * MANAGED_POSITIONAL_SOUND_MULTI_EMITTER_PAN_SCALE)
	if (total_pan_weight > 0)
		sound_pan = weighted_pan / total_pan_weight

	return list(
		"emitter" = loudest_candidate["emitter"],
		"source" = loudest_candidate["source"],
		"stored_volume" = loudest_volume,
		"volume_cap" = volume_cap,
		"emitter_count" = length(candidates),
		"source_turf" = loudest_candidate["source_turf"],
		"sound_pan" = sound_pan,
	)

/// Returns the loudest effective emitter candidate for a listener.
/datum/managed_positional_sound/proc/get_best_candidate_for_client(client/C, mob/M)
	RETURN_TYPE(/list)
	var/list/best_candidate = null
	for (var/datum/managed_positional_sound_emitter/emitter as anything in src.emitters)
		var/list/candidate = src.get_candidate_for_client(C, M, emitter)
		if (!candidate)
			continue
		if (!best_candidate || candidate["stored_volume"] > best_candidate["stored_volume"])
			best_candidate = candidate

	return best_candidate

/// Returns this emitter's effective listener candidate data, or null if inaudible.
/datum/managed_positional_sound/proc/get_candidate_for_client(client/C, mob/M, datum/managed_positional_sound_emitter/emitter)
	RETURN_TYPE(/list)
	if (!src.active || !src.sound_template || !C || !M)
		return null

	var/atom/source = emitter?.source
	var/turf/source_turf = get_turf(source)
	var/turf/Mloc = get_turf(M)
	if (!source_turf || !Mloc)
		return null

	var/vol = src.volume
	if (vol < TOO_QUIET)
		return null

	var/ignore_flag = src.ignore_flag
	if (CLIENT_IGNORES_SOUND(C))
		return null

	if (!(src.flags & SOUND_IGNORE_DEAF) && !M.hearing_check(FALSE, TRUE))
		return null

	var/extrarange = src.extrarange
	var/spaced_source = FALSE
	var/atten_temp = attenuate_for_location(source_turf)
	SOURCE_ATTEN(atten_temp)
	if (vol < TOO_QUIET)
		return null

	var/max_range = MAX_SOUND_RANGE + extrarange
	if (max_range <= 0)
		return null

	var/dist = max(GET_MANHATTAN_DIST(Mloc, source_turf), 1)
	if (dist > max_range)
		return null

	var/area/source_location = get_area(source)
	var/source_location_sound_group = null
	if (source_location)
		source_location_sound_group = source_location.sound_group

	var/area/listener_location = Mloc.loc
	if (listener_location)
		if (source_location_sound_group && source_location_sound_group != listener_location.sound_group)
			return null

	var/ourvolume = vol * get_managed_positional_sound_falloff_multiplier(dist, max_range)

	var/spaced_env = FALSE
	atten_temp = attenuate_for_location(Mloc)
	LISTENER_ATTEN(atten_temp)
	if (ourvolume < TOO_QUIET)
		return null

	if (src.flags & SOUND_DO_LOS)
		if (!(M in hearers(MAX_SOUND_RANGE, source)))
			return null

	return list(
		"emitter" = emitter,
		"source" = source,
		"stored_volume" = ourvolume,
		"Mloc" = Mloc,
		"source_turf" = source_turf,
		"spaced_env" = spaced_env,
		"dist" = dist,
		"max_range" = max_range,
		"sound_x" = source_turf.x - Mloc.x,
	)

/// Returns this emitter's debug field contribution at a turf, or null if it does not contribute there.
/datum/managed_positional_sound/proc/get_debug_candidate_for_turf(turf/listener_turf, datum/managed_positional_sound_emitter/emitter)
	RETURN_TYPE(/list)
	if (!src.active || !src.sound_template || !listener_turf)
		return null

	var/atom/source = emitter?.source
	var/turf/source_turf = get_turf(source)
	if (!source_turf)
		return null

	var/vol = src.volume
	if (vol < TOO_QUIET)
		return null

	var/extrarange = src.extrarange
	var/spaced_source = FALSE
	var/atten_temp = attenuate_for_location(source_turf)
	SOURCE_ATTEN(atten_temp)
	if (vol < TOO_QUIET)
		return null

	var/max_range = MAX_SOUND_RANGE + extrarange
	if (max_range <= 0)
		return null

	var/dist = max(GET_MANHATTAN_DIST(listener_turf, source_turf), 1)
	if (dist > max_range)
		return null

	var/area/source_location = get_area(source)
	var/source_location_sound_group = null
	if (source_location)
		source_location_sound_group = source_location.sound_group

	var/area/listener_location = listener_turf.loc
	if (listener_location)
		if (source_location_sound_group && source_location_sound_group != listener_location.sound_group)
			return null

	var/ourvolume = vol * get_managed_positional_sound_falloff_multiplier(dist, max_range)

	var/spaced_env = FALSE
	atten_temp = attenuate_for_location(listener_turf)
	LISTENER_ATTEN(atten_temp)
	if (ourvolume < TOO_QUIET)
		return null

	return list(
		"emitter" = emitter,
		"source" = source,
		"stored_volume" = ourvolume,
		"source_turf" = source_turf,
		"spaced_env" = spaced_env,
		"dist" = dist,
		"max_range" = max_range,
		"sound_x" = source_turf.x - listener_turf.x,
	)

/// Applies a precomputed listener candidate.
/datum/managed_positional_sound/proc/update_client_from_candidate(client/C, mob/M, list/candidate, force = FALSE)
	if (!candidate)
		return

	src.update_client(C, M, candidate["Mloc"], candidate["source_turf"], candidate["source"], candidate["stored_volume"], candidate["spaced_env"], force, candidate["sound_x"], candidate["sound_pan"])

/// Sends the initial file-bearing packet for a silent listener prime.
/datum/managed_positional_sound/proc/prime_client(client/C, mob/M, turf/Mloc, turf/source_turf)
	if (!src.repeat || !C || !M || !Mloc || !source_turf)
		return

	var/sound/S = src.create_start_sound()
	S.volume = 0
	var/raw_sound_x = source_turf.x - Mloc.x
	var/sound_pan = get_managed_positional_sound_output_pan(raw_sound_x)
	apply_managed_positional_sound_output(S, sound_pan)

	var/sound_offset = src.get_sound_offset()
	if (!isnull(sound_offset))
		S.offset = sound_offset

	C << S
	src.refresh_sound_duration(S)

	src.add_listener(C, M)
	src.client_stored_volumes[C] = 0
	src.client_sound_pan[C] = sound_pan
	src.client_environment[C] = null
	src.client_echo[C] = null
	C.sound_playing[src.sound_channel][1] = 0
	C.sound_playing[src.sound_channel][2] = src.volume_channel

/// Updates or starts this managed sound for one listener.
/datum/managed_positional_sound/proc/update_client(client/C, mob/M, turf/Mloc, turf/source_turf, atom/source_atom, stored_volume, spaced_env, force = FALSE, sound_x = null, sound_pan = null)
	if (!C || !Mloc || !source_turf)
		return

	var/already_playing = (C in src.listeners)
	var/target_stored_volume = stored_volume
	if (already_playing)
		stored_volume = src.smooth_stored_volume(src.client_stored_volumes[C], target_stored_volume)

	var/final_volume = stored_volume * C.getVolume(src.volume_channel) / 100
	if (target_stored_volume * C.getVolume(src.volume_channel) / 100 < TOO_QUIET && !already_playing)
		return

	if (isnull(sound_x))
		sound_x = source_turf.x - Mloc.x
	var/sound_z = source_turf.y - Mloc.y
	if (isnull(sound_pan))
		sound_pan = get_managed_positional_sound_output_pan(sound_x)
	var/list/sound_effects = get_managed_positional_sound_effects(source_atom, M, spaced_env, src.flags)
	var/environment = sound_effects["environment"]
	var/echo = sound_effects["echo"]
	var/use_3d_output = !isnull(environment) || !isnull(echo)
	var/last_environment = src.client_environment[C]
	var/last_echo = src.client_echo[C]
	var/should_apply_effects = !isnull(environment) || !isnull(echo)
	var/should_clear_effects = !should_apply_effects && (!isnull(last_environment) || !isnull(last_echo))
	if (!force && already_playing)
		if (abs(stored_volume - src.client_stored_volumes[C]) < src.update_volume_threshold \
			&& src.client_sound_pan[C] == sound_pan \
			&& src.client_sound_x[C] == (use_3d_output ? sound_x : null) \
			&& src.client_sound_z[C] == (use_3d_output ? sound_z : null) \
			&& last_environment == environment \
			&& last_echo == echo)
			return

	src.add_listener(C, M)
	src.client_stored_volumes[C] = stored_volume
	src.client_sound_pan[C] = sound_pan
	src.client_sound_x[C] = use_3d_output ? sound_x : null
	src.client_sound_z[C] = use_3d_output ? sound_z : null
	src.client_environment[C] = environment
	src.client_echo[C] = echo

	C.sound_playing[src.sound_channel][1] = stored_volume
	C.sound_playing[src.sound_channel][2] = src.volume_channel

	if (already_playing && should_clear_effects)
		src.send_clear_effects_sound(C, final_volume)

	if (already_playing)
		src.send_update_sound(C, final_volume, sound_pan, sound_x, sound_z, use_3d_output, environment, echo, should_apply_effects)
	else
		var/sound_offset = src.get_sound_offset()
		src.send_start_sound(C, M, final_volume, sound_pan, sound_x, sound_z, use_3d_output, environment, echo, should_apply_effects, sound_offset)

/// Sends a fileless SOUND_UPDATE packet to clear BYOND environment/echo state before returning to explicit pan output.
/datum/managed_positional_sound/proc/send_clear_effects_sound(client/C, volume)
	PRIVATE_PROC(TRUE)
	var/sound/S = sound(null, wait = FALSE, channel = src.sound_channel)
	S.status = src.get_sound_status(TRUE)
	S.repeat = src.repeat
	S.volume = volume
	clear_managed_positional_sound_effects(S)
	C << S

/// Builds the initial file-bearing sound packet for a listener.
/datum/managed_positional_sound/proc/create_start_sound()
	PRIVATE_PROC(TRUE)
	var/sound/S = sound(src.sound_template.file, wait = FALSE, channel = src.sound_channel)
	S.repeat = src.repeat
	S.status = src.get_sound_status()
	S.priority = src.sound_template.priority
	S.frequency = src.sound_template.frequency
	return S

/// Caches a BYOND-reported sound length from a file-bearing packet, if available.
/datum/managed_positional_sound/proc/refresh_sound_duration(sound/S)
	PRIVATE_PROC(TRUE)
	if (S?.len)
		src.sound_duration = S.len

/// Caches sound length from active listener channels when BYOND only reports len through SoundQuery().
/datum/managed_positional_sound/proc/refresh_sound_duration_from_listeners()
	PRIVATE_PROC(TRUE)
	if (src.sound_duration)
		return

	for (var/client/C as anything in src.listeners)
		for (var/sound/S as anything in C.SoundQuery())
			if (S.channel == src.sound_channel && S.len)
				src.sound_duration = S.len
				return

/// Returns the BYOND sound status flags appropriate for this token's paused state.
/datum/managed_positional_sound/proc/get_sound_status(update = FALSE)
	PRIVATE_PROC(TRUE)
	var/status = update ? SOUND_UPDATE : 0
	if (src.paused)
		status |= SOUND_PAUSED
	return status

/// Sends a fileless SOUND_UPDATE packet for an already-started managed sound channel.
/datum/managed_positional_sound/proc/send_update_sound(client/C, volume, sound_pan, sound_x, sound_z, use_3d_output, environment, echo, apply_effects = FALSE)
	PRIVATE_PROC(TRUE)
	var/sound/S = sound(null, wait = FALSE, channel = src.sound_channel)
	S.status = src.get_sound_status(TRUE)
	S.repeat = src.repeat
	S.volume = volume
	if (src.sound_template)
		S.frequency = src.sound_template.frequency
	if (apply_effects)
		apply_managed_positional_sound_effects(S, environment, echo)
	apply_managed_positional_sound_output(S, sound_pan, sound_x, sound_z, use_3d_output)
	C << S

/// Sends the file-bearing start packet for one listener, followed by a fileless update for properties BYOND can drop on initial play.
/datum/managed_positional_sound/proc/send_start_sound(client/C, mob/M, volume, sound_pan, sound_x, sound_z, use_3d_output, environment, echo, apply_effects = FALSE, sound_offset = null)
	PRIVATE_PROC(TRUE)
	if (!C)
		return

	var/sound/S = src.create_start_sound()
	S.volume = volume
	if (apply_effects)
		apply_managed_positional_sound_effects(S, environment, echo)
	apply_managed_positional_sound_output(S, sound_pan, sound_x, sound_z, use_3d_output)
	if (!isnull(sound_offset))
		S.offset = sound_offset

	var/orig_freq = S.frequency
	if (M)
		S.frequency *= (HAS_ATOM_PROPERTY(M, PROP_MOB_HEARD_PITCH) ? GET_ATOM_PROPERTY(M, PROP_MOB_HEARD_PITCH) : 1)

	C << S
	src.refresh_sound_duration(S)
	src.send_update_sound(C, volume, sound_pan, sound_x, sound_z, use_3d_output, environment, echo, apply_effects)
	S.frequency = orig_freq
	S.offset = 0

/// Resends the file-bearing start packet to every current listener, preserving cached volume and position.
/datum/managed_positional_sound/proc/restart_listener_channels()
	PRIVATE_PROC(TRUE)
	for (var/client/C as anything in src.listeners.Copy())
		src.restart_listener_channel(C)

/// Resends the file-bearing start packet to one current listener when a fileless update cannot revive its channel.
/datum/managed_positional_sound/proc/restart_listener_channel(client/C)
	PRIVATE_PROC(TRUE)
	if (!C || !(C in src.listeners))
		return

	var/list/state = src.get_cached_listener_state(C)
	C.sound_playing[src.sound_channel][1] = state["stored_volume"]
	C.sound_playing[src.sound_channel][2] = src.volume_channel
	src.send_start_sound(C, C.mob, state["final_volume"], state["sound_pan"], state["sound_x"], state["sound_z"], state["use_3d_output"], state["environment"], state["echo"], state["use_3d_output"], src.get_sound_offset())

/// Mutes every current listener, optionally forcing volume directly to zero.
/datum/managed_positional_sound/proc/mute_all(force = FALSE)
	for (var/client/C as anything in src.listeners.Copy())
		src.mute_client(C, force)

/// Smoothly mutes a listener or immediately stops its audible volume when forced.
/datum/managed_positional_sound/proc/mute_client(client/C, force = FALSE)
	if (!C)
		return

	if (!force && src.client_stored_volumes[C] == 0)
		return

	var/stored_volume = force ? 0 : src.smooth_stored_volume(src.client_stored_volumes[C], 0)
	if (stored_volume < TOO_QUIET)
		stored_volume = 0

	var/environment = src.client_environment[C]
	var/echo = src.client_echo[C]
	var/should_apply_effects = !isnull(environment) || !isnull(echo)
	src.client_stored_volumes[C] = stored_volume
	if (!stored_volume)
		src.client_sound_pan[C] = null
		src.client_sound_x[C] = null
		src.client_sound_z[C] = null

	C.sound_playing[src.sound_channel][1] = stored_volume
	C.sound_playing[src.sound_channel][2] = src.volume_channel

	var/sound/S = sound(null, wait = FALSE, channel = src.sound_channel)
	S.status = src.get_sound_status(TRUE)
	S.repeat = src.repeat
	S.volume = stored_volume * C.getVolume(src.volume_channel) / 100
	if (should_apply_effects)
		apply_managed_positional_sound_effects(S, environment, echo)
	C << S

/// Sends pause/resume/pitch/repeat state to every client already tracking this sound.
/datum/managed_positional_sound/proc/send_control_update_to_listeners()
	PRIVATE_PROC(TRUE)
	for (var/client/C as anything in src.listeners.Copy())
		src.send_control_update(C)

/// Sends pause/resume/pitch/repeat state to one current listener without recalculating its position.
/datum/managed_positional_sound/proc/send_control_update(client/C)
	PRIVATE_PROC(TRUE)
	if (!C || !(C in src.listeners))
		return

	var/list/state = src.get_cached_listener_state(C)
	src.send_update_sound(C, state["final_volume"], state["sound_pan"], state["sound_x"], state["sound_z"], state["use_3d_output"], state["environment"], state["echo"], state["use_3d_output"])

/// Returns the last sent listener state as packet-ready values.
/datum/managed_positional_sound/proc/get_cached_listener_state(client/C)
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/list)
	var/sound_pan = src.client_sound_pan[C]
	if (isnull(sound_pan))
		sound_pan = 0
	var/environment = src.client_environment[C]
	var/echo = src.client_echo[C]
	var/use_3d_output = !isnull(environment) || !isnull(echo)
	var/stored_volume = src.client_stored_volumes[C]
	if (isnull(stored_volume))
		stored_volume = 0

	return list(
		"stored_volume" = stored_volume,
		"final_volume" = stored_volume * C.getVolume(src.volume_channel) / 100,
		"sound_pan" = sound_pan,
		"sound_x" = src.client_sound_x[C],
		"sound_z" = src.client_sound_z[C],
		"environment" = environment,
		"echo" = echo,
		"use_3d_output" = use_3d_output,
	)

/// Tracks a client as an active listener and attaches movement/logout signals to its current mob.
/datum/managed_positional_sound/proc/add_listener(client/C, mob/M)
	PRIVATE_PROC(TRUE)
	if (!C || !M)
		return

	src.listeners[C] = TRUE
	global.managed_positional_sound_process?.register_client_sound(C, src)

/// Steps stored volume toward the target to avoid abrupt managed update changes.
/datum/managed_positional_sound/proc/smooth_stored_volume(current_volume, target_volume)
	PRIVATE_PROC(TRUE)
	if (isnull(current_volume))
		return target_volume

	var/max_delta = max(src.volume_slew_per_second * (src.update_interval / 1 SECOND), src.update_volume_threshold)
	return current_volume + clamp(target_volume - current_volume, -max_delta, max_delta)

/// Fully stops this sound for a client and clears all per-listener tracking state.
/datum/managed_positional_sound/proc/stop_client(client/C)
	if (!C)
		return

	C.sound_playing[src.sound_channel][1] = 0
	C.sound_playing[src.sound_channel][2] = src.volume_channel

	var/sound/stopsound = sound(null, wait = 0, channel = src.sound_channel)
	C << stopsound

	src.listeners -= C
	global.managed_positional_sound_process?.unregister_client_sound(C, src)
	src.client_stored_volumes -= C
	src.client_sound_pan -= C
	src.client_sound_x -= C
	src.client_sound_z -= C
	src.client_environment -= C
	src.client_echo -= C
