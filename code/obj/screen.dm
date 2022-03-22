/atom/movable/screen
	name = "screen"
	icon = 'icons/mob/screen1.dmi'
	layer = HUD_LAYER
	var/list/clients = new
	mat_changename = 0
	mat_changedesc = 0

/atom/movable/screen/proc/clicked(list/params, mob/user = null)

/atom/movable/screen/proc/add_to_client(var/client/C)
	if (clients)
		clients |= C
	C.screen += src

/atom/movable/screen/disposing()
	if (clients)
		for(var/client/C in clients)
			if (C.mob)
				if(ishuman(C.mob))
					var/mob/living/carbon/human/H = C.mob
					if (H.hud)
						H.hud.inventory_bg -= src
						H.hud.inventory_items -= src
			C.screen -= src
		clients.len = 0
	clients = null
	..()

/atom/movable/screen/grab
	name = "grab"

/atom/movable/screen/intent_sel
	name = "Intent Select"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "help"

/atom/movable/screen/stamina_background
	name = "stamina"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "stamina"


/mob/living/proc/update_stamina_desc(var/newDesc)
	.= 0

/mob/living/carbon/human/update_stamina_desc(var/newDesc)
	if (src.hud && src.hud.stamina)
		src.hud.stamina.desc = newDesc

/mob/living/critter/update_stamina_desc(var/newDesc)
	if (src.hud && src.hud.stamina)
		src.hud.stamina.desc = newDesc

/atom/movable/screen/stamina_bar
	name = "Stamina"
	desc = ""
	icon = 'icons/mob/hud_human_new.dmi'
	icon_state = "stamina_bar"
	var/last_val = -123123
	var/tooltipTheme = "stamina"
	var/last_update = 0
	layer = HUD_LAYER-1

	New(var/mob/living/carbon/C)
		..(null)
		src.loc = null
		if (C && istype(C))
			src.desc = src.getDesc(C)
		if (ishuman(C))
			SPAWN(0)
				var/icon/hud_style = hud_style_selection[get_hud_style(C)]
				if (isicon(hud_style))
					src.icon = hud_style

	proc/getDesc(var/mob/living/C)
		return "[C.stamina] / [C.stamina_max] Stamina. Regeneration rate : [(C.stamina_regen + GET_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS))]"

	proc/update_value(var/mob/living/C)
		last_update = TIME
		if(C.stamina_max <= 0 || abs(C.stamina - last_val) * 32 / C.stamina_max <= 1) return //No need to change anything
		else last_val = C.stamina

		if(C.stamina < 0)
			//icon_state = "stamina_bar_neg"
			var/scaling = C.stamina / STAMINA_NEG_CAP
			src.transform = matrix(1, scaling, MATRIX_SCALE)
			var/offy = nround((21 - (21 * scaling)) / 2)
			src.screen_loc =  "EAST-1:0, NORTH:-[offy]"
			animate(src, time = 1, color = rgb(255, 0, 0),  easing = LINEAR_EASING, loop = -1)
			animate(time = 1, color = rgb(200, 200, 200),  easing = LINEAR_EASING, loop = -1)
		else
			//icon_state = "stamina_bar"
			var/x = max(0, C.stamina)
			var/scaling = x / C.stamina_max
			//var/red = ((1 - scaling) * 255)
			src.transform = matrix(1, scaling, MATRIX_SCALE)
			var/offy = nround((21 - (21 * scaling)) / 2)
			src.screen_loc =  "EAST-1:0, NORTH:-[offy]"
			animate(src, time = 5, color = rgb(255, 255, 1),  easing = LINEAR_EASING)
			//src.transform = M
			//src.color = rgb(red, 255 - red, 1)

		var/newDesc = src.getDesc(C)
		src.desc = newDesc
		C.update_stamina_desc(newDesc)
		return

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = src.name,
				"content" = (src.desc ? src.desc : null),
				"theme" = src.tooltipTheme
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

/atom/movable/screen/intent_sel/clicked(list/params)
	var/icon_x = text2num(params["icon-x"])
	var/icon_y = text2num(params["icon-y"])

	var/mob/user = usr
	if (!istype(usr))
		return

	if (icon_y > 16)
		if (icon_x > 16) //Upper Right
			user.set_a_intent(INTENT_DISARM)
			src.icon_state = "disarm"
			if(literal_disarm && ishuman(user))
				var/mob/living/carbon/human/H = user
				H.limbs.l_arm.sever()
				H.limbs.r_arm.sever()
		else //Upper Left
			user.set_a_intent(INTENT_HELP)
			src.icon_state = "help"

	else
		if (icon_x > 16) //Lower Right
			user.set_a_intent(INTENT_HARM)
			src.icon_state = "harm"
		else //Lower Left
			user.set_a_intent(INTENT_GRAB)
			src.icon_state = "grab"

	boutput(user, "<span class='hint'>Your intent is now set to '[user.a_intent]'.</span>")

/atom/movable/screen/clicked(list/params)
	switch(src.name)
		if("stamina")
			out(usr, src.desc)
