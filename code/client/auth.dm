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
	new /datum/client_auth_gate/version,
)

var/list/datum/client_auth_gate/post_auth_gates = list(
	new /datum/client_auth_gate/whitelist,
	new /datum/client_auth_gate/cap,
	new /datum/client_auth_gate/ban,
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
	var/ckey = null
	var/key = null
	var/player_id = null
	var/admin = FALSE
	var/admin_rank = null
	var/mentor = FALSE
	var/hos = FALSE
	var/whitelisted = FALSE
	var/can_bypass_cap = FALSE
	var/can_skip_player_login = FALSE

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
	src.client_auth_provider = null

	// The user previously failed a gate check and rejoined.
	// So delete the unauthed mob so they arent stuck in it if they pass auth this time.
	if (istype(src.mob, /mob/unauthed))
		src.mob.key = null
		del(src.mob)
		src.mob = null

	for (var/datum/client_auth_gate/gate in pre_auth_gates)
		if (!gate.check(src))
			gate.fail(src)
			return CLIENT_AUTH_FAILED

	var/datum/client_auth_provider/provider = client_auth_providers[CLIENT_AUTH_PROVIDER_CURRENT]
	src.client_auth_provider = new provider(src)

	// Vague protection against bad clients
	if (!src.client_auth_provider.valid)
		return CLIENT_AUTH_FAILED

	return src.client_auth_provider.start_state

/*
 * Client auth callback
 *
 * This is called when the client is authenticated with the set auth provider.
 */
/client/proc/on_auth()
	SHOULD_CALL_PARENT(TRUE)

	for (var/datum/client_auth_gate/gate in post_auth_gates)
		if (!gate.check(src))
			src.client_auth_provider.post_auth_failed()
			gate.fail(src)
			return CLIENT_AUTH_FAILED

	src.client_auth_provider.post_auth()
	src.post_auth()

/*
 * Client auth failed
 *
 * This is called when the client fails to authenticate with the set auth provider, or fails a gate check.
 */
/client/proc/on_auth_failed()
	SHOULD_CALL_PARENT(TRUE)
	if (src)
		if (istype(src.mob, /mob/unauthed))
			src.mob.key = null
			del(src.mob)
			src.mob = null
		del(src)

/*
 * Client auth logout
 *
 * This is called when the client logs out.
 */
/client/proc/on_logout()
	SHOULD_CALL_PARENT(TRUE)
	if (src) del(src)
