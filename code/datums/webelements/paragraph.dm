/datum/tag/paragraph
	New()
		..("p")

	proc/setText(txt as text)
		innerHtml = txt
