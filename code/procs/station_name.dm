/*
	Hello good coder sir!

	Recently the quality of these lists went down, like WAY DOWN.

	The only things that should be in the random name lists are
	science fiction themed things and references to
	existing science fiction media (movies, books, etc).

	If you wish to add anything else, FUCK YOU AND DIE.

	(and don't add it)

	-Rick
*/

#define MAX_STATION_NAME_LENGTH 40

var/global/station_name_changing = 1 //Are people allowed to change the station name?
var/global/station_or_ship = null
var/global/station_name = null
var/global/the_station_name = null
var/global/list/station_name_whitelist = new()
var/global/list/station_name_whitelist_sectioned = new()

var/global/stationNameChangeDelay = 1 MINUTE //deciseconds. 600 = 60 seconds
var/global/lastStationNameChange = 0 //timestamp

/mob/proc/openStationNameChangeWindow(source, submitRoute)
	if (!length(station_name_whitelist_sectioned))
		build_station_name_whitelist()

	var/changerHtml = grabResource("html/stationNameChanger.html")
	changerHtml = replacetext(changerHtml, "JSON Goes Here", json_encode(station_name_whitelist_sectioned))
	changerHtml = replacetext(changerHtml, "action=\"\"", "action=\"?src=\ref[source];[submitRoute];\"")
	changerHtml = replacetext(changerHtml, "MAXLENGTH_HERE", MAX_STATION_NAME_LENGTH)
	changerHtml = replacetext(changerHtml, "ADMIN_USER_HERE", "[isadmin(src)]")
	src.Browse(changerHtml, "window=stationnamechanger;size=600x500;title=Station+Namer+Deluxe+3000;", 1)

/proc/station_or_ship()
	if (station_or_ship)
		return station_or_ship
	if (map_settings)
		station_or_ship = map_settings.style
	else if (ismap("DESTINY") || ismap("CLARION") || ismap("HORIZON") || ismap("ATLAS"))
		station_or_ship = "ship"
	else
		station_or_ship = "station"
	return station_or_ship


/proc/generate_random_station_name()
	var/name = ""

	//halloween prefixes, temporary thing
#ifdef HALLOWEEN
	name += pick_string("station_name.txt", "halloweenPrefixes")
	name += " "
#endif

	if (map_settings && istext(map_settings.display_name))
		name += map_settings.display_name

	else
		// Prefix
		if (prob(20))
			name += pick_string("station_name.txt", "prefixes1")
			name += pick_string("station_name.txt", "prefixes2")
			name += " "
		else if (prob(15))
			name += pick_string("station_name.txt", "prefixes2")
			name += " "

		// Location
		if (prob(50))
			name += pick_string("station_name.txt", "frontierLocations")
			name += " "
			if (prob(40))
				name += pick_string("station_name.txt", "prefixes3")
				name += " "
		// Type
		else
			name += pick_string("station_name.txt", "prefixes3")
			name += " "

		// Suffix
		name += pick_string("station_name.txt", "suffixes")
		name += " "

		// ID Number
		if (prob(50))
			name += "[rand(1, 99)]"
		else if (prob(3))
			name += "3000"
		else if (prob(3))
			name += "9000"
		else if (prob(1))
			name += "14000000000"
		else if (prob(10))
			name += "205[pick(1, 3)]"
		else if (prob(50))
			name += pick_string("station_name.txt", "greek")
		else if (prob(40))
			name += pick_string("station_name.txt", "romanNum")
		else if (prob(20))
			name += pick_string("station_name.txt", "militaryLetters")
		else
			name += pick_string("station_name.txt", "numbers")

	return name


/proc/build_station_name_whitelist()
	var/list/whitelist_lists = list(
		"prefixes" = "Prefixes",
		"adjectives" = "Adjectives",
		"frontierLocations" = "Frontier Locations",
		"frontierBodies" = "Frontier Bodies",
		"solBodies" = "Sol System Bodies",
		"organizations" = "Organizations",
		"countries" = "Countries",
		"directions" = "Directions",
		"suffixes" = "Suffixes",
		//"languageprefixes" = "Language Prefixes",
		//"languagesuffixes" = "Language Suffixes",
		"pettingzooanimals" = "Petting Zoo Animals",
		"greek" = "Greek",
		"romanNum" = "Roman Numerals",
		"militaryLetters" = "Military Letters",
		"numbers" = "Numbers",
		"misc" = "Misc. Nonsense",
		"admins" = "Admins",
		"verbs" = "Verbs",
		"nouns" = "Nouns"
	)

	sortList(whitelist_lists, /proc/cmp_text_asc)

	for (var/section in whitelist_lists)
		var/list/words = strings("station_name_whitelist.txt", section)
		station_name_whitelist_sectioned += list(whitelist_lists[section] = sortList(words, /proc/cmp_text_asc))

		for (var/word in words)
			station_name_whitelist += lowertext(word)

			if (findtextEx(word, uppertext(word)))
				station_name_whitelist[lowertext(word)] = list("allcaps" = 1)


//Verifies the given name matches a whitelist of words, only run on a manual setting of station name
/proc/verify_station_name(name, adminset)
	//Admins can just kinda set it to whatever
	if (adminset)
		return trim(name)

	name = lowertext(trim(name))

	if (length(name) < 1 || length(name) > MAX_STATION_NAME_LENGTH)
		return 0

	if (!length(station_name_whitelist))
		build_station_name_whitelist()

	var/valid = 1
	var/list/words = splittext(name, " ")
	var/formattedName = ""

	for (var/word in words)
		if (isnum(text2num(word)))
			formattedName += "[word] "
			continue

		if (!(lowertext(word) in station_name_whitelist))
			valid = 0
			break

		//Does word contain metadata?
		if (islist(station_name_whitelist[lowertext(word)]))
			//Is this word defined as allcaps in the original txtfile?
			if (station_name_whitelist[lowertext(word)]["allcaps"])
				formattedName += "[uppertext(word)] "

		else
			formattedName += "[capitalize(word)] "

	return valid ? trim(formattedName) : valid


/proc/set_station_name(mob/user = null, manual = null, admin_override=null)
	if(isnull(admin_override) && ismob(user))
		admin_override = isadmin(user)

	var/name

	if (manual)
		if (!station_name_changing)
			return 0

		name = verify_station_name(manual, admin_override)

		if (!name)
			return 0

		phrase_log.log_phrase("stationname-[admin_override?"admin":"player"]", name, no_duplicates=TRUE)

		#if defined(REVERSED_MAP)
		name = reverse_text(name)
		#endif

		the_station_name = name

		if (user)
			logTheThing(LOG_ADMIN, user, "changed the station name to: [name]")
			logTheThing(LOG_DIARY, user, "changed the station name to: [name]", "admin")
			message_admins("[key_name(user)] changed the station name to: [name]")

			var/ircmsg[] = new()
			ircmsg["key"] = ismob(user) ? user.client.key : user
			ircmsg["name"] = ismob(user) ? ((user?.real_name) ? stripTextMacros(user.real_name) : "NULL") : null
			ircmsg["msg"] = "changed the station name to [name]"
			ircbot.export_async("admin", ircmsg)

	else
		name = generate_random_station_name()
		#if defined(REVERSED_MAP)
			name = reverse_text(name)
		#endif
		if (station_or_ship() == "ship")
#ifdef HALLOWEEN // a lot of the halloween prefixes already have a "the" at the start of them so we can skip that
			the_station_name = name
#else
			the_station_name = "the [name]"
#endif
		else
			the_station_name = name

	station_name = name

	if (config?.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = name

	return 1


/proc/station_name(var/the = 0)
	if (!station_name)
//#ifdef RP_MODE
//		//We disallow station name changing on RP servers for ~flavor~
//		station_name_changing = 0
//#endif
		set_station_name()

	return the ? the_station_name : station_name
