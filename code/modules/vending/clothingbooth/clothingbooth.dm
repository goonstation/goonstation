/**
 * # Clothing Booth
 */
/obj/machinery/clothingbooth
	name = "Clothing Booth"
	desc = "Contains a sophisticated autoloom system capable of manufacturing a variety of clothing items on demand."
	icon = 'icons/obj/vending.dmi'
	icon_state = "clothingbooth-open"
	flags = FPRINT | TGUI_INTERACTIVE
	anchored = ANCHORED
	density = 1

	/// Clothing booth emits an ambient light when powered.
	var/datum/light/ambient_light

	// Grouping and item selection.
	/// Currently selected item grouping, corresponding to the items visible on the catalogue.
	var/datum/clothingbooth_grouping/selected_grouping = null
	/// Currently selected item, corresponding to each individual swatch for multi-item groupings, or the single item inside of a singlet grouping.
	var/datum/clothingbooth_item/selected_item = null

	/// The current mob inside.
	var/mob/living/carbon/human/occupant
	/// Occupant preview.
	var/datum/movable_preview/character/multiclient/preview
	/// The item of clothing to be previewed.
	var/obj/item/clothing/preview_item
	/// The direction that the preview mob is currently facing.
	var/current_preview_direction = SOUTH
	/// If `TRUE`, show the clothing that the occupant is currently wearing on the preview.
	var/show_clothing = TRUE

	// Money handling.
	var/datum/db_record/accessed_record
	var/obj/item/card/id/scanned_id
	/// Amount of inserted cash.
	var/cash = 0

	New()
		..()
		// Set up ambient lighting.
		src.ambient_light = new /datum/light/point
		src.ambient_light.attach(src)
		src.ambient_light.set_brightness(0.6)
		src.ambient_light.set_height(1.5)
		// Preview stuff.
		src.preview = new()
		src.preview.add_background()

	disposing()
		src.eject_contents()
		src.clear_preview_item()
		qdel(src.preview)
		..()

	power_change()
		if (src.powered())
			src.status &= ~NOPOWER
			src.ambient_light.enable()
		else
			src.status |= NOPOWER
			src.ambient_light.disable()

	attackby(obj/item/W, mob/user)
		var/obj/item/card/id/id_card = get_id_card(W)
		if (istype(id_card))
			src.process_card(user, id_card)
		else if (istype(W, /obj/item/currency/spacecash))
			src.cash += W.amount
			W.amount = 0
			user.visible_message(SPAN_NOTICE("[user.name] inserts credits into [src]"))
			playsound(user, 'sound/machines/capsulebuy.ogg', 80, TRUE)
			user.u_equip(W)
			W.dropped(user)
			qdel(W)
		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (ismob(G.affecting))
				var/mob/GM = G.affecting
				if (!src.occupant)
					src.add_occupant(GM)
					qdel(G)
					user.visible_message(SPAN_ALERT("<b>[user] stuffs [GM.name] into [src]!</b>"), SPAN_ALERT("<b>You stuff [GM.name] into [src]!</b>"))
					logTheThing(LOG_COMBAT, user, "places [constructTarget(GM,"combat")] into [src] at [log_loc(src)].")
		else
			..()

	attack_hand(mob/user)
		if (!ishuman(user))
			boutput(user, SPAN_ALERT("Human clothes don't fit you!"))
			return
		if (!IN_RANGE(user, src, 1))
			return
		if (!can_act(user))
			return
		if (!src.occupant)
			src.add_occupant(user)
		else
			SETUP_GENERIC_ACTIONBAR(user, src, 10 SECONDS, PROC_REF(remove_occupant), src.occupant, src.icon, src.icon_state, "[user] forces open [src]!", INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION)

	Click()
		if ((usr in src) && !src.occupant)
			var/obj/item/equipped_item = usr.equipped()
			var/obj/item/card/id/id_card = get_id_card(equipped_item)
			if (istype(id_card))
				src.process_card(usr, id_card)
			if (istype(equipped_item, /obj/item/currency/spacecash))
				var/obj/item/dummy_credits = equipped_item
				src.cash += dummy_credits.amount
				dummy_credits.amount = 0
				qdel(dummy_credits)
			src.ui_interact(usr)
		..()

	relaymove(mob/user as mob)
		if (!isalive(user))
			return
		src.remove_occupant(user)

	ui_interact(mob/user, datum/tgui/ui)
		if (!user.client)
			return
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "ClothingBooth")
			ui.open()

	ui_close(mob/user)
		. = ..()
		src.clear_preview_item()

	ui_static_data(mob/user)
		. = ..()
		.["catalogue"] = global.serialized_clothingbooth_catalogue
		.["tags"] = global.serialized_clothingbooth_tags
		.["name"] = src.name

	ui_data(mob/user)
		var/icon/preview_icon = getFlatIcon(src.preview.preview_thing, no_anim = TRUE)
		. = list(
			"accountBalance" = src.accessed_record ? src.accessed_record["current_money"] : 0,
			"cash" = src.cash,
			"previewIcon" = icon2base64(preview_icon),
			"previewHeight" = preview_icon.Height(),
			"previewItem" = src.preview_item,
			"previewShowClothing" = src.show_clothing,
			"scannedID" = src.scanned_id,
			"selectedGroupingName" = src.selected_grouping?.name,
			"selectedItemName" = src.selected_item?.name
		)

	ui_act(action, params)
		. = ..()
		if (. || !(usr in src.contents))
			return
		switch (action)
			if ("login")
				var/obj/item/equipped_item = usr.equipped()
				var/obj/item/card/id/id_card = get_id_card(equipped_item)
				if (istype(id_card))
					src.process_card(usr, id_card)
					. = TRUE
			if ("logout")
				src.scanned_id = null
				src.accessed_record = null
				. = TRUE
			if ("select-grouping")
				var/datum/clothingbooth_grouping/selected_grouping_buffer = global.clothingbooth_catalogue[params["name"]]
				if (!selected_grouping_buffer)
					boutput(usr, SPAN_ALERT("Invalid group selected! Please call 1-800-CODER!"))
					return
				src.selected_grouping = selected_grouping_buffer
				var/first_item_name = src.selected_grouping.clothingbooth_items[1]
				var/datum/clothingbooth_item/selected_item_buffer = src.selected_grouping.clothingbooth_items[first_item_name]
				if (!selected_item_buffer)
					src.selected_item = null
					boutput(usr, SPAN_ALERT("Selected item returned nothing! Please call 1-800-CODER!"))
					return
				src.selected_item = selected_item_buffer
				src.equip_and_preview()
				. = TRUE
			if ("select-item")
				if (!src.selected_grouping)
					src.selected_item = null
					boutput(usr, SPAN_ALERT("Unable to select item without selecting a group! Please call 1-800-CODER!"))
					return
				var/datum/clothingbooth_item/selected_item_buffer = src.selected_grouping.clothingbooth_items[params["name"]]
				if (!selected_item_buffer)
					src.selected_item = null
					boutput(usr, SPAN_ALERT("Selected item returned nothing! Please call 1-800-CODER!"))
					return
				src.selected_item = selected_item_buffer
				src.equip_and_preview()
				. = TRUE
			if ("purchase")
				if (src.selected_item)
					var/price_to_pay = text2num_safe(src.selected_item.cost)
					if (src.accessed_record)
						var/money_on_card = src.accessed_record["current_money"]
						var/difference = money_on_card - price_to_pay
						if (difference < 0)
							if (src.cash >= abs(difference))
								src.accessed_record["current_money"] -= money_on_card
								src.cash -= abs(difference)
								src.purchase_item(usr)
							else
								src.insufficient_funds()
						else
							src.accessed_record["current_money"] -= money_on_card
							src.purchase_item(usr)
					else if (price_to_pay <= src.cash)
						src.cash -= price_to_pay
						src.purchase_item(usr)
					else
						src.insufficient_funds()
					. = TRUE
				else
					boutput(usr, SPAN_ALERT("No item selected! Please call 1-800-CODER!"))
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

	proc/access_bank_record(obj/item/card/id/id_card)
		var/accessed_record = data_core.bank.find_record("name", id_card.registered)
		return !!accessed_record

	proc/process_card(mob/user, obj/item/card/id/id_card)
		user.visible_message(SPAN_NOTICE("[user.name] swipes [his_or_her(user)] ID card in [src]."))
		if (src.scanned_id)
			boutput(user, SPAN_ALERT("[src] already has an ID card loaded!"))
			return
		if (src.scanned_id.registered in global.FrozenAccounts)
			boutput(user, SPAN_ALERT("This account cannot currently be liquidated due to active borrows."))
			return
		var/enter_pin = usr.enter_pin(src)
		if (enter_pin == id_card.pin)
			src.accessed_record = src.access_bank_record(id_card)
			if (src.accessed_record)
				src.scanned_id = id_card
			else
				boutput(usr, SPAN_ALERT("Cannot find a bank record for this card."))
		else
			boutput(usr, SPAN_ALERT("Incorrect pin number."))
		tgui_process?.update_uis(src)

	/// A shame this will rarely fire, since having insufficient funds will just disable the purchase button.
	proc/insufficient_funds()
		boutput(usr, SPAN_ALERT("Insufficient funds!"))
		animate_shake(src, 12, 3, 3)
		playsound(src, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)

	proc/purchase_item(mob/target)
		var/purchased_item_path = src.selected_item.item_path
		if (!purchased_item_path)
			return
		target.put_in_hand_or_drop(new purchased_item_path(src))

	proc/add_occupant(mob/target)
		if (src.occupant)
			return
		target.set_loc(src.loc)
		SPAWN(0.5 SECONDS)
			if (src.occupant)
				return
			src.icon_state = "clothingbooth-close"
			target.set_loc(src)
			src.occupant = target
			src.preview.add_client(target.client)
			src.update_preview()
			ui_interact(target)

	proc/remove_occupant(mob/target)
		if (!src.occupant)
			return
		src.icon_state = "clothingbooth-open"
		SPAWN(2 SECONDS)
			src.eject_contents(target)

	proc/eject_contents(mob/target)
		src.clear_preview_item()
		src.preview.remove_all_clients()
		tgui_process.close_uis(src)
		src.reset_clothingbooth_parameters()
		var/turf/T = get_turf(src)
		if (!target && src.occupant)
			target = src.occupant
		if (target?.loc == src) //ensure mob wasn't otherwise removed during out spawn call
			target.set_loc(T)
			if (src.cash > 0)
				target.put_in_hand_or_drop(new /obj/item/currency/spacecash(T, src.cash))
			src.cash = 0
			for (var/obj/item/I in src.contents)
				target.put_in_hand_or_drop(I)
			for (var/atom/movable/AM in contents)
				AM.set_loc(T)
		else
			if (src.cash > 0)
				new /obj/item/currency/spacecash(T, src.cash)
			src.cash = 0
			for (var/atom/movable/AM in contents)
				AM.set_loc(T)
		src.occupant = null

	proc/equip_and_preview()
		var/mob/living/carbon/human/preview_mob = src.preview.preview_thing
		if (src.preview_item)
			preview_mob.u_equip(src.preview_item)
			src.clear_preview_item()
		if (src.selected_item?.item_path)
			var/obj/item/clothing/clothing_item = new src.selected_item.item_path
			src.preview_item = clothing_item
		preview_mob.force_equip(src.preview_item, src.selected_grouping.slot)
		src.update_preview()

	proc/reset_clothingbooth_parameters()
		src.current_preview_direction = initial(src.current_preview_direction)
		src.selected_grouping = null
		src.selected_item = null

	proc/clear_preview_item()
		if (!isnull(src.preview_item))
			qdel(src.preview_item)
			src.preview_item = null

	/// generates a preview of the current occupant
	proc/update_preview()
		src.preview.update_appearance(src.occupant.bioHolder.mobAppearance, src.occupant.mutantrace, src.current_preview_direction, src.occupant.real_name)
