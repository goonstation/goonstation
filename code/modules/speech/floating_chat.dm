/obj/chat_maptext_holder
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE
	mouse_opacity = 0
	var/list/image/chat_maptext/lines = list() // a queue sure would be nice
	var/atom/movable/target
	var/registered = FALSE

	New(loc, atom/movable/target)
		..()
		if (isnull(target))
			CRASH("chat_maptext_holder requires a target")
		src.target = target

	proc/update_outermost_movable(atom/movable/_target, atom/movable/old_outermost, atom/movable/new_outermost)
		// use turf for the chat if we are in a disposal pipe and other such underfloor things
		if (old_outermost.level == UNDERFLOOR && old_outermost.invisibility == INVIS_ALWAYS)
			old_outermost = old_outermost.loc
		if (new_outermost.level == UNDERFLOOR && new_outermost.invisibility == INVIS_ALWAYS)
			new_outermost = new_outermost.loc

		old_outermost?.vis_contents -= src
		new_outermost?.vis_contents += src

	proc/notify_empty()
		if(registered)
			UnregisterSignal(target, XSIG_OUTERMOST_MOVABLE_CHANGED)
			registered = FALSE
			vis_locs = null

	proc/notify_nonempty()
		if(!registered)
			outermost_movable(target)?.vis_contents += src
			RegisterSignal(target, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(update_outermost_movable))
			registered = TRUE

	disposing()
		for(var/image/chat_maptext/I in src.lines)
			qdel(I)
		src.lines = null
		if(src.target.chat_text == src)
			src.target.chat_text = null
		src.target = null
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
		if(istype(whomob) && !isunconscious(whomob) && isliving(whomob) && !whomob.sleeping && !whomob.getStatusDuration("unconscious"))
			for (var/mob/dead/target_observer/observer in whomob:observers)
				if(!observer.client)
					continue
				observer.client << src
				src.visible_to += observer.client*/

	proc/measure(var/client/who)
		var/measured = 8
		// MeasureText sleeps and that fucks up a lot, removing for now
		src.measured_height = measured * (1 + round(length(src.maptext) / 80))

proc/make_chat_maptext(atom/target, msg, style = "", alpha = 255, force = 0, time = 40)
	var/image/chat_maptext/text = new /image/chat_maptext
	animate(text, maptext_y = 28, time = 0.01) // this shouldn't be necessary but it keeps breaking without it
	if (!force)
		msg = copytext(msg, 1, 256) // 4 lines, seems fine to me
		text.maptext = "<span class='pixel c ol' style=\"[style]\">[msg]</span>"
	else
		// force whatever it is to be shown. for not chat tings. honk.
		text.maptext = msg

	var/obj/chat_maptext_holder/holder = target.chat_text

	if(istype(target, /atom/movable) && holder)
		var/atom/movable/L = target
		holder = L.chat_text
		text.loc = holder
		if (target.layer > HUD_LAYER)
			text.layer = target.layer+1
	else
		text.loc = target

	if (holder)
		if(length(holder.lines) && holder.lines[length(holder.lines)].maptext == text.maptext)
			holder.lines[length(holder.lines)].transform *= 1.05
			qdel(text)
			return null

		holder.lines.Add(text)

		holder.notify_nonempty()

	animate(text, alpha = alpha, maptext_y = 34, time = 4, flags = ANIMATION_END_NOW)
	var/text_id = text.unique_id
	SPAWN(time)
		if(text_id == text.unique_id)
			text.bump_up(invis=1)
			sleep(0.5 SECONDS)
			qdel(text)
			if (holder && !length(holder.lines))
				holder.notify_empty()
	return text
