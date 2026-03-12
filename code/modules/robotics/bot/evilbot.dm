//A robuddy that has gone mad. plum loco. unhinged. cabin crazy - from halloween.dm

//A spooky outer-space EVIL robuddy.  I guess that makes it...a roBADDY!
TYPEINFO(/obj/machinery/bot/guardbot/bad)
	start_speech_modifiers = list(SPEECH_MODIFIER_BOT_BAD)

/obj/machinery/bot/guardbot/bad
	name = "Secbuddy"
	desc = "An early sub-model of the popular PR-6S Guardbuddy line. It seems to be in rather poor shape."
	skin_icon_state = "secbuddy"
	face_icon_override = 'icons/obj/bots/robuddy/hemera-secbuddy-faces.dmi'

	control_freq = FREQ_SECBUDDY
	beacon_freq = FREQ_SECBUDDY_NAVBEACON

	no_camera = 1
	flashlight_red = 0.4
	flashlight_green = 0.1
	flashlight_blue = 0.1

	setup_charge_maximum = 800
	setup_default_startup_task = /datum/computer/file/guardbot_task/security/crazy
	setup_default_tool_path = /obj/item/device/guardbot_tool/taser
	no_camera = 1
	req_access = list(access_impossible)
	object_flags = 0
