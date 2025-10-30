#define MODE_OFF 0
#define MODE_RECORDING 1


/datum/listen_module/effect/audio_log
	id = LISTEN_EFFECT_AUDIO_LOG

/datum/listen_module/effect/audio_log/process(datum/say_message/message)
	var/obj/item/device/audio_log/audio_log = src.parent_tree.listener_parent
	if (!istype(audio_log) || (audio_log.mode != MODE_RECORDING) || !audio_log.tape)
		return

	var/mob/M = message.speaker
	if (istype(M) && (M.mind?.assigned_role == "Captain"))
		M.unlock_medal("Captain's Log", TRUE)

	if (!audio_log.tape.add_message(message.speaker_to_display, message.content, audio_log.continuous))
		audio_log.say("Memory full. Have a nice day.", message_params = list("speaker_to_display" = ""))
		audio_log.mode = MODE_OFF
		audio_log.updateSelfDialog()


#undef MODE_OFF
#undef MODE_RECORDING
