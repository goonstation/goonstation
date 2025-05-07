//------------ Player Speech Verbs ------------//
/mob/verb/ooc(message as text)
	src.say(":ooc [message]", flags = SAYFLAG_SPOKEN_BY_PLAYER)

/mob/verb/looc(message as text)
	src.say(":looc [message]", flags = SAYFLAG_SPOKEN_BY_PLAYER)

/mob/verb/say_verb(message as text)
	set name = "say"

	if (!src.can_use_say)
		boutput(src, SPAN_ALERT("You can not speak!"))
		return

	if (!message)
		return

	src.say(message, flags = SAYFLAG_SPOKEN_BY_PLAYER)

/mob/verb/sa_verb(message as text)
	set name = "sa"
	set hidden = TRUE

	src.say_verb(message)

/mob/verb/whisper_verb(message as text)
	set name = "whisper"

	if (!src.can_use_say)
		boutput(src, SPAN_ALERT("You can not speak!"))
		return

	if (!message)
		return

	src.say(message, flags = SAYFLAG_WHISPER | SAYFLAG_SPOKEN_BY_PLAYER)

/mob/verb/say_main_radio(message as text)
	set name = "say_main_radio"
	set hidden = TRUE

/mob/living/say_main_radio(message as text)
	set name = "say_main_radio"
	set desc = "Speaking on the main radio frequency"
	set hidden = TRUE

	src.say_verb("; [message]")

/mob/verb/say_radio()
	set name = "say_radio"
	set hidden = TRUE

/mob/living/say_radio()
	set name = "say_radio"
	set hidden = TRUE

	var/list/choices = list()
	for (var/datum/speech_module/prefix/prefix_module as anything in src.ensure_speech_tree().GetAllPrefixes())
		var/list/prefix_choice = prefix_module.get_prefix_choices()
		if (!length(prefix_choice))
			continue

		choices += prefix_choice

	if (!length(choices))
		return

	var/choice
	if (length(choices) == 1)
		choice = choices[1]
	else
		choice = input("", "Select Radio Channel") as null | anything in choices

	if (!choice)
		return

	var/prefix = choices[choice]
	var/message = input("", "Speaking to [choice] Frequency") as null | text
	if (!message)
		return

	src.say_verb("[prefix] [message]")


//------------ Admin Speech Procs ------------//
#define ADMIN_SAY_PROC(proc_name, channel, module) \
/client/proc/##proc_name(message as text) { \
	SET_ADMIN_CAT(ADMIN_CAT_NONE); \
	set name = #proc_name; \
	set hidden = TRUE; \
	ADMIN_ONLY; \
	SHOW_VERB_DESC; \
	if (!src.mob || src.player_mode) { \
		return; \
	} \
	src.mob.say(message, flags = SAYFLAG_ADMIN_MESSAGE | SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = channel, "output_module_override" = module)); \
	logTheThing(LOG_ADMIN, src, "[uppertext(#proc_name)]: [message]"); \
	logTheThing(LOG_DIARY, src, "[uppertext(#proc_name)]: [message]", "admin"); \
}

ADMIN_SAY_PROC(blobsay, SAY_CHANNEL_BLOB, null)
ADMIN_SAY_PROC(dronesay, SAY_CHANNEL_GHOSTDRONE, null)
ADMIN_SAY_PROC(dsay, SAY_CHANNEL_DEAD, SPEECH_OUTPUT_DEADCHAT)
ADMIN_SAY_PROC(flocksay, SAY_CHANNEL_GLOBAL_FLOCK, null)
ADMIN_SAY_PROC(hivesay, SAY_CHANNEL_GLOBAL_HIVEMIND, null)
ADMIN_SAY_PROC(kudzusay, SAY_CHANNEL_KUDZU, null)
ADMIN_SAY_PROC(marsay, SAY_CHANNEL_MARTIAN, null)
ADMIN_SAY_PROC(silisay, SAY_CHANNEL_SILICON, null)
ADMIN_SAY_PROC(thrallsay, SAY_CHANNEL_GLOBAL_THRALL, null)

#undef ADMIN_SAY_PROC
