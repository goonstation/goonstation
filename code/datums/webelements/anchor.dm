/datum/tag/anchor
	INIT()
		..("a")

	proc/setHref(var/href as text)
		setAttribute("href", href)

	proc/setText(var/txt as text)
		innerHtml = txt
