/obj/screen
	name = "screen"
	icon = 'icons/mob/screen1.dmi'
	layer = HUD_LAYER
	var/list/clients = new
	mat_changename = 0
	mat_changedesc = 0

/obj/screen/proc/clicked(list/params, mob/user = null)

/obj/screen/proc/add_to_client(var/client/C)
	if (clients)
		clients -= C
		clients += C
	C.screen += src

/obj/screen/disposing()
	if (clients)
		for(var/client/C in clients)
			if (C.mob && ishuman(C.mob))
				var/mob/living/carbon/human/H = C.mob
				if (H.hud)
					H.hud.inventory_bg -= src
					H.hud.inventory_items -= src

			C.screen -= src
		clients.len = 0
	clients = null
	..()

/obj/screen/grab
	name = "grab"

/obj/screen/intent_sel
	name = "Intent Select"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "help"

/obj/screen/stamina_background
	name = "stamina"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "stamina"

/obj/screen/stamina_bar
	name = "Stamina"
	desc = ""
	icon = 'icons/mob/hud_human_new.dmi'
	icon_state = "stamina_bar"
	var/last_val = -123123
	var/tooltipTheme = "stamina"

	New(var/mob/living/carbon/C)
		..()
		if (C && istype(C))
			src.desc = src.getDesc(C)
		if (ishuman(C))
			SPAWN_DBG(0)
				var/icon/hud_style = hud_style_selection[get_hud_style(C)]
				if (isicon(hud_style))
					src.icon = hud_style

	proc/getDesc(var/mob/living/carbon/C)
		return "[C.stamina] / [C.stamina_max] Stamina. Regeneration rate : [(C.stamina_regen + C.get_stam_mod_regen())]"

	proc/update_value(var/mob/living/carbon/C)
		if(!istype(C)) return

		if(C.stamina == last_val) return //No need to change anything
		else last_val = C.stamina

		if(C.stamina < 0)
			//icon_state = "stamina_bar_neg"
			var/scaling = C.stamina / STAMINA_NEG_CAP
			src.transform = matrix(1, scaling, MATRIX_SCALE)
			var/offy = nround((21 - (21 * scaling)) / 2)
			src.screen_loc =  "EAST-1:0, NORTH:-[offy]"
			animate(src, time = 3, color = rgb(255, 255, 255),  easing = LINEAR_EASING, loop = -1)
			animate(time = 3, color = rgb(255, 0, 0),  easing = LINEAR_EASING, loop = -1)
		else
			//icon_state = "stamina_bar"
			var/x = max(0, C.stamina)
			var/scaling = x / C.stamina_max
			var/red = ((1 - scaling) * 255)
			src.transform = matrix(1, scaling, MATRIX_SCALE)
			var/offy = nround((21 - (21 * scaling)) / 2)
			src.screen_loc =  "EAST-1:0, NORTH:-[offy]"
			animate(src, time = 5, color = rgb(red, 255 - red, 1),  easing = LINEAR_EASING)
			//src.transform = M
			//src.color = rgb(red, 255 - red, 1)

		var/newDesc = src.getDesc(C)
		src.desc = newDesc
		if (C:hud && C:hud:stamina) //grossssss
			C:hud:stamina:desc = newDesc
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

/obj/screen/intent_sel/clicked(list/params)
	var/icon_x = text2num(params["icon-x"])
	var/icon_y = text2num(params["icon-y"])

	var/mob/user = usr
	if (!istype(usr))
		return

	if (icon_y > 16)
		if (icon_x > 16) //Upper Right
			user.a_intent = INTENT_DISARM
			src.icon_state = "disarm"
			if(literal_disarm && ishuman(user))
				var/mob/living/carbon/human/H = user
				H.limbs.l_arm.sever()
				H.limbs.r_arm.sever()
		else //Upper Left
			user.a_intent = INTENT_HELP
			src.icon_state = "help"

	else
		if (icon_x > 16) //Lower Right
			user.a_intent = INTENT_HARM
			src.icon_state = "harm"
		else //Lower Left
			user.a_intent = INTENT_GRAB
			src.icon_state = "grab"

	boutput(user, "<span style=\"color:blue\">Your intent is now set to '[user.a_intent]'.</span>")

/obj/screen/clicked(list/params)
	switch(src.name)
		if("stamina")
			out(usr, src.desc)
