// Viewing a player's notes
/datum/admins/proc/viewPlayerNotes(var/player)
	if (!player)
		return

	if(src.tempmin)
		logTheThing(LOG_ADMIN, usr, "tried to access the notes of [constructTarget(player,"admin")]")
		logTheThing(LOG_DIARY, usr, "tried to access the notes of [constructTarget(player,"diary")]", "admin")
		message_admins("[key_name(usr)] tried to access the notes of [player] but was denied.")
		alert("You need to be an actual admin to view player notes.")
		del(usr.client)
		return

	if (!config.player_notes_baseurl || !config.player_notes_auth)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = config.player_notes_auth,
		"action" = "get",
		"ckey" = player
	)

	// Fetch notes via HTTP
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.player_notes_baseurl]/?[list2params(data)]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()

	if (response.errored || !response.body)
		logTheThing(LOG_DEBUG, null, "viewPlayerNotes: Failed to fetch notes of player: [player].")
		return

	var/content = response.body
	var/deletelinkpre = "<A href='?src=\ref[src];action=notes2;target=[player];type=del;id="
	var/deletelinkpost = "'>(DEL)"

	var/regex/R = new("!!ID(\\d+)", "g")
	content = R.Replace(content, "[deletelinkpre]$1[deletelinkpost]")

	var/datum/player/pdatum = make_player(player)
	pdatum.cloud_fetch()
	var/noticelink = ""
	if (pdatum.cloud_available() && pdatum.cloud_get("login_notice"))
		noticelink = {" style="color: red; font-weight: bold;">Login Notice Set"}
	else
		noticelink = {">Add Login Notice"}

	var/dat = "<h1>Player Notes for <b>[player]</b></h1><HR><br><a href='?src=\ref[src];action=notes2;target=[player];type=add'>Add Note</A> - <a href='?src=\ref[src];action=loginnotice;target=[player]'[noticelink]</a><hr>"
	dat += replacetext(content, "\n", "<br>")
	usr.Browse(dat, "window=notesp;size=875x400;title=Notes for [player]")


// Adding a player note
/proc/addPlayerNote(player, admin, note)
	if (!player || !admin || !note)
		return

	if (!config.player_notes_baseurl || !config.player_notes_auth)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = config.player_notes_auth,
		"action" = "add",
		"server" = serverKey,
		"server_id" = config.server_id,
		"ckey" = player,
		"akey" = admin,
		"note" = note
	)

	// Send data
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.player_notes_baseurl]/?[list2params(data)]", "", "")
	request.begin_async()


// Deleting a player note
/proc/deletePlayerNote(id)
	if (!id)
		return

	if (!config.player_notes_baseurl || !config.player_notes_auth)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = config.player_notes_auth,
		"action" = "delete",
		"id" = id
	)

	// Send data
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.player_notes_baseurl]/?[list2params(data)]", "", "")
	request.begin_async()
