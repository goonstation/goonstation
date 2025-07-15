/datum/titlecard
	var/global/list/maptext_areas = list()
	var/global/last_pregame_html = ""

	#if defined(MAP_OVERRIDE_OSHAN)
	var/image_url = "images/titlecards/oshan_titlecard.png"
	#elif defined(MAP_OVERRIDE_POD_WARS)
	var/image_url = "images/titlecards/podwars.png"
	#else
	var/image_url = "images/titlecards/main_titlecard.gif"
	#endif
	var/is_game_mode = FALSE
	var/add_html = ""
	var/overlay_image_url = null
	var/pixelated = TRUE

	heisenbee
		image_url = "images/titlecards/heisenbee_titlecard.png"
		add_html = {"<a href="https://www.deviantart.com/alexbluebird" target="_blank" style="position:absolute;bottom:3px;right:3px;color:white;opacity:0.7;">by AlexBlueBird</a>"}
		pixelated = FALSE

	hehe
		image_url = "images/titlecards/hehe_titlecard.png"

	nightshade
		image_url = "images/titlecards/nightshade2024_titlecard.png"
		pixelated = FALSE

	nightshade_2
		image_url = "images/titlecards/nightshade2024_titlecard2.png"
		pixelated = FALSE

	disaster
		overlay_image_url = "images/titlecards/disaster_titlecard.gif"
		is_game_mode = TRUE

	battleroyale
		overlay_image_url = "images/titlecards/battleroyale_titlecard.png"
		is_game_mode = TRUE

/datum/titlecard/proc/set_pregame_html()
	var/html = grabResource("html/pregame.html")
	html = replacetext(html, "<!--main_img-->", {"<img id="main-img" src="[resource(src.image_url)]" style="[src.pixelated ? "image-rendering: pixelated;" : ""]">"})

	if (!isnull(src.overlay_image_url))
		html = replacetext(html, "<!--overlay_img-->", {"<img id="olay-img" src="[resource(src.overlay_image_url)]">"})

	html = replacetext(html, "<!--add_html-->", src.add_html)
	last_pregame_html = html
	pregameHTML = last_pregame_html

	var/list/resources = list()
	if (!cdn)
		resources = list("browserassets/src/misc/ibmvga9.ttf")
		if (src.image_url) resources += "browserassets/src/[src.image_url]"
		if (src.overlay_image_url) resources += "browserassets/src/[src.overlay_image_url]"

	for (var/client/C)
		if (C && isnewplayer(C.mob))
			if (!cdn) C.loadResourcesFromList(resources)
			C.load_pregame()

/client/proc/load_pregame()
	#ifndef NO_PREGAME_HTML
	if (!pregameHTML || !src) return
	src << browse(pregameHTML, "window=pregameBrowser")
	winshow(src, "pregameBrowser", TRUE)

	if (isnewplayer(src.mob))
		var/mob/new_player/new_player = src.mob
		new_player.pregameBrowserLoaded = TRUE
	#endif

/datum/titlecard/proc/set_maptext(id, text)
	maptext_areas[id] = text
	if(isnull(pregameHTML))
		return
#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
	if(current_state <= GAME_STATE_PREGAME)
		return
#endif
	if (last_pregame_html == pregameHTML)
		for (var/client/C)
			if (isnewplayer(C.mob))
				var/mob/new_player/new_player = C.mob
				if (new_player.pregameBrowserLoaded)
					C << output(list2params(list(id, text)), "pregameBrowser:set_area")

/client/verb/send_lobby_text()
	set name = ".send-lobby-text"
	set hidden = 1

	if (!isnewplayer(src?.mob)) return
	lobby_titlecard.send_lobby_text(src)

/datum/titlecard/proc/send_lobby_text(client/C)
	if (last_pregame_html != pregameHTML) return
	if (isnull(pregameHTML)) return

#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
	if (current_state <= GAME_STATE_PREGAME) return
#endif

	var/mob/new_player/new_player = C.mob
	if (istype(new_player) && new_player.pregameBrowserLoaded)
		var/list/to_send = maptext_areas
		to_send["auth"] = !C.authenticated ? "Please authenticate to play. To re-open the login window, <a href='byond://winset?command=goonhub-auth'>click here</a>." : ""
		to_send["tip"] = C.authenticated ? src.get_tip(new_player) : ""
		C << output(list2params(list(json_encode(to_send))), "pregameBrowser:set_areas")

/datum/titlecard/proc/get_tip(mob/new_player/new_player)
	. = new_player.my_own_roundstart_tip || get_global_tip()
	. = "Tip: [.] <a href='byond://winset?command=.refresh_tip' style='color:#aaf;'>🔄</a>"

proc/get_random_tip()
	#ifdef RP_MODE
	// do we instead want weighting here?
	var/static/list/all_tips = dd_file2list("strings/roundstart_hints.txt") + dd_file2list("strings/roundstart_hints_rp.txt")
	#else
	var/static/list/all_tips = dd_file2list("strings/roundstart_hints.txt")
	#endif
	. = pick(all_tips)

proc/get_global_tip(generate = TRUE)
	var/static/global_tip = null
	if(isnull(global_tip) && generate)
		global_tip = get_random_tip()
	. = global_tip

/mob/new_player/verb/refresh_tip()
	set name = ".refresh_tip"
	set hidden = 1
	var/new_tip = ""
	// Avoid duplicate sequential tips
	var/tries = 0
	while (new_tip == "" || new_tip == src.my_own_roundstart_tip || (!src.my_own_roundstart_tip && new_tip == get_global_tip(FALSE)))
		new_tip = get_random_tip()
		tries++
		if (tries > 10) break
	src.my_own_roundstart_tip = new_tip
	lobby_titlecard.send_lobby_text(src.client)


///old title card turf
/obj/titlecard
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	icon = null //set in New()
	icon_state = "title_main"
	layer = 60
	name = "Space Station 13"
	desc = "The title card for it, at least."
	plane = PLANE_OVERLAY_EFFECTS
	pixel_x = -96
	anchored = ANCHORED_ALWAYS

	ex_act(severity)
		return

	meteorhit(obj/meteor)
		return

	New()
		..()
		icon = file("assets/icons/widescreen.dmi")
	#if defined(MAP_OVERRIDE_OSHAN)
		icon_state = "title_oshan"
		name = "Oshan Laboratory"
		desc = "An underwater laboratory on the planet Abzu."
	#endif
	#if defined(REVERSED_MAP)
		transform = list(-1, 0, 0, 0, 1, 0)
	#endif
