var/command_name = null
/proc/command_name()
	if (command_name)
		return command_name

	var/name = ""

	if (prob(10))
		name += pick("Super", "Ultra", "Mega", "Supreme", "Grand", "Secret")
		name += " "

	// Prefix
	if (name)
		name += pick("", "Central", "System", "Galactic", "Space")
	else
		name += pick("Central", "System", "Galactic", "Space")
	if (name)
		name += " "

	// Suffix
	name += pick("Federation", "Command", "Alliance", "Unity", "Empire", "Confederation", "Protectorate", "Commonwealth", "Imperium", "Republic", "Corporate", "Authority", "Council", "System")
	//name += " "

	command_name = name
	return name

