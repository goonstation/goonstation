/datum/tag/input
	New(var/type as text)
		..("input")
		selfCloses = 1

	proc/setType(var/type as text)
		setAttribute("type", type)

	proc/setValue(var/value as text)
		setAttribute("value", value)

	proc/setName(var/name as text)
		setAttribute("name", name)
