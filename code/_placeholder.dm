
/* This file is intended to provide placeholder paths.
 * These objects are not in this codebase, but the paths are present on maps.
 */
/obj/item/device/audio_log/ht_1
/obj/item/device/audio_log/ht_2
/obj/item/device/audio_log/ht_3
/obj/item/paper/grillnasium/fartnasium_recruitment/flyer

/** Placeholder Spawner
 *  Spawns a designated atom/movable at it's location upon creation
 */
/obj/placeholder
	name = "Placeholder Object"
	var/spawn_path = "/obj/item/space_thing" //Cardinal sin (can runtime), but will enable paths that don't exist to be used

	New(turf/loc)
		..()
		#ifdef SECRETS_ENABLED
		new spawn_path(loc)
		#endif
		qdel(src)
