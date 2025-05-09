/**
 * Listening post prefab loading, because copy/pasting the changes between every map for every tweak sucks.
 */
TYPEINFO(/datum/mapPrefab/listening_post)
	stored_as_subtypes = TRUE
/datum/mapPrefab/listening_post

/datum/mapPrefab/listening_post/default
	prefabPath = "assets/maps/listening_post/default.dmm"

proc/load_listening_post()
	for_by_tcl(landmark, /obj/landmark/listening_post)
		landmark.apply()

/obj/landmark/listening_post
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "listening_post"
	deleted_on_start = FALSE
	add_to_landmarks = FALSE
	opacity = 1
	invisibility = 0 // To see landmarks if NO_RANDOM_ROOM is defined
	plane = PLANE_FLOOR
	var/prefab_datum = /datum/mapPrefab/listening_post/default

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/apply()
		var/datum/mapPrefab/listening_post/listening_post = new prefab_datum
		listening_post.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "loaded listening post [listening_post.prefabPath]")
		qdel(src)
