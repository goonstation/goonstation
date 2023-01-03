TYPEINFO(/obj/machinery/cashreg)
	mats = 6

/obj/machinery/cashreg
	name = "credit transfer device"
	desc = "Sends funds directly to a host ID."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "scanner"
	req_access = list(access_heads) // Allows heads of staff to deregister owners from a cashreg.
	anchored = TRUE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	flags = TGUI_INTERACTIVE

	var/datum/db_record/owner_account = null
	var/obj/item/card/id/owner_card = null

	/// Safety thing to prevent other tasks from occurring during a transaction.
	var/active_transaction = FALSE
	/// The number of transfers the machine has processed.
	var/transaction_count = 0
	/// The price set by the owner of the machine.
	var/amount = 0
	/// The proportion of the given price to be added on as a tip, from 0 to 1.
	var/tip = 0
	/// Maximum amount of credits a single transaction can move.
	var/transaction_limit = 999999

	New()
		..()
		UnsubscribeProcess()

	// please check fingerprints on attackby and attack_hand
	attackby(obj/item/O, mob/user)
		// If attempting to use an ID or PDA with an ID inserted, attempt to register device to that ID. Else, they're paying for something.
		var/held_ID = src.get_ID(O)
		if (src.get_ID(O))
			if (!src.owner_account)
				src.register_owner(user, held_ID)
			else
				src.pay(user, held_ID)
			src.attack_hand(user)
			return

		// (Un)anchoring the device with a tool.
		if (istool(O, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [anchored ? "unbolts the [src] from" : "secures the [src] to"] the floor.")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 80, 1)
			src.anchored = !src.anchored

	attack_hand(mob/user)
		..()
		ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Cashreg")
			ui.open()

	ui_data(mob/user)
		. = list(
			"active_transaction" = src.active_transaction,
			"amount" = src.amount,
			"name" = src.name,
			"owner" = src.owner_card?.registered,
			"tip" = src.tip,
			"total" = src.amount + round(src.amount * src.tip),
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("cancel_transaction")
				var/obj/O = usr.equipped()
				if (src.get_ID(O) == src.owner_card && !src.active_transaction)
					boutput(usr, "<span class='alert'>Transaction cancelled.</span>")
					usr.visible_message("<span class='alert'><B>[usr]</B> cancels the active transaction on [src].</span>")
					src.amount = 0
					src.tip = 0
					. = TRUE
				else
					boutput(usr, "<span class='alert'>Unable to cancel transaction.</span>")
					return
			if ("set_amount")
				var/obj/O = src.check_worn_ID(usr)
				if (src.get_ID(O) == src.owner_card && !src.active_transaction)
					var/amount_buffer = tgui_input_number(usr, "Enter amount.", src.name, 0, src.transaction_limit)
					if (amount_buffer !src.active_transaction)
						src.amount = amount_buffer
						. = TRUE
			if ("set_tip")
				if (!src.active_transaction)
					src.tip = clamp((tgui_input_number(usr, "What percentage would you like to pay as a tip?", "Tip", 10, 100, 0) / 100), 0, 1)
					. = TRUE
			if ("swipe_owner")
				var/obj/O = usr.equipped()
				if (src.get_ID(O) && !src.owner_account)
					src.register_owner(usr, O)
					. = TRUE
			if ("swipe_payer")
				var/obj/O = usr.equipped()
				if (src.get_ID(O))
					src.pay(usr, O)
					. = TRUE
			if ("reset")
				var/obj/O = src.check_worn_ID(usr)
				// (If the user's ID matches the registered card OR the user has head access) AND there is no active transaction
				if ((src.get_ID(O) == src.owner_card || src.allowed(usr)) && !src.active_transaction)
					if (tgui_alert(usr, "Reset the reader?", "Reset reader", list("Reset", "Cancel")) == "Reset" && !src.active_transaction)
						boutput(usr, "<span class='alert'>Reader reset.</span>")
						usr.visible_message("<span class='alert'><B>[usr]</B> resets [src].</span>")
						src.owner_account = null
						src.owner_card = null
						src.amount = 0
						src.tip = 0
						. = TRUE
				else
					boutput(usr, "<span class='alert'>You are not the owner or you don't have permission to reset the machine!</span>")
					return
		src.add_fingerprint(usr)

	proc/authenticate_card(mob/user, obj/item/card/id/O)
		var/enter_pin = user.enter_pin()
		if (enter_pin == O.pin)
			var/datum/db_record/card_account = data_core.bank.find_record("name", O.registered)
			if (card_account)
				user.visible_message("<span class='notice'>[user] swipes [src] with [O].</span>")
				return card_account
			else
				boutput(user, "<span class='alert'>Unable to find bank account!</span>")
				return null
		else
			boutput(user, "<span class='alert'>Invalid PIN!</span>")
			return null

	proc/cancel(mob/user)
		user.visible_message("<span class='alert'><b>[src] buzzes.</b> The transaction was cancelled!</span>")
		src.active_transaction = FALSE

	// This proc should really exist elsewhere.
	proc/get_ID(obj/item/O)
		if (istype(O, /obj/item/card/id))
			return O
		else if (istype(O, /obj/item/device/pda2))
			var/obj/item/device/pda2/pda = O
			return pda.ID_card

	// If an ID is being held, get what's equipped. Otherwise, if mob M is wearing something in their ID slot, get an ID from that.
	proc/check_worn_ID(mob/M)
		var/obj/item/O
		if (ishuman(M))
			var/mob/living/carbon/human/owner = M
			if (istype(M.equipped(), /obj/item/card/id) || istype(M.equipped(), /obj/item/device/pda2))
				O = M.equipped()
			else if (owner.wear_id)
				O = owner.wear_id
			return O

	proc/register_owner(mob/user, obj/item/card/id/O)
		src.owner_account = src.authenticate_card(user, O)
		if (src.owner_account)
			src.owner_card = O
			boutput(usr, "<span class='notice'>Successfully registered ownership of [src]!</span>")
		else
			boutput(usr, "<span class='alert'>Unable to successfully register ownership of [src]!</span>")

	proc/pay(mob/user, obj/item/card/id/O)
		var/payer_account = src.authenticate_card(user, O)
		src.active_transaction = TRUE

		// Checks to make sure that the scanned card is allowed to transfer money to the owner at all.
		if (!payer_account)
			boutput(user, "<span class='alert'>Unable to authenticate account!</span>")
			src.cancel(user)
			return
		if (O.registered in FrozenAccounts)
			boutput(user, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
			src.cancel(user)
			return
		if (payer_account == src.owner_account)
			boutput(user, "<span class='alert'>You can't send funds with the owner ID to the owner ID!</span>")
			src.cancel(user)
			return

		// Confirmation of transaction
		var/transaction_total = src.amount + round(src.amount * src.tip) // when we get to 515 please replace this with ceil()
		if (tgui_alert(usr, "Please confirm transfer of [transaction_total] to [src.owner_card?.registered].", "Confirm transfer", list("Confirm", "Cancel")) == "Confirm")
			if (src.amount > payer_account["current_money"])
				boutput(user, "<span class='alert'>Insufficent funds in account to complete transaction.</span>")
				src.cancel(user)
				return

			var/print_customer_copy = FALSE
			if (tgui_alert(usr, "Print customer receipt?", "Receipt", list("Print", "Cancel")) == "Print")
				print_customer_copy = TRUE

			var/transaction_price = src.amount
			var/transaction_tip = src.tip
			var/payee = src.owner_card.registered

			payer_account["current_money"] -= transaction_total
			src.owner_account["current_money"] += transaction_total
			src.transaction_count++
			src.amount = 0
			src.tip = 0
			src.active_transaction = FALSE

			tgui_process.update_uis(src)
			boutput(user, "<span class='notice'>Sending transaction.</span>")
			user.visible_message("<span class='notice'><b>[src] beeps affirmatively.</b> The transaction was successful!</span>")

			playsound(src, 'sound/machines/printer_cargo.ogg', 50, 1)
			SPAWN(3 SECONDS)
				if (print_customer_copy)
					src.print_receipt(payee, O.registered, transaction_price, transaction_tip, transaction_total, customer_copy = true)
				src.print_receipt(payee, O.registered, transaction_price, transaction_tip, transaction_total)

	// Generate and create a receipt. This doesn't include the delay or the sound.
	proc/print_receipt(payee, payer, price, tip, total, customer_copy = false)
		var/receipt_text = {"
			<span style="text-transform:uppercase;font-family:Monospace;">
				<table>
					<tbody>
					<tr>
						<td colspan="2" style="text-align:center">
							[customer_copy ? "*--------CUSTOMER COPY--------*" : "*--------MERCHANT COPY--------*"]
						</td>
					</tr>
					<tr>
						<td colspan="2" style="text-align:center">*-----TRANSACTION RECEIPT-----*</td>
					</tr>
					<tr>
						<td colspan="2">[src.name]</td>
					</tr>
					<tr>
						<td>NUMBER</td>
						<td style="text-align:right">[src.transaction_count]</td>
					</tr>
					<tr>
						<td>TIME</td>
						<td style="text-align:right">[time2text(world.timeofday, "DD MMM hh:mm")]</td>
					</tr>
					<tr>
						<td>TO</td>
						<td style="text-align:right">[payee]</td>
					</tr>
					<tr>
						<td>FROM</td>
						<td style="text-align:right">[payer]</td>
					</tr>
					<tr>
						<td colspan="2" style="text-align:center">*-----------------------------*</td>
					</tr>
					<tr>
						<td>PURCHASE</td>
						<td style="text-align:right">[price][CREDIT_SIGN]</td>
					</tr>
					[tip ? "<tr><td>TIP</td><td style='text-align:right'>[tip * 100]%</td></tr>" : ""]
					<tr>
						<td>TOTAL</td>
						<td style="text-align:right">[total][CREDIT_SIGN]</td>
					</tr>
					</tbody>
				</table>
			</span>
		"}

		var/obj/item/paper/receipt = new /obj/item/paper{rand_pos = TRUE}
		receipt.set_loc(get_turf(src))
		receipt.name = "RECEIPT - [customer_copy ? "CUSTOMER" : "MERCHANT"] COPY"
		receipt.info = receipt_text
		receipt.icon_state = "thermal_paper"
