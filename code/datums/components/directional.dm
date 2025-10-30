/datum/component/directional
	/// The directional offsets ID to use, corresponding to the name of the offsets tuple.
	var/directional_offsets_id = null
	/// Directional offsets behaviour flags. See `_std\macros\directional_offsets.dm`.
	var/flags = 0
	/// The initial x offset that the parent had, prior to any directional offsets.
	var/initial_x_offset = 0
	/// The initial y offset that the parent had, prior to any directional offsets.
	var/initial_y_offset = 0

TYPEINFO(/datum/component/directional)
	initialization_args = list(
		ARG_INFO("directional_offsets_id", DATA_INPUT_TEXT, "The directional offsets ID to use, corresponding to the name of the offsets tuple"),
		ARG_INFO("flags", DATA_INPUT_NUM, "A bitflag that modifies the behaviour of the directional offsets"),
	)

/datum/component/directional/Initialize(directional_offsets_id, flags = 0)
	if (!isatom(src.parent))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	var/atom/A = src.parent
	src.directional_offsets_id = directional_offsets_id
	src.flags = flags

	if (!(src.flags & FORBID_INITIAL_OFFSETS))
		src.initial_x_offset = A.pixel_x - A::pixel_x
		src.initial_y_offset = A.pixel_y - A::pixel_y

	src.RegisterSignal(A, COMSIG_ATOM_DIR_CHANGED, PROC_REF(update_offsets))
	src.update_offsets(A, null, A.dir)
#ifdef CI_RUNTIME_CHECKING
	START_TRACKING
#endif

/datum/component/directional/UnregisterFromParent()
#ifdef CI_RUNTIME_CHECKING
	STOP_TRACKING
#endif
	src.UnregisterSignal(src.parent, COMSIG_ATOM_DIR_CHANGED)
	. = ..()

/datum/component/directional/proc/update_offsets(atom/A, old_dir, new_dir)
	for (var/datum/directional_offsets/offsets as anything in global.directional_offsets_cache.directional_offsets_by_id[src.directional_offsets_id])
		if (!offsets.is_compatible(A, old_dir, new_dir))
			continue

		offsets.apply_offsets(src, A, old_dir, new_dir)
		return
