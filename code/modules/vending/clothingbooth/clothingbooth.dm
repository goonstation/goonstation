// TO DO
// alter spans to use macros

// clothing booth stuffs <3
/obj/machinery/clothingbooth
	name = "Clothing Booth"
	desc = "Contains a sophisticated autoloom system capable of manufacturing a variety of clothing items on demand."
	icon = 'icons/obj/vending.dmi'
	icon_state = "clothingbooth-open"
	flags = FPRINT | TGUI_INTERACTIVE
	anchored = ANCHORED
	density = 1
	var/datum/light/ambient_light

	var/selected_item = null
	var/selected_variant = null
	/// Path ref for `/obj/item/clothing`.
	var/clothing_to_purchase_path = null

	var/datum/movable_preview/character/multiclient/preview
	var/mob/living/carbon/human/occupant
	var/obj/item/clothing/preview_item = null
	var/current_preview_direction = SOUTH
	/// If `TRUE`, show the clothing that the occupant is currently wearing on the preview.
	var/show_clothing = TRUE

	/// Amount of inserted cash; presently, only cash is accepted.
	var/money = 0
	/// `src` can only be entered if `src.open` is TRUE.
	var/open = TRUE

	New()
		..()
		UnsubscribeProcess()
		src.ambient_light = new /datum/light/point
		src.ambient_light.attach(src)
		src.ambient_light.set_brightness(0.6)
		src.ambient_light.set_height(1.5)
		src.ambient_light.enable()
		src.preview = new()
		src.preview.add_background()

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/currency/spacecash))
			if(!(locate(/mob) in src))
				src.money += W.amount
				W.amount = 0
				user.visible_message("<span class='notice'>[user.name] inserts credits into [src]")
				playsound(user, 'sound/machines/capsulebuy.ogg', 80, TRUE)
				user.u_equip(W)
				W.dropped(user)
				qdel(W)
			else
				boutput(user,"<span style=\"color:red\">It seems the clothing booth is currently occupied. Maybe it's better to just wait.</span>")

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
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
			SETUP_GENERIC_ACTIONBAR(user, src, 10 SECONDS, PROC_REF(eject), null, src.icon, src.icon_state, "[user] forces open [src]!", INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION)

	Click()
		if((usr in src) && (src.open == 0))
			if(istype(usr.equipped(),/obj/item/currency/spacecash))
				var/obj/item/dummycredits = usr.equipped()
				src.money += dummycredits.amount
				dummycredits.amount = 0
				qdel(dummycredits)
			src.ui_interact(usr)
		..()

	disposing()
		qdel(src.preview)
		qdel(src.preview_item)
		qdel(src.selected_item)
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
		. = ..()
		.["itemLookups"] = global.clothingbooth_stock_ui_data["itemLookups"]
		.["itemGroupings"] = global.clothingbooth_stock_ui_data["itemGroupings"]
		.["name"] = src.name

	ui_data(mob/user)
		var/icon/preview_icon = getFlatIcon(src.preview.preview_thing, no_anim = TRUE)
		. = list(
			"money" = src.money,
			"previewIcon" = icon2base64(preview_icon),
			"previewHeight" = preview_icon.Height(),
			"previewItem" = src.preview_item,
			"selectedVariant" = src.selected_variant,
			"showClothing" = src.show_clothing,
		)
		.["selectedItem"]  = src.selected_item

	ui_act(action, params)
		. = ..()
		if (. || !(usr in src.contents))
			return

		switch(action)
			if ("select-item")
				var/selected_item_buffer = global.clothingbooth_stock_list[params["name"]]
				if (!selected_item_buffer)
					boutput(usr, "<span class='alert'>Invalid item selected!</span>")
					return
				src.selected_item = selected_item_buffer
				var/selected_variant_buffer = params["variantName"]
				if (!src.selected_item["variants"][selected_variant_buffer])
					boutput(usr, "<span class='alert'>Selected variant doesn't exist!</span>")
					src.selected_item = null
					return
				src.selected_variant = src.selected_item["variants"][selected_variant_buffer]
				src.equip_and_preview()
				. = TRUE
			if ("select-variant")
				if (!src.selected_item)
					boutput(usr, "<span class='alert'>How? Nothing's selected!</span>")
					return
				var/selected_variant_buffer = params["variantName"]
				if (!src.selected_item["variants"][selected_variant_buffer])
					boutput(usr, "<span class='alert'>Selected variant doesn't exist!</span>")
					return
				src.selected_variant = src.selected_item["variants"][selected_variant_buffer]
				src.equip_and_preview()
				. = TRUE
			if ("purchase")
				if (src.selected_item)
					// var/variant_to_purchase = src.selected_item["variants"][src.selected_variant]
					// if (text2num_safe(src.selected_item.cost) <= src.money)
					// 	src.money -= text2num_safe(src.selected_item.cost)
					// 	var/purchased_item_path
					// 	if ()
					// 	usr.put_in_hand_or_drop(new purchased_item_path(src))
					// else
					// 	boutput(usr, "<span class='alert'>Insufficient funds!</span>")
					// 	animate_shake(src, 12, 3, 3)
					. = TRUE
				else
					boutput(usr, "<span class='alert'>No item selected!</span>")
			if ("rotate-cw")
				src.current_preview_direction = turn(src.current_preview_direction, -90)
				src.update_preview()
				. = TRUE
			if ("rotate-ccw")
				src.current_preview_direction = turn(src.current_preview_direction, 90)
				src.update_preview()
				. = TRUE
			if ("toggle-clothing")
				src.show_clothing = !src.show_clothing
				src.equip_and_preview()
				. = TRUE

	/// open the booth
	proc/open()
		flick("clothingbooth-opening", src)
		src.icon_state = "clothingbooth-open"
		src.open = TRUE

	/// close the booth
	proc/close()
		flick("clothingbooth-closing", src)
		src.icon_state = "clothingbooth-closed"
		src.open = FALSE

	/// ejects occupant if any along with any contents
	proc/eject(mob/occupant)
		if (open) return
		open()
		SPAWN(2 SECONDS)
			qdel(src.preview_item)
			qdel(src.selected_item)
			src.preview.remove_all_clients()
			src.current_preview_direction = initial(src.current_preview_direction)
			src.selected_item = null
			src.selected_variant = null
			src.clothing_to_purchase_path = null
			tgui_process.close_uis(src)
			var/turf/T = get_turf(src)
			if (!occupant)
				occupant = locate(/mob/living/carbon/human) in src
			if (occupant?.loc == src) //ensure mob wasn't otherwise removed during out spawn call
				occupant.set_loc(T)
				if(src.money > 0)
					occupant.put_in_hand_or_drop(new /obj/item/currency/spacecash(T, src.money))
				src.money = 0
				for (var/obj/item/I in src.contents)
					occupant.put_in_hand_or_drop(I)
				for (var/atom/movable/AM in contents)
					AM.set_loc(T) //dump anything that's left in there on out
			else
				if(src.money > 0)
					new /obj/item/currency/spacecash(T, src.money)
				src.money = 0
				for (var/atom/movable/AM in contents)
					AM.set_loc(T)

	proc/equip_and_preview()
		var/mob/living/carbon/human/preview_mob = src.preview.preview_thing
		if (src.preview_item)
			preview_mob.u_equip(src.preview_item)
			qdel(src.preview_item)
			src.preview_item = null
		src.clothing_to_purchase_path = src.selected_variant["itemPath"]
		var/obj/item/clothing/clothing_item = new src.clothing_to_purchase_path
		src.preview_item = clothing_item
		src.reference_clothes(src.occupant, preview_mob)
		var/slot_to_clear = preview_mob.get_slot(src.selected_item["slot"])
		slot_to_clear = null
		preview_mob.force_equip(src.preview_item, src.selected_item["slot"])
		src.update_preview()

	proc/reference_clothes(mob/living/carbon/human/to_copy, mob/living/carbon/human/to_paste)
		src.clear_clothing(to_paste)
		if (!src.show_clothing)
			return

		to_paste.wear_suit = to_copy.wear_suit
		to_paste.w_uniform = to_copy.w_uniform
		to_paste.shoes = to_copy.shoes
		to_paste.belt = to_copy.belt
		to_paste.gloves = to_copy.gloves
		to_paste.glasses = to_copy.glasses
		to_paste.head = to_copy.head
		to_paste.wear_id = to_copy.wear_id
		to_paste.back = to_copy.back
		to_paste.wear_mask = to_copy.wear_mask
		to_paste.ears = to_copy.ears

	proc/clear_clothing(mob/living/carbon/human/to_paste)
		to_paste.wear_suit = null
		to_paste.w_uniform = null
		to_paste.shoes = null
		to_paste.belt = null
		to_paste.gloves = null
		to_paste.glasses = null
		to_paste.head = null
		to_paste.wear_id = null
		to_paste.r_store = null
		to_paste.l_store = null
		to_paste.back = null
		to_paste.wear_mask = null
		to_paste.ears = null

	/// generates a preview of the current occupant
	proc/update_preview()
		src.preview.update_appearance(src.occupant.bioHolder.mobAppearance, src.occupant.mutantrace, src.current_preview_direction, src.occupant.real_name)
