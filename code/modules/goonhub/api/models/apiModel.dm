

ABSTRACT_TYPE(/datum/apiModel)
/// Base apiModel datum - ABSTRACT
/// Everything is generally required unless annotated as such
/datum/apiModel
	var/id = null // integer

/datum/apiModel/New()
	. = ..()
	if (!VerifyIntegrity())
#if defined(SPACEMAN_DMM)
		return
#elif DM_VERSION >= 515 || defined(OPENDREAM) // Yay, actual sanity!
		throw EXCEPTION("malformed [__TYPE__] [src.ToString()]")
#else
		throw EXCEPTION("malformed [.....] [src.ToString()]")
#endif

/// Override to verify that the model object is correctly formed. Return FALSE if not.
/datum/apiModel/proc/VerifyIntegrity()
	if (
		isnull(src.id)
	)
		return FALSE

/// Override to determine how this mdoel will get shown for debugging purposes
/datum/apiModel/proc/ToString()
	. = list()
	.["id"] = src.id
	return json_encode(.)
