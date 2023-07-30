
ABSTRACT_TYPE(/datum/apiBody)
/// Represents the body of an API request - ABSTRACT
/// Everything is generally required unless annotated as such
/datum/apiBody

/datum/apiBody/New()
	. = ..()
	if (!VerifyIntegrity())
#if defined(SPACEMAN_DMM)
		return
#elif DM_VERSION >= 515 || defined(OPENDREAM) // Yay, actual sanity!
		throw EXCEPTION("malformed [__TYPE__] [src.ToString()]")
#else
		return
		//throw EXCEPTION("malformed [....] [src.ToString()]")
#endif

/// Override to verify that the model object is correctly formed. Return FALSE if not.
/datum/apiBody/proc/VerifyIntegrity()
	return TRUE

/// Override to provide a way to convert this body to json
/datum/apiBody/proc/toJson()
	return "{}"
