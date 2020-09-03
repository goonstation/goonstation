#define SUPPLY_OPEN_TIME 1 SECOND //Time it takes to open supply door in seconds.
#define SUPPLY_CLOSE_TIME 13 SECONDS //Time it takes to close supply door in seconds.

/datum/shipping_market

	var/list/commodities = list()
	var/time_between_shifts = 0.0
	var/time_until_shift = 0.0
	var/demand_multiplier = 2
	var/list/active_traders = list()
	var/max_buy_items_at_once = 20
	var/last_market_update = 0

	var/list/supply_requests = list() // Pending requests, of type /datum/supply_order
	var/list/supply_history = list() // History of all approved requests, of type string

	var/points_per_crate = 10

	New()

		add_commodity(new /datum/commodity/goldbar(src))

		for (var/commodity_path in (typesof(/datum/commodity) - /datum/commodity/goldbar))
			var/datum/commodity/C = new commodity_path(src)
			if(C.onmarket)
				add_commodity(C)
			else
				qdel(C)

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

	// Returns the time, in MM:SS format
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

	proc/sell_crate(obj/storage/crate/sell_crate, var/list/commodities_list)
		var/obj/item/card/id/scan = sell_crate.scan
		var/datum/data/record/account = sell_crate.account

		var/duckets = src.points_per_crate  // fuck yeah duckets
		var/add = 0

		if (!commodities_list)
			for(var/obj/O in sell_crate.contents)
				for (var/C in src.commodities) // Key is type of the commodity
					var/datum/commodity/CM = commodities[C]
					if (istype(O, CM.comtype))
						add = CM.price
						if (CM.indemand)
							add *= shippingmarket.demand_multiplier
						if (istype(O, /obj/item/raw_material) || istype(O, /obj/item/material_piece) || istype(O, /obj/item/plant) || istype(O, /obj/item/reagent_containers/food/snacks/plant))
							add *= O:amount // TODO: fix for snacks
							pool(O)
						else
							qdel(O)
						duckets += add
						break
					else if (istype(O, /obj/item/spacecash))
						duckets += O:amount
						pool(O)
		else // Please excuse this duplicate code, I'm gonna change trader commodity lists into associative ones later I swear
			for(var/obj/O in sell_crate.contents)
				for (var/datum/commodity/C in commodities_list)
					if (istype(O, C.comtype))
						add = C.price
						if (C.indemand)
							add *= shippingmarket.demand_multiplier
						if (istype(O, /obj/item/raw_material) || istype(O, /obj/item/material_piece) || istype(O, /obj/item/plant) || istype(O, /obj/item/reagent_containers/food/snacks/plant))
							add *= O:amount // TODO: fix for snacks
							pool(O)
						else
							qdel(O)
						duckets += add
						break
					else if (istype(O, /obj/item/spacecash))
						duckets += O:amount
						pool(O)
		qdel(sell_crate)

		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		if(scan && account)
			wagesystem.shipping_budget += duckets / 2
			account.fields["current_money"] += duckets / 2
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=MGD_CARGO, "sender"="00000000", "message"="Notification: [duckets] credits earned from last outgoing shipment. Splitting half of profits with [scan.registered].")
		else
			wagesystem.shipping_budget += duckets
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=MGD_CARGO, "sender"="00000000", "message"="Notification: [duckets] credits earned from last outgoing shipment.")

		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(null, pdaSignal)

	proc/receive_crate(obj/storage/S)

		var/turf/spawnpoint
		for(var/turf/T in get_area_turfs(/area/supply/spawn_point))
			spawnpoint = T
			break

		var/turf/target
		for(var/turf/T in get_area_turfs(/area/supply/delivery_point))
			target = T
			break

		if (!spawnpoint)
			logTheThing("debug", null, null, "<b>Shipping: </b> No spawn turfs found! Can't deliver crate")
			return

		if (!target)
			logTheThing("debug", null, null, "<b>Shipping: </b> No target turfs found! Can't deliver crate")
			return

		S.set_loc(spawnpoint)

		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=MGD_CARGO, "sender"="00000000", "message"="Shipment arriving to Cargo Bay: [S.name].")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		transmit_connection.post_signal(null, pdaSignal)


#if ASS_JAM
		if(prob(5))
			var/list/turf/viable_turfs = get_area_turfs(/area/station/quartermaster/cargobay)
			if(!viable_turfs.len)
				viable_turfs = get_area_turfs(/area/station/quartermaster)
			if(viable_turfs.len)
				var/turf/ass_spawn = pick(viable_turfs)
				S.set_loc(ass_spawn)
				heavenly_spawn(S)
				return
#endif
		for(var/obj/machinery/door/poddoor/P in by_type[/obj/machinery/door])
			if (P.id == "qm_dock")
				playsound(P.loc, "sound/machines/bellalert.ogg", 50, 0)
				SPAWN_DBG(SUPPLY_OPEN_TIME)
					if (P && P.density)
						P.open()
				SPAWN_DBG(SUPPLY_CLOSE_TIME)
					if (P && !P.density)
						P.close()

		S.throw_at(target, 100, 1)

// Debugging and admin verbs (mostly coder)

/client/proc/cmd_modify_market_variables()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Edit Market Variables"

	if (shippingmarket == null) boutput(src, "UH OH!")
	else src.debug_variables(shippingmarket)

/client/proc/BK_finance_debug()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
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
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
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
			boutput(usr, "<span class='alert'>Whatever you did, it didn't work.</span>")
			return

#undef SUPPLY_OPEN_TIME
#undef SUPPLY_CLOSE_TIME
