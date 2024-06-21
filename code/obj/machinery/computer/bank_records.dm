/obj/machinery/computer/bank_data
	name = "bank records"
	icon_state = "databank"
	req_access = list(access_money)
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
				boutput(user, SPAN_NOTICE("You insert [I] into the authentication card slot."))
				user.drop_item()
				I.set_loc(src)
				src.scan = I
			else
				boutput(user, SPAN_NOTICE("There is already a card inserted."))

		else
			..()

	attack_hand(mob/user)
		if(..())
			return
		var/list/dat = list()
		if (src.temp)
			dat += text("<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>")
		else
			var/total_funds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
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
					</tbody>
				</table>
				"}

			if (src.authenticated)
				var/payroll = 0
				for(var/datum/db_record/R as anything in data_core.bank.records)
					payroll += R["wage"]
				var/surplus = round(wagesystem.payroll_stipend - payroll)

				dat += {"
				<table>
					<thead>
					<tr><th colspan="2" class='second'>Payroll Details</th></tr></thead>
					<tbody>
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
						boutput(usr, SPAN_ALERT("You cannot set a negative wage."))
					if (!t1) t1 = 0
					if (t1 > 10000)
						t1 = 10000
						boutput(usr, SPAN_ALERT("Maximum wage is 10,000[CREDIT_SIGN]."))
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
							boutput(usr, SPAN_ALERT("This account cannot currently be liquidated due to active borrows."))
							return
						avail = R["current_money"]
						if (t1 > avail) t1 = avail
						if (t1 < 1) return
						R["current_money"] -= t1
						wagesystem.station_budget += t1
						logTheThing(LOG_STATION, usr, "adds [t1][CREDIT_SIGN] to the station budget from <b>[R["name"]]</b>'s account.")
						boutput(usr, SPAN_NOTICE("[t1][CREDIT_SIGN] added to station budget from [R["name"]]'s account."))
					else if (t2 == "Deposit")
						avail = wagesystem.station_budget
						if (t1 > avail) t1 = avail
						if (t1 < 1) return
						R["current_money"] += t1
						wagesystem.station_budget -= t1
						logTheThing(LOG_STATION, usr, "adds [t1][CREDIT_SIGN] to <b>[R["name"]]</b>'s account from the station budget.")
						boutput(usr, SPAN_NOTICE("[t1][CREDIT_SIGN] added to [R["name"]]'s account from station budget."))
					else boutput(usr, SPAN_ALERT("Error selecting withdraw/deposit mode."))
				else if(href_list["payroll"])
					if(world.time >= src.payroll_rate_limit_time)
						src.payroll_rate_limit_time = world.time + (10 SECONDS)
					else //slow the fuck down cowboy
						boutput(usr, SPAN_ALERT("Nanotrasen policy forbids the modification station payroll status more than once every ten seconds!"))
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
						boutput(usr, SPAN_ALERT("Error selecting budget to transfer from."))
						return
					var/transto = input("Transfer to which?", "Budgeting", null, null) in list("Payroll", "Shipping", "Research")
					if (!transto)
						boutput(usr, SPAN_ALERT("Error selecting budget to transfer to."))
						return
					if (transfrom == transto)
						boutput(usr, SPAN_ALERT("You can't transfer a budget into itself."))
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
