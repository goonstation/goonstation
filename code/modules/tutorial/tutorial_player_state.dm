/**
 * This is the datum which keeps track of tutorial state for each player
 *
 * This is seralized and stored in da cloud.
 * Functions:
 * * Track how far a player has progressed in the tutorial (see: restarting stages, resuming the tutorial)
 * * Keep track of which group they are assigned
 */
/datum/tutorial/player_state
	/// Our player client
	var/client/client = null
	/// The group the player is assigned
	var/datum/tutorial/group/group
	/// TODO: The stages the player has finished (number:bool)
	var/list/finished_stages = null
	/// TODO: The current stage the player is in
	var/datum/tutorial/stage/current_stage = null
	/// TODO: The server that the player came from for exiting the tutorial. Not serialized.
	var/tmp/return_server = null

	New(client/C, datum/tutorial/group/G)
		. = ..()
		client = C
		group = G
		group.add_player(src)

	/// Called when we're being deleted, say the client logged out or left
	disposing()
		. = ..()
		qdel(group)
		group = null
		current_stage = null

// TODO: implement (de)serialization
// probably ideally using the API and a database
// but lol at that getting finished in the immediate present
// so https://github.com/alexkar598/cereal-ize likely
