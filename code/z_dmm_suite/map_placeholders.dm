

//-- Map Placeholders ----------------------------------------------------------

//-- Used to store meta data in dmm files --------
/obj/dmm_suite/comment
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "comment"
	invisibility = INVIS_ALWAYS
	anchored = 1
	layer = FLY_LAYER+1
	var/coordinates
	var/dimensions
	INIT()
		. = ..()
		// Must assign at runtime so initial() != runtime when saving
		icon = null
		SPAWN_DBG(1 DECI SECOND)
			qdel(src)

//-- Used in generating turf underlay stacks -----
turf/dmm_suite/underlay
	INIT()
		SHOULD_CALL_PARENT(FALSE)
		qdel(src)

//-- Fills maps when writing with IGNORE_TURFS ---
turf/dmm_suite/clear_turf
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "clear_turf"
	layer = FLY_LAYER
	INIT()
		SHOULD_CALL_PARENT(FALSE)
		qdel(src)
//-- Fills maps when writing with IGNORE_AREAS ---
area/dmm_suite/clear_area
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "clear_area"
	layer = FLY_LAYER
	INIT()
		SHOULD_CALL_PARENT(FALSE)
		qdel(src)
