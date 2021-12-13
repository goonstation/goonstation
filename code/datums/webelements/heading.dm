/datum/tag/heading
	INIT(var/level = 1)
		..("h[level]")

	proc/setText(txt as text)
		innerHtml = txt
