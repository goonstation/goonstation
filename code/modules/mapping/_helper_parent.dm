/* Mapping helper parent
 * intended for mapping helpers which do something on an atom on loc and delete themselves such as access spawners
 * if the orginal location is needed for anything a landmark should be used instead
*/
ABSTRACT_TYPE(/obj/mapping_helper)
/obj/mapping_helper
	name = "mapping helper"
	desc = "Parent for mapping helpers"
	icon = 'icons/effects/mapeditor.dmi'
	mouse_opacity = FALSE
	pass_unstable = FALSE
	anchored = ANCHORED_ALWAYS
	invisibility = INVIS_ALWAYS
	layer = OBJ_LAYER + 1 // yeah let's consistently be above doors
	var/initialised = FALSE
#ifdef CI_RUNTIME_CHECKING
	var/deleted_on_start = FALSE
#else
	var/deleted_on_start = TRUE
#endif

/obj/mapping_helper/New()
	. = ..()
	if (global.current_state >= GAME_STATE_WORLD_INIT)
		SPAWN(0)
			src.initialize()

/obj/mapping_helper/initialize()
	. = ..()
	if (QDELETED(src) || src.initialised)
		return

#ifdef CI_RUNTIME_CHECKING
	var/error = src.setup()
	if (length(error)) // Admits text and lists.
		CI.ERRORS.mapping_helpers += error
#else
	src.setup()
#endif

	src.initialised = TRUE
	if (src.deleted_on_start)
		qdel(src)

/obj/mapping_helper/proc/setup()
	return
