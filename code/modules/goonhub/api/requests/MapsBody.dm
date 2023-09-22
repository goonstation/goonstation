
/datum/apiBody/maps/generate
	var/map				= "string"
	var/images			= "string"

/datum/apiBody/maps/generate/New(
	map,
	images
)
	. = ..()
	src.map = map
	src.images = images

/datum/apiBody/maps/generate/VerifyIntegrity()
	if (
		isnull(src.map) \
		|| isnull(src.images) \
	)
		return FALSE

/datum/apiBody/maps/generate/toJson()
	return json_encode(list(
		"map"				= src.map,
		"images"			= src.images
	))
