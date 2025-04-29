/*
* Stuff that overrides the default byond error handler, so we can print to the error.log in a prettier format
* And also build data for an in-game runtime viewer
*
* It catches all normal runtimes and uncaught exceptions
* It does NOT catch reference bugs
*/

var/global/list/runtimeDetails = null
var/global/runtime_count = 0
var/global/blame_for_runtimes = FALSE

/world/Error(exception/E)
	var/timestamp = time2text(world.timeofday,"hh:mm:ss")
	var/invalid = !istype(E) //what the fuck is this byond
	runtime_count++

	if (!runtimeDetails) CRASH("runtimeDetails list not initialized, how the fuck did this happen?")

	//Save the runtime into our persistent, uh, "storage"
	runtimeDetails["[length(runtimeDetails) + 1]"] = list(
		"name" = !invalid ? E.name : E,
		"file" = !invalid ? E.file : "",
		"line" = !invalid ? E.line : "",
		"desc" = E.desc ? E.desc : "",
		"usr" = usr ? (ismob(usr) ? "[usr] ([usr.ckey])" : "[usr]") : "null",
		"seen" = timestamp,
		"invalid" = invalid
	)

	var/datum/eventRecord/Error/errorEvent = new()
	errorEvent.buildAndSend(E, usr)

	//Output formatted runtime to the usual error.log
#ifndef CI_RUNTIME_CHECKING
	if (invalid)
		world.log << "\[[timestamp]\] Invalid exception in error handler: [E]"
	else
		world.log << "\[[timestamp]\] [E.file],[E.line]: [E.name]"
		if (E.desc)
			world.log << "[E.desc]"
#endif

	//dumb stupid dangerous meme, do not use unless you want to have bad time
	if (blame_for_runtimes && !ON_COOLDOWN(global, "runtime_blame", 1 DECI SECOND)) //cooldown should prevent infinite server crashing loops at least
		if (get_turf(usr))
			new /obj/lightning_target(get_turf(usr))

	// if we're in a fucked up state and generating lots of runtimes we don't want to make the performance of the runtimes even worse
	if(runtime_count < 1000)
		if (istype(usr, /mob))
			usr.unlock_medal("Call 1-800-CODER", 1)


/client/proc/cmd_view_runtimes()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "View Runtimes"
	set desc = "View a detailed list of the runtimes during this round"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!cdn)
		var/list/viewerResources = list(
			"browserassets/src/js/runtimeViewer.js",
			"browserassets/src/css/runtimeViewer.css"
		)
		src.loadResourcesFromList(viewerResources)

	src.Browse(grabResource("html/runtimeViewer.html"), "window=runtimeviewer;size=500x600;title=Runtime+Viewer;", 1)

/client/proc/cmd_aggressive_debugging()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Toggle Aggressive Debugging"
	set desc = "Makes triggering a runtime strike you with lightning. Yes really."
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC
	if (global.blame_for_runtimes)
		global.blame_for_runtimes = FALSE
		boutput(src, SPAN_NOTICE("Aggressive debugging disabled"))
	else
		if (input(src, "Are you sure you want to cause a lightning strike on every runtime? (May cause extreme unforseen consequences) Type YES below if you're sure.", "Really enable aggressive debugging?", "NO") == "YES")
			global.blame_for_runtimes = TRUE

/client/Topic(href, href_list)

	if (href_list["action"] == "getRuntimeData")
		USR_ADMIN_ONLY
		src << output(url_encode(json_encode(runtimeDetails)), "runtimeviewer.browser:refreshRuntimes")

	..()
