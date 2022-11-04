/client/proc/cmd_admin_say(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "asay"
	set hidden = 1

	ADMIN_ONLY

	if (src.ismuted())
		return

	msg = copytext(sanitize(html_encode(msg)), 1, MAX_MESSAGE_LEN)
	logTheThing(LOG_ADMIN, src, "ASAY: [msg]")
	logTheThing(LOG_DIARY, src, "ASAY: [msg]", "admin")

	if (!msg)
		return

	var/special
	if (src.holder.rank in list("Goat Fart", "Ayn Rand's Armpit"))
		special = "gfartadmin"
	message_admins("[key_name(src)]: <span class=\"adminMsgWrap [special]\">[msg]</span>", 1)

	var/ircmsg[] = new()
	ircmsg["key"] = src.key
	ircmsg["name"] = stripTextMacros(src.mob.real_name)
	ircmsg["msg"] = html_decode(msg)
	ircbot.export_async("asay", ircmsg)

/client/proc/cmd_admin_forceallsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "forceallsay"
	set hidden = 1
	ADMIN_ONLY

	if (src.ismuted())
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	for(var/mob/living/M in mobs)
		if (ismob(M))
			var/speech = msg
			if(!speech)
				return
			M.say(speech)
			speech = copytext(sanitize(speech), 1, MAX_MESSAGE_LEN)

	logTheThing(LOG_ADMIN, usr, "forced everyone to say: [msg]")
	logTheThing(LOG_DIARY, usr, "forced everyone to say: [msg]", "admin")
	message_admins("<span class='internal'>[key_name(usr)] forced everyone to say: [msg]</span>")

/client/proc/cmd_admin_murraysay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "murraysay"
	set hidden = 1

	ADMIN_ONLY

	if (src.ismuted())
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	for (var/obj/machinery/bot/guardbot/old/maybeMurray in machine_registry[MACHINES_BOTS])
		if (!dd_hasprefix(maybeMurray.name, "Murray"))
			continue

		maybeMurray.speak(msg)
		break

	logTheThing(LOG_ADMIN, usr, "forced Murray to beep: [msg]")
	logTheThing(LOG_DIARY, usr, "forced Murray to beep: [msg]", "admin")
	message_admins("<span class='internal'>[key_name(usr)] forced Murray to beep: [msg]</span>")


// more copies than a kinkos
/client/proc/cmd_admin_hssay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "hssay"
	set hidden = 1

	ADMIN_ONLY

	if (src.ismuted())
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	// Given that HS can also talk on his own (well, used to be able to)
	// this should probably be a proc off in world.dm. Maybe. Probably nobody cares.
	for (var/obj/machinery/bot/medbot/head_surgeon/maybeHS in machine_registry[MACHINES_BOTS])
		maybeHS.speak(msg)
		logTheThing(LOG_ADMIN, usr, "forced HeadSurgeon to beep: [msg]")
		logTheThing(LOG_DIARY, usr, "forced HeadSurgeon: [msg]", "admin")
		message_admins("<span class='internal'>[key_name(usr)] forced HeadSurgeon to beep: [msg]</span>")
		return

	for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/maybeHS in world)
		LAGCHECK(LAG_LOW)
		maybeHS.speak(msg)
		logTheThing(LOG_ADMIN, usr, "forced HeadSurgeon to beep: [msg]")
		logTheThing(LOG_DIARY, usr, "forced HeadSurgeon: [msg]", "admin")
		message_admins("<span class='internal'>[key_name(usr)] forced HeadSurgeon to beep: [msg]</span>")
		return


// can you guess what this is a copy of?  I bet you can't
/client/proc/cmd_admin_bradsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set  name = "bradsay"
	set hidden = 1

	ADMIN_ONLY

	if (src.ismuted())
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	for (var/obj/machinery/derelict_aiboss/ai/maybeBrad in machine_registry[MACHINES_BOTS])
		maybeBrad.speak(msg)
		break

	logTheThing(LOG_ADMIN, usr, "forced Bradbury II to beep: [msg]")
	logTheThing(LOG_DIARY, usr, "forced Bradbury II to beep: [msg]", "admin")
	message_admins("<span class='internal'>[key_name(usr)] forced Bradbury II to beep: [msg]</span>")

// surely Beepsky's too much of an upstanding character to copy and steal intellectual property!
/client/proc/cmd_admin_beepsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "beepsay"
	set hidden = 1

	ADMIN_ONLY

	if (src.ismuted())
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	for (var/obj/machinery/bot/secbot/beepsky/maybeBeepsky in machine_registry[MACHINES_BOTS])
		maybeBeepsky.speak(msg)
		break

	logTheThing(LOG_ADMIN, usr, "forced Beepsky to beep: [msg]")
	logTheThing(LOG_DIARY, usr, "forced Beepsky to beep: [msg]", "admin")
	message_admins("<span class='internal'>[key_name(usr)] forced Beepsky to beep: [msg]</span>")

