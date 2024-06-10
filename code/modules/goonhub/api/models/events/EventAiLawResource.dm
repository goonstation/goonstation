
/// EventAiLawResource
/datum/apiModel/Tracked/EventAiLawResource
	var/round_id		= null // string
	var/player_id		= null // string
	var/ai_name			= null // string
	var/law_number		= null // string
	var/law_text		= null // string
	var/uploader_name	= null // string
	var/uploader_job	= null // string
	var/uploader_ckey	= null // string

/datum/apiModel/Tracked/EventAiLawResource/SetupFromResponse(response)
	. = ..()
	src.round_id = response["round_id"]
	src.player_id = response["player_id"]
	src.ai_name = response["ai_name"]
	src.law_number = response["law_number"]
	src.law_text = response["law_text"]
	src.uploader_name = response["uploader_name"]
	src.uploader_job = response["uploader_job"]
	src.uploader_ckey = response["uploader_ckey"]

/datum/apiModel/Tracked/EventAiLawResource/VerifyIntegrity()
	if (
		isnull(id) \
		|| isnull(src.round_id) \
		|| isnull(src.player_id) \
		|| isnull(src.ai_name) \
		|| isnull(src.law_number) \
		|| isnull(src.law_text) \
		|| isnull(src.uploader_name) \
		|| isnull(src.uploader_job) \
		|| isnull(src.uploader_ckey) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/EventAiLawResource/ToList()
	. = ..()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["player_id"] = src.player_id
	.["ai_name"] = src.ai_name
	.["law_number"] = src.law_number
	.["law_text"] = src.law_text
	.["uploader_name"] = src.uploader_name
	.["uploader_job"] = src.uploader_job
	.["uploader_ckey"] = src.uploader_ckey
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
