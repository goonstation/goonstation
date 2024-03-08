var/global/list/vpn_ip_checks = list() //assoc list of ip = true or ip = false. if ip = true, thats a vpn ip. if its false, its a normal ip.

/client/New()
	. = ..()
	vpn_scan()

/client/proc/vpn_scan()
	set waitfor = FALSE
	//vpn check (for ban evasion purposes)
#ifdef DO_VPN_CHECKS
	if (vpn_blacklist_enabled)
		var/is_vpn_address = global.vpn_ip_checks["[src.address]"]
		var/list/round_stats = src.player?.get_round_stats(TRUE)

		// We have already checked this user this round and they are indeed on a VPN, kick em
		if (is_vpn_address)
			src.vpn_bonk(repeat_attempt = TRUE)
			return

		// Client has not been checked for VPN status this round, go do so, but only for relatively new accounts
		// NOTE: adjust magic numbers here if we approach vpn checker api rate limits
		try
			if (isnull(is_vpn_address) && (round_stats?["participated"] < 5 || round_stats?["seen"] < 20))
				if (vpn_prescan()) return

				var/datum/apiModel/VpnCheckResource/checkedVpn
				try
					var/datum/apiRoute/vpn/check/checkVpn = new
					checkVpn.routeParams = list(src.address)
					checkVpn.queryParams = list("ckey" = src.ckey, "round_id" = roundId)
					checkedVpn = apiHandler.queryAPI(checkVpn)
				catch (var/exception/e)
					var/datum/apiModel/Error/error = e.name
					logTheThing(LOG_ADMIN, src, "unable to check VPN status of [src.address] because: [error.message]")
					logTheThing(LOG_DIARY, src, "unable to check VPN status of [src.address] because: [error.message]", "debug")
					return

				// Successful Goonhub API query
				var/list/responseData = json_decode(checkedVpn.response)
				var/result = postscan(responseData)
				if (result == 2 || checkedVpn.meta["whitelisted"])
					// User is explicitly whitelisted from VPN checks, ignore
					global.vpn_ip_checks["[src.address]"] = FALSE
				else
					// VPN checker service returns error responses in a "message" property
					if (checkedVpn.error)
						// Yes, we're forcing a cache for a no-VPN response here on purpose
						// Reasoning: The goonhub API has cached the VPN checker error response for the foreseeable future and further queries won't change that
						//			  so we want to avoid spamming the goonhub API this round for literally no gain
						global.vpn_ip_checks["[src.address]"] = FALSE
						logTheThing(LOG_ADMIN, src, "unable to check VPN status of [src.address] because: [checkedVpn.error]")
						logTheThing(LOG_DIARY, src, "unable to check VPN status of [src.address] because: [checkedVpn.error]", "debug")

					// Successful VPN check
					// IP is a known VPN, cache locally and kick
					else if (result || (((responseData["vpn"] == TRUE) || (responseData["tor"] == TRUE)) && (responseData["fraud_score"] > 75)))
						vpn_bonk(responseData["host"], responseData["ASN"], responseData["organization"], responseData["fraud_score"])
						return
					// IP is not a known VPN
					else
						global.vpn_ip_checks["[src.address]"] = FALSE

		catch(var/exception/e)
			logTheThing(LOG_ADMIN, src, "unable to check VPN status of [src.address] because: [e.name]")
			logTheThing(LOG_DIARY, src, "unable to check VPN status of [src.address] because: [e.name]", "debug")
#endif

/// boots player and displays VPN message
/client/proc/vpn_bonk(host, asn, organization, fraud_score, repeat_attempt = FALSE, info)
	var/vpn_kick_string = {"
				<!doctype html>
				<html>
					<head>
						<title>VPN or Proxy Detected</title>
					</head>
					<body>
						<h1>Warning: VPN or proxy connection detected</h1>

						Please disable your VPN or proxy, close the game, and rejoin.<br>
						<h2>Not using a VPN or proxy / Having trouble connecting?</h2>
						If you are not using a VPN or proxy please join <a href="https://discord.com/invite/zd8t6pY" target="_blank">our Discord server</a> and and fill out <a href="https://dyno.gg/form/b39d898a" target="_blank">this form</a> for help whitelisting your account.
					</body>
				</html>
			"}

	if (repeat_attempt)
		logTheThing(LOG_ADMIN, src, "[src.address] is using a vpn that they've already logged in with during this round.")
		logTheThing(LOG_DIARY, src, "[src.address] is using a vpn that they've already logged in with during this round.", "admin")
		message_admins("[key_name(src)] [src.address] attempted to connect with a VPN or proxy but was kicked!")
	else
		global.vpn_ip_checks["[src.address]"] = TRUE
		var/msg_txt = "[src.address] attempted to connect via vpn or proxy. vpn info:[host ? " host: [host]," : ""] ASN: [asn], org: [organization][fraud_score ? ", fraud score: [fraud_score]" : ""][info ? ", info: [info]" : ""]"

		addPlayerNote(src.ckey, "bot", msg_txt)
		logTheThing(LOG_ADMIN, src, msg_txt)
		logTheThing(LOG_DIARY, src, msg_txt, "admin")
		message_admins("[key_name(src)] [msg_txt]")
		ircbot.export_async("admin", list(key="VPN Blocker", name="[src.key]", msg=msg_txt))
	if(do_compid_analysis)
		do_computerid_test(src) //Will ban yonder fucker in case they are prix
		check_compid_list(src) //Will analyze their computer ID usage patterns for aberrations
	src.Browse(vpn_kick_string, "window=vpnbonked")
	sleep(3 SECONDS)
	if (src)
		tgui_process.close_user_uis(src.mob)
		del(src)
	return

#ifndef SECRETS_ENABLED
/client/proc/vpn_prescan()
	return
/client/proc/postscan(list/data)
	return
#endif
