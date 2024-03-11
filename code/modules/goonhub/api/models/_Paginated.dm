
ABSTRACT_TYPE(/datum/apiModel/Paginated)
/// Paginated - ABSTRACT
/// Anything with a paginated list inherits from this
/datum/apiModel/Paginated
	var/list/datum/apiModel/data = null
	var/list/links = null
	var/list/meta = null

/datum/apiModel/Paginated/SetupFromResponse(response)
	. = ..()
	src.links = response["links"]
	src.meta = response["meta"]

/datum/apiModel/Paginated/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.data) \
		|| isnull(src.links) \
		|| isnull(src.meta)
	)
		return FALSE

	for (var/datum/apiModel/item in src.data)
		if (!item.VerifyIntegrity())
			return FALSE

/datum/apiModel/Paginated/ToList()
	. = ..()
	.["data"] = list()
	for (var/datum/apiModel/item in src.data)
		.["data"] += list(item.ToList())
	.["links"] = src.links
	.["meta"] = src.meta
