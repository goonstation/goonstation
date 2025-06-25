/datum/client_auth_provider/goonhub
	name = "Goonhub"
	start_state = CLIENT_AUTH_PENDING
	can_logout = TRUE
	var/window_id = "goonhubauth"
	var/timeout = 4 MINUTES
	var/authenticating = FALSE

/datum/client_auth_provider/goonhub/New(client/owner)
	. = ..()
	src.owner.verbs += list(/client/proc/open_goonhub_auth)
	src.show_ui()

	boutput(src.owner, {"
		<div style='border: 2px solid orange; margin: 0.5em 0;'>
			<div style="color: black; background: #ffd07b; font-weight: bold; border-bottom: 1px solid orange; text-align: center; padding: 0.2em 0.5em;">
				Authentication required
			</div>
			<div style="padding: 0.2em 0.5em; text-align: center;">
				You are required to authenticate to play on this server. Please login via the popup window.<br>
				If you fail to login within [src.timeout / 10] seconds you will be disconnected.<br><br>
				To re-open the login window, <a href='byond://winset?command=goonhub-auth'>please click here</a>.
			</div>
		</div>
		"}, forceScroll=TRUE)

	SPAWN(src.timeout / 2)
		if (src.owner) src.timeout_warning(src.timeout / 2)

	SPAWN(src.timeout - src.timeout / 4)
		if (src.owner) src.timeout_warning(src.timeout / 4)

	SPAWN(src.timeout)
		if (src.owner) src.on_timeout()

/datum/client_auth_provider/goonhub/Topic(href, href_list)
	if (href_list["authenticated"])
		if (src.authenticating || src.authenticated) return
		src.authenticating = TRUE
		var/list/user = json_decode(href_list["user"])
		src.verify_auth(user["session"])
	if (href_list["logout"])
		src.on_logout()

/datum/client_auth_provider/goonhub/proc/timeout_warning(remaining_time)
	if (src.authenticated) return
	boutput(src.owner, {"
		<div style='border: 2px solid orange; margin: 0.5em 0;'>
			<div style="color: black; background: #ffd07b; font-weight: bold; border-bottom: 1px solid orange; text-align: center; padding: 0.2em 0.5em;">
				Authentication timeout warning
			</div>
			<div style="padding: 0.2em 0.5em; text-align: center;">
				Please login within the next [remaining_time / 10] seconds or you will be disconnected.
			</div>
		</div>
		"}, forceScroll=TRUE)

/datum/client_auth_provider/goonhub/proc/on_timeout()
	if (src.authenticated) return
	boutput(src.owner, {"
		<div style='border: 2px solid red; margin: 0.5em 0;'>
			<div style="color: black; background: #f88; font-weight: bold; border-bottom: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
				Authentication timed out
			</div>
			<div style="padding: 0.2em 0.5em; text-align: center;">
				You will now be disconnected.
			</div>
		</div>
		"}, forceScroll=TRUE)
	src.on_auth_failed()

/datum/client_auth_provider/goonhub/proc/verify_auth(session)
	var/datum/apiRoute/gameauth/verify/verifyAuth = new
	verifyAuth.buildBody(
		session,
		config.server_id,
		src.owner.address ? src.owner.address : "127.0.0.1", // fallback for local dev
		src.owner.computer_id,
		src.owner.byond_version,
		src.owner.byond_build,
		roundId || null
	)
	try
		var/datum/apiModel/VerifyAuthResource/verification = apiHandler.queryAPI(verifyAuth)
		src.on_auth(verification)
	catch
		src.authenticating = FALSE
		src.show_ui()
		return FALSE

/datum/client_auth_provider/goonhub/on_auth(datum/apiModel/VerifyAuthResource/verification)
	winshow(src.owner, src.window_id, FALSE)
	src.owner.verbs -= list(/client/proc/open_goonhub_auth)

	src.owner.client_auth_intent.player_id = verification.player_id
	src.owner.ckey = verification.ckey
	src.owner.key = verification.key || verification.ckey

	var/mob/old_mob = src.owner.mob
	var/mob/new_player/new_mob = new()
	old_mob.last_client = null
	new_mob.key = src.owner.key

	if (verification.is_admin && verification.admin_rank)
		src.owner.client_auth_intent.admin = TRUE
		src.owner.client_auth_intent.admin_rank = verification.admin_rank
		admins[src.owner.ckey] = verification.admin_rank

	if (verification.is_mentor)
		src.owner.client_auth_intent.mentor = TRUE
		mentors += src.owner.ckey

	if (verification.is_hos)
		src.owner.client_auth_intent.hos = TRUE
		NT += src.owner.ckey

	if (verification.is_whitelisted)
		src.owner.client_auth_intent.whitelisted = TRUE
		whitelistCkeys += src.owner.ckey

	if (verification.can_bypass_cap)
		src.owner.client_auth_intent.can_bypass_cap = TRUE
		bypassCapCkeys += src.owner.ckey

	boutput(src.owner, {"
		<div style='border: 2px solid green; margin: 0.5em 0;'>
			<div style="color: black; background: #8f8; font-weight: bold; border-bottom: 1px solid green; text-align: center; padding: 0.2em 0.5em;">
				Authentication successful
			</div>
			<div style="padding: 0.2em 0.5em; text-align: center;">
				You have been successfully authenticated, have fun!
			</div>
		</div>
		"}, forceScroll=TRUE)

	src.authenticating = FALSE
	. = ..()

// /datum/client_auth_provider/goonhub/on_auth_failed()
// 	// TODO: show a message to the user that they failed to authenticate
// 	. = ..()

/datum/client_auth_provider/goonhub/logout()
	. = ..()
	src.show_ui("logout")

/datum/client_auth_provider/goonhub/on_logout()
	winshow(src.owner, src.window_id, FALSE)
	. = ..()

/// Show the login window
/datum/client_auth_provider/goonhub/proc/show_ui(route = "login")
	var/html = grabResource("html/goonhub_auth.html")
	html = replacetext(html, "{ref}", "\ref[src]")
	html = replacetext(html, "{goonhub_url}", config.goonhub_url)
	html = replacetext(html, "{route}", route)

	winset(src.owner, src.window_id, list2params(list(
		"type" = "browser",
		"size" = "1x1",
		"is-visible" = FALSE,
		"titlebar" = FALSE,
		"use-title" = TRUE,
	)))

	src.owner << browse(html, list2params(list(
		"window" = src.window_id,
		"title" = "Goonhub Auth",
		"titlebar" = FALSE,
		"can_close" = FALSE,
		"can_resize" = FALSE,
		"can_minimize" = FALSE,
	)))

	if (route != "logout")
		winset(src.owner, src.window_id, list2params(list(
			"size" = "500x500",
			"titlebar" = TRUE,
			"can-resize" = TRUE,
			"is-visible" = TRUE,
			// "on-close" = ".on-goonhub-auth-close [route]",
		)))

/// A way to open the login window, just in case
/client/proc/open_goonhub_auth()
	set name = "Goonhub Auth"
	set category = "Commands"
	set desc = "Open the Goonhub auth window"
	if (src.authenticated) return
	if (istype(src.client_auth_provider, /datum/client_auth_provider/goonhub))
		var/datum/client_auth_provider/goonhub/provider = src.client_auth_provider
		provider.show_ui()

/// Reopen the login window if the user somehow manages to close it
// /client/proc/on_goonhub_auth_close(route as text)
// 	set name = ".on-goonhub-auth-close"
// 	set hidden = TRUE
// 	if (src.authenticated) return
// 	if (istype(src.client_auth_provider, /datum/client_auth_provider/goonhub))
// 		var/datum/client_auth_provider/goonhub/provider = src.client_auth_provider
// 		provider.show_ui(route)
