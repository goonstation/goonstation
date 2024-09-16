#define STATE_DEFAULT 1
#define STATE_CALLSHUTTLE 2
#define STATE_CANCELSHUTTLE 3
#define STATE_MESSAGELIST 4
#define STATE_VIEWMESSAGE 5
#define STATE_DELMESSAGE 6
#define STATE_STATUSDISPLAY 7

// The communications computer

/obj/machinery/computer/communications
	name = "communications console"
	icon_state = "comm"
	req_access = list(access_heads)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	machine_registry_idx = MACHINES_COMMSCONSOLES
	circuit_type = /obj/item/circuitboard/communications
	var/prints_intercept = 1
	var/authenticated = 0
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT

	var/status_display_freq = FREQ_STATUS_DISPLAY
	var/stat_msg1
	var/stat_msg2
	desc = "A computer that allows one to call and recall the emergency shuttle, as well as receive messages from Centcom."

	light_r =0.6
	light_g = 1
	light_b = 0.1

	New()
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, null, status_display_freq)

/obj/machinery/computer/communications/special_deconstruct(obj/computerframe/frame as obj)
	if(src.status & BROKEN)
		logTheThing(LOG_STATION, usr, "disassembles [src] (broken) [log_loc(src)]")
	else
		logTheThing(LOG_STATION, usr, "disassembles [src] [log_loc(src)]")


/obj/machinery/computer/communications/process()
	..()
	if(state != STATE_STATUSDISPLAY)
		src.updateDialog()

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)

	if(!href_list["operation"] || (dd_hasprefix(href_list["operation"], "ai-") && !issilicon(usr) && !isAI(usr)))
		return
	switch(href_list["operation"])
		// main interface
		if("main")
			src.state = STATE_DEFAULT
		if("login")
			var/mob/M = usr
			var/obj/item/card/id/I = M.equipped()
			if (I && istype(I))
				if(src.check_access(I))
					authenticated = 1
		if("logout")
			authenticated = 0
		if("nolockdown")
			disablelockdown(usr)
			post_status("alert", "default")
		if("call-prison")
			call_prison_shuttle(usr)
		if("callshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CALLSHUTTLE
		if("callshuttle2")
			if(src.authenticated)
				call_shuttle_proc(usr)

				if(emergency_shuttle.online)
					post_status("shuttle")

			src.state = STATE_DEFAULT
		if("cancelshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CANCELSHUTTLE
		if("cancelshuttle2")
			if(src.authenticated)
				cancel_call_proc(usr)
			src.state = STATE_DEFAULT
		if("messagelist")
			src.currmsg = 0
			src.state = STATE_MESSAGELIST
		if("viewmessage")
			src.state = STATE_VIEWMESSAGE
			if (!src.currmsg)
				if(href_list["message-num"])
					src.currmsg = text2num_safe(href_list["message-num"])
				else
					src.state = STATE_MESSAGELIST
		if("delmessage")
			src.state = (src.currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("delmessage2")
			if(src.authenticated)
				if(src.currmsg)
					var/title = src.messagetitle[src.currmsg]
					var/text  = src.messagetext[src.currmsg]
					src.messagetitle.Remove(title)
					src.messagetext.Remove(text)
					if(src.currmsg == src.aicurrmsg)
						src.aicurrmsg = 0
					src.currmsg = 0
				src.state = STATE_MESSAGELIST
			else
				src.state = STATE_VIEWMESSAGE
		if("status")
			src.state = STATE_STATUSDISPLAY

		// Status display stuff
		if("setstat")
			switch(href_list["statdisp"])
				if(STATUS_DISPLAY_PACKET_MODE_MESSAGE)
					post_status(STATUS_DISPLAY_PACKET_MODE_MESSAGE, stat_msg1, stat_msg2)
				if(STATUS_DISPLAY_PACKET_MODE_DISPLAY_ALERT)
					post_status(STATUS_DISPLAY_PACKET_MODE_DISPLAY_ALERT, href_list["alert"])
				else
					post_status(href_list["statdisp"])

		if(STATUS_DISPLAY_PACKET_MESSAGE_TEXT_1)
			stat_msg1 = input("Line 1", "Enter Message Text", stat_msg1) as text|null
			stat_msg1 = copytext(adminscrub(stat_msg1), 1, MAX_MESSAGE_LEN)
			src.updateDialog()
		if(STATUS_DISPLAY_PACKET_MESSAGE_TEXT_2)
			stat_msg2 = input("Line 2", "Enter Message Text", stat_msg2) as text|null
			stat_msg2 = copytext(adminscrub(stat_msg2), 1, MAX_MESSAGE_LEN)
			src.updateDialog()

		// AI interface
		if("ai-main")
			src.aicurrmsg = 0
			src.aistate = STATE_DEFAULT
		if("ai-callshuttle")
			src.aistate = STATE_CALLSHUTTLE
		if("ai-callshuttle2")
			call_shuttle_proc(usr)
			src.aistate = STATE_DEFAULT
		if("ai-messagelist")
			src.aicurrmsg = 0
			src.aistate = STATE_MESSAGELIST
		if("ai-viewmessage")
			src.aistate = STATE_VIEWMESSAGE
			if (!src.aicurrmsg)
				if(href_list["message-num"])
					src.aicurrmsg = text2num_safe(href_list["message-num"])
				else
					src.aistate = STATE_MESSAGELIST
		if("ai-delmessage")
			src.aistate = (src.aicurrmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("ai-delmessage2")
			if(src.aicurrmsg)
				var/title = src.messagetitle[src.aicurrmsg]
				var/text  = src.messagetext[src.aicurrmsg]
				src.messagetitle.Remove(title)
				src.messagetext.Remove(text)
				if(src.currmsg == src.aicurrmsg)
					src.currmsg = 0
				src.aicurrmsg = 0
			src.aistate = STATE_MESSAGELIST
		if("ai-status")
			src.aistate = STATE_STATUSDISPLAY
	src.updateUsrDialog()

/proc/disablelockdown(var/mob/usr)
	boutput(world, SPAN_ALERT("Lockdown cancelled by [usr.name]!"))

	for(var/obj/machinery/firealarm/FA as anything in machine_registry[MACHINES_FIREALARMS]) //deactivate firealarms
		SPAWN(0)
			if(FA.lockdownbyai == 1)
				FA.lockdownbyai = 0
				FA.reset()
	for_by_tcl(AL, /obj/machinery/door/airlock) //open airlocks
		SPAWN(0)
			if(AL.canAIControl() && AL.lockdownbyai == 1)
				AL.open()
				AL.lockdownbyai = 0

/obj/machinery/computer/communications/attack_hand(var/mob/user)
	if(..())
		return

	src.add_dialog(user)
	var/list/dat = list("<head><title>Communications Console</title></head><body>")
	if (emergency_shuttle.online && emergency_shuttle.location == SHUTTLE_LOC_CENTCOM)
		var/timeleft = emergency_shuttle.timeleft()
		dat += "<B>Emergency shuttle</B><br><BR><br>ETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]<BR>"

	if (issilicon(user) || isAI(user))
		var/dat2 = src.interact_ai(user) // give the AI a different interact proc to limit its access
		if(dat2)
			dat +=  dat2
			user.Browse(dat.Join(), "window=communications;size=400x500")
			onclose(user, "communications")
		return

	switch(src.state)
		if(STATE_DEFAULT)
			if (src.authenticated)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Log Out</A> \]"
//				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=call-prison'>Send Prison Shutle</A> \]"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=nolockdown'>Disable Lockdown</A> \]"
				if(emergency_shuttle.location == SHUTTLE_LOC_CENTCOM)
					if (emergency_shuttle.online)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=cancelshuttle'>Cancel Shuttle Call</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=callshuttle'>Call Emergency Shuttle</A> \]"

				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=status'>Set Status Display</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>Log In</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=messagelist'>Message List</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
		if(STATE_CANCELSHUTTLE)
			dat += "Are you sure you want to cancel the shuttle? \[ <A HREF='?src=\ref[src];operation=cancelshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.currmsg)
				dat += "<B>[src.messagetitle[src.currmsg]]</B><BR><BR>[src.messagetext[src.currmsg]]"
				if (src.authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete \]"
			else
				src.state = STATE_MESSAGELIST
				src.Attackhand(user)
				return
		if(STATE_DELMESSAGE)
			if (src.currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				src.state = STATE_MESSAGELIST
				src.Attackhand(user)
				return
		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"


	dat += "<BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?action=mach_close&window=communications'>Close</A> \]"
	user.Browse(dat.Join(), "window=communications;size=400x500")
	onclose(user, "communications")

/obj/machinery/computer/communications/proc/interact_ai(var/mob/living/silicon/ai/user as mob)
	var/dat = ""
	switch(src.aistate)
		if(STATE_DEFAULT)
			if(emergency_shuttle.location == SHUTTLE_LOC_CENTCOM && !emergency_shuttle.online)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-callshuttle'>Call Emergency Shuttle</A> \]"
//			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=call-prison'>Send Prison Shutle</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-messagelist'>Message List</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=nolockdown'>Disable Lockdown</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-status'>Set Status Display</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=ai-callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=ai-viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.aicurrmsg)
				dat += "<B>[src.messagetitle[src.aicurrmsg]]</B><BR><BR>[src.messagetext[src.aicurrmsg]]"
				dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=ai-delmessage'>Delete</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.Attackhand(user)
				return null
		if(STATE_DELMESSAGE)
			if(src.aicurrmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=ai-delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.Attackhand(user)
				return

		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"


	dat += "<BR>\[ [(src.aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?action=mach_close&window=communications'>Close</A> \]"
	return dat

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

	// hack to display shuttle timer
	if(emergency_shuttle.online)
		var/obj/machinery/computer/communications/C = locate() in machine_registry[MACHINES_COMMSCONSOLES]
		if(C)
			C.post_status("shuttle")

/proc/call_prison_shuttle(var/mob/usr)
	if ((!(ticker && ticker.mode) || emergency_shuttle.location == SHUTTLE_LOC_STATION))
		return
	/*if(istype(ticker.mode, /datum/game_mode/sandbox))
		boutput(usr, "Under directive 7-10, [station_name()] is quarantined until further notice.")
		return*/
	if(istype(ticker.mode, /datum/game_mode/revolution))
		boutput(usr, "Centcom will not allow the shuttle to be called.")
		return
	return


/proc/enable_prison_shuttle(var/mob/user)
	return

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
	command_announcement(call_reason + "<br><b>[SPAN_ALERT("It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")]</b>", "The Emergency Shuttle Has Been Called", css_class = "notice")
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

	boutput(world, SPAN_NOTICE("<B>Alert: The shuttle is going back!</B>")) //marker4

	logTheThing(LOG_STATION, user, "recalled the Emergency Shuttle")
	message_admins(SPAN_INTERNAL("[key_name(user)] recalled the Emergency Shuttle"))
	emergency_shuttle.recall()

	return 0

/obj/machinery/computer/communications/proc/post_status(var/command, var/data1, var/data2)
	var/datum/signal/status_signal = get_free_signal()
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command
	status_signal.data["address_tag"] = "STATDISPLAY"

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, status_signal, null, status_display_freq)



	/*
		receive_signal(datum/signal/signal)

		switch(signal.data["command"])
			if("blank")
				mode = 0

			if("shuttle")
				mode = 1

			if("message")
				set_message(signal.data["msg1"], signal.data["msg2"])

			if("alert")
				set_picture(signal.data["picture_state"])
*/

#undef STATE_DEFAULT
#undef STATE_CALLSHUTTLE
#undef STATE_CANCELSHUTTLE
#undef STATE_MESSAGELIST
#undef STATE_VIEWMESSAGE
#undef STATE_DELMESSAGE
#undef STATE_STATUSDISPLAY
