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
		"ckey" = player,
		"format" = "json"
	)

	// Fetch notes via HTTP
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.player_notes_baseurl]/?[list2params(data)]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()

	if (response.errored || !response.body)
		logTheThing(LOG_DEBUG, null, "viewPlayerNotes: Failed to fetch notes of player: [player].")
		alert("Failed to fetch notes for [player].")
		return

	var/content = response.body
	// var/content = file2text('data/_TEST_.json')
	var/all_notes = json_decode(content)

	var/datum/player/pdatum = make_player(player)
	pdatum.cloud_fetch()
	var/noticelink = ""
	if (pdatum.cloud_available() && pdatum.cloud_get("login_notice"))
		noticelink = {" style="color: red; font-weight: bold;">Login Notice Set"}
	else
		noticelink = {">Add Login Notice"}

	var/list/dat = list({"
		<title>Player Notes - [player]</title>
		<style>
			body { background: #101018; color: #fff; font-family: Verdana, sans-serif; }
			table { width: 100%; border-spacing: 1px; }
			a { color: #88f; }
			th { background: #558; padding: 0.1em 0.25em; }
			td { background: #223; padding: 0.25em 0.5em; }
			.auto th { background: #446; color: #eee; }
			.auto td { background: #112; color: #aaa; }
			.ban th { background: #855; }
			.ban td { background: #633; }
			.auto.ban th { background: #644; }
			.auto.ban td { background: #311; }
			.empty td { padding: 0.25em; background: none;}
			blockquote { font-style: italic; margin: 0.3em 0 0.3em 3em; }
		</style>
		"})

	dat += "<h1 style='text-align: center;'>Player Notes for <b>[player]</b></h1><center><a href='?src=\ref[src];action=notes2;target=[player];type=add'>Add Note</A> - <a href='?src=\ref[src];action=loginnotice;target=[player]'[noticelink]</a></center><br><br><table><tbody>"

	if (all_notes["error"])
		dat += "No notes. <i>Yet.</i>"

	else

		for (var/i in 1 to length(all_notes))
			var/list/row_classes = list()

			// somehow newlines in notes are 0D 0D 0A
			// i don't know how the fuck this happened
			// but what the FUCK, byond
			all_notes[i]["note"] = replacetext(all_notes[i]["note"], "\x0D", "")

			// screaming
			if (all_notes[i]["akey"] == "Auto Banner" || all_notes[i]["akey"] == "VPN Blocker" || all_notes[i]["akey"] == "(AUTO)")
				row_classes += "auto"

			var/regex/R = new("Banned from (.+?) by (.+?), reason: (.+), duration: (.+)", "m")
			if (R.Find(all_notes[i]["note"]))
				row_classes += "ban"
				all_notes[i]["note"] = R.Replace(all_notes[i]["note"], "<b>BANNED</b> from <b>$1</b> by <b>$2</b> &mdash; $4<br><blockquote>$3</blockquote>")


			var/classes = row_classes.Join(" ")
			dat += {"
			<tr class="[classes]">
				<th>[all_notes[i]["server"]]</th>
				<th>[all_notes[i]["created"]]</th>
				<th style='width: 0; white-space: pre;'>#[all_notes[i]["id"]] <a href="?src=\ref[src];action=notes2;target=[player];type=del;id=[all_notes[i]["id"]]" style="background: red; color: white; display: inline-block; text-align: center; padding: 0.1em 0.25em; border-radius: 4px; text-decoration: none;">&times;</a></th>
			</tr>
			<tr class="[classes]" style="margin-bottom: 1em;">
				<th>[all_notes[i]["akey"]]</th>
				<td colspan="2" style="white-space: pre-wrap;">[all_notes[i]["note"]]</td>
			</tr>
			<tr class='empty'><td colspan='3'></td></tr>
			"}

		dat += "</table>"

	usr.Browse(dat.Join(""), "window=notesp;size=875x600;title=Notes for [player]")


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
