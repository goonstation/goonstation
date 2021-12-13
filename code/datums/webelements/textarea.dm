/datum/tag/textarea
	INIT(var/type as text)
		..("textarea")

	proc/setName(var/name as text)
		setAttribute("name", name)

	proc/setValue(var/txt as text)
		innerHtml = txt
