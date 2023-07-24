
/// PlayerMetadataResource
/datum/apiModel/PlayerRes/PlayerMetadataResource
	var/player	= null // { id: integer, ckey: string }
	var/ckey	= null // string
	var/data	= null // integer

/datum/apiModel/PlayerRes/PlayerMetadataResource/New(
	id,
	player,
	ckey,
	data,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player = player
	src.ckey = ckey
	src.data = data
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/PlayerRes/PlayerMetadataResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player) \
		|| isnull(src.ckey) \
		|| isnull(src.data) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/PlayerRes/PlayerMetadataResource/ToString()
	. = list()
	.["id"] = src.id
	.["player"] = src.player
	.["ckey"] = src.ckey
	.["data"] = src.data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
