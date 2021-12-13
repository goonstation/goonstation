/datum/tag/option
	INIT()
		..("option")

	proc/setValue(var/val as text)
		setAttribute("value", val)

	proc/setText(var/txt as text)
		innerHtml = txt
