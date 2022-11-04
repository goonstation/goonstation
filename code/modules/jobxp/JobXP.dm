//List of KEY : TOTAL XP EARNED THIS ROUND. Used for post game stats, XP caps etc.
var/list/xp_earned = list()

//List of KEY : List(Timestamp : XP amount) used for throttling
var/list/xp_throttle_list = list()

//List of KEY : List(JOB : XP amount) used for end-of-round XP recaps and stat tracking
var/list/xp_archive = list()

var/list/xp_cache = list()

/proc/testSummary(var/amt = 1)
	award_xp(usr.key, "Bip", amt, 1)
	award_xp(usr.key, "Bop", amt, 1)
	sleep(1 SECOND)
	SPAWN(0) show_xp_summary(usr.key, usr)
	return

/proc/show_xp_summary(var/key, var/mob/M) //ONLY EVER SPAWN THIS
	if(key in xp_archive)
		var/loadingHtml = {"<p>Loading your XP stats. Hang on ...</p><br>"}
		M.Browse(loadingHtml, "window=xpsummary;size=350x450;title=Experience")

		var/html = {"<link rel="stylesheet" type="text/css" href="[resource("css/style.css")]">"}

		var/list/keyList = xp_archive[key]
		var/hasEntries = 0
		for(var/job in keyList)
			hasEntries = 1
			var/xpEarned = keyList[job]
			var/xpTotal = get_xp(key, job)

			html += {"<p>[job] +[xpEarned]xp</p>"}

			if(xpTotal)
				var/prc = (LEVEL_FOR_XP(xpTotal) - round(LEVEL_FOR_XP(xpTotal))) //This is required since modulo refuses to work. Thanks byond.
				prc *= 100
				prc = round(prc)
				html += {"<span style="float:left">Level [round(LEVEL_FOR_XP(xpTotal)+1)]</span><span style="float:right">Level [round(LEVEL_FOR_XP(xpTotal)+2)]</span><br>"}
				html += {"<div class="progress-bar"><div class="progress" style="width: [min(prc, 100)]%"></div></div><br><br>"}

		if(!hasEntries)
			html += {"<p>No experience earned.</p><br>"}

		M.Browse(html, "window=xpsummary;size=350x450;title=Experience")
	return

/proc/is_eligible_xp(key, xp)
	if(!xp_throttle_list.Find(key))
		return 1
	var/list/original = xp_throttle_list[key]
	if(!original.len)
		return 1
	var/total = 0
	for(var/x in original)
		if((world.time - text2num(x)) > XP_THROTTLE_TICKS)
			original.Remove(x)
			continue
		else
			total += original[x]
	xp_throttle_list[key] = original
	if(total >= XP_THROTTLE_AMT)
		return 0
	else
		return 1

/proc/add_xp_throttle_entry(var/key, var/amount)
	if(!xp_throttle_list[key])
		xp_throttle_list[key] = list()

	var/list/curr_list = xp_throttle_list[key]
	var/list/curr_time = world.time
	curr_list["[curr_time]"] = amount
	xp_throttle_list[key] = curr_list
	return

/proc/archive_xp(var/key, var/field, var/amount)
	if(!xp_archive[key])
		xp_archive[key] = list()

	var/list/curr_list = xp_archive[key]
	var/amt = amount

	if(curr_list["[field]"])
		amt = curr_list["[field]"]
		amt += amount

	curr_list["[field]"] = amt
	xp_archive[key] = curr_list
	return

//Wrapper for add_xp which handles XP multipliers, caps etc. Use this.
/proc/award_xp(var/key = null, var/field_name="debug", var/amount = 0, var/ignore_caps=0)
	if(!key) return null
	var/actual = round(amount * XP_GLOBAL_MOD)

	if(is_eligible_xp(key, amount) || (amount >= XP_THROTTLE_AMT) || ignore_caps)
		if(xp_earned[key] && !ignore_caps)
			if(xp_earned[key] + (amount * XP_GLOBAL_MOD) > XP_ROUND_CAP)
				actual = (XP_ROUND_CAP - xp_earned[key])

		if(actual >= 0)
			// SPAWN(0)
				// add_xp(key, field_name, actual)
			add_xp_throttle_entry(key, actual)
			archive_xp(key, field_name, actual)
	return
//Wrapper for awarding exp without actually adding it to the byond medals database
/proc/award_xp_and_archive(var/key = null, var/field_name="debug", var/amount = 0, var/ignore_caps=0)
	if(!key) return null
	var/actual = round(amount * XP_GLOBAL_MOD)

	if(is_eligible_xp(key, amount) || (amount >= XP_THROTTLE_AMT) || ignore_caps)
		if(xp_earned[key] && !ignore_caps)
			if(xp_earned[key] + (amount * XP_GLOBAL_MOD) > XP_ROUND_CAP)
				actual = (XP_ROUND_CAP - xp_earned[key])

		if(actual >= 0)
			SPAWN(0)
				add_xp_throttle_entry(key, actual)
				archive_xp(key, field_name, actual)
	return

//Saves the xp gained by players in this round into the byond scores db
//Only to be used at round end.
var/global/awarded_xp = 0
/proc/award_archived_round_xp()
	if (awarded_xp)
		message_admins("Tried to award job exp for the round more than once. Probably some fuckery is going on.")
		logTheThing(LOG_DEBUG, null, "Tried to award job exp for the round more than once. Probably some fuckery is going on.")
		return
	if (!islist(xp_archive))
		return
	awarded_xp = 1

	for (var/key in xp_archive)
		SPAWN(0)
			var/list/v_list = xp_archive[key]
			for (var/field in v_list)		//field is the job. Botanist, Clown, etc.
				var/amt = v_list["[field]"]
				amt = clamp(amt,0,XP_ROUND_CAP)
				add_xp(key, field, amt)

//wrapper for set_xp
/proc/add_xp(var/key = null, var/field_name="debug", var/amount = 0)
	if(!key) return null

	var/field = get_xp(key, field_name)

	if(field && !isnull(field))
		if((field + amount) > 0)
			set_xp(key, field_name, field + amount)
	else
		if(amount > 0 && !isnull(field))
			set_xp(key, field_name, amount)
	return

/proc/get_xp(key, field_name="debug", force_new=FALSE)
	if(!key) return null
	if (IsGuestKey(key))
		return null
	else if (!config)
		return null
	else if (!config.medal_hub || !config.medal_password)
		return null
	if(!(key in xp_cache) || force_new)
		var/response = world.GetScores(key, null, config.medal_hub, config.medal_password)
		if(isnull(response))
			return null
		xp_cache[key] = params2list(response)
		for(var/field in xp_cache[key])
			var/num = text2num(xp_cache[key][field])
			if(!isnull(num))
				xp_cache[key][field] = num
	if(field_name in xp_cache[key])
		return xp_cache[key][field_name]
	return 0

/proc/get_level(var/key = null, var/field_name="debug")
	var/xp = get_xp(key, field_name)
	if(xp)
		return round(LEVEL_FOR_XP(xp))
	return null

//Actually sets the xp on byond scores
/proc/set_xp(var/key = null, var/field_name="debug", var/field_value="0")
	if(!key) return null
	if (IsGuestKey(key))
		return null
	else if (!config)
		return null
	else if (!config.medal_hub || !config.medal_password)
		return null
	var/result = world.SetScores(key, "[field_name]=[field_value]", config.medal_hub, config.medal_password)
	return result
