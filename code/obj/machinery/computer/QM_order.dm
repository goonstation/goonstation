/obj/machinery/computer/ordercomp
	name = "supply request console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMreq"
	var/obj/item/card/id/scan = null
	var/console_location = null
	circuit_type = /obj/item/circuitboard/qmorder

	light_r =1
	light_g = 0.7
	light_b = 0.03

	New()
		..()
		console_location = get_area(src)
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

/obj/machinery/computer/ordercomp/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "qmreq1"
/obj/machinery/computer/ordercomp/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "qmreq1"

/obj/machinery/computer/ordercomp/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SupplyRequestConsole", src.name)
		ui.open()

/obj/machinery/computer/ordercomp/ui_static_data(mob/user)
	. = list()
	.["supply_categories"] = global.QM_CategoryList
	.["supply_entries"] = global.shippingmarket.fetch_supply_entry_data(include_syndicate = FALSE)

/obj/machinery/computer/ordercomp/ui_data(mob/user)
	. = list()
	.["shipping_budget"] = global.wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY]
	.["market_reset_timer"] = global.shippingmarket.get_market_timeleft()
	.["requests"] = global.shippingmarket.fetch_supply_request_data()
	.["signal_loss"] = global.signal_loss
	var/list/account_data = list()
	if(src.scan)
		account_data["scanned_name"] = src.scan.registered
		account_data["scanned_job"] = src.scan.assignment
		var/datum/db_record/account = FindBankAccountByName(src.scan.registered)
		if(account)
			account_data["scanned_credits"] = account["current_money"]
	.["account_data"] = account_data

/obj/machinery/computer/ordercomp/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(!in_interact_range(src, user))
		boutput(user, SPAN_ALERT("You must be next to [src] to use it!"))
		return
	switch(action)
		// Account management
		if("scan_id")
			var/obj/item/card/id/id_card = get_id_card(user.equipped())
			if(!istype(id_card))
				boutput(user, SPAN_ALERT("You need an ID card to sign in!"))
				return
			src.scan_id(id_card, user)
		if("logout")
			src.scan = null
			tgui_process.update_uis(src)
		if("contribute")
			if(!src.scan?.registered)
				boutput(user, SPAN_ALERT("You need to scan an ID with a registered name to donate!"))
				return
			if (src.scan.registered in global.FrozenAccounts)
				boutput(user, SPAN_ALERT("Your account cannot currently be liquidated due to active borrows."))
				return
			var/datum/db_record/account = FindBankAccountByName(src.scan.registered)
			var/reccomended_amount = round(account["current_money"]/20) //Make sure to donate generously!
			var/text = "How much to donate? <br>Current Budget: [global.wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY]]"
			var/amount = tgui_input_number(user, text , src.name, reccomended_amount, account["current_money"])
			if(!isnum_safe(amount) || amount < 1)
				return
			if(account["current_money"] < amount)
				boutput(user, SPAN_ALERT("ERROR: Insufficient funds. Donation cancelled."))
				return
			if(!scan || !account)
				boutput(user, SPAN_ALERT("ERROR: Logout detected mid-transaction. Please remain logged in to donate"))
				return
			account["current_money"] -= amount
			wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY] += amount
			boutput(user, SPAN_NOTICE("Donation complete. Thank you for your patronage!"))
			src.pda_alert("Notification: [amount] credits transferred to supply budget from [src.scan.registered].", list(MGT_CARGO, MGA_SHIPPING))
		// Request management
		if("place_order")
			src.handle_order(locate(params["ref"]), user)
		if("deny_request")
			var/datum/supply_order/supply_order = locate(params["ref"])
			if(!istype(supply_order))
				return
			if(supply_order.orderedby != user.name)
				boutput(user, SPAN_ALERT("You cannot cancel a request you didn't make!"))
				return
			global.shippingmarket.supply_requests -= supply_order
			if(supply_order.address)
				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1" = supply_order.address, \
									"command" = "text_message", \
									"sender_name" = "CARGO-MAILBOT",  \
									"sender" = "00000000", \
									"message"= "Your order of [supply_order.object.name] has been cancelled")
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")

/obj/machinery/computer/ordercomp/proc/handle_order(var/datum/supply_packs/supply_pack, mob/user)
	if(!istype(supply_pack))
		boutput(user, SPAN_ALERT("Communications error with central supply console. Please notify a Certified Service Technician."))
		return
	// The order computer has no emagged / other ability to display hidden or syndicate packs.
	// It follows that someone's being clever if trying to order either of these items
	if(supply_pack.syndicate || supply_pack.hidden)
		if (usr in range(1)) //Check that whoever's doing this is nearby - otherwise they could gib any old scrub
			trigger_anti_cheat(usr, "tried to href exploit order packs on [src]") // Get that jerk
		return

	var/datum/db_record/account = null
	if(src.scan)
		if (src.scan.registered in global.FrozenAccounts)
			boutput(usr, SPAN_ALERT("Your account cannot currently be liquidated due to active borrows."))
			return
		account = FindBankAccountByName(src.scan.registered)
	var/datum/supply_order/order = new/datum/supply_order()
	order.object = supply_pack
	order.orderedby = user.name
	order.console_location = src.console_location

	var/shown_confirmation_window = FALSE // Always show some form of confirmation window to prevent spam and accidental requests
	var/use_personal_funds = !!account
	if(account && account["current_money"] < supply_pack.cost)
		if(tgui_confirm(user,"Insufficient funds in account. Place request for [supply_pack.name] ([supply_pack.cost] credits) using supply budget instead?"))
			use_personal_funds = FALSE
			shown_confirmation_window = TRUE
		else
			boutput(user, SPAN_ALERT("Order cancelled."))
			qdel(order)
			return

	if(!shown_confirmation_window)
		var/text = "[use_personal_funds ? "Order" : "Request"] [supply_pack.name] for [supply_pack.cost] credits?"
		if(!tgui_confirm(user, text))
			boutput(user, SPAN_ALERT("Order cancelled."))
			qdel(order)
			return
	if(use_personal_funds) //buy it with their money
		if(account["current_money"] < supply_pack.cost)
			boutput(user, SPAN_ALERT("Insufficient funds in account."))
			qdel(order)
			return
		account["current_money"] -= supply_pack.cost
		if (account["pda_net_id"])
			order.address = account["pda_net_id"]
		order.used_personal_funds = TRUE
		var/obj/storage/crate = order.create(user)
		shippingmarket.receive_crate(crate)
		logTheThing(LOG_STATION, usr, "ordered a [supply_pack.name] at [log_loc(src)].")
		boutput(user, "Your order of [supply_pack.name] has been processed and will be delivered shortly.")
		shippingmarket.supply_history += "[order.object.name] ordered by [order.orderedby] for [supply_pack.cost] credits from personal account.<BR>"
		src.pda_alert("Notification: [order.object] ordered by [order.orderedby] using personal account at [order.console_location].", list(MGT_CARGO, MGA_SHIPPING))
		return

	var/list/pda_list = list()

	// check visible PDAs
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		pda_list += H.get_slot(SLOT_L_HAND)
		pda_list += H.get_slot(SLOT_R_HAND)
		pda_list += H.get_slot(SLOT_WEAR_ID)
		pda_list += H.get_slot(SLOT_BELT)

	for (var/obj/item/device/pda2/pda in pda_list)
		if (pda.host_program.message_on && pda.owner)
			order.address = pda.net_id
			break

	shippingmarket.supply_requests += order
	logTheThing(LOG_STATION, usr, "placed a request for a [supply_pack.name] at [log_loc(src)].")
	boutput(user, "Request for [supply_pack.name] sent to Supply Console. The Quartermasters will process your request as soon as possible.")
	src.pda_alert("Notification: [order.object] requested by [order.orderedby] at [order.console_location].", list(MGT_CARGO, MGA_CARGOREQUEST))
	src.update_static_data_for_all_viewers()

/obj/machinery/computer/ordercomp/proc/pda_alert(var/message, var/groups = list(MGT_CARGO))
	var/datum/signal/pdaSignal = get_free_signal()
	pdaSignal.data = list("address_1" = "00000000", \
						"command" = "text_message", \
						"sender_name" = "CARGO-MAILBOT",  \
						"group" = groups, \
						"sender" = "00000000", \
						"message"= message)
	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")


/obj/machinery/computer/ordercomp/attackby(var/obj/item/I, mob/user)
	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card))
		src.scan_id(id_card, user)
	else
		. = ..()

/obj/machinery/computer/ordercomp/proc/scan_id(var/obj/item/card/id/id_card, mob/user)
	if(!istype(id_card))
		return
	var/datum/db_record/account = FindBankAccountByName(id_card.registered)
	if(!account)
		boutput(user, SPAN_ALERT("No bank account associated with this ID found."))
		src.scan = null
		return
	if (user.enter_pin("Order Console") != id_card.pin)
		boutput(user, SPAN_ALERT("PIN incorrect."))
		src.scan = null
		return
	boutput(user, SPAN_NOTICE("Card authorized."))
	src.scan = id_card
