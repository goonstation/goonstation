/datum/client_auth_gate/ban
	var/ban_message = ""

	check(client/C)
		if (IsLocalClient(C)) return TRUE

		var/list/checkBan = bansHandler.check(C.client_auth_intent.ckey, C.computer_id, C.address, C.client_auth_intent.player_id)
		if (!checkBan) return TRUE

		var/datum/apiModel/Tracked/Ban/ban = checkBan["ban"]
		var/banUrl = "<a href='[goonhub_href("/admin/bans/[ban.id]", TRUE)]'>[ban.id]</a>"
		logTheThing(LOG_ADMIN, null, "Failed Login: [constructTarget(C,"diary")] - Banned (ID: [ban.id], CKEY: [C.client_auth_intent.ckey], IP: [C.address], CID: [C.computer_id])")
		logTheThing(LOG_DIARY, null, "Failed Login: [constructTarget(C,"diary")] - Banned (ID: [ban.id], CKEY: [C.client_auth_intent.ckey], IP: [C.address], CID: [C.computer_id])", "access")
		if (announce_banlogin) message_admins(SPAN_INTERNAL("Failed Login: <a href='byond://?C=%admin_ref%;action=notes;target=[C.ckey]'>[C]</a> - Banned (ID: [banUrl], CKEY: [C.client_auth_intent.ckey], IP: [C.address], CID: [C.computer_id])"))
		src.ban_message = checkBan["message"]

		return FALSE

/datum/client_auth_gate/ban/get_failure_message(client/C)
	return {"
		<h1>You have been banned.</h1>
		<span style="color: red;">Reason: [src.ban_message]</span>
		<br><br>
		If you believe you were unjustly banned, head to the forums at https://forum.ss13.co and post an appeal.
		<br><br>
		<strong>If you believe this ban was not meant for you then please appeal regardless of what the ban message or length says!</strong>
	"}
