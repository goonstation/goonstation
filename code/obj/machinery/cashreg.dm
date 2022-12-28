TYPEINFO(/obj/machinery/cashreg)
	mats = 6

/obj/machinery/cashreg
	name = "credit transfer device"
	desc = "Sends funds directly to a host ID."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "scanner"
	anchored = TRUE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	flags = TGUI_INTERACTIVE

	var/datum/db_record/owner_account = null
	var/obj/item/card/id/owner_card = null
	var/amount = 0
	var/transaction_limit = 999999 // Maximum amount of credits a single transaction can move.

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
		ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Cashreg")
			ui.open()

	ui_data(mob/user)
		. = list(
			"owner" = src.owner_card?.registered,
			"amount" = src.amount,
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("set_amount")
				var/obj/O
				if (ishuman(usr))
					var/mob/living/carbon/human/owner = usr
					if (owner.wear_id)
						O = owner.wear_id
					else
						O = usr.equipped()
				else
					return

				if (src.get_ID(O))
					var/amount_buffer = tgui_input_number(usr, "Enter amount.", src.name, 0, src.transaction_limit)
					if (amount_buffer)
						src.amount = amount_buffer
						. = TRUE
			if ("swipe_owner")
				var/obj/O = usr.equipped()
				if (src.get_ID(O) && !src.owner_account)
					src.register_owner(usr, O)
					. = TRUE
			if ("swipe_payee")
				var/obj/O = usr.equipped()
				if (src.get_ID(O))
					src.pay(usr, O)
					. = TRUE
			if ("reset")
				// todo: allow certain accesses to reset readers
				var/obj/O = usr.equipped()
				if (src.get_ID(O) && src.get_ID(O) == src.owner_card)
					if (!src.owner_account)
						boutput(usr, "<span class='alert'>You press the reset button, but nothing happens.</span>")
						return
					if (tgui_alert(usr, "Reset the reader?", "Reset reader", list("Reset", "Cancel")) == "Reset")
						boutput(usr, "<span class='alert'>Reader reset.</span>")
						usr.visible_message("<span class='alert'><B>[usr]</B> resets [src].</span>")
						src.owner_account = null
						src.amount = 0
						. = TRUE
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

	proc/cancel_message(mob/user)
		user.visible_message("<span class='alert'><b>[src] buzzes.</b> The transaction was cancelled!</span>")

	proc/get_ID(obj/item/O)
		if (istype(O, /obj/item/card/id))
			return O
		else if (istype(O, /obj/item/device/pda2))
			var/obj/item/device/pda2/pda = O
			return pda.ID_card

	proc/register_owner(mob/user, obj/item/card/id/O)
		src.owner_account = src.authenticate_card(user, O)
		if (src.owner_account)
			src.owner_card = O
			boutput(usr, "<span class='notice'>Successfully registered ownership of [src]!</span>")
		else
			boutput(usr, "<span class='alert'>Unable to successfully register ownership of [src]!</span>")

	proc/pay(mob/user, obj/item/card/id/O)
		var/payee_account = src.authenticate_card(user, O)

		if (!payee_account)
			boutput(user, "<span class='alert'>Unable to authenticate account!</span>")
			src.cancel_message(user)
			return

		if (O.registered in FrozenAccounts)
			boutput(user, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
			src.cancel_message(user)
			return

		if (payee_account == src.owner_account)
			boutput(user, "<span class='alert'>You can't send funds with the owner ID to the owner ID!</span>")
			src.cancel_message(user)
			return

		if (tgui_alert(usr, "Please confirm transfer of [src.amount] to [src.owner_card?.registered].", "Confirm transfer", list("Confirm", "Cancel")) == "Confirm")
			if (!src.amount)
				boutput(user, "<span class='alert'>Invalid transaction!</span>")
				src.cancel_message(user)
				return

			if (src.amount > payee_account["current_money"])
				boutput(user, "<span class='alert'>Insufficent funds in account to complete transaction.</span>")
				src.cancel_message(user)
				return

			payee_account["current_money"] -= src.amount
			src.owner_account["current_money"] += src.amount
			boutput(user, "<span class='notice'>Sending transaction.</span>")
			user.visible_message("<span class='notice'><b>[src] beeps affirmatively.</b> The transaction was successful!</span>")

			if (tgui_alert(usr, "Print customer receipt?", "Receipt", list("Print", "Cancel")) == "Print")
				src.receipt(O.registered, src.amount, customer_copy = true)
			else
				src.receipt(O.registered, src.amount)

		src.amount = 0
		tgui_process.update_uis(src)

	proc/receipt(payee, total, customer_copy = false)
		// spam protection pls
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
						<td>TIME</td>
						<td style="text-align:right">[time2text(world.timeofday, "DD MMM hh:mm")]</td>
					</tr>
					<tr>
						<td>TO</td>
						<td style="text-align:right">[src.owner_card?.registered]</td>
					</tr>
					<tr>
						<td>FROM</td>
						<td style="text-align:right">[payee]</td>
					</tr>
					<tr>
						<td colspan="2" style="text-align:center">*-----------------------------*</td>
					</tr>
					<tr>
						<td>TOTAL</td>
						<td style="text-align:right">[total][CREDIT_SIGN]</td>
					</tr>
					</tbody>
				</table>
			</span>
		"}

		playsound(src, 'sound/machines/printer_cargo.ogg', 50, 1)
		SPAWN(3 SECONDS)
			var/obj/item/paper/receipt = new /obj/item/paper{rand_pos = TRUE}
			receipt.set_loc(get_turf(src))
			receipt.name = "RECEIPT - [customer_copy ? "CUSTOMER" : "MERCHANT"] COPY"
			receipt.info = receipt_text
			receipt.icon_state = "thermal_paper"
