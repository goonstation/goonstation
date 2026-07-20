/datum/speech_module/modifier/original_name
	id = SPEECH_MODIFIER_ORIGINAL_NAME
	//we want this to work in hivechat
	override_say_channel_modifier_preference = TRUE

/datum/speech_module/modifier/original_name/process(datum/say_message/message)
	. = message
	if (ismobcritter(message.original_speaker))
		var/mob/living/critter/critter = message.original_speaker
		if (critter.original_name)
			message.speaker_to_display = critter.original_name
