/**
 * tgui process
 *
 * Contains a bit of the tgui process code.
 * Copyright (c) 2020 Aleksej Komarov & ZeWaka (minor porting changes)
 * SPDX-License-Identifier: MIT
 */

var/global/datum/controller/process/tgui/tgui_process

// handles tgui interfaces
/datum/controller/process/tgui

	/// A list of UIs scheduled to process
	var/list/current_run = list()
	/// A list of open UIs
	var/list/open_uis = list()
	/// A list of open UIs, grouped by src_object.
	var/list/open_uis_by_src = list()
	/// The HTML base used for all UIs.
	var/basehtml

	setup()
		name = "tgui"
		schedule_interval = 9 DECI SECONDS
		basehtml = grabResource("tgui/tgui.html") // |GOONSTATION-ADD|
		tgui_process = src

	doWork()
		src.current_run = open_uis.Copy()
		//cache for sanic speed (lists are references anyways)
		var/list/current_run = src.current_run

		while(current_run.len)
			var/datum/tgui/ui = current_run[current_run.len]
			current_run.len--
			if(ui && ui.user && ui.src_object)
				ui.process()
			else
				open_uis.Remove(ui)
			scheck()

	onKill()
		close_all_uis()

	tickDetail()
		boutput(usr, "Open TGUIs:[open_uis.len]")
