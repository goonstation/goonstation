/datum/speech_module/modifier/translator
	id = SPEECH_MODIFIER_TRANSLATOR
	var/language_id = null

/datum/speech_module/modifier/translator/New(datum/speech_module_tree/parent, language_id)
	. = ..()

	if (!language_id)
		CRASH("Translator modifier created without a language ID.")

	src.language_id = language_id

/datum/speech_module/modifier/translator/process(datum/say_message/message)
	. = message

	if (message.output_module_channel != SAY_CHANNEL_OUTLOUD)
		return

	message.language = global.SpeechManager.GetLanguageInstance(src.language_id)
