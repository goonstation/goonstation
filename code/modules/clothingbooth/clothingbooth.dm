/**
 * # Clothing Booth
 *
 * A vendor for purchasing clothing items using a TGUI interface that (should) allow for the easy navigation of an otherwise large pile of available
 * stock.
 *
 * Pulls the list of available stock from `global.clothingbooth_catalogue`, see `clothingbooth_datums.dm` to see how those are all generated.
 */
/obj/machinery/clothingbooth
	name = "clothing booth"
	desc = "Contains a sophisticated autoloom system capable of manufacturing a variety of clothing items on demand."
	icon = 'icons/obj/vending.dmi'
	icon_state = "clothingbooth-open"
	flags = TGUI_INTERACTIVE
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
	/// If `TRUE`, don't check for account balance or inserted money.
	var/everything_is_free = FALSE

	/// Optional dye color or matrix to apply to all sold objects.
	var/dye

/obj/machinery/clothingbooth/New()
	..()
	// Set up ambient lighting.
	src.ambient_light = new /datum/light/point
	src.ambient_light.attach(src)
	src.ambient_light.set_brightness(0.6)
	src.ambient_light.set_height(1.5)

	// Preview stuff.
	src.preview = new()
	src.preview.add_background()

	if (src.everything_is_free)
		src.maptext_y = 34
		src.maptext = "<span class='pixel c vb'>FREE</span>"
		src.name = "completely free [src.name]"
		src.desc += " This one happens to not need any money."

/obj/machinery/clothingbooth/disposing()
	src.eject_contents()
	src.clear_preview_item()
	qdel(src.preview)
	src.preview = null
	qdel(src.ambient_light)
	src.ambient_light = null
	src.accessed_record = null
	src.scanned_id = null
	..()

/obj/machinery/clothingbooth/power_change()
	if (src.powered())
		src.status &= ~NOPOWER
		src.ambient_light.enable()
		src.icon_state = "clothingbooth-open"
	else
		src.status |= NOPOWER
		src.ambient_light.disable()
		src.remove_occupant()
		SPAWN(2 SECONDS) // allow remove_occupant to finish animating
			src.icon_state = "clothingbooth-off"

/obj/machinery/clothingbooth/attackby(obj/item/W, mob/user)
	if (src.status & NOPOWER)
		return
	var/obj/item/card/id/id_card = get_id_card(W)
	if (istype(id_card))
		src.process_card(user, id_card)
		return
	if (istype(W, /obj/item/currency/spacecash))
		var/obj/item/currency/spacecash/cash_to_add = W
		src.add_cash(user, cash_to_add)
		return
	if (istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if (!ismob(G.affecting))
			return
		var/mob/GM = G.affecting
		if (src.occupant)
			return
		src.add_occupant(GM)
		qdel(G)
		user.visible_message(SPAN_ALERT("<b>[user] stuffs [GM.name] into [src]!</b>"), SPAN_ALERT("<b>You stuff [GM.name] into [src]!</b>"))
		logTheThing(LOG_COMBAT, user, "places [constructTarget(GM,"combat")] into [src] at [log_loc(src)].")
		return
	..()

/obj/machinery/clothingbooth/attack_hand(mob/user)
	if (status & NOPOWER)
		return
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

/obj/machinery/clothingbooth/Click()
	if ((usr in src) && src.occupant)
		var/obj/item/equipped_item = usr.equipped()
		var/obj/item/card/id/id_card = get_id_card(equipped_item)
		if (istype(id_card))
			src.process_card(usr, id_card)
		if (istype(equipped_item, /obj/item/currency/spacecash))
			var/obj/item/currency/spacecash/cash_to_add = equipped_item
			src.add_cash(usr, cash_to_add)
		src.ui_interact(usr)
	..()

/obj/machinery/clothingbooth/relaymove(mob/user as mob)
	if (!isalive(user))
		return
	src.remove_occupant(user)

/obj/machinery/clothingbooth/ui_interact(mob/user, datum/tgui/ui)
	if (!user.client)
		return
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ClothingBooth")
		ui.open()

/obj/machinery/clothingbooth/ui_close(mob/user)
	. = ..()
	src.clear_preview_item()

/obj/machinery/clothingbooth/ui_static_data(mob/user)
	. = ..()
	.["catalogue"] = global.serialized_clothingbooth_catalogue
	.["tags"] = global.serialized_clothingbooth_tags
	.["name"] = src.name

/obj/machinery/clothingbooth/ui_data(mob/user)
	var/icon/preview_icon = getFlatIcon(src.preview.preview_thing, no_anim = TRUE)
	. = list(
		"accountBalance" = src.accessed_record ? src.accessed_record["current_money"] : 0,
		"cash" = src.cash,
		"everythingIsFree" = src.everything_is_free,
		"previewIcon" = icon2base64(preview_icon),
		"previewHeight" = preview_icon.Height(),
		"previewItem" = src.preview_item,
		"previewShowClothing" = src.show_clothing,
		"scannedID" = src.scanned_id,
		"selectedGroupingName" = src.selected_grouping?.name,
		"selectedItemName" = src.selected_item?.name
	)

/obj/machinery/clothingbooth/ui_act(action, params)
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
		if ("eject_cash")
			src.eject_cash(get_turf(src), usr)
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
				if (src.everything_is_free)
					src.purchase_item(usr)
					return TRUE
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
						src.accessed_record["current_money"] -= price_to_pay
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

/obj/machinery/clothingbooth/proc/process_card(mob/user, obj/item/card/id/id_card)
	if (src.everything_is_free)
		boutput(user, SPAN_ALERT("You won't need that where you're going, everything is free!"))
		return
	if (src.scanned_id)
		boutput(user, SPAN_ALERT("[src] already has an ID card loaded!"))
		return
	if (id_card.registered in global.FrozenAccounts)
		boutput(user, SPAN_ALERT("This account cannot currently be liquidated due to active borrows."))
		return
	var/enter_pin = usr.enter_pin(src)
	if (enter_pin == id_card.pin)
		var/datum/db_record/record_to_access = data_core.bank.find_record("name", id_card.registered)
		if (record_to_access)
			src.scanned_id = id_card
			src.accessed_record = record_to_access
			user.visible_message(SPAN_NOTICE("[user.name] swipes [his_or_her(user)] ID card in [src]."))
		else
			boutput(usr, SPAN_ALERT("Cannot find a bank record for this card."))
	else
		boutput(usr, SPAN_ALERT("Incorrect pin number."))
	tgui_process?.update_uis(src)

/obj/machinery/clothingbooth/proc/add_cash(mob/user, obj/item/currency/spacecash/cash_to_add)
	if (src.everything_is_free)
		boutput(user, SPAN_ALERT("You won't need that where you're going, everything is free!"))
		return
	if (!cash_to_add?.amount)
		boutput(user, SPAN_ALERT("No cash to insert!"))
		return
	src.cash += cash_to_add.amount
	cash_to_add.amount = 0
	user.visible_message(SPAN_NOTICE("[user.name] inserts credits into [src]"))
	user.u_equip(cash_to_add)
	cash_to_add.dropped(user)
	playsound(user, 'sound/machines/capsulebuy.ogg', 80, TRUE)
	qdel(cash_to_add)

/obj/machinery/clothingbooth/proc/eject_cash(turf/location, mob/target)
	if (src.cash <= 0)
		return
	if (!location)
		location = get_turf(src)
	if (ismob(target))
		target.put_in_hand_or_drop(new /obj/item/currency/spacecash(location, src.cash))
	else
		new /obj/item/currency/spacecash(location, src.cash)
	src.cash = 0

/// A shame this will rarely fire, since having insufficient funds will just disable the purchase button.
/obj/machinery/clothingbooth/proc/insufficient_funds()
	boutput(usr, SPAN_ALERT("Insufficient funds!"))
	animate_shake(src, 12, 3, 3)
	playsound(src, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)

/obj/machinery/clothingbooth/proc/purchase_item(mob/target)
	var/purchased_item_path = src.selected_item.item_path
	if (!purchased_item_path)
		return
	var/obj/item/clothing/purchased_item = new purchased_item_path(src)
	if (src.dye)
		purchased_item.color = src.dye
	target.put_in_hand_or_drop(purchased_item)

/obj/machinery/clothingbooth/proc/add_occupant(mob/target)
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
		src.equip_and_preview()
		src.ui_interact(target)

/obj/machinery/clothingbooth/proc/remove_occupant(mob/target)
	if (!src.occupant)
		return
	src.icon_state = "clothingbooth-open"
	SPAWN(2 SECONDS)
		src.eject_contents(target)

/obj/machinery/clothingbooth/proc/eject_contents(mob/target)
	src.clear_preview_item()
	src.preview.remove_all_clients()
	tgui_process.close_uis(src)
	src.reset_clothingbooth_parameters()
	var/turf/T = get_turf(src)
	if (!target && src.occupant)
		target = src.occupant
	if (target?.loc == src) // Ensure mob wasn't otherwise removed during out spawn call.
		target.set_loc(T)
		src.eject_cash(T, target)
		for (var/obj/item/I in src.contents)
			target.put_in_hand_or_drop(I)
		for (var/atom/movable/AM in contents)
			AM.set_loc(T)
	else
		src.eject_cash(T)
		for (var/atom/movable/AM in contents)
			AM.set_loc(T)
	src.occupant = null

// Blatantly stolen from `/datum/component/barber`.
/obj/machinery/clothingbooth/proc/reference_clothes(mob/living/carbon/human/to_copy, mob/living/carbon/human/to_paste)
	src.nullify_clothes(to_paste)
	to_paste.wear_suit = to_copy.wear_suit
	to_paste.w_uniform = to_copy.w_uniform
	to_paste.shoes = to_copy.shoes
	to_paste.gloves = to_copy.gloves
	to_paste.glasses = to_copy.glasses
	to_paste.head = to_copy.head
	to_paste.wear_id = to_copy.wear_id

/obj/machinery/clothingbooth/proc/nullify_clothes(mob/living/carbon/human/to_nullify)
	to_nullify.wear_suit = null
	to_nullify.w_uniform = null
	to_nullify.shoes = null
	to_nullify.gloves = null
	to_nullify.glasses = null
	to_nullify.head = null
	to_nullify.wear_id = null

/obj/machinery/clothingbooth/proc/equip_and_preview()
	var/mob/living/carbon/human/preview_mob = src.preview.preview_thing
	if (src.preview_item)
		preview_mob.vars[src.selected_grouping.slot] = null
		src.clear_preview_item()
	if (src.selected_item?.item_path)
		var/obj/item/clothing/clothing_item = new src.selected_item.item_path
		src.preview_item = clothing_item
	if (src.dye)
		src.preview_item.color = src.dye
	if (src.show_clothing)
		src.reference_clothes(src.occupant, preview_mob)
	else
		src.nullify_clothes(preview_mob)
	if (src.preview_item)
		//we don't want to actually EQUIP the thing so we can't use equip procs, we just want to copy the ref into the respective var, hence:
		preview_mob.vars[src.selected_grouping.slot] = src.preview_item //hehe hoohoo
	var/datum/human_limbs/preview_mob_limbs = preview_mob.limbs
	// Get those limbs!
	preview_mob_limbs.replace_with("l_arm", src.occupant.limbs.l_arm.type, show_message = FALSE)
	preview_mob_limbs.replace_with("r_arm", src.occupant.limbs.r_arm.type, show_message = FALSE)
	preview_mob_limbs.replace_with("l_leg", src.occupant.limbs.l_leg.type, show_message = FALSE)
	preview_mob_limbs.replace_with("r_leg", src.occupant.limbs.r_leg.type, show_message = FALSE)
	src.update_preview()

/obj/machinery/clothingbooth/proc/reset_clothingbooth_parameters()
	src.current_preview_direction = initial(src.current_preview_direction)
	src.selected_grouping = null
	src.selected_item = null

/obj/machinery/clothingbooth/proc/clear_preview_item()
	qdel(src.preview_item)
	src.preview_item = null

/obj/machinery/clothingbooth/proc/update_preview()
	src.preview.update_appearance(src.occupant.bioHolder.mobAppearance, src.occupant.mutantrace, src.current_preview_direction, src.occupant.real_name)

/obj/machinery/clothingbooth/free
	everything_is_free = TRUE

/obj/machinery/clothingbooth/clothingboothgbr
	name = "Strange Clothing Booth"
	color = list(0,1,0,1,0,1,1,1,0)
	dye = list(0,1,0,0,0,1,1,0,0)

/obj/machinery/clothingbooth/clothingboothbr/free
	everything_is_free = TRUE

/obj/machinery/clothingbooth/clothingboothbrg
	name = "Unusual Clothing Booth"
	color = list(1,0,1,1,1,0,0,1,1)
	dye = list(0,0,1,1,0,0,0,1,0)

/obj/machinery/clothingbooth/clothingboothbrg/free
	everything_is_free = TRUE
