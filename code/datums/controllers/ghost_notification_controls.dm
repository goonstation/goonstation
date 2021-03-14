// another new system in our spaghetti codebase
// INTENT OF THE SYSTEM: provide notification to ghosts of events that they can click to either observe or sign up as a candidate for
// mostly inspired by TG's ghost notification system
// for people wanting to use this to get a list of ghosts to do a thing:
// 1. make sure that your thing that wants the list is the subject
// 2. implement the following proc on said object
// *****
// receive_ghosts(var/list/ghosts)
// *****
// 3. create a new child datum of the type of notification you want (ie. observe or respawn) so that the blacklist will work properly

// the list will contain a list of mobs that have agreed to whatever you sent the notification about
// please remember that mobs can disappear and be destroyed and logout and logoff at literally any time, so CHECK THE LIST for nulls and empty clients
// a check IS made before the list is passed on but you need to double check still!
// ALSO THE LIST COULD BE COMPLETELY EMPTY, TOO

var/datum/ghost_notification_controller/ghost_notifier
/datum/ghost_notification_controller
	var/list/active_notifications = list() // associative list, key is notification key (timeofday), value is ghost_notification
	var/list/notifications_blacklist = list() // associative list, key is ckey, value is a list of notification PATHS they're not interested in
	var/last_time
	var/chui/window/ghost_notification_config/config_window

/datum/ghost_notification_controller/New()
	..()
	src.last_time = world.timeofday
	src.config_window = new(src)

/datum/ghost_notification_controller/proc/send_notification(var/datum/dispatcher, var/datum/subject, var/datum/ghost_notification/n_type) // the last one is a TYPE field!!!
	if(!dispatcher || !subject || !n_type)
		return
	var/datum/ghost_notification/N = new n_type()
	var/list/to_notify = list()
	N.dispatcher = dispatcher
	N.subject = subject
	N.key = "[world.timeofday]"
	if(!N)
		return // abandon ship alart alart
	for(var/client/C)
		if (!istype(C.mob, /mob/dead/observer))
			continue
		var/mob/dead/observer/O = C.mob
		if(O && N.is_authorised(O))
			// check if this is blacklisted for the round
			if(O.ckey && (O.ckey in notifications_blacklist))
				var/list/blacklist = notifications_blacklist[O.ckey]
				if("[N.type]" in blacklist)
					continue // no notification for this guy
			to_notify |= O
	N.dispatch(to_notify)
	active_notifications[N.key] = N

/datum/ghost_notification_controller/proc/add_notification_to_blacklist(var/mob/M, var/datum/ghost_notification/N)
	if(!M || !M.ckey || !N)
		return
	var/list/blacklist = notifications_blacklist[M.ckey]
	if(!blacklist)
		blacklist = list()
		notifications_blacklist[M.ckey] = blacklist
	blacklist |= "[N.type]"


// invoked by ghost notifications process, which exists, shut up
/datum/ghost_notification_controller/proc/process()
	// get the time elapsed since the last process
	var/current_time = world.timeofday
	var/time_elapsed = 0
	if(current_time < last_time)
		// we've hit midnight rollover, i guess
		time_elapsed = ((current_time + 864000) - last_time) / 10
	else
		time_elapsed = (current_time - last_time) / 10
	last_time = current_time

	// track what notifications we can discard
	var/list/expired_notifications = list()
	for(var/notification_key in src.active_notifications)
		var/datum/ghost_notification/N = src.active_notifications[notification_key]
		if(N)
			N.time_displayed += time_elapsed
			if(N.time_displayed >= N.time_to_display || N.invalid)
				// cancel the notification from being viewed
				expired_notifications |= N.key
				N.expire()

	// remove expired notifications
	for(var/expired_key in expired_notifications)
		src.active_notifications[expired_key] = null

/datum/ghost_notification_controller/proc/invalidate(var/key)
	if(!key || !src.active_notifications[key])
		return // probably already removed
	var/datum/ghost_notification/N = src.active_notifications[key]
	if(!N)
		N.expire()

/datum/ghost_notification_controller/proc/config()
	src.config_window.Subscribe(usr.client)


/////////////////////////////////////////////
// NOTIFICATION PARENT
// Please don't use this root ghost notification datum, use observe, or respawn, or something else more appropriate to your needs
/datum/ghost_notification
	var/time_to_display = 30 // in seconds, how long should this window stay up before it autocloses
	var/time_displayed = 0 // how long the notification's been displayed to all users
	var/dispatched = 0 // has this already been sent out?
	var/invalid = 0 // are responses still valid? do we need to be expunged?
	var/key = ""
	var/category = "dial 911-CODR"
	var/datum/dispatcher
	var/datum/subject // what atom this notification is about or for
	var/list/notified = list()
	var/chui/window/ghost_notification/window

/datum/ghost_notification/proc/dispatch(var/list/toNotify)
	if(src.dispatched)
		return // do not dispatch more than once
	if(length(toNotify))
		src.window = new(src)
		for(var/mob/M in toNotify)
			if(M)
				src.notify(M)
	else
		// we have no one to notify, delete
		src.invalid = 1
	src.dispatched = 1

/datum/ghost_notification/proc/get_notice_body()
	return "help help this is all going wrong TELL CIRR IT WENT WRONG"

/datum/ghost_notification/proc/is_authorised(var/mob/M)
	if(!M)
		return 0 // null can't catch a break
	return 1

/datum/ghost_notification/proc/ignore(var/mob/M)
	if(!M)
		return
	ghost_notifier.add_notification_to_blacklist(M, src)

/datum/ghost_notification/proc/notify(var/mob/M)
	if(!M || !M.client)
		return
	var/client/C = M.client
	if(src.window)
		src.window.Subscribe(C)
		M << sound('sound/effects/ghost2.ogg', volume=100, wait=0)
	src.notified |= M

/datum/ghost_notification/proc/expire()
	if(src.invalid)
		return // we're already dead
	// remove this from the display of all notified
	src.invalid = 1
	for(var/mob/M in notified)
		if(M)
			if(src.window && M.client)
				src.window.Unsubscribe(M.client)

/datum/ghost_notification/proc/respond(var/mob/M)
	if(!subject || !M || src.invalid)
		if(src.window && M.client)
			src.window.Unsubscribe(M.client)
		return 1
	return 0

/////////////////////////////////////////////
// OBSERVE NOTIFICATION
// sends a ghost to observe whatever the data of the notification is
/datum/ghost_notification/observe
	category = "observe"

/datum/ghost_notification/observe/get_notice_body()
	return "Something is happening! Observe [src.subject]?<br>[bicon(src.subject)]"

/datum/ghost_notification/observe/respond(var/mob/M)
	if(..())
		return
	var/mob/dead/observer/O = M
	if(!O)
		return
	if(ismob(subject) || isobj(subject))
		// send the ghost to them to observe
		O.insert_observer(subject)
	else if(isturf(subject))
		O.set_loc(subject)
	else
		// what the fuck are you doing trying to observe a datum??!!!
		boutput(M, "<span class='alert'>You can't observe something that abstract. Please contact a coder, something has gone terribly, terribly wrong.</span>")

/datum/ghost_notification/observe/admin
	category = "admin alert"

/////////////////////////////////////////////
// RESPAWN NOTIFICATION
// adds all responders to a list and then sends the list to the subscriber
/datum/ghost_notification/respawn
	category = "respawn"
	var/respawn_explanation = "something or other"
	var/icon = null
	var/icon_state = ""
	var/list/responders = list()

/datum/ghost_notification/respawn/get_notice_body()
	var/webicon = ""
	if(icon)
		var/image/I = image(icon, icon_state)
		webicon = bicon(I)
	return "Would you like to play as \a [respawn_explanation]?<br>[webicon]"

/datum/ghost_notification/respawn/dispatch(var/list/toNotify)
	..()
	if(src.invalid)
		// let's tell our subscriber we had no one to notify and the ghosts to receive is an empty list
		if(src.subject && hascall(src.subject, "receive_ghosts"))
			src.subject:receive_ghosts(list())

// allow any ghost that isn't DNR by default
/datum/ghost_notification/respawn/is_authorised(var/mob/query)
	if(!..())
		return 0
	return dead_player_list_helper(query) // might as well use convair's dead player selection criteria for consistency
	// SEEING AS I DIDN'T REALISE THE DEAD PLAYER LIST STUFF ALREADY EXISTED, RENDERING THIS WHOLE SYSTEM ENTIRELY POINTLESS

/datum/ghost_notification/respawn/respond(var/mob/M)
	if(..())
		return
	src.responders |= M
	boutput(M, "<span class='notice'>You've been added to the list for selection. Good luck!</span>")

/datum/ghost_notification/respawn/expire()
	..() // close all the windows
	if(src.subject && hascall(src.subject, "receive_ghosts"))
		// validate the list
		var/list/valid_entries = list()
		for(var/mob/M in responders)
			if(is_authorised(M) && M.client)
				valid_entries |= M
		src.subject:receive_ghosts(valid_entries)

/////////////////////////////////////////////
// GHOST NOTIFICATION WINDOW woo chui
// an INCREDIBLY simple "yes, no, ignore" dialogue
/chui/window/ghost_notification
	name = "Ghost Alert!"
	windowSize = "450x200"
	var/noticeBody = ""
	var/datum/ghost_notification/associated

	New(var/datum/ghost_notification/associated)
		..(null) // pass null to our parent because we do NOT have an ATOM that depends on the window being drawn
		src.associated = associated

	GetBody()
		if(!src.associated)
			return "Something has gone terribly wrong. Please call a coder."
		var/ret = "<p style=\"font-size:110%;\"><b>[src.associated.get_notice_body()]</b></p><br/>"
		ret += "[theme.generateButton("respond", "Yes")]"
		ret += "[theme.generateButton("close", "No")]"
		ret += "[theme.generateButton("ignore", "Ignore all [src.associated.category] notices for the round")]"
		return ret

	OnClick( var/client/who, var/id )
		switch(id)
			// close is ignored, all it does is close the window
			if("respond")
				src.associated.respond(who.mob)
			if("ignore")
				src.associated.ignore(who.mob)
		Unsubscribe(who)

/////////////////////////////////////////////
// GHOST NOTIFICATIONS CONTROL WINDOW
// view currently existing ghost notifications, who has responded, and how much time is left
/chui/window/ghost_notification_config
	name = "Ghost Notification Config"
	windowSize = "450x400"
	var/datum/ghost_notification_controller/associated

	New(var/datum/ghost_notification_controller/associated)
		..()
		src.associated = associated

	GetBody()
		if(!src.associated)
			return "The ghost notification controller is dead or something. RIP. The process should handle restarting it."

		// stolen from chemicals.dm
		var/script = {"
		<script type='text/javascript'>
			function removeNotification(key){
				$("#" + key + "-row").fadeOut(300, function(){ $(this).remove(); });
			}
		</script>"}

		var/ret = script
		ret += "<p style=\"font-size:110%;\"><h3>Active Notifications</h3></p><br/>"
		ret += "<table id='notes-table'><thead><tr><th>Key</th><th>Category</th><th>Notice</th><th>Target</th><th>Responders</th><th>Actions</th></tr></thead><tbody>"
		for(var/datum/ghost_notification/N in src.associated.active_notifications)
			ret += "<tr id='[N.key]-row'>"
			ret += "<td>[N.key]</td>"
			ret += "<td>[N.category]</td>"
			ret += "<td>[N.get_notice_body()]</td>"
			ret += "<td>[N.subject]</td>"
			var/responder_list = ""
			ret += "<td>[responder_list]</td>"
			ret += "<td>[theme.generateButton("invalidate-[N.key]", "Invalidate")]</td>"
			ret += "</tr>"
		ret += "</tbody></table>"
		return ret

	OnClick( var/client/who, var/id )
		if(copytext(id, 1, 11) == "invalidate")
			var/key = copytext(id, 12)
			CallJSFunction("removeNotification", list(key))
			src.associated.invalidate(key)
