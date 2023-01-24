/datum/tgs_chat_command/ping
	name = "ping"
	help_text = "Server responds with pong."

/datum/tgs_chat_command/ping/Run(datum/tgs_chat_user/sender, params)
	return "Pong"

/datum/tgs_chat_command/respawn_dude
	name = "respawn"
	help_text = "Respawns a given ckey."

/datum/tgs_chat_command/respawn_dude/Run(datum/tgs_chat_user/sender, params)
	var/mob/target = ckey_to_mob(params)
	logTheThing(LOG_ADMIN, "[sender.friendly_name] (Discord)", target, "respawned [constructTarget(target,"admin")]")
	logTheThing(LOG_DIARY, "[sender.friendly_name] (Discord)", target, "respawned [constructTarget(target,"diary")].", "admin")
	message_admins("[sender.friendly_name] (Discord) respawned [key_name(target)].")

	var/mob/new_player/newM = new()
	newM.adminspawned = 1

	newM.key = target.key
	if (target.mind)
		target.mind.damned = 0
		target.mind.transfer_to(newM)
	newM.Login()
	newM.sight = SEE_TURFS //otherwise the HUD remains in the login screen
	qdel(target)

	boutput(newM, "<b>You have been respawned.</b>")
	return "Player respawned."
