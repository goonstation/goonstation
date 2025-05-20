// in order of execution
var/list/datum/client_auth_gate/pre_auth_gates = list(
	new /datum/client_auth_gate/telnet,
	new /datum/client_auth_gate/guest,
)

var/list/datum/client_auth_gate/post_auth_gates = list(
	new /datum/client_auth_gate/ban,
	new /datum/client_auth_gate/whitelist,
	new /datum/client_auth_gate/cap,
)

/datum/client_auth_intent
	var/admin = FALSE
	var/mentor = FALSE

/client/var/datum/client_auth_intent/client_auth_intent
/client/var/datum/client_auth_provider/client_auth_provider

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

/client/proc/on_auth()
	SHOULD_CALL_PARENT(TRUE)
	world.log << "Authenticated"

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
