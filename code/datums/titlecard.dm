/datum/titlecard
	var/global/list/maptext_areas = list()
	var/global/last_pregame_html = ""

	#if defined(MAP_OVERRIDE_OSHAN)
	var/image_url = "images/oshan_titlecard.png"
	#elif defined(MAP_OVERRIDE_MANTA)
	var/image_url = "images/manta_titlecard.png"
	#else
	var/image_url = "images/main_titlecard.gif"
	#endif
	var/is_game_mode = FALSE
	var/add_html = ""
	var/overlay_image_url = null

	heisenbee
		image_url = "images/heisenbee_titlecard.png"
		add_html = {"<a href="https://www.deviantart.com/alexbluebird" target="_blank" style="position:absolute;bottom:3px;right:3px;color:white;opacity:0.7;">by AlexBlueBird</a>"}

	hehe
		image_url = "images/hehe_titlecard.png"

	s
		image_url = "images/s_titlecard.png"

	nightshade
		image_url = "images/nightshade_titlecard.png"

	disaster
		overlay_image_url = "images/disaster_titlecard.gif"
		is_game_mode = TRUE

	battleroyale
		overlay_image_url = "images/battleroyale_titlecard.png"
		is_game_mode = TRUE

/datum/titlecard/proc/set_pregame_html()
	last_pregame_html = {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>@font-face{font-family:'PxPlus IBM VGA9';src:url([resource("misc/ibmvga9.ttf")]);}body,#overlay{margin:0;padding:0;background:url([resource(src.image_url)]) black;background-size:contain;background-repeat:no-repeat;overflow:hidden;background-position:center center;background-attachment:fixed;image-rendering:pixelated;}"}
	if (isnull(src.overlay_image_url))
		last_pregame_html += {"#overlay{display:none;}"}
	else
		last_pregame_html += {"#overlay{background-image:url([resource(src.overlay_image_url)]);background-color:transparent;left:0;top:0;right:0;bottom:0;position:fixed;}"}
	last_pregame_html += {".area{white-space:pre;color:#fff;text-shadow: -2px -2px 0 #000, 2px -2px 0 #000, -2px 2px 0 #000, 2px 2px 0 #000;font:1em 'PxPlus IBM VGA9';-webkit-text-stroke:0.083em black;}a{text-decoration:none;}#leftside{position:fixed;left:0;bottom:0;}#status,#timer{text-align:center;position:fixed;right:0;bottom:0;height:12%;width:40%;}#timer{bottom:15%;}</style></head><body><script>document.onclick=function(){location="byond://winset?id=mapwindow.map&focus=true";};function set_area(id,text){document.getElementById(id).innerHTML=text||"";};onresize=function(){document.body.style.fontSize=Math.min(innerWidth/672,innerHeight/480)*16+"px";};onload=function(){onresize();location="byond://winset?command=.send-lobby-text";};</script><div id="overlay"></div><div id="status" class="area"></div><div id="timer" class="area"></div><div id="leftside" class="area"></div>[src.add_html]</body></html>"}
	pregameHTML = last_pregame_html
	for(var/client/C)
		if(istype(C.mob, /mob/new_player))
			C << browse(pregameHTML, "window=pregameBrowser")
			if(C)
				winshow(C, "pregameBrowser", 1)

/datum/titlecard/proc/set_maptext(id, text)
	maptext_areas[id] = text
	if (last_pregame_html == pregameHTML)
		for(var/client/C)
			if(istype(C.mob, /mob/new_player))
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

	for (var/id in maptext_areas)
		C << output(list2params(list(id, maptext_areas[id])), "pregameBrowser:set_area")

///old title card turf
/obj/titlecard
	appearance_flags = TILE_BOUND
	icon = null //set in New()
	icon_state = "title_main"
	layer = 60
	name = "Space Station 13"
	desc = "The title card for it, at least."
	plane = PLANE_OVERLAY_EFFECTS
	pixel_x = -96
	anchored = 2

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
