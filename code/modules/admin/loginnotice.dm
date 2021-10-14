// Based roughly off of viewing notes.
/datum/admins/proc/setLoginNotice(var/target_key)
	target_key = ckey(target_key)

	if (!target_key)
		return

	// no fake admins
	if (src.tempmin)
		logTheThing("admin", src.owner, target_key, "tried to change the login notice of [constructTarget(target_key,"admin")]")
		logTheThing("diary", src.owner, target_key, "tried to change the login notice of [constructTarget(target_key,"diary")]", "admin")
		alert("You need to be an actual admin to view login notices.")
		return

	// get their cloud data.
	// this forces an update of the cloud data, to make sure it's fresh
	// god forbid someone update it on server 4 and then overwrites it on server 1
	var/datum/player/player = make_player(target_key)
	player.cloud_fetch()

	// get the current notice (if anything)
	var/message = player.cloud_get("login_notice")

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
		if (!player.cloud_put("login_notice", null))
			tgui_alert(src.owner.mob, "ERROR: Failed to clear login notice to cloud for [target_key].")
			return
		addPlayerNote(target_key, src.owner.ckey + " (AUTO)", "Cleared the previous login notice.")
		return


	// otherwise, we have a new message to save
	// yes it is using the log date. no i don't care
	var/message_text = "Message from Admin [src.owner.ckey] at [roundLog_date]:\n\n[new_message]"
	if (!player.cloud_put("login_notice", message_text))
		input(src.owner.mob, "** ERROR SAVING LOGIN MESSAGE **\nYou can copy it from here to retry later:", "Login Notice", message) as null|message
		return

	// New note saved, usual player notes bookkeeping
	addPlayerNote(target_key, src.owner.ckey + " (AUTO)", "New login notice set:\n\n[message_text]")
	tgui_alert(src.owner.mob, "Login notice for '[target_key]' has been set. They should see it next time they connect.")


/// Returns 1 if a login message is pending, 0 otherwise
/client/proc/has_login_notice_pending(var/show_again = 0)
	if (!src.player.cloud_available())
		return

	var/message = src.player.cloud_get("login_notice")
	if (message && show_again)
		src.show_login_notice()

	return !!message

/// Shows a login notice, if one exists
/client/proc/show_login_notice()

	// If the cloud isn't available then, welp.
	if (!src.player.cloud_available())
		return

	var/message = src.player.cloud_get("login_notice")

	if (message)
		src << csound("sound/voice/bfreeze.ogg")

		var/login_notice_html = {"
						<!doctype html>
						<html>
							<head>
								<title>Admin Alert!!!</title>
								<style>
									h1 { font-color:#F00; }
									body, h1 { font-family: Verdana; }
								</style>
							</head>
							<body>
								<h1>Admin Notice</h1>
								<p><strong>You need to read and acknowledge this message to play.
								<br>If you need to communicate with an admin, please adminhelp or post on the forums.</strong></p>
								<hr>
								<p style='white-space: pre-wrap;'>[message]</p>
								<hr>
								<p><a href="?src=\ref[src];action=loginnotice_ack">Acknowledge Message</a></p>
							</body>
						</html>
					"}
		src.mob.Browse(login_notice_html, "window=loginnotice")
		boutput(src, "<span class='warning'>You have a pending login notice! You must acknowledge it before you can play!</span>")

/client/proc/acknowledge_login_notice()
	// This literally should not be possible but you know how it is
	if (!src.player.cloud_available())
		return

	var/message = src.player.cloud_get("login_notice")
	if (message)
		if (!player.cloud_put("login_notice", null))
			tgui_alert(src.mob, "ERROR: Failed to clear login notice for some reason...")
			return

		addPlayerNote(src.ckey, "(AUTO)", "Acknowledged their login notice.")
		src.mob.Browse(null, "window=loginnotice")
		src << csound("sound/machines/futurebuddy_beep.ogg")
		alert("You have acknowledged the admin notice and can now play.")

