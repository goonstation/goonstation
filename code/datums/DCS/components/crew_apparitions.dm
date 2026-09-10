/// Number of turf candidates tried when spawning a crew apparition
#define CREW_APPARITION_LOCATION_ATTEMPTS 10
/// Number of destination routes attempted for each walker start
#define CREW_APPARITION_WALK_DESTINATION_ATTEMPTS 2
/// Maximum pathfinding nodes examined while finding walker starts; 768 nodes × 4 cardinal directions
/// ≈ 3072 worst-case start-flood edge checks
#define CREW_APPARITION_WALK_SEARCH_NODE_CAP 768
/// Number of cardinal edges examined per flood node
#define CREW_APPARITION_WALK_SEARCH_DIRECTION_COUNT 4
/// Maximum cardinal edge-check attempts shared by both floods in one distance pass; the total pass budget is 8192
#define CREW_APPARITION_WALK_SEARCH_WORK_CAP 8192
/// Maximum cardinal edge-check attempts reserved for each destination flood
/// The remaining 5120 edge-check budget is shared by destination floods for candidate walker starts
#define CREW_APPARITION_WALK_DESTINATION_WORK_CAP \
	(CREW_APPARITION_WALK_SEARCH_WORK_CAP - \
	(CREW_APPARITION_WALK_SEARCH_NODE_CAP * CREW_APPARITION_WALK_SEARCH_DIRECTION_COUNT))
/// Player's maximum visible radius in tiles
#define CREW_APPARITION_VIEW_RADIUS ((WIDE_TILE_WIDTH - 1) / 2)
/// Maximum distance searched for an apparition that begins outside the victim's view
#define CREW_APPARITION_OFFSCREEN_MAX_DISTANCE CREW_APPARITION_VIEW_RADIUS + 2
/// Standard lifetime for crew apparitions
#define CREW_APPARITION_TTL (30 SECONDS)
/// Extended lifetime used by watcher apparitions while they observe their victim
#define CREW_APPARITION_WATCHER_TTL (90 SECONDS)
/// Duration of the initial reveal animation for a client-visible crew apparition actor
#define CREW_APPARITION_APPEAR_TIME (0.25 SECONDS)
/// Hard maximum number of apparition spawn attempts made per life tick
#define CREW_APPARITION_ENCOUNTERS_PER_TICK_CAP 10
/// Number of lines a watcher can deliver during its appearance
#define CREW_APPARITION_WATCHER_LINES 4
/// How long a watcher waits for its victim to see it
#define CREW_APPARITION_WATCHER_VISIBLE_WAIT (15 SECONDS)
/// Delay between watcher lines when the victim can see the apparition
#define CREW_APPARITION_WATCHER_PHRASE_DELAY (15 SECONDS)
/// Number of lines exchanged by a chatter pair
#define CREW_APPARITION_CHATTER_LINES 8
/// Delay between lines in a chatter conversation
#define CREW_APPARITION_CHATTER_DELAY (3 SECONDS)
/// How long a chatter pair waits for its victim to see them
#define CREW_APPARITION_CHATTER_VISIBLE_WAIT (15 SECONDS)
/// Maximum separation allowed between members of a chatter pair
#define CREW_APPARITION_CHATTER_MAX_DISTANCE 3
/// Number of descending travel-distance bands tried for a walker
#define CREW_APPARITION_WALK_DISTANCE_PASSES 2
/// Step cadence used to keep walkers close to player movement speed
#define CREW_APPARITION_WALK_STEP_DELAY (BASE_SPEED + WALK_DELAY_ADD)
/// How long a walker waits for its victim to see it after arriving
#define CREW_APPARITION_WALKER_VISIBLE_WAIT (10 SECONDS)
/// Total number of phrases a walker delivers after reaching its destination
#define CREW_APPARITION_WALKER_LINES 3

TYPEINFO(/datum/component/crew_apparitions)
	initialization_args = list(
		ARG_INFO("encounter_chance", DATA_INPUT_NUM, "Chance (%) for a crew apparition each life tick", 10),
		ARG_INFO("max_apparitions", DATA_INPUT_NUM, "Maximum simultaneous crew apparitions (minimum 1)", 10),
		ARG_INFO("encounters_per_life_tick", DATA_INPUT_NUM, "Number of apparition spawn attempts per life tick", 1)
	)

/datum/component/crew_apparitions
	dupe_mode = COMPONENT_DUPE_SELECTIVE

	var/mob/affected_mob
	var/client/viewer_client
	/// Client image group shared by all apparitions owned by this component
	var/datum/client_image_group/image_group
	var/list/obj/crew_apparition_actor/active_apparitions
	var/last_archetype
	var/lifecycle_generation = 0
	var/lifecycle_active = TRUE
	var/encounter_chance = 10
	/// Configured maximum number of simultaneous apparitions; positive values have no artificial upper bound
	var/max_apparitions = 10
	/// Number of apparition spawn attempts made on each life tick
	var/encounters_per_life_tick = 1


/datum/component/crew_apparitions/Initialize(encounter_chance = 10, max_apparitions = 10, encounters_per_life_tick = 1)
	. = ..()
	if (. == COMPONENT_INCOMPATIBLE || !ismob(src.parent))
		return COMPONENT_INCOMPATIBLE
	src.affected_mob = src.parent
	src.configure(encounter_chance, max_apparitions, encounters_per_life_tick)


/datum/component/crew_apparitions/CheckDupeComponent(datum/component/C, encounter_chance = 10, max_apparitions = 10, encounters_per_life_tick = 1)
	src.configure(encounter_chance, max_apparitions, encounters_per_life_tick)
	return TRUE

/datum/component/crew_apparitions/proc/configure(encounter_chance = 10, max_apparitions = 10, encounters_per_life_tick = 1)
	if (!isnum(encounter_chance))
		encounter_chance = 10
	if (!isnum_safe(max_apparitions))
		max_apparitions = 10
	if (!isnum(encounters_per_life_tick))
		encounters_per_life_tick = 1
	src.encounter_chance = clamp(encounter_chance, 0, 100)
	src.max_apparitions = max(round(max_apparitions, 1), 1)
	src.encounters_per_life_tick = clamp(round(encounters_per_life_tick, 1), 1, CREW_APPARITION_ENCOUNTERS_PER_TICK_CAP)

/datum/component/crew_apparitions/RegisterWithParent()
	src.RegisterSignal(src.parent, COMSIG_LIVING_LIFE_TICK, PROC_REF(on_life_tick))
	src.RegisterSignal(src.parent, COMSIG_MOB_LOGIN, PROC_REF(viewer_login))
	src.RegisterSignal(src.parent, COMSIG_MOB_LOGOUT, PROC_REF(viewer_logout))
	src.RegisterSignal(src.parent, COMSIG_MOB_OBSERVER_ATTACHED, PROC_REF(observer_attached))
	src.RegisterSignal(src.parent, COMSIG_MOB_OBSERVER_DETACHED, PROC_REF(observer_detached))
	src.RegisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(parent_disposing))
	src.image_group = new /datum/client_image_group
	src.image_group.add_mob(src.affected_mob)
	for (var/mob/dead/target_observer/observer as anything in src.affected_mob.observers)
		src.image_group.add_mob(observer)
	src.register_client(src.affected_mob.client)

/datum/component/crew_apparitions/proc/is_lifecycle_valid(current_generation = null)
	if (isnull(current_generation))
		current_generation = src.lifecycle_generation
	if (QDELETED(src) || !src.lifecycle_active || src.lifecycle_generation != current_generation || src.parent != src.affected_mob)
		return FALSE
	if (QDELETED(src.affected_mob))
		return FALSE
	return TRUE

/datum/component/crew_apparitions/proc/cleanup(dissolve_time = 2 SECONDS)
	if (!src.lifecycle_active)
		return
	src.lifecycle_active = FALSE
	src.lifecycle_generation++
	src.clear(dissolve_time = dissolve_time)

/datum/component/crew_apparitions/proc/parent_disposing()
	src.cleanup(dissolve_time = 0)


/datum/component/crew_apparitions/UnregisterFromParent()
	if (src.parent)
		src.UnregisterSignal(src.parent, list(COMSIG_LIVING_LIFE_TICK, COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_MOB_OBSERVER_ATTACHED, COMSIG_MOB_OBSERVER_DETACHED, COMSIG_PARENT_PRE_DISPOSING))
	src.unregister_client()
	src.cleanup(dissolve_time = 0)
	src.dispose_image_group()
	. = ..()

/datum/component/crew_apparitions/disposing()
	src.unregister_client()
	src.cleanup(dissolve_time = 0)
	src.dispose_image_group()
	src.affected_mob = null
	src.active_apparitions = null
	src.viewer_client = null
	src.last_archetype = null
	. = ..()

/// Dispose the image group owned by this component
/datum/component/crew_apparitions/proc/dispose_image_group()
	if (!src.image_group)
		return
	var/datum/client_image_group/group = src.image_group
	src.image_group = null
	qdel(group)

/// Track the viewer's current client for image ownership
/datum/component/crew_apparitions/proc/register_client(client/new_client)
	if (new_client == src.viewer_client)
		return
	src.unregister_client()
	src.viewer_client = new_client
	if (src.viewer_client)
		src.RegisterSignal(src.viewer_client, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(viewer_client_disposing))

/// Stop tracking the viewer's client
/datum/component/crew_apparitions/proc/unregister_client()
	if (src.viewer_client && !QDELETED(src.viewer_client))
		src.UnregisterSignal(src.viewer_client, COMSIG_PARENT_PRE_DISPOSING)
	src.viewer_client = null

/// Reattach image ownership when the viewer logs in
/datum/component/crew_apparitions/proc/viewer_login(mob/logged_in_viewer)
	if (logged_in_viewer != src.affected_mob)
		return
	src.register_client(logged_in_viewer.client)

/// Remove viewer-only images when the viewer logs out
/datum/component/crew_apparitions/proc/viewer_logout(mob/logged_out_viewer)
	if (logged_out_viewer != src.affected_mob)
		return
	src.clear(dissolve_time = 0)
	src.unregister_client()

/// Remove viewer-only images before the viewer's client is disposed
/datum/component/crew_apparitions/proc/viewer_client_disposing(client/disposed_client)
	if (disposed_client != src.viewer_client)
		return
	src.clear(dissolve_time = 0)
	src.unregister_client()

/// Subscribe a target observer that has started observing the affected mob
/datum/component/crew_apparitions/proc/observer_attached(mob/observed_mob, mob/dead/target_observer/observer)
	if (observed_mob != src.affected_mob || !observer || QDELETED(observer))
		return
	src.image_group?.add_mob(observer)

/// Unsubscribe a target observer that has stopped observing the affected mob
/datum/component/crew_apparitions/proc/observer_detached(mob/observed_mob, mob/dead/target_observer/observer)
	if (observed_mob != src.affected_mob || !observer)
		return
	src.image_group?.remove_mob(observer)

/// Create and retain a client-visible crew apparition actor at a world location
/datum/component/crew_apparitions/proc/create_apparition_actor(atom/location, ttl = CREW_APPARITION_TTL, range = CREW_APPARITION_VIEW_RADIUS, fallback_to_viewer = FALSE)
	RETURN_TYPE(/obj/crew_apparition_actor/humanoid)
	if (!src.is_lifecycle_valid() || !src.affected_mob.client || !location)
		return
	var/mob/living/carbon/human/appearance_source = pick_crew_apparition_human(src.affected_mob, range)
	if (!appearance_source && fallback_to_viewer && ishuman(src.affected_mob))
		var/mob/living/carbon/human/human_viewer = src.affected_mob
		appearance_source = human_viewer
	if (!appearance_source)
		return

	var/obj/crew_apparition_actor/humanoid/apparition = new /obj/crew_apparition_actor/humanoid(location, src.affected_mob, appearance_source, ttl, fallback_to_viewer, range, \
		appearance_time = CREW_APPARITION_APPEAR_TIME, image_group = src.image_group)
	if (QDELETED(apparition))
		return
	src.active_apparitions ||= list()
	src.active_apparitions += apparition
	src.RegisterSignal(apparition, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(apparition_disposing))
	return apparition

/// Remove a disposed apparition from this component's index
/datum/component/crew_apparitions/proc/apparition_disposing(obj/crew_apparition_actor/disposed_apparition)
	if (src.active_apparitions)
		src.active_apparitions -= disposed_apparition

/// Return active client-visible actors owned by this component
/datum/component/crew_apparitions/proc/get_active_apparitions()
	var/list/obj/crew_apparition_actor/active = list()
	if (!src.active_apparitions)
		return active
	for (var/obj/crew_apparition_actor/apparition as anything in src.active_apparitions)
		if (QDELETED(apparition) || !apparition.is_active())
			continue
		active += apparition
	return active

/// Check whether this component can manage an apparition
/datum/component/crew_apparitions/proc/is_tracked_apparition(obj/crew_apparition_actor/apparition)
	return !QDELETED(apparition) && src.active_apparitions && (apparition in src.active_apparitions)

/// End one client-visible crew apparition actor
/datum/component/crew_apparitions/proc/end(obj/crew_apparition_actor/apparition, dissolve_time = 2 SECONDS)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	if (dissolve_time <= 0)
		qdel(apparition)
		return TRUE
	return apparition.dissolve(dissolve_time)

/// End all client-visible actors owned by this component
/datum/component/crew_apparitions/proc/clear(dissolve_time = 2 SECONDS)
	if (!src.active_apparitions)
		return
	for (var/obj/crew_apparition_actor/apparition as anything in src.active_apparitions.Copy())
		src.end(apparition, dissolve_time)

/// Cancel running movement or dialogue behavior on one apparition
/datum/component/crew_apparitions/proc/cancel_behavior(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.cancel_behavior()

/// Enable or disable viewer tracking on one apparition
/datum/component/crew_apparitions/proc/set_viewer_tracking(obj/crew_apparition_actor/humanoid/apparition, should_track)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.set_viewer_tracking(should_track)

/// Start watcher behavior on one apparition
/datum/component/crew_apparitions/proc/start_watcher_behavior(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.start_watcher_behavior()

/// Check whether one apparition is active and visible to its viewer
/datum/component/crew_apparitions/proc/is_visible_to_viewer(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.is_visible_to_viewer()

/// Check whether one apparition is still active
/datum/component/crew_apparitions/proc/is_active(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.is_active()

/// Return the remaining lifetime of one apparition
/datum/component/crew_apparitions/proc/remaining_ttl(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return 0
	return apparition.remaining_ttl()

/// Face one apparition toward its viewer
/datum/component/crew_apparitions/proc/face_viewer(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.face_viewer()

/// Set one apparition's facing direction
/datum/component/crew_apparitions/proc/set_direction(obj/crew_apparition_actor/humanoid/apparition, new_direction)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	apparition.set_dir(new_direction)
	return TRUE

/// Say a phrase through one apparition
/datum/component/crew_apparitions/proc/say_phrase(obj/crew_apparition_actor/humanoid/apparition, phrase = null, sound = null, sound_volume = 50, atom/facing_target = null)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.say_phrase(phrase, sound, sound_volume, facing_target)

/// Check whether one apparition follows its viewer
/datum/component/crew_apparitions/proc/is_viewer_tracking(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.is_viewer_tracking()

/// Check whether one apparition is following a walking route
/datum/component/crew_apparitions/proc/is_walking(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.is_walking()

/// Walk one apparition to a target
/datum/component/crew_apparitions/proc/walk_apparition_to(obj/crew_apparition_actor/humanoid/apparition, atom/target, max_distance = null, step_delay = null)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.walk_apparition_to(target, max_distance, step_delay)

/// Check whether one apparition's watcher behavior is running
/datum/component/crew_apparitions/proc/is_watcher_running(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return FALSE
	return apparition.is_watcher_running()

/// Return one apparition's watcher behavior generation
/datum/component/crew_apparitions/proc/get_watcher_generation(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_tracked_apparition(apparition))
		return
	return apparition.get_watcher_generation()

/// Pick a pathable turf near the affected mob, preferring an off-screen location
/datum/component/crew_apparitions/proc/pick_apparition_location(excluded_turf = null, prefer_outside_view = FALSE)
	if (!src.is_lifecycle_valid())
		return
	var/turf/victim_turf = get_turf(src.affected_mob)
	if (!victim_turf || isrestrictedz(victim_turf.z))
		return

	var/search_outside_view = prefer_outside_view
	var/search_passes = search_outside_view ? 2 : 1
	var/list/visible_turf_set
	if (search_outside_view)
		if (!src.affected_mob.client)
			return
		visible_turf_set = list()
		for (var/turf/visible_turf in view(src.affected_mob.client.view, src.affected_mob))
			visible_turf_set[visible_turf] = TRUE

	for (var/search_pass in 1 to search_passes)
		var/maximum_distance = CREW_APPARITION_VIEW_RADIUS
		if (search_outside_view && search_pass == 1)
			maximum_distance = CREW_APPARITION_OFFSCREEN_MAX_DISTANCE
		if (search_outside_view && search_pass == 1)
			var/list/candidates = list()
			for (var/turf/candidate in range(maximum_distance, victim_turf))
				if (candidate == excluded_turf || visible_turf_set[candidate])
					continue
				var/distance = get_dist(candidate, victim_turf)
				if (distance < 1 || distance > maximum_distance)
					continue
				if (is_blocked_turf(candidate) || !candidate.pathable || isrestrictedz(candidate.z))
					continue
				candidates += candidate
			if (length(candidates))
				return pick(candidates)
			continue

		for (var/attempt in 1 to CREW_APPARITION_LOCATION_ATTEMPTS)
			var/turf/candidate = locate(
				victim_turf.x + rand(-maximum_distance, maximum_distance), \
				victim_turf.y + rand(-maximum_distance, maximum_distance), \
				victim_turf.z)
			if (!candidate || candidate == excluded_turf)
				continue
			var/distance = get_dist(candidate, victim_turf)
			if (distance < 1 || distance > maximum_distance)
				continue
			if (search_outside_view && search_pass == 1 && visible_turf_set[candidate])
				continue
			if (is_blocked_turf(candidate) || !candidate.pathable || isrestrictedz(candidate.z))
				continue
			return candidate
	return

/// Pick a second location that keeps a chatter pair visible and close together
/datum/component/crew_apparitions/proc/pick_chatter_location(turf/first_location)
	if (!src.is_lifecycle_valid() || !first_location)
		return
	if (!(first_location in view(CREW_APPARITION_VIEW_RADIUS, src.affected_mob)))
		return
	for (var/attempt in 1 to CREW_APPARITION_LOCATION_ATTEMPTS)
		var/turf/candidate = locate(
			first_location.x + rand(-CREW_APPARITION_CHATTER_MAX_DISTANCE, CREW_APPARITION_CHATTER_MAX_DISTANCE), \
			first_location.y + rand(-CREW_APPARITION_CHATTER_MAX_DISTANCE, CREW_APPARITION_CHATTER_MAX_DISTANCE), \
			first_location.z)
		if (!candidate || candidate == first_location)
			continue
		if (is_blocked_turf(candidate) || !candidate.pathable || isrestrictedz(candidate.z))
			continue
		if (get_dist(candidate, first_location) > CREW_APPARITION_CHATTER_MAX_DISTANCE)
			continue
		if (!(candidate in view(CREW_APPARITION_VIEW_RADIUS, src.affected_mob)))
			continue
		if (!(candidate in view(CREW_APPARITION_VIEW_RADIUS, first_location)))
			continue
		if (!(first_location in view(CREW_APPARITION_VIEW_RADIUS, candidate)))
			continue
		return candidate
	return

/// Wait for an apparition to enter the affected mob's view
/datum/component/crew_apparitions/proc/wait_for_visibility(obj/crew_apparition_actor/humanoid/apparition, wait_time)
	if (src.visibility_wait_aborted(apparition))
		return FALSE
	UNTIL(src.visibility_wait_aborted(apparition) || src.is_visible_to_viewer(apparition), wait_time)
	if (src.visibility_wait_aborted(apparition))
		return FALSE
	return src.is_visible_to_viewer(apparition)

/// Check whether waiting for an apparition's visibility should stop without success
/datum/component/crew_apparitions/proc/visibility_wait_aborted(obj/crew_apparition_actor/humanoid/apparition)
	return !src.is_lifecycle_valid() || QDELETED(apparition) || !src.affected_mob.client

/// Check whether both members of a chatter pair are visible
/datum/component/crew_apparitions/proc/chatters_are_visible(obj/crew_apparition_actor/humanoid/first_chatter, obj/crew_apparition_actor/humanoid/second_chatter)
	if (!src.is_lifecycle_valid() || QDELETED(first_chatter) || QDELETED(second_chatter))
		return FALSE
	return src.is_visible_to_viewer(first_chatter) && src.is_visible_to_viewer(second_chatter)

/// Wait for both members of a chatter pair to enter the affected mob's view
/datum/component/crew_apparitions/proc/wait_for_chatter_visibility(obj/crew_apparition_actor/humanoid/first_chatter, obj/crew_apparition_actor/humanoid/second_chatter)
	if (src.chatter_visibility_wait_aborted(first_chatter, second_chatter))
		return FALSE
	UNTIL(src.chatter_visibility_wait_aborted(first_chatter, second_chatter) || \
		src.chatters_are_visible(first_chatter, second_chatter), CREW_APPARITION_CHATTER_VISIBLE_WAIT)
	if (src.chatter_visibility_wait_aborted(first_chatter, second_chatter))
		return FALSE
	return src.chatters_are_visible(first_chatter, second_chatter)

/// Check whether waiting for a chatter pair's visibility should stop without success
/datum/component/crew_apparitions/proc/chatter_visibility_wait_aborted(obj/crew_apparition_actor/humanoid/first_chatter, obj/crew_apparition_actor/humanoid/second_chatter)
	return !src.is_lifecycle_valid() || QDELETED(first_chatter) || QDELETED(second_chatter) || !src.affected_mob.client

/// Check whether a flooded turf can be used as a walker start
/datum/component/crew_apparitions/proc/is_valid_walker_candidate_start(turf/current_turf, turf/victim_turf, list/visible_turf_set)
	if (visible_turf_set[current_turf])
		return FALSE
	if (current_turf == victim_turf)
		return FALSE
	if (get_dist(current_turf, victim_turf) > CREW_APPARITION_OFFSCREEN_MAX_DISTANCE)
		return FALSE
	if (is_blocked_turf(current_turf))
		return FALSE
	if (!current_turf.pathable)
		return FALSE
	return TRUE

/// Check whether a flooded turf can be used as a visible walker destination
/datum/component/crew_apparitions/proc/is_valid_walker_destination(turf/current_turf, turf/start_location, turf/victim_turf, \
	start_distance_from_victim, maximum_walk_distance, list/visible_turf_set)
	if (current_turf == start_location)
		return FALSE
	if (!visible_turf_set[current_turf])
		return FALSE
	if (get_dist(current_turf, victim_turf) >= start_distance_from_victim)
		return FALSE
	if (abs(current_turf.x - start_location.x) + abs(current_turf.y - start_location.y) > maximum_walk_distance)
		return FALSE
	if (is_blocked_turf(current_turf))
		return FALSE
	if (!current_turf.pathable)
		return FALSE
	return TRUE

/// Flood from visible turfs outward to find bounded walker starts
/datum/component/crew_apparitions/proc/find_walker_candidate_starts(maximum_walk_distance, list/pass_work)
	if (!src.is_lifecycle_valid())
		return
	if (!src.affected_mob.client)
		return
	if (!isnum(maximum_walk_distance))
		return
	var/turf/victim_turf = get_turf(src.affected_mob)
	if (!victim_turf)
		return
	if (isrestrictedz(victim_turf.z))
		return
	maximum_walk_distance = min(maximum_walk_distance, get_crew_apparition_actor_max_walk_distance())
	maximum_walk_distance = max(round(maximum_walk_distance, 1), 1)
	var/route_slack = get_crew_apparition_actor_walk_route_slack()
	var/route_max_distance = maximum_walk_distance + route_slack
	var/search_radius = CREW_APPARITION_OFFSCREEN_MAX_DISTANCE + route_slack
	var/list/turf/visible_destinations = list()
	var/list/visible_turf_set = list()
	for (var/turf/visible_turf in view(src.affected_mob.client.view, src.affected_mob))
		visible_turf_set[visible_turf] = TRUE
		if (length(visible_destinations) >= CREW_APPARITION_WALK_SEARCH_NODE_CAP)
			continue
		if (visible_turf.z != victim_turf.z)
			continue
		if (isrestrictedz(visible_turf.z))
			continue
		if (is_blocked_turf(visible_turf))
			continue
		if (!visible_turf.pathable)
			continue
		visible_destinations += visible_turf
	if (!length(visible_destinations))
		return

	// Seed eligible visible destinations so disconnected rooms can contribute starts
	// A candidate only needs reverse reachability to some visible seed; the destination flood checks the forward route
	// Distances also mark queued turfs as visited; zero is a valid seed distance
	var/list/turf/search_queue = visible_destinations.Copy()
	var/list/distance_by_turf = list()
	for (var/turf/destination as anything in visible_destinations)
		distance_by_turf[destination] = 0

	var/list/turf/candidate_starts = list()
	for (var/queue_index = 1; queue_index <= length(search_queue); queue_index++)
		if (queue_index > CREW_APPARITION_WALK_SEARCH_NODE_CAP)
			break
		if (pass_work["edges_checked"] >= CREW_APPARITION_WALK_SEARCH_WORK_CAP)
			break
		var/turf/current_turf = search_queue[queue_index]
		var/current_distance = distance_by_turf[current_turf]
		if (src.is_valid_walker_candidate_start(current_turf, victim_turf, visible_turf_set))
			candidate_starts += current_turf

		if (current_distance >= route_max_distance)
			continue
		for (var/direction in list(EAST, WEST, NORTH, SOUTH))
			if (pass_work["edges_checked"] >= CREW_APPARITION_WALK_SEARCH_WORK_CAP)
				break
			// Charge every attempted edge, including neighbors rejected below
			pass_work["edges_checked"]++
			var/turf/next_turf = get_step(current_turf, direction)
			if (!next_turf)
				continue
			if (next_turf.z != victim_turf.z)
				continue
			if (!isnull(distance_by_turf[next_turf]))
				continue
			if (get_dist(next_turf, victim_turf) > search_radius)
				continue
			if (is_blocked_turf(next_turf))
				continue
			if (!next_turf.pathable)
				continue
			// Check the edge in the walker's direction by flooding in reverse
			if (!jpsTurfPassable(current_turf, source = next_turf, passer = src.affected_mob))
				continue
			distance_by_turf[next_turf] = current_distance + 1
			search_queue += next_turf
	return candidate_starts

/// Flood from one unseen start inward to find visible destinations
/datum/component/crew_apparitions/proc/find_walker_destinations(turf/start_location, maximum_walk_distance, list/pass_work)
	if (!src.is_lifecycle_valid())
		return
	if (!src.affected_mob.client)
		return
	if (!start_location)
		return
	if (!isnum(maximum_walk_distance))
		return
	var/turf/victim_turf = get_turf(src.affected_mob)
	if (!victim_turf)
		return
	if (start_location.z != victim_turf.z)
		return
	maximum_walk_distance = max(round(maximum_walk_distance, 1), 1)
	var/route_slack = get_crew_apparition_actor_walk_route_slack()
	var/route_max_distance = maximum_walk_distance + route_slack
	var/search_radius = CREW_APPARITION_OFFSCREEN_MAX_DISTANCE + route_slack
	var/list/visible_turf_set = list()
	for (var/turf/visible_turf in view(src.affected_mob.client.view, src.affected_mob))
		visible_turf_set[visible_turf] = TRUE

	var/list/turf/search_queue = list(start_location)
	// Distances also mark queued turfs as visited; zero is a valid seed distance
	var/list/distance_by_turf = list()
	distance_by_turf[start_location] = 0
	var/list/turf/destinations = list()
	var/destination_edges_checked = 0
	var/start_distance_from_victim = get_dist(start_location, victim_turf)
	for (var/queue_index = 1; queue_index <= length(search_queue); queue_index++)
		if (queue_index > CREW_APPARITION_WALK_SEARCH_NODE_CAP)
			break
		var/turf/current_turf = search_queue[queue_index]
		var/current_distance = distance_by_turf[current_turf]
		if (src.is_valid_walker_destination(current_turf, start_location, victim_turf, \
			start_distance_from_victim, maximum_walk_distance, visible_turf_set))
			destinations += current_turf

		if (current_distance >= route_max_distance)
			continue
		// Exhausting either edge budget stops expansion, but queued destinations still count
		if (pass_work["edges_checked"] >= CREW_APPARITION_WALK_SEARCH_WORK_CAP || \
			destination_edges_checked >= CREW_APPARITION_WALK_DESTINATION_WORK_CAP)
			continue
		for (var/direction in list(EAST, WEST, NORTH, SOUTH))
			if (pass_work["edges_checked"] >= CREW_APPARITION_WALK_SEARCH_WORK_CAP)
				break
			if (destination_edges_checked >= CREW_APPARITION_WALK_DESTINATION_WORK_CAP)
				break
			// Charge every attempted edge to both this start's allowance and the shared pass
			pass_work["edges_checked"]++
			destination_edges_checked++
			var/turf/next_turf = get_step(current_turf, direction)
			if (!next_turf)
				continue
			if (next_turf.z != victim_turf.z)
				continue
			if (!isnull(distance_by_turf[next_turf]))
				continue
			if (get_dist(next_turf, victim_turf) > search_radius)
				continue
			if (is_blocked_turf(next_turf))
				continue
			if (!next_turf.pathable)
				continue
			// Flood in the walker's direction so routes match actor movement
			if (!jpsTurfPassable(next_turf, source = current_turf, passer = src.affected_mob))
				continue
			distance_by_turf[next_turf] = current_distance + 1
			search_queue += next_turf
	return destinations

/// Create a watcher apparition that follows the viewer
/datum/component/crew_apparitions/proc/create_watcher()
	var/turf/watcher_location = src.pick_apparition_location(prefer_outside_view = TRUE)
	if (!watcher_location)
		watcher_location = get_turf(src.affected_mob)
	if (!watcher_location || !src.is_lifecycle_valid())
		return FALSE
	var/obj/crew_apparition_actor/humanoid/watcher = src.create_apparition_actor(watcher_location, \
		CREW_APPARITION_WATCHER_TTL, CREW_APPARITION_VIEW_RADIUS, fallback_to_viewer = TRUE)
	if (QDELETED(watcher) || !src.is_lifecycle_valid())
		return FALSE
	src.set_viewer_tracking(watcher, TRUE)
	src.start_watcher(watcher)
	return TRUE

/// Create two apparitions that exchange lines while facing one another
/datum/component/crew_apparitions/proc/create_chatter()
	var/turf/first_chatter_location = src.pick_apparition_location()
	var/turf/second_chatter_location = src.pick_chatter_location(first_chatter_location)
	if (!first_chatter_location)
		return src.create_watcher()
	if (!second_chatter_location)
		var/obj/crew_apparition_actor/humanoid/fallback_watcher = src.create_apparition_actor(first_chatter_location, \
		CREW_APPARITION_WATCHER_TTL, CREW_APPARITION_VIEW_RADIUS, fallback_to_viewer = TRUE)
		if (QDELETED(fallback_watcher))
			return FALSE
		return src.fallback_to_watcher(fallback_watcher)

	var/obj/crew_apparition_actor/humanoid/first_chatter = src.create_apparition_actor(first_chatter_location, \
		CREW_APPARITION_TTL, CREW_APPARITION_VIEW_RADIUS, fallback_to_viewer = TRUE)
	if (QDELETED(first_chatter))
		return FALSE
	var/obj/crew_apparition_actor/humanoid/second_chatter = src.create_apparition_actor(second_chatter_location, \
		CREW_APPARITION_TTL, CREW_APPARITION_VIEW_RADIUS, fallback_to_viewer = TRUE)
	if (QDELETED(second_chatter))
		return src.fallback_to_watcher(first_chatter)

	src.set_viewer_tracking(first_chatter, FALSE)
	src.set_viewer_tracking(second_chatter, FALSE)
	src.set_direction(first_chatter, get_dir(first_chatter, second_chatter))
	src.set_direction(second_chatter, get_dir(second_chatter, first_chatter))
	src.start_alternating_chatter(first_chatter, second_chatter)
	return TRUE

/// Create an apparition that walks to a nearby destination
/datum/component/crew_apparitions/proc/create_walker()
	var/maximum_walk_distance = get_crew_apparition_actor_max_walk_distance()
	var/distance_step = max(round(maximum_walk_distance / CREW_APPARITION_WALK_DISTANCE_PASSES, 1), 1)
	var/obj/crew_apparition_actor/humanoid/fallback_walker
	for (var/distance_pass in 1 to CREW_APPARITION_WALK_DISTANCE_PASSES)
		var/pass_maximum_walk_distance = max(maximum_walk_distance - ((distance_pass - 1) * distance_step), 1)
		// Share one edge-check budget between both floods in this pass
		var/list/pass_work = list("edges_checked" = 0)
		var/list/candidate_starts = src.find_walker_candidate_starts(pass_maximum_walk_distance, pass_work)
		if (!length(candidate_starts) || !src.is_lifecycle_valid())
			continue
		var/list/turf/shuffled_candidate_starts = candidate_starts.Copy()
		shuffle_list(shuffled_candidate_starts)
		for (var/start_attempt in 1 to length(shuffled_candidate_starts))
			if (!src.is_lifecycle_valid() || pass_work["edges_checked"] >= CREW_APPARITION_WALK_SEARCH_WORK_CAP)
				break
			var/turf/start_location = shuffled_candidate_starts[start_attempt]
			var/list/turf/destinations = src.find_walker_destinations(start_location, pass_maximum_walk_distance, pass_work)
			if (!length(destinations))
				continue

			var/obj/crew_apparition_actor/humanoid/walker
			var/list/turf/shuffled_destinations = destinations.Copy()
			shuffle_list(shuffled_destinations)
			for (var/destination_attempt in 1 to min(length(shuffled_destinations), CREW_APPARITION_WALK_DESTINATION_ATTEMPTS))
				if (!src.is_lifecycle_valid())
					break
				var/turf/destination = shuffled_destinations[destination_attempt]

				if (!walker)
					walker = src.create_apparition_actor(start_location, \
						CREW_APPARITION_TTL, CREW_APPARITION_VIEW_RADIUS, fallback_to_viewer = TRUE)
					if (QDELETED(walker))
						walker = null
						break
					src.set_viewer_tracking(walker, FALSE)
				if (!src.walk_apparition_to(walker, destination, max_distance = pass_maximum_walk_distance, \
					step_delay = CREW_APPARITION_WALK_STEP_DELAY))
					continue
				if (fallback_walker)
					src.end(fallback_walker, dissolve_time = 0)
				fallback_walker = null
				src.start_walker(walker)
				return TRUE
			if (walker)
				// Candidate discovery checks visibility and occupancy from the victim's perspective
				if (fallback_walker)
					src.end(fallback_walker, dissolve_time = 0)
				fallback_walker = walker
	if (fallback_walker)
		if (src.fallback_to_watcher(fallback_walker))
			return TRUE
		src.end(fallback_walker, dissolve_time = 0)
	return src.create_watcher()

/// Handle a walker after its route completes or becomes invalid
/datum/component/crew_apparitions/proc/start_walker(obj/crew_apparition_actor/humanoid/walker)
	var/current_generation = src.lifecycle_generation
	SPAWN(0)
		if (!src.is_lifecycle_valid(current_generation) || QDELETED(walker))
			return
		UNTIL(!src.is_lifecycle_valid(current_generation) || QDELETED(walker) || !src.is_walking(walker), 0)
		if (!src.is_lifecycle_valid(current_generation) || QDELETED(walker) || !src.affected_mob.client)
			if (!QDELETED(walker))
				src.end(walker)
			return
		if (!src.is_viewer_tracking(walker))
			src.fallback_to_watcher(walker)
			return
		if (!src.wait_for_visibility(walker, CREW_APPARITION_WALKER_VISIBLE_WAIT))
			src.end(walker)
			return
		src.face_viewer(walker)
		if (!src.say_phrase(walker))
			src.end(walker)
			return
		for (var/line_number in 2 to CREW_APPARITION_WALKER_LINES)
			var/phrase_delay = min(CREW_APPARITION_CHATTER_DELAY, src.remaining_ttl(walker))
			if (phrase_delay <= 0)
				return
			sleep(phrase_delay)
			if (!src.is_lifecycle_valid(current_generation) || QDELETED(walker) || !src.affected_mob.client)
				return
			if (!src.wait_for_visibility(walker, CREW_APPARITION_WALKER_VISIBLE_WAIT))
				if (!src.is_lifecycle_valid(current_generation) || QDELETED(walker))
					return
				src.end(walker)
				return
			src.face_viewer(walker)
			if (!src.say_phrase(walker))
				src.end(walker)
				return

/// Convert an apparition into a single watcher
/datum/component/crew_apparitions/proc/fallback_to_watcher(obj/crew_apparition_actor/humanoid/apparition)
	if (!src.is_lifecycle_valid() || QDELETED(apparition) || !src.affected_mob.client)
		return FALSE
	if (!src.cancel_behavior(apparition))
		return FALSE
	src.set_viewer_tracking(apparition, TRUE)
	src.start_watcher(apparition)
	return TRUE

/// Keep this component's active apparitions within its capacity
/datum/component/crew_apparitions/proc/prune_apparitions()
	if (!src.is_lifecycle_valid())
		return
	var/list/active_apparitions = src.get_active_apparitions()
	var/excess_apparitions = length(active_apparitions) - src.max_apparitions
	if (excess_apparitions <= 0)
		return
	for (var/prune_attempt in 1 to excess_apparitions)
		var/obj/crew_apparition_actor/humanoid/oldest_apparition = active_apparitions[1]
		active_apparitions -= oldest_apparition
		src.end(oldest_apparition)

/// Check whether a watcher still belongs to this lifecycle and behavior sequence
/datum/component/crew_apparitions/proc/watcher_is_current(obj/crew_apparition_actor/humanoid/watcher, lifecycle_generation, watcher_generation)
	return src.is_lifecycle_valid(lifecycle_generation) \
		&& !QDELETED(watcher) \
		&& src.get_watcher_generation(watcher) == watcher_generation

/// Check whether a watcher can continue its current sequence
/datum/component/crew_apparitions/proc/watcher_is_ready(obj/crew_apparition_actor/humanoid/watcher, current_generation)
	if (!src.is_lifecycle_valid() || QDELETED(watcher) || !src.affected_mob.client)
		return FALSE
	if (src.get_watcher_generation(watcher) != current_generation)
		return FALSE
	return src.is_active(watcher) && src.is_watcher_running(watcher)

/// Deliver a watcher's lines after it enters the affected mob's view
/datum/component/crew_apparitions/proc/start_watcher(obj/crew_apparition_actor/humanoid/watcher)
	if (!src.is_lifecycle_valid() || QDELETED(watcher) || !src.start_watcher_behavior(watcher))
		return
	var/current_generation = src.get_watcher_generation(watcher)
	var/lifecycle_generation = src.lifecycle_generation
	SPAWN(0)
		for (var/line_number in 1 to CREW_APPARITION_WATCHER_LINES)
			if (!src.watcher_is_current(watcher, lifecycle_generation, current_generation))
				return
			if (!src.watcher_is_ready(watcher, current_generation))
				src.end(watcher)
				return
			if (!src.wait_for_visibility(watcher, CREW_APPARITION_WATCHER_VISIBLE_WAIT))
				if (!src.watcher_is_current(watcher, lifecycle_generation, current_generation))
					return
				if (src.watcher_is_ready(watcher, current_generation))
					continue
				src.end(watcher)
				return
			if (!src.watcher_is_ready(watcher, current_generation))
				src.end(watcher)
				return
			src.face_viewer(watcher)
			if (!src.say_phrase(watcher))
				src.end(watcher)
				return
			if (line_number < CREW_APPARITION_WATCHER_LINES)
				var/phrase_delay = min(CREW_APPARITION_WATCHER_PHRASE_DELAY, src.remaining_ttl(watcher))
				if (phrase_delay > 0)
					sleep(phrase_delay)

/// End both members of a chatter pair
/datum/component/crew_apparitions/proc/end_chatter_pair(obj/crew_apparition_actor/humanoid/first_chatter, obj/crew_apparition_actor/humanoid/second_chatter)
	if (!QDELETED(first_chatter))
		src.end(first_chatter)
	if (!QDELETED(second_chatter))
		src.end(second_chatter)

/// Deliver an alternating conversation between two apparitions
/datum/component/crew_apparitions/proc/start_alternating_chatter(obj/crew_apparition_actor/humanoid/first_chatter, obj/crew_apparition_actor/humanoid/second_chatter)
	var/lifecycle_generation = src.lifecycle_generation
	SPAWN(0)
		if (!src.is_lifecycle_valid(lifecycle_generation) || !src.wait_for_chatter_visibility(first_chatter, second_chatter))
			src.end_chatter_pair(first_chatter, second_chatter)
			return

		for (var/line_number in 1 to CREW_APPARITION_CHATTER_LINES)
			var/obj/crew_apparition_actor/humanoid/speaker = line_number % 2 ? first_chatter : second_chatter
			var/obj/crew_apparition_actor/humanoid/listener = line_number % 2 ? second_chatter : first_chatter
			if (!src.is_lifecycle_valid(lifecycle_generation) || !src.wait_for_chatter_visibility(first_chatter, second_chatter))
				src.end_chatter_pair(first_chatter, second_chatter)
				return
			if (!src.say_phrase(speaker, facing_target = listener))
				src.end_chatter_pair(first_chatter, second_chatter)
				return
			if (line_number < CREW_APPARITION_CHATTER_LINES)
				sleep(CREW_APPARITION_CHATTER_DELAY)

/// Try to create a crew apparition autonomously on a mob life tick
/datum/component/crew_apparitions/proc/on_life_tick(mob/living/living_mob, mult = 1)
	if (living_mob != src.affected_mob || !src.is_lifecycle_valid() || !living_mob.client)
		return
	for (var/encounter_number in 1 to src.encounters_per_life_tick)
		if (probmult(src.encounter_chance))
			src.create_apparition()

/// Select and create one crew apparition archetype
/datum/component/crew_apparitions/proc/create_apparition()
	if (!src.is_lifecycle_valid())
		return
	src.prune_apparitions()
	var/active_apparition_count = length(src.get_active_apparitions())
	if (active_apparition_count >= src.max_apparitions)
		return

	var/list/available_archetypes = list("watcher", "walker")
	if (active_apparition_count + 2 <= src.max_apparitions)
		available_archetypes += "chatter"
	var/fallback_archetype
	if ((src.last_archetype in available_archetypes) && length(available_archetypes) > 1)
		fallback_archetype = src.last_archetype
		available_archetypes -= src.last_archetype
	var/archetype = pick(available_archetypes)
	var/list/archetypes_to_try = list(archetype)
	if (fallback_archetype)
		// A failed non-repeating pick should not starve a previously successful archetype...probably irrelevant 99% of the time
		archetypes_to_try += fallback_archetype
	for (var/attempted_archetype in archetypes_to_try)
		var/creation_succeeded = FALSE
		switch (attempted_archetype)
			if ("watcher")
				creation_succeeded = src.create_watcher()
			if ("chatter")
				creation_succeeded = src.create_chatter()
			if ("walker")
				creation_succeeded = src.create_walker()
		if (creation_succeeded)
			src.last_archetype = attempted_archetype
			return TRUE
	return FALSE

#undef CREW_APPARITION_LOCATION_ATTEMPTS
#undef CREW_APPARITION_WALK_DESTINATION_ATTEMPTS
#undef CREW_APPARITION_WALK_SEARCH_NODE_CAP
#undef CREW_APPARITION_WALK_SEARCH_DIRECTION_COUNT
#undef CREW_APPARITION_WALK_SEARCH_WORK_CAP
#undef CREW_APPARITION_WALK_DESTINATION_WORK_CAP
#undef CREW_APPARITION_VIEW_RADIUS
#undef CREW_APPARITION_OFFSCREEN_MAX_DISTANCE
#undef CREW_APPARITION_TTL
#undef CREW_APPARITION_WATCHER_TTL
#undef CREW_APPARITION_APPEAR_TIME
#undef CREW_APPARITION_ENCOUNTERS_PER_TICK_CAP
#undef CREW_APPARITION_WATCHER_LINES
#undef CREW_APPARITION_WATCHER_VISIBLE_WAIT
#undef CREW_APPARITION_WATCHER_PHRASE_DELAY
#undef CREW_APPARITION_CHATTER_LINES
#undef CREW_APPARITION_CHATTER_DELAY
#undef CREW_APPARITION_CHATTER_VISIBLE_WAIT
#undef CREW_APPARITION_CHATTER_MAX_DISTANCE
#undef CREW_APPARITION_WALK_DISTANCE_PASSES
#undef CREW_APPARITION_WALK_STEP_DELAY
#undef CREW_APPARITION_WALKER_VISIBLE_WAIT
#undef CREW_APPARITION_WALKER_LINES
