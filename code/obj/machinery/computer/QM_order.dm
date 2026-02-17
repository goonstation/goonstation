/obj/machinery/computer/ordercomp
	name = "supply request console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMreq"
	circuit_type = /obj/item/circuitboard/qmorder

	light_r =1
	light_g = 0.7
	light_b = 0.03

	/// id scanned for purchases straight from account
	var/obj/item/card/id/scanned_id = null
	/// name of where console is found
	var/console_location = null
	/// associative list of buy categories to a list containing ajdacent lists of info for each supply pack in that category
	var/static/list/buy_list

	// ui vars
	/// current category of supply packs being viewed
	var/current_category = "All"

	New()
		..()
		console_location = get_area(src)
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)

/obj/machinery/computer/ordercomp/ui_interact(mob/user, datum/tgui/ui)
	if (!src.buy_list)
		src.buy_list = list()
		src.buy_list["All"] = list()

		for (var/category in global.QM_CategoryList)
			src.buy_list[category] = list()

		for (var/datum/supply_packs/pack in global.qm_supply_cache)
			if (pack.syndicate || pack.hidden)
				continue
			src.buy_list["All"] += list(list("pack_ref" = "\ref[pack]", "pack_name" = pack.name, "pack_cost" = pack.cost, "pack_desc" = pack.desc))
			src.buy_list[pack.category] += list(list("pack_ref" = "\ref[pack]", "pack_name" = pack.name, "pack_cost" = pack.cost, "pack_desc" = pack.desc))
			LAGCHECK(LAG_LOW)

	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SupplyRequestConsole")
		ui.open()

/obj/machinery/computer/ordercomp/ui_static_data(mob/user)
	. = list("categories_available" = list("All") + global.QM_CategoryList)

/obj/machinery/computer/ordercomp/ui_data(mob/user)
	var/datum/db_record/account = src.scanned_id ? FindBankAccountByName(src.scanned_id.registered) : null

	var/list/shipping_requests = list()
	for(var/datum/supply_order/order in shippingmarket.supply_requests)
		shipping_requests += list(list("order_item" = order.object.name, "ordered_by" = order.orderedby, "order_loc" = order.console_location))

	. = list("shipping_budget" = wagesystem.shipping_budget,
			 "scanned_id_name" = src.scanned_id ? src.scanned_id.registered : null,
			 "account_frozen" = src.scanned_id ? (src.scanned_id.registered in FrozenAccounts) : null,
			 "account_credits" = (account ? account["current_money"] : null),
			 "viewing_category" = src.current_category,
			 "items_to_show" = src.buy_list[src.current_category],
			 "shipping_requests" = shipping_requests
			)

/obj/machinery/computer/ordercomp/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	var/mob/user = usr

	var/play_sound = FALSE

	switch (action)
		if ("id_clicked")
			src.scanned_id = null
			src.try_register_id_card(user, user.equipped())

			play_sound = TRUE

			. = TRUE
		if ("contribute_to_shipping_budget")
			var/datum/db_record/account = FindBankAccountByName(src.scanned_id.registered)

			var/transaction = tgui_input_number(user, "How much?", "Contribute", 0, account["current_money"], 0, round_input = TRUE)
			transaction = clamp(transaction, 0, account["current_money"])
			if (transaction > 0)
				account["current_money"] -= transaction
				wagesystem.shipping_budget += transaction
				boutput(user, SPAN_NOTICE("Transaction successful. Thank you for your patronage."))

				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT", "group"=list(MGD_CARGO, MGA_SHIPPING), \
					"sender"="00000000", "message"="Notification: [transaction] credits transferred to shipping budget from [src.scanned_id.registered].")
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")

			play_sound = TRUE

			. = TRUE
		if ("set_viewing_category")
			src.current_category = params["category"]
			. = TRUE
		if ("purchase")
			var/datum/supply_order/order = new
			var/datum/supply_packs/pack = locate(params["pack_ref"])

			order.object = pack
			order.orderedby = user.name
			order.console_location = src.console_location

			var/datum/signal/pdaSignal = get_free_signal()

			var/datum/db_record/account = src.scanned_id ? FindBankAccountByName(src.scanned_id.registered) : null
			if(account)
				account["current_money"] -= pack.cost
				if (account["pda_net_id"])
					order.address = account["pda_net_id"]
				order.used_personal_funds = TRUE
				shippingmarket.receive_crate(order.create(user))
				logTheThing(LOG_STATION, user, "ordered a [pack.name] at [log_loc(src)].")
				boutput(user, SPAN_NOTICE("Your order of [pack.name] has been processed and will be delivered shortly."))
				shippingmarket.supply_history += "[order.object.name] ordered by [order.orderedby] for [pack.cost] credits from personal account.<BR>"

				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT", "group"=list(MGD_CARGO, MGA_SHIPPING), \
					"sender"="00000000", "message"="Notification: [order.object] ordered by [order.orderedby] using personal account at [order.console_location].")
			else
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					for (var/obj/item/device/pda2/pda in list(H.get_slot(SLOT_L_HAND), H.get_slot(SLOT_R_HAND), H.get_slot(SLOT_WEAR_ID), H.get_slot(SLOT_BELT)))
						if (pda.host_program.message_on && pda.owner)
							order.address = pda.net_id
							break
				shippingmarket.supply_requests += order
				boutput(user, SPAN_NOTICE("Request for [pack.name] sent to Supply Console. The Quartermasters will process your request as soon as possible."))

				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT", "group"=list(MGD_CARGO, MGA_CARGOREQUEST), \
					"sender"="00000000", "message"="Notification: [order.object] requested by [order.orderedby] at [order.console_location].")

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")

			play_sound = TRUE

			. = TRUE

	if (play_sound)
		playsound(get_turf(src), 'sound/machines/keypress.ogg', 30, TRUE, -15)

/obj/machinery/computer/ordercomp/attackby(obj/item/I, mob/user)
	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card))
		src.try_register_id_card(user, id_card)
	else
		..()

/obj/machinery/computer/ordercomp/proc/try_register_id_card(mob/user, obj/possible_id_card)
	var/obj/item/card/id/id_card = get_id_card(possible_id_card)
	if (!istype(id_card))
		return
	boutput(user, SPAN_NOTICE("You swipe the ID card."))
	var/datum/db_record/account = FindBankAccountByName(id_card.registered)
	if (account)
		var/enterpin = user.enter_pin("Supply Request Console")
		if (enterpin == id_card.pin)
			boutput(user, SPAN_NOTICE("Card authorized."))
			src.scanned_id = id_card
		else
			boutput(user, SPAN_ALERT("PIN incorrect."))
			src.scanned_id = null
	else
		boutput(user, SPAN_ALERT("No bank account associated with this ID found."))
		src.scanned_id = null
