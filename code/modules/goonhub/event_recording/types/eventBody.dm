
ABSTRACT_TYPE(/datum/eventRecordBody)
/// Represents the body of an event - ABSTRACT
/datum/eventRecordBody
	var/list/fields
	var/list/values = list()

/datum/eventRecordBody/New(list/fieldValues)
	. = ..()
	src.setValues(fieldValues)
	if (!VerifyIntegrity())
#if defined(SPACEMAN_DMM)
		return
#elif DM_VERSION >= 515 || defined(OPENDREAM) // Yay, actual sanity!
		throw EXCEPTION("malformed [__TYPE__] [json_encode(src.ToList())]")
#else
		throw EXCEPTION("malformed event [json_encode(src.ToList())]")
#endif

/datum/eventRecordBody/proc/setValues(list/fieldValues)
	var/idx = 1
	for (var/key in src.fields)
		src.values[key] = fieldValues[idx]
		idx++

/// Override to verify that the model object is correctly formed. Return FALSE if not.
/datum/eventRecordBody/proc/VerifyIntegrity()
	return TRUE

/datum/eventRecordBody/proc/ToList()
	var/list/data = list()
	for (var/key in src.fields)
		data[key] = src.values[key]
	. = list("data" = data)
