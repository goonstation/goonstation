// Component defines for complex signals.


// --- Outermost Movable Complex Signals ---

	/// When the outermost movable in the `.loc` chain changes. (thing, old_outermost_movable, new_outermost_movable)
	#define XSIG_OUTERMOST_MOVABLE_CHANGED /datum/xsig/outermost_movable/outermost_changed
	/// When the outermost movable in the `.loc` chain moves to a new z-level. (thing, old_z_level, new_z_level)
	#define XSIG_MOVABLE_Z_CHANGED /datum/xsig/outermost_movable/z_level_changed
	/// When the outermost movable in the `.loc` chain moves to a new area. (thing, old_area, new_area)
	#define XSIG_MOVABLE_AREA_CHANGED /datum/xsig/outermost_movable/area_changed
	/// When the outermost movable in the `.loc` chain moves to a new turf. (thing, old_turf, new_turf)
	#define XSIG_MOVABLE_TURF_CHANGED /datum/xsig/outermost_movable/turf_changed





ALWAYS_ABSTRACT(/datum/xsig)
/**
 *	XSIG datums are non-instantiable paths that are used to store static data relating to the associated XSIG.
 */
/datum/xsig
	/// XSIGs differ from ordinary signals in that when registered to a datum, they also register a component to that datum. This is the type path of that component.
	var/datum/component/complexsignal/component = null
	/// XSIGs also require a unique ID string which will act as an ordinary signal for the registered datum to listen for. This signal will be emitted by the XSIG component.
	var/id = null

/datum/xsig/outermost_movable
	component = /datum/component/complexsignal/outermost_movable
	/// Whether the component should listen for `COMSIG_MOVABLE_MOVED` signals on the outermost movable.
	var/track_movable_moved = FALSE

/datum/xsig/outermost_movable/outermost_changed
	id = "mov_outermost_changed"
	track_movable_moved = FALSE

/datum/xsig/outermost_movable/z_level_changed
	id = "mov_z_level_changed"
	track_movable_moved = FALSE

/datum/xsig/outermost_movable/area_changed
	id = "mov_area_changed"
	track_movable_moved = TRUE

/datum/xsig/outermost_movable/turf_changed
	id = "mov_turf_changed"
	track_movable_moved = TRUE
