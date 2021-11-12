obj/machinery/air_vendor
	name = "Oxygen Vending Machine"
	desc = "Here, you can buy the oxygen that you need to live."
	icon = 'icons/obj/O2vend.dmi'
	icon_state = "O2vend"

	anchored = 1
	density = 1

	deconstruct_flags = DECON_CROWBAR | DECON_WRENCH | DECON_MULTITOOL

	// Credits inserted
	var/credits = 0

	// Currently installed tank
	var/obj/item/tank/holding = null

	// Scanned account
	var/obj/item/card/id/scan = null

	// Slot overlay image
	var/global/image/holding_overlay_image = image('icons/obj/O2vend.dmi', "O2vend_slot")

	// Gas mix to be copied into the target tank
	var/datum/gas_mixture/gas_prototype = null

	var/target_pressure = ONE_ATMOSPHERE
	var/air_cost = 0.1 // units: credits / ( kPa * L )

	New()
		..()
		gas_prototype = new /datum/gas_mixture

	proc/update_icon()
		if(status & BROKEN)
			icon_state = "O2vend_broken"
			return
		if(status & NOPOWER)
			icon_state = "O2vend_off"
		else
			icon_state = "O2vend"
		if(holding)
			UpdateOverlays(holding_overlay_image, "o2_vend_tank_overlay")
		else
			UpdateOverlays(null, "o2_vend_tank_overlay")

	power_change()
		..()
		update_icon()

	proc/fill_cost()
		if(!holding) return 0
		return clamp(round((src.target_pressure - MIXTURE_PRESSURE(src.holding.air_contents)) * src.holding.air_contents.volume * src.air_cost), 0, INFINITY)

	proc/fill()
		if(!holding) return
		gas_prototype.volume = holding.air_contents.volume
		gas_prototype.temperature = T20C

		gas_prototype.oxygen = (target_pressure)*gas_prototype.volume/(R_IDEAL_GAS_EQUATION*gas_prototype.temperature)

		holding.air_contents.copy_from(gas_prototype)

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if (istype(W, /obj/item/spacecash))
			src.credits += W.amount
			W.amount = 0
			boutput(user, "<span class='notice'>You insert [W].</span>")
			user.u_equip(W)
			W.dropped()
			qdel(W)
			src.updateUsrDialog()
		else if (istype(W, /obj/item/tank))
			if(!src.holding)
				boutput(user, "You insert the [W.name] into the the [src.name].</span>")
				user.drop_item()
				W.set_loc(src)
				src.holding = W
				src.update_icon()
				src.updateUsrDialog()
			else
				boutput(user, "You try to insert the [W.name] into the the [src.name], but there's already a tank there!</span>")
		else if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if (istype(W, /obj/item/card/id))
			src.scan_card(W, user)

	// Shamelessly stolen from vending.dm
	proc/scan_card(var/obj/item/card/id/card as obj, var/mob/user as mob)
		if (!card || !user)
			return
		boutput(user, "<span class='notice'>You swipe [card].</span>")
		var/datum/db_record/account = null
		account = FindBankAccountByName(card.registered)
		if (account)
			var/enterpin = input(user, "Please enter your PIN number.", "Enter PIN", 0) as null|num
			if (enterpin == card.pin)
				boutput(user, "<span class='notice'>Card authorized.</span>")
				src.scan = card
			else
				boutput(user, "<span class='alert'>Pin number incorrect.</span>")
				src.scan = null
		else
			boutput(user, "<span class='alert'>No bank account associated with this ID found.</span>")
			src.scan = null
		src.updateUsrDialog()

	attack_hand(var/mob/user as mob)
		src.add_dialog(user)
		var/html = ""
		html += "<TT><b>Welcome!</b><br>"
		html += "<b>Current balance: <a href='byond://?src=\ref[src];return_credits=1'>[src.credits] credits</a></b><br>"
		if (src.scan)
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			html += "<b>Current ID:</b> <a href='?src=\ref[src];clearcard=1'>[src.scan]</a><br />"
			html += "<b>Credits on Account: [account["current_money"]] Credits</b> <br>"
		else
			html += "<b>Current ID:</b> None<br>"
		if(src.holding)
			html += "<font color = 'blue'>Current tank:</font> <a href='?src=\ref[src];eject=1'>[holding]</a><br />"
			html += "<font color = 'red'>Pressure:</font> [MIXTURE_PRESSURE(holding.air_contents)] kPa<br />"
		else
			html += "<font color = 'blue'>Current tank:</font> none<br />"

		html += "<font color = 'green'>Desired pressure:</font> <a href='?src=\ref[src];changepressure=1'>[src.target_pressure] kPa</a><br/>"
		html += (holding) ? "<a href='?src=\ref[src];fill=1'>Fill ([src.fill_cost()] credits)</a>" : "<font color = 'red'>Fill (unavailable)</red>"

		user.Browse(html, "window=o2_vending")
		onclose(user, "vending")

	Topic(href, href_list)
		if (status & (BROKEN|NOPOWER))
			return
		if (usr.stat || usr.restrained())
			return
		if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))))
			src.add_dialog(usr)
			src.add_fingerprint(usr)

			if(href_list["eject"])
				if(holding)
					holding.set_loc(loc)
					holding = null

			if(href_list["clearcard"])
				if(scan)
					scan = null

			if(href_list["changepressure"])
				var/change = input(usr,"Target Pressure (10.1325-1013.25):","Enter target pressure",target_pressure) as num
				if(isnum(change))
					target_pressure = min(max(10.1325, change),1013.25)

			if(href_list["fill"])
				if (holding)
					var/cost = fill_cost()
					if(credits >= cost)
						src.credits -= cost
						src.fill()
						boutput(usr, "<span class='notice'>You fill up the [src.holding].</span>")
						src.updateUsrDialog()
						return
					else if(scan)
						var/datum/db_record/account = FindBankAccountByName(src.scan.registered)
						if (account && account["current_money"] >= cost)
							account["current_money"] -= cost
							src.fill()
							boutput(usr, "<span class='notice'>You fill up the [src.holding].</span>")
							src.updateUsrDialog()
							return
					boutput(usr, "<span class='alert'>Insufficient funds.</span>")
				else
					boutput(usr, "<span class='alert'>There is no tank to fill up!</span>")

			if (href_list["return_credits"])
				if (src.credits > 0)
					var/obj/item/spacecash/returned = new /obj/item/spacecash
					returned.setup(src.loc, src.credits)

					usr.put_in_hand_or_eject(returned)
					src.credits = 0
					boutput(usr, "<span class='notice'>You receive [returned].</span>")

			src.updateUsrDialog()
			src.add_fingerprint(usr)
			update_icon()
