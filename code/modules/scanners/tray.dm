TYPEINFO(/obj/item/device/t_scanner)
	mats = list("crystal" = 1,
				"conductive" = 1)
/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A tuneable terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = FALSE
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	item_state = "accessgun"
	m_amt = 50
	g_amt = 20
	var/scan_range = 3
	var/client/last_client = null
	var/image/last_display = null
	var/find_interesting = TRUE
	var/list/datum/contextAction/actions = null
	contextLayout = new /datum/contextLayout/experimentalcircle
	var/show_underfloor_cables = TRUE
	var/show_underfloor_disposal_pipes = TRUE
	var/show_blueprint_disposal_pipes = TRUE

	New()
		..()
		actions = list()
		for(var/actionType in childrentypesof(/datum/contextAction/t_scanner)) //see context_actions.dm
			var/datum/contextAction/t_scanner/action = new actionType(src)
			actions += action

	dropped(mob/user)
		. = ..()
		user?.closeContextActions()

	/// Update the inventory, ability, and context buttons
	proc/set_on(new_on, mob/user=null)
		on = new_on
		set_icon_state("t-ray[on]")
		for(var/datum/contextAction/t_scanner/action in src.actions)
			if(istype(action, /datum/contextAction/t_scanner/active))
				action.icon_state ="[action.base_icon_state][on ? "on" : "off"]"
		if(user)
			boutput(user, "You switch [src] [on ? "on" : "off"].")
		if(!on)
			hide_displays()
		else
			processing_items |= src

	proc/set_underfloor_cables(state, mob/user=null)
		show_underfloor_cables = state
		for(var/datum/contextAction/t_scanner/action in src.actions)
			if(istype(action, /datum/contextAction/t_scanner/underfloor_cables))
				action.icon_state = "[action.base_icon_state][show_underfloor_cables ? "on" : "off"]"
		if(user)
			boutput(user, "You switch [src] to [show_underfloor_cables ? "show" : "hide"] underfloor cables.")

	proc/set_underfloor_disposal_pipes(state, mob/user=null)
		show_underfloor_disposal_pipes = state
		for(var/datum/contextAction/t_scanner/action in src.actions)
			if(istype(action, /datum/contextAction/t_scanner/underfloor_disposal_pipes))
				action.icon_state = "[action.base_icon_state][show_underfloor_disposal_pipes ? "on" : "off"]"
		if(user)
			boutput(user, "You switch [src] to [show_underfloor_disposal_pipes ? "show" : "hide"] underfloor disposal pipes.")

	proc/set_blueprint_disposal_pipes(state, mob/user=null)
		show_blueprint_disposal_pipes = state
		for(var/datum/contextAction/t_scanner/action in src.actions)
			if(istype(action, /datum/contextAction/t_scanner/blueprint_disposal_pipes))
				action.icon_state = "[action.base_icon_state][show_blueprint_disposal_pipes ? "on" : "off"]"
		if(user)
			boutput(user, "You switch [src] to [show_blueprint_disposal_pipes ? "show" : "hide"] disposal pipe blueprints.")

	attack_self(mob/user)
		user.showContextActions(actions, src, contextLayout)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (istype(A, /turf))
			if (BOUNDS_DIST(A, user) > 0) // Scanning for COOL LORE SECRETS over the camera network is fun, but so is drinking and driving.
				return
			if(A.interesting && src.on)
				animate_scanning(A, "#7693d3")
				user.visible_message(SPAN_ALERT("<b>[user]</b> has scanned the [A]."))
				boutput(user, "<br><i>Historical analysis:</i><br>[SPAN_NOTICE("[A.interesting]")]")
				return
		else if (istype(A, /obj) && A.interesting)
			animate_scanning(A, "#7693d3")
			user.visible_message(SPAN_ALERT("<b>[user]</b> has scanned the [A]."))
			boutput(user, "<br><i>Analysis failed:</i><br>[SPAN_NOTICE("Unable to determine signature")]")

	proc/hide_displays()
		if(last_client)
			last_client.images -= last_display
		qdel(last_display)
		last_display = null
		last_client = null

	disposing()
		hide_displays()
		last_display = null
		last_client = null
		..()

	process()
		hide_displays()

		if(!on)
			processing_items.Remove(src)
			return null

		var/mob/our_mob = src
		while(!isnull(our_mob) && !istype(our_mob, /turf) && !ismob(our_mob)) our_mob = our_mob.loc
		if(!istype(our_mob) || !our_mob.client)
			return null
		var/client/C = our_mob.client
		var/turf/center = get_turf(our_mob)

		var/image/main_display = image(null)
		for(var/turf/T in range(src.scan_range, our_mob))
			if(T.interesting && find_interesting)
				our_mob.playsound_local(T, 'sound/machines/ping.ogg', 55, 1)

			var/image/display = new

			for(var/atom/A in T)
				if(A.interesting && find_interesting)
					our_mob.playsound_local(A, 'sound/machines/ping.ogg', 55, 1)
				if(ismob(A))
					var/mob/M = A
					if(M?.invisibility != INVIS_CLOAK || !(BOUNDS_DIST(src, M) == 0))
						continue
				else if(isobj(A))
					var/obj/O = A
					if (O.level == OVERFLOOR && !istype(O, /obj/disposalpipe))
						continue // show unsecured pipes behind walls
					if (!show_underfloor_cables && istype(O, /obj/cable))
						continue
					if (!show_underfloor_disposal_pipes && istype(O, /obj/disposalpipe))
						continue
				var/image/img = image(A.icon, icon_state=A.icon_state, dir=A.dir)
				img.plane = PLANE_SCREEN_OVERLAYS
				img.color = A.color
				img.overlays = A.overlays
				img.alpha = 100
				img.appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE
				display.overlays += img

			if (show_blueprint_disposal_pipes && T.disposal_image)
				display.overlays += T.disposal_image

			if(length(display.overlays))
				display.plane = PLANE_SCREEN_OVERLAYS
				display.pixel_x = (T.x - center.x) * 32
				display.pixel_y = (T.y - center.y) * 32
				main_display.overlays += display

		main_display.loc = our_mob.loc

		C.images += main_display
		last_display = main_display
		last_client = C

/obj/item/device/t_scanner/abilities = list(/obj/ability_button/tscanner_toggle)

/obj/item/device/t_scanner/adventure
	name = "experimental scanner"
	desc = "a bodged-together T-Ray scanner with a few coils cut, and a few extra coils tied-in."
	scan_range = 4

/obj/item/device/t_scanner/pda
	name = "PDA T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	find_interesting = FALSE

/*
he`s got a craving
for american haiku
that cannot be itched
*/
