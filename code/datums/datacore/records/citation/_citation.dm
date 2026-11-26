ABSTRACT_TYPE(/datum/db_record/citation)
/datum/db_record/citation

/datum/db_record/citation/to_display_string()
	return src["id"] + ": " + src["target"]

/// Constructs and returns the paper form of this citation.
/datum/db_record/citation/proc/build_citation(paper_icon_state = "paper_caution")
	RETURN_TYPE(/obj/item/paper)

	var/list/sections = list(
		src.get_header(),
		src.get_recipient(),
		src.get_approver(),
		src.get_reason(),
		src.get_resolution(),
		src.get_footer(),
	)

	var/list/rendered = list()
	for (var/text as anything in sections)
		text = trimtext(text)
		if (text)
			rendered += text

	var/text = rendered.Join("------------------------------------------------------")

	var/obj/item/paper/paper = new()
	paper.name = src.get_name()
	paper.info = text
	paper.icon_state = paper_icon_state
	paper.paper_color = "#FFE9AD"
	return paper

/datum/db_record/citation/proc/get_name()
	PROTECTED_PROC(TRUE)
	CRASH("Not implemented.")

/datum/db_record/citation/proc/get_header()
	PROTECTED_PROC(TRUE)
	return {"\
		<font face="Monospace" color="453425">\
		<center>\
		<font size="4">[src["authority"]]</font><br>\
		<font size="3">[global.station_name]</font><br><br>\
		</center>\
		[src.get_date()]\
	"}

/datum/db_record/citation/proc/get_date()
	var/time = src["time"]
	var/display_time = copytext(time, 1, 11) + " " + copytext(time, 12, 20)
	return {"\
		<table width="365px">\
		<tr><td width="200px">DATE OF ISSUE</td><td>[display_time]</td></tr>\
		</table>\
	"}

/datum/db_record/citation/proc/get_recipient()
	PROTECTED_PROC(TRUE)
	return {"\
		<table width="365px">\
		<tr><td width="200px">RECIPIENT</td><td>[src["target"]]</td></tr>\
		<tr></tr>\
		<tr><td width="200px">ISSUED BY</td><td>[src["issuer"]]</td></tr>\
		<tr><td width="200px">ASSIGNMENT</td><td>[src["issuer_job"]]</td></tr>\
		</table>\
	"}

/datum/db_record/citation/proc/get_approver()
	PROTECTED_PROC(TRUE)
	return

/datum/db_record/citation/proc/get_reason()
	PROTECTED_PROC(TRUE)
	return {"\
		<table width="365px">\
		<tr><td width="100px">REASON</td><td>[src["reason"]]</td></tr>\
		</table>\
	"}

/datum/db_record/citation/proc/get_resolution()
	PROTECTED_PROC(TRUE)
	return

/datum/db_record/citation/proc/get_footer()
	PROTECTED_PROC(TRUE)
	var/flavour_text = pick(
		"Follow the Law.",
		"Contact a monkey in a [prob(10) ? "biz " : ""]suit and a funny hat if required.",
		"Do not Reoffend.",
		"Don't make it a habit.",
		"Your move, creep.",
		"I AM THE LAW.",
		"Justice is made.",
		"Unsafe for human consumption.",
		"Remember to recycle.",
		"Days without infractions: 0",
		"Could be your last.",
	)

	return {"\
		<br><br>\
		<center>\
		<font size="3">[flavour_text]</font>\
		[global.string_to_barcode(src["id"], 20, "453425")]\
		</center>\
		</font>\
	"}
