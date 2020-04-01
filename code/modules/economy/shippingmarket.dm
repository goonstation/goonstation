/datum/shipping_market

	var/list/commodities = new/list()
	var/time_between_shifts = 0.0
	var/time_until_shift = 0.0
	var/demand_multiplier = 2
	var/list/active_traders = new/list()
	var/max_buy_items_at_once = 20
	var/last_market_update = 0

	New()
		add_commodity(new /datum/commodity/produce(src))
		add_commodity(new /datum/commodity/meat(src))
		add_commodity(new /datum/commodity/herbs(src))
		add_commodity(new /datum/commodity/honey(src))
		add_commodity(new /datum/commodity/sheet(src))
		add_commodity(new /datum/commodity/robotics(src))
		add_commodity(new /datum/commodity/electronics(src))
		add_commodity(new /datum/commodity/ore/mauxite(src))
		add_commodity(new /datum/commodity/ore/pharosium(src))
		add_commodity(new /datum/commodity/ore/molitz(src))
		add_commodity(new /datum/commodity/ore/char(src))
		add_commodity(new /datum/commodity/ore/cobryl(src))
		add_commodity(new /datum/commodity/ore/bohrum(src))
		add_commodity(new /datum/commodity/ore/claretine(src))
		add_commodity(new /datum/commodity/ore/erebite(src))
		add_commodity(new /datum/commodity/ore/cerenkite(src))
		add_commodity(new /datum/commodity/ore/plasmastone(src))
		add_commodity(new /datum/commodity/ore/syreline(src))
		add_commodity(new /datum/commodity/ore/uqill(src))
		add_commodity(new /datum/commodity/ore/telecrystal(src))
		add_commodity(new /datum/commodity/ore/fibrilith(src))
		add_commodity(new /datum/commodity/synthmodule(src))
		add_commodity(new /datum/commodity/goldbar(src))

		var/list/unique_traders = list(/datum/trader/gragg,/datum/trader/josh,/datum/trader/pianzi_hundan,
		/datum/trader/vurdalak,/datum/trader/buford)

		var/total_unique_traders = 5
		while(total_unique_traders > 0)
			total_unique_traders--
			var/the_trader = pick(unique_traders)
			src.active_traders += new the_trader(src)
			unique_traders -= the_trader

		src.active_traders += new /datum/trader/generic(src)
		src.active_traders += new /datum/trader/generic(src)

		time_between_shifts = 6000 // 10 minutes
		time_until_shift = time_between_shifts + rand(-900,1200)

	proc/add_commodity(var/datum/commodity/new_c)
		src.commodities["[new_c.comtype]"] = new_c

	proc/timeleft()
		var/timeleft = src.time_until_shift - ticker.round_elapsed_ticks

		if(timeleft <= 0)
			market_shift()
			src.time_until_shift =ticker.round_elapsed_ticks + time_between_shifts + rand(-900,900)
			return 0

		return timeleft

	//Returns the time, in MM:SS format
	proc/get_market_timeleft()
		var/timeleft = src.timeleft() / 10
		if(timeleft)
			return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"

	proc/market_shift()
		last_market_update = world.timeofday
		for (var/type in src.commodities)
			var/datum/commodity/C = src.commodities[type]
			C.indemand = 0
			// Clear current in-demand products so we can set new ones later
			if (prob(90))
				C.price += rand(C.lowerfluc,C.upperfluc)
				// Most of the time price fluctuates normally
			else
				var/multiplier = rand(2,4)
				C.price += rand(C.lowerfluc * multiplier,C.upperfluc * multiplier)
				// Sometimes it goes apeshit though!
			if (C.price < 0)
				C.price = 0
				// No point in paying centcom to take your goods away
			if (prob(5))
				C.price = C.baseprice
				// Small chance of a price being sent back to its original value

		if (prob(3))
			src.demand_multiplier = rand(2,4)
			// Small chance of the multiplier of in-demand items being altered
		var/demands = rand(2,4)
		// How many goods are going to be in demand this time?
		while(demands > 0)
			var/datum/commodity/D = src.commodities[pick(src.commodities)]
			if (D.price > 0)
				D.indemand = 1
				// Goods that are in demand sell for a multiplied price
			demands--

		// Shuffle trader visibility around a bit
		for (var/datum/trader/T in src.active_traders)
			if (T.hidden)
				if (prob(T.chance_arrive))
					T.hidden = 0
					T.current_message = pick(T.dialogue_greet)
					T.patience = rand(T.base_patience[1],T.base_patience[2])
					T.set_up_goods()
			else
				if (prob(T.chance_leave))
					T.hidden = 1

		SPAWN_DBG(5 SECONDS)
			// 20% chance to shuffle out generic traders for a new one
			// Do this after a short delay so QMs can finish any last-second deals
			var/removed_count = 0
			for (var/datum/trader/generic/GT in src.active_traders)
				if (prob(20))
					src.active_traders -= GT
					removed_count++

			while(removed_count > 0)
				removed_count--
				src.active_traders += new /datum/trader/generic(src)

// Debugging and admin verbs (mostly coder)

/client/proc/cmd_modify_market_variables()
	set category = "Debug"
	set name = "Edit Market Variables"


	if (shippingmarket == null) boutput(src, "UH OH!")
	else src.debug_variables(shippingmarket)

/client/proc/BK_finance_debug()
	set category = "Debug"
	set name = "Financial Info"
	set desc = "Shows budget variables and current market prices."

	var/payroll = 0
	var/totalfunds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
	for(var/datum/data/record/R in data_core.bank)
		payroll += R.fields["wage"]

	var/dat = {"<B>Budget Variables:</B>
	<BR><BR><u><b>Total Station Funds:</b> $[num2text(totalfunds,50)]</u>
	<BR>
	<BR><b>Current Payroll Budget:</b> $[num2text(wagesystem.station_budget,50)]
	<BR><b>Current Research Budget:</b> $[num2text(wagesystem.research_budget,50)]
	<BR><b>Current Shipping Budget:</b> $[num2text(wagesystem.shipping_budget,50)]
	<BR>
	<b>Current Payroll Cost:</b> $[payroll]<HR>"}

	dat += "Shipping Market Prices<BR><BR>"
	for(var/item_type in shippingmarket.commodities)
		var/datum/commodity/C = shippingmarket.commodities[item_type]
		var/viewprice = C.price
		if (C.indemand) viewprice *= shippingmarket.demand_multiplier
		dat += "<BR><B>[C.comname]:</B> $[viewprice] per unit "
		if (C.indemand) dat += " <b>(High Demand!)</b>"
	var/timer = shippingmarket.get_market_timeleft()
	dat += "<BR><HR><b>Next Price Shift:</B> [timer]<BR>"
	dat += "Last updated: [shippingmarket.last_market_update]<BR>"

	dat += "<BR><BR><HR><b>Lottery</b><BR><BR>Current Jackpot = [wagesystem.lotteryJackpot] <BR>"
	dat += "Current Round = [wagesystem.lotteryRound] <BR>"

	dat += "List of rounds and their numbers:"
	for(var/j = 1, j < wagesystem.lotteryRound + 1, j++)
		dat += "<BR>Round [j]: "
		for(var/i = 1, i < 5, i++)
			dat += "[wagesystem.winningNumbers[i][j]] "

	usr.Browse(dat, "window=budgetdebug;size=400x400")

/client/proc/BK_alter_funds()
	set category = "Debug"
	set name = "Alter Budget"
	set desc = "Add to or subtract from a budget."

	var/trans = input("Which budget?", "Budgeting", null, null) in list("Payroll", "Shipping", "Research")
	if (!trans) return

	var/amount = input(usr, "How much?", "Funds", 0) as null|num
	if (!amount) return

	switch(trans)
		if("Payroll")
			wagesystem.station_budget += amount
			if (wagesystem.station_budget < 0) wagesystem.station_budget = 0
		if("Shipping")
			wagesystem.shipping_budget += amount
			if (wagesystem.shipping_budget < 0) wagesystem.shipping_budget = 0
		if("Research")
			wagesystem.research_budget += amount
			if (wagesystem.research_budget < 0) wagesystem.research_budget = 0
		else
			boutput(usr, "<span style=\"color:red\">Whatever you did, it didn't work.</span>")
			return
