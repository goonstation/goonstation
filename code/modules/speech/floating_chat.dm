/obj/chat_maptext_holder
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE
	mouse_opacity = 0
	var/list/image/chat_maptext/lines = list() // a queue sure would be nice

	disposing()
		for(var/image/chat_maptext/I in src.lines)
			pool(I)
		src.lines = null
		for(var/A in src.vis_locs)
			if(isliving(A))
				var/mob/living/L = A
				if(L.chat_text == src)
					L.chat_text = null
			A:vis_contents -= src
		..()

/image/chat_maptext
	var/bumped = 0
	var/list/client/visible_to = list()
	bumped = 0
	layer = HUD_LAYER_UNDER_1
	plane = PLANE_HUD
	maptext_x = -64
	maptext_y = 28
	maptext_width = 160
	maptext_height = 48
	alpha = 0
	icon = null
	appearance_flags = PIXEL_SCALE
	var/unique_id
	var/measured_height = 8

	unpooled(var/pooltype)
		..()
		// for optimization purposes some of these could probably be left out if necessary because they *shouldn't* ever change
		src.bumped = initial(src.bumped)
		src.layer = initial(src.layer)
		src.plane = initial(src.plane)
		src.maptext_x = initial(src.maptext_x)
		src.maptext_y = initial(src.maptext_y)
		src.maptext_width = initial(src.maptext_width)
		src.maptext_height = initial(src.maptext_height)
		src.alpha = initial(src.alpha)
		src.icon = initial(src.icon)
		src.appearance_flags = initial(src.appearance_flags)
		src.measured_height = initial(src.measured_height)
		src.transform = null
		for(var/client/C in src.visible_to)
			C.images -= src
		src.visible_to = list()
		src.unique_id = TIME

	disposing()
		if(istype(src.loc, /obj/chat_maptext_holder))
			var/obj/chat_maptext_holder/holder = src.loc
			holder.lines -= src
		for(var/client/C in src.visible_to)
			C.images -= src
		src.loc = null
		src.unique_id = 0
		..()

	proc/bump_up(how_much = 8, invis = 0)
		src.bumped++
		if(invis)
			animate(src, alpha = 0, maptext_y = src.maptext_y + how_much, time = 4)
		else
			animate(src, maptext_y = src.maptext_y + how_much, time = 4)

	proc/show_to(var/client/who)
		if(!istype(who))
			return
		who << src
		src.visible_to += who
		/*var/mob/whomob = who.mob
		if(istype(whomob) && !isunconscious(whomob) && isliving(whomob) && !whomob.sleeping && !whomob.getStatusDuration("paralysis"))
			for (var/mob/dead/target_observer/observer in whomob:observers)
				if(!observer.client)
					continue
				observer.client << src
				src.visible_to += observer.client*/

	proc/measure(var/client/who)
		var/measured = 8
		if(istype(who)) // client's a client
			measured = who.MeasureText(src.maptext, width = src.maptext_width)
		else if(length(clients) >= 1) // even if it isnt *your* client
			var/client/C = pick(clients)
			measured = C.MeasureText(src.maptext, width = src.maptext_width)
		src.measured_height = text2num(splittext(measured, "x")[2])

proc/make_chat_maptext(atom/target, msg, style = "", alpha = 255)
	var/image/chat_maptext/text = unpool(/image/chat_maptext)
	animate(text, maptext_y = 28, time = 0.01) // this shouldn't be necessary but it keeps breaking without it
	msg = copytext(msg, 1, 128) // 4 lines, seems fine to me
	text.maptext = "<span class='pixel c ol' style=\"[style]\">[msg]</span>"
	if(istype(target, /atom/movable))
		var/atom/movable/L = target
		text.loc = L.chat_text
		if(length(L.chat_text.lines) && L.chat_text.lines[length(L.chat_text.lines)].maptext == text.maptext)
			L.chat_text.lines[length(L.chat_text.lines)].transform *= 1.05
			pool(text)
			return null
		L.chat_text.lines.Add(text)
	else // hmm?
		text.loc = target
	animate(text, alpha = alpha, maptext_y = 34, time = 4, flags = ANIMATION_END_NOW)
	var/text_id = text.unique_id
	SPAWN_DBG(4 SECONDS)
		if(text_id == text.unique_id)
			text.bump_up(invis=1)
			sleep(0.5 SECONDS)
			pool(text)
	return text
