
ABSTRACT_TYPE(/datum/eventRecordBody/TracksPlayer)
/// For events that require a player ID - ABSTRACT
/datum/eventRecordBody/TracksPlayer
	var/player_id	= null // integer

/datum/eventRecordBody/TracksPlayer/New(
	player_id
)
	. = ..()
	src.player_id = player_id

/datum/eventRecordBody/TracksPlayer/VerifyIntegrity()
	if (
		isnull(src.player_id)
	)
		return FALSE

/datum/eventRecordBody/TracksPlayer/ToList()
	. = list("player_id" = src.player_id)
