// THIS IS STATIC, I.E. NOTHING WILL BE ABLE TO REMOVE THIS SYSTEM FROM
// THE GAME, IT CAN ONLY BE MODIFIED

// THE REASON I SAY THIS IS BECAUSE WE CAN ADD A DATACORE OR SOMETHING THAT CAN BE BLOWN UP
// AND ALL THE MONEY WILL BE GONE

/datum/wage_system

	// Stations budget
	var/station_budget = 0
	var/shipping_budget = 0
	var/research_budget = 0
	var/payroll_stipend = 0
	var/total_stipend = 0

	var/list/jobs = new/list()

	var/pay_active = 1
	var/lottery_active = 0		// inactive until someone actually buys a ticket
	var/time_between_paydays = 0
	var/time_until_payday = 0

	var/time_between_lotto = 0
	var/time_until_lotto = 0

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

		for(var/occupation in occupations)

			// Skip AI
			if(occupation == "AI" || occupation == "Cyborg")
				continue

			// If its not already in the list add it
			if (!(occupation in jobs))
				// 0.0 is the default wage
				jobs[occupation] = 0

		for(var/occupation in assistant_occupations)
			// If its not already in the list add it
			if (!(occupation in jobs))
				// 0.0 is the default wage
				jobs[occupation] = 0

		// Captain isn't in the occupation list
		jobs["Captain"] = 0

		default_wages()


	proc/default_wages()

		station_budget =      0
		shipping_budget = 30000
		research_budget = 20000
		total_stipend = station_budget + shipping_budget + research_budget

		// This is gonna throw up some crazy errors if it isn't done right!
		// cogwerks - raising all of the paychecks, oh god

		jobs["Engineer"] = PAY_TRADESMAN
		jobs["Miner"] = PAY_TRADESMAN
//		jobs["Atmospheric Technician"] = PAY_TRADESMAN
		jobs["Security Officer"] = PAY_TRADESMAN
//		jobs["Vice Officer"] = PAY_TRADESMAN
		jobs["Detective"] = PAY_TRADESMAN
		jobs["Geneticist"] = PAY_DOCTORATE
		jobs["Pathologist"] = PAY_DOCTORATE
		jobs["Scientist"] = PAY_DOCTORATE
		jobs["Medical Doctor"] = PAY_DOCTORATE
		jobs["Medical Director"] = PAY_IMPORTANT
		jobs["Head of Personnel"] = PAY_IMPORTANT
		jobs["Head of Security"] = PAY_IMPORTANT
//		jobs["Head of Security"] = PAY_DUMBCLOWN
		jobs["Chief Engineer"] = PAY_IMPORTANT
		jobs["Research Director"] = PAY_IMPORTANT
		jobs["Chaplain"] = PAY_UNTRAINED
		jobs["Roboticist"] = PAY_DOCTORATE
//		jobs["Hangar Mechanic"]= PAY_TRADESMAN
//		jobs["Elite Security"] = PAY_TRADESMAN
		jobs["Bartender"] = PAY_UNTRAINED
		jobs["Chef"] = PAY_UNTRAINED
		jobs["Janitor"] = PAY_TRADESMAN
		jobs["Clown"] = PAY_DUMBCLOWN
//		jobs["Chemist"] = PAY_DOCTORATE
		jobs["Quartermaster"] = PAY_TRADESMAN
		jobs["Botanist"] = PAY_TRADESMAN
		jobs["Rancher"] = PAY_TRADESMAN
//		jobs["Attorney at Space-Law"] = PAY_DOCTORATE
		jobs["Staff Assistant"] = PAY_UNTRAINED
		jobs["Medical Assistant"] = PAY_UNTRAINED
		jobs["Technical Assistant"] = PAY_UNTRAINED
		jobs["Security Assistant"] = PAY_UNTRAINED
		jobs["Captain"] = PAY_EXECUTIVE

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
				if (t["pda_net_id"])
					var/datum/signal/signal = get_free_signal()
					signal.data["sender"] = "00000000"
					signal.data["command"] = "text_message"
					signal.data["sender_name"] = "PAYROLL-MAILBOT"
					signal.data["address_1"] = t["pda_net_id"]
					signal.data["message"] = "[t["wage"]] credits have been deposited into your bank account. You have [t["current_money"]] credits total."
					radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)
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


/*
	proc/update_wage(var/mob/living/carbon/C, var/rank)

		if(!jobs.Find(rank))
			message_admins("Yo dudes [rank] isn't defined as having any wage, this means they won't get paid!! Alert Nannek this is a disaster!!")
			return

		jobs[rank] = C.wage
*/

/obj/machinery/computer/ATM
	name = "ATM"
	icon_state = "atm"

	var/datum/db_record/accessed_record = null
	var/obj/item/card/id/scan = null

	var/state = STATE_LOGGEDOFF
	var/const
		STATE_LOGGEDOFF = 1
		STATE_LOGGEDIN = 2


	var/pin = null
	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/device/pda2) && I:ID_card)
			I = I:ID_card
		if(istype(I, /obj/item/card/id))
			boutput(user, "<span class='notice'>You swipe your ID card in the ATM.</span>")
			src.scan = I
			return
		if(istype(I, /obj/item/spacecash/))
			if (src.accessed_record)
				boutput(user, "<span class='notice'>You insert the cash into the ATM.</span>")
				src.accessed_record["current_money"] += I.amount
				I.amount = 0
				qdel(I)
			else boutput(user, "<span class='alert'>You need to log in before depositing cash!</span>")
			return
		if(istype(I, /obj/item/lotteryTicket))
			if (src.accessed_record)
				boutput(user, "<span class='notice'>You insert the lottery ticket into the ATM.</span>")
				if(I:winner)
					boutput(user, "<span class='notice'>Congratulations, this ticket is a winner netting you [I:winner] credits</span>")
					src.accessed_record["current_money"] += I:winner

					if(wagesystem.lotteryJackpot > I:winner)
						wagesystem.lotteryJackpot -= I:winner
					else
						wagesystem.lotteryJackpot = 0
				else
					boutput(user, "<span class='alert'>This ticket isn't a winner. Better luck next time!</span>")
				qdel(I)
			else boutput(user, "<span class='alert'>You need to log in before inserting a ticket!</span>")
			return
		if(istype(I, /obj/item/spacebux))
			var/obj/item/spacebux/SB = I
			if(SB.spent == 1)
				return
			SB.spent = 1
			logTheThing(LOG_DIARY, user, "deposits a spacebux token worth [SB.amount].")
			user.client.add_to_bank(SB.amount)
			boutput(user, "<span class='alert'>You deposit [SB.amount] spacebux into your account!</span>")
			qdel(SB)
		else if(istype(I, /obj/item/spacecash/))
			if (src.accessed_record)
				boutput(user, "<span class='notice'>You insert the cash into the ATM.</span>")

				if(istype(I, /obj/item/spacecash/buttcoin))
					boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
				else
					src.accessed_record["current_money"] += I.amount

				I.amount = 0
				qdel(I)
			else boutput(user, "<span class='alert'>You need to log in before depositing cash!</span>")
		else if(istype(I, /obj/item/lotteryTicket))
			if (src.accessed_record)
				boutput(user, "<span class='notice'>You insert the lottery ticket into the ATM.</span>")
				if(I:winner)
					boutput(user, "<span class='notice'>Congratulations, this ticket is a winner netting you [I:winner] credits</span>")
					src.accessed_record["current_money"] += I:winner

					if(wagesystem.lotteryJackpot > I:winner)
						wagesystem.lotteryJackpot -= I:winner
					else
						wagesystem.lotteryJackpot = 0


				else
					boutput(user, "<span class='alert'>This ticket isn't a winner. Better luck next time!</span>")
				qdel(I)
			else boutput(user, "<span class='alert'>You need to log in before inserting a ticket!</span>")
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
						boutput(usr, "<span class='alert'>Cannot find a bank record for this card.</span>")
				else
					boutput(usr, "<span class='alert'>Incorrect pin number.</span>")

			if("login")
				if(TryToFindRecord())
					src.state = STATE_LOGGEDIN
				else
					boutput(usr, "<span class='alert'>Cannot find a bank record for this card.</span>")

			if("logout")
				src.state = STATE_LOGGEDOFF
				src.accessed_record = null
				src.scan = null

			if("withdrawcash")
				if (scan.registered in FrozenAccounts)
					boutput(usr, "<span class='alert'>This account is frozen!</span>")
					return
				var/amount = round(input(usr, "How much would you like to withdraw?", "Withdrawal", 0) as num)
				if( amount < 1)
					boutput(usr, "<span class='alert'>Invalid amount!</span>")
					return
				if(amount > src.accessed_record["current_money"])
					boutput(usr, "<span class='alert'>Insufficient funds in account.</span>")
				else
					src.accessed_record["current_money"] -= amount
					var/obj/item/spacecash/S = new /obj/item/spacecash
					S.setup(src.loc, amount)
					usr.put_in_hand_or_drop(S)

			if("buy")
				if(accessed_record["current_money"] >= 100)
					src.accessed_record["current_money"] -= 100
					boutput(usr, "<span class='alert'>Ticket being dispensed. Good luck!</span>")

					new /obj/item/lotteryTicket(src.loc)
					wagesystem.start_lottery()

				else
					boutput(usr, "<span class='alert'>Insufficient Funds</span>")

			if("view_spacebux_balance")
				boutput(usr, "<span class='notice'>You have [usr.client.persistent_bank] spacebux.</span>")

			if("transfer_spacebux")
				if(!usr.client)
					boutput(usr, "<span class='alert'>Banking system offline. Welp.</span>")
				var/amount = input("How much do you wish to transfer? You have [usr.client.persistent_bank] spacebux", "Spacebux Transfer") as num|null
				if(!amount)
					return
				if(amount <= 0)
					boutput(usr, "<span class='alert'>No.</span>")
					src.updateUsrDialog()
					return
				var/client/C = input("Who do you wish to give [amount] to?", "Spacebux Transfer") as anything in clients|null
				if(tgui_alert(usr, "You are about to send [amount] to [C]. Are you sure?", "Confirmation", list("Yes", "No")) == "Yes")
					if(!usr.client.bank_can_afford(amount))
						boutput(usr, "<span class='alert'>Insufficient Funds</span>")
						return
					C.add_to_bank(amount)
					boutput(C, "<span class='notice'><B>[usr.name] sent you [amount] spacebux!</B></span>")
					usr.client.add_to_bank(-amount)
					boutput(usr, "<span class='notice'><B>Transaction successful!</B></span>")
					logTheThing(LOG_DIARY, usr, "sent [amount] spacebux to [C].")
					src.updateUsrDialog()
					return
				boutput(usr, "<span class='alert'><B>No online player with that ckey found!</B></span>")

			if("withdraw_spacebux")
				var/amount = round(input(usr, "You have [usr.client.persistent_bank] spacebux.\nHow much would you like to withdraw?", "How much?", 0) as num)
				amount = clamp(amount, 0, 1000000)
				if(amount <= 0)
					boutput(usr, "<span class='alert'>No.</span>")
					src.updateUsrDialog()
					return

				if(!usr.client.bank_can_afford(amount))
					boutput(usr, "<span class='alert'>Insufficient Funds</span>")
				else
					logTheThing(LOG_DIARY, usr, "withdrew a spacebux token worth [amount].")
					usr.client.add_to_bank(-amount)
					var/obj/item/spacebux/newbux = new(src.loc, amount)
					usr.put_in_hand_or_drop(newbux)

		src.updateUsrDialog()


/obj/machinery/computer/bank_data
	name = "Bank Records"
	icon_state = "databank"
	req_access = list(access_heads)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	circuit_type = /obj/item/circuitboard/bank_data
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/payroll_rate_limit_time = 0 //for preventing coammand message spam

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/card/id))
			if (!src.scan)
				boutput(user, "<span class='notice'>You insert [I] into the authentication card slot.</span>")
				user.drop_item()
				I.set_loc(src)
				src.scan = I
			else
				boutput(user, "<span class='notice'>There is already a card inserted.</span>")

		else
			..()

	attack_hand(mob/user)
		if(..())
			return
		var/list/dat = list()
		if (src.temp)
			dat += text("<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>")
		else
			dat += {"
				<style type="text/css">
				.l { text-align: left; }
				.r { text-align: right; }
				.c { text-align: center; }
				.hyp-dominant { font-weight: bold; background-color: rgba(160, 160, 160, 0.33);}
				.buttonlink { background: #66c; width: 1.1em; height: 1.2em; padding: 0.2em 0.2em; margin-bottom: 2px; border-radius: 4px; font-size: 90%; color: white; text-decoration: none; display: inline-block; vertical-align: middle; }
				table { width: 100%; }
				td, th { border-bottom: 1px solid rgb(160, 160, 160); padding: 0.1em 0.2em; }
				thead { background: rgba(160, 160, 160, 0.6); }
				th.second { background: rgba(160, 160, 160, 0.3); }
				abbr { text-decoration: underline; }
				.buttonlinks { white-space: nowrap; padding: 0; text-align: center; }
				</style>

				ID Card: [src.scan ? "<a href='?src=\ref[src];scan=1' class='buttonlink'>&#9167;</a> [src.scan.name]" : "<a href='?src=\ref[src];scan=1'>No card inserted.</a>"]
				<br><a href='?src=\ref[src];[src.authenticated ? "logout=1'>Log Out" : "login=1'>Log In"]</a><hr>
				"}

			if (src.authenticated)

				var/total_funds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
				var/payroll = 0
				for(var/datum/db_record/R as anything in data_core.bank.records)
					payroll += R["wage"]
				var/surplus = round(wagesystem.payroll_stipend - payroll)

				dat += {"
			<table>
				<thead>
					<tr><th colspan="2">Budget Status</th></tr>
				</thead>
				<tbody>
					<tr><th>Payroll Budget</th><td class='r'>[num2text(round(wagesystem.station_budget),50)][CREDIT_SIGN]</td></tr>
					<tr><th>Shipping Budget</th><td class='r'>[num2text(round(wagesystem.shipping_budget),50)][CREDIT_SIGN]</td></tr>
					<tr><th>Research Budget</th><td class='r'>[num2text(round(wagesystem.research_budget),50)][CREDIT_SIGN]</td></tr>
					<tr><th>Total Funds</th><th class='r'>[num2text(round(total_funds),50)][CREDIT_SIGN]</th></tr>
					<tr><th colspan="2" class='second'>Payroll Details</th></tr>
					<tr><th>Payroll Stipend</th><td class='r'>[num2text(round(wagesystem.payroll_stipend),50)][CREDIT_SIGN]</td></tr>
					<tr><th>Payroll Cost</th><td class='r'>[num2text(round(payroll),50)][CREDIT_SIGN]</td></tr>
					[surplus >= 0 ? {"
					<tr><th>Surplus</th><th class='r'>+[num2text(round(surplus),50)][CREDIT_SIGN]</th></tr>
					"} : {"
					<tr><th>Deficit</th><th style="text-align: right; color: red;">-[num2text(round(surplus * -1),50)][CREDIT_SIGN]</th></tr>
					"}]
					<tr><th>Total Stipend</th><td class='r'>[num2text(round(wagesystem.total_stipend), 50)][CREDIT_SIGN]</td></tr>
				</tbody>
			</table>
			<div class='c'>
				<a href='?src=\ref[src];payroll=1'>[wagesystem.pay_active ? "Suspend Payroll" : "Resume Payroll"]</a>
				- <a href='?src=\ref[src];transfer=1'>Transfer Funds Between Budgets</a>
			</div>
			<hr>
			Every payday cycle, Centcom distributes the <em>payroll stipend</em> into the station's budget, which is then paid out to crew accounts.
			<br>
			<br>The payday stipend is based on typical staffing costs and will not change if you adjust the pay scales below.
			<br>
			<br>The station is profitable if the <em>total funds</em> are larger than the <em>total stipend</em>.
			<hr>
			<table>
				<thead>
					<tr>
						<th>Name</th>
						<th>Job</th>
						<th>Wage</th>
						<th>Balance</th>
					</tr>
				</thead>
				<tbody>
				"}

				for(var/datum/db_record/R as anything in data_core.bank.records)
					dat += {"
					<tr>
						<th class='l'><a href='?src=\ref[src];Fname=\ref[R]' class='buttonlink'>&#x270F;&#xFE0F;</a> [R["name"]]</th>
						<td><a href='?src=\ref[src];Fjob=\ref[R]' class='buttonlink'>&#x270F;&#xFE0F;</a> [R["job"]]</td>
						<td class='r'>[R["wage"]][CREDIT_SIGN] <a href='?src=\ref[src];Fwage=\ref[R]' class='buttonlink'>&#x270F;&#xFE0F;</a></td>
						<td style="text-align: right; font-weight: bold;">[R["current_money"]][CREDIT_SIGN] <a href='?src=\ref[src];Fmoney=\ref[R]' class='buttonlink'>&#x270F;&#xFE0F;</a></td>
					</tr>
					"}

				dat += {"
				</tbody>
			</table>
				"}
		user.Browse(dat.Join(), "window=secure_bank;size=500x700;title=Bank Records")
		onclose(user, "secure_bank")
		return

	Topic(href, href_list)
		if(..())
			return
		var/usr_is_robot = issilicon(usr) || isAIeye(usr)
		if (((src in usr.contents) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (usr_is_robot))
			src.add_dialog(usr)
			if (href_list["temp"])
				src.temp = null
			if (href_list["scan"])
				if (src.scan)
					usr.put_in_hand_or_eject(src.scan)
					src.scan = null
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/card/id))
						usr.drop_item()
						I.set_loc(src)
						src.scan = I
			else
				if (href_list["logout"])
					src.authenticated = null
					src.screen = null
				else
					if (href_list["login"])
						if (usr_is_robot && !isghostdrone(usr))
							src.authenticated = 1
							src.rank = "AI"
							src.screen = 1
						if (istype(src.scan, /obj/item/card/id))
							if(check_access(src.scan))
								src.authenticated = src.scan.registered
								src.rank = src.scan.assignment
								src.screen = 1
			if (src.authenticated)
				if (href_list["list"])
					src.screen = 2
				else if (href_list["main"])
					src.screen = 1
				else if(href_list["Fname"])
					var/datum/db_record/R = locate(href_list["Fname"])
					var/t1 = input("Please input name:", "Secure. records", R["name"], null)  as null|text
					t1 = copytext(html_encode(t1), 1, MAX_MESSAGE_LEN)
					if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_interact_range(src, usr) && (!usr_is_robot)))) return
					R["name"] = t1
				else if(href_list["Fjob"])
					var/datum/db_record/R = locate(href_list["Fjob"])
					var/t1 = input("Please input name:", "Secure. records", R["job"], null)  as null|text
					t1 = copytext(html_encode(t1), 1, MAX_MESSAGE_LEN)
					if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_interact_range(src, usr) && (!usr_is_robot)))) return
					R["job"] = t1
					playsound(src.loc, "keyboard", 50, 1, -15)
				else if(href_list["Fwage"])
					var/datum/db_record/R = locate(href_list["Fwage"])
					var/t1 = input("Please input wage:", "Secure. records", R["wage"], null)  as null|num
					if ((!( src.authenticated ) || usr.stat || usr.restrained() || (!in_interact_range(src, usr) && (!usr_is_robot)))) return
					if (t1 < 0)
						t1 = 0
						boutput(usr, "<span class='alert'>You cannot set a negative wage.</span>")
					if (!t1) t1 = 0
					if (t1 > 10000)
						t1 = 10000
						boutput(usr, "<span class='alert'>Maximum wage is 10,000[CREDIT_SIGN].</span>")
					logTheThing(LOG_STATION, usr, "sets <b>[R["name"]]</b>'s wage to [t1][CREDIT_SIGN].")
					R["wage"] = t1
				else if(href_list["Fmoney"])
					var/datum/db_record/R = locate(href_list["Fmoney"])
					var/avail = null
					var/t2 = input("Withdraw or Deposit?", "Secure Records", null, null) in list("Withdraw", "Deposit")
					var/t1 = input("How much?", "Secure. records", R["current_money"], null)  as null|num
					if ((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!in_interact_range(src, usr) && (!usr_is_robot)))) return
					if (t2 == "Withdraw")
						if (R["name"] in FrozenAccounts)
							boutput(usr, "<span class='alert'>This account cannot currently be liquidated due to active borrows.</span>")
							return
						avail = R["current_money"]
						if (t1 > avail) t1 = avail
						if (t1 < 1) return
						R["current_money"] -= t1
						wagesystem.station_budget += t1
						logTheThing(LOG_STATION, usr, "adds [t1][CREDIT_SIGN] to the station budget from <b>[R["name"]]</b>'s account.")
						boutput(usr, "<span class='notice'>[t1][CREDIT_SIGN] added to station budget from [R["name"]]'s account.</span>")
					else if (t2 == "Deposit")
						avail = wagesystem.station_budget
						if (t1 > avail) t1 = avail
						if (t1 < 1) return
						R["current_money"] += t1
						wagesystem.station_budget -= t1
						logTheThing(LOG_STATION, usr, "adds [t1][CREDIT_SIGN] to <b>[R["name"]]</b>'s account from the station budget.")
						boutput(usr, "<span class='notice'>[t1][CREDIT_SIGN] added to [R["name"]]'s account from station budget.</span>")
					else boutput(usr, "<span class='alert'>Error selecting withdraw/deposit mode.</span>")
				else if(href_list["payroll"])
					if(world.time >= src.payroll_rate_limit_time)
						src.payroll_rate_limit_time = world.time + (10 SECONDS)
					else //slow the fuck down cowboy
						boutput(usr, "<span class='alert'>Nanotrasen policy forbids the modification station payroll status more than once every ten seconds!</span>")
						return
					if (wagesystem.pay_active)
						wagesystem.pay_active = 0
						logTheThing(LOG_STATION, usr, "suspends the station payroll.")
						command_alert("The payroll has been suspended until further notice. No further wages will be paid until the payroll is resumed.","Payroll Announcement", alert_origin = ALERT_STATION)
					else
						wagesystem.pay_active = 1
						logTheThing(LOG_STATION, usr, "resumes the station payroll.")
						command_alert("The payroll has been resumed. Wages will now be paid into employee accounts normally.","Payroll Announcement", alert_origin = ALERT_STATION)
				else if(href_list["transfer"])
					var/transfrom = input("Transfer from which?", "Budgeting", null, null) in list("Payroll", "Shipping", "Research")
					if (!transfrom)
						boutput(usr, "<span class='alert'>Error selecting budget to transfer from.</span>")
						return
					var/transto = input("Transfer to which?", "Budgeting", null, null) in list("Payroll", "Shipping", "Research")
					if (!transto)
						boutput(usr, "<span class='alert'>Error selecting budget to transfer to.</span>")
						return
					if (transfrom == transto)
						boutput(usr, "<span class='alert'>You can't transfer a budget into itself.</span>")
						return
					var/amount = input(usr, "How much would you like to transfer?", "Budget Transfer", 0) as null|num
					if (!amount) amount = 0
					if (amount < 0) amount = 0

					if (transfrom == "Payroll" && amount > wagesystem.station_budget) amount = wagesystem.station_budget
					if (transfrom == "Shipping" && amount > wagesystem.shipping_budget) amount = wagesystem.shipping_budget
					if (transfrom == "Research" && amount > wagesystem.research_budget) amount = wagesystem.research_budget

					if (transfrom == "Payroll") wagesystem.station_budget -= amount
					if (transfrom == "Shipping") wagesystem.shipping_budget -= amount
					if (transfrom == "Research") wagesystem.research_budget -= amount

					if (transto == "Payroll") wagesystem.station_budget += amount
					if (transto == "Shipping") wagesystem.shipping_budget += amount
					if (transto == "Research") wagesystem.research_budget += amount

		src.add_fingerprint(usr)
		src.updateUsrDialog()

		return

/obj/machinery/computer/bank_data/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "bank1"
/obj/machinery/computer/bank_data/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "bank2"

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
	name = "ATM"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "atm"
	density = 0
	opacity = 0
	anchored = 1
	plane = PLANE_NOSHADOW_ABOVE
	flags = TGUI_INTERACTIVE

	deconstruct_flags = DECON_MULTITOOL

	var/datum/db_record/accessed_record = null
	var/obj/item/card/id/scan = null
	var/health = 70
	var/broken = 0
	var/afterlife = 0

	var/state = STATE_LOGGEDOFF
	var/const
		STATE_LOGGEDOFF = 1
		STATE_LOGGEDIN = 2

	attackby(var/obj/item/I, mob/user)
		if(broken)
			boutput(user, "<span class='alert'>With its money removed and circuitry destroyed, it's unlikely this ATM will be able to do anything of use.</span>")
			return
		if (istype(I, /obj/item/device/pda2) && I:ID_card)
			I = I:ID_card
		if(istype(I, /obj/item/card/id))
			boutput(user, "<span class='notice'>You swipe your ID card in the ATM.</span>")
			src.scan = I
			attack_hand(user)
			return
		if(istype(I, /obj/item/spacecash/))
			if (afterlife)
				boutput(user, "<span class='alert'>On closer inspection, this ATM doesn't seem to have a deposit slot for credits!</span>")
				return
			if (src.accessed_record)
				boutput(user, "<span class='notice'>You insert the cash into the ATM.</span>")
				src.accessed_record["current_money"] += I.amount
				I.amount = 0
				qdel(I)
				attack_hand(user)
			else boutput(user, "<span class='alert'>You need to log in before depositing cash!</span>")
			return
		if(istype(I, /obj/item/lotteryTicket))
			if (src.accessed_record)
				boutput(user, "<span class='notice'>You insert the lottery ticket into the ATM.</span>")
				if(I:winner)
					boutput(user, "<span class='notice'>Congratulations, this ticket is a winner netting you [I:winner] credits</span>")
					src.accessed_record["current_money"] += I:winner

					if(wagesystem.lotteryJackpot > I:winner)
						wagesystem.lotteryJackpot -= I:winner
					else
						wagesystem.lotteryJackpot = 0
				else
					boutput(user, "<span class='alert'>This ticket isn't a winner. Better luck next time!</span>")
				qdel(I)
			else boutput(user, "<span class='alert'>You need to log in before inserting a ticket!</span>")
			return
		if(istype(I, /obj/item/spacebux))
			var/obj/item/spacebux/SB = I
			if(SB.spent == 1)
				return
			SB.spent = 1
			logTheThing(LOG_DIARY, user, "deposits a spacebux token worth [SB.amount].")
			user.client.add_to_bank(SB.amount)
			boutput(user, "<span class='alert'>You deposit [SB.amount] spacebux into your account!</span>")
			qdel(SB)
		var/damage = I.force
		if (damage >= 5) //if it has five or more force, it'll do damage. prevents very weak objects from rattling the thing.
			user.lastattacked = src
			attack_particle(user,src)
			playsound(src, 'sound/impact_sounds/Glass_Hit_1.ogg', 50,1)
			src.take_damage(damage, user)
			user.visible_message("<span class='alert'><b>[user] bashes the [src] with [I]!</b></span>")
		else
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 50,1)
			user.visible_message("<span class='alert'><b>[user] uselessly bumps the [src] with [I]!</b></span>")
			return

	attack_ai(var/mob/user as mob)
		return

	attack_hand(var/mob/user)
		if(broken)
			boutput(user, "<span class='alert'>With its money removed and circuitry destroyed, it's unlikely this ATM will be able to do anything of use.</span>")
			return
		if(..())
			return

		ui_interact(user)

		// src.add_dialog(user)
		// var/list/dat = list("<span style=\"inline-flex\">")

		// switch(src.state)
		// 	if(STATE_LOGGEDOFF)
		// 		if (src.scan)
		// 			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Logout</A> \]"
		// 			if(afterlife)
		// 				dat += "<BR><BR><A HREF='?src=\ref[src];operation=login'>Log In</A>"
		// 			else
		// 				dat += "<BR><BR><A HREF='?src=\ref[src];operation=enterpin'>Enter Pin</A>"

		// 		else dat += "Please swipe your card to begin."

		// 	if(STATE_LOGGEDIN)
		// 		if(!src.accessed_record)
		// 			dat += "ERROR, NO RECORD DETECTED. LOGGING OFF."
		// 			src.state = STATE_LOGGEDOFF
		// 			src.updateUsrDialog()

		// 		else
		// 			dat += "<BR><A HREF='?src=\ref[src];operation=logout'>Logout</A>"

		// 			if (src.scan)
		// 				dat += "<BR><BR>Your balance is: [src.accessed_record["current_money"]][CREDIT_SIGN]."
		// 				dat += "<BR><A HREF='?src=\ref[src];operation=withdrawcash'>Withdraw Cash</A>"
		// 				dat += "<BR><BR><A HREF='?src=\ref[src];operation=buy'>Buy Lottery Ticket (100 credits)</A>"
		// 				dat += "<BR>To claim your winnings you'll need to insert your lottery ticket."
		// 			else
		// 				dat += "<BR>Please swipe your card to continue."


		// if (user.client)
		// 	dat += {"
		// 	<br><br><br>
		// 	<div style="color:#666; border: 1px solid #555; padding:5px; margin: 3px; background-color:#efefef;">
		// 	<strong>&mdash; [user.client.key] Spacebux Menu &mdash;</strong>
		// 	<br><em>(This menu is only here for <strong>you</strong>. Other players cannot access your Spacebux!)</em>
		// 	<br>
		// 	<br>Current balance: <strong>[user.client.persistent_bank]</strong> Spacebux <!-- <a href='?src=\ref[src];operation=view_spacebux_balance'>Check Spacebux Balance</a> -->
		// 	<br><a href='?src=\ref[src];operation=withdraw_spacebux'>Withdraw Spacebux</a>
		// 	<br><a href='?src=\ref[src];operation=transfer_spacebux'>Securely Send Spacebux</a>
		// 	<br>Deposit Spacebux at any time by inserting a token. It will always go to <strong>your</strong> account!
		// 	</div>
		// 	"}

		// dat += "<BR><BR><A HREF='?action=mach_close&window=atm'>Close</A></span>"
		// user.Browse(dat.Join(), "window=atm;size=400x500;title=Automated Teller Machine")
		// onclose(user, "atm") */

	bullet_act(var/obj/projectile/P)
		if (P.power && P.proj_data.ks_ratio) //shooting ATMs with lethal rounds instantly makes them spit out their money, just like in the movies!
			src.take_damage(70)

	proc/TryToFindRecord()
		if(src.scan)
			src.accessed_record = data_core.bank.find_record("name", src.scan.registered)
			return !!src.accessed_record
		return 0

	/* Topic(href, href_list)
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
						boutput(usr, "<span class='alert'>Cannot find a bank record for this card.</span>")
				else
					boutput(usr, "<span class='alert'>Incorrect pin number.</span>")

			if("login")
				if(TryToFindRecord())
					src.state = STATE_LOGGEDIN
				else
					boutput(usr, "<span class='alert'>Cannot find a bank record for this card.</span>")

			if("logout")
				src.state = STATE_LOGGEDOFF
				src.accessed_record = null
				src.scan = null

			if("withdrawcash")
				if (scan.registered in FrozenAccounts)
					boutput(usr, "<span class='alert'>This account is frozen!</span>")
					return
				var/amount = round(input(usr, "How much would you like to withdraw?", "Withdrawal", 0) as num)
				if( amount < 1)
					boutput(usr, "<span class='alert'>Invalid amount!</span>")
					return
				if(amount > src.accessed_record["current_money"])
					boutput(usr, "<span class='alert'>Insufficient funds in account.</span>")
				else
					src.accessed_record["current_money"] -= amount
					var/obj/item/spacecash/S = new /obj/item/spacecash
					S.setup(src.loc, amount)
					usr.put_in_hand_or_drop(S)

			if("buy")
				if(accessed_record["current_money"] >= 100)
					src.accessed_record["current_money"] -= 100
					boutput(usr, "<span class='alert'>Ticket being dispensed. Good luck!</span>")

					new /obj/item/lotteryTicket(src.loc)
					wagesystem.start_lottery()

				else
					boutput(usr, "<span class='alert'>Insufficient Funds</span>")

			if("view_spacebux_balance")
				boutput(usr, "<span class='notice'>You have [usr.client.persistent_bank] spacebux.</span>")

			if("transfer_spacebux")
				if(!usr.client)
					boutput(usr, "<span class='alert'>Banking system offline. Welp.</span>")
				var/amount = input("How much do you wish to transfer? You have [usr.client.persistent_bank] spacebux", "Spacebux Transfer") as num|null
				if(!amount)
					return
				if(amount <= 0)
					boutput(usr, "<span class='alert'>No.</span>")
					src.updateUsrDialog()
					return
				var/client/C = input("Who do you wish to give [amount] to?", "Spacebux Transfer") as anything in clients|null
				if(tgui_alert("You are about to send [amount] to [C]. Are you sure?", "Confirmation", list("Yes", "No")) == "Yes")
					if(!usr.client.bank_can_afford(amount))
						boutput(usr, "<span class='alert'>Insufficient Funds</span>")
						return
					C.add_to_bank(amount)
					boutput(C, "<span class='notice'><B>[usr.name] sent you [amount] spacebux!</B></span>")
					usr.client.add_to_bank(-amount)
					boutput(usr, "<span class='notice'><B>Transaction successful!</B></span>")
					logTheThing(LOG_DIARY, usr, "sent [amount] spacebux to [C].")
					src.updateUsrDialog()
					return
				boutput(usr, "<span class='alert'><B>No online player with that ckey found!</B></span>")

			if("withdraw_spacebux")
				var/amount = round(input(usr, "You have [usr.client.persistent_bank] spacebux.\nHow much would you like to withdraw?", "How much?", 0) as num)
				amount = clamp(amount, 0, 1000000)
				if(amount <= 0)
					boutput(usr, "<span class='alert'>No.</span>")
					src.updateUsrDialog()
					return

				if(!usr.client.bank_can_afford(amount))
					boutput(usr, "<span class='alert'>Insufficient Funds</span>")
				else
					logTheThing(LOG_DIARY, usr, "withdrew a spacebux token worth [amount].")
					usr.client.add_to_bank(-amount)
					var/obj/item/spacebux/newbux = new(src.loc, amount)
					usr.put_in_hand_or_drop(newbux)

		src.updateUsrDialog() */

	proc/take_damage(var/damage_amount = 5, var/mob/user as mob)
		if (broken)
			return
		src.health -= damage_amount
		if (src.health <= 0)
			src.broken = 1
			src.visible_message("<span class='alert'><b>The [src.name] breaks apart and spews out cash!</b></span>")
			src.icon_state = "[src.icon_state]_broken"
			var/obj/item/C = pick(/obj/item/spacecash/hundred, /obj/item/spacecash/fifty, /obj/item/spacecash/ten)
			C = new C(get_turf(src))
			playsound(src.loc,'sound/impact_sounds/Machinery_Break_1.ogg', 50, 2)
			playsound(src.loc,'sound/machines/capsulebuy.ogg', 50, 2)
			if (user)
				C.throw_at(user, 20, 3)

	ex_act(severity)
		src.take_damage(70)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Atm", name)
			ui.open()

	ui_data(mob/user)
		. = list(
			"scannedCard" = src.scan,
			"cardname" = src.scan?.name,
			"loggedIn" = src.state
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		switch(action)
			if ("insert_card")
				if (src.scan)
					return TRUE
				var/obj/O = usr.equipped()
				if (istype(O, /obj/item/card/id))
					boutput(usr, "<span class='notice'>You swipe your ID card.</span>")
					src.scan = O
					. = TRUE
			if("logout")
				if(!src.scan)
					. = FALSE
					return
				boutput(usr, "<span class='notice'>You log out of the ATM.</span>")
				src.scan = null
				src.state = STATE_LOGGEDOFF
				. = TRUE
			if("login_attempt")
				if(!src.scan)
					return FALSE
				var/userPin
				if (usr.mind?.remembered_pin)
					userPin = usr.mind?.remembered_pin
				var/enteredPIN = text2num(tgui_input_text(usr, "Enter your PIN", src.name, userPin, 4))
				if (enteredPIN == src.scan.pin)
					if(TryToFindRecord())
						src.state = STATE_LOGGEDIN
						. = TRUE
					else
						boutput(usr, "<span class='alert'>Cannot find a bank record for this card.</span>")
				else
					boutput(usr, "<span class='alert'>Incorrect or invalid PIN number.</span>")
		src.add_fingerprint(usr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "machineUsed")

	atm_alt
		icon_state = "atm_alt"
		layer = EFFECTS_LAYER_UNDER_1

/obj/submachine/ATM/afterlife
	afterlife = 1

	take_damage(var/damage_amount = 5, var/mob/user as mob)
		return


/obj/item/lotteryTicket
	name = "Lottery Ticket"
	desc = "A winning lottery ticket perhaps...?"

	icon = 'icons/obj/writing.dmi'
	icon_state = "paper"

	w_class = W_CLASS_TINY

	// 4 numbers between 1 and 3 gives a one in 81 chance of winning. It's 3^4 possible combinations.
	var/list/numbers = new/list(4)
	// Lottery rounds
	var/lotteryRound = 0
	// If this ticket is a winner!
	var/winner = 0

	// Give a random set of numbers
	New()
		..()
		START_TRACKING

		lotteryRound = wagesystem.lotteryRound

		name = "Lottery Ticket. Round [lotteryRound]"

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
