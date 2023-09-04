/* Mapping helper parent
 * intended for mapping helpers which do something on an atom on loc and delete themselves such as access spawners
 * if the the orginal location is needed for anything a landmark should be used instead
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

	New()
		..()
		if (current_state >= GAME_STATE_WORLD_INIT)
			SPAWN(0)
				src.initialize()

	initialize()
		..()
#ifdef CHECK_MORE_RUNTIMES
		for(var/obj/mapping_helper/helper in src.loc)
			if(helper.type == src.type && helper != src)
				CRASH("Two or more mapping helpers of type [src.type] found on [x], [y], [z] at area [get_area(src)]")
#endif
		if(src.disposed)
			return
		src.setup()
		qdel(src)

	proc/setup()
		return
