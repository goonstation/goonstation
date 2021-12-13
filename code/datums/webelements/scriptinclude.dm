/datum/tag/scriptinclude
	INIT()
		..("script")
		setAttribute("type", "text/javascript")

	proc/setSrc(var/source as text)
		setAttribute("src", source)
