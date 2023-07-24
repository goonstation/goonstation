
/// PollResource
/datum/apiModel/PollResource
	var/game_admin_id									= null // integer
	var/datum/apiModel/GameAdmin/game_admin				= null // GameAdmin
	var/question										= null // string
	var/list/datum/apiModel/PollOptionResource/options	= null // [PollOptionResource]
	var/servers											= null // [string]
	var/total_answers									= null // integer
	var/winning_option_id								= null // integer
	var/multiple_choice									= null // boolean
	var/expires_at										= null // date-time
	var/created_at										= null // date-time
	var/updated_at										= null // date-time

/datum/apiModel/PollResource/New(
	id,
	game_admin_id,
	game_admin,
	question,
	options,
	servers,
	total_answers,
	winning_option_id,
	multiple_choice,
	expires_at,
	created_at,
	updated_at,
)
	. = ..()
	src.id = id
	src.game_admin_id = game_admin_id
	src.game_admin = game_admin
	src.question = question
	src.options = options
	src.servers = servers
	src.total_answers = total_answers
	src.winning_option_id = winning_option_id
	src.multiple_choice = multiple_choice
	src.expires_at = expires_at
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/PollResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.game_admin_id) \
		|| isnull(src.game_admin) \
		|| isnull(src.question) \
		|| isnull(src.options) \
		|| isnull(src.servers) \
		|| isnull(src.total_answers) \
		|| isnull(src.winning_option_id) \
		|| isnull(src.multiple_choice) \
		|| isnull(src.expires_at) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/PollResource/ToString()
	. = list()
	.["id"] = src.id
	.["game_admin_id"] = src.game_admin_id
	.["game_admin"] = src.game_admin
	.["question"] = src.question
	.["options"] = src.options
	.["servers"] = src.servers
	.["total_answers"] = src.total_answers
	.["winning_option_id"] = src.winning_option_id
	.["multiple_choice"] = src.multiple_choice
	.["expires_at"] = src.expires_at
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
