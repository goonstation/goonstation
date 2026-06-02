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
	var/list/testmerge_changes = null
	var/list/entries = null
	var/list/admin_entries = null
	var/current_commit = null
	var/host = null
	var/coders = null
	var/spriters = null

	/**
	 *	Parses the changelog section included in a PR body. Separates the captured text into two groups: \
	 *	Group 1 for the PR author, e.g.:
	 *	> (u)CodeDude
	 *
	 *	Group 2 for the feedback thread, e.g.:
	 *	> (f)https://forum.ss13.co/
	 *
	 *	Group 3 for the changes, e.g.:
	 *	> (*)Added soft soft pizza to the game - a tasty drink found in soda machines! \
	 *	> (+)Drinking any kind of soda will cause you to burp violently.
	 */
	var/static/regex/changelog_regex = regex(@"```changelog\n(\(u\)\s*.*?):?$\n(\(f\)\s*.*?)$\n([\s\S\n]*)(\n)```", "m")

	/// Matches all carriage return characters.
	var/static/regex/carriage_return_regex = regex(@"\r", "g")

	/// A map between auto-generated changelog day strings and their full strings.
	var/static/alist/day_lookup = alist(
		"sun" = "Sunday",
		"mon" = "Monday",
		"tue" = "Tuesday",
		"wed" = "Wednesday",
		"thu" = "Thursday",
		"fri" = "Friday",
		"sat" = "Saturday",
	)
	/// A map between auto-generated changelog month strings and their full strings.
	var/static/alist/month_lookup = alist(
		"jan" = "January",
		"feb" = "February",
		"mar" = "March",
		"apr" = "April",
		"may" = "May",
		"jun" = "June",
		"jul" = "July",
		"aug" = "August",
		"sep" = "September",
		"oct" = "October",
		"nov" = "November",
		"dec" = "December",
	)

/datum/changelog/New()
	. = ..()
	#ifdef TESTMERGE_PRS
	src.testmerge_changes = list("(t)Testmerge")

	for (var/pr_num as anything in TESTMERGE_PRS) // list(123, 456)
		var/log = src.get_testmerge_changelog(pr_num)
		if (log)
			src.testmerge_changes += log
	#endif

	src.entries = src.create_changelog_entries(file2text("strings/changelog.txt"), TRUE)
	src.admin_entries = src.create_changelog_entries(file2text("strings/admin_changelog.txt"))
	src.current_commit = copytext(ORIGIN_REVISION, 1, 8)
	src.host = english_list(strings("changelog_attribution/host.txt"), and_text = " & ")
	src.coders = english_list(strings("changelog_attribution/coders.txt"), and_text = " & ")
	src.spriters = english_list(strings("changelog_attribution/spriters.txt"), and_text = " & ")

/datum/changelog/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Changelog")
		ui.open()

/datum/changelog/ui_static_data(mob/user)
	. = list(
		"entries" = src.entries,
		"is_admin" = global.isadmin(user),
		"admin_entries" = src.admin_entries,
		"current_commit" = src.current_commit,
		"dev_host" = src.host,
		"dev_coders" = src.coders,
		"dev_spriters" = src.spriters,
	)

/datum/changelog/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/changelog/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/// Gets the changelog for a given testmerge PR number and returns relevant information for `build_changelog`.
/// Returns `null` if no correctly formatted changelog was found in the body of the PR.
/datum/changelog/proc/get_testmerge_changelog(pr_num)
	. = list()

	var/file_text = file2text("testmerges/[pr_num].json")
	var/list/json = json_decode(file_text)

	var/body = replacetext(json["body"], src.carriage_return_regex, "")
	if (!src.changelog_regex.Find(body))
		return

	// The changelog author, or if no author is specified, the PR author instead.
	. += src.changelog_regex.group[1] || "(u)[json["user"]["login"]]"
	// The PR number.
	. += "(p)[json["number"]]"
	// The feedback thread.
	. += src.changelog_regex.group[2]
	// The testmerge tag.
	. += "(e)🧪|Testmerge"
	// The changelog changes, prefixed by (*) for major changes, or (+) for minor changes.
	. += splittext(src.changelog_regex.group[3], "\n")

/// Parses auto-generated changelog strings into TGUI inputs.
/datum/changelog/proc/create_changelog_entries(changelog_string, show_testmerges = FALSE)
	if (!changelog_string)
		logDiary("Failed to load changelog.")
		return

	var/list/entry_dates = list()
	var/list/major_entries = list()
	var/list/minor_entries = list()

	var/current_date = ""		// (t)
	var/author = null			// (u)
	var/pr_num = null			// (p)
	var/feedback = null			// (f)
	var/emojis = null			// (e)
	var/emoji_tooltips = null	// (e)
	var/change_entry = null		// (*) (+)

	var/list/lines = splittext(changelog_string, "\n")
	if (show_testmerges && src.testmerge_changes)
		lines.Insert(1, testmerge_changes)

	for (var/line as anything in lines)
		if (!line || (copytext(line, 1, 2) == "#"))
			continue

		switch (copytext(line, 1, 4))
			if ("(t)")
				current_date = src.changelog_date_parse(line)
				entry_dates += current_date
				major_entries[current_date] = list()
				minor_entries[current_date] = list()

			if ("(u)")
				author = copytext(line, 4, 0)
				pr_num = null
				feedback = null
				emojis = null
				emoji_tooltips = null
				change_entry = null

			if ("(p)")
				pr_num = copytext(line, 4, 0)

			if ("(f)")
				var/link = trimtext(copytext(line, 4, 0))
				if (copytext(link, 1, 23) == "https://forum.ss13.co/")
					feedback = link

			if ("(e)")
				var/emoji_line = copytext(line, 4, 0)
				var/list/emoji_parts = splittext(emoji_line, "|")
				if (length(emoji_parts))
					emojis = emoji_parts[1]
					emoji_tooltips = emoji_parts[2]

			if ("(*)")
				change_entry = copytext(line, 4, 0)

				var/pr_found = FALSE
				for (var/list/entry as anything in major_entries[current_date])
					if (entry["pr_num"] == pr_num)
						pr_found = TRUE
						entry["changes"] += list(change_entry)
						break

				if (!pr_found)
					major_entries[current_date] += list(list(
						"author" = author,
						"pr_num" = pr_num,
						"feedback" = feedback,
						"emojis" = emojis,
						"emoji_tooltips" = emoji_tooltips,
						"changes" = list(change_entry),
					))

			if ("(+)")
				change_entry = copytext(line, 4, 0)

				var/pr_found = FALSE
				for (var/list/entry as anything in minor_entries[current_date])
					if (entry["pr_num"] == pr_num)
						pr_found = TRUE
						entry["changes"] += list(change_entry)
						break

				if (!pr_found)
					minor_entries[current_date] += list(list(
						"author" = author,
						"pr_num" = pr_num,
						"feedback" = feedback,
						"emojis" = emojis,
						"emoji_tooltips" = emoji_tooltips,
						"changes" = list(change_entry),
					))

	for (var/date as anything in entry_dates)
		. += list(list(
			"entry_date" = date,
			"major_entries" = major_entries[date],
			"minor_entries" = minor_entries[date],
		))

/// Creates a date string from an auto-generated changelog date.
/datum/changelog/proc/changelog_date_parse(dateline)
	if (copytext(dateline, 4, 13) == "Testmerge")
		return "Current Testmerged PRs"

	var/day = src.day_lookup[copytext(dateline, 4, 7)] || "Whoopsday"
	var/month = src.month_lookup[copytext(dateline, 8, 11)] || "Whoops"
	var/date = "[text2num(copytext(dateline, 12, 14))]\th"
	var/year = "20[copytext(dateline, 15, 17)]"

	return "[day], [month] [date], [year]"
