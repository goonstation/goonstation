
ABSTRACT_TYPE(/datum/eventRecordBody)
/// Represents the body of an event - ABSTRACT
/datum/eventRecordBody

/datum/eventRecordBody/New()
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
/datum/eventRecordBody/proc/VerifyIntegrity()
	return TRUE

/datum/eventRecordBody/proc/ToList()
	. = list("data" = list())
