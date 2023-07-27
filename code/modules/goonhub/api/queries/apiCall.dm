

/// Base apiCall type
/// Represents a predefined query we can make to the Goonhub API
/datum/apiCall
	/// HTTP Method this call uses, for example `RUSTG_HTTP_METHOD_GET`
	var/method = null
	/// Actual path of the api query, for example `/rounds`
	var/path = null
	/// Parameters for the call
	var/list/parameters = null
	/// The expected type upon deserialization
	var/correct_response = "string"


