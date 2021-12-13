/datum/tag/span
	INIT(var/type as text)
		..("span")

	proc/setText(var/txt as text)
		src.innerHtml = txt
