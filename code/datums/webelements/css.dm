/datum/tag/css
	INIT()
		..("style")
		setAttribute("type", "text/css")

	proc/setContent(var/content as text)
		innerHtml = content
