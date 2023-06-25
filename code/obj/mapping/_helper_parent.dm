/* Mapping helper parent
 * uses /effects/ since it creates an unclickable object
 *
*/
ABSTRACT_TYPE(/obj/effect/map_helper)
/obj/effects/map_helper
	name = "mapping helper"
	desc = "Parent for mapping helpers"
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "access_spawn"
	invisibility = INVIS_ALWAYS
	layer = OBJ_LAYER + 1 // yeah let's consistently be above doors

	New()
		..()
		if (current_state > GAME_STATE_WORLD_INIT)
			SPAWN(5 DECI SECONDS)
				src.setup()
				qdel(src)

	initialize()
		..()
		src.setup()
		qdel(src)

	proc/setup()
		return
