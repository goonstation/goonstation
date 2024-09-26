/*
 * tgui process
 *
 * Contains a bit of the tgui process code.
 * Copyright (c) 2020 Aleksej Komarov & ZeWaka (minor porting changes)
 * SPDX-License-Identifier: MIT
 */

var/global/datum/controller/process/tgui/tgui_process

/// handles tgui interfaces
/datum/controller/process/tgui
	/// A list of UIs scheduled to process
	var/list/current_run = list()
	/// A list of all open UIs
	var/list/all_uis = list()
	/// The HTML base used for all UIs.
	var/basehtml
	/// The polyfills uses for all UIs |GOONSTATION-ADD|
	var/polyfill

/datum/controller/process/tgui/setup()
	name = "tgui"
	schedule_interval = 0.9 SECONDS
	try
		basehtml = grabResource("tgui/tgui.html") // |GOONSTATION-CHANGE|
		polyfill = grabResource("tgui/tgui-polyfill.min.js") // |GOONSTATION-CHANGE|
		polyfill = "<script>\n[polyfill]\n</script>"
		setupBaseHtml()
	catch(var/exception/e)
		stack_trace("Unable to load tgui.html, retrying in 10 seconds.\n[e]")
		SPAWN(10 SECONDS)
			basehtml = grabResource("tgui/tgui.html")
			polyfill = grabResource("tgui/tgui-polyfill.min.js")
			polyfill = "<script>\n[polyfill]\n</script>"
			setupBaseHtml()
	global.tgui_process = src

/datum/controller/process/tgui/proc/setupBaseHtml()
	basehtml = replacetextEx(basehtml, "<!-- tgui:inline-polyfill -->", polyfill)

/datum/controller/process/tgui/copyStateFrom(datum/controller/process/target)
	var/datum/controller/process/tgui/old_tgui = target
	src.basehtml = old_tgui.basehtml
	src.current_run = old_tgui.current_run
	src.all_uis = old_tgui.all_uis
	global.tgui_process = src

/datum/controller/process/tgui/doWork()
	src.current_run = all_uis.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run

	while(length(current_run))
		var/datum/tgui/ui = current_run[length(current_run)]
		current_run.len--
		// TODO: Move user/src_object check to process()
		if(ui?.user && ui.src_object)
			ui.process()
		else
			ui.close(FALSE)
		scheck()

/datum/controller/process/tgui/onKill()
	close_all_uis()

/datum/controller/process/tgui/tickDetail()
	boutput(usr, SPAN_ADMIN("Open TGUIs:[all_uis.len]"))
