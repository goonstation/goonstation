/datum/tag/script
	New()
		..("script")
		setAttribute("type", "text/javascript")

	proc/setContent(var/content as text)
		innerHtml = content
