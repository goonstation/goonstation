/**
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
	/// A list of open UIs
	var/list/open_uis = list()
	/// A list of open UIs, grouped by src_object.
	var/list/open_uis_by_src = list()
	/// The HTML base used for all UIs.
	var/basehtml
	/// The polyfills uses for all UIs |GOONSTATION-ADD|
	var/polyfill

/datum/controller/process/tgui/setup()
	name = "tgui"
	schedule_interval = 0.9 SECONDS
	try
		basehtml = grabResource("tgui/tgui.html") // |GOONSTATION-ADD|
		polyfill = grabResource("tgui/tgui-polyfill.min.js") // |GOONSTATION-ADD|
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
	src.open_uis = old_tgui.open_uis
	src.open_uis_by_src = old_tgui.open_uis_by_src
	global.tgui_process = src

/datum/controller/process/tgui/doWork()
	src.current_run = open_uis.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run

	while(length(current_run))
		var/datum/tgui/ui = current_run[length(current_run)]
		current_run.len--
		if(ui?.user && ui.src_object)
			ui.process()
		else
			open_uis.Remove(ui)
		scheck()

/datum/controller/process/tgui/onKill()
	close_all_uis()

/datum/controller/process/tgui/tickDetail()
	boutput(usr, SPAN_ADMIN("Open TGUIs:[open_uis.len]"))
