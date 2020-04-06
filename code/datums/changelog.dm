/*
(t)
(u)
(*)
(+)
*/
/datum/changelog
//	var/changelog_path = "icons/changelog.txt"
	var/html = null
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

WIRE NOTE: You don't need to use (-) anymore (although doing so doesn't break anything)
OTHER NOTE:
(t)mon dec 1 14
returns "Monday, December 1 th, 204"
so you'll want your single-digit days to have 0s in front
*/

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ATTENTION: The changelog has moved into its own file: strings/changelog.txt

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/proc/changelog_parse(var/changes, var/title)
	var/list/html=list()
	var/text = changes
	if (!text)
		diary << "Failed to load changelog."
	else
		html += "<ul class=\"log\"><li class=\"title\"><i class=\"icon-bookmark\"></i> [title] as of [vcs_revision]</li>"

		var/list/collapsible_html = list()
		var/added_collapsible_author = 0
		var/added_author = 0
		var/author = null

		var/list/lines = splittext(text, "\n")
		for(var/line in lines)
			if (!line)
				continue

			if (copytext(line, 1, 2) == "#")
				continue

			switch(copytext(line, 1, 4))
				if("(t)")
					if(collapsible_html.len)
						html += "<li class=\"collapse-button\">Minor Changes</li><div class='collapsible'>[collapsible_html.Join()]</div>"
						collapsible_html.Cut()
						author = null
						added_collapsible_author = 0
						added_author = 0
					var/day = copytext(line, 4, 7)
					html += "<li class=\"date\">"
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
					author = copytext(line, 4, 0)
					added_collapsible_author = 0
					added_author = 0
				if("(*)")
					if(!added_author && author)
						html += "<li class=\"admin\"><span><i class=\"icon-check\"></i> [author]</span> updated:</li>"
						added_author = 1
					html += "<li>[copytext(line, 4, 0)]</li>"
				if("(+)")
					if(!added_collapsible_author && author)
						collapsible_html += "<li class=\"admin\"><span><i class=\"icon-check\"></i> [author]</span> updated:</li>"
						added_collapsible_author = 1
					collapsible_html += "<li>[copytext(line, 4, 0)]</li>"
				else continue

		if(collapsible_html.len)
			html += "<li class=\"collapse-button\">Minor Changes</li><div class='collapsible'>[collapsible_html.Join()]</div>"
		html += "</ul>"
		return html.Join()

/datum/changelog/New()
//<img alt="Goon Station 13" src="[resource("images/changelog/postcardsmall.jpg")]" class="postcard" />

	html = {"
<h1>Goon Station 13 <a href="#license"><img alt="Creative Commons License" src="[resource("images/changelog/somerights20.png")]" /></a></h1>

<ul class="links cf">
    <li>Official Wiki<br><strong>http://wiki.ss13.co</strong><span></span></li>
    <li>Official Forums<br><strong>https://forum.ss13.co</strong></li>
</ul>"}

	html += changelog_parse(file2text("strings/changelog.txt"), "Changelog")
	html += {"
<h3>GoonStation 13 Development Team</h3>
<p class="team">
    <strong>Host:</strong> Wire (#1, #2, Wiki, Forums, & more)<br>

    <strong>Coders:</strong> stuntwaffle, Showtime, Pantaloons, Nannek, Keelin, Exadv1, hobnob, 0staf, sniperchance, AngriestIBM, BrianOBlivion, I Said No, Harmar, Dropsy, ProcitizenSA, Pacra, LLJK-Mosheninkov, JackMassacre, Jewel, Dr. Singh, Infinite Monkeys, Cogwerks, Aphtonites, Wire, BurntCornMuffin, Tobba, Haine, Marquesas, SpyGuy, Conor12, Daeren, Somepotato, MyBlueCorners, ZeWaka, Gannets, Kremlin, Flourish, Mordent, Cirrial, Grayshift, Firebarrage, Kyle, Azungar, Warcrimes, HydroFloric, Zamujasa, Gerhazo, & Readster
		<br>
    <strong>Spriters:</strong> Supernorn, Haruhi, Stuntwaffle, Pantaloons, Rho, SynthOrange, I Said No, Cogwerks, Aphtonites, Hempuli, Gannets, Haine, SLthePyro, Sundance, Azungar, Flaborized, and a bunch of awesome people from the forums!
</p>

<p class="lic">
    <a href="http://creativecommons.org/licenses/by-nc-sa/3.0/" name="license"><img alt="Creative Commons CC-BY-NC-SA License" src="[resource("images/changelog/88x31.png")]" /></a><br/>

    <em>
    	Except where otherwise noted, Goon Station 13 is licensed under a <a href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-Noncommercial-Share Alike 3.0 License</a>.<br>
    	Rights are currently extended to SomethingAwful Goons only.
    </em>
</p>"}
