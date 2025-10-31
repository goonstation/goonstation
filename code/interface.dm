/client
	verb
		changes()
			set category = "Commands"
			set name = "Changelog"
			set desc = "Show or hide the changelog"
			if (winexists(src, "changes") && winget(src, "changes", "is-visible") == "true")
				src.Browse(null, "window=changes")
			else
				var/changelogHtml
				var/data
				if (!cdn)
					src << browse_rsc(file("browserassets/src/images/changelog/88x31.png"))
				if (byond_version >= 516)
					changelogHtml = grabResource("html/changelog.html")
					data = changelog.html
				else
					changelogHtml = grabResource("html/legacy_changelog.html")
					data = legacy_changelog.html
				var/fontcssdata = {"
				<style type="text/css">
				@font-face {
					font-family: 'Twemoji';
					src: url('[resource("css/fonts/twemoji.woff2")]') format('woff2');
					text-rendering: optimizeLegibility;
				}
				</style>
				"}
				changelogHtml = replacetext(changelogHtml, "<!-- CSS INJECT GOES HERE -->", fontcssdata)
				changelogHtml = replacetext(changelogHtml, "<!-- HTML GOES HERE -->", "[data]")
				if (byond_version >= 516)
					message_modal(src, changelogHtml, "Changelog", width = 500, height = 650, sanitize = FALSE)
				else
					src.Browse(changelogHtml, "window=changes;size=500x650;title=Changelog;", 1)
				src.changes = 1

		bugreport()
			set category = "Commands"
			set name = "bugreport"
			set desc = "Report a bug."
			set hidden = 1
			bug_report_form(src.mob, easteregg_chance=1)

		disable_menu()
			set category = "Commands"
			set name = "disable_menu"
			set desc = "Disables the menu and gives a message about it"
			set hidden = 1
			boutput(src, {"
				<div style="border: 3px solid red; padding: 3px;">
					You have disabled the menu. To enable the menu again, you can use the Menu button on the top right corner of the screen!
					<a href='byond://winset?command=enable_menu'>Or just click here!</a>
				</div>"})
			winset(src, null, "hide_menu.is-checked=true; mainwindow.menu=''; menub.is-visible = true")

		enable_menu()
			set category = "Commands"
			set name = "enable_menu"
			set desc = "Reenables the menu"
			set hidden = 1
			winset(src, null, "mainwindow.menu='menu'; hide_menu.is-checked=false; menub.is-visible = false")

		github()
			set category = "Commands"
			set name = "github"
			set desc = "Opens the github in your browser"
			set hidden = 1
			src << link("https://github.com/goonstation/goonstation")

		wiki()
			set category = "Commands"
			set name = "Wiki"
			set desc = "Open the Wiki in your browser"
			set hidden = 1
			src << link(generate_ingame_wiki_link(src))

		map()
			set category = "Commands"
			set name = "Map"
			set desc = "Open an interactive map in your browser"
			set hidden = 1
			src << link(generate_ingame_map_link(src))

		forum()
			set category = "Commands"
			set name = "Forum"
			set desc = "Open the Forum in your browser"
			set hidden = 1
			src << link("https://forum.ss13.co")

	proc
		set_macro(name)
			winset(src, "mainwindow", "macro=\"[name]\"")

/proc/generate_ingame_map_link(client/our_user)
	. = "/maps/cogmap"
	if (map_settings)
		. = map_settings.goonhub_map
	. = goonhub_href(.)
	var/turf/T = get_turf(our_user.mob)
	if (!T || T.z != Z_LEVEL_STATION && T.z != Z_LEVEL_DEBRIS) //no maps for weird z levels or nullspace
		return .
	. += "?sx=[T.x]&sy=[T.y]&zoom=0"
	if (T.z == Z_LEVEL_DEBRIS)
		. += "&layer=debris"

/proc/generate_ingame_wiki_link(client/our_user)
	. = "https://wiki.ss13.co/"
	var/datum/mind/user_mind = our_user.mob.mind
	if(!user_mind)
		return
	if (user_mind.assigned_role)
		var/datum/job/Job = find_job_in_controller_by_string(user_mind.assigned_role)
		if(Job?.wiki_link)
			. = Job.wiki_link
	if (user_mind.is_antagonist())
		for (var/datum/antagonist/antagonist_role in user_mind.antagonists)
			if(antagonist_role.wiki_link)
				. = antagonist_role.wiki_link //Keep going until you get the most recent antag (its probably the one you want the page for)
