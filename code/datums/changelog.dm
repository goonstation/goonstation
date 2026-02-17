/*
New auto-generated changelog:
Format:
Use (t) for the timestamp, (u) for the user, and (*)for the line to add.
Use (+) instead for minor changes (will be collapsed and grouped up at the end of the day's log).
Be sure to add a \ before a [
Examples:
Single update for a given day:
(t)mon jan 01 12
(u)Pantaloons
(*)Did a thing.
Multiple updates in a day:
(t)mon jan 01 12
(u)Pantaloons
(*)Did a thing.
(+)Fixed a bug.
(u)Nannek
(*)Also did a thing.

OTHER NOTE:
(t)mon dec 1 14
returns "Monday, December 1 th, 204"
so you'll want your single-digit days to have 0s in front
*/

/datum/changelog
	var/testmerge_changes = null

	var/list/entries
	var/list/admin_entries

	New()
		..()
		#ifdef TESTMERGE_PRS
		src.testmerge_changes = list("(t)Testmerge")

		for (var/pr_num in TESTMERGE_PRS) // list(123, 456)
			var/log = src.get_testmerge_changelog(pr_num)
			if (log)
				src.testmerge_changes += log
		#endif

		src.entries = src.create_changelog_entries(file2text("strings/changelog.txt"), src.testmerge_changes)
		src.admin_entries = src.create_changelog_entries(file2text("strings/admin_changelog.txt"))

/datum/changelog/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Changelog")
		ui.open()

/datum/changelog/ui_static_data(mob/user)
	. = list("entries" = src.entries,
			 "is_admin" = isadmin(user),
			 "admin_entries" = src.admin_entries
			 )

/datum/changelog/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/changelog/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/// Gets the changelog for a given testmerge PR number and returns relevant information for build_changelog
/// Returns null if no correctly formatted changelog was found in the body of the PR
/datum/changelog/proc/get_testmerge_changelog(pr_num)
	. = list()

	var/file_text = file2text("testmerges/[pr_num].json")
	var/json = json_decode(file_text)

	var/body = json["body"]

	var/static/regex/changelog_regex = regex(@"```changelog\n(\(u\)\s*.*?):?$\n([\s\S\n]*)(\n)```", "m") // good luck lol
	var/static/regex/i_hate_windows = regex(@"\r", "g") // The year is 2053. BYOND still does not know \r exists.
	body = replacetext(body, i_hate_windows, "")

	if (!changelog_regex.Find(body)) // no changelog
		return null

	if (changelog_regex.group[1]) // author
		. += changelog_regex.group[1]
	else
		. += "(u)[json["user"]["login"]]" // no changelog author specified???

	. += "(p)[json["number"]]"
	. += "(e)🧪|Testmerge"
	. += splittext(changelog_regex.group[2], "\n") // actual changelog (*) changes

/// Parses auto-generated changelog strings into TGUI inputs
/datum/changelog/proc/create_changelog_entries(changelog_string, testmerge_changes_string)
	if (!changelog_string)
		logDiary("Failed to load changelog.")
		return

	var/list/ent_dates = list()
	var/list/maj_entries = list()
	var/list/min_entries = list()

	var/list/lines = splittext(changelog_string, "\n")
	if (testmerge_changes)  // sorry for ruining this code -Ze
		lines.Insert(1, testmerge_changes) // insert testmerge changes at top of changelog

	var/cur_date = ""
	var/author = null
	var/pr_num = null
	var/emojis = null
	var/emoji_tooltips = null
	var/change_entry = null

	for(var/line in lines)
		if (!line)
			continue
		if (copytext(line, 1, 2) == "#")
			continue
		switch(copytext(line, 1, 4))
			if("(t)")
				cur_date = changelog_date_parse(line)
				ent_dates.Add(cur_date)
				maj_entries[cur_date] = list()
				min_entries[cur_date] = list()
			if("(u)")
				author = copytext(line, 4, 0)
				emojis = null
				emoji_tooltips = null
			if("(p)")
				pr_num = copytext(line, 4, 0)
			if("(e)")
				var/emoji_line = copytext(line, 4, 0)
				var/list/emoji_parts = splittext(emoji_line, "|")
				if (length(emoji_parts))
					emojis = emoji_parts[1]
					emoji_tooltips = emoji_parts[2]
			if("(*)")
				change_entry = copytext(line, 4, 0)
				var/pr_found = FALSE
				var/i = 0
				for (var/entry in maj_entries[cur_date])
					i++
					if (entry["pr_num"] == pr_num)
						pr_found = TRUE
						maj_entries[cur_date][i]["changes"] += list(change_entry)
						break
				if (!pr_found)
					maj_entries[cur_date] += list(list("author" = author, "pr_num" = pr_num, "emojis" = emojis, "emoji_tooltips" = emoji_tooltips, \
						"changes" = list(change_entry)))
			if ("(+)")
				change_entry = copytext(line, 4, 0)
				var/pr_found = FALSE
				var/i = 0
				for (var/entry in min_entries[cur_date])
					i++
					if (entry["pr_num"] == pr_num)
						pr_found = TRUE
						min_entries[cur_date][i]["changes"] += list(change_entry)
						break
				if (!pr_found)
					min_entries[cur_date] += list(list("author" = author, "pr_num" = pr_num, "emojis" = emojis, "emoji_tooltips" = emoji_tooltips, \
						"changes" = list(change_entry)))
			else
				continue

	var/list/cl_entries = list()
	for (var/day in ent_dates)
		cl_entries += list(list("entry_date" = day, "major_entries" = maj_entries[day], "minor_entries" = min_entries[day]))

	return cl_entries

/// Creates a date string from a auto-generated changelog date
/datum/changelog/proc/changelog_date_parse(dateline)
	var/cur_date = ""
	if (copytext(dateline, 4, 13) == "Testmerge") // special case, we don't care about dates
		cur_date = "Current Testmerged PRs"
		return
	var/day = copytext(dateline, 4, 7)
	switch(day)
		if("sun")
			cur_date += "Sunday, "
		if("mon")
			cur_date += "Monday, "
		if("tue")
			cur_date += "Tuesday, "
		if("wed")
			cur_date += "Wednesday, "
		if("thu")
			cur_date += "Thursday, "
		if("fri")
			cur_date += "Friday, "
		if("sat")
			cur_date += "Saturday, "
		else
			cur_date += "Whoopsday, "
	var/month = copytext(dateline, 8, 11)
	switch(month)
		if("jan")
			cur_date += "January "
		if("feb")
			cur_date += "February "
		if("mar")
			cur_date += "March "
		if("apr")
			cur_date += "April "
		if("may")
			cur_date += "May "
		if("jun")
			cur_date += "June "
		if("jul")
			cur_date += "July "
		if("aug")
			cur_date += "August "
		if("sep")
			cur_date += "September "
		if("oct")
			cur_date += "October "
		if("nov")
			cur_date += "November "
		if("dec")
			cur_date += "December "
		else
			cur_date += "Whoops"
	var/date1 = copytext(dateline, 12, 13)
	var/date2 = copytext(dateline, 13, 14)
	switch(date1)
		if("0")
			cur_date += date2
			switch(date2)
				if("1")
					cur_date += "st, "
				if("2")
					cur_date += "nd, "
				if("3")
					cur_date += "rd, "
				else
					cur_date += "th, "
		if("1")
			cur_date += "[date1][date2]th, "
		else
			cur_date += date1
			cur_date += date2
			switch(date2)
				if("1")
					cur_date += "st, "
				if("2")
					cur_date += "nd, "
				if("3")
					cur_date += "rd, "
				else
					cur_date += "th, "
	cur_date += "20[copytext(dateline, 15, 17)]"

	return cur_date
