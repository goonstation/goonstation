
ABSTRACT_TYPE(/datum/apiModel/Paginated)
/// Paginated - ABSTRACT
/// Anything with a paginated list inherits from this
/datum/apiModel/Paginated
	var/list/data = null
	var/list/links = null
	var/list/meta = null

/datum/apiModel/Paginated/New(
	data,
	links,
	meta
)
	. = ..()
	src.data = data
	src.links = links
	src.meta = meta

/datum/apiModel/Paginated/setupFromResponse(response)
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

/datum/apiModel/Paginated/ToString()
	. = list()
	.["data"] = list()
	for (var/datum/apiModel/item in src.data)
		.["data"] += item.ToString()
	.["links"] = src.links
	.["meta"] = src.meta
	return json_encode(.)
