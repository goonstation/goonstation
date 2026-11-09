/datum/random_event/special/command_tracker
	name = "Command Tracker Distribution"
	disabled = TRUE
	centcom_headline = "Unregistered Signal Insertion"
	centcom_origin = ALERT_EGERIA_PROVIDENCE
	var/already_released = FALSE

	event_effect(var/source)
		var/ongoing_revolution_text = "S"
		if(length(get_all_antagonists(ROLE_REVOLUTIONARY)) || length(get_all_antagonists(ROLE_HEAD_REVOLUTIONARY)))
			ongoing_revolution_text = "To aid with the ongoing revolution, s"
		src.centcom_message = "Relevant biometric signatures of Command have been identified. [ongoing_revolution_text]tation command can now be tracked through the transmitted PDA program."
		. = ..()

		var/datum/signal/signal = get_free_signal()
		signal.data_file = (new /datum/computer/file/pda_program/headtracker)
		signal.data = list("command"="file_send", "file_name" = "Nanotrasen Command Tracker", "file_ext" = "PPROG", "file_size" = "1", "tag" = "auto_fileshare", "sender"="00000000")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)
		src.already_released = TRUE

/datum/random_event/special/headrev_tracker
	name = "Headrev Tracker Distribution"
	disabled = TRUE
	centcom_headline = "Central Command Security Alert"
	centcom_origin = ALERT_WATCHFUL_EYE
	var/already_released = FALSE

	event_effect(var/source)
		src.centcom_message = "Foreign mutiny located [station_or_ship()]wide, a program to track revolutionary leaders have been sent to all crew member PDA's."
		. = ..()

		var/datum/signal/signal = get_free_signal()
		signal.data_file = (new /datum/computer/file/pda_program/revheadtracker)
		signal.data = list("command"="file_send", "file_name" = "Revolutionary Leader Locater", "file_ext" = "PPROG", "file_size" = "1", "tag" = "auto_fileshare", "sender_name"="Central Command Distribution Line", "sender"="00000000")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)
		src.already_released = TRUE
