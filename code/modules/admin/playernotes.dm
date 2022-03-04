// Viewing a player's notes
/datum/admins/proc/viewPlayerNotes(var/player)
	if (!player)
		return

	if(src.tempmin)
		logTheThing("admin", usr, player, "tried to access the notes of [constructTarget(player,"admin")]")
		logTheThing("diary", usr, player, "tried to access the notes of [constructTarget(player,"diary")]", "admin")
		alert("You need to be an actual admin to view player notes.")
		return

	if (!config.opengoon_api_endpoint || !config.opengoon_api_token)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = md5(config.opengoon_api_token),
		"action" = "get",
		"ckey" = player
	)

	// Fetch notes via HTTP
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.opengoon_api_endpoint]/notes/?[list2params(data)]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()

	if (response.errored || !response.body)
		logTheThing("debug", null, null, "viewPlayerNotes: Failed to fetch notes of player: [player].")
		return

	var/content = response.body
	var/deletelinkpre = "<A href='?src=\ref[src];action=notes2;target=[player];type=del;id="
	var/deletelinkpost = "'>(DEL)"

	var/regex/R = new("!!ID(\\d+)", "g")
	content = R.Replace(content, "[deletelinkpre]$1[deletelinkpost]")

	var/dat = "<h1>Player Notes for <b>[player]</b></h1><HR><br><A href='?src=\ref[src];action=notes2;target=[player];type=add'>Add Note</A><br><HR>"
	dat += replacetext(content, "\n", "<br>")
	usr.Browse(dat, "window=notesp;size=875x400;title=Notes for [player]")


// Adding a player note
/proc/addPlayerNote(player, admin, note)
	if (!player || !admin || !note)
		return

	if (!config.opengoon_api_endpoint || !config.opengoon_api_token)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = md5(config.opengoon_api_token),
		"action" = "add",
		"server" = serverKey,
		"server_id" = config.server_id,
		"ckey" = player,
		"akey" = admin,
		"note" = note
	)

	// Send data
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.opengoon_api_endpoint]/notes/?[list2params(data)]", "", "")
	request.begin_async()


// Deleting a player note
/proc/deletePlayerNote(id)
	if (!id)
		return

	if (!config.opengoon_api_endpoint || !config.opengoon_api_token)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = md5(config.opengoon_api_token),
		"action" = "delete",
		"id" = id
	)

	// Send data
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.opengoon_api_endpoint]/notes/?[list2params(data)]", "", "")
	request.begin_async()
