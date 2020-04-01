/datum/tag/scriptinclude
	New()
		..("script")
		setAttribute("type", "text/javascript")

	proc/setSrc(var/source as text)
		setAttribute("src", source)
