/datum/tag/button
	New()
		..("button")

	proc/setText(var/txt as text)
		innerHtml = txt
