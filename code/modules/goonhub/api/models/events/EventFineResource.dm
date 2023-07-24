
/// EventFineResource
/datum/apiModel/EventFineResource
	var/round_id	= null // string
	var/player_id	= null // string
	var/target		= null // string
	var/reason		= null // string
	var/issuer		= null // string
	var/issuer_job	= null // string
	var/issuer_ckey	= null // string
	var/amount		= null // string
	var/created_at	= null // date-time
	var/updated_at	= null // date-time

/datum/apiModel/EventFineResource/New(
	id,
	round_id,
	player_id,
	target,
	reason,
	issuer,
	issuer_job,
	issuer_ckey,
	amount,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.round_id = round_id
	src.player_id = player_id
	src.target = target
	src.reason = reason
	src.issuer = issuer
	src.issuer_job = issuer_job
	src.issuer_ckey = issuer_ckey
	src.amount = amount
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/EventFineResource/VerifyIntegrity()
	if (
		isnull(id)
		|| isnull(src.round_id)
		|| isnull(src.player_id)
		|| isnull(src.target)
		|| isnull(src.reason)
		|| isnull(src.issuer)
		|| isnull(src.issuer_job)
		|| isnull(src.issuer_ckey)
		|| isnull(src.amount)
		|| isnull(src.created_at)
		|| isnull(src.updated_at)
	)
		return FALSE

/datum/apiModel/EventFineResource/ToString()
	. = list()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["player_id"] = src.player_id
	.["target"] = src.target
	.["reason"] = src.reason
	.["issuer"] = src.issuer
	.["issuer_job"] = src.issuer_job
	.["issuer_ckey"] = src.issuer_ckey
	.["amount"] = src.amount
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
