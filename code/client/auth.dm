/*
 * Client auth gates
 *
 * These are the gates that are used to check if the client is allowed to join the server.
 * They are executed in order of definition.
 *
 * Pre-auth gates are executed before the client is authenticated with the set auth provider.
 * They should be used to check for basic things that don't require client details like ckey or a player ID.
 *
 * Post-auth gates are executed after the client is authenticated with the set auth provider.
 * They should be used to check for more complex things that require client details.
 */

var/list/datum/client_auth_gate/pre_auth_gates = list(
	new /datum/client_auth_gate/telnet,
	#if CLIENT_AUTH_PROVIDER_CURRENT == CLIENT_AUTH_PROVIDER_BYOND
	new /datum/client_auth_gate/guest,
	#endif
)

var/list/datum/client_auth_gate/post_auth_gates = list(
	new /datum/client_auth_gate/ban,
	new /datum/client_auth_gate/whitelist,
	new /datum/client_auth_gate/cap,
)

/*
 * Client auth intent
 *
 * This is a simple intent object that is used to indicate what access the client will have,
 * without actually granting it.
 *
 * This is used to avoid granting access to the client until all the gate checks have been made.
 */
/datum/client_auth_intent
	var/player_id = null
	var/admin = FALSE
	var/admin_rank = null
	var/mentor = FALSE
	var/hos = FALSE
	var/whitelisted = FALSE
	var/can_bypass_cap = FALSE

/client/var/datum/client_auth_intent/client_auth_intent
/client/var/datum/client_auth_provider/client_auth_provider

/*
 * Client auth
 *
 * This is the main proc for client auth.
 * It is called when the client connects to the server.
 * It is used to authenticate the client and set the client's auth intent.
 */
/client/proc/auth()
	src.client_auth_intent = new()

	for (var/datum/client_auth_gate/gate in pre_auth_gates)
		world.log << "Checking gate: [gate]"
		if (!gate.check(src))
			world.log << "Gate failed"
			gate.fail(src)
			return CLIENT_AUTH_FAILED

	var/datum/client_auth_provider/provider = client_auth_providers[CLIENT_AUTH_PROVIDER_CURRENT]
	src.client_auth_provider = new provider(src)
	return src.client_auth_provider.start_state

/*
 * Client auth callback
 *
 * This is called when the client is authenticated with the set auth provider.
 */
/client/proc/on_auth()
	SHOULD_CALL_PARENT(TRUE)

	for (var/datum/client_auth_gate/gate in post_auth_gates)
		world.log << "Checking gate: [gate]"
		if (!gate.check(src))
			world.log << "Gate failed"
			gate.fail(src)
			return CLIENT_AUTH_FAILED

	if (isnewplayer(src.mob))
		var/mob/new_player/new_player = src.mob
		new_player.blocked_from_joining = FALSE

	src.post_auth()
