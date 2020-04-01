var/church_name = null
/proc/church_name()
	if (church_name)
		return church_name

	var/name = ""
	
	name += pick("Holy", "United", "First", "Second", "Last", "Primary", "Secondary", "Tertiary", "Unholy", "Exiled", "Exalted", "Free")
	
	if (prob(20))
		name += " Space"
	else if (prob(10))
		name += " "
		name += pick("Galactic", "Universal", "Dimensional")
	
	name += " " + pick("Church", "Cathedral", "Body", "Worshippers", "Movement", "Witnesses", "Followers", "Ascendants", "Society", "Fellowship", "Order", "Community", "School", "Assembly", "Assemblies", "Association", "Foundation", "Gate", "Trust", "Temple", "Mission", "Union", "Brotherhood", "Sisterhood", "Fraternity")
	name += " of [religion_name()]"
	
	return name
