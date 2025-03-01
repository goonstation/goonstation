// THIS IS STATIC, I.E. NOTHING WILL BE ABLE TO REMOVE THIS SYSTEM FROM
// THE GAME, IT CAN ONLY BE MODIFIED

// THE REASON I SAY THIS IS BECAUSE WE CAN ADD A DATACORE OR SOMETHING THAT CAN BE BLOWN UP
// AND ALL THE MONEY WILL BE GONE

#define STATE_LOGGEDOFF 1
#define STATE_LOGGEDIN 2

/datum/wage_system

	// Stations budget
	var/station_budget = 0
	var/shipping_budget = 0
	var/research_budget = 0
	var/payroll_stipend = 0
	var/total_stipend = 0

	var/pay_active = 1
	var/lottery_active = 0		// inactive until someone actually buys a ticket
	var/time_between_paydays = 0
	var/time_until_payday = 0

	var/time_between_lotto = 0
	var/time_until_lotto = 0

	/// The last time a bonus was issued
	var/last_issued_bonus_time = 0

	// We'll start at 0 credits, and increase it in the lotteryday proc
	var/lotteryJackpot = 0
	// 500 minutes ~ 8.2 hours
	var/list/winningNumbers = new/list(4, 100)
	var/lotteryRound = 1

	var/clones_for_cash = 0
	var/clone_cost = 2500 // I wanted to make this a var on SOMETHING so that it can be changed during rounds

	New()
		..()
		time_between_paydays = 5 MINUTES
		time_between_lotto = 8 MINUTES

		station_budget = PAY_IMPORTANT
		shipping_budget = PAY_EXECUTIVE*5
		research_budget = PAY_EXECUTIVE*10
		total_stipend = station_budget + shipping_budget + research_budget

		// This is gonna throw up some crazy errors if it isn't done right!
		// cogwerks - raising all of the paychecks, oh god

		src.time_until_lotto = ( ticker ? ticker.round_elapsed_ticks : 0 ) + time_between_lotto
		src.time_until_payday = ( ticker ? ticker.round_elapsed_ticks : 0 ) + time_between_paydays


	proc/process()
		if(!ticker)
			return
		var/timeleft = src.time_until_payday - ticker.round_elapsed_ticks

		if(timeleft <= 0)
			payday()
			src.time_until_payday = ticker.round_elapsed_ticks + time_between_paydays
		if(lottery_active && src.time_until_lotto <= ticker.round_elapsed_ticks)
			lotteryDay()
			src.time_until_lotto = ticker.round_elapsed_ticks + time_between_lotto

	proc/checkLotteryTime()
		if(!lottery_active)	return

		var/timeleft = src.time_until_lotto - ticker.round_elapsed_ticks

		if(timeleft <= 0)
			lotteryDay()
			src.time_until_lotto = ticker.round_elapsed_ticks + time_between_lotto
			return 0


	proc/start_lottery()
		src.time_until_lotto = ( ticker ? ticker.round_elapsed_ticks : 0 ) + time_between_lotto
		lottery_active = 1
		return

	proc/payday()
		// Every payday cycle, the station budget is awarded its stipend
		// Even if payday is off, which lets heads disable payday for
		// saving up funds or whatever.
		// This also means that payday stopping is strictly a result of
		// someone tampering it and not just having 80 assistants in 20 minutes
		station_budget += payroll_stipend
		total_stipend += payroll_stipend

		// Everyone gets paid into their bank accounts
		if (!wagesystem.pay_active) return // some greedy prick suspended the payroll!
		// if (station_budget < 1) return // we don't have any money so don't bother!
		// technically this can be 0 now with payday stipends

		for(var/datum/db_record/t as anything in data_core.bank.records)
			if(station_budget >= t["wage"])
				t["current_money"] += t["wage"]
				station_budget -= t["wage"]
#ifndef SHUT_UP_ABOUT_MY_PAY
				if (t["pda_net_id"])
					var/datum/signal/signal = get_free_signal()
					signal.data["sender"] = "00000000"
					signal.data["command"] = "text_message"
					signal.data["sender_name"] = "PAYROLL-MAILBOT"
					signal.data["address_1"] = t["pda_net_id"]
					signal.data["message"] = "[t["wage"]] credits have been deposited into your bank account. You have [t["current_money"]] credits total."
					radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)
#endif
			else
				command_alert("The station budget appears to have run dry. We regret to inform you that no further wage payments are possible until this situation is rectified.","Payroll Announcement", alert_origin = ALERT_STATION)
				wagesystem.pay_active = 0
				break

	proc/lotteryDay()

		// Increase by 10000 regardless // cogwerks - changed this to be way higher
		lotteryJackpot += 50000

		// Just so its not a mass of text
		var/j = lotteryRound

		var/dat = ""
		// Get the winning numbers
		for(var/i=1, i<5, i++)
			winningNumbers[i][j] = rand(1,3)
			dat += "[winningNumbers[i][j]] "

		for_by_tcl(T, /obj/item/lotteryTicket)
			// If the round associated on the lottery ticked is this round
			if(lotteryRound == T.lotteryRound)
				// Check the nubers
				if(winningNumbers[1][j] == T.numbers[1] && winningNumbers[2][j] == T.numbers[2] && winningNumbers[3][j] == T.numbers[3] && winningNumbers[4][j] == T.numbers[4] )
					// We have a winner
					T.winner = lotteryJackpot
					T.name = "Winning Ticket"

		//LAGCHECK(LAG_LOW)
		command_alert("Lottery round [lotteryRound]. I wish you all the best of luck. For an amazing prize of [lotteryJackpot] credits the lottery numbers are: [dat]. If you have these numbers get to an ATM to claim your prize now!", "Lottery")

		// We're in the next round!
		lotteryRound += 1

/obj/machinery/computer/ATM
	name = "\improper ATM"
	icon_state = "atm"

	var/datum/db_record/accessed_record = null
	var/obj/item/card/id/scan = null

	var/state = STATE_LOGGEDOFF


	var/pin = null
	attackby(var/obj/item/I, mob/user)
		var/obj/item/card/id/id_card = get_id_card(I)
		if(istype(id_card))
			boutput(user, SPAN_NOTICE("You swipe your ID card in the ATM."))
			src.scan = id_card
			return
		if(istype(I, /obj/item/currency/spacecash/))
			if (src.accessed_record)
				boutput(user, SPAN_NOTICE("You insert the cash into the ATM."))
				src.accessed_record["current_money"] += I.amount
				I.amount = 0
				qdel(I)
			else boutput(user, SPAN_ALERT("You need to log in before depositing cash!"))
			return
		if(istype(I, /obj/item/lotteryTicket))
			if (src.accessed_record)
				boutput(user, SPAN_NOTICE("You insert the lottery ticket into the ATM."))
				if(I:winner)
					boutput(user, SPAN_NOTICE("Congratulations, this ticket is a winner netting you [I:winner] credits"))
					src.accessed_record["current_money"] += I:winner

					if(wagesystem.lotteryJackpot > I:winner)
						wagesystem.lotteryJackpot -= I:winner
					else
						wagesystem.lotteryJackpot = 0
				else
					boutput(user, SPAN_ALERT("This ticket isn't a winner. Better luck next time!"))
				qdel(I)
			else boutput(user, SPAN_ALERT("You need to log in before inserting a ticket!"))
			return
		if(istype(I, /obj/item/currency/spacebux))
			var/obj/item/currency/spacebux/SB = I
			if(SB.spent == 1)
				return
			SB.spent = 1
			logTheThing(LOG_DIARY, user, "deposits a spacebux token worth [SB.amount].")
			user.client.add_to_bank(SB.amount)
			boutput(user, SPAN_ALERT("You deposit [SB.amount] spacebux into your account!"))
			qdel(SB)
		else if(istype(I, /obj/item/currency/spacecash/))
			if (src.accessed_record)
				boutput(user, SPAN_NOTICE("You insert the cash into the ATM."))
				src.accessed_record["current_money"] += I.amount
				I.amount = 0
				qdel(I)
			else boutput(user, SPAN_ALERT("You need to log in before depositing cash!"))
		else if(istype(I, /obj/item/currency/buttcoin/))
			if (src.accessed_record)
				boutput(user, SPAN_NOTICE("You force the cash into the ATM."))
				boutput(user, SPAN_SUCCESS("Your transaction will complete anywhere within 10 to 10e27 minutes from now."))
				I.amount = 0
				qdel(I)
			else boutput(user, SPAN_ALERT("You need to log in before depositing cash!"))
		else if(istype(I, /obj/item/lotteryTicket))
			if (src.accessed_record)
				boutput(user, SPAN_NOTICE("You insert the lottery ticket into the ATM."))
				if(I:winner)
					boutput(user, SPAN_NOTICE("Congratulations, this ticket is a winner netting you [I:winner] credits"))
					src.accessed_record["current_money"] += I:winner

					if(wagesystem.lotteryJackpot > I:winner)
						wagesystem.lotteryJackpot -= I:winner
					else
						wagesystem.lotteryJackpot = 0


				else
					boutput(user, SPAN_ALERT("This ticket isn't a winner. Better luck next time!"))
				qdel(I)
			else boutput(user, SPAN_ALERT("You need to log in before inserting a ticket!"))
		else
			..()
		return

	attack_ai(var/mob/user as mob)
		return

	attack_hand(var/mob/user)
		if(..())
			return

		src.add_dialog(user)
		var/list/dat = list("<span style=\"inline-flex\">")

		switch(src.state)
			if(STATE_LOGGEDOFF)
				if (src.scan)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Logout</A> \]"
					dat += "<BR><BR><A HREF='?src=\ref[src];operation=enterpin'>Enter Pin</A>"

				else dat += "Please swipe your card to begin."

			if(STATE_LOGGEDIN)
				if(!src.accessed_record)
					dat += "ERROR, NO RECORD DETECTED. LOGGING OFF."
					src.state = STATE_LOGGEDOFF
					src.updateUsrDialog()

				else
					dat += "<BR><A HREF='?src=\ref[src];operation=logout'>Logout</A>"

					if (src.scan)
						dat += "<BR><BR>Your balance is: [src.accessed_record["current_money"]][CREDIT_SIGN]."
						dat += "<BR><A HREF='?src=\ref[src];operation=withdrawcash'>Withdraw Cash</A>"
						dat += "<BR><BR><A HREF='?src=\ref[src];operation=buy'>Buy Lottery Ticket (100 credits)</A>"
						dat += "<BR>To claim your winnings you'll need to insert your lottery ticket."
					else
						dat += "<BR>Please swipe your card to continue."


		if (user.client)
			dat += {"
			<br><br><br>
			<div style="color:#666; border: 1px solid #555; padding:5px; margin: 3px; background-color:#efefef;">
			<strong>&mdash; [user.client.key] Spacebux Menu &mdash;</strong>
			<br><em>(This menu is only here for <strong>you</strong>. Other players cannot access your Spacebux!)</em>
			<br>
			<br>Current balance: <strong>[user.client.persistent_bank]</strong> Spacebux <!-- <a href='?src=\ref[src];operation=view_spacebux_balance'>Check Spacebux Balance</a> -->
			<br><a href='?src=\ref[src];operation=withdraw_spacebux'>Withdraw Spacebux</a>
			<br><a href='?src=\ref[src];operation=transfer_spacebux'>Securely Send Spacebux</a>
			<br>Deposit Spacebux at any time by inserting a token. It will always go to <strong>your</strong> account!
			</div>
			"}

		dat += "<BR><BR><A HREF='?action=mach_close&window=atm'>Close</A></span>"
		user.Browse(dat.Join(), "window=atm;size=400x500;title=Automated Teller Machine")
		onclose(user, "atm")


	proc/TryToFindRecord()
		src.accessed_record = data_core.bank.find_record("name", src.scan.registered)
		return !!src.accessed_record

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)

		switch(href_list["operation"])

			if ("enterpin")
				var/enterpin = usr.enter_pin("ATM")
				if (enterpin == src.scan.pin)
					if(TryToFindRecord())
						src.state = STATE_LOGGEDIN
					else
						boutput(usr, SPAN_ALERT("Cannot find a bank record for this card."))
				else
					boutput(usr, SPAN_ALERT("Incorrect PIN."))

			if("login")
				if(TryToFindRecord())
					src.state = STATE_LOGGEDIN
				else
					boutput(usr, SPAN_ALERT("Cannot find a bank record for this card."))

			if("logout")
				src.state = STATE_LOGGEDOFF
				src.accessed_record = null
				src.scan = null

			if("withdrawcash")
				if (scan.registered in FrozenAccounts)
					boutput(usr, SPAN_ALERT("This account is frozen!"))
					return
				var/amount = round(input(usr, "How much would you like to withdraw?", "Withdrawal", 0) as num)
				if( amount < 1)
					boutput(usr, SPAN_ALERT("Invalid amount!"))
					return
				if(amount > src.accessed_record["current_money"])
					boutput(usr, SPAN_ALERT("Insufficient funds in account."))
				else
					src.accessed_record["current_money"] -= amount
					var/obj/item/currency/spacecash/S = new /obj/item/currency/spacecash
					S.setup(src.loc, amount)
					usr.put_in_hand_or_drop(S)

			if("buy")
				if(accessed_record["current_money"] >= 100)
					src.accessed_record["current_money"] -= 100
					boutput(usr, SPAN_ALERT("Ticket being dispensed. Good luck!"))

					new /obj/item/lotteryTicket(src.loc)
					wagesystem.start_lottery()

				else
					boutput(usr, SPAN_ALERT("Insufficient Funds"))

			if("view_spacebux_balance")
				boutput(usr, SPAN_NOTICE("You have [usr.client.persistent_bank] spacebux."))

			if("transfer_spacebux")
				if(!usr.client)
					boutput(usr, SPAN_ALERT("Banking system offline. Welp."))
				var/amount = input("How much do you wish to transfer? You have [usr.client.persistent_bank] spacebux", "Spacebux Transfer") as num|null
				if(!amount)
					return
				if(amount <= 0)
					boutput(usr, SPAN_ALERT("No."))
					src.updateUsrDialog()
					return
				var/client/C = input("Who do you wish to give [amount] to?", "Spacebux Transfer") as anything in clients|null
				if(tgui_alert(usr, "You are about to send [amount] to [C]. Are you sure?", "Confirmation", list("Yes", "No")) == "Yes")
					if(!usr.client.bank_can_afford(amount))
						boutput(usr, SPAN_ALERT("Insufficient Funds"))
						return
					C.add_to_bank(amount)
					boutput(C, SPAN_NOTICE("<B>[usr.name] sent you [amount] spacebux!</B>"))
					usr.client.add_to_bank(-amount)
					boutput(usr, SPAN_NOTICE("<B>Transaction successful!</B>"))
					logTheThing(LOG_DIARY, usr, "sent [amount] spacebux to [C].")
					src.updateUsrDialog()
					return
				boutput(usr, SPAN_ALERT("<B>No online player with that ckey found!</B>"))

			if("withdraw_spacebux")
				var/amount = round(input(usr, "You have [usr.client.persistent_bank] spacebux.\nHow much would you like to withdraw?", "How much?", 0) as num)
				amount = clamp(amount, 0, 1000000)
				if(amount <= 0)
					boutput(usr, SPAN_ALERT("No."))
					src.updateUsrDialog()
					return

				if(!usr.client.bank_can_afford(amount))
					boutput(usr, SPAN_ALERT("Insufficient Funds"))
				else
					logTheThing(LOG_DIARY, usr, "withdrew a spacebux token worth [amount].")
					usr.client.add_to_bank(-amount)
					var/obj/item/currency/spacebux/newbux = new(src.loc, amount)
					usr.put_in_hand_or_drop(newbux)

		src.updateUsrDialog()

/obj/submachine
	name = "You shouldn't see me!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "atm"

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

/obj/submachine/ATM
	name = "\improper ATM"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "atm"
	density = 0
	opacity = 0
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_ABOVE
	flags = TGUI_INTERACTIVE

	deconstruct_flags = DECON_MULTITOOL

	var/datum/db_record/accessed_record = null
	var/obj/item/card/id/scan = null

	/// Limits how much spacebux can be physically withdrawn from the machine
	var/const/spacebux_limit = 1000000
	var/current_status_message = list()
	var/current_message_number = 0
	var/health = 70
	var/broken = 0
	var/afterlife = 0
	var/sound_interact = 'sound/machines/keypress.ogg'
	var/sound_insert_cash = 'sound/machines/scan.ogg'

	var/state = STATE_LOGGEDOFF

	attackby(var/obj/item/I, mob/user)
		if (broken)
			boutput(user, SPAN_ALERT("With its money removed and circuitry destroyed, it's unlikely this ATM will be able to do anything of use."))
			return
		var/obj/item/card/id/id_card = get_id_card(I)
		if(istype(id_card))
			if (src.scan)
				return
			boutput(user, SPAN_NOTICE("You swipe your ID card in the ATM."))
			src.scan = id_card
			src.Attackhand(user)
			return
		if (istype(I, /obj/item/currency/spacecash/))
			if (afterlife)
				boutput(user, SPAN_ALERT("On closer inspection, this ATM doesn't seem to have a deposit slot for credits!"))
				return
			if (src.accessed_record)
				boutput(user, SPAN_NOTICE("You insert the cash into the ATM."))
				src.show_message("Deposit successful.", "success", "atm")
				if (!ON_COOLDOWN(src, "sound_insertcash", 2 SECONDS))
					playsound(src.loc, sound_insert_cash, 50, 1)
				src.accessed_record["current_money"] += I.amount
				I.amount = 0
				qdel(I)
				src.Attackhand(user)
			else boutput(user, SPAN_ALERT("You need to log in before depositing cash!"))
			return
		if (istype(I, /obj/item/currency/buttcoin))
			if (afterlife)
				boutput(user, SPAN_ALERT("On closer inspection, this ATM doesn't seem to have a deposit slot for credits!"))
				return
			if (src.accessed_record)
				boutput(user, SPAN_NOTICE("You force the cash into the ATM."))
				boutput(user, SPAN_SUCCESS("Your transaction will complete anywhere within 10 to 10e27 minutes from now."))
				if (!ON_COOLDOWN(src, "sound_insertcash", 2 SECONDS))
					playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
				I.amount = 0
				qdel(I)
			else boutput(user, SPAN_ALERT("You need to log in before depositing cash!"))
			return
		if (istype(I, /obj/item/lotteryTicket))
			if (src.accessed_record)
				boutput(user, SPAN_NOTICE("You insert the lottery ticket into the ATM."))
				if (!ON_COOLDOWN(src, "sound_insertcash", 2 SECONDS))
					playsound(src.loc, sound_insert_cash, 50, 1)
				if(I:winner)
					boutput(user, SPAN_NOTICE("Congratulations, this ticket is a winner netting you [I:winner] credits"))
					src.show_message("Your ticket is a winner. Congratulations.", "success", "lottery")
					src.accessed_record["current_money"] += I:winner

					if(wagesystem.lotteryJackpot > I:winner)
						wagesystem.lotteryJackpot -= I:winner
					else
						wagesystem.lotteryJackpot = 0
					src.Attackhand(user)
				else
					boutput(user, SPAN_ALERT("This ticket isn't a winner. Better luck next time!"))
					src.show_message("Your ticket is not a winner. Commiserations.", "danger", "lottery")
				qdel(I)
			else boutput(user, SPAN_ALERT("You need to log in before inserting a ticket!"))
			return
		if (istype(I, /obj/item/currency/spacebux))
			var/obj/item/currency/spacebux/SB = I
			if(SB.spent == 1)
				return
			SB.spent = 1
			logTheThing(LOG_DIARY, user, "deposits a spacebux token worth [SB.amount].")
			user.client.add_to_bank(SB.amount)
			boutput(user, SPAN_ALERT("You deposit [SB.amount] spacebux into your account!"))
			if (!ON_COOLDOWN(src, "sound_inserttoken", 2 SECONDS))
				playsound(src.loc, 'sound/machines/capsulebuy.ogg', 50, 1)
			user.drop_item(SB)
			qdel(SB)
			src.Attackhand(user)
			return
		var/damage = I.force
		if (damage >= 5) //if it has five or more force, it'll do damage. prevents very weak objects from rattling the thing.
			user.lastattacked = get_weakref(src)
			attack_particle(user,src)
			playsound(src, 'sound/impact_sounds/Glass_Hit_1.ogg', 50,TRUE)
			src.take_damage(damage, user)
			user.visible_message(SPAN_ALERT("<b>[user] bashes the [src] with [I]!</b>"))
		else
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 50,TRUE)
			user.visible_message(SPAN_ALERT("<b>[user] uselessly bumps the [src] with [I]!</b>"))
			return

	attack_ai(var/mob/user as mob)
		return

	attack_hand(var/mob/user)
		if(broken)
			boutput(user, SPAN_ALERT("With its money removed and circuitry destroyed, it's unlikely this ATM will be able to do anything of use."))
			return
		if(..())
			return
		ui_interact(user)

	bullet_act(var/obj/projectile/P)
		if (P.power && P.proj_data.ks_ratio) //shooting ATMs with lethal rounds instantly makes them spit out their money, just like in the movies!
			src.take_damage(70)

	ex_act(severity)
		src.take_damage(70)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Atm", name)
			ui.open()

	ui_status(mob/user, datum/ui_state/state)
		. = ..()
		if(. <= UI_CLOSE || src.broken)
			return UI_CLOSE

	ui_data(mob/user)
		. = list(
			"accountBalance" = src.accessed_record ? src.accessed_record["current_money"] : 0,
			"accountName" = src.scan?.registered,
			"cardname" = src.scan?.name,
			"clientKey" = user.client?.key,
			"loggedIn" = src.state,
			"message" = src.current_status_message,
			"name" = src.name,
			"scannedCard" = src.scan,
			"spacebuxBalance" = user.client?.persistent_bank,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		if (src.broken)
			return
		switch(action)
			if("buy")
				if (ON_COOLDOWN(usr, "anti-spam", 0.5 SECONDS))
					return
				if(accessed_record["current_money"] >= 100)
					src.accessed_record["current_money"] -= 100
					boutput(usr, SPAN_ALERT("Ticket being dispensed. Good luck!"))
					usr.put_in_hand_or_eject(new /obj/item/lotteryTicket(src.loc))
					wagesystem.start_lottery()
					src.show_message("Lottery ticket purchased. Good luck.", "success", "lottery")
					if (!ON_COOLDOWN(src, "sound_buylottery", 2 SECONDS))
						playsound(src.loc, 'sound/machines/printer_cargo.ogg', 50, 1)
				else
					boutput(usr, SPAN_ALERT("Insufficient funds."))
					src.show_message("Insufficient funds in account.", "danger", "lottery")
				. = TRUE
			if ("insert_card")
				if (src.scan)
					return TRUE
				var/obj/O = usr.equipped()
				var/obj/item/card/id/ID = get_id_card(O)
				if (istype(ID))
					boutput(usr, SPAN_NOTICE("You swipe your ID card."))
					src.scan = ID
				. = TRUE
			if("login_attempt")
				if(!src.scan)
					return FALSE
				var/enteredPIN = usr.enter_pin()
				playsound(src.loc, sound_interact, 50, 1)
				if (enteredPIN == src.scan.pin)
					if(TryToFindRecord())
						src.state = STATE_LOGGEDIN
					else
						boutput(usr, SPAN_ALERT("Cannot find a bank record for this card."))
						src.show_message("Cannot find a bank record for this card.", "danger", "login")
				else
					boutput(usr, SPAN_ALERT("Incorrect or invalid PIN."))
					src.show_message("Incorrect or invalid PIN entered. Please try again.", "danger", "login")
				. = TRUE
			if("logout")
				if(!src.scan)
					. = FALSE
					return
				boutput(usr, SPAN_NOTICE("You log out of the ATM."))
				src.show_message("Log out successful. Have a secure day.", "success", "splash")
				playsound(src.loc, sound_interact, 50, 1)
				src.scan = null
				src.accessed_record = null
				src.state = STATE_LOGGEDOFF
				. = TRUE
			if("transfer_spacebux")
				if(!usr.client)
					boutput(usr, SPAN_ALERT("Banking system offline. Welp."))
				var/amount = tgui_input_number(usr, "How much do you wish to transfer? You have [usr.client.persistent_bank] spacebux.", "Spacebux Transfer", 0, usr.client?.persistent_bank)
				if(!amount)
					return
				if(amount <= 0)
					boutput(usr, SPAN_ALERT("No."))
					return
				var/client/C = tgui_input_list(usr, "Who do you wish to give [amount] to?", "Spacebux Transfer", clients)
				if(!C)
					boutput(usr, SPAN_ALERT("<B>No online player with that ckey found!</B>"))
					return
				if(tgui_alert(usr, "You are about to send [amount] spacebux to [C]. Are you sure?", "Confirmation", list("Yes", "No")) == "Yes")
					if(!usr.client.bank_can_afford(amount))
						boutput(usr, SPAN_ALERT("Insufficient funds."))
						return
					C.add_to_bank(amount)
					boutput(C, SPAN_NOTICE("<B>[usr.name] sent you [amount] spacebux!</B>"))
					usr.client.add_to_bank(-amount)
					boutput(usr, SPAN_NOTICE("<B>Transaction successful!</B>"))
					logTheThing(LOG_DIARY, usr, "sent [amount] spacebux to [C].")
				. = TRUE
			if("withdraw_cash")
				if (scan.registered in FrozenAccounts)
					boutput(usr, SPAN_ALERT("This account is frozen!"))
					src.show_message("Cannot withdraw from a frozen account.", "danger", "atm")
					return
				var/amount = tgui_input_number(usr, "How much would you like to withdraw?", "Withdrawal", 0, src.accessed_record["current_money"])
				if( amount < 1)
					boutput(usr, SPAN_ALERT("Invalid amount!"))
					src.show_message("Invalid withdrawal amount.", "danger", "atm")
					return
				if(amount > src.accessed_record["current_money"])
					boutput(usr, SPAN_ALERT("Insufficient funds in account."))
					src.show_message("Insufficient funds in account.", "danger", "atm")
				else
					src.accessed_record["current_money"] -= amount
					var/obj/item/currency/spacecash/S = new /obj/item/currency/spacecash
					S.setup(src.loc, amount)
					usr.put_in_hand_or_drop(S)
					src.show_message("Withdrawal successful.", "success", "atm")
					playsound(src.loc, 'sound/machines/printer_cargo.ogg', 50, 1)
				. = TRUE
			if("withdraw_spacebux")
				var/amount = round(tgui_input_number(usr, "You have [usr.client.persistent_bank] Spacebux.\nHow much would you like to withdraw?", "How much?", 0, min(src.spacebux_limit, usr.client?.persistent_bank)))
				if(amount <= 0)
					boutput(usr, SPAN_ALERT("No."))
					src.updateUsrDialog()
					return
				if(!usr.client.bank_can_afford(amount))
					boutput(usr, SPAN_ALERT("Insufficient funds."))
				else
					logTheThing(LOG_DIARY, usr, "withdrew a spacebux token worth [amount].")
					usr.client.add_to_bank(-amount)
					var/obj/item/currency/spacebux/newbux = new(src.loc, amount)
					usr.put_in_hand_or_drop(newbux)
				. = TRUE
		src.add_fingerprint(usr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "machineUsed")

	proc/TryToFindRecord()
		if(src.scan)
			src.accessed_record = data_core.bank.find_record("name", src.scan.registered)
			return !!src.accessed_record
		return 0

	proc/take_damage(var/damage_amount = 5, var/mob/user as mob)
		if (broken)
			return
		src.health -= damage_amount
		if (src.health <= 0)
			src.broken = 1
			src.visible_message(SPAN_ALERT("<b>The [src.name] breaks apart and spews out cash!</b>"))
			src.icon_state = "[src.icon_state]_broken"
			var/obj/item/C = pick(/obj/item/currency/spacecash/hundred, /obj/item/currency/spacecash/fifty, /obj/item/currency/spacecash/ten)
			C = new C(get_turf(src))
			playsound(src.loc,'sound/impact_sounds/Machinery_Break_1.ogg', 50, 2)
			playsound(src.loc,'sound/machines/capsulebuy.ogg', 50, 2)
			if (user)
				C.throw_at(user, 20, 3)

	#define MESSAGE_SHOW_TIME 5 SECONDS

	proc/show_message(message = "", status = "info", position = "") //blatantly stole this proc from thepotato's cloner rework thanks bud - disturbherb
		src.current_status_message["text"] = message
		src.current_status_message["status"] = status
		src.current_status_message["position"] = position
		tgui_process?.update_uis(src)
		//prevents us from overwriting the wrong message
		current_message_number += 1
		var/messageNumber = current_message_number
		SPAWN(MESSAGE_SHOW_TIME)
		if(src.current_message_number == messageNumber)
			src.current_status_message["text"] = ""
			src.current_status_message["status"] = ""
			src.current_status_message["position"] = ""
			tgui_process?.update_uis(src)

	#undef MESSAGE_SHOW_TIME

	atm_alt
		icon_state = "atm_alt"
		layer = EFFECTS_LAYER_UNDER_1

/obj/submachine/ATM/afterlife
	afterlife = 1

	take_damage(var/damage_amount = 5, var/mob/user as mob)
		return


/obj/item/lotteryTicket
	name = "lottery ticket"
	desc = "A winning lottery ticket perhaps...?"

	icon = 'icons/obj/writing.dmi'
	icon_state = "paper"

	w_class = W_CLASS_TINY

	/// 4 numbers between 1 and 3 gives a one in 81 chance of winning. It's 3^4 possible combinations.
	var/list/numbers = new/list(4)
	/// Lottery rounds
	var/lotteryRound = 0
	// If this ticket is a winner!
	var/winner = 0

	// Give a random set of numbers
	New()
		..()
		START_TRACKING

		lotteryRound = wagesystem.lotteryRound

		name = "lottery ticket (round [lotteryRound])"

		var/dat = ""

		for(var/i=1, i<5, i++)
			numbers[i] = rand(1,3)
			dat += "[numbers[i]] "

		desc = "The numbers on this ticket are: [dat]. This is for round [lotteryRound]."

	disposing()
		. = ..()
		STOP_TRACKING

proc/FindBankAccountByName(var/nametosearch)
	RETURN_TYPE(/datum/db_record)
	if (!nametosearch) return
	return data_core.bank.find_record("name", nametosearch)

/// Given a list of jobs, return the associated bank account records. Does not de-duplicate bank account records.
proc/FindBankAccountsByJobs(var/list/job_list)
	RETURN_TYPE(/list/datum/db_record)
	. = list()
	for (var/each_job in job_list)
		. += data_core.general.find_records("rank", each_job)

#undef STATE_LOGGEDOFF
#undef STATE_LOGGEDIN
