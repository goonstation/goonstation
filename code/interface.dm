/client
	verb
		changes()
			set category = "Commands"
			set name = "Changelog"
			set desc = "Show or hide the changelog"
			if (winexists(src, "changes") && winget(src, "changes", "is-visible") == "true")
				src.Browse(null, "window=changes")
			else
				var/changelogHtml = grabResource("html/changelog.html")
				var/data = changelog:html
				var/fontcssdata = {"
				<style type="text/css">
				@font-face {
					font-family: 'Twemoji';
					src: url('[resource("css/fonts/Twemoji.eot")]');
					src: url('[resource("css/fonts/Twemoji.eot")]') format('embedded-opentype'),
						 url('[resource("css/fonts/Twemoji.ttf")]') format('truetype');
					text-rendering: optimizeLegibility;
				}
				</style>
				"}
				changelogHtml = replacetext(changelogHtml, "<!-- CSS INJECT GOES HERE -->", fontcssdata)
				changelogHtml = replacetext(changelogHtml, "<!-- HTML GOES HERE -->", "[data]")
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
			src << link("http://wiki.ss13.co")

		map()
			set category = "Commands"
			set name = "Map"
			set desc = "Open an interactive map in your browser"
			set hidden = 1
			if (map_settings)
				src << link(map_settings.goonhub_map)
			else
				src << link("http://goonhub.com/maps/cogmap")

		forum()
			set category = "Commands"
			set name = "Forum"
			set desc = "Open the Forum in your browser"
			set hidden = 1
			src << link("https://forum.ss13.co")

	proc
		set_macro(name)
			winset(src, "mainwindow", "macro=\"[name]\"")
