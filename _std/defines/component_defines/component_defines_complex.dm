// Component defines for complex signals.
// Standard XSIG structure: (component_type, signal_name)


// --- Outermost Movable Complex Signals ---

	// Structure: (component_type, signal_name, track_movable_moved)

	/// When the outermost movable in the `.loc` chain changes. (thing, old_outermost_movable, new_outermost_movable)
	#define XSIG_OUTERMOST_MOVABLE_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_outermost_changed", FALSE)
	/// When the outermost movable in the `.loc` chain moves to a new z-level. (thing, old_z_level, new_z_level)
	#define XSIG_MOVABLE_Z_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_z_level_changed", FALSE)
	/// When the outermost movable in the `.loc` chain moves to a new area. (thing, old_area, new_area)
	#define XSIG_MOVABLE_AREA_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_area_changed", TRUE)

	/// When the outermost movable in the `.loc` chain moves to a new turf. (thing, old_turf, new_turf)
	#define XSIG_MOVABLE_TURF_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_turf_changed", TRUE)
	/// When the outermost movable in the `.loc` chain moves to a new turf, provided both the old and new turfs exist. (thing, old_turf, new_turf)
	#define XSIG_MOVABLE_TURF_CHANGED_SAFE list(/datum/component/complexsignal/outermost_movable, "mov_turf_changed_safe", TRUE)
	/// When the outermost movable in the `.loc` chain moves from a turf to nullspace. (thing, old_turf)
	#define XSIG_MOVABLE_TURF_TO_NULLSPACE list(/datum/component/complexsignal/outermost_movable, "mov_turf_to_nullspace", TRUE)
	/// When the outermost movable in the `.loc` chain moves from nullspace to a turf. (thing, new_turf)
	#define XSIG_MOVABLE_NULLSPACE_TO_TURF list(/datum/component/complexsignal/outermost_movable, "mov_nullspace_to_turf", TRUE)
