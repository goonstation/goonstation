
/// PollResource
/datum/apiModel/Tracked/PollResource
	var/game_admin_id									= null // integer
	var/datum/apiModel/Tracked/GameAdmin/game_admin		= null // GameAdmin
	var/question										= null // string
	var/list/datum/apiModel/PollOptionResource/options	= null // [PollOptionResource]
	var/servers											= null // [string]
	var/total_answers									= null // integer
	var/winning_option_id								= null // integer
	var/multiple_choice									= null // boolean
	var/expires_at										= null // date-time

/datum/apiModel/Tracked/PollResource/SetupFromResponse(response)
	. = ..()
	src.game_admin_id = response["game_admin_id"]
	if ("game_admin" in response)
		src.game_admin = new
		src.game_admin.SetupFromResponse(response["game_admin"])
	src.question = response["question"]
	src.options = list()
	for (var/item in response["options"])
		var/datum/apiModel/PollOptionResource/option = new
		option.SetupFromResponse(item)
		src.options.Add(option)
	src.servers = response["servers"]
	src.total_answers = response["total_answers"]
	src.winning_option_id = response["winning_option_id"]
	src.multiple_choice = response["multiple_choice"]
	src.expires_at = response["expires_at"]

/datum/apiModel/Tracked/PollResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.question) \
	)
		return FALSE

/datum/apiModel/Tracked/PollResource/ToList()
	. = ..()
	.["id"] = src.id
	.["game_admin_id"] = src.game_admin_id
	if (src.game_admin)
		.["game_admin"] = src.game_admin.ToList()
	.["question"] = src.question
	.["options"] = list()
	for (var/datum/apiModel/PollOptionResource/option in src.options)
		.["options"] += list(option.ToList())
	.["servers"] = src.servers
	.["total_answers"] = src.total_answers
	.["winning_option_id"] = src.winning_option_id
	.["multiple_choice"] = src.multiple_choice
	.["expires_at"] = src.expires_at
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
