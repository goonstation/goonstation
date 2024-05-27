#define PASS_TO_ATOM_LISTENERS(message, atoms) if (length(atoms)) {\
	var/list/list/datum/listen_module/input/listen_modules_by_type = list(); \
	for (var/atom/A as anything in atoms) {\
		if (!A.listen_tree) {\
			continue; \
		}\
		for (var/datum/listen_module/input/input as anything in A.listen_tree.input_modules_by_channel[src.channel_id]) {\
			listen_modules_by_type[input.type] ||= list(); \
			listen_modules_by_type[input.type] += input; \
		}\
	}\
	src.PassToListeners(message, listen_modules_by_type); \
}

/datum/say_channel/delimited/local/outloud
	channel_id = SAY_CHANNEL_OUTLOUD

/datum/say_channel/delimited/local/outloud/PassToChannel(datum/say_message/message)
	if (!(message.flags & SAYFLAG_WHISPER))
		return ..()

	var/list/atom/heard_clearly = atom_hearers(WHISPER_RANGE, message.speaker)
	PASS_TO_ATOM_LISTENERS(message, heard_clearly)

	var/list/atom/heard_distorted = atom_hearers(message.heard_range, message.speaker) - heard_clearly
	var/datum/say_message/distorted_message = message.Copy()
	distorted_message.content = stars(distorted_message.content)
	PASS_TO_ATOM_LISTENERS(distorted_message, heard_distorted)

/datum/say_channel/delimited/local/outloud/GetAtomListeners(datum/say_message/message)
	return atom_hearers(message.heard_range, message.speaker)

/datum/say_channel/delimited/local/outloud/log_message(datum/say_message/message)
	var/mob/M = message.speaker
	if (!istype(M) || !M.client || !(message.flags & SAYFLAG_SPOKEN_BY_PLAYER))
		return

	if (message.flags & SAYFLAG_SINGING)
		logTheThing(LOG_DIARY, src, "(singing): [message]", "say")
		phrase_log.log_phrase("sing", message.content, user = message.speaker, strip_html = TRUE)

	else if (message.flags & SAYFLAG_WHISPER)
		logTheThing(LOG_DIARY, src, "(whisper): [message]", "whisper")
		logTheThing(LOG_WHISPER, src, "SAY: [message]")
		phrase_log.log_phrase("whisper", message.content, user = message.speaker, strip_html = TRUE)

	else
		logTheThing(LOG_DIARY, src, "(spoken): [message]", "say")
		phrase_log.log_phrase("say", message.content, user = message.speaker, strip_html = TRUE)


/datum/say_channel/global_channel/outloud
	channel_id = SAY_CHANNEL_GLOBAL_OUTLOUD
	delimited_channel_id = SAY_CHANNEL_OUTLOUD


#undef PASS_TO_ATOM_LISTENERS
