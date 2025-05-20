/datum/client_auth_provider/goonhub
	start_state = CLIENT_AUTH_PENDING
	var/window_id = "goonhubauth"

/datum/client_auth_provider/goonhub/New(client/owner)
	. = ..()
	src.owner.verbs += /client/proc/open_goonhub_auth
	src.show_ui()

/datum/client_auth_provider/goonhub/Topic(href, href_list)
	if (href_list["authenticated"])
		boutput(world, "Authenticated: [href_list["user"]]")
		var/list/user = json_decode(href_list["user"])
		src.verify_auth(user["session"])
	if (href_list["log"])
		boutput(world, "Log: [href_list["log"]]")

/datum/client_auth_provider/goonhub/proc/verify_auth(session)
	boutput(world, "Verifying auth: [session]")
	var/datum/apiRoute/gameauth/verify/verifyAuth = new
	verifyAuth.buildBody(session)
	try
		var/datum/apiModel/VerifyAuthResource/verification = apiHandler.queryAPI(verifyAuth)
		boutput(world, "Verified auth. is_admin: [verification.is_admin]")
		src.on_auth(verification)
	catch
		boutput(world, "Failed to verify auth")
		return FALSE

/datum/client_auth_provider/goonhub/on_auth(datum/apiModel/VerifyAuthResource/verification)
	winshow(src.owner, src.window_id, FALSE)
	src.owner.verbs -= /client/proc/open_goonhub_auth

	if (verification.is_admin && verification.admin_rank)
		src.owner.client_auth_intent.admin = TRUE
		admins[src.owner.ckey] = verification.admin_rank

	boutput(src.owner, SPAN_SUCCESS(SPAN_BOLD("You have been successfully authenticated, go nuts!")))
	logTheThing(LOG_ADMIN, src.owner, "authenticated via Goonhub")
	logTheThing(LOG_DIARY, src.owner, "authenticated via Goonhub", "admin")

	. = ..()

/datum/client_auth_provider/goonhub/proc/show_ui()
	var/html = grabResource("html/goonhub_auth.html")
	html = replacetext(html, "{ref}", "\ref[src]")
	html = replacetext(html, "{goonhub_url}", config.goonhub_url)
	src.owner << browse(html, "window=[src.window_id];title=Goonhub Auth;size=500x500;can_close=0;can_resize=1;can-minimize=0;")


/client/proc/open_goonhub_auth()
	set name = "Goonhub Auth"
	if (istype(src.client_auth_provider, /datum/client_auth_provider/goonhub))
		var/datum/client_auth_provider/goonhub/provider = src.client_auth_provider
		provider.show_ui()
