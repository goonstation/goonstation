/mob/living/silicon/ai/proc/ai_call_shuttle()
	set category = "AI Commands"
	set name = "Call Emergency Shuttle"

	var/call_reason = tgui_input_text(usr, "Please state the nature of your current emergency.", "Emergency Shuttle Call Reason", allowEmpty = TRUE)

	if (isnull(call_reason)) // Cancel
		return
	if(isdead(src))
		boutput(usr, "You can't call the shuttle because you are dead!")
		return
	if(get_z(src) != Z_LEVEL_STATION)
		src.show_text("Your mainframe was unable relay this command that far away!", "red")
		return

	if (emergency_shuttle.online)
		boutput(usr, SPAN_ALERT("The emergency shuttle is currently in flight!"))
		return

	logTheThing(LOG_ADMIN, usr,  "called the Emergency Shuttle (reason: [call_reason])")
	logTheThing(LOG_DIARY, usr, "called the Emergency Shuttle (reason: [call_reason])", "admin")
	message_admins(SPAN_INTERNAL("[key_name(usr)] called the Emergency Shuttle to the station"))
	call_shuttle_proc(usr, call_reason)
/proc/call_shuttle_proc(var/mob/user, var/call_reason)
	if ((!( ticker ) || emergency_shuttle.location))
		return 1

	if(world.time/10 < 600)
		boutput(user, "Centcom will not allow the shuttle to be called.")
		return 1
	/*if(istype(ticker.mode, /datum/game_mode/sandbox))
		boutput(user, "Under directive 7-10, [station_name()] is quarantined until further notice.")
		return 1*/
	if(emergency_shuttle.disabled)
		boutput(user, "Centcom will not allow the shuttle to be called.")
		return 1
	if (signal_loss >= 75)
		boutput(user, SPAN_ALERT("Severe signal interference is preventing contact with the Emergency Shuttle."))
		return 1

	// sanitize the reason
	if(call_reason)
		call_reason = copytext(html_decode(trimtext(strip_html(html_decode(call_reason)))), 1, 140)
	if(!call_reason || length(call_reason) < 1)
		call_reason = "No reason given."

	message_admins(SPAN_INTERNAL("[key_name(user)] called the Emergency Shuttle to the station"))
	logTheThing(LOG_STATION, null, "[key_name(user)] called the Emergency Shuttle to the station")

	emergency_shuttle.incall()
	command_announcement(call_reason + "<br><b>[SPAN_ALERT("It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")]</b>", "The Emergency Shuttle Has Been Called", alert_origin=ALERT_COMMAND)
	return 0

/proc/cancel_call_proc(var/mob/user)
	if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0 || emergency_shuttle.timeleft() < (SHUTTLEARRIVETIME / 3) ))
		return 1

	if (!emergency_shuttle.can_recall)
		boutput(user, SPAN_ALERT("Centcom will not allow the shuttle to be recalled."))
		return 1

	if (signal_loss >= 75)
		boutput(user, SPAN_ALERT("Severe signal interference is preventing contact with the Emergency Shuttle."))
		return 1

	command_announcement("<b>[SPAN_ALERT("Alert: The shuttle is going back!")]</b>", "Emergency Shuttle Recall", alert_origin=ALERT_COMMAND)

	logTheThing(LOG_STATION, user, "recalled the Emergency Shuttle")
	message_admins(SPAN_INTERNAL("[key_name(user)] recalled the Emergency Shuttle"))
	emergency_shuttle.recall()

	return 0
