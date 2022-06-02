// Put any effects the detective may want here
ABSTRACT_TYPE(/datum/microbioeffects/forensics)
/datum/microbioeffects/forensics
	name = "Forensic Effects"

//datum/microbioeffects/forensics/germidentity
	//Create groups of 3-5 for all players with a "germ identity"
	//The groups have similar germ cultures that cannot be washed off.

	//On Objects: If the object (a door, gun, etc.) has obscured fingerprints, produce the list of names from the
	//germ group that includes the name of the unknown fingerprinter.

	//Expected outcome: Sec can get a suspect list even when the perp leaves only (insulated) glove threads!
	//Probable outcome: Because most players keep gloves, sec won't need this to find a gloved perp...

//datum/microbioeffects/forensics/sherlock

	//On Dead Mob: Reveals the dead player's final words.

	//Expected effect: Sec gains another lead option.
	//Probable effect: Nobody uses final words to out murderers...

//datum/microbioeffects/forensics/eyedentify

	//On Mob: Reveals the true names of obscured players (e.g. "Unknown" in a spacesuit would appear as "John Doe")

	//Expected effect: Sec will have the information to either ignore or chase obscured people.
	//Probable effect: Sec already detains IDless people...
