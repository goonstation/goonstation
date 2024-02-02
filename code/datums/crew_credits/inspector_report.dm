#define REPORT_TAB_REPORTS "reports"

/datum/inspectorReport
	var/inspector_report_data
	var/has_contents = FALSE
	var/list/report_data = list()

/datum/inspectorReport/New()
	. = ..()

	src.report_data = list(
		REPORT_TAB_REPORTS = list(),
	)
	src.generate_report_data()

/datum/inspectorReport/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/inspectorReport/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/datum/inspectorReport/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "InspectorReport")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/inspectorReport/ui_static_data(mob/user)
	return src.inspector_report_data

/datum/inspectorReport/proc/generate_report_data()
	for_by_tcl(clipboard, /obj/item/clipboard/with_pen/inspector)
		var/list/pages = list()
		for(var/obj/item/paper/paper in clipboard.contents)
			//ignore blank pages
			if (!paper.info)
				continue
			src.has_contents = TRUE
			pages += list(paper.package_ui_static_data())
		if(length(pages) > 0)
			src.report_data[REPORT_TAB_REPORTS] += list(list(
				"issuer" = "Inspector[clipboard.inspector_name ? " [clipboard.inspector_name]" : ""]'s Report",
				"pages" = pages,
			))

	src.inspector_report_data = list(
		"reports" = src.report_data[REPORT_TAB_REPORTS],
	)
