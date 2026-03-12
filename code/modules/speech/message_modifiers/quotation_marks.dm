/datum/message_modifier/postprocessing/quotation_marks
	sayflag = SAYFLAG_HAS_QUOTATION_MARKS
	priority = SAYFLAG_PRIORITY_PROCESS_LAST

/datum/message_modifier/postprocessing/quotation_marks/process(datum/say_message/message)
	. = message

	message.format_content_prefix += "\""
	message.format_content_suffix = "\"" + message.format_content_suffix
