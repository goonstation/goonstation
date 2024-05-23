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

/obj/item/device/chemicompiler
	name = "sloppy-looking hackjob of a device"
	desc = "you have no earthy idea what this pile of junk could be for."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chemicompiler"
	var/datum/chemicompiler_executor/executor
	HELP_MESSAGE_OVERRIDE({"Chemicompiler information can be found on the wiki "} + EXTERNAL_LINK("https://wiki.ss13.co/ChemiCompiler", "here") + ".")

	New()
		..()
		executor = new(src, /datum/chemicompiler_core/portableCore)
		processing_items += src

	disposing()
		. = ..()
		processing_items -= src

	attack_self(mob/user as mob)
		ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ChemiCompiler", src.name)
			ui.open()

	ui_data(mob/user)
		. = executor.get_ui_data()
		.["theme"] = "syndicate"

	ui_act(action, list/params)
		. = ..()
		if (.)
			return

		return executor.execute_ui_act(action, params)

	process()
		. = ..()
		executor?.on_process()
