
ABSTRACT_TYPE(/datum/apiBody)
/// Represents the body of an API request - ABSTRACT
/// Everything is generally required unless annotated as such
/datum/apiBody
	var/list/fields = list()
	var/list/values = list()

/datum/apiBody/New(list/fieldValues)
	. = ..()
	src.setValues(fieldValues)
	if (!VerifyIntegrity())
#if defined(SPACEMAN_DMM)
		return
#elif DM_VERSION >= 515 || defined(OPENDREAM) // Yay, actual sanity!
		var/datum/apiModel/Error/errorModel = new
		errorModel.SetupFromResponse(list("message" = "malformed [__TYPE__] [src.toJson()]"))
		throw EXCEPTION(errorModel)
#else
		var/datum/apiModel/Error/errorModel = new
		errorModel.SetupFromResponse(list("message" = "malformed api body [json_encode(src.toJson())]"))
		throw EXCEPTION(errorModel)
#endif

/// Build a list of values based on fields and input
/datum/apiBody/proc/setValues(list/fieldValues)
	var/idx = 1
	for (var/key in src.fields)
		src.values[key] = fieldValues[idx]
		idx++

/// Override to verify that the model object is correctly formed. Return FALSE if not.
/datum/apiBody/proc/VerifyIntegrity()
	return TRUE

/// Override to provide a way to convert this body to json
/datum/apiBody/proc/toJson()
	. = list()
	for (var/key in src.fields)
		.[key] = src.values[key]
	. = json_encode(.)
