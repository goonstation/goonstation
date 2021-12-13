/datum/tag/button
	INIT()
		..("button")

	proc/setText(var/txt as text)
		innerHtml = txt
