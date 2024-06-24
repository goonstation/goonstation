// Based roughly off of viewing notes.
/datum/admins/proc/setLoginNotice(var/target_key)
	target_key = ckey(target_key)

	if (!target_key)
		return

	// no fake admins
	if (src.tempmin)
		logTheThing(LOG_ADMIN, src.owner, "tried to change the login notice of [constructTarget(target_key,"admin")]")
		logTheThing(LOG_DIARY, src.owner, "tried to change the login notice of [constructTarget(target_key,"diary")]", "admin")
		alert("You need to be an actual admin to view login notices.")
		return

	// get their cloud data.
	// this forces an update of the cloud data, to make sure it's fresh
	// god forbid someone update it on server 4 and then overwrites it on server 1
	var/datum/player/player = make_player(target_key)
	player.cloudSaves.fetch()

	// get the current notice (if anything)
	var/message = player.cloudSaves.getData("login_notice")

	if (message)
		alert("This player already has a login notice set. You can modify it in the next window. To delete it, blank the text and hit OK.")

	// i sure hope input() returns null and not "" if you hit ok in an empty textbox!
	var/new_message = input(src.owner.mob, "Message to be displayed on next login:", "Login Notice", message) as null|message

	// if it's the same as the current message, or null,
	// assume nothing changed and just skip
	if (isnull(new_message) || new_message == message)
		alert("Message editing aborted. Nothing has been changed.")
		return

	// if there's no new message but there WAS one, we're deleting the current set one
	if (!new_message && message)
		if (!player.cloudSaves.deleteData("login_notice"))
			tgui_alert(src.owner.mob, "ERROR: Failed to clear login notice to cloud for [target_key].")
			return
		addPlayerNote(target_key, src.owner.ckey, "Cleared the previous login notice.")
		return


	// otherwise, we have a new message to save
	// yes it is using the log date. no i don't care
	var/message_text = "Message from Admin [src.owner.ckey] at [roundLog_date]:\n[new_message]"
	if (!player.cloudSaves.putData("login_notice", message_text))
		input(src.owner.mob, "** ERROR SAVING LOGIN MESSAGE **\nYou can copy it from here to retry later:", "Login Notice", message) as null|message
		return

	// New note saved, usual player notes bookkeeping
	addPlayerNote(target_key, src.owner.ckey, "New login notice set:\n[message_text]")
	message_admins(SPAN_INTERNAL("[key_name(src.owner.mob)] added a login notice for <a href='?src=%admin_ref%;action=notes&target=[target_key]'>[target_key]</A>:<br><div style='whitespace: pre-wrap;'>[message_text]</div>"))
	tgui_alert(src.owner.mob, "Login notice for '[target_key]' has been set. They should see it next time they connect.")

	ircbot.export_async("admin", list(
		"key" = src.owner.ckey,
		"name" = src.owner.mob.name,
		"msg" = "added an admin notice for `[target_key]`:\n[message_text]"))


/// Returns 1 if a login message is pending, 0 otherwise
/client/proc/has_login_notice_pending(var/show_again = 0)
	var/message = src.player.cloudSaves.getData("login_notice")
	if (message && show_again)
		src.show_login_notice()

	return !!message

/// Shows a login notice, if one exists
/client/proc/show_login_notice()
	var/message = src.player.cloudSaves.getData("login_notice")

	if (message)
		src << csound('sound/voice/bfreeze.ogg')

		var/login_notice_html = {"
						<!doctype html>
						<html>
							<head>
								<title>Admin Alert!!!</title>
								<style>
									h1 { font-color:#F00; text-align: center; border-bottom: 1px solid red; padding: 0.25em; }
									body, h1 { font-family: Verdana; }
									.c { text-align: center; }
									.a { display: inline-block; text-align: center; padding: 0.25em 1em; border: 2px solid black; background: #2a2; color: #fff; }
									.a:hover { border: 2px solid #141; background: #5c5; color: #fff; }
								</style>
							</head>
							<body>
								<h1>Admin Notice</h1>
								<p class="c"><strong>You need to read and acknowledge this message to play.</strong></p>
								<p>If you need to talk with an admin, please <a href="byond://winset?command=adminhelp">Adminhelp</a> or post on the <a href="https://forums.ss13.co/" target="_blank">forums</a>.</strong></p>
								<hr>
								<p style='white-space: pre-wrap;'>[message]</p>
								<hr>
								<p class='c'><a class='a' href="?src=\ref[src];action=loginnotice_ack">Acknowledge Message</a></p>
							</body>
						</html>
					"}
		src.mob.Browse(login_notice_html, "window=loginnotice;size=600x400")
		boutput(src, SPAN_ALERT("You have a pending login notice! You must acknowledge it before you can play!"))

/client/proc/acknowledge_login_notice()
	var/message = src.player.cloudSaves.getData("login_notice")
	if (message)
		if (!player.cloudSaves.deleteData("login_notice"))
			tgui_alert(src.mob, "ERROR: Failed to clear login notice for some reason...")
			return

		message_admins(SPAN_INTERNAL("[src.ckey] acknowledged their login notice."))
		addPlayerNote(src.ckey, "bot", "Acknowledged their login notice.")
		src.mob.Browse(null, "window=loginnotice")
		src << csound('sound/machines/futurebuddy_beep.ogg')
		alert("You have acknowledged the admin notice and can now play.")
		ircbot.export_async("admin", list(
			"key" = src.ckey,
			"name" = src.mob.name,
			"msg" = "Acknowledged their admin notice."))

