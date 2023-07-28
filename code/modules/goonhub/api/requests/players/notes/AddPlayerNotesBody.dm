
/datum/apiBody/players/notes/post
  var/game_admin_ckey	= "string"
  var/round_id			= 0
  var/server_id			= "string"
  var/ckey				= "string"
  var/note				= "string"

/datum/apiBody/players/notes/post/toJson()
	return json_encode(list(
		"game_admin_ckey"	= src.game_admin_ckey,
		"round_id"			= src.round_id,
		"server_id"			= src.server_id,
		"ckey"				= src.ckey,
		"note"				= src.note,
	))
