
/// PlayerMedalResource
/datum/apiModel/Tracked/PlayerRes/PlayerMedalResource
	var/medal_id = null // integer
	var/datum/apiModel/Tracked/MedalResource/medal = null // /datum/apiModel/Tracked/MedalResource - not required
	var/round_id = null // integer

/datum/apiModel/Tracked/PlayerRes/PlayerMedalResource/SetupFromResponse(response)
	. = ..()
	src.medal_id = response["medal_id"]
	if ("medal" in response)
		src.medal = new
		src.medal.SetupFromResponse(response["medal"])
	src.round_id = response["round_id"]

/datum/apiModel/Tracked/PlayerRes/PlayerMedalResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.medal_id) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerMedalResource/ToList()
	. = ..()
	.["medal_id"] = src.medal_id
	if (src.medal)
		.["medal"] = src.medal.ToList()
	.["round_id"] = src.round_id
