//Fancy announcement panel
/client/proc/cmd_admin_command_report_panel()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Command Report Panel"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.command_report_panel ||= new
	src.holder.command_report_panel.ui_interact(src.mob)

#define TEXT_STYLING_NORMAL "Normal"
#define TEXT_STYLING_ZALGO "Zalgo"
#define TEXT_STYLING_VOID "Void"

#define ADVANCED_REPORT_HELP_TEXT SPAN_NOTICE("**************************************************************<br>\
	[SPAN_BOLD("Advanced Command Report")]<br>\
	This report works exactly like the normal report, except it sends a tailored message\
	to each mob in the world, replacing some values with values applicable to them.<br>\
	If you're not planning to use this feature, then I recommend the normal command report as it is\
	less demanding on resources.<br>\
	%name%	  	  	   	   - The name of the mob currently viewing the report<br>\
	%key%	  	  	   	   - The key of the mob currently viewing the report<br>\
	%job%	  	  	   	   - The job of the mob currently viewing the report<br>\
	%area_name%	  	  	   - The name of the area where the viewer currently is.<br>\
	%srand_name%	  	   - The name of a random player, this is the same for everyone.<br>\
	%srand_job%	 		   - The job of a random player, this is the same for everyone.<br>\
	%mrand_name%	 	   - The name of a random player, this is [SPAN_BOLD("different")] for everyone.<br>\
	%mrand_job%	 	 	   - The job of a random player, this is [SPAN_BOLD("different")] for everyone.<br>\
**************************************************************")

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
		"Unknown Source", //Doesn't have a custom style but Zalgo/Void defaulted to this
	)
	var/show_origin = TRUE // I kinda hate that announcements have two procs
	var/origin = ALERT_CENTCOM

	var/header = null
	var/body = null

	var/text_styling = TEXT_STYLING_NORMAL
	var/send_printout = TRUE
	var/advanced_report = FALSE

	var/static/list/default_announcement_sounds = list(
		'sound/misc/announcement_1.ogg',
		'sound/misc/bingbong.ogg',
		'sound/machines/announcement_clown.ogg',
		'sound/musical_instruments/artifact/Artifact_Eldritch_4.ogg',
		'sound/ambience/spooky/Void_Calls.ogg',
	)
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
		"origin_choices" = src.origin_choices,
		"show_origin" = src.show_origin,
		"origin" = src.origin,
		"header" = src.header,
		"body" = src.body,
		"text_styling" = src.text_styling,
		"text_styling_options" = list(TEXT_STYLING_NORMAL, TEXT_STYLING_ZALGO, TEXT_STYLING_VOID),
		"send_printout" = src.send_printout,
		"advanced_report" = src.advanced_report,
		"sound_to_play" = src.sound_to_play,
		"sound_options" = src.default_announcement_sounds,
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
		if("set_header")
			src.header = params["value"]
		if("set_body")
			src.body = params["value"]
		if("set_sound")
			src.sound_to_play = params["value"]
		if("upload_sound")
			src.sound_to_play = input(usr, "Upload a file:", "File Uploader", null) as null|sound
		if("sync_sound")
			src.sync_sound_to_origin()
		if("set_text_styling")
			src.text_styling = params["value"]
		if("toggle_advanced")
			src.advanced_report = !src.advanced_report
		if("toggle_show_origin")
			src.show_origin = !src.show_origin
		if("toggle_send_printout")
			src.send_printout = !src.send_printout
		if("set_sound_volume")
			src.sound_volume = clamp(params["volume"], 0, 100)
		if("announce")
			src.announce()
		if("advanced_report_help")
			boutput(usr, ADVANCED_REPORT_HELP_TEXT)
	src.validate_options()

/datum/command_report_panel/proc/announce()
	src.validate_options()

	var/header_to_send = src.header
	var/body_to_send = src.body
	if(src.text_styling == TEXT_STYLING_ZALGO)
		header_to_send = zalgoify(header_to_send, rand(0,2), rand(0, 2), rand(0, 2))
		body_to_send = zalgoify(body_to_send, rand(0,2), rand(0, 2), rand(0, 2))
	else if(src.text_styling == TEXT_STYLING_VOID)
		body_to_send = voidSpeak(body_to_send)

	if(src.advanced_report)
		advanced_command_alert(body_to_send, header_to_send, src.sound_to_play, src.origin)
	else if(src.show_origin)
		command_alert(body_to_send, header_to_send, src.sound_to_play, alert_origin = src.origin)
	else
		command_announcement(body_to_send, header_to_send, src.sound_to_play, volume = src.sound_volume, alert_origin = src.origin)

	if(src.send_printout && !src.advanced_report)
		for_by_tcl(comms_dish, /obj/machinery/communications_dish)
			comms_dish.add_centcom_report(src.header, src.body)

	logTheThing(LOG_ADMIN, usr, "created a[src.advanced_report ? "n advanced" : null] command report ([src.text_styling]): [src.origin], [src.header], [src.body]")
	logTheThing(LOG_DIARY, usr, "created a[src.advanced_report ? "n advanced" : null] command report ([src.text_styling]): [src.origin], [src.header], [src.body]", "admin")
	message_admins("[key_name(usr)] has created a[src.advanced_report ? "n advanced" : null] command report")

/datum/command_report_panel/proc/validate_options()
	src.origin ||= ALERT_CENTCOM
	src.sound_to_play ||= 'sound/misc/announcement_1.ogg'
	if(src.advanced_report)
		src.show_origin = TRUE //advanced reports always show the origin
		src.send_printout = FALSE //they change per person so can't be printed
		src.text_styling = TEXT_STYLING_NORMAL //breaks the formatting
	if(!isnum_safe(src.sound_volume) || src.show_origin)
		src.sound_volume = 100
	src.sound_volume = clamp(src.sound_volume, 0, 100)
	tgui_process.update_uis(src)

//Sync to defaults from the announcements
/datum/command_report_panel/proc/sync_sound_to_origin()
	if(src.origin == ALERT_CLOWN) //Comedy precedes the call of the void
		src.sound_to_play = 'sound/machines/announcement_clown.ogg'
		src.sound_volume = 50
	else if(src.text_styling == TEXT_STYLING_ZALGO)
		src.sound_to_play = 'sound/musical_instruments/artifact/Artifact_Eldritch_4.ogg'
	else if(src.text_styling == TEXT_STYLING_VOID)
		src.sound_to_play = 'sound/ambience/spooky/Void_Calls.ogg'
	else if(src.origin == ALERT_DEPARTMENT)
		src.sound_to_play = 'sound/misc/bingbong.ogg'
		src.sound_volume = 70
	else
		src.sound_to_play = 'sound/misc/announcement_1.ogg'
		src.sound_volume = 100
	src.validate_options()

#undef TEXT_STYLING_NORMAL
#undef TEXT_STYLING_ZALGO
#undef TEXT_STYLING_VOID
#undef ADVANCED_REPORT_HELP_TEXT
