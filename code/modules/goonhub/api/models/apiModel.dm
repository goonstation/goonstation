

ABSTRACT_TYPE(/datum/apiModel)
/// Base apiModel datum - ABSTRACT
/// Everything is generally required unless annotated as such
/datum/apiModel

/// Override to verify that the model object is correctly formed. Return FALSE if not.
/datum/apiModel/proc/VerifyIntegrity()
	return TRUE

/// Override to determine how this mdoel will get shown for debugging purposes
/datum/apiModel/proc/ToString()
	return

/datum/apiModel/proc/SetupFromResponse()
	return
