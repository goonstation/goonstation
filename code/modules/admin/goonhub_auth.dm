/datum/goonhub_auth
	var/client/owner = null
	var/authenticated = FALSE

/datum/goonhub_auth/New(client/owner)
	. = ..()
	src.owner = owner
	src.owner.verbs += /client/proc/open_goonhub_auth

/datum/goonhub_auth/Topic(href, href_list)
	if (href_list["openLogin"])
		src.owner << link("[config.goonhub_url]/login?auth_from_game=[config.server_id]")

/datum/goonhub_auth/proc/on_auth()
	src.authenticated = TRUE
	src.send_client_data(TRUE, "onAuthSuccess")
	src.owner.make_admin()
	src.owner.verbs -= /client/proc/open_goonhub_auth
	boutput(src.owner, "<span class='ooc adminooc'>You are an admin! Time for crime.</span>")

	logTheThing(LOG_ADMIN, src.owner, "authenticated as an admin via Goonhub")
	logTheThing(LOG_DIARY, src.owner, "authenticated as an admin via Goonhub", "admin")
	message_admins("[key_name(src.owner)] authenticated as an admin via Goonhub")

/datum/goonhub_auth/proc/show_ui()
	var/html = grabResource("html/admin/goonhub_auth.html")
	html = replacetext(html, "{ref}", "\ref[src]")
	src.owner << browse(html, "window=goonhubauth;title=Goonhub Login;size=300x250")

/datum/goonhub_auth/proc/send_client_data(data, function)
	src.owner << output("[data]", "goonhubauth.browser:[function]")


/client/var/datum/goonhub_auth/goonhub_auth

/client/proc/open_goonhub_auth()
	set name = "Goonhub Auth"
	src.goonhub_auth.show_ui()
