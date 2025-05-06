/datum/shared_input_format_module/ai_ears
	id = LISTEN_INPUT_EARS_AI

/datum/shared_input_format_module/ai_ears/process(datum/say_message/message)
	. = message

	// Restrict this behaviour to radio messages.
	if (!(message.relay_flags & SAY_RELAY_RADIO))
		return

	// Determine and format the speaker's displayed job title.
	var/job_title = "Unknown"
	if (ishuman(message.original_speaker))
		var/mob/living/carbon/human/H = message.original_speaker
		if (H.wear_id)
			job_title = H.wear_id:assignment
		else
			job_title = "No ID"

	else if (isAI(message.original_speaker))
		job_title = "AI"

	else if (isrobot(message.original_speaker))
		job_title = "Cyborg"

	else if (istype(message.original_speaker, /obj/machinery/computer))
		job_title = "Computer"

	message.speaker_to_display = message.real_ident

	message.format_speaker_prefix += "<a href='byond://?src=\ref[src];action=track;heard_name=[message.real_ident]'>"
	message.format_verb_prefix = " ([job_title])</a>" + message.format_verb_prefix

// I dislike implementing AI tracking here, however the alternative, performing the above formatting per listener and using `/mob/living/silicon/Topic` would incur a performance cost.
/datum/shared_input_format_module/ai_ears/Topic(href, href_list)
	if (usr.stat)
		return

	var/mob/living/silicon/A
	if (isAIeye(usr))
		var/mob/living/intangible/aieye/eye = usr
		A = eye.mainframe
	else
		A = usr

	if (!issilicon(A))
		return

	if ((href_list["action"] == "track") && href_list["heard_name"])
		A.ai_name_track(href_list["heard_name"])
