/**
 * A bunch of procs for showing admins player data from the central API databases
 */


/**
 * Verbs
 */

/client/proc/cmd_admin_show_player_stats()
	set name = "Show Player Stats"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	ADMIN_ONLY

	var/ckey = input(usr, "Please enter a ckey", "Player Details", "") as text
	src.holder.showPlayerStats(ckey)


/client/proc/cmd_admin_show_player_ips()
	set name = "Show Player IPs"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	ADMIN_ONLY

	var/ckey = input(usr, "Please enter a ckey", "Player Details", "") as text
	src.holder.showPlayerIPs(ckey)


/client/proc/cmd_admin_show_player_compids()
	set name = "Show Player Computer IDs"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	ADMIN_ONLY

	var/ckey = input(usr, "Please enter a ckey", "Player Details", "") as text
	src.holder.showPlayerCompIDs(ckey)


/**
 * Procs-that-open-popups
 */

/datum/admins/proc/showPlayerStats(ckey)
	if (!ckey)
		return alert("You must provide a valid ckey.")
	if(src.tempmin)
		logTheThing(LOG_ADMIN, usr, "tried to access the player stats of [constructTarget(ckey,"admin")]")
		logTheThing(LOG_DIARY, usr, "tried to access the player stats of [constructTarget(ckey,"diary")]", "admin")
		message_admins("[key_name(usr)] tried to access the player stats of [ckey] but was denied.")
		alert("You need to be an actual admin to view player stats.")
		del(usr.client)
		return

	var/list/response
	try
		response = apiHandler.queryAPI("playerInfo/get", list("ckey" = ckey), forceResponse = 1)
	catch ()
		return alert("Failed to query API, try again later.")

	if (text2num(response["seen"]) < 1)
		return alert("No data found.")

	//Find the connected client, if present (ignore not found)
	var/client/C
	try
		C = getClientFromCkey(ckey)
	catch

	var/html = "<p><b>[capitalize(ckey)]</b> Stats</p>"

	html += "<table>"
	html += "<tr><td><b>Current status</b></td><td>[C ? "<span style='color: green;'>Online" : "<span style='color: red;'>Offline"]</span></td></tr>"
	html += "<tr><td><b>Rounds connected to</b></td><td>[response["seen"]]</td></tr>"
	html += "<tr><td><b>Rounds participated in</b></td><td>[response["participated"]]</td></tr>"
	html += "<tr><td><b>Rounds connected to, RP</b></td><td>[response["seen_rp"]]</td></tr>"
	html += "<tr><td><b>Rounds participated in, RP</b></td><td>[response["participated_rp"]]</td></tr>"
	html += "<tr><td><b>Last seen</b></td><td>[response["last_seen"]]</td></tr>"
	html += "<tr><td><b>Last seen BYOND version</b></td><td>[response["byondMajor"]].[response["byondMinor"]]</td></tr>"
	html += "<tr><td><b>Platform</b></td><td>[response["platform"]]</td></tr>"
	html += "<tr><td><b>Browser</b></td><td>[response["browser"]] [response["browserVersion"]][response["browserMode"] ? " ([response["browserMode"]])" : ""]</td></tr>"

	html += "<tr><td style='vertical-align: top;'><b>IP</b></td><td>"
	html += "Last seen: [response["last_ip"]]<br>"
	html += "<a href='?src=\ref[src];action=show_player_ips;ckey=[ckey];'>See All</a>"
	html += "</td></tr>"

	html += "<tr><td style='vertical-align: top;'><b>Computer ID</b></td><td>"
	html += "Last seen: [response["last_compID"]]<br>"
	html += "<a href='?src=\ref[src];action=show_player_compids;ckey=[ckey];'>See All</a>"
	html += "</td></tr>"

	html += "</table>"

	var/client/ownerC = src.owner
	ownerC.Browse(html, "window=playerStats[ckey];title=Player+Stats;size=500x380", 1)


/datum/admins/proc/showPlayerIPs(ckey)
	if (!ckey)
		return alert("You must provide a valid ckey.")
	if(src.tempmin)
		logTheThing(LOG_ADMIN, usr, "tried to access the player IPs of [constructTarget(ckey,"admin")]")
		logTheThing(LOG_DIARY, usr, "tried to access the player IPs of [constructTarget(ckey,"diary")]", "admin")
		message_admins("[key_name(usr)] tried to access the player IPs of [ckey] but was denied.")
		alert("You need to be an actual admin to view player IPs.")
		del(usr.client)
		return

	var/list/response
	try
		response = apiHandler.queryAPI("playerInfo/getIPs", list("ckey" = ckey), forceResponse = 1)
	catch ()
		return alert("Failed to query API, try again later.")

	if (length(response) < 1)
		return alert("No data found.")

	var/html = "<p><b>[capitalize(ckey)]</b> IP History</p>"
	html += "<p><b>Last seen IP:</b> [response[1]["last_seen"]]</p>"

	html += "<table>"
	html += "<thead><tr>"
	html += "<th style='text-align: left;'>IP</th>"
	html += "<th style='text-align: left;'>Times connected</th>"
	html += "</tr></thead>"

	for (var/list/details in response)
		html += "<tr><td>[details["ip"]]</td><td>[details["times"]]</td></tr>"

	html += "</table>"

	var/client/ownerC = src.owner
	ownerC.Browse(html, "window=playerStatsIPs[ckey];title=IP+History;size=300x250", 1)


/datum/admins/proc/showPlayerCompIDs(ckey)
	if (!ckey)
		return alert("You must provide a valid ckey.")
	if(src.tempmin)
		logTheThing(LOG_ADMIN, usr, "tried to access the player compIDs of [constructTarget(ckey,"admin")]")
		logTheThing(LOG_DIARY, usr, "tried to access the player compIDs of [constructTarget(ckey,"diary")]", "admin")
		message_admins("[key_name(usr)] tried to access the player compIDs of [ckey] but was denied.")
		alert("You need to be an actual admin to view player compIDs.")
		del(usr.client)
		return

	var/list/response
	try
		response = apiHandler.queryAPI("playerInfo/getCompIDs", list("ckey" = ckey), forceResponse = 1)
	catch ()
		return alert("Failed to query API, try again later.")

	if (length(response) < 1)
		return alert("No data found.")

	var/html = "<p><b>[capitalize(ckey)]</b> Computer ID History</p>"
	html += "<p><b>Last seen Computer ID:</b> [response[1]["last_seen"]]</p>"

	html += "<table>"
	html += "<thead style='text-align: left;'><tr>"
	html += "<th style='text-align: left;'>Computer ID</th>"
	html += "<th style='text-align: left;'>Times connected</th>"
	html += "</tr></thead>"

	for (var/list/details in response)
		html += "<tr><td>[details["compID"]]</td><td>[details["times"]]</td></tr>"

	html += "</table>"

	var/client/ownerC = src.owner
	ownerC.Browse(html, "window=playerStatsCompIDs[ckey];title=Computer+ID+History;size=300x250", 1)
