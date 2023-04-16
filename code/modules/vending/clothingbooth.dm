/*Clothing Booth UI*/
//list creation
var/list/clothingbooth_stock = list()
var/list/clothingbooth_paths = list()

/proc/clothingbooth_setup()
	var/list/list/list/boothlist = list()
	for(var/datum/clothingbooth_item/type as anything in concrete_typesof(/datum/clothingbooth_item))
		var/datum/clothingbooth_item/I = new type
		var/item_name = I.name
		var/path_name = "[I.path]"
		var/category_name = I.category
		var/cost = I.cost

		var/atom/dummy_atom = I.path
		var/icon/dummy_icon = icon(initial(dummy_atom.icon), initial(dummy_atom.icon_state), frame = 1)
		var/item_img = icon2base64(dummy_icon)

		var/match_found = FALSE
		if(length(boothlist))
			for(var/i=1, i<=boothlist.len, i++)
				if(boothlist[i]["category"] == category_name)
					match_found = TRUE
					boothlist[i]["items"] += list(list(
							"cost" = cost,
							"img" = item_img,
							"name" = item_name,
							"path" = path_name
					))
					break
		if(!match_found)
			boothlist += list(list(
				"category" = category_name,
				"items" = list(list(
					"cost" = cost,
					"img" = item_img,
					"name" = item_name,
					"path" = path_name
				))
			))

		clothingbooth_paths[path_name] = I
	clothingbooth_stock = boothlist

//clothing booth stuffs <3
/obj/machinery/clothingbooth
	name = "Clothing Booth"
	desc = "Contains a sophisticated autoloom system capable of manufacturing a variety of clothing items on demand."
	icon = 'icons/obj/vending.dmi'
	icon_state = "clothingbooth-open"
	flags = FPRINT | TGUI_INTERACTIVE
	anchored = ANCHORED
	density = 1
	var/datum/movable_preview/character/multiclient/preview
	var/datum/light/light
	var/datum/clothingbooth_item/item_to_purchase = null
	var/mob/living/carbon/human/occupant
	var/obj/item/preview_item = null
	var/money = 0
	var/open = TRUE
	var/preview_direction
	var/preview_direction_default = SOUTH

	New()
		..()
		UnsubscribeProcess()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.enable()
		src.preview = new()
		src.preview.add_background()
		src.preview_direction = src.preview_direction_default

	attackby(obj/item/weapon, mob/user)
		if(istype(weapon, /obj/item/spacecash))
			if(!(locate(/mob) in src))
				src.money += weapon.amount
				weapon.amount = 0
				user.visible_message("<span class='notice'>[user.name] inserts credits into [src]")
				playsound(user, 'sound/machines/capsulebuy.ogg', 80, 1)
				user.u_equip(weapon)
				weapon.dropped(user)
				qdel(weapon)
			else
				boutput(user,"<span style=\"color:red\">It seems the clothing booth is currently occupied. Maybe it's better to just wait.</span>")

		else if (istype(weapon, /obj/item/grab))
			var/obj/item/grab/G = weapon
			if (ismob(G.affecting))
				var/mob/GM = G.affecting
				if (src.open)
					GM.set_loc(src)
					src.occupant = GM
					src.preview.add_client(GM.client)
					src.update_preview()
					ui_interact(GM)
					user.visible_message("<span class='alert'><b>[user] stuffs [GM.name] into [src]!</b></span>","<span class='alert'><b>You stuff [GM.name] into [src]!</b></span>")
					src.close()
					qdel(G)
					logTheThing(LOG_COMBAT, user, "places [constructTarget(GM,"combat")] into [src] at [log_loc(src)].")
		else
			..()

	attack_hand(mob/user)
		if (!ishuman(user))
			boutput(user,"<span style=\"color:red\">Human clothes don't fit you!</span>")
			return
		if (!IN_RANGE(user, src, 1))
			return
		if (!can_act(user))
			return
		if (open)
			user.set_loc(src.loc)
			SPAWN(0.5 SECONDS)
				if (!open) return
				user.set_loc(src)
				src.close()
				src.occupant = user
				src.preview.add_client(user.client)
				src.update_preview()
				ui_interact(user)
		else
			SETUP_GENERIC_ACTIONBAR(user, src, 10 SECONDS, .proc/eject, null, src.icon, src.icon_state, "[user] forces open [src]!", INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION)

	Click()
		if((usr in src) && (src.open == 0))
			if(istype(usr.equipped(),/obj/item/spacecash))
				var/obj/item/dummycredits = usr.equipped()
				src.money += dummycredits.amount
				dummycredits.amount = 0
				qdel(dummycredits)
			src.ui_interact(usr)
		..()

	disposing()
		qdel(src.preview)
		qdel(src.preview_item)
		qdel(src.item_to_purchase)
		..()

	relaymove(mob/user as mob)
		if (!isalive(user))
			return
		eject(user)

	ui_interact(mob/user, datum/tgui/ui)
		if(!user.client)
			return
		if(!ishuman(user))
			return
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ClothingBooth")
			ui.open()

	ui_close(mob/user)
		. = ..()
		if (!isnull(src.preview_item))
			qdel(src.preview_item)
			src.preview_item = null

	ui_static_data(mob/user)
		. = list(
			"name" = src.name
		)
		.["clothingBoothCategories"] = clothingbooth_stock

	ui_data(mob/user)
		var/icon/preview_icon = src.preview.get_icon()
		. = list(
			"money" = src.money,
			"previewIcon" = icon2base64(preview_icon),
			"previewHeight" = preview_icon.Height(),
			"previewItem" = src.preview_item,
			"selectedItemCost" = src.item_to_purchase?.cost,
			"selectedItemName" = src.item_to_purchase?.name
		)

	ui_act(action, params)
		. = ..()
		if (. || !(usr in src.contents))
			return

		switch(action)
			if("purchase")
				if(src.item_to_purchase)
					if(text2num_safe(src.item_to_purchase.cost) <= src.money)
						src.money -= text2num_safe(src.item_to_purchase.cost)
						var/purchased_item_path = src.item_to_purchase.path
						usr.put_in_hand_or_drop(new purchased_item_path(src))
					else
						boutput(usr, "<span class='alert'>Insufficient funds!</span>")
						animate_shake(src, 12, 3, 3)
					. = TRUE
				else
					boutput(usr, "<span class='alert'>No item selected!</span>")
			if ("rotate-cw")
				src.preview_direction = turn(src.preview_direction, -90)
				update_preview()
				. = TRUE
			if ("rotate-ccw")
				src.preview_direction = turn(src.preview_direction, 90)
				update_preview()
				. = TRUE
			if("select")
				var/datum/clothingbooth_item/selected_item = clothingbooth_paths[params["path"]]
				if(!istype(selected_item))
					return
				var/selected_item_path = text2path(params["path"])
				var/mob/living/carbon/human/preview_mob = src.preview.preview_thing
				if(src.preview_item)
					preview_mob.u_equip(src.preview_item)
					qdel(src.preview_item)
					src.preview_item = null
				src.preview_item = new selected_item_path
				preview_mob.force_equip(src.preview_item, selected_item.slot)
				src.item_to_purchase = selected_item
				update_preview()
				. = TRUE

	/// open the booth
	proc/open()
		flick("clothingbooth-opening", src)
		src.icon_state = "clothingbooth-open"
		open = TRUE

	/// close the booth
	proc/close()
		flick("clothingbooth-closing", src)
		src.icon_state = "clothingbooth-closed"
		open = FALSE

	/// ejects occupant if any along with any contents
	proc/eject(mob/occupant)
		if (open) return
		open()
		SPAWN(2 SECONDS)
			qdel(src.preview_item)
			qdel(src.item_to_purchase)
			src.preview.remove_all_clients()
			src.preview_direction = src.preview_direction_default
			src.item_to_purchase = null
			tgui_process.close_uis(src)
			var/turf/T = get_turf(src)
			if (!occupant)
				occupant = locate(/mob/living/carbon/human) in src
			if (occupant?.loc == src) //ensure mob wasn't otherwise removed during out spawn call
				occupant.set_loc(T)
				if(src.money > 0)
					occupant.put_in_hand_or_drop(new /obj/item/spacecash(T, src.money))
				src.money = 0
				for (var/obj/item/I in src.contents)
					occupant.put_in_hand_or_drop(I)
				for (var/atom/movable/AM in contents)
					AM.set_loc(T) //dump anything that's left in there on out
			else
				if(src.money > 0)
					new /obj/item/spacecash(T, src.money)
				src.money = 0
				for (var/atom/movable/AM in contents)
					AM.set_loc(T)

	/// generates a preview of the current occupant
	proc/update_preview()
		src.preview.update_appearance(src.occupant.bioHolder.mobAppearance, src.occupant.mutantrace, src.preview_direction, src.occupant.real_name)
