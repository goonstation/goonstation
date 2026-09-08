/// Upper bound on the lifetime of a client-visible crew apparition actor
#define CREW_APPARITION_ACTOR_MAX_TTL (5 MINUTES)
/// Maximum duration allotted to a client-visible crew apparition actor's conversation
#define CREW_APPARITION_ACTOR_MAX_CONVERSATION_DURATION (30 SECONDS)
/// Maximum number of lines in a client-visible crew apparition actor's conversation
#define CREW_APPARITION_ACTOR_MAX_CONVERSATION_LINES 8
/// Maximum route length for a client-visible crew apparition actor walker
#define CREW_APPARITION_ACTOR_MAX_WALK_DISTANCE 12
/// Maximum number of route nodes considered for a client-visible crew apparition actor walker
#define CREW_APPARITION_ACTOR_MAX_WALK_SEEN 128

/// Check whether a human can provide an appearance for a client-visible crew apparition actor
/proc/is_crew_apparition_human_eligible(mob/victim, mob/living/carbon/human/human, range = 7)
	if (!victim?.client || !human || QDELETED(human) || human == victim)
		return FALSE
	if (human.stat || human.lying || human.dir == NORTH || human.invisibility)
		return FALSE
	if (isrestrictedz(get_z(human)) || get_z(human) != get_z(victim) || get_dist(human, victim) > range)
		return FALSE
	return TRUE


/// Pick a nearby, awake human whose appearance is safe to copy for a client-visible crew apparition actor
/proc/pick_crew_apparition_human(mob/victim, range = 7)
	if (!victim || !victim.client)
		return

	var/list/mob/living/carbon/human/eligible_humans = list()
	for (var/mob/living/carbon/human/candidate in view(max(range, 0), victim))
		if (!is_crew_apparition_human_eligible(victim, candidate, range))
			continue
		eligible_humans += candidate

	if (!length(eligible_humans))
		return
	return pick(eligible_humans)


/// A client-visible crew apparition actor whose image is visible only to its viewer
/obj/crew_apparition_actor
	icon = null
	icon_state = null
	density = FALSE
	anchored = ANCHORED
	mouse_opacity = 1
	opacity = 0
	pass_unstable = FALSE
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP

	var/mob/viewer
	var/client/viewer_client
	var/image/client_image
	var/datum/client_image_group/image_group
	/// World time when this actor's client image expires
	var/apparition_expiry
	var/lifecycle_generation = 0
	var/lifecycle_active = TRUE
	var/dissolving = FALSE
	var/track_viewer_movement = FALSE

/obj/crew_apparition_actor/New(location, mob/viewer, appearance_source, ttl = 30 SECONDS, appearance_time = 2 SECONDS, datum/client_image_group/image_group = null)
	. = ..(location)
	if (!viewer?.client || !appearance_source)
		qdel(src)
		return
	var/image/appearance_image
	appearance_image = image(appearance_source)
	if (!appearance_image)
		qdel(src)
		return

	src.viewer = viewer
	src.viewer_client = viewer.client
	var/normalized_ttl = ttl < 0 ? CREW_APPARITION_ACTOR_MAX_TTL : clamp(ttl, 1, CREW_APPARITION_ACTOR_MAX_TTL)
	src.apparition_expiry = world.time + normalized_ttl

	RegisterSignal(src.viewer, COMSIG_MOVABLE_MOVED, PROC_REF(viewer_moved))

	src.client_image = image(src)
	src.client_image.appearance = appearance_image.appearance
	src.client_image.loc = src
	src.image_group = image_group
	if (src.image_group)
		src.image_group.add_image(src.client_image)
	else
		src.viewer_client.images += src.client_image
	src.set_dir(appearance_image.dir)
	src.appear(appearance_time)

	var/expiry_generation = src.lifecycle_generation
	SPAWN(src.apparition_expiry - world.time)
		if (!QDELETED(src) && src.lifecycle_generation == expiry_generation)
			src.dissolve()

/obj/crew_apparition_actor/proc/viewer_moved(mob/moved_viewer, atom/previous_loc, movement_dir)
	if (moved_viewer != src.viewer)
		return
	if (src.track_viewer_movement)
		src.face_target(src.viewer)

/// Return the remaining lifetime in deciseconds
/obj/crew_apparition_actor/proc/remaining_ttl()
	return max(src.apparition_expiry - world.time, 0)

/// Check whether this actor can still be shown to its viewer
/obj/crew_apparition_actor/proc/is_active()
	return !QDELETED(src) && src.lifecycle_active && !src.dissolving && src.viewer?.client && src.remaining_ttl() > 0

/// Stop this actor's lifecycle and movement callbacks
/obj/crew_apparition_actor/proc/invalidate()
	if (!src.lifecycle_active)
		return FALSE
	src.lifecycle_active = FALSE
	src.lifecycle_generation++
	src.apparition_expiry = world.time
	if (src.viewer && !QDELETED(src.viewer))
		UnregisterSignal(src.viewer, COMSIG_MOVABLE_MOVED)
	return TRUE

/// Animate this actor into the viewer's image list
/obj/crew_apparition_actor/proc/appear(time = 2 SECONDS)
	if (QDELETED(src) || !src.client_image)
		return FALSE
	if (!isnum(time))
		time = 2 SECONDS
	time = max(time, 0)
	if (!time)
		return TRUE
	var/filter_params = wave_filter(x = -5, size = 2, flags = WAVE_BOUNDED | WAVE_SIDEWAYS)
	src.client_image.filters += filter(arglist(filter_params))
	var/ripple = src.client_image.filters[length(src.client_image.filters)]
	src.client_image.alpha = 0
	animate(ripple, x = 0, time = time, flags = ANIMATION_PARALLEL)
	animate(src.client_image, alpha = 255, time = time)
	return TRUE

/// Animate this actor out of the viewer's image list
/obj/crew_apparition_actor/proc/dissolve(time = 2 SECONDS)
	if (QDELETED(src) || src.dissolving)
		return FALSE
	src.dissolving = TRUE
	src.invalidate()
	if (!src.client_image || !src.viewer_client)
		qdel(src)
		return TRUE
	if (!isnum(time))
		time = 2 SECONDS
	time = max(time, 0)
	if (!time)
		qdel(src)
		return TRUE

	// animate_ripple() and animate_wave() only accept atoms, while this image is
	// client-only. Recreate their filter animation directly on the image instead
	for (var/i in 1 to 4)
		var/ripple_size = rand() * 2.5 + 1
		var/ripple_radius = rand() * 10 + 10
		var/list/ripple_params = ripple_filter(
			x = rand(-6, 6),
			y = rand(-6, 6),
			size = ripple_size,
			repeat = rand() * 2.5 + 1,
			radius = 0
		)
		src.client_image.filters += filter(arglist(ripple_params))
		var/ripple_effect = src.client_image.filters[length(src.client_image.filters)]
		animate(ripple_effect, size = ripple_size, radius = 0, time = 0, flags = ANIMATION_PARALLEL)
		animate(ripple_effect, size = 0, radius = ripple_radius, time = time, easing = SINE_EASING)

	for (var/i in 1 to 3)
		var/wave_angle = rand(0, 359)
		var/wave_radius = rand() * 20 + 10
		var/wave_x = wave_radius * sin(wave_angle)
		var/wave_y = wave_radius * cos(wave_angle)
		var/wave_offset = rand()
		var/list/wave_params = wave_filter(
			x = wave_x,
			y = wave_y,
			size = rand() * 2.5 + 0.5,
			offset = wave_offset,
			flags = WAVE_BOUNDED | WAVE_SIDEWAYS
		)
		src.client_image.filters += filter(arglist(wave_params))
		var/wave_effect = src.client_image.filters[length(src.client_image.filters)]
		animate(wave_effect, offset = wave_offset, time = 0, flags = ANIMATION_PARALLEL)
		animate(wave_effect, offset = wave_offset - 1, time = time, easing = LINEAR_EASING)

	src.client_image.filters += filter(arglist(gauss_blur_filter(size = 0)))
	var/blur_effect = src.client_image.filters[length(src.client_image.filters)]
	animate(blur_effect, size = 0, time = 0, flags = ANIMATION_PARALLEL)
	animate(blur_effect, size = 2.5, time = time, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	// Hold the apparition's silhouette long enough for the distortion to read,
	// then let it collapse into the final fade
	var/fade_hold_time = time * 0.35
	var/fade_out_time = time - fade_hold_time
	animate(src.client_image, alpha = 128, time = fade_hold_time, easing = SINE_EASING)
	animate(src.client_image, alpha = 0, time = fade_out_time, easing = SINE_EASING)

	var/current_generation = src.lifecycle_generation
	SPAWN(time)
		if (!QDELETED(src) && src.lifecycle_generation == current_generation)
			if (src.client_image)
				src.client_image.filters = null
			qdel(src)
	return TRUE

/obj/crew_apparition_actor/set_dir(new_dir)
	. = ..()
	if (src.client_image)
		src.client_image.dir = src.dir

/obj/crew_apparition_actor/attack_hand(mob/user)
	return

/obj/crew_apparition_actor/attackby(obj/item/item, mob/user, params, is_special = 0, silent = FALSE)
	return

/obj/crew_apparition_actor/pull(mob/user)
	return TRUE

/obj/crew_apparition_actor/disposing()
	src.invalidate()
	if (src.image_group && !QDELETED(src.image_group) && src.client_image)
		src.image_group.remove_image(src.client_image)
	else if (src.viewer_client && src.client_image)
		src.viewer_client.images -= src.client_image
	if (src.client_image)
		src.client_image.filters = null
	qdel(src.client_image)
	src.client_image = null
	src.image_group = null
	src.viewer = null
	src.viewer_client = null
	. = ..()

/// A client-visible crew apparition actor backed by an atom for movement and speech origin
/obj/crew_apparition_actor/humanoid
	name = "hallucinated person"
	var/mob/victim
	var/mob/living/carbon/human/appearance_source
	var/conversation_running = FALSE
	var/conversation_generation = 0
	var/watcher_running = FALSE
	var/watcher_generation = 0
	var/walking = FALSE
	var/walk_generation = 0
	var/list/turf/walk_route
	var/turf/walk_destination

/obj/crew_apparition_actor/humanoid/New(location, mob/viewer, mob/living/carbon/human/appearance_source, ttl = 30 SECONDS, fallback_to_viewer = FALSE, range = 7, appearance_time = 2 SECONDS, datum/client_image_group/image_group = null)
	var/can_use_viewer_appearance = fallback_to_viewer && appearance_source == viewer && ishuman(viewer)
	if (!can_use_viewer_appearance && !is_crew_apparition_human_eligible(viewer, appearance_source, range))
		appearance_source = pick_crew_apparition_human(viewer, range)
	if (!appearance_source)
		qdel(src)
		return

	. = ..(location, viewer, appearance_source, ttl, appearance_time, image_group)
	if (QDELETED(src))
		return
	src.victim = viewer
	src.appearance_source = appearance_source
	src.name = appearance_source.name
	src.track_viewer_movement = TRUE
	src.face_viewer()

/// Face the viewer
/obj/crew_apparition_actor/humanoid/proc/face_viewer()
	return src.face_target(src.victim)

/// Enable or disable automatic facing toward the viewer
/obj/crew_apparition_actor/humanoid/proc/set_viewer_tracking(should_track)
	src.track_viewer_movement = should_track
	if (should_track)
		src.face_viewer()
	return TRUE

/// Check whether this actor follows the viewer's movement
/obj/crew_apparition_actor/humanoid/proc/is_viewer_tracking()
	return src.track_viewer_movement

/// Check whether this actor is following a walking route
/obj/crew_apparition_actor/humanoid/proc/is_walking()
	return src.walking

/// Begin a watcher behavior sequence
/obj/crew_apparition_actor/humanoid/proc/start_watcher_behavior()
	if (QDELETED(src) || src.watcher_running)
		return FALSE
	src.watcher_running = TRUE
	src.watcher_generation++
	return TRUE

/// Check whether the watcher behavior is still running
/obj/crew_apparition_actor/humanoid/proc/is_watcher_running()
	return src.watcher_running

/// Return the watcher's current lifecycle generation
/obj/crew_apparition_actor/humanoid/proc/get_watcher_generation()
	return src.watcher_generation

/// Cancel all running movement and dialogue behavior
/obj/crew_apparition_actor/humanoid/proc/cancel_behavior()
	src.conversation_generation++
	src.conversation_running = FALSE
	src.watcher_generation++
	src.watcher_running = FALSE
	src.walk_generation++
	src.walking = FALSE
	src.walk_route = null
	src.walk_destination = null
	return TRUE

/// Check whether this active actor is in the viewer's current sight
/obj/crew_apparition_actor/humanoid/proc/is_visible_to_viewer()
	if (!src.is_active())
		return FALSE
	return src in view(src.victim.client.view, src.victim)

/// Face a target using the closest cardinal direction
/obj/crew_apparition_actor/proc/face_target(atom/target)
	if (!src.is_active() || !target)
		return FALSE
	var/turf/source_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if (!source_turf || !target_turf || source_turf.z != target_turf.z)
		return FALSE
	if (source_turf == target_turf)
		return TRUE

	var/target_angle = get_angle(src, target)
	if (isnull(target_angle))
		return FALSE

	// Humanoid appearance sources use cardinal-facing states, so choose the closest
	// cardinal direction within a 90-degree cone toward the target
	var/selected_direction = 0
	var/smallest_angle_difference = 180
	for (var/direction in cardinal)
		var/angle_difference = abs(angledifference(dir_to_angle(direction), target_angle))
		if (angle_difference < smallest_angle_difference)
			selected_direction = direction
			smallest_angle_difference = angle_difference
	if (selected_direction && smallest_angle_difference <= 90)
		src.set_dir(selected_direction)
	return TRUE

/// Say a phrase directly to the viewer
/obj/crew_apparition_actor/humanoid/proc/say_phrase(phrase = null, sound = null, sound_volume = 50, atom/facing_target = null)
	if (!src.is_visible_to_viewer())
		return FALSE
	if (isnull(phrase))
		phrase = phrase_log.random_phrase("say")
	if (!length(phrase))
		return FALSE
	if (!sound && src.appearance_source)
		sound = src.appearance_source.voice_sound_override
		if (!sound)
			var/voice_type = src.appearance_source.voice_type
			switch (copytext(phrase, length(phrase)))
				if ("?")
					voice_type = "[voice_type]?"
				if ("!")
					voice_type = "[voice_type]!"
			sound = global.sounds_speak["[voice_type]"]

	var/atom/speaking_target = facing_target ? facing_target : src.victim
	src.face_target(speaking_target)
	// Deliver the message directly to the hallucinating victim through the atom listener override
	src.say(phrase, atom_listeners_override = list(src.victim))
	if (sound)
		var/atom/origin = src.loc || src
		var/voice_pitch = src.appearance_source?.get_age_pitch_for_talk() || 1
		src.victim.playsound_local(origin, sound, sound_volume, 1, pitch = voice_pitch)
	return TRUE

/// Start a timed sequence of phrases for the viewer
/obj/crew_apparition_actor/humanoid/proc/start_conversation(max_lines = 3, line_delay = 2 SECONDS, sound = null, sound_volume = 50)
	if (!src.is_active() || src.conversation_running)
		return FALSE

	max_lines = clamp(max_lines, 1, CREW_APPARITION_ACTOR_MAX_CONVERSATION_LINES)
	var/conversation_duration = min(src.remaining_ttl(), CREW_APPARITION_ACTOR_MAX_CONVERSATION_DURATION)
	if (conversation_duration <= 0)
		return FALSE

	src.conversation_running = TRUE
	src.conversation_generation++
	var/current_generation = src.conversation_generation
	SPAWN(0)
		var/conversation_deadline = world.time + conversation_duration
		for (var/line_number = 1 to max_lines)
			if (QDELETED(src) || world.time >= conversation_deadline || !src.victim?.client)
				break
			if (src.conversation_generation != current_generation)
				return
			if (!src.say_phrase(sound = sound, sound_volume = sound_volume))
				break
			if (src.conversation_generation != current_generation)
				return
			if (line_number < max_lines)
				var/time_until_next_line = min(max(line_delay, 1), conversation_deadline - world.time)
				if (time_until_next_line <= 0)
					break
				if (src.conversation_generation != current_generation)
					return
				sleep(time_until_next_line)
				if (QDELETED(src) || src.conversation_generation != current_generation)
					return
		if (!QDELETED(src) && src.conversation_generation == current_generation)
			src.conversation_running = FALSE
	return TRUE

/// Walk this actor to a nearby pathable turf
/obj/crew_apparition_actor/humanoid/proc/walk_apparition_to(atom/target, max_distance = CREW_APPARITION_ACTOR_MAX_WALK_DISTANCE, step_delay = BASE_SPEED + WALK_DELAY_ADD)
	if (QDELETED(src) || src.walking || !src.victim?.client || src.remaining_ttl() <= 0 || QDELETED(target))
		return FALSE
	if (!isturf(src.loc))
		return FALSE
	var/turf/target_turf = get_turf(target)
	if (!target_turf || target_turf.z != src.z)
		return FALSE
	if (!isnum(max_distance))
		max_distance = CREW_APPARITION_ACTOR_MAX_WALK_DISTANCE
	max_distance = clamp(max_distance, 1, CREW_APPARITION_ACTOR_MAX_WALK_DISTANCE)
	if (!isnum(step_delay))
		step_delay = BASE_SPEED + WALK_DELAY_ADD
	step_delay = max(step_delay, world.tick_lag)

	var/list/turf/route = get_path_to(src, target_turf, max_distance = max_distance, max_seen = CREW_APPARITION_ACTOR_MAX_WALK_SEEN, \
		mintargetdist = 0, simulated_only = FALSE, skip_first = TRUE, cardinal_only = TRUE)
	if (!length(route))
		return FALSE

	src.walking = TRUE
	src.walk_route = route.Copy()
	src.walk_destination = target_turf
	src.set_viewer_tracking(FALSE)
	src.walk_generation++
	var/walk_generation = src.walk_generation
	SPAWN(0)
		var/reached_destination = TRUE
		var/list/turf/route_to_follow = src.walk_route
		var/turf/destination_to_reach = src.walk_destination
		for (var/turf/next_turf as anything in route_to_follow)
			if (QDELETED(src) || src.walk_generation != walk_generation || !src.is_active())
				reached_destination = FALSE
				break
			if (!destination_to_reach || !isturf(src.loc) || src.z != destination_to_reach.z)
				reached_destination = FALSE
				break
			var/turf/current_turf = get_turf(src)
			if (!next_turf || !current_turf || !jpsTurfPassable(next_turf, source = current_turf, passer = src))
				reached_destination = FALSE
				break
			src.set_dir(get_dir(current_turf, next_turf))
			src.set_loc(next_turf)
			if (next_turf != route_to_follow[length(route_to_follow)])
				sleep(step_delay)
		if (!QDELETED(src) && src.walk_generation == walk_generation)
			src.walking = FALSE
			src.walk_route = null
			src.walk_destination = null
			if (reached_destination)
				src.set_viewer_tracking(TRUE)
	return TRUE

/obj/crew_apparition_actor/humanoid/disposing()
	src.conversation_generation++
	src.walk_generation++
	src.watcher_generation++
	src.watcher_running = FALSE
	src.walking = FALSE
	src.walk_route = null
	src.walk_destination = null
	src.victim = null
	src.appearance_source = null
	. = ..()

#undef CREW_APPARITION_ACTOR_MAX_TTL
#undef CREW_APPARITION_ACTOR_MAX_CONVERSATION_DURATION
#undef CREW_APPARITION_ACTOR_MAX_CONVERSATION_LINES
#undef CREW_APPARITION_ACTOR_MAX_WALK_DISTANCE
#undef CREW_APPARITION_ACTOR_MAX_WALK_SEEN
