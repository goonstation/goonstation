/datum/tag/css
	New()
		..("style")
		setAttribute("type", "text/css")

	proc/setContent(var/content as text)
		innerHtml = content
