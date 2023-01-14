TYPEINFO(/obj/submachine/slot_machine)
	mats = 8

/obj/submachine/slot_machine
	name = "Slot Machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "slots-off"
	anchored = 1
	density = 1
	flags = TGUI_INTERACTIVE
	deconstruct_flags = DECON_SIMPLE
	var/plays = 0
	var/working = 0
	var/obj/item/card/id/scan = null
	var/icon_base = "slots"
	var/datum/db_record/accessed_record = null
	var/available_funds = 0
	var/emagged = 0
	///break-even point for slots when this is set to 2500. make lower to make slots pay out better, or higher to give the house an edge
	var/max_roll = 2250
	var/wager = 20

	New()
		AddComponent(/datum/component/mechanics_holder)
		..()

/obj/submachine/slot_machine/emag_act(mob/user, obj/item/card/emag/E)
	if (src.emagged)
		user?.show_message("<span class='alert'>The [src] has already had been tampered with.</span>")
		return
	boutput(user, "<span class='notice'>You short out the random number generator on [src]")
	src.emagged = 1
	return TRUE

/* INTERFACE */

/obj/submachine/slot_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SlotMachine", name)
		ui.open()

/obj/submachine/slot_machine/ui_data(mob/user)
	. = list(
		"busy" = working,
		"scannedCard" = src.scan,
		"money" = available_funds,
		"account_funds" = src.accessed_record?["current_money"],
		"plays" = plays,
		"wager" = wager,
	)

/obj/submachine/slot_machine/ui_state(mob/user)
	return tgui_physical_state

/obj/submachine/slot_machine/ui_status(mob/user)
  return min(
		tgui_physical_state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)

/obj/submachine/slot_machine/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if ("insert_card")
			if (src.scan)
				return TRUE
			var/obj/O = usr.equipped()
			if (istype(O, /obj/item/card/id))
				. = src.Attackby(O, usr)
		if ("play")
			if (src.working || !src.accessed_record)
				return TRUE
			if (src.available_funds < wager)
				src.visible_message("<span class='subtle'><b>[src]</b> says, 'Insufficient money to play!'</span>")
				return TRUE
			src.available_funds -= wager
			src.plays++
			src.working = 1
			src.icon_state = "[icon_base]-on"

			playsound(src, 'sound/machines/ding.ogg', 50, 1)
			. = TRUE
			ui_interact(usr, ui)
			SPAWN(2.5 SECONDS) // why was this at ten seconds, christ
				money_roll(wager)
				src.working = 0
				src.icon_state = "[icon_base]-off"

		if("eject")
			usr.put_in_hand_or_eject(src.scan)
			src.scan = null
			src.working = FALSE
			src.icon_state = "[icon_base]-off" // just in case, some fucker broke it earlier
			if(!src.accessed_record)
				src.visible_message("<span class='subtle'><b>[src]</b> says, 'Winnings not transferred, thank you for playing!'</span>")
				return TRUE // jerks doing that "hide in a chute to glitch auto-update windows out" exploit caused a wall of runtime errors
			src.accessed_record["current_money"] += src.available_funds
			src.available_funds = 0
			src.accessed_record = null
			src.visible_message("<span class='subtle'><b>[src]</b> says, 'Winnings transferred, thank you for playing!'</span>")
			. = TRUE

		if("cashin")
			if(!src.accessed_record)
				boutput(usr, "<span class='alert'>No account connected.</span>")
				return TRUE
			var/transfer_amount = input(usr, "Enter how much to transfer from your account.", "Deposit Credits", 0) as null|num
			transfer_amount = clamp(transfer_amount,0,src.accessed_record["current_money"])
			src.accessed_record["current_money"] -= transfer_amount
			src.available_funds += transfer_amount
			boutput(usr, "<span class='notice'>Funds transferred.</span>")

		if("cashout")
			src.accessed_record["current_money"] += src.available_funds
			src.available_funds = 0
			boutput(usr, "<span class='notice'>Funds transferred.</span>")

		if("set_wager")
			src.wager = clamp(round(params["bet"]), 20, 1000)
			. = TRUE


	src.add_fingerprint(usr)
	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "machineUsed")

/obj/submachine/slot_machine/attackby(var/obj/item/I, mob/user)
	if(istype(I, /obj/item/card/id))
		if(src.scan)
			boutput(user, "<span class='alert'>There is a card already in the slot machine.</span>")
		else
			var/obj/item/card/id/idcard = I
			boutput(user, "<span class='notice'>You insert your ID card.</span>")
			user.drop_item()
			I.set_loc(src)
			if(!idcard.registered)
				boutput(user, "<span class='alert'>No account data found!</span>")
				user.put_in_hand_or_eject(I)
				ui_interact(user)
				return TRUE
			var/enterpin = user.enter_pin("Enter PIN")
			if (enterpin != idcard.pin)
				boutput(user, "<span class='alert'>Pin number incorrect.</span>")
				user.put_in_hand_or_eject(I)
				ui_interact(user)
				return TRUE
			src.accessed_record = FindBankAccountByName(idcard.registered)
			if(isnull(src.accessed_record))
				boutput(user, "<span class='alert'>That card has no bank account associated.</span>")
				user.put_in_hand_or_eject(I)
				ui_interact(user)
				return TRUE
			boutput(user, "<span class='notice'>Card authorized.</span>")
			src.scan = I
			ui_interact(user)
			. = TRUE
	else
		. = ..()

/obj/submachine/slot_machine/proc/money_roll(wager)
	var/roll = rand(1, max_roll)
	var/exclamation = ""
	var/win_sound = 'sound/machines/ping.ogg'
	var/amount = 0

	//300x and 100x jackpots fall through to 50x winner if wager <= 250
	if(wager < 250)
		roll = max(6, roll)
	if(src.emagged)
		roll = min(roll * 2, max_roll)

	if (roll == 1) //1 - 300
		win_sound = 'sound/misc/airraid_loop_short.ogg'
		exclamation = "JACKPOT! "
		amount = 300 * wager
		command_alert("Congratulations to [src.scan.registered] on winning a Jackpot of [amount] credits!", "Jackpot Winner", alert_origin = ALERT_STATION)
	else if (roll <= 5) //4 - 400
		win_sound =  'sound/misc/klaxon.ogg'
		exclamation = "Big Winner! "
		amount = 100 * wager
		command_alert("Congratulations to [src.scan.registered] on winning [amount] credits!", "Big Winner", alert_origin = ALERT_STATION)
	else if (roll <= 15) //10 - 500    (Plus additional 5 - 250 if wager <= 250)
		win_sound =  'sound/musical_instruments/Bell_Huge_1.ogg'
		exclamation = "Big Winner! "
		amount = 50 * wager
	else if (roll <= 65) //50 - 500
		exclamation = "Winner! "
		amount = 10 * wager
	else if (roll <= 165) //100 - 500
		exclamation = "Winner! "
		amount = 5 * wager
	else if (roll <= 265) //100 - 300
		exclamation = "Winner! "
		amount = 3 * wager
	else if (roll <= 715 && wager < 250) //450 - 450, if wager <= 250, to make up for not having jackpots
		exclamation = "Small Winner! "
		amount = 1 * wager
	else
		src.visible_message("<span class='subtle'><b>[src]</b> says, 'No luck!'</span>")

	if (amount > 0)
		src.visible_message("<span class='subtle'><b>[src]</b> says, '[exclamation][src.scan.registered] has won [amount] credits!'</span>")
		playsound(src, "[win_sound]", 55, 1)
		src.available_funds += amount

/obj/submachine/slot_machine/cursed
	name = "Slot Machine"
	desc = "Gambling for the damned."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "slots-off"

	attack_hand(var/mob/user)
		src.add_dialog(user)
		if (src.working)
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			<B>Please wait!</B><BR>"}
			user.Browse(dat, "window=slotmachine;size=450x500")
			onclose(user, "slotmachine")
		else
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			Free to play - IF YOU DARE!<BR>
			[src.plays] attempts have been made today!<BR>
			<HR><BR>
			<A href='?src=\ref[src];ops=1'>Play!</A><BR>"}
			user.Browse(dat, "window=slotmachine;size=400x500")
			onclose(user, "slotmachine")

	Topic(href, href_list)
		if (BOUNDS_DIST(src, usr) > 0 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return

		if(href_list["ops"])
			var/operation = text2num_safe(href_list["ops"])
			if(operation == 1) // Play
				if(src.working) return
				/*if (src.money < 0)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> says, 'No prize money left!'", src), 1)
					return*/
				//src.money += 10
				src.plays += 1
				src.working = 1
				src.icon_state = "slots-on"
				//for(var/mob/O in hearers(src, null))
					//O.show_message(text("<b>[]</b> says, 'Let's roll!'", src), 1)
				var/roll = rand(1,101)

				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				SPAWN(2.5 SECONDS)
					if (roll == 1)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'JACKPOT! [usr.name] has won their freedom!'</span>", src), 1)
						playsound(src.loc, 'sound/voice/heavenly.ogg', 55, 1)
						usr.un_damn()
					else if(roll > 1 && roll <= 10 && istype(usr,/mob/living/carbon/human))
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, '[usr.name] has a limb ripped off by the machine!'</span>", src), 1)
						playsound(src.loc, 'sound/machines/ping.ogg', 55, 1)
						var/mob/living/carbon/human/H = usr
						if(H.limbs.l_arm)
							H.limbs.l_arm.sever()
							H.unlock_medal("One Armed Bandit", 1) // only need to unlock here since it always checks for left arm first and generally there's no other way to lose limbs in hell
						else if(H.limbs.l_leg)
							H.limbs.l_leg.sever()
						else if(H.limbs.r_leg)
							H.limbs.r_leg.sever()
						else if(H.limbs.r_arm)
							H.limbs.r_arm.sever()
					else
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'No luck!'</span>", src), 1)
					src.working = 0
					src.icon_state = "slots-off"
					updateUsrDialog()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"machineUsed")
		return

/obj/submachine/slot_machine/cash
	name = "Slot Machine"
	desc = "Gambling for the dead"
	icon = 'icons/obj/gambling.dmi'
	icon_state = "slots-off"
	var/play_money = 0

	attackby(var/obj/item/I, user)
		if(istype(I, /obj/item/spacecash/))
			boutput(user, "<span class='notice'>You insert the cash into [src].</span>")

			if(istype(I, /obj/item/spacecash/buttcoin))
				boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
			else
				src.play_money += I.amount

			I.amount = 0
			qdel(I)

	attack_hand(var/mob/user)
		src.add_dialog(user)
		if (src.working)
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			<B>Please wait!</B><BR>"}
			user.Browse(dat, "window=slotmachine;size=450x500")
			onclose(user, "slotmachine")
		else
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			Twenty credits to play!<BR>
			<B>Credits Remaining:</B> [src.play_money]<BR>
			[src.plays] attempts have been made today!<BR>
			<HR><BR>
			<A href='?src=\ref[src];ops=1'>Play!</A><BR>
			<A href='?src=\ref[src];ops=2'>Eject cash</A>"}
			user.Browse(dat, "window=slotmachine;size=400x500")
			onclose(user, "slotmachine")

	Topic(href, href_list)
		if (BOUNDS_DIST(src, usr) > 0 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return

		if(href_list["ops"])
			var/operation = text2num_safe(href_list["ops"])
			if(operation == 1) // Play
				if(src.working) return
				if (src.play_money < 20)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<span class='subtle'><b>[]</b> says, 'Insufficient money to play!'</span>", src), 1)
					return
				/*if (src.money < 0)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> says, 'No prize money left!'", src), 1)
					return*/
				src.play_money -= 20
				//src.money += 10
				src.plays += 1
				src.working = 1
				src.icon_state = "slots-on"
				//for(var/mob/O in hearers(src, null))
					//O.show_message(text("<b>[]</b> says, 'Let's roll!'", src), 1)
				var/roll = rand(1,1350)

				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				SPAWN(2.5 SECONDS) // why was this at ten seconds, christ
					if (roll == 1)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'JACKPOT! You have won a MILLION CREDITS!'</span>", src), 1)
						playsound(src.loc, 'sound/misc/airraid_loop_short.ogg', 55, 1)
						src.play_money += 1000000
						//src.money = 0
					else if (roll > 1 && roll <= 5)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'Big Winner! You have won a hundred thousand credits!'</span>", src), 1)
						playsound(src.loc, 'sound/misc/klaxon.ogg', 55, 1)
						src.play_money += 100000
						//src.money -= 100000
					else if (roll > 5 && roll <= 25)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'Big Winner! You have won ten thousand credits!'</span>", src), 1)
						playsound(src.loc, 'sound/misc/klaxon.ogg', 55, 1)
						src.play_money += 10000
						//src.money -= 10000
					else if (roll > 25 && roll <= 50)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'Winner! You have won a thousand credits!'</span>", src), 1)
						playsound(src.loc, 'sound/musical_instruments/Bell_Huge_1.ogg', 55, 1)
						src.play_money += 1000
						//src.money -= 1000
					else if (roll > 50 && roll <= 100)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'Winner! You have won a hundred credits!'</span>", src), 1)
						playsound(src.loc, 'sound/musical_instruments/Bell_Huge_1.ogg', 55, 1)
						src.play_money += 100
						//src.money -= 100
					else if (roll > 100 && roll <= 200)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'Winner! You have won fifty credits!'</span>", src), 1)
						playsound(src.loc, 'sound/machines/ping.ogg', 55, 1)
						src.play_money += 50
						//src.money -= 50
					else if (roll > 200 && roll <= 500)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'You have won ten credits!'</span>", src), 1)
						playsound(src.loc, 'sound/machines/ping.ogg', 55, 1)
						src.play_money += 10
						//src.money -= 10
					else
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span class='subtle'><b>[]</b> says, 'No luck!'</span>", src), 1)
							//playsound(src.loc, 'sound/machines/buzz-two.ogg', 55, 1) // way too loud UGH
					src.working = 0
					src.icon_state = "slots-off"
					updateUsrDialog()
			if(operation == 2) // Eject Card
				new /obj/item/spacecash(src.loc, src.play_money)
				src.play_money = 0
				src.working = 0
				src.icon_state = "slots-off" // just in case, some fucker broke it earlier
				for(var/mob/O in hearers(src, null))
					O.show_message(text("<span class='subtle'><b>[]</b> says, 'Thank you for playing!'</span>", src), 1)
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"machineUsed")
		return
