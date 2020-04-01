/client
	verb
		changes()
			set category = "Commands"
			set name = "Changelog"
			set desc = "Show or hide the changelog"

			if (winget(src, "changes", "is-visible") == "true")
				src.Browse(null, "window=changes")
			else
				var/changelogHtml = grabResource("html/changelog.html")
				var/data = changelog:html
				changelogHtml = replacetext(changelogHtml, "<!-- HTML GOES HERE -->", "[data]")
				src.Browse(changelogHtml, "window=changes;size=500x650;title=Changelog;", 1)
				src.changes = 1

		wiki()
			set category = "Commands"
			set name = "Wiki"
			set desc = "Open the Wiki in your browser"
			set hidden = 1
			src << link("http://wiki.ss13.co")

		map()
			set category = "Commands"
			set name = "Map"
			set desc = "Open an interactive map in your browser"
			set hidden = 1
			if (map_settings)
				src << link(map_settings.goonhub_map)
			else
				if (ismap("COGMAP2"))
					src << link("http://goonhub.com/maps/cogmap2")
				else if (ismap("DESTINY"))
					src << link("http://goonhub.com/maps/destiny")
				else
					src << link("http://goonhub.com/maps/cogmap")

		forum()
			set category = "Commands"
			set name = "Forum"
			set desc = "Open the Forum in your browser"
			set hidden = 1
			src << link("https://forum.ss13.co")

		savetraits()
			set hidden = 1
			set name = ".savetraits"
			set instant = 1

			if(preferences)
				if(preferences.traitPreferences.isValid())
					preferences.ShowChoices(usr)
				else
					alert(usr, "Invalid trait setup. Please make sure you have 0 or more points available.")
					preferences.traitPreferences.showTraits(usr)

	proc
		set_macro(name)
			winset(src, "mainwindow", "macro=\"[name]\"")
