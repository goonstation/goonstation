

/// Base apiCall type
/// Represents a predefined query we can make to the Goonhub API
/// SECURITY: Sanitization occurs right before output
/datum/apiCall
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
/datum/apiCall/proc/formatParams(var/list/paramList)
  if (length(paramList))
    . = list("?")
    for (var/key in paramList)
      var/value = paramList[key]
      if (islist(value)) // Do we need to encode the value?
        value = jointext(value, ",") // lists become csvs by convention
      . += "[key]=[value]"
    . = jointext(., "&")
