/// Active process controller for managed positional sounds.
var/global/datum/controller/process/managed_positional_sounds/managed_positional_sound_process = null
/// Managed positional sounds created before the process scheduler is ready.
var/global/list/pending_managed_positional_sounds = list()

/// Concrete spatial hashmap subtype. Used to index managed positional sound emitters by their source atoms.
/datum/spatial_hashmap/managed_positional_sound_emitters

/// Process scheduler that owns listener-driven managed positional sound discovery.
/datum/controller/process/managed_positional_sounds
	/// All currently active managed positional sounds.
	var/tmp/list/datum/managed_positional_sound/sounds
	/// Sounds that should update existing and nearby listeners on the next tick.
	var/tmp/list/datum/managed_positional_sound/dirty_sounds
	/// Clients whose nearby managed sounds should be recalculated on the next tick.
	var/tmp/list/dirty_clients
	/// Dirty clients that also need same-z repeating sounds silently primed.
	var/tmp/list/dirty_clients_need_prime
	/// Managed sound emitters indexed by their source atom.
	var/tmp/datum/spatial_hashmap/emitter_hashmap
	/// Current managed sounds tracked for each client.
	var/tmp/list/client_sounds
	/// Clients whose login/logout/delete signals are registered with this controller.
	var/tmp/list/tracked_clients
	/// Mob movement signal owner for each tracked client.
	var/tmp/list/client_listener_mobs
	/// Largest query range currently needed by any registered managed sound.
	var/tmp/max_query_range = 0

	/// Initializes the process, emitter hashmap, client tracking, and pending sounds.
	setup()
		name = "Managed Positional Sounds"
		schedule_interval = MANAGED_POSITIONAL_SOUND_PROCESS_INTERVAL
		src.sounds = list()
		src.dirty_sounds = list()
		src.dirty_clients = list()
		src.dirty_clients_need_prime = list()
		src.emitter_hashmap = new /datum/spatial_hashmap/managed_positional_sound_emitters(cell_size = MAX_SOUND_RANGE_NORMAL, name = "Managed Positional Sound Emitters")
		src.client_sounds = list()
		src.tracked_clients = list()
		src.client_listener_mobs = list()
		src.max_query_range = MAX_SOUND_RANGE
		global.managed_positional_sound_process = src

		src.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CLIENT_NEW, PROC_REF(client_new))
		for (var/client/C as anything in global.clients)
			src.track_client(C, TRUE)

		for (var/datum/managed_positional_sound/managed_sound as anything in global.pending_managed_positional_sounds)
			if (managed_sound?.active)
				src.register_sound(managed_sound)
		global.pending_managed_positional_sounds.Cut()

	/// Keeps managed sound and listener state across process controller replacement.
	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/managed_positional_sounds/old_process = target
		src.sounds = old_process.sounds
		src.dirty_sounds = old_process.dirty_sounds
		src.dirty_clients = old_process.dirty_clients
		src.dirty_clients_need_prime = old_process.dirty_clients_need_prime
		src.emitter_hashmap = old_process.emitter_hashmap
		src.client_sounds = old_process.client_sounds
		src.tracked_clients = list()
		src.client_listener_mobs = list()
		src.max_query_range = old_process.max_query_range
		global.managed_positional_sound_process = src

		src.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CLIENT_NEW, PROC_REF(client_new))
		for (var/client/C as anything in global.clients)
			src.track_client(C, TRUE)

	/// Updates dirty sound tokens, then dirty listener clients, then periodic listener fallback work.
	doWork()
		var/c = 0
		for (var/datum/managed_positional_sound/managed_sound as anything in src.dirty_sounds.Copy())
			src.dirty_sounds -= managed_sound
			if (!src.process_sound(managed_sound, TRUE))
				continue

			if (!(++c % 10))
				scheck()

		for (var/client/C as anything in src.dirty_clients.Copy())
			var/needs_prime = src.dirty_clients_need_prime[C]
			src.dirty_clients -= C
			src.dirty_clients_need_prime -= C
			if (!src.process_client(C, needs_prime))
				continue

			if (!(++c % 10))
				scheck()

		for (var/datum/managed_positional_sound/managed_sound as anything in src.sounds)
			if (src.dirty_sounds[managed_sound])
				continue
			if (!src.process_sound(managed_sound, FALSE))
				continue

			if (!(++c % 10))
				scheck()

	/// Updates one sound for emitter-driven changes or periodic fallback.
	proc/process_sound(datum/managed_positional_sound/managed_sound, dirty_update = FALSE)
		if (!managed_sound?.active || !managed_sound.sound_channel)
			src.unregister_sound(managed_sound)
			return FALSE

		if (managed_sound.is_finished())
			qdel(managed_sound)
			return FALSE

		if (!dirty_update && world.time < managed_sound.next_update_time)
			return FALSE

		src.setLastTask("managed positional sound", managed_sound)
		managed_sound.next_update_time = world.time + managed_sound.update_interval

		if (dirty_update)
			managed_sound.update_nearby_clients(TRUE)
			if (managed_sound.repeat)
				src.prime_same_z_clients(managed_sound)
		else
			managed_sound.update_current_listeners(FALSE)

		return TRUE

	/// Recalculates the managed positional sounds relevant to one client.
	proc/process_client(client/C, prime_repeating = FALSE)
		if (!C?.mob)
			src.mute_client_sounds(C)
			return FALSE

		src.track_client(C)

		var/mob/M = C.mob
		var/turf/Mloc = get_turf(M)
		if (!Mloc || !src.emitter_hashmap)
			src.mute_client_sounds(C)
			return FALSE

		var/list/current_sounds = list()
		var/list/emitters_by_sound = list()
		for (var/datum/managed_positional_sound_emitter/emitter as anything in src.emitter_hashmap.exact_supremum(Mloc, src.max_query_range))
			var/datum/managed_positional_sound/managed_sound = emitter.managed_sound
			if (!managed_sound?.active)
				continue

			emitters_by_sound[managed_sound] ||= list()
			emitters_by_sound[managed_sound] += emitter

		for (var/datum/managed_positional_sound/managed_sound as anything in emitters_by_sound)
			var/list/candidate = managed_sound.get_blended_candidate_for_client(C, M, emitters_by_sound[managed_sound])
			if (!candidate)
				continue

			managed_sound.update_client_from_candidate(C, M, candidate, FALSE)
			current_sounds[managed_sound] = TRUE

		if (prime_repeating)
			src.prime_client_repeating_sounds(C, M, Mloc, current_sounds)

		var/list/old_sounds = src.client_sounds[C]
		for (var/datum/managed_positional_sound/managed_sound as anything in old_sounds?.Copy())
			if (current_sounds[managed_sound])
				continue
			managed_sound.mute_client(C)

		return TRUE

	/// Updates one managed sound for one listener using only nearby indexed emitters.
	proc/process_sound_for_client(datum/managed_positional_sound/managed_sound, client/C, mob/M, force = FALSE)
		if (!managed_sound?.active || !C || !M)
			return FALSE

		var/turf/Mloc = get_turf(M)
		if (!Mloc || !src.emitter_hashmap)
			if (C in managed_sound.listeners)
				managed_sound.mute_client(C, force)
			return FALSE

		var/list/nearby_emitters = list()
		for (var/datum/managed_positional_sound_emitter/emitter as anything in src.emitter_hashmap.exact_supremum(Mloc, managed_sound.get_query_range()))
			if (emitter.managed_sound != managed_sound)
				continue

			nearby_emitters += emitter

		var/list/candidate = managed_sound.get_blended_candidate_for_client(C, M, nearby_emitters)
		if (!candidate)
			if (C in managed_sound.listeners)
				managed_sound.mute_client(C, force)
			return FALSE

		managed_sound.update_client_from_candidate(C, M, candidate, force)
		return TRUE

	/// Adds a managed sound to the scheduler and indexes each of its emitters.
	proc/register_sound(datum/managed_positional_sound/managed_sound)
		if (!managed_sound?.active)
			return

		if (!src.sounds)
			src.sounds = list()
		if (!src.dirty_sounds)
			src.dirty_sounds = list()
		if (!src.emitter_hashmap)
			src.emitter_hashmap = new /datum/spatial_hashmap/managed_positional_sound_emitters(cell_size = MAX_SOUND_RANGE_NORMAL, name = "Managed Positional Sound Emitters")

		src.sounds[managed_sound] = TRUE
		for (var/datum/managed_positional_sound_emitter/emitter as anything in managed_sound.emitters)
			src.register_emitter(emitter, FALSE)

		src.max_query_range = max(src.max_query_range, managed_sound.get_query_range())
		managed_sound.next_update_time = min(managed_sound.next_update_time, world.time)
		src.dirty_sounds[managed_sound] = TRUE

	/// Removes a managed sound from scheduler, emitter spatial index, and per-client tracking.
	proc/unregister_sound(datum/managed_positional_sound/managed_sound)
		src.sounds -= managed_sound
		src.dirty_sounds -= managed_sound
		for (var/datum/managed_positional_sound_emitter/emitter as anything in managed_sound?.emitters)
			src.unregister_emitter(emitter)

		for (var/client/C as anything in src.client_sounds.Copy())
			var/list/tracked_sounds = src.client_sounds[C]
			if (isnull(tracked_sounds))
				stack_trace("Managed positional sound process had a null client_sounds entry for [C] while unregistering [managed_sound].")
			tracked_sounds -= managed_sound
			if (!length(tracked_sounds))
				src.client_sounds -= C

		src.rebuild_max_query_range()

	/// Queues a managed sound for emitter-driven updates on the next process tick.
	proc/mark_sound_dirty(datum/managed_positional_sound/managed_sound)
		if (!managed_sound?.active)
			return
		if (!src.dirty_sounds)
			src.dirty_sounds = list()
		if (managed_sound.get_query_range() > src.max_query_range)
			src.max_query_range = managed_sound.get_query_range()
		managed_sound.next_update_time = min(managed_sound.next_update_time, world.time)
		src.dirty_sounds[managed_sound] = TRUE

	/// Adds a managed sound emitter to the spatial index.
	proc/register_emitter(datum/managed_positional_sound_emitter/emitter, mark_dirty = TRUE)
		var/datum/managed_positional_sound/managed_sound = emitter?.managed_sound
		if (!managed_sound?.active || !emitter.source)
			return

		if (!src.emitter_hashmap)
			src.emitter_hashmap = new /datum/spatial_hashmap/managed_positional_sound_emitters(cell_size = MAX_SOUND_RANGE_NORMAL, name = "Managed Positional Sound Emitters")

		src.emitter_hashmap.register_hashmap_entry(emitter, emitter.source)
		src.max_query_range = max(src.max_query_range, managed_sound.get_query_range())
		if (mark_dirty)
			src.mark_sound_dirty(managed_sound)

	/// Removes a managed sound emitter from the spatial index.
	proc/unregister_emitter(datum/managed_positional_sound_emitter/emitter)
		src.emitter_hashmap?.unregister_hashmap_entry(emitter)

	/// Updates the emitter spatial index after an emitter changes source atoms.
	proc/update_emitter_source(datum/managed_positional_sound_emitter/emitter)
		var/datum/managed_positional_sound/managed_sound = emitter?.managed_sound
		if (!managed_sound?.active)
			return

		src.emitter_hashmap?.update_tracked_atom(emitter, emitter.source)
		src.mark_sound_dirty(managed_sound)

	/// Adds a sound to the per-client tracking set.
	proc/register_client_sound(client/C, datum/managed_positional_sound/managed_sound)
		if (!C || !managed_sound)
			return
		src.client_sounds[C] ||= list()
		src.client_sounds[C][managed_sound] = TRUE

	/// Removes a sound from the per-client tracking set.
	proc/unregister_client_sound(client/C, datum/managed_positional_sound/managed_sound)
		if (!C || !managed_sound)
			return
		if (!(C in src.client_sounds))
			return
		var/list/tracked_sounds = src.client_sounds[C]
		if (isnull(tracked_sounds))
			stack_trace("Managed positional sound process had a null client_sounds entry for [C] while unregistering [managed_sound].")
		tracked_sounds -= managed_sound
		if (!length(tracked_sounds))
			src.client_sounds -= C

	/// Queues one client for listener-driven sound recalculation.
	proc/mark_client_dirty(client/C, prime_repeating = FALSE)
		if (!C)
			return
		if (!src.dirty_clients)
			src.dirty_clients = list()
		if (!src.dirty_clients_need_prime)
			src.dirty_clients_need_prime = list()
		src.dirty_clients[C] = TRUE
		if (prime_repeating)
			src.dirty_clients_need_prime[C] = TRUE

	/// Tracks a client and its current mob for movement/login/logout updates.
	proc/track_client(client/C, prime_repeating = FALSE)
		if (!C)
			return

		if (!(C in src.tracked_clients))
			src.RegisterSignal(C, COMSIG_CLIENT_LOGIN, PROC_REF(client_login))
			src.RegisterSignal(C, COMSIG_CLIENT_LOGOUT, PROC_REF(client_logout))
			src.RegisterSignal(C, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(client_disposing))
			src.tracked_clients[C] = TRUE

		var/mob/M = C.mob
		if (src.client_listener_mobs[C] == M)
			if (prime_repeating)
				src.mark_client_dirty(C, TRUE)
			return

		if (src.client_listener_mobs[C])
			src.unregister_client_mob(src.client_listener_mobs[C])

		src.client_listener_mobs[C] = M
		src.register_client_mob(M)
		src.mark_client_dirty(C, TRUE)

	/// Stops tracking a client and all sounds currently assigned to it.
	proc/untrack_client(client/C)
		if (!C)
			return

		src.UnregisterSignal(C, COMSIG_CLIENT_LOGIN)
		src.UnregisterSignal(C, COMSIG_CLIENT_LOGOUT)
		src.UnregisterSignal(C, COMSIG_PARENT_PRE_DISPOSING)
		src.tracked_clients -= C

		if (src.client_listener_mobs[C])
			src.unregister_client_mob(src.client_listener_mobs[C])
		src.client_listener_mobs -= C

		src.mute_client_sounds(C, TRUE)
		src.dirty_clients -= C
		src.dirty_clients_need_prime -= C

	/// Registers movement/delete signals for a tracked client's current mob.
	proc/register_client_mob(mob/M)
		if (!M)
			return
		src.RegisterSignal(M, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(client_moved))
		src.RegisterSignal(M, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(client_mob_disposing))

	/// Unregisters movement/delete signals for a tracked client's old mob.
	proc/unregister_client_mob(mob/M)
		if (!M)
			return
		src.UnregisterSignal(M, XSIG_MOVABLE_TURF_CHANGED)
		src.UnregisterSignal(M, COMSIG_PARENT_PRE_DISPOSING)

	/// Global new-client callback.
	proc/client_new(source, client/C)
		src.track_client(C, TRUE)

	/// Client login callback, fired when the client attaches to a mob.
	proc/client_login(client/C, mob/M)
		src.track_client(C, TRUE)

	/// Client logout callback, fired before the client detaches from a mob.
	proc/client_logout(client/C, mob/M)
		src.mark_client_dirty(C, TRUE)

	/// Client delete callback.
	proc/client_disposing(client/C)
		src.untrack_client(C)

	/// Tracked mob delete callback.
	proc/client_mob_disposing(mob/M)
		for (var/client/C as anything in src.client_listener_mobs.Copy())
			if (src.client_listener_mobs[C] == M)
				var/client/affected_client = C
				src.client_listener_mobs -= C
				src.mark_client_dirty(C, TRUE)
				SPAWN(0)
					if (affected_client && !QDELETED(affected_client))
						src.track_client(affected_client, TRUE)

	/// Tracked mob movement callback.
	proc/client_moved(datum/component/complexsignal/outermost_movable/component, turf/old_turf, turf/new_turf)
		var/mob/M = component?.parent
		var/client/C = M?.client
		if (!C)
			return
		src.mark_client_dirty(C, old_turf?.z != new_turf?.z)

	/// Starts repeating sounds silently for one client when it joins or changes z-level.
	proc/prime_client_repeating_sounds(client/C, mob/M, turf/Mloc, list/current_sounds)
		for (var/datum/managed_positional_sound/managed_sound as anything in src.sounds)
			if (!managed_sound?.repeat || (managed_sound in current_sounds) || (C in managed_sound.listeners))
				continue

			var/turf/source_turf = managed_sound.get_emitter_turf_on_z(Mloc.z)
			if (!source_turf || source_turf.z != Mloc.z)
				continue

			managed_sound.prime_client(C, M, Mloc, source_turf)
			current_sounds[managed_sound] = TRUE

	/// Starts a repeating sound silently for every current client on an emitter z-level.
	proc/prime_same_z_clients(datum/managed_positional_sound/managed_sound)
		if (!managed_sound?.repeat)
			return

		for (var/client/C as anything in global.clients)
			var/mob/M = C?.mob
			var/turf/Mloc = get_turf(M)
			if (!Mloc || (C in managed_sound.listeners))
				continue

			var/turf/source_turf = managed_sound.get_emitter_turf_on_z(Mloc.z)
			if (!source_turf)
				continue

			managed_sound.prime_client(C, M, Mloc, source_turf)

	/// Mutes every managed sound currently tracked for one client.
	proc/mute_client_sounds(client/C, stop = FALSE)
		if (!(C in src.client_sounds))
			return
		var/list/tracked_sounds = src.client_sounds[C]
		if (isnull(tracked_sounds))
			stack_trace("Managed positional sound process had a null client_sounds entry for [C] while muting client sounds.")
		for (var/datum/managed_positional_sound/managed_sound as anything in tracked_sounds?.Copy())
			if (stop)
				managed_sound.stop_client(C)
			else
				managed_sound.mute_client(C)

	/// Rebuilds the largest needed sound query range after unregistering a sound.
	proc/rebuild_max_query_range()
		src.max_query_range = MAX_SOUND_RANGE
		for (var/datum/managed_positional_sound/managed_sound as anything in src.sounds)
			src.max_query_range = max(src.max_query_range, managed_sound.get_query_range())
