/client/proc/cmd_admin_create_centcom_report()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Create Command Report"
	ADMIN_ONLY
	SHOW_VERB_DESC
	var/input = input(usr, "Enter the text for the alert. Anything. Serious.", "What?", "") as null|message
	if(!input)
		return
	var/input2 = input(usr, "Add a headline for this alert? leaving this blank creates no headline", "What?", "") as null|text
	var/input3 = input(usr, "Add an origin to the transmission, leaving this blank '[ALERT_CENTCOM]'", "What?", "") as null|text
	if(!input3)
		input3 = ALERT_CENTCOM

	if (alert(src, "Origin: [input3 ? "\"[input3]\"" : "None"]\nHeadline: [input2 ? "\"[input2]\"" : "None"]\nBody: \"[input]\"", "Confirmation", "Send Report", "Cancel") == "Send Report")
		for_by_tcl(C, /obj/machinery/communications_dish)
			C.add_centcom_report(input2, input)

		var/sound_to_play = 'sound/misc/announcement_1.ogg'
		command_alert(input, input2, sound_to_play, alert_origin = input3);

		logTheThing(LOG_ADMIN, src, "has created a command report: [input]")
		logTheThing(LOG_DIARY, src, "has created a command report: [input]", "admin")
		message_admins("[key_name(src)] has created a command report")

/client/proc/cmd_admin_create_advanced_centcom_report()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Adv. Command Report"
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as null|message
	if (!input)
		return
	var/input2 = input(usr, "Add a headline for this alert?", "What?", "") as null|text
	if (alert(src, "Headline: [input2 ? "\"[input2]\"" : "None"] | Body: \"[input]\"", "Confirmation", "Send Report", "Cancel") == "Send Report")
		var/sound_to_play = 'sound/misc/announcement_1.ogg'
		advanced_command_alert(input, input2, sound_to_play);

		logTheThing(LOG_ADMIN, src, "has created an advanced command report: [input]")
		logTheThing(LOG_DIARY, src, "has created an advanced command report: [input]", "admin")
		message_admins("[key_name(src)] has created an advanced command report")

/client/proc/cmd_admin_advanced_centcom_report_help()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Adv. Command Report - Help"
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/T = {"<TT><h1>Advanced Command Report</h1><hr>
	This report works exactly like the normal report, except it sends a tailored message
	to each mob in the world, replacing some values with values applicable to them.
	If you're not planning to use this feature, then I recommend the normal command report as it is
	less demanding on resources.
	<table border=1>
		<tr>
			<td>%name%
			<td>The name of the mob currently viewing the report
		<tr>
			<td>%key%
			<td>The key of the mob currently viewing the report
		<tr>
			<td>%job%
			<td>The job of the mob currently viewing the report
		<tr>
			<td>%area_name%
			<td>The name of the area where the mob currently viewing the report is.
		<tr>
			<td>%srand_name%
			<td>The name of a random player, this is the same for everyone viewing the report.
		<tr>
			<td>%srand_job%
			<td>The job of a random player, this is the same for everyone viewing the report.
		<tr>
			<td>%mrand_name%
			<td>The name of a random player, this is <B>different</B> for everyone viewing the report.
		<tr>
			<td>%mrand_job%
			<td>The job of a random player, this is <B>different</B> for everyone viewing the report.

		</table>"}
	usr.Browse(T, "window=adv_com_help;size=700x500")

//Fancy announcement panel
/client/proc/cmd_admin_command_report_panel()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Command Report Panel"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.command_report_panel ||= new
	src.holder.command_report_panel.ui_interact(src.mob)

/datum/command_report_panel
	///Static list of alert origins that have unique styling
	var/static/list/origin_choices = list(
		ALERT_WATCHFUL_EYE,
		ALERT_EGERIA_PROVIDENCE,
		ALERT_ANOMALY,
		ALERT_WEATHER,
		ALERT_GENERAL,
		ALERT_STATION,
		ALERT_CENTCOM,
		ALERT_DEPARTMENT,
		ALERT_COMMAND,
		ALERT_CLOWN,
		ALERT_SYNDICATE,
	)
	var/origin = ALERT_CENTCOM
	var/header = null
	var/body = null
	var/show_origin = TRUE // I kinda hate that announcements have two procs

	var/sound_to_play = 'sound/misc/announcement_1.ogg'
	var/sound_volume = 100

/datum/command_report_panel/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/command_report_panel/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/command_report_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CommandReportPanel")
		ui.open()

/datum/command_report_panel/ui_data(mob/user)
	. = list(
		"origin" = src.origin,
		"origin_choices" = src.origin_choices,
		"header" = src.header,
		"body" = src.body,
		"show_origin" = src.show_origin,
		"sound_to_play" = src.sound_to_play,
		"sound_volume" = src.sound_volume,
	)

/datum/command_report_panel/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	USR_ADMIN_ONLY
	switch (action)
		if("set_origin")
			src.origin = params["value"]
		if("choose_origin")
			var/input = tgui_input_list(usr, "Choose an origin", "Command Report Panel", src.origin_choices, ALERT_CENTCOM)
			if(input)
				src.origin = input
		if("set_header")
			src.header = params["value"]
		if("set_body")
			src.body = params["value"]
		if("toggle_show_origin")
			src.show_origin = !src.show_origin
		if("set_sound_volume")
			src.sound_volume = clamp(params["volume"], 0, 100)
		if("announce")
			src.announce()
	src.validate_options()

/datum/command_report_panel/proc/announce()
	src.validate_options()

	if(src.show_origin)
		command_alert(src.body, src.header, src.sound_to_play, alert_origin = src.origin)
	else
		command_announcement(src.body, src.header, src.sound_to_play, volume = src.sound_volume, alert_origin = src.origin)

	logTheThing(LOG_ADMIN, usr, "created a command report: [src.origin], [src.header], [src.body]")
	logTheThing(LOG_DIARY, usr, "created a command report: [src.origin], [src.header], [src.body]", "admin")
	message_admins("[key_name(usr)] has created a command report")

/datum/command_report_panel/proc/validate_options()
	src.origin ||= ALERT_CENTCOM
	src.sound_to_play ||= 'sound/misc/announcement_1.ogg'
	if(!isnum_safe(src.sound_volume))
		src.sound_volume = 100
	src.sound_volume = clamp(src.sound_volume, 0, 100)
