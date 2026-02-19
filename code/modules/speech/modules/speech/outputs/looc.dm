/datum/speech_module/output/looc
	id = SPEECH_OUTPUT_LOOC
	channel = SAY_CHANNEL_LOOC
	speech_prefix = SPEECH_PREFIX_LOOC

/datum/speech_module/output/looc/process(datum/say_message/message)
	if (!ismob(message.speaker))
		return

	var/mob/mob_speaker = message.speaker

	if (!mob_speaker.client)
		return

	if (mob_speaker.client.holder)
		return ..()

	if (!mob_speaker.client.authenticated)
		boutput(mob_speaker, "You are not authorised to communicate over these channels.")
		return
	if (oocban_isbanned(mob_speaker))
		boutput(mob_speaker, "You are currently banned from using OOC and LOOC, you may appeal at https://forum.ss13.co/index.php")
		return
	if (!dooc_allowed && (mob_speaker.client.deadchat != 0))
		boutput(mob_speaker, "LOOC for dead mobs has been turned off.")
		return
	if (findtext(message.original_content, "byond://"))
		boutput(mob_speaker, "<B>Advertising other servers is not allowed.</B>")
		logTheThing(LOG_ADMIN, mob_speaker, "has attempted to advertise in LOOC.")
		logTheThing(LOG_DIARY, mob_speaker, "has attempted to advertise in LOOC.", "admin")
		message_admins("[key_name(mob_speaker)] has attempted to advertise in LOOC.")
		return

	. = ..()
