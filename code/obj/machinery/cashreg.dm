/obj/machinery/cashreg
	name = "credit transfer device"
	desc = "Sends funds directly to a host ID."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "scanner"
	anchored = 1
	mats = 6
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	var/datum/data/record/mainaccount = null


	New()
		..()
		UnsubscribeProcess()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if (iswrenchingtool(W))
			user.visible_message("<span style='color:red'>[user] smacks [src] with the wrench!</span>")
			if(prob(33))
				new/obj/item/scrap(get_turf(src))
				src.visible_message("<span style='color:red'>[src] breaks!</span>")
				qdel(src)//honk
		if (istype(W, /obj/item/card/id))
			var/obj/item/card/id/card = W
			if (!mainaccount)
				for (var/datum/data/record/account in data_core.bank)
					if (ckey(account.fields["name"]) == ckey(card.registered))
						mainaccount = account
						break

				if (!istype(mainaccount))
					mainaccount = null
					boutput(user, "<span style=\"color:red\">Unable to find bank account!</span>")
					return

				user.visible_message("<span style=\"color:blue\">[user] swipes [src] with [W].</span>")
				return

			if (card.registered in FrozenAccounts)
				boutput(user, "<span style=\"color:red\">Your account cannot currently be liquidated due to active borrows.</span>")
				return
			var/datum/data/record/target_account = null
			for (var/datum/data/record/account in data_core.bank)
				if (ckey(account.fields["name"]) == ckey(card.registered))
					target_account = account
					break
			if (!istype(target_account))
				boutput(user, "<span style=\"color:red\">Unable to find user bank account!</span>")
				return

			if (target_account == mainaccount)
				boutput(user, "<span style=\"color:red\">You can't send funds with the host ID to the host ID!</span>")
				return

			boutput(user, "<span style=\"color:blue\">The current host ID is [mainaccount.fields["name"]]. Insert a value less than zero to cancel transaction.</span>")
			var/amount = input(usr, "How much money would you like to send?", "Deposit", 0) as null|num
			if (amount <= 0)
				return
			if (amount > target_account.fields["current_money"])
				boutput(user, "<span style=\"color:red\">Insufficent funds. [W] only has [target_account.fields["current_money"]] credits.</span>")
				return
			boutput(user, "<span style=\"color:blue\">Sending transaction.</span>")
			user.visible_message("<span style=\"color:blue\">[user] swipes [src] with [W].</span>")
			target_account.fields["current_money"] -= amount
			mainaccount.fields["current_money"] += amount
			user.visible_message("<b>[src]</b> beeps, \"[mainaccount.fields["name"]] now holds [mainaccount.fields["current_money"]] credits. Thank you for your service!\"")

	attack_hand(mob/user as mob)
		if (!mainaccount)
			boutput(user, "<span style=\"color:red\">You press the reset button, but nothing happens.</span>")
			return
		switch(alert("Reset the reader?",,"Yes","No"))
			if ("Yes")
				boutput(user, "<span style=\"color:red\">Reader reset.</span>")
				user.visible_message("<span style=\"color:red\"><B>[user]</B> resets [src].</span>")
				mainaccount = null
			if ("No")
				return
