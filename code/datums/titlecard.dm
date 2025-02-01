/datum/titlecard
	var/global/list/maptext_areas = list()
	var/global/last_pregame_html = ""

	#if defined(MAP_OVERRIDE_OSHAN)
	var/image_url = "images/titlecards/oshan_titlecard.png"
	#elif defined(MAP_OVERRIDE_MANTA)
	var/image_url = "images/titlecards/manta_titlecard.png"
	#elif defined(MAP_OVERRIDE_POD_WARS)
	var/image_url = "images/titlecards/podwars.png"
	#else
	var/image_url = "images/titlecards/main_titlecard.gif"
	#endif
	var/is_game_mode = FALSE
	var/add_html = ""
	var/overlay_image_url = null

	heisenbee
		image_url = "images/titlecards/heisenbee_titlecard.png"
		add_html = {"<a href="https://www.deviantart.com/alexbluebird" target="_blank" style="position:absolute;bottom:3px;right:3px;color:white;opacity:0.7;">by AlexBlueBird</a>"}

	hehe
		image_url = "images/titlecards/hehe_titlecard.png"

	s
		image_url = "images/titlecards/s_titlecard.png"

	nightshade
		image_url = "images/titlecards/nightshade2024_titlecard.png"

	nightshade_2
		image_url = "images/titlecards/nightshade2024_titlecard2.png"

	disaster
		overlay_image_url = "images/titlecards/disaster_titlecard.gif"
		is_game_mode = TRUE

	battleroyale
		overlay_image_url = "images/titlecards/battleroyale_titlecard.png"
		is_game_mode = TRUE

/datum/titlecard/proc/set_pregame_html()
#if defined(BANISH_PREGAME_HTML)
	var/turf/T = landmarks[LANDMARK_LOBBY_LEFTSIDE]?[1]
	if(T)
		T = locate(T.x + 3, T.y, T.z)
		if (locate(/obj/titlecard) in T) return
		new /obj/titlecard(T)
	return
#else
	last_pregame_html = {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>@font-face{font-family:'PxPlus IBM VGA9';src:url([resource("misc/ibmvga9.ttf")]);}body,#overlay{margin:0;padding:0;background:url([resource(src.image_url)]) black;background-size:contain;background-repeat:no-repeat;overflow:hidden;background-position:center center;background-attachment:fixed;image-rendering:pixelated;}"}
	if (isnull(src.overlay_image_url))
		last_pregame_html += {"#overlay{display:none;}"}
	else
		last_pregame_html += {"#overlay{background-image:url([resource(src.overlay_image_url)]);background-color:transparent;left:0;top:0;right:0;bottom:0;position:fixed;}"}
	last_pregame_html += {".area{white-space:pre;color:#fff;text-shadow: -2px -2px 0px #000, 2px -2px 0px #000, -2px 2px 0px #000, 2px 2px 0px #000, 2px 0px 0px #000, -2px 0px 0px #000, 0px 2px 0px #000, 0px -2px 0px #000;font:1em 'PxPlus IBM VGA9';-webkit-text-stroke:0.083em black;}a{text-decoration:none;}#leftside{position:fixed;left:0;bottom:0;}#tip{text-align: center; width: 80%; white-space: pre-wrap; font-size: 0.7em; margin: 10px auto auto auto;}#status,#timer{text-align:center;position:fixed;right:0;bottom:0;height:12%;width:40%;}#timer{bottom:15%;}</style></head><body><script>document.onclick=function(){location="byond://winset?id=mapwindow.map&focus=true";};function set_area(id,text){document.getElementById(id).innerHTML=text||"";};onresize=function(){document.body.style.fontSize=Math.min(innerWidth/672,innerHeight/480)*16+"px";};onload=function(){onresize();location="byond://winset?command=.send-lobby-text";};</script><div id="overlay"></div><div id="tip" class="area"></div><div id="status" class="area"></div><div id="timer" class="area"></div><div id="leftside" class="area"></div>[src.add_html]</body></html>"}
	for(var/client/C)
		if(istype(C.mob, /mob/new_player))
			C << browse(last_pregame_html, "window=pregameBrowser")
			if(C)
				winshow(C, "pregameBrowser", 1)
				var/mob/new_player/new_player = C.mob
				new_player.pregameBrowserLoaded = TRUE
	pregameHTML = last_pregame_html
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
		for(var/client/C)
			if(istype(C.mob, /mob/new_player))
				var/mob/new_player/new_player = C.mob
				if(new_player.pregameBrowserLoaded)
					C << output(list2params(list(id, text)), "pregameBrowser:set_area")

/client/verb/send_lobby_text()
	set name = ".send-lobby-text"
	set hidden = 1

	if (!istype(src?.mob, /mob/new_player))
		return

	lobby_titlecard.send_lobby_text(src)

/datum/titlecard/proc/send_lobby_text(client/C)
	if (last_pregame_html != pregameHTML)
		return
	if(isnull(pregameHTML))
		return

#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
	if(current_state <= GAME_STATE_PREGAME)
		return
#endif
	var/mob/new_player/new_player = C.mob
	if(istype(new_player) && new_player.pregameBrowserLoaded)
		for (var/id in maptext_areas)
			C << output(list2params(list(id, maptext_areas[id])), "pregameBrowser:set_area")
		C << output(list2params(list("tip", src.get_tip(new_player))), "pregameBrowser:set_area")

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

proc/get_global_tip()
	var/static/global_tip = null
	if(isnull(global_tip))
		global_tip = get_random_tip()
	. = global_tip

/mob/new_player/verb/refresh_tip()
	set name = ".refresh_tip"
	set hidden = 1
	src.my_own_roundstart_tip = get_random_tip()
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
	#elif defined(MAP_OVERRIDE_MANTA)
		icon_state = "title_manta"
		name = "The NSS Manta"
		desc = "Some fancy comic about the NSS Manta and its travels on the planet Abzu."
	#endif
	#if defined(REVERSED_MAP)
		transform = list(-1, 0, 0, 0, 1, 0)
	#endif
