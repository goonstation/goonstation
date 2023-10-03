
ABSTRACT_TYPE(/datum/eventRecordBody/TracksPlayer)
/// For events that require a player ID - ABSTRACT
/datum/eventRecordBody/TracksPlayer
	var/player_id	= null // integer

/datum/eventRecordBody/TracksPlayer/New(list/fieldValues)
	src.player_id = fieldValues[1]
	. = ..(fieldValues.Copy(2, 0))

/datum/eventRecordBody/TracksPlayer/VerifyIntegrity()
	if (!src.player_id)
		return FALSE

	return TRUE

/datum/eventRecordBody/TracksPlayer/ToList()
	. = ..()
	.["player_id"] = src.player_id
