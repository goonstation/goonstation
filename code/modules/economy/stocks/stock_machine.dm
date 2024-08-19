/obj/machinery/computer/stockexchange
	name = "stock exchange"
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMreq"
	var/logged_in = null
	var/vmode = 0
	deconstruct_flags = DECON_MULTITOOL
	light_r =1
	light_g = 0.7
	light_b = 0.03
	circuit_type = /obj/item/circuitboard/stockexchange

/obj/machinery/computer/stockexchange/proc/balance()
	if (!logged_in)
		return 0
	var/datum/db_record/B = FindBankAccountByName(logged_in)
	if (B)
		return B["current_money"]
	return "--- account not found ---"

/obj/machinery/computer/stockexchange/attack_hand(mob/user)
	if(..())
		return
	src.add_dialog(user)

	var/css={"<style>
						.company {
							font-weight: bold;
						}
						.stable {
							width: 100%
							border: 1px solid black;
							border-collapse: collapse;
						}
						.stable tr {
							border: none;
						}
						.stable td, .stable th {
							border-right: 1px solid white;
							border-bottom: 1px solid black;
						}
						a.updated {
							color: red;
						}
						</style>"}
	var/dat = "<html><head><title>[station_name()] Stock Exchange</title>[css]</head><body><h2>Stock Exchange</h2>"
	dat += "<i>This is a work in progress. Certain features may not be available.</i><br>"

	if (!logged_in)
		dat += "<span class='user'>Welcome, <b>NT_Guest</b></span><br>"
	else
		dat += "<span class='user'>Welcome, <b>[logged_in]</b></span> <a href='?src=\ref[src];logout=1'>Log out</a><br><span class='balance'><b>Your account balance:</b> [balance()] credits</span><br>"
		for (var/datum/stock/ticker/S in stockExchange.last_read)
			var/list/LR = stockExchange.last_read[S]
			if (!(logged_in in LR))
				LR[logged_in] = 0
	dat += "<b>View mode:</b> <a href='?src=\ref[src];cycleview=1'>[vmode ? "compact" : "full"]</a>"

	dat += "<h3>Listed stocks</h3>"

	if (vmode == 0)
		for (var/datum/stock/ticker/S as anything in stockExchange.stocks)
			var/mystocks = 0
			if (logged_in && (logged_in in S.shareholders))
				mystocks = S.shareholders[logged_in]
			dat += "<hr /><div class='stock'><span class='company'>[S.name]</span> <span class='s_company'>([S.short_name])</span>[S.bankrupt ? " <b style='color:red'>BANKRUPT</b>" : null]<br>"
			if (S.last_unification)
				dat += "<b>Unified shares</b> [(ticker.round_elapsed_ticks - S.last_unification) / 600] minutes ago.<br>"
			dat += "<b>Current value per share:</b> [S.current_value] | <a href='?src=\ref[src];viewhistory=\ref[S]'>View history</a><br><br>"
			dat += "You currently own <b>[mystocks]</b> shares in this company. There are [S.available_shares] purchasable shares on the market currently.<br>"
			if (S.bankrupt)
				dat += "You cannot buy or sell shares in a bankrupt company!<br><br>"
			else
				dat += "<a href='?src=\ref[src];buyshares=\ref[S]'>Buy shares</a> | <a href='?src=\ref[src];sellshares=\ref[S]'>Sell shares</a><br><br>"
			dat += "<b>Prominent products:</b><br>"
			for (var/prod in S.products)
				dat += "<i>[prod]</i><br>"
			dat += "<br><b>Borrow options:</b><br>"
			if (S.borrow_brokers.len)
				for (var/datum/stock/borrow/B in S.borrow_brokers)
					dat += "<b>[B.broker]</b> offers <i>[B.share_amount] shares</i> for borrowing, for a deposit of <i>[B.deposit * 100]%</i> of the shares' value.<br>"
					dat += "The broker expects the return of the shares after <i>[B.lease_time / 600] minutes</i>, with a grace period of <i>[B.grace_time / 600]</i> minute(s).<br>"
					dat += "<i>This offer expires in [(B.offer_expires - ticker.round_elapsed_ticks) / 600] minutes.</i><br>"
					dat += "<b>Note:</b> If you do not return all shares by the end of the grace period, you will lose your deposit and the value of all unreturned shares at current value from your account!<br>"
					dat += "<b>Note:</b> You cannot withdraw or transfer money off your account while a borrow is active.<br>"
					dat += "<a href='?src=\ref[src];take=\ref[B]'>Take offer</a> (Estimated deposit: [B.deposit * S.current_value * B.share_amount] credits)<br><br>"
			else
				dat += "<i>No borrow options available</i><br><br>"
			for (var/datum/stock/borrow/B in S.borrows)
				if (B.borrower == logged_in)
					dat += "You are borrowing <i>[B.share_amount] shares</i> from <b>[B.broker]</b>.<br>"
					dat += "Your deposit riding on the deal is <i>[B.deposit] credits</i>.<br>"
					if (ticker.round_elapsed_ticks < B.lease_expires)
						dat += "You are expected to return the borrowed shares in [(B.lease_expires - ticker.round_elapsed_ticks) / 600] minutes.<br><br>"
					else
						dat += "The brokering agency is collecting. You still owe them <i>[B.share_debt]</i> shares, which you have [(B.grace_expires - ticker.round_elapsed_ticks) / 600] minutes to present.<br><br>"
			var/news = 0
			if (logged_in)
				var/list/LR = stockExchange.last_read[S]
				var/lrt = LR[logged_in]
				for (var/datum/stock/article/A as anything in S.articles)
					if (A.ticks > lrt)
						news = 1
						break
				if (!news)
					for (var/datum/stock/event/E as anything in S.events)
						if (E.last_change > lrt && !E.hidden)
							news = 1
							break
			dat += "<a href='?src=\ref[src];archive=\ref[S]'>View news archives</a>[news ? " <span style='color:red'>(updated)</span>" : null]</div>"
	else if (vmode == 1)
		dat += "<b>Actions:</b> + Buy, - Sell, (A)rchives, (H)istory<br><br>"
		dat += "<table class='stable'><tr><th>&nbsp;</th><th>Name</th><th>Value</th><th>Owned/Avail</th><th>Actions</th></tr>"
		for (var/datum/stock/ticker/S as anything in stockExchange.stocks)
			var/mystocks = 0
			if (logged_in && (logged_in in S.shareholders))
				mystocks = S.shareholders[logged_in]
			dat += "<tr><td>[S.disp_value_change > 0 ? "+" : (S.disp_value_change < 0 ? "-" : "=")]</td><td><span class='company'>[S.name] "
			if (S.bankrupt)
				dat += "<b style='color:red'>B</b>"
			dat += "</span> <span class='s_company'>([S.short_name])</span></td><td>[S.current_value]</td><td><b>[mystocks]</b>/[S.available_shares]</td>"
			var/news = 0
			if (logged_in)
				var/list/LR = stockExchange.last_read[S]
				var/lrt = LR[logged_in]
				for (var/datum/stock/article/A as anything in S.articles)
					if (A.ticks > lrt)
						news = 1
						break
				if (!news)
					for (var/datum/stock/event/E as anything in S.events)
						if (E.last_change > lrt && !E.hidden)
							news = 1
							break
			dat += "<td>"
			if (S.bankrupt)
				dat += "+ - "
			else
				dat += "<a href='?src=\ref[src];buyshares=\ref[S]'>+</a> <a href='?src=\ref[src];sellshares=\ref[S]'>-</a> "
			dat += "<a href='?src=\ref[src];archive=\ref[S]' class='[news ? "updated" : "default"]'>(A)</a> <a href='?src=\ref[src];viewhistory=\ref[S]'>(H)</a></td></tr>"

	dat += "</body></html>"
	user.Browse(dat, "window=computer;size=600x400")
	onclose(user, "computer")
	return

/obj/machinery/computer/stockexchange/attackby(obj/item/I, mob/user)
	var/obj/item/card/id/ID = get_id_card(I)
	if (istype(ID))
		boutput(user, SPAN_NOTICE("You swipe the ID card."))
		var/datum/db_record/account = null
		account = FindBankAccountByName(ID.registered)
		if(account)
			var/enterpin = user.enter_pin("Stock Exchange")
			if (enterpin == ID.pin)
				boutput(user, SPAN_NOTICE("Card authorized."))
				src.logged_in = ID.registered
			else
				boutput(user, SPAN_ALERT("PIN incorrect."))
				src.logged_in = null
		else
			boutput(user, SPAN_ALERT("No bank account associated with this ID found."))
			src.logged_in = null
	else ..()
	return

/obj/machinery/computer/stockexchange/proc/sell_some_shares(datum/stock/ticker/S, mob/user)
	if (!user || !S)
		return
	var/li = logged_in
	if (!li)
		boutput(user, SPAN_ALERT("No active account on the console!"))
		return
	var/b = balance()
	if (!isnum(b))
		boutput(user, SPAN_ALERT("No active account on the console!"))
		return
	var/avail = S.shareholders[logged_in]
	if (!avail)
		boutput(user, SPAN_ALERT("This account does not own any shares of [S.name]!"))
		return
	var/price = S.current_value
	var/amt = round(input(user, "How many shares? (Have: [avail], unit price: [price])", "Sell shares in [S.name]", 0) as num|null)
	if (!user)
		return
	if (!isnum_safe(amt))
		return
	if (!(user in range(1, src)))
		return
	if (li != logged_in)
		return
	b = balance()
	if (!isnum(b))
		boutput(user, SPAN_ALERT("No active account on the console!"))
		return
	if (amt > S.shareholders[logged_in])
		boutput(user, SPAN_ALERT("You do not own that many shares!"))
		return
	var/total = amt * S.current_value
	if (!S.sellShares(logged_in, amt))
		boutput(user, SPAN_ALERT("Could not complete transaction."))
		return
	boutput(user, SPAN_NOTICE("Sold [amt] shares of [S.name] for [total] credits."))

/obj/machinery/computer/stockexchange/proc/buy_some_shares(datum/stock/ticker/S, mob/user)
	if (!user || !S)
		return
	var/li = logged_in
	if (!li)
		boutput(user, SPAN_ALERT("No active account on the console!"))
		return
	var/b = balance()
	if (!isnum(b))
		boutput(user, SPAN_ALERT("No active account on the console!"))
		return
	var/avail = S.available_shares
	var/price = S.current_value
	var/canbuy = round(b / price)
	var/amt = round(input(user, "How many shares? (Available: [avail], unit price: [price], can buy: [canbuy])", "Buy shares in [S.name]", 0) as num|null)
	if (!user)
		return
	if (!isnum_safe(amt))
		return
	if (!(user in range(1, src)))
		return
	if (li != logged_in)
		return
	b = balance()
	if (!isnum(b))
		boutput(user, SPAN_ALERT("No active account on the console!"))
		return
	if (amt > S.available_shares)
		boutput(user, SPAN_ALERT("That many shares are not available!"))
		return
	var/total = amt * S.current_value
	if (total > b)
		boutput(user, SPAN_ALERT("Insufficient funds."))
		return
	if (!S.buyShares(logged_in, amt))
		boutput(user, SPAN_ALERT("Could not complete transaction."))
		return
	boutput(user, SPAN_NOTICE("Bought [amt] shares of [S.name] for [total] credits."))

/obj/machinery/computer/stockexchange/proc/do_borrowing_deal(datum/stock/borrow/B, mob/user)
	if (B.stock.borrow(B, logged_in))
		boutput(user, SPAN_NOTICE("You successfully borrowed [B.share_amount] shares. Deposit: [B.deposit]."))
	else
		boutput(user, SPAN_ALERT("Could not complete transaction. Check your account balance."))

/obj/machinery/computer/stockexchange/Topic(href, href_list)
	if (..())
		return 1

	if (usr in range(1, src))
		src.add_dialog(usr)

	if (href_list["viewhistory"])
		var/datum/stock/ticker/S = locate(href_list["viewhistory"])
		if (S)
			S.displayValues(usr)

	if (href_list["logout"])
		logged_in = null

	if (href_list["buyshares"])
		var/datum/stock/ticker/S = locate(href_list["buyshares"])
		if (S)
			buy_some_shares(S, usr)

	if (href_list["sellshares"])
		var/datum/stock/ticker/S = locate(href_list["sellshares"])
		if (S)
			sell_some_shares(S, usr)

	if (href_list["take"])
		var/datum/stock/borrow/B = locate(href_list["take"])
		if (B && !B.lease_expires)
			do_borrowing_deal(B, usr)

	if (href_list["archive"])
		var/datum/stock/ticker/S = locate(href_list["archive"])
		if (logged_in && logged_in != "")
			var/list/LR = stockExchange.last_read[S]
			LR[logged_in] = ticker.round_elapsed_ticks
		var/dat = "<html><head><title>News feed for [S.name]</title></head><body><h2>News feed for [S.name]</h2><div><a href='?src=\ref[src];archive=\ref[S]'>Refresh</a></div>"
		dat += "<div><h3>Events</h3>"
		var/p = 0
		for (var/datum/stock/event/E as anything in S.events)
			if (E.hidden)
				continue
			if (p > 0)
				dat += "<hr>"
			dat += "<div><b style='font-size:1.25em'>[E.current_title]</b><br>[E.current_desc]</div>"
			p++
		dat += "</div><hr><div><h3>Articles</h3>"
		p = 0
		for (var/datum/stock/article/A as anything in S.articles)
			if (p > 0)
				dat += "<hr>"
			dat += "<div><b style='font-size:1.25em'>[A.headline]</b><br><i>[A.subtitle]</i><br><br>[A.article]<br>- [A.author], [A.spacetime] (via <i>[A.outlet]</i>)</div>"
			p++
		dat += "</div></body></html>"
		usr.Browse(dat, "window=archive_[S.name];size=600x400")

	if (href_list["cycleview"])
		vmode++
		if (vmode > 1)
			vmode = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
