

/// Base apiCall type
/// Represents a predefined query we can make to the Goonhub API
/// SECURITY: Sanitization occurs right before output
/datum/apiRoute
	/// HTTP Method this call uses, for example `RUSTG_HTTP_METHOD_GET`
	var/method = null
	/// Actual path of the api query, for example `/rounds`
	var/path = null
	/// Route parameters for the call, ie /rounds/{round_id}/ - Must be in order
	var/list/routeParams = null
	/// Query parameters for the call, ie /rounds?&id=3
	var/list/queryParams = null
	/// Body of the request, invalid for GET
	var/datum/apiBody/body = null
	/// The expected type upon deserialization
	var/correct_response = null
	/// Is this request allowed to automatically retry if it fails?
	var/allow_retry = TRUE


/// Formats a given parameter associated list into a urlstring format
/// E.g. `list("ckey"="zewaka") to `?&ckey=zewaka` and `list("x"=list("a" = "foo", "b" = "bar"))` to `?&x[a]=foo&x[b]=bar`
/datum/apiRoute/proc/formatQueryParams()
	if (length(src.queryParams))
		. = list()
		for (var/key in src.queryParams)
			if (islist(src.queryParams[key])) // Do we need to encode the value?
				if (length(src.queryParams[key]) > 0)
					for (var/subKey in src.queryParams[key])
						if (islist(src.queryParams[key][subKey]))
							if (length(src.queryParams[key][subKey]))
								for (var/idx in 1 to length(src.queryParams[key][subKey]))
									// encode in array syntax e.x. ?&filters[servers][0]=main3&filters[servers][1]=main4
									.["[key]\[[subKey]\]\[[idx-1]\]"] = src.queryParams[key][subKey][idx]
							else
								.["[key]\[[subKey]\]\[\]"] = null
						else
							.["[key]\[[subKey]\]"] = src.queryParams[key][subKey]
				else
					.["[key]\[\]"] = null
			else
				.[key] = src.queryParams[key]
		. = list2params(.)

/// Formats a given parameter list into a route-append format
/// E.g. `list("tuesday", "wednesday")` to `tuesday/wednesday`
/datum/apiRoute/proc/formatRouteParams()
	if (length(src.routeParams))
		return jointext(src.routeParams, "/")

/datum/apiRoute/proc/buildBody(list/fieldValues)
	src.body = new src.body(fieldValues)
