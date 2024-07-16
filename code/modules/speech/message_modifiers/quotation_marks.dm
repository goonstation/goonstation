/datum/message_modifier/postprocessing/quotation_marks
	sayflag = SAYFLAG_HAS_QUOTATION_MARKS
	priority = -100

/datum/message_modifier/postprocessing/quotation_marks/process(datum/say_message/message)
	. = message

	message.format_content_prefix += "\""
	message.format_content_suffix = "\"" + message.format_content_suffix
