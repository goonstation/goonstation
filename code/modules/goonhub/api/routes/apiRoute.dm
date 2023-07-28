

/// Base apiCall type
/// Represents a predefined query we can make to the Goonhub API
/// SECURITY: Sanitization occurs right before output
/datum/apiRoute
	/// HTTP Method this call uses, for example `RUSTG_HTTP_METHOD_GET`
	var/method = null
	/// Actual path of the api query, for example `/rounds`
	var/path = null
	/// Parameters for the call
	var/list/parameters = null
	/// The expected type upon deserialization
	var/correct_response = "string"


/// Formats a given parameter associated list into a urlstring format
/// E.g. `list("ckey"="zewaka") to `?&ckey=zewaka` and `list("x"=list("a", "b"))` to `?&x=a,b`
/datum/apiRoute/proc/formatParams()
	if (length(src.parameters))
		var/paramListClone = src.parameters.Copy()
		for (var/key in paramListClone)
			if (islist(paramListClone[key])) // Do we need to encode the value?
				paramListClone[key] = jointext(paramListClone[key], ",") // lists become csvs by convention
		. = list2params(.)
