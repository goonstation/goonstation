/obj/item/device/radio/ai
	initial_microphone_enabled = FALSE
	icon_override = "ai"
	icon_tooltip = "Artificial Intelligence"


// The AI's `radio1`, for communicating over the general radio.
/obj/item/device/radio/ai/primary
	name = "Primary Radio"
	initial_speaker_enabled = FALSE


// The AI's `radio2`, for communicating over the AI intercoms.
TYPEINFO(/obj/item/device/radio/ai/intercom)
	start_speech_modifiers = list(SPEECH_MODIFIER_RADIO, SPEECH_MODIFIER_AI_INTERCOM_RADIO)

/obj/item/device/radio/ai/intercom
	name = "AI Intercom Monitor"
	device_color = "#7F7FE2"
	frequency = RADIO::FREQ::INTERCOM::AI
	initial_speaker_enabled = TRUE


// The AI's `radio3`, for communicating over secure channels.
/obj/item/device/radio/ai/secure
	name = "Secure Channels Monitor"
	initial_speaker_enabled = TRUE
	secure_frequencies = list(
		"h" = RADIO::FREQ::COMMAND,
		"g" = RADIO::FREQ::SECURITY,
		"e" = RADIO::FREQ::ENGINEERING,
		"r" = RADIO::FREQ::RESEARCH,
		"m" = RADIO::FREQ::MEDICAL,
		"c" = RADIO::FREQ::CIVILIAN,
	)
