/// This atom's outermost listener tracker.
/atom/var/datum/outermost_listener_tracker/outermost_listener_tracker

/// Returns this atom's outermost listener tracker. If this atom does not possess an outermost listener tracker, instantiates one.
/atom/proc/ensure_outermost_listener_tracker()
	RETURN_TYPE(/datum/outermost_listener_tracker)
	src.outermost_listener_tracker ||= new(src)
	return src.outermost_listener_tracker


/**
 *	Outermost listener trackers are responsible for handling the logic used to track an atom's outermost listener. They are typically
 *	only required for atoms that speak or listen to a local delimited say channel.
 */
/datum/outermost_listener_tracker
	/// The atom that this outermost listener tracker belongs to.
	var/atom/parent
	/// The current outermost listener of the parent.
	var/atom/outermost_listener
	/// The number of concurrent requests for this outermost listener tracker to be enabled.
	var/track_requests = 0

/datum/outermost_listener_tracker/New(atom/parent)
	. = ..()

	src.parent = parent

	if (isturf(src.parent))
		src.outermost_listener = src.parent
	else
		src.RegisterSignal(src.parent, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(update_outermost_listener))
		src.update_outermost_listener()

/datum/outermost_listener_tracker/disposing()
	src.UnregisterSignal(src.parent, XSIG_OUTERMOST_MOVABLE_CHANGED)
	src.parent.outermost_listener_tracker = null
	src.parent = null

	. = ..()

/// Locates the outermost listener of the parent.
/datum/outermost_listener_tracker/proc/update_outermost_listener()
	// Observers should default to hearing from their target's outermost movable.
	if (istype(src.parent, /mob/dead/target_observer))
		var/mob/dead/target_observer/M = src.parent
		src.outermost_listener = M.target || M
	else
		src.outermost_listener = src.parent

	while (src.loc_open_to_sound())
		src.outermost_listener = src.outermost_listener.loc

/// Determines whether the loc of the outermost listener is open to sound.
/datum/outermost_listener_tracker/proc/loc_open_to_sound()
	if (!src.outermost_listener.loc)
		return FALSE

	if (src.outermost_listener.loc.open_to_sound)
		return TRUE

	// Disgusting, but that is human code for you.
	// Treat humans as open containers if object is in pockets, hands, or belt.
	// Ideally, humans would have two subcontainers; one with `open_to_sound` set to TRUE, the other FALSE.
	if (ishuman(src.outermost_listener.loc))
		var/mob/living/carbon/human/H = src.outermost_listener.loc
		if (H.l_hand == src.outermost_listener)
			return TRUE
		if (H.r_hand == src.outermost_listener)
			return TRUE
		if (H.l_store == src.outermost_listener)
			return TRUE
		if (H.r_store == src.outermost_listener)
			return TRUE
		if (H.belt == src.outermost_listener)
			return TRUE

	return FALSE

/// Add a track request to this outermost listener tracker.
/datum/outermost_listener_tracker/proc/request_track(count = 1)
	src.track_requests += count

/// Remove a track request from this outermost listener tracker.
/datum/outermost_listener_tracker/proc/unrequest_track(count = 1)
	src.track_requests -= count

	if (src.track_requests <= 0)
		qdel(src)
