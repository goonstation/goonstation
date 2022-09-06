/**
 * Chemicompiler
 * v1.0 By volundr 9/24/14
 * This device is a programmable chemistry mixing and heating device.
 * The javascript code to run the frontend is in browserassets/js/chemicompiler.min.js
 *   which is minified javascript from browserassets/js/chemicompiler.js
 *   If you make changes to the uncompressed javascript, you'll need to install node.js,
 *   and run `npm install -g uglify-js`
 *   then run `uglifyjs browserassets/js/chemicompiler.js -c > browserassets/js/chemicompiler.min.js` to rebuild the compressed version.
 */
/datum/chemicompiler_core/portableCore
	maxReservoir = 6

/obj/item/device/chemicompiler/
	name = "sloppy-looking hackjob of a device"
	desc = "you have no earthy idea what this pile of junk could be for."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chemicompiler"
	var/datum/chemicompiler_executor/executor

	New()
		..()
		executor = new(src, /datum/chemicompiler_core/portableCore)
		processing_items += src

	disposing()
		. = ..()
		processing_items -= src

	attack_self(mob/user as mob)
		executor.panel()

	proc/topicPermissionCheck(action)
		if(src.loc != usr)
			return 0
		if(executor.core.running)
			return action in list("getUIState", "reportError", "abortCode")
		return 1

	process()
		. = ..()
		executor?.on_process()
