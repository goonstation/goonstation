

/// Base apiCall type
/// Represents a predefined query we can make to the Goonhub API
/// SECURITY: Sanitization occurs right before output
/datum/apiRoute
	/// HTTP Method this call uses, for example `RUSTG_HTTP_METHOD_GET`
	var/method = null
	/// Actual path of the api query, for example `/rounds`
	var/path = null
	/// Route parameters for the call, ie /rounds/{round_id}/
	var/list/routeParams = null
	/// Query parameters for the call, ie /rounds?&id=3
	var/list/queryParams = null
	/// Body of the request, invalid for GET
	var/datum/apiBody/body = null
	/// The expected type upon deserialization
	var/correct_response = "string"


/// Formats a given parameter associated list into a urlstring format
/// E.g. `list("ckey"="zewaka") to `?&ckey=zewaka` and `list("x"=list("a", "b"))` to `?&x=a,b`
/datum/apiRoute/proc/formatQueryParams()
	if (length(src.queryParams))
		var/paramListClone = src.queryParams.Copy()
		for (var/key in paramListClone)
			if (islist(paramListClone[key])) // Do we need to encode the value?
				paramListClone[key] = jointext(paramListClone[key], ",") // lists become csvs by convention
		. = list2params(.)

/// Formats a given parameter list into a route-append format
/// E.g. `list("tuesday", "wednesday")` to `tuesday/wednesday`
/datum/apiRoute/proc/formatRouteParams()
	if (length(src.routeParams))
		return jointext(src.routeParams, "/")
