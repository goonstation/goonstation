/datum/client_auth_provider/goonhub
	name = "Goonhub"
	start_state = CLIENT_AUTH_PENDING
	can_logout = TRUE
	var/timeout = 4 MINUTES
	var/token = ""

/datum/client_auth_provider/goonhub/New(client/owner)
	. = ..()
	world.log << "/datum/client_auth_provider/goonhub/New for [src.owner]"
	src.owner.verbs += list(/client/proc/open_goonhub_auth)
	src.hide_ui()
	src.show_wrapper()
	if (src.begin_auth())
		src.show_external("login")
	else
		// TODO: error handling
		world.log << "/datum/client_auth_provider/goonhub/New for [src.owner] failed to begin auth"

	SPAWN(src.timeout)
		src.on_timeout()

/datum/client_auth_provider/goonhub/Topic(href, href_list)
	world.log << "/datum/client_auth_provider/goonhub/Topic for [src.owner] with href [href]"
	if (href_list["logout"])
		src.on_logout()

/datum/client_auth_provider/goonhub/proc/on_timeout()
	if (!src.owner || src.authenticated) return
	world.log << "/datum/client_auth_provider/goonhub/on_timeout for [src.owner]"
	src.owner << output(null, "mainwindow.authwrapper:onTimeout")
	src.on_auth_failed()

/datum/client_auth_provider/goonhub/proc/begin_auth()
	world.log << "/datum/client_auth_provider/goonhub/begin_auth for [src.owner]"
	var/datum/apiRoute/gameauth/begin/beginAuth = new
	beginAuth.buildBody(config.server_id, src.owner.ckey)
	try
		var/datum/apiModel/BeginAuthResource/begin = apiHandler.queryAPI(beginAuth)
		src.token = begin.token
		return TRUE
	catch (var/exception/e)
		var/datum/apiModel/Error/errorModel = e.name
		logTheThing(LOG_ADMIN, null, "Failed to begin auth for [src.owner] because: [errorModel.message]", "admin")
		return FALSE

// Called in world/Topic "auth_callback" route
/datum/client_auth_provider/goonhub/on_auth(verification)
	world.log << "/datum/client_auth_provider/goonhub/on_auth for [src.owner]"
	src.token = "" // Token consumed
	try
		verification = json_decode(verification)
	catch (var/exception/e)
		// TODO: error handling for the user
		logTheThing(LOG_ADMIN, null, "Failed to decode auth data for [src.owner] because: [e]", "admin")
		return

	src.owner.verbs -= list(/client/proc/open_goonhub_auth)

	src.owner.client_auth_intent.ckey = verification["ckey"]
	src.owner.client_auth_intent.key = verification["key"] || verification["ckey"]
	src.owner.client_auth_intent.player_id = verification["player_id"]

	if (verification["is_admin"] && verification["admin_rank"])
		src.owner.client_auth_intent.admin = TRUE
		src.owner.client_auth_intent.admin_rank = verification["admin_rank"]
		admins[verification["ckey"]] = verification["admin_rank"]

	if (verification["is_mentor"])
		src.owner.client_auth_intent.mentor = TRUE
		mentors += verification["ckey"]

	if (verification["is_hos"])
		src.owner.client_auth_intent.hos = TRUE
		NT += verification["ckey"]

	if (verification["is_whitelisted"])
		src.owner.client_auth_intent.whitelisted = TRUE
		whitelistCkeys += verification["ckey"]

	if (verification["can_bypass_cap"])
		src.owner.client_auth_intent.can_bypass_cap = TRUE
		bypassCapCkeys += verification["ckey"]

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

	. = ..()

/datum/client_auth_provider/goonhub/post_auth()
	world.log << "/datum/client_auth_provider/goonhub/post_auth for [src.owner]"
	src.owner.key = src.owner.client_auth_intent.key

	if (isnewplayer(src.owner.mob))
		src.owner.mob.key = src.owner.client_auth_intent.key
		src.owner.mob.name = src.owner.client_auth_intent.key
		src.owner.mob.mind.key = src.owner.client_auth_intent.key
		src.owner.mob.mind.ckey = src.owner.client_auth_intent.ckey
		src.owner.mob.mind.displayed_key = src.owner.client_auth_intent.key

	src.hide_ui()

/datum/client_auth_provider/goonhub/logout()
	world.log << "/datum/client_auth_provider/goonhub/logout for [src.owner]"
	. = ..()
	src.show_external("logout")

/datum/client_auth_provider/goonhub/on_logout()
	world.log << "/datum/client_auth_provider/goonhub/on_logout for [src.owner]"
	src.hide_ui()
	. = ..()

/datum/client_auth_provider/goonhub/proc/show_wrapper()
	world.log << "/datum/client_auth_provider/goonhub/show_wrapper for [src.owner]"
	var/html = grabResource("html/goonhub_auth.html")
	// var/html = parseAssetLinks(file("browserassets/src/html/goonhub_auth.html"))
	html = replacetext(html, "{ref}", "\ref[src]")
	// html = replacetext(html, "{goonhub_url}", config.goonhub_url)
	html = replacetext(html, "{timeout}", src.timeout / 10)

	if (!cdn)
		src.owner.loadResourcesFromList(list(
			"browserassets/src/css/goonhub_auth.css",
			"browserassets/src/js/goonhub_auth.js",
			"browserassets/src/images/welcome_logo_light.png",
			"browserassets/src/images/goonhub_auth_bg.jpg",
		))

	winset(src.owner, "authwrapper", list2params(list(
		"parent" = "mainwindow",
		"type" = "browser",
		"pos" = "0,0",
		"size" = "-1x-1",
		"anchor1" = "0,0",
		"anchor2" = "100,100",
		"background-color" = "#0f0f0f",
		"is-visible" = TRUE,
	)))

	src.owner << browse(html, "window=mainwindow.authwrapper")

/// Show the external auth page
/datum/client_auth_provider/goonhub/proc/show_external(route = "login")
	world.log << "/datum/client_auth_provider/goonhub/show_external for [src.owner] with route [route]"
	var/url = "[config.goonhub_url]/game-auth/[route]?ref=\ref[src]"
	if (src.owner.byond_version <= 515) url += "&legacy=1"
	if (route == "login") url += "&token=[src.token]"
	winset(src.owner, "authexternal", list2params(list(
		"parent" = "mainwindow",
		"type" = "browser",
		"size" = "1x1",
		"background-color" = "#0f0f0f",
		"is-visible" = route != "logout",
	)))
	src.owner << browse(
		{"<html><head><meta http-equiv="refresh" content="0; url=[url]" /></head></html>"},
		"window=mainwindow.authexternal;size=1x1"
	)

/datum/client_auth_provider/goonhub/proc/hide_ui()
	if (winexists(src.owner, "mainwindow.authwrapper"))
		winset(src.owner, "mainwindow.authwrapper", "parent=none")
	if (winexists(src.owner, "mainwindow.authexternal"))
		winset(src.owner, "mainwindow.authexternal", "parent=none")

/// A way to open the login window, just in case
/client/proc/open_goonhub_auth()
	set name = "Goonhub Auth"
	set category = "Commands"
	set desc = "Open the Goonhub auth window"
	world.log << "/client/proc/open_goonhub_auth for [src]"
	if (src.authenticated) return
	if (istype(src.client_auth_provider, /datum/client_auth_provider/goonhub))
		var/datum/client_auth_provider/goonhub/provider = src.client_auth_provider
		provider.show_wrapper()
		provider.show_external("login")
