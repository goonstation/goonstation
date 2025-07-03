/*
(t)
(u)
(*)
(+)
*/
/datum/changelog
	var/html = null
	var/testmerge_changes = null
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

/// Gets the changelog for a given testmerge PR number and returns relevant information for changelog_parse
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

/proc/changelog_parse(changes, title, testmerge_changes, use_modern_tags)
	var/list/html = list()
	var/text = changes
	if (!text)
		logDiary("Failed to load changelog.")
	else
		html += "<ul class='log'><li class='title'><i class='icon-bookmark'></i> [title] as of [copytext(ORIGIN_REVISION, 1, 8)]</li>" //truncate to 7 long

		var/list/collapsible_html = list()
		var/added_collapsible_author = 0
		var/added_author = 0
		var/author = null
		var/pr_num = null
		var/emoji_labels = null

		var/list/lines = splittext(text, "\n")

		var/tmerge_lines_left = 0
		if (testmerge_changes)  // sorry for ruining this code -Ze
			tmerge_lines_left = length(testmerge_changes) + 1 // + index
			lines.Insert(1, testmerge_changes) // insert testmerge changes at top of changelog

		for(var/line in lines)
			if (!line)
				continue

			if (copytext(line, 1, 2) == "#")
				continue

			tmerge_lines_left-- // fight me

			switch(copytext(line, 1, 4))
				if("(p)")
					pr_num = copytext(line, 4, 0)
				if("(e)")
					emoji_labels = copytext(line, 4, 0)
				if("(t)")
					if (copytext(line, 4, 13) == "Testmerge") // special case, we don't care about dates
						html += "<li class='date testmerge'>Current Testmerged PRs</li>"
						continue
					if (length(collapsible_html)) // test -1 below because the prior changes would've eaten it
						if (use_modern_tags)
							html += "<li class='minor-changes[tmerge_lines_left > -1 ? " testmerge" : ""]'><details><summary>Minor Changes</summary><div>[collapsible_html.Join()]</div></details></li>"
						else
							html += "<li class='collapse-button[tmerge_lines_left > -1 ? " testmerge" : ""]'>Minor Changes</li><div class='collapsible'>[collapsible_html.Join()]</div>"
						collapsible_html.Cut()
						author = null
						added_collapsible_author = 0
						added_author = 0
					var/day = copytext(line, 4, 7)
					html += "<li class='date'>"
					switch(day)
						if("sun")
							html += "Sunday, "
						if("mon")
							html += "Monday, "
						if("tue")
							html += "Tuesday, "
						if("wed")
							html += "Wednesday, "
						if("thu")
							html += "Thursday, "
						if("fri")
							html += "Friday, "
						if("sat")
							html += "Saturday, "
						else
							html += "Whoopsday, "
					var/month = copytext(line, 8, 11)
					switch(month)
						if("jan")
							html += "January "
						if("feb")
							html += "February "
						if("mar")
							html += "March "
						if("apr")
							html += "April "
						if("may")
							html += "May "
						if("jun")
							html += "June "
						if("jul")
							html += "July "
						if("aug")
							html += "August "
						if("sep")
							html += "September "
						if("oct")
							html += "October "
						if("nov")
							html += "November "
						if("dec")
							html += "December "
						else
							html += "Whoops"
					var/date1 = copytext(line, 12, 13)
					var/date2 = copytext(line, 13, 14)
					switch(date1)
						if("0")
							html += date2
							switch(date2)
								if("1")
									html += "st, "
								if("2")
									html += "nd, "
								if("3")
									html += "rd, "
								else
									html += "th, "
						if("1")
							html += "[date1][date2]th, "
						else
							html += date1
							html += date2
							switch(date2)
								if("1")
									html += "st, "
								if("2")
									html += "nd, "
								if("3")
									html += "rd, "
								else
									html += "th, "
					html += "20[copytext(line, 15, 17)]</li>"
				if("(u)")
					#ifdef APRIL_FOOLS_2021
					author = "CodeDude"
					#else
					author = copytext(line, 4, 0)
					#endif
					added_collapsible_author = 0
					added_author = 0
					pr_num = null
					emoji_labels = null
				if("(*)")
					if(!added_author && author)
						html += "<li class='admin[tmerge_lines_left > 0 ? " testmerge" : ""]'><span><i class='icon-check'></i> [author]</span> updated:"
						if(emoji_labels)
							var/list/emoji_parts = splittext(emoji_labels, "|")
							#ifdef APRIL_FOOLS_2021
							var/random_em = ""
							for(var/i in 1 to rand(1, 4))
								random_em += random_emoji()
							html += "<span class='emoji'>[random_em]"
							#else
							html += "<span class='emoji'>[emoji_parts[1]]"
							#endif
							if(length(emoji_parts) > 1)
								html += "<span class='tooltiptext'>[emoji_parts[2]]</span>"
							html += "</span>"
						if(pr_num)
							html += "<a target='_blank' href='https://github.com/goonstation/goonstation/pull/[pr_num]' class='pr_link'><span class='pr_number'>#[pr_num]</span>&gt;</a>"
						html += "</li>"
						added_author = 1
					html += "<li[tmerge_lines_left > 0 ? " class='testmerge'" : ""]>[copytext(line, 4, 0)]</li>"
				if("(+)")
					if(!added_collapsible_author && author)
						collapsible_html += "<li class='admin[tmerge_lines_left > 0 ? " testmerge" : ""]'><span><i class='icon-check'></i> [author]</span> updated:"
						if(emoji_labels)
							var/list/emoji_parts = splittext(emoji_labels, "|")
							collapsible_html += "<span class='emoji'>[emoji_parts[1]]"
							if(length(emoji_parts) > 1)
								collapsible_html += "<span class='tooltiptext'>[emoji_parts[2]]</span>"
							collapsible_html += "</span>"
						if(pr_num)
							collapsible_html += "<a target='_blank' href='https://github.com/goonstation/goonstation/pull/[pr_num]' class='pr_link'><span class='pr_number'>#[pr_num]</span>&gt;</a>"
						collapsible_html += "</li>"
						added_collapsible_author = 1
					collapsible_html += "<li[tmerge_lines_left > 0 ? " class='testmerge'" : ""]>[copytext(line, 4, 0)]</li>"
				else
					continue

		if(collapsible_html.len)
			if (use_modern_tags)
				html += "<li class='minor-changes[tmerge_lines_left > 0 ? " testmerge" : ""]'><details><summary>Minor Changes</summary></li><div>[collapsible_html.Join()]</div></details>"
			else
				html += "<li class='collapse-button[tmerge_lines_left > 0 ? " testmerge" : ""]'>Minor Changes</li><div class='collapsible'>[collapsible_html.Join()]</div>"
		html += "</ul>"
		return html.Join()

/datum/changelog/New(use_modern_tags)
	..()

#ifdef TESTMERGE_PRS
	src.testmerge_changes = list("(t)Testmerge")

	for (var/pr_num in TESTMERGE_PRS) // list(123, 456)
		var/log = src.get_testmerge_changelog(pr_num)
		if (log)
			src.testmerge_changes += log
#endif

	html = {"
<h1>Goonstation 13 <a href="#license"><img alt="Creative Commons CC-BY-NC-SA License" src="[resource("images/changelog/88x31.png")]" /></a></h1>

<ul class="links cf">
    <li>Official Wiki<br><strong><a target="_blank" href="http://wiki.ss13.co/" target="_blank">https://wiki.ss13.co</a></strong><span></span></li>
    <li>Official Forums<br><strong><a target="_blank" href="https://forum.ss13.co/" target="_blank">https://forum.ss13.co</a></strong></li>
</ul>"}

	html += changelog_parse(file2text("strings/changelog.txt"), "Changelog", src.testmerge_changes, use_modern_tags)
	html += {"
<h3>GoonStation 13 Development Team</h3>
<p class="team">
    <strong>Host:</strong> Wire (#1, #2, Wiki, Forums, & more)<br>

    <strong>Coders:</strong> stuntwaffle, Showtime, Pantaloons, Nannek, Keelin, Exadv1, hobnob, 0staf, sniperchance, AngriestIBM, BrianOBlivion, I Said No, Harmar, Dropsy, ProcitizenSA, Pacra, LLJK-Mosheninkov, JackMassacre, Jewel, Dr. Singh, Infinite Monkeys, Cogwerks, Aphtonites, Wire, BurntCornMuffin, Tobba, Haine, Marquesas, SpyGuy, Conor12, Daeren, Somepotato, MyBlueCorners, ZeWaka, Gannets, Kremlin, Flourish, Mordent, Cirrial, Grayshift, Firebarrage, Kyle, Azungar, Warcrimes, HydroFloric, Zamujasa, Gerhazo, Readster, pali6, Tarmunora, UrsulaMejor, Sovexe, MarkNstein, Virvatuli, Aloe, Caro, Sord, AdharaInSpace, Azrun, Walpvrgis, & LeahTheTech.
		<br>
    <strong>Spriters:</strong> Supernorn, Haruhi, Stuntwaffle, Pantaloons, Rho, SynthOrange, I Said No, Cogwerks, Aphtonites, Hempuli, Gannets, Haine, SLthePyro, Sundance, Azungar, Flaborized, Erinexx, Walpvrgis, and a bunch of awesome people from the forums!
</p>

<p id="license" class="lic">
    <a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/3.0/" name="license"><img alt="Creative Commons CC-BY-NC-SA License" src="[resource("images/changelog/88x31.png")]" /></a><br/>

    <em>
    	Except where otherwise noted, Goonstation 13 is licensed under a <a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-Noncommercial-Share Alike 3.0 License</a>.
    </em>
</p>"}
