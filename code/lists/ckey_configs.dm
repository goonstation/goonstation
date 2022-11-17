// Various configuration lists full of player ckeys

// Some of these are loaded in world/New(), some are loaded here.
// not sure why and don't want to risk breaking more things

/// Admins ( ["ckey"] = "rank" )
/// Populated by proc call in world.New()
var/global/list/admins = list()
var/global/list/onlineAdmins = list()

/// HoS/NTSO-whitelisted players
var/global/list/NT = load_config_list("config/nt.txt")

/// Mentors
var/global/list/mentors = load_config_list("config/mentors.txt")

/// Players whomst'd've get allowed if whitelist-only is enabled
var/global/list/whitelistCkeys = list()

// Players who are allowed to bypass the server's player cap
var/global/list/bypassCapCkeys = list()


/**
* Gets a list of ckeys from a file, ignoring comments/blank lines
* This could probably be refactored to config files in general, but
*/
/proc/load_config_list(filename, as_ckey = 1, secrets = 0)
	// "fexists doesn't count symlinks as files"
	// if (!fexists(filename)))
	//		throw EXCEPTION("lummox!!!!!!!!!!!!!!")

	var/list/result = list()

	#if defined(SECRETS_ENABLED) && !defined(LIVE_SERVER)
	if (!secrets)
		// If secrets are enabled, load config options from +secrets as well.
		// This way you can still have local additions to it.
		// This can probably be improved, since you can't *remove* entries,
		// just add new ones...
		result += load_config_list("[CONFIG_PATH_PREFIX][filename]", as_ckey, 1)
	#endif

	try
		// Get every line in the file as a list of lines
		// [CONFIG_PATH_PREFIX] here reads from +secret/config/ instead of config/,
		// if secrets are enabled.
		var/list/lines = dd_file2list(filename)

		if(!length(lines))
			throw EXCEPTION("No lines in config file")

		// Turn the list of lines into a different list of *valid* lines
		for(var/line in lines)
			if (!line)
				// Blank lines don't count
				continue
			if (copytext(line, 1, 2) == "#")
				// Comments don't count either
				continue

			result += (as_ckey ? ckey(line) : line)

	catch (var/exception/e)
		// this might not ever happen depending on what dd_file2list does
		// in the event of missing files. oh well
		logDiary("Failed to load config file '[filename]': [e]\n")
		#ifdef LIVE_SERVER
		if(!secrets)
			stack_trace("Failed to load config file '[filename]': [e]")
		#endif

	return result

/proc/load_admins()
	var/text = file2text("config/admins.txt")
	#if defined(SECRETS_ENABLED) && !defined(LIVE_SERVER)
	text += "\n" + file2text("[CONFIG_PATH_PREFIX]config/admins.txt")
	#endif
	if (!text)
		logDiary("Failed to load config/admins.txt\n")
	else
		var/list/lines = splittext(text, "\n")
		for(var/line in lines)
			if (!line)
				continue

			if (copytext(line, 1, 2) == "#")
				continue

			var/pos = findtext(line, " - ", 1, null)
			if (pos)
				var/m_key = ckey(copytext(line, 1, pos))
				var/a_lev = copytext(line, pos + 3, length(line) + 1)
				admins[m_key] = a_lev
				logDiary("ADMIN: [m_key] = [a_lev]")

/proc/load_whitelist(fileName = null)
	whitelistCkeys += load_config_list(!isnull(fileName) ? fileName : config.whitelist_path)
	logDiary("Whitelisted ckeys: [jointext(whitelistCkeys, ", ")]")


/proc/load_playercap_bypass()
	bypassCapCkeys += load_config_list("config/allow_thru_cap.txt")
	logDiary("Bypass Cap ckeys: [jointext(bypassCapCkeys, ", ")]")

