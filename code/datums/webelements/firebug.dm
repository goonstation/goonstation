/datum/tag/firebug
	New()
		..("script")
		setAttribute("src", "https://getfirebug.com/firebug-lite.js")
		setAttribute("type", "text/javascript")
		innerHtml = {"
			{
				startOpened: true,
				enableTrace: true
			}
		"}
