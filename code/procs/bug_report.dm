/proc/bug_report_form(mob/user, easteregg_chance=0)
	var/client/user_client = user.client
	var/datum/tgui_bug_report_form/form = new
	form.ui_interact(user)
	UNTIL(form.done || form.closed)
	if (!form.done)
		return
	var/title = form.data["title"]
	var/labels = list()
	for (var/label in form.data["tags"])
		labels += "\[[label]\]"
	var/desc = {"
### Labels

\[BUG\][jointext(labels, " ")]

### Description

[form.data["description"]]

### Steps to reproduce

[form.data["steps"]]

### Expected Behavior

[form.data["expected_behavior"]]

### Additional Information & Screenshots

[form.data["additional"]]

Reported by: [user_client.key]
On server: [global.config.server_name]
Round log date: [global.roundLog_date]
Reported on: [time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")]
Map: [global.map_setting]
"}
	var/success = ircbot.export("issue", list(
		"title" = title,
		"body" = desc,
		"secret" = form.data["secret"],
	))
	if (!form.disposed)
		qdel(form)
	if(success)
		tgui_alert(user_client.mob, "Issue reported!", "Issue reported!")
		if(prob(easteregg_chance))
			var/obj/critter/roach/actual_bug = new(user_client.mob.loc)
			actual_bug.name = title
	else
		tgui_alert(user_client.mob, "There has been an issue with reporting your bug, please try again later!", "Issue not reported!")

/datum/tgui_bug_report_form
	/// Boolean field describing if the bug report form was closed by the user.
	var/closed = FALSE
	/// Boolean field describing if the bug report form was finished and confirmed by the user.
	var/done = FALSE
	/// Data from the bug report form.
	var/data = null

/datum/tgui_bug_report_form/disposing()
	tgui_process.close_uis(src)
	. = ..()

/datum/tgui_bug_report_form/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BugReportForm")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/tgui_bug_report_form/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_bug_report_form/ui_state(mob/user)
	. = tgui_always_state

/datum/tgui_bug_report_form/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("confirm")
			data = params
			tgui_process.close_uis(src)
			done = TRUE
			. = TRUE
		if("cancel")
			tgui_process.close_uis(src)
			closed = TRUE
			. = TRUE
