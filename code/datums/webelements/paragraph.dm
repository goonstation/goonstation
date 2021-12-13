/datum/tag/paragraph
	INIT()
		..("p")

	proc/setText(txt as text)
		innerHtml = txt
