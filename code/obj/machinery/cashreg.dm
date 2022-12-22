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
	var/price = 0

	New()
		..()
		UnsubscribeProcess()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [anchored ? "unbolts the [src] from" : "secures the [src] to"] the floor.")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 80, 1)
			src.anchored = !src.anchored
		if (istype(W, /obj/item/card/id))
			var/obj/item/card/id/card = W
			if (!owner_account)
				for (var/datum/db_record/account as anything in data_core.bank.records)
					if (ckey(account["name"]) == ckey(card.registered))
						owner_account = account
						break

				if (!istype(owner_account))
					owner_account = null
					boutput(user, "<span class='alert'>Unable to find bank account!</span>")
					return

				user.visible_message("<span class='notice'>[user] swipes [src] with [W].</span>")
				return

			if (card.registered in FrozenAccounts)
				boutput(user, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
				return
			var/datum/db_record/target_account = null
			for (var/datum/db_record/account as anything in data_core.bank.records)
				if (ckey(account["name"]) == ckey(card.registered))
					target_account = account
					break
			if (!istype(target_account))
				boutput(user, "<span class='alert'>Unable to find user bank account!</span>")
				return

			if (target_account == owner_account)
				boutput(user, "<span class='alert'>You can't send funds with the host ID to the host ID!</span>")
				return

			boutput(user, "<span class='notice'>The current host ID is [owner_account["name"]]. Insert a value less than zero to cancel transaction.</span>")
			var/amount = input(user, "How much money would you like to send?", "Deposit", 0) as null|num
			if (amount <= 0 || !isnum_safe(amount))
				return
			if (amount > target_account["current_money"])
				boutput(user, "<span class='alert'>Insufficent funds. [W] only has [target_account["current_money"]] credits.</span>")
				return
			boutput(user, "<span class='notice'>Sending transaction.</span>")
			user.visible_message("<span class='notice'>[user] swipes [src] with [W].</span>")
			target_account["current_money"] -= amount
			owner_account["current_money"] += amount
			user.visible_message("<b>[src]</b> beeps, \"[owner_account["name"]] now holds [owner_account["current_money"]] credits. Thank you for your service!\"")

	attack_hand(mob/user)
		ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Cashreg")
			ui.open()

	ui_data(mob/user)
		. = list(
			"owner" = src.owner_account,
			"price" = src.price,
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("swipe_owner")
				if (!src.owner_account)

				else
					boutput(usr, "<span class='alert'>An owner is already registered with [src]!</span>")
			if ("swipe_payee")
			if ("pay")
				src.pay()
				. = TRUE
			if ("reset")
				if (!src.owner_account)
					boutput(usr, "<span class='alert'>You press the reset button, but nothing happens.</span>")
					return
				if (tgui_alert(usr, "Reset the reader?", "Reset reader", list("Yes", "No")) == "Yes")
					boutput(usr, "<span class='alert'>Reader reset.</span>")
					usr.visible_message("<span class='alert'><B>[usr]</B> resets [src].</span>")
					src.owner_account = null
					. = TRUE
		src.add_fingerprint(usr)

	proc/pay()
		