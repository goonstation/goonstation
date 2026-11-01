

/// PlayerAdmin
/datum/apiModel/Tracked/PlayerAdmin
	var/player_id	= null // integer
	var/alias			= null // string|null
	var/datum/apiModel/Tracked/Player/player 			= null // Model - not required
	var/datum/apiModel/Tracked/GameAdminRank/rank = null // Model - not required

/datum/apiModel/Tracked/PlayerAdmin/SetupFromResponse(response)
	. = ..()
	src.player_id = response["player_id"]
	src.alias = response["alias"]
	src.rank = response["rank"]

	if (("player" in response) && islist(response["player"]))
		src.player = new
		src.player.SetupFromResponse(response["player"])

	if (("rank" in response) && islist(response["rank"]))
		src.rank = new
		src.rank.SetupFromResponse(response["rank"])

/datum/apiModel/Tracked/PlayerAdmin/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.player_id)
	)
		return FALSE

/datum/apiModel/Tracked/PlayerAdmin/ToList()
	. = ..()
	.["player_id"] = src.player_id
	.["alias"] = src.alias
	.["rank"] = src.rank
	.["player"] = src.player ? src.player.ToList() : src.player
	.["rank"] = src.rank ? src.rank.ToList() : src.rank
