/datum/tag/cssinclude
	INIT()
		..("link")
		setAttribute("rel", "stylesheet")
		setAttribute("type", "text/css")
		selfCloses = 1

	proc/setHref(var/href as text)
		setAttribute("href", href)
