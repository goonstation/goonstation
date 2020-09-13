// Viewing a player's notes
/datum/admins/proc/viewPlayerNotes(var/player)
	if (!player)
		return

	if(src.tempmin)
		logTheThing("admin", usr, player, "tried to access the notes of [constructTarget(player,"admin")]")
		logTheThing("diary", usr, player, "tried to access the notes of [constructTarget(player,"diary")]", "admin")
		alert("You need to be an actual admin to view player notes.")
		return

	if (!config.player_notes_baseurl || !config.player_notes_auth)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = config.player_notes_auth,
		"action" = "get",
		"ckey" = player
	)

	var/query = "[config.player_notes_baseurl]/?[list2params(data)]"
	var/http[] = world.Export(query)

	if(!http)
		alert("Query Failed.")
		return

	var/key
	var/contentExists = 0
	for (key in http)
		if (key == "CONTENT")
			contentExists = 1

	if (0 == contentExists)
		alert("Query Failed.")
		return

	var/content = file2text(http["CONTENT"])
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

	var/query = "[config.player_notes_baseurl]/?[list2params(data)]"
	world.Export(query)


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

	var/query = "[config.player_notes_baseurl]/?[list2params(data)]"
	world.Export(query)
