#define ORDER_LABEL_MAX_LEN 32 // The "order label" refers to the label you can specify when ordering something through cargo.
#define SUPPLY_PRINT_COOLDOWN 2 SECONDS //! Amount of time before supply consoles can print again
/datum/rockbox_globals
	var/const/rockbox_standard_fee = 5
	var/rockbox_client_fee_min = 1
	var/rockbox_client_fee_pct = 10
	var/rockbox_premium_purchased = 1

var/global/datum/rockbox_globals/rockbox_globals = new /datum/rockbox_globals

/proc/build_qm_categories()
	QM_CategoryList.Cut()
	if (!global.qm_supply_cache)
		message_coders("ZeWaka/QMCategories: QM Supply Cache was not found!")
	for(var/datum/supply_packs/S in qm_supply_cache )
		if(S.syndicate || S.hidden) continue //They don't have their own categories anyways.
		if (S.category)
			if (!(global.QM_CategoryList.Find(S.category)))
				QM_CategoryList += S.category
				// gonna be real here it seems more useful to have the oft-used stuff at the top.
				//global.QM_CategoryList.Insert(1,S.category) //So Misc. is not #1, reverse ordering.

/obj/machinery/computer/supplycomp
	name = "quartermaster's console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMcom"
	req_access = list(access_supply_console)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_MULTITOOL
	circuit_type = /obj/item/circuitboard/qmsupply
	var/temp = null
	var/last_cdc_message = null
	var/hacked = 0
	var/tradeamt = 1
	var/in_dialogue_box = 0
	var/obj/item/card/id/scan = null
	var/list/datum/supply_pack

	//These will be used to not update the price list needlessly
	var/last_market_update = -INFINITY
	var/price_list = null

	light_r =1
	light_g = 0.7
	light_b = 0.03

	New()
		..()
		START_TRACKING // all machinery has start tracking, but for some reason this computer ends up not being tracked by this point???
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)

/obj/machinery/computer/supplycomp/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if(!hacked)
		if(user)
			boutput(user, SPAN_NOTICE("The intake safety shorts out. Special supplies unlocked."))
		shippingmarket.launch_distance = 200 // dastardly
		src.hacked = 1
		src.req_access = list()
		src.update_static_data_for_all_viewers()
		return 1
	return 0

/obj/machinery/computer/supplycomp/demag(var/mob/user)
	if(!hacked)
		return 0
	if(user)
		boutput(user, SPAN_NOTICE("Treacherous supplies removed."))
	src.req_access = initial(src.req_access)
	src.hacked = 0
	src.update_static_data_for_all_viewers()
	return 1

/obj/machinery/computer/supplycomp/attackby(I, mob/user)
	if(!istype(I,/obj/item/card/emag))
		//I guess you'll wanna put the emag away now instead of getting a massive popup
		..()

/obj/machinery/computer/supplycomp/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SupplyConsole", src.name)
		ui.open()

/obj/machinery/computer/supplycomp/ui_static_data(mob/user)
	. = list()
	.["supply_categories"] = global.QM_CategoryList
	.["supply_entries"] = src.fetch_supply_entry_data()
	.["market_data"] = src.fetch_market_data()
	.["trader_data"] = src.fetch_trader_data()
	.["requisition_data"] = src.fetch_requisition_data()

/obj/machinery/computer/supplycomp/proc/fetch_supply_entry_data()
	. = list()
	for (var/datum/supply_packs/supply_pack in qm_supply_cache)
		if((supply_pack.syndicate && !src.hacked) || supply_pack.hidden)
			continue
		.+= list(list(
			"name" = supply_pack.name,
			"desc" = supply_pack.desc,
			"category" = supply_pack.category,
			"cost" = supply_pack.cost,
			"ref" = ref(supply_pack),
		))
		LAGCHECK(LAG_LOW)

/obj/machinery/computer/supplycomp/proc/fetch_market_data()
	. = list()
	for(var/item_type in shippingmarket.commodities)
		var/datum/commodity/C = shippingmarket.commodities[item_type]
		var/viewprice = C.price
		if (C.indemand)
			viewprice *= shippingmarket.demand_multiplier
		.+= list(list(
			"name" = C.comname,
			"in_demand" = C.indemand,
			"price" = viewprice,
		))

/obj/machinery/computer/supplycomp/proc/fetch_trader_data()
	. = list()
	for (var/datum/trader/trader in shippingmarket.active_traders)
		if (trader.hidden)
			continue
		var/cart_cost = 0
		var/total_cart_amount = 0
		var/buy_cap = global.shippingmarket.max_buy_items_at_once || 99
		for (var/datum/commodity/cart_commodity in trader.shopping_cart)
			cart_cost += cart_commodity.price * cart_commodity.amount
			total_cart_amount += cart_commodity.amount
		.+= list(list(
			"name" = trader.name,
			"ref" = ref(trader),
			"picture" = trader.picture,
			"current_message" = trader.current_message,
			"patience" = trader.patience,
			"cart_count" = total_cart_amount,
			"cart_max" = buy_cap,
			"cart_cost" = cart_cost,
			"goods_sell" = trader.fetch_commodities_data(trader.goods_sell),
			"goods_buy" = trader.fetch_commodities_data(trader.goods_buy),
			"cart" = trader.fetch_commodities_data(trader.shopping_cart),
		))

/obj/machinery/computer/supplycomp/proc/fetch_requisition_data()
	. = list()
	for (var/datum/req_contract/RC in shippingmarket.req_contracts)
		var/req_data = list()
		req_data["name"] = RC.name
		req_data["desc"]= RC.requis_desc
		req_data["ref"]= ref(RC)
		req_data["pinned"] = RC.pinned
		req_data["req_code"] = RC.req_code
		req_data["flavor_desc"] = RC.flavor_desc
		req_data["payout"] = RC.payout
		req_data["item_rewards"] = list()
		if(!RC.hide_item_payouts)
			for(var/datum/rc_itemreward/RI in RC.item_rewarders)
				req_data["item_rewards"] += list(list("name" = RI.name, "count" = RI.count))
		req_data["urgent"] = FALSE
		req_data["cycles_left"] = 0
		if(RC.req_class == AID_CONTRACT && !RC.pinned) // Cannot ordinarily be pinned. Unpin support included for contract testing.
			req_data["urgent"] = TRUE
			var/datum/req_contract/aid/RCAID = RC
			req_data["cycles_left"] = RCAID.cycles_remaining
		. += list(req_data)

/obj/machinery/computer/supplycomp/ui_data(mob/user)
	. = list()
	.["shipping_budget"] = global.wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY]
	.["market_reset_timer"] = global.shippingmarket.get_market_timeleft()
	.["order_history"] = src.fetch_order_history_data()
	.["requests"] = src.fetch_supply_request_data()
	.["signal_loss"] = global.signal_loss
	.["rockbox_transaction_percent_fee"] = global.rockbox_globals.rockbox_client_fee_pct
	.["rockbox_transaction_minimum_fee"] = global.rockbox_globals.rockbox_client_fee_min
	if(global.shippingmarket.last_market_update != src.last_market_update) //The market has refreshed.
		src.last_market_update = global.shippingmarket.last_market_update
		src.update_static_data_for_all_viewers() //Requisitions, market prices, etc.

/obj/machinery/computer/supplycomp/proc/fetch_order_history_data()
	. = list()
	var/regex/history_regex = new("(.+?) ordered by (.+?) for (.+?) credits. Comment: (.*)<br>", "m")
	for(var/entry in global.shippingmarket.supply_history)
		if (!history_regex.Find(entry))
			continue
		.+= list(list(
			"supply_name" = history_regex.group[1],
			"orderer" = history_regex.group[2],
			"cost" = history_regex.group[3],
			"comment" = history_regex.group[4],
		))

/obj/machinery/computer/supplycomp/proc/fetch_supply_request_data()
	. = list()
	for(var/datum/supply_order/SO in shippingmarket.supply_requests)
		.+= list(list(
			"supply_name" = SO.object.name,
			"order_ref" = ref(SO),
			"requester" = SO.orderedby,
			"cost" = SO.object.cost,
			"console_location" = SO.console_location,
		))

/obj/machinery/computer/supplycomp/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(!in_interact_range(src, user))
		boutput(user, SPAN_ALERT("You must be next to [src] to use it!"))
		return
	if(!src.allowed(user))
		boutput(user, SPAN_ALERT("Access Denied."))
		return
	switch(action)
		//Rockbox
		if("set_rockbox_percentage_fee")
			var/percentage = params["value"]
			percentage = max(0, percentage)
			rockbox_globals.rockbox_client_fee_pct = percentage
			boutput(user, SPAN_NOTICE("Fee Percent per Transaction is now [rockbox_globals.rockbox_client_fee_pct]%"))
			ui.send_update() //Immediately update to the changed value
			return
		if("set_rockbox_minimum_fee")
			var/value = params["value"]
			value = max(0, value)
			rockbox_globals.rockbox_client_fee_min = value
			boutput(user, SPAN_NOTICE("Minimum Fee per Transaction is now [rockbox_globals.rockbox_client_fee_min][CREDIT_SIGN]"))
			ui.send_update() //Immediately update to the changed value
			return
		//Requisitions
		if("requisition_pin")
			var/datum/req_contract/contract = locate(params["ref"]) in shippingmarket.req_contracts
			if(QDELETED(contract))
				boutput(user, SPAN_ALERT("The requisition contract has expired due to a market update."))
				return
			if(contract.req_class == AID_CONTRACT)
				boutput(user, SPAN_ALERT("That requisition contract is urgent and cannot be pinned!"))
				return
			contract.pinned = !contract.pinned
			global.shippingmarket.update_supply_console_data() //Requisition data is static so pinning one requires an immediate update.
			return
		if("requisition_print")
			var/datum/req_contract/contract = locate(params["ref"]) in shippingmarket.req_contracts
			if(QDELETED(contract))
				boutput(user, SPAN_ALERT("The requisition contract has expired due to a market update."))
				return
			if(GET_COOLDOWN(src, "print"))
				boutput(user, SPAN_ALERT("It's still cooling off from the last print!"))
				return
			if(params["type"] == "barcode")
				src.print_barcode(contract, contract.req_code)
				return
			src.print_requisition(contract)
			return
		//Supply pack orders, including requests
		if("place_order")
			var/target = locate(params["ref"])
			var/datum/supply_order/supply_order
			var/datum/supply_packs/supply_pack
			if(istype(target, /datum/supply_order)) //Ordered via a request
				supply_order = target
				supply_pack = supply_order.object
			else //Ordered via supply list
				supply_order = new()
				supply_pack = target
				supply_order.object = supply_pack
			if(src.handle_order(user, supply_order, supply_pack))
				boutput(user, SPAN_NOTICE("Order successful."))
			return
		if("deny_request")
			var/datum/supply_order/supply_order = locate(params["ref"])
			if(!istype(supply_order))
				return
			global.shippingmarket.supply_requests -= supply_order
			if(supply_order.address)
				src.send_pda_message(supply_order.address, "Your order of [supply_order.object.name] has been denied.")
			return
		//Traders
		if ("trader_sell")
			var/datum/trader/trader = locate(params["trader_ref"]) in global.shippingmarket.active_traders
			if(!src.trader_sanity_check(trader, user))
				return
			if(GET_COOLDOWN(src, "print"))
				boutput(user, SPAN_ALERT("It's still cooling off from the last print!"))
				return
			src.print_barcode(trader.name, trader.crate_tag)
			return
		if("trader_haggle")
			var/datum/trader/trader = locate(params["trader_ref"]) in global.shippingmarket.active_traders
			if(!src.trader_sanity_check(trader, user))
				return
			var/trader_goods = trader.goods_buy + trader.goods_sell
			var/buying = FALSE
			if(locate(params["commodity_ref"]) in trader.goods_sell)
				buying = TRUE
			var/datum/commodity/commodity = locate(params["commodity_ref"]) in trader_goods
			if(!src.commodity_sanity_check(commodity, user))
				return
			src.handle_haggle(user, trader, commodity, buying)
		if("trader_purchase")
			var/datum/trader/trader = locate(params["trader_ref"]) in global.shippingmarket.active_traders
			if(!src.trader_sanity_check(trader, user))
				return
			var/datum/commodity/commodity = locate(params["commodity_ref"]) in trader.goods_sell
			if(!src.commodity_sanity_check(commodity, user))
				return
			src.handle_trader_add_to_cart(user, trader, commodity, TRUE)
			return
		if("trader_remove_from_cart")
			var/datum/trader/trader = locate(params["trader_ref"]) in global.shippingmarket.active_traders
			if(!src.trader_sanity_check(trader, user))
				return
			var/datum/commodity/trader/incart/cart_commodity = locate(params["commodity_ref"]) in trader.shopping_cart
			if(!src.commodity_sanity_check(cart_commodity, user))
				return
			var/selected_amount = tgui_input_number(user, "How many units do you want to remove from the cart?", "Remove from Cart", 1, cart_commodity.amount, 0)
			if(!isnum_safe(selected_amount) || selected_amount < 1)
				return
			//Shouldn't normally be reachable thanks to the tgui window already limiting your maximum input
			if(cart_commodity.amount < selected_amount)
				selected_amount = cart_commodity.amount
			cart_commodity.amount -= selected_amount
			if(cart_commodity.reference && istype(cart_commodity.reference) && cart_commodity.reference.amount >= 0)
				cart_commodity.reference.amount += selected_amount
			if(cart_commodity.amount <= 0)
				trader.shopping_cart -= cart_commodity
				qdel(cart_commodity)
			global.shippingmarket.update_supply_console_data()
			return
		if ("trader_buy_cart")
			var/datum/trader/trader = locate(params["trader_ref"]) in global.shippingmarket.active_traders
			if(!src.trader_sanity_check(trader, user))
				return
			if (!trader.shopping_cart.len)
				boutput(user, SPAN_ALERT("There's nothing in the shopping cart to buy!"))
				return
			if (!(global.shippingmarket && istype(global.shippingmarket,/datum/shipping_market)))
				logTheThing(LOG_DEBUG, null, "<b>ISN/Trader:</b> Shippingmarket buy cap improperly configured")
			var/buy_cap = global.shippingmarket.max_buy_items_at_once || 99
			var/cart_cost = 0
			var/total_cart_amount = 0
			for (var/datum/commodity/cart_commodity in trader.shopping_cart)
				cart_cost += cart_commodity.price * cart_commodity.amount
				total_cart_amount += cart_commodity.amount
			if (total_cart_amount > buy_cap)
				boutput(user, SPAN_ALERT("There are too many items in the cart. You may only order [buy_cap] items at a time."))
				return
			if (global.wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY] < cart_cost)
				trader.current_message = pick(trader.dialogue_cant_afford_that)
				return
			trader.current_message = pick(trader.dialogue_purchase)
			trader.buy_from()
			return

/obj/machinery/computer/supplycomp/proc/handle_order(var/mob/user, var/datum/supply_order/supply_order, var/datum/supply_packs/supply_pack)
	if(!istype(supply_order) || !istype(supply_pack))
		return FALSE
	if(global.wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY] < supply_pack.cost)
		boutput(user, SPAN_ALERT("Insufficient funds in supply budget."))
		return FALSE
	var/default_comment = "" //Makes default confirm different to cancel
	var/comment = tgui_input_text(usr, "Comment:", "Enter comment", default_comment, multiline = TRUE, max_length = ORDER_LABEL_MAX_LEN, allowEmpty = TRUE)
	if(global.wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY] < supply_pack.cost)
		boutput(user, SPAN_ALERT("Insufficient funds in supply budget."))
		return FALSE
	if(isnull(comment))
		return FALSE
	if(comment && comment != default_comment)
		phrase_log.log_phrase("order-comment", comment, no_duplicates=TRUE)
	//If this is a supply order we came from the request approval form
	global.shippingmarket.supply_requests -= supply_order
	supply_order.comment = html_encode(trimtext(comment))
	supply_order.orderedby = user.name
	global.wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY] -= supply_pack.cost
	if (supply_order.address)
		src.send_pda_message(supply_order.address, "Your order of [supply_pack.name] has been approved.")
	var/obj/storage/shipment = supply_order.create(user)
	shippingmarket.receive_crate(shipment)
	logTheThing(LOG_STATION, user, "ordered a [supply_pack.name] at [log_loc(src)].")
	global.shippingmarket.supply_history += "[supply_pack.name] ordered by [supply_order.orderedby] for [supply_pack.cost] credits. Comment: [supply_order.comment]<br>"
	return TRUE

/obj/machinery/computer/supplycomp/proc/handle_haggle(var/mob/user, var/datum/trader/trader, var/datum/commodity/commodity, var/buying = FALSE)
	if(!istype(trader) || !istype(commodity))
		return
	if(trader.patience <= 0)
		trader.current_message = pick(trader.dialogue_leave)
		boutput(user, SPAN_ALERT("Your haggling has pushed [trader.name] too far, and they have left."))
		return
	var/haggle_target = tgui_input_number(user, "Suggest a new price", "Haggling", commodity.price, 1000000, 0)
	if(!isnum_safe(haggle_target) || haggle_target < 0)
		boutput(user, SPAN_ALERT("That doesn't even make any sense!"))
		return
	trader.haggle(commodity, haggle_target, buying)
	// Trader data is static, so update to new price on haggle
	global.shippingmarket.update_supply_console_data()

/obj/machinery/computer/supplycomp/proc/handle_trader_add_to_cart(var/mob/user, var/datum/trader/trader, var/datum/commodity/commodity)
	if(!istype(trader) || !istype(commodity))
		return
	if(commodity.amount == 0)
		trader.current_message = pick(trader.dialogue_out_of_stock)
		boutput(user, SPAN_ALERT("[trader.name] has no more [commodity.comname] left to trade!"))
		return
	if (!(global.shippingmarket && istype(global.shippingmarket,/datum/shipping_market)))
		logTheThing(LOG_DEBUG, null, "<b>ISN/Trader:</b> Shippingmarket buy cap improperly configured")
	var/buy_cap = global.shippingmarket.max_buy_items_at_once || 99
	var/total_stuff_in_cart
	for(var/datum/commodity/cart_commodity in trader.shopping_cart)
		total_stuff_in_cart += cart_commodity.amount
	if (total_stuff_in_cart >= buy_cap)
		boutput(user, SPAN_ALERT("You may only have a maximum of [buy_cap] items in your shopping cart. You have already reached that limit."))
		return
	var/maximum_buy = buy_cap - total_stuff_in_cart
	if(commodity.amount >= 0)
		maximum_buy = min(maximum_buy, commodity.amount)
	var/selected_amount = tgui_input_number(user, "How many units do you want to purchase?", "Trader Purchase", 1, maximum_buy, 0)
	if(!isnum_safe(selected_amount) || selected_amount < 1)
		return
	//Below two checks shouldn't normally be reachable thanks to the tgui window already limiting your maximum input
	if(commodity.amount > 0 && selected_amount > commodity.amount)
		selected_amount = commodity.amount
	if(selected_amount + total_stuff_in_cart > buy_cap)
		boutput(user, SPAN_ALERT("You may only have a maximum of [buy_cap] items in your shopping cart. This order would exceed that limit."))
		return
	var/datum/commodity/trader/incart/newcart = new(trader)
	trader.shopping_cart += newcart
	newcart.comname = commodity.comname
	newcart.price = commodity.price
	newcart.reference = commodity
	newcart.comtype = commodity.comtype
	newcart.amount = selected_amount
	if (commodity.amount > 0)
		commodity.amount -= selected_amount
	// Trader data is static, so update to new stock count
	global.shippingmarket.update_supply_console_data()

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user)
	if(!src.allowed(user))
		boutput(user, SPAN_ALERT("Access Denied."))
		return
	.=..()

/obj/machinery/computer/supplycomp/proc/print_requisition(var/datum/req_contract/contract)
	if (!ON_COOLDOWN(src, "print", SUPPLY_PRINT_COOLDOWN))
		playsound(src.loc, 'sound/machines/printer_thermal.ogg', 60, 0)
		var/obj/item/paper/P = new(src.loc)
		P.info = "<font face='System' size='2'><center>REQUISITION CONTRACT MANIFEST<br>"
		P.info += "FOR SUPPLIER REFERENCE ONLY<br><br>"
		P.info += uppertext(contract.requis_desc)
		if(contract.payout > 0 || length(contract.item_rewarders) && !contract.hide_item_payouts)
			P.info += "<br>CONTRACT REWARD:"
			if(contract.payout > 0) P.info += "<br>[contract.payout] CREDITS"
			if(!contract.hide_item_payouts)
				for(var/datum/rc_itemreward/RI in contract.item_rewarders)
					if(RI.count) P.info += "<br>[RI.count]X [uppertext(RI.name)]"
					else P.info += "<br>[uppertext(RI.name)]"
		P.info += "</center></font>"
		P.name = "Requisition: [contract.name]"
		P.icon_state = "thermal_paper"

/obj/machinery/computer/supplycomp/proc/print_barcode(to_name, destination)
	playsound(src.loc, 'sound/machines/printer_cargo.ogg', 60, 0)
	if (!ON_COOLDOWN(src, "print", SUPPLY_PRINT_COOLDOWN))
		var/obj/item/sticker/barcode/B = new/obj/item/sticker/barcode(src.loc)
		B.name = "Barcode Sticker ([to_name])"
		B.destination = destination

/obj/machinery/computer/supplycomp/proc/trader_sanity_check(var/datum/trader/trader, var/mob/user)
	if(QDELETED(trader) || !istype(trader) || trader.hidden)
		boutput(user, SPAN_ALERT("Error contacting trader. They may have departed from communications range."))
		return FALSE
	if(global.signal_loss >= 75)
		boutput(user, SPAN_ALERT("Severe signal interference is preventing contact with [trader.name]."))
		return FALSE
	return TRUE

/obj/machinery/computer/supplycomp/proc/commodity_sanity_check(var/datum/commodity/commodity, var/mob/user)
	if(QDELETED(commodity) || !istype(commodity))
		boutput(user, SPAN_ALERT("Something has gone wrong trying to access this commodity! Please file a bug report."))
		return FALSE
	return TRUE

/obj/machinery/computer/supplycomp/proc/send_pda_message(address, message)
	var/datum/signal/newsignal = get_free_signal()
	newsignal.source = src
	newsignal.data["command"] = "text_message"
	newsignal.data["sender_name"] = "CARGO-MAILBOT"
	newsignal.data["message"] = message
	newsignal.data["address_1"] = address
	newsignal.data["sender"] = "00000000"

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal, null, "pda")

#undef SUPPLY_PRINT_COOLDOWN
#undef ORDER_LABEL_MAX_LEN
