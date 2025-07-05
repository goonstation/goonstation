/datum/client_auth_gate/ban
	check(client/C)
		if (IsLocalClient(C)) return TRUE

		var/list/checkBan = bansHandler.check(C.client_auth_intent.ckey, C.computer_id, C.address, C.client_auth_intent.player_id)
		if (!checkBan) return TRUE

		SPAWN(-1)
			var/datum/apiModel/Tracked/BanResource/banResource = checkBan["ban"]
			var/banUrl = "<a href='[goonhub_href("/admin/bans/[banResource.id]", TRUE)]'>[banResource.id]</a>"
			logTheThing(LOG_ADMIN, null, "Failed Login: [constructTarget(C,"diary")] - Banned (ID: [banResource.id], CKEY: [C.client_auth_intent.ckey], IP: [C.address], CID: [C.computer_id])")
			logTheThing(LOG_DIARY, null, "Failed Login: [constructTarget(C,"diary")] - Banned (ID: [banResource.id], CKEY: [C.client_auth_intent.ckey], IP: [C.address], CID: [C.computer_id])", "access")
			if (announce_banlogin) message_admins(SPAN_INTERNAL("Failed Login: <a href='byond://?C=%admin_ref%;action=notes;target=[C.ckey]'>[C]</a> - Banned (ID: [banUrl], CKEY: [C.client_auth_intent.ckey], IP: [C.address], CID: [C.computer_id])"))

			C.Browse({"
				<!doctype html>
				<html>
					<head>
						<title>BANNED!</title>
						<style>
							h1, .banreason {
								font-color:#F00;
							}
						</style>
					</head>
					<body>
						<h1>You have been banned.</h1>
						<span class='banreason'>Reason: [checkBan["message"]]</span><br>
						If you believe you were unjustly banned, head to <a target="_blank" href=\"https://forum.ss13.co\">the forums</a> and post an appeal.<br>
						<b>If you believe this ban was not meant for you then please appeal regardless of what the ban message or length says!</b>
					</body>
				</html>
			"}, "window=ripyou")

		return FALSE
