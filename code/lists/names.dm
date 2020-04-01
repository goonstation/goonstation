var/list/ai_names = dd_file2list("strings/names/ai.txt")
var/list/monkey_names = dd_file2list("strings/names/monkeynames.txt")
var/list/commando_names = dd_file2list("strings/names/death_commando.txt")
var/list/first_names_male = dd_file2list("strings/names/first_male.txt")
var/list/first_names_female = dd_file2list("strings/names/first_female.txt")
var/list/last_names = dd_file2list("strings/names/last.txt")
var/list/loggedsay = dd_file2list("strings/names/loggedsay.txt")
//var/list/wiz_male = dd_file2list("strings/names/wizard_male.txt")
//var/list/wiz_female = dd_file2list("strings/names/wizard_female.txt")
//loaded on startup because of "
//would include in rsc if ' was used

// temporary measure until I can talk to someone re: wizard name files being broken or something?
var/list/wiz_male = list("Gandalf",
"The Witch King",
"Rincewind",
"Shazam",
"Merlin",
"Voldemort",
"Dumbledore",
"Snape",
"Wizard Whitebeard",
"Prospero",
"Elminster",
"Rasputin",
"Thulsa Doom",
"Lord Zedd",
"Zordon",
"Constantine",
"Faust",
"Doctor Strange",
"Mr. Mxyzptlk",
"Astaroth",
"Nemesis the Warlock")
var/list/wiz_female = list("Queen Mab",
"Nanny Ogg",
"Granny Weatherwax",
"Baba Yaga",
"Wicked Witch of the West",
"Morgan le Fay",
"Circe",
"Malificent",
"Hermione",
"Umbridge",
"The Worst Witch",
"Sabrina",
"Morrigan",
"Ursula",
"Buffy")

/proc/print_wname_list() // totally inelegant debug thing
	var/list_to_check = input(usr, "Select list", "Select list") as null|anything in list("wiz_male", "wiz_female")
	if (!list_to_check)
		return
	switch(list_to_check)
		if ("wiz_male")
			if (!islist(wiz_male) || !wiz_male.len)
				DEBUG_MESSAGE("wiz_male is blank")
				return
			for (var/i in wiz_male)
				boutput(world, i)

		if ("wiz_female")
			if (!islist(wiz_female) || !wiz_female.len)
				DEBUG_MESSAGE("wiz_female is blank")
				return
			for (var/i in wiz_female)
				boutput(world, i)

//
