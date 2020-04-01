/datum/tag/cssinclude
	New()
		..("link")
		setAttribute("rel", "stylesheet")
		setAttribute("type", "text/css")
		selfCloses = 1

	proc/setHref(var/href as text)
		setAttribute("href", href)
