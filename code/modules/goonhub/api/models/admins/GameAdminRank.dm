/// GameAdminRank
/datum/apiModel/Tracked/GameAdminRank
	var/rank = null // string

/datum/apiModel/Tracked/GameAdminRank/New(
	id,
	rank,
	created_at,
	updated_at,
)
	. = ..()
	src.id = id
	src.rank = rank
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/GameAdmin/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.rank) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/GameAdmin/ToString()
	. = list()
	.["id"] = src.id
	.["rank"] = src.rank
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
