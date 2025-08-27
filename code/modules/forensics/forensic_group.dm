
#define FORENSIC_EVIDENCE_MAX 20

ABSTRACT_TYPE(/datum/forensic_group)
ABSTRACT_TYPE(/datum/forensic_group/basic_list)
// Only one of each type of forensics_group should exist per forensic_holder
// If you want to store multiple groups of the same type, use multiple forensic_holders
/datum/forensic_group
	/// An identifier for the group type. Must be unique for each group.
	var/category = FORENSIC_GROUP_NONE
	var/group_flags = 0 //! Flags associated with the whole group. Actual usage may vary by group.

	proc/apply_evidence(var/datum/forensic_data/new_data)
		return

	proc/remove_evidence(var/removal_flags)
		return FALSE

	proc/report_text(var/datum/forensic_scan/scan, var/datum/forensic_report/report)
		return

	proc/copy_to(var/datum/forensic_holder/other)
		return

	proc/get_header()
		return "Null"

	proc/should_remove(var/target_flags, var/removal_flags)
		target_flags &= FORENSIC_REMOVE_ALL
		removal_flags &= FORENSIC_REMOVE_ALL
		return HAS_ALL_FLAGS(target_flags, removal_flags)

/datum/forensic_group/text
	category = FORENSIC_GROUP_TEXT
	var/list/datum/forensic_data/text/evidence_list = new/list()

	disposing()
		src.evidence_list.len = 0
		src.evidence_list = null
		..()

	apply_evidence(var/datum/forensic_data/new_data)
		if(!istype(new_data, /datum/forensic_data/text))
			return
		var/datum/forensic_data/text/data = new_data
		src.evidence_list.Add(data)

	remove_evidence(var/removal_flags)
		for(var/i=0; i<= src.evidence_list.len; i++)
			if(should_remove(src.evidence_list[i].flags, removal_flags))
				var/list/datum/forensic_data/removed_data = src.evidence_list[i]
				src.evidence_list.Cut(i, i+1)
				qdel(removed_data)
		return src.evidence_list.len == 0

	report_text(var/datum/forensic_scan/scan, var/datum/forensic_report/report)
		for(var/datum/forensic_data/text/f_data in src.evidence_list)
			report.add_line(f_data.get_text(scan), f_data.header)

	copy_to(var/datum/forensic_holder/other)
		for(var/datum/forensic_data/evidence in src.evidence_list)
			var/datum/forensic_data/evidence_copy = evidence.get_copy()
			other.add_evidence(evidence_copy, src.category)


/datum/forensic_group/basic_list
	var/list/datum/forensic_data/basic/evidence_list = new/list()
	var/value_usage = FORENSIC_VALUE_IGNORE //! Basic data has a value that can optionally be affected by duplicate evidence
	group_flags = 0

	disposing()
		src.evidence_list.len = 0
		src.evidence_list = null
		..()

	apply_evidence(var/datum/forensic_data/new_data)
		if(!istype(new_data, /datum/forensic_data/basic))
			return
		var/datum/forensic_data/basic/data = new_data

		var/oldest = 1
		for(var/i in 1 to length(src.evidence_list))
			if(data.evidence == src.evidence_list[i].evidence)
				evidence_list[i].time_start = min(evidence_list[i].time_start, data.time_start)
				evidence_list[i].time_end = max(evidence_list[i].time_end, data.time_end)
				update_value(evidence_list[i], data)
				return
			if(evidence_list[i].time_end < evidence_list[oldest].time_end)
				oldest = i
		if(length(src.evidence_list) < FORENSIC_EVIDENCE_MAX)
			// Randomize the order. Do it here so that it is the same order for each scan.
			src.evidence_list.Insert(rand(length(evidence_list) + 1), data)
		else
			src.evidence_list[oldest] = data

	remove_evidence(var/removal_flags)
		if(!should_remove(src.group_flags, removal_flags))
			return
		src.evidence_list.len = 0
		return TRUE

	report_text(var/datum/forensic_scan/scan, var/datum/forensic_report/report)
		for(var/datum/forensic_data/f_data in src.evidence_list)
			report.add_line(f_data.get_text(scan), src.get_header())

	copy_to(var/datum/forensic_holder/other)
		for(var/datum/forensic_data/evidence_data in src.evidence_list)
			var/datum/forensic_data/evidence_copy = evidence_data.get_copy()
			other.add_evidence(evidence_copy, src.category)

	/// If duplicate evidence is added, you can have that affect the value of the existing evidence
	proc/update_value(var/datum/forensic_data/basic/data_old, var/datum/forensic_data/basic/data_new)
		switch(value_usage)
			if(FORENSIC_VALUE_IGNORE)
				return
			if(FORENSIC_VALUE_SUM)
				data_old.value += data_new.value
			if(FORENSIC_VALUE_MULT)
				data_old.value *= data_new.value
			if(FORENSIC_VALUE_MIN)
				data_old.value = min(data_old.value, data_new.value)
			if(FORENSIC_VALUE_MAX)
				data_old.value = max(data_old.value, data_new.value)

/datum/forensic_group/basic_list/notes
	category = FORENSIC_GROUP_NOTES
	group_flags = FORENSIC_REMOVE_ALL

	remove_evidence(var/removal_flags)
		for(var/i=1; i<= src.evidence_list.len; i++)
			if(should_remove(src.evidence_list[i].flags, removal_flags))
				var/list/datum/forensic_data/removed_data = src.evidence_list[i]
				src.evidence_list.Cut(i, i+1)
				qdel(removed_data)
		return src.evidence_list.len == 0

	get_header()
		return FORENSIC_HEADER_NOTES

/datum/forensic_group/basic_list/sleuth // Used to store smells for Pug sleuthing
	category = FORENSIC_GROUP_SLEUTH
	group_flags = 0

	report_text(var/datum/forensic_scan/scan, var/datum/forensic_report/report)
		return

	/// Text proc is seperate for now since sleuthing is obtained via an emote rather than the forensics scanner
	proc/get_sleuth_text(var/atom/A, var/sleuth_all = FALSE)
		var/list/main_scents = list()
		var/list/datum/forensic_data/basic/other_scents = list()
		if (isliving(A))
			var/mob/living/L = A
			main_scents += L.mind?.color?.id
		for(var/datum/forensic_data/basic/scent_data in src.evidence_list)
			if(scent_data.time_end == INFINITY)
				main_scents += scent_data.evidence.id
			else
				other_scents += scent_data
		if(main_scents.len == 0 && other_scents.len == 0)
			return null

		var/scent_report = ""
		if(main_scents.len > 0)
			scent_report = "[A] mostly smells like "
		for(var/i in 1 to main_scents.len)
			if(i == 1)
				scent_report += main_scents[i]
			else if(i == main_scents.len)
				if(main_scents.len == 2)
					scent_report += " and [main_scents[i]]"
				else
					scent_report += ", and [main_scents[i]]"
			else
				scent_report += ", [main_scents[i]]"
		if(scent_report)
			scent_report = SPAN_NOTICE("<li>[scent_report].</li>")

		if(!sleuth_all)
			other_scents = list(pick(other_scents))

		var/data_text = ""
		for(var/datum/forensic_data/basic/scent in other_scents)
			data_text += sleuth_data(A, scent.evidence.id, TIME - scent.time_end, !data_text)
		return scent_report + data_text

	proc/sleuth_data(var/atom/A, var/color, var/time_since, var/is_first)
		var/list/time_since_list = list(0, rand(4,6), rand(8,12), rand(27,33), rand(41,49), rand(55,65))
		var/color_text
		if(is_first)
			var/list/intensity_list = list("faintly","acutely","strongly","mildly","kind","trace")
			var/intensity = get_intensity(intensity_list, time_since_list, time_since)
			color_text = "\The [A] smells [intensity] of \a [color]."
		else
			var/list/intensity_list = list("a faint","an acute","a strong","a mild","kind of a","a trace")
			var/scent = pick("scent", "hint", "taste", "aroma", "fragrance")
			var/detect = pick("detect","notice","note","find","pick up","smell","locate","track","discover","acertain","inhale","sense")
			var/intensity = get_intensity(intensity_list, time_since_list, time_since)
			color_text = "You also [detect] [intensity] [scent] of [color]."
		return "<li>[SPAN_NOTICE(color_text)]</li>"

	proc/get_intensity(var/list/intensity_list, var/list/time_since_list, var/time_since)
		for(var/i in 2 to length(intensity_list))
			if(time_since < time_since_list[i] MINUTES)
				return intensity_list[i]
		return intensity_list[1]

#undef FORENSIC_EVIDENCE_MAX
