/mob/dead/target_observer/mentor_mouse_observer
	name = "mentor mouse"
	real_name = "mentor mouse"
	is_respawnable = FALSE
	var/image/ping
	var/ping_id
	var/mob/the_guy
	var/mob/living/critter/small_animal/mouse/weak/mentor/my_mouse
	var/is_admin = 0

	var/leave_popup_open = FALSE

	New(atom/L, is_admin)
		..()
		src.is_admin = is_admin
		if(istype(L, /mob))
			src.the_guy = L
		src.ping = new('icons/effects/64x64.dmi', icon_state="thick_ring")
		src.ping.color = "#b954e0"
		if(src.is_admin)
			src.ping.color = "#e05d54"
			src.name = "admin mouse"
			src.real_name = "admin mouse"
		src.ping.blend_mode = BLEND_ADD
		src.ping.layer = HUD_LAYER_3
		src.ping.plane = PLANE_HUD
		src.ping.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA

	process_move(keys)
		if(keys && src.move_dir && !src.leave_popup_open)
			src.leave_popup_open = TRUE
			if(tgui_alert(src, "Are you sure you want to leave?", "Hop out of the pocket", list("Yes", "No")) == "Yes")
				qdel(src)
			src.leave_popup_open = FALSE

	click(atom/target, params) // TODO spam delay
		if (!islist(params))
			params = params2list(params)

		if(!params["ctrl"]) // mouse ping is now ctrl+click
			return ..()

		src.the_guy << src.ping
		src << src.ping

		var/my_id = world.time
		src.ping_id = my_id

		src.ping.pixel_x = text2num(params["icon-x"]) - 32
		src.ping.pixel_y = text2num(params["icon-y"]) - 32
		src.ping.loc = target

		src.ping.alpha = 0
		var/matrix/M = new /matrix
		M.Reset()
		M.Scale(3/2, 3/2)
		src.ping.transform = M
		M.Scale(1/10, 1/10)
		animate(src.ping, alpha = 255, time = 1 SECOND, easing = SINE_EASING)
		animate(src.ping, transform = M, time = 1 SECOND, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		qdel(M)

		SPAWN(1 SECONDS)
			if(my_id == src.ping_id) // spam clicking and stuff
				animate(src.ping, alpha = 0, time = 0.3 SECOND, easing = SINE_EASING)
				animate(src.ping, transform = null, time = 0.3 SECOND, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
			sleep(0.3 SECOND)
			if(my_id == src.ping_id)
				src.ping.loc = null

	examine_verb(atom/A)
		. = ..()
		if(istype(A, /obj/machinery/computer3))
			A.Attackhand(src)

	say_understands(var/other)
		return 1

	say(var/message)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		if (!message)
			return

		if (dd_hasprefix(message, "*"))
			return

		if(src.is_admin)
			logTheThing(LOG_DIARY, src, "(ADMINMOUSE): [message]", "say")
		else
			logTheThing(LOG_DIARY, src, "(MENTORMOUSE): [message]", "say")

		if (src.client && src.client.ismuted())
			boutput(src, "You are currently muted and may not speak.")
			return

#ifdef DATALOGGER
		game_stats.ScanText(message)
#endif

		var/more_class = " mhelp"
		if(src.is_admin)
			more_class = " adminooc"
		var/rendered = "<span class='game say[more_class]'><span class='name' data-ctx='\ref[src.mind]'>[src.name]</span> whispers, <span class='message'>\"[message]\"</span></span>"
		var/rendered_admin = "<span class='game say[more_class]'><span class='name' data-ctx='\ref[src.mind]'>[src.name] ([src.ckey])</span> whispers, <span class='message'>\"[message]\"</span></span>"

		//show message to admins
		for (var/client/C)
			if (!C.mob) continue
			var/mob/M = C.mob
			if(M == src || M == src.the_guy)
				continue
			if (C.holder && !C.player_mode)
				var/thisR = rendered
				if ((istype(M, /mob/dead/observer)||C.holder) && src.mind)
					thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[rendered_admin]</span>"
				boutput(M, thisR)

		boutput(src, rendered)
		boutput(src.the_guy, rendered)

	emote(act, voluntary=0)
		..()
		src.my_mouse.emote(act, voluntary)

	stop_observing()
		boot()

	disposing()
		if(src.client)
			src.removeOverlaysClient(src.client)
		if(src.my_mouse)
			src.my_mouse.set_loc(get_turf(src))
			src.mind?.transfer_to(src.my_mouse)
			if(!get_turf(src))
				src.my_mouse.gib()
		src.the_guy = null
		src.my_mouse = null
		..()

	proc/boot()
		if(!src.my_mouse)
			src.my_mouse = new
		src.target?.visible_message("\The [src.my_mouse] jumps out of [src.target]'s pocket.")
		if(src.client)
			src.removeOverlaysClient(src.client)
		src.my_mouse.set_loc(get_turf(src))
		if(src.mind)
			src.mind.transfer_to(src.my_mouse)
		else if(src.client)
			src.my_mouse.client = src.client
		if(!get_turf(src))
			src.my_mouse.gib()
		src.my_mouse = null
		qdel(src)
