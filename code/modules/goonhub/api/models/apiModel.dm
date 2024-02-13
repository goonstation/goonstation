

ABSTRACT_TYPE(/datum/apiModel)
/// Base apiModel datum - ABSTRACT
/// Everything is generally required unless annotated as such
/datum/apiModel

/// Override to verify that the model object is correctly formed. Return FALSE if not.
/datum/apiModel/proc/VerifyIntegrity()
	return TRUE

/// Override to convert a model to an associative list
/datum/apiModel/proc/ToList()
	return list()

/// Get a string representation of a model for debugging purposes. Optional.
/datum/apiModel/proc/ToString()
	return json_encode(src.ToList())

/// Override to build a model from an API response object
/datum/apiModel/proc/SetupFromResponse()
	return
