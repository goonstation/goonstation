
#define FORENSIC_EVIDENCE_MAX 20

ABSTRACT_TYPE(/datum/forensic_group)
ABSTRACT_TYPE(/datum/forensic_group/basic_list)
// Only one of each type of forensics_group should exist per forensic_holder
// If you want to store multiple groups of the same type, use multiple forensic_holders
/datum/forensic_group
	// An identifier for the group type. Must be unique for each group.
	var/category = FORENSIC_GROUP_NONE
	var/group_flags = 0 // Flags associated with the whole group. Actual usage may vary by group.
	var/group_accuracy = 1

	proc/apply_evidence(var/datum/forensic_data/data)
		return

/datum/forensic_group/basic_list
	var/list/datum/forensic_data/basic/evidence_list = new/list()
	var/value_usage = FORENSIC_VALUE_IGNORE
	group_flags = 0

	disposing()
		src.evidence_list.len = 0
		src.evidence_list = null
		..()

	apply_evidence(var/datum/forensic_data/data)
		if(!istype(data))
			return
		var/datum/forensic_data/basic/new_ev = data

		var/oldest = 1
		for(var/i in 1 to length(src.evidence_list))
			if(new_ev.evidence == src.evidence_list[i].evidence)
				evidence_list[i].time_end = max(evidence_list[i].time_end, new_ev.time_end)
				update_value(evidence_list[i], new_ev)
				return
			if(evidence_list[i].time_end < evidence_list[oldest].time_end)
				oldest = i
		if(length(src.evidence_list) < FORENSIC_EVIDENCE_MAX)
			src.evidence_list.Insert(rand(length(evidence_list) + 1), new_ev) // Randomize the order
		else
			src.evidence_list[oldest] = new_ev

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

/datum/forensic_group/basic_list/sleuth // Used to store smells for Pug sleuthing
	category = FORENSIC_GROUP_SLEUTH
	group_flags = 0

	// Text proc is seperate for now since sleuthing is obtained via an emote rather than the forensics scanner
	proc/get_sleuth_text(var/atom/A, var/sleuth_all = FALSE, var/accuracy = -1)
		if(length(src.evidence_list) == 0)
			return null
		if(!sleuth_all)
			return sleuth_data(A, src.evidence_list[rand(1, length(src.evidence_list))], accuracy, TRUE)

		var/data_text = ""
		for(var/i in 1 to length(src.evidence_list))
			data_text += sleuth_data(A, src.evidence_list[i], accuracy, i == 1)
		return data_text

	proc/sleuth_data(var/atom/A, var/datum/forensic_data/basic/slueth_data, var/accuracy, var/is_first)
		var/color = slueth_data.evidence.id
		var/time_since = TIME - slueth_data.time_end
		var/list/time_since_list = list(0, rand(4,6), rand(8,12), rand(27,33), rand(41,49), rand(55,65))
		var/c_text
		if(is_first)
			var/list/intensity_list = list("faintly","acutely","strongly","mildly","kind","trace")
			var/intensity = get_intensity(intensity_list, time_since_list, time_since)
			c_text = "\The [A] smells [intensity] of \a [color]."
		else
			var/list/intensity_list = list("a faint","an acute","a strong","a mild","kind of a","a trace")
			var/scent = pick("scent", "hint", "taste", "aroma", "fragrance")
			var/detect = pick("detect","notice","note","find","pick up","smell","locate","track","discover","acertain","inhale","sense")
			var/intensity = get_intensity(intensity_list, time_since_list, time_since)
			c_text = "You also [detect] [intensity] [scent] of [color]."
		return "<li>[SPAN_NOTICE(c_text)]</li>"

	proc/get_intensity(var/list/intensity_list, var/list/time_since_list, var/time_since)
		for(var/i in 2 to length(intensity_list))
			if(time_since < time_since_list[i] MINUTES)
				return intensity_list[i]
		return intensity_list[1]

#undef FORENSIC_EVIDENCE_MAX
