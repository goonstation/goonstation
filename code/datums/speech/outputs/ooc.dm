TYPEINFO(/datum/speech_module/output/ooc)
	id = "ooc"
/datum/speech_module/output/ooc
	id = "ooc"
	channel = SAY_CHANNEL_OOC
	var/my_prefix = ":ooc"
	priority = INFINITY //always top priority

	process(datum/say_message/message)
		if(message.prefix != src.my_prefix)
			return FALSE

		message.flags |= SAYFLAG_NO_MAPTEXT
		. = TRUE //Always consume the message here. If it's for OOC, it's not for anything else.
		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
			if (IsGuestKey(mob_speaker.key))
				boutput(src, "You are not authorized to communicate over these channels.")
				return
			if (oocban_isbanned(mob_speaker))
				boutput(src, "You are currently banned from using OOC and LOOC, you may appeal at https://forum.ss13.co/index.php")
				return


			if (!mob_speaker.client?.preferences?.listen_ooc)
				return
			if (!ooc_allowed && !mob_speaker.client?.holder)
				boutput(mob_speaker, "OOC is currently disabled. For gameplay questions, try <a href='byond://winset?command=mentorhelp'>mentorhelp</a>.")
				return
			if (!dooc_allowed && !mob_speaker.client?.holder && (mob_speaker.client?.deadchat != 0))
				boutput(mob_speaker, "OOC for dead mobs has been turned off.")
				return
			if (findtext(message.orig_message, "byond://") && !mob_speaker.client?.holder)
				boutput(src, "<B>Advertising other servers is not allowed.</B>")
				logTheThing(LOG_ADMIN, src, "has attempted to advertise in OOC.")
				logTheThing(LOG_DIARY, src, "has attempted to advertise in OOC.", "admin")
				message_admins("[key_name(src)] has attempted to advertise in OOC.")
				return

		logTheThing(LOG_DIARY, message.speaker, ": [message.content]", "ooc")
		phrase_log.log_phrase("ooc", message.content)

#ifdef DATALOGGER
		game_stats.ScanText(message.content)
#endif
		..()
		return

TYPEINFO(/datum/speech_module/output/looc)
	id = "looc"
/datum/speech_module/output/looc
	id = "looc"
	channel = SAY_CHANNEL_LOOC
	var/my_prefix = ":looc"
	priority = INFINITY //always top priority

	process(datum/say_message/message)
		if(message.prefix != src.my_prefix)
			return FALSE
		//LOOC gets maptext
		. = TRUE //Always consume the message here. If it's for OOC, it's not for anything else.
		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
			if (IsGuestKey(mob_speaker.key))
				boutput(src, "You are not authorized to communicate over these channels.")
				return
			if (oocban_isbanned(mob_speaker))
				boutput(src, "You are currently banned from using OOC and LOOC, you may appeal at https://forum.ss13.co/index.php")
				return

			if (!mob_speaker.client?.preferences?.listen_looc)
				return
			if (!looc_allowed && !mob_speaker.client?.holder)
				boutput(mob_speaker, "LOOC is currently disabled. For gameplay questions, try <a href='byond://winset?command=mentorhelp'>mentorhelp</a>.")
				return
			if (!dooc_allowed && !mob_speaker.client?.holder && (mob_speaker.client?.deadchat != 0))
				boutput(mob_speaker, "LOOC for dead mobs has been turned off.")
				return

			if (findtext(message.orig_message, "byond://") && !mob_speaker.client?.holder)
				boutput(src, "<B>Advertising other servers is not allowed.</B>")
				logTheThing(LOG_ADMIN, src, "has attempted to advertise in LOOC.")
				logTheThing(LOG_DIARY, src, "has attempted to advertise in LOOC.", "admin")
				message_admins("[key_name(src)] has attempted to advertise in LOOC.")
				return

		logTheThing(LOG_DIARY, message.speaker, ": [message.content]", "looc")
		phrase_log.log_phrase("looc", message.content)

#ifdef DATALOGGER
		game_stats.ScanText(message.content)
#endif

		message.maptext_prefix = "\[LOOC: "
		message.maptext_suffix = "]"
		..()
		return

