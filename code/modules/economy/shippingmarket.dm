#define SUPPLY_OPEN_TIME 1 SECOND //Time it takes to open supply door in seconds.
#define SUPPLY_CLOSE_TIME 15 SECONDS //Time it takes to close supply door in seconds.

/datum/shipping_market

	var/list/commodities = list()
	var/time_between_shifts = 0.0
	var/time_until_shift = 0.0
	var/demand_multiplier = 2
	var/list/active_traders = list()
	var/max_buy_items_at_once = 99
	var/last_market_update = 0

	var/list/supply_requests = list() // Pending requests, of type /datum/supply_order
	var/list/supply_history = list() // History of all approved requests, of type string

	var/points_per_crate = 10

	var/artifact_resupply_amount = 0 // amount of artifacts in next resupply crate

	var/list/datum/special_order/active_orders

	New()
		..()

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
			src.time_until_shift = ticker.round_elapsed_ticks + time_between_shifts + rand(-900,900)
			market_shift()
			return 0

		return timeleft

	// Returns the time, in MM:SS format
	proc/get_market_timeleft()
		var/timeleft = src.timeleft() / 10
		if(timeleft)
			return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"

	proc/market_shift()
		last_market_update = world.timeofday

		// Chance of a commodity being hot. Sometimes the market is on fire.
		// Sometimes it is not. They still have to have a positive value roll,
		// so on average the % chance is actually about ~half this value.
		var/hot_chance = rand(10, 33)

		for (var/type in src.commodities)
			var/datum/commodity/C = src.commodities[type]

			// First, get the basic RNG roll. Why -90 to 90? Well, because...
			var/modifier_roll = rand(-900, 900) / 10
			// ...we feed it into cos(x). -90 ... 0 ... 90 = 0 ... 1 ... 0
			// Then we subtract it from 1, so that roll=0 -> 0, roll=90 = 1
			var/price_mod = 1 - cos(modifier_roll)

			// All prices are initially based off of the base price.
			// Previously it was based off of the PREVIOUS price, which
			// could end up making certain commodies skyrocket to absurd
			// levels, or outright crash to literally worthless.
			// The price is then adjusted by either upperfluc or lowerfluc,
			// based on the roll and modifier above.
			var/price_adjust = C.baseprice
			if (modifier_roll >= 0)
				// Good rolls adjust based on the upper fluctuation...
				price_adjust += C.upperfluc * price_mod
			else
				// ... and bad rolls adjust on the lower one.
				price_adjust += C.lowerfluc * price_mod

			C.price = price_adjust

			// At this point, the price is (hopefully) roughly on this
			// unfortunately upside-down scale of probabilities:
			//   |                                 | | v rare
			//    -                               -  |
			//     -_                           _-   | rare
			//       --___                 ___--     |
			//            ----____|____----          | common
			// lowerfluc      baseprice        upperfluc

			// This means that the price will always be between
			// (baseprice - abs(lowerfluc)) and (baseprice + upperfluc),
			// tending to land closer to the middle of the range.

			// If we had a good roll (> 0), roll a chance to make this
			// item Hot™! Hot items get a bigger bonus to their current value,
			// which is just pure random inflation.
			C.indemand = 0
			if (modifier_roll > 0 && prob(hot_chance))
				// shit is on FIYAH! SELL SELL SELL!!
				// Hot prices are marked up by +50% to +200%.
				// This might be a bit much, but compensating for some of the
				// commodities that achieved stupidly inflated prices in the
				// old system. Can be adjusted down later if need be.
				C.indemand = 1
				C.price *= rand(150, 300) / 100

			// If (somehow) a price manages to become negative, make it
			// zero again so you aren't charged for disposing of it.
			// (comedy option: actual trash should cost money to dispose of.)
			// (please only do this when something that can recycle
			//  the crusher's scraps exist.)
			// We also strip off any weird decimals because it is 2053
			// and the penny has been abolished, along with all other coins.
			C.price = max(round(C.price), 0)


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

	proc/sell_artifact(obj/sell_art, var/datum/artifact/sell_art_datum)
		var/price = 0
		var/modifier = sell_art_datum.get_rarity_modifier()

		// calculate price
		price = modifier*modifier * 10000
		var/obj/item/sticker/postit/artifact_paper/pap = locate(/obj/item/sticker/postit/artifact_paper/) in sell_art.vis_contents
		if(pap?.lastAnalysis)
			price *= pap.lastAnalysis
		price += rand(-50,50)
		price = round(price, 5)

		// track score
		if(pap)
			score_tracker.artifacts_analyzed++
		if(pap?.lastAnalysis >= 3)
			score_tracker.artifacts_correctly_analyzed++

		// send artifact resupply
		if(prob(modifier*40*pap?.lastAnalysis)) // range from 0% to ~78% for fully researched t4 artifact
			if(!src.artifact_resupply_amount)
				SPAWN_DBG(rand(1,5) MINUTES)
					// message
					var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
					var/datum/signal/pdaSignal = get_free_signal()
					pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(MGD_CARGO, MGD_SCIENCE), "sender"="00000000", "message"="Notification: Incoming artifact resupply crate. ([artifact_resupply_amount] objects)")
					pdaSignal.transmission_method = TRANSMISSION_RADIO
					if(transmit_connection != null)
						transmit_connection.post_signal(null, pdaSignal)
					// actual shipment
					var/obj/storage/crate/artcrate = new /obj/storage/crate()
					artcrate.name = "Artifact Resupply Crate"
					for(var/i = 0 to artifact_resupply_amount)
						new /obj/artifact_type_spawner/vurdalak(artcrate)
					artifact_resupply_amount = 0
					shippingmarket.receive_crate(artcrate)
			src.artifact_resupply_amount++

		// sell
		wagesystem.shipping_budget += price
		qdel(sell_art)

		// give PDA group messages
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		var/message = "Notification: [price] credits earned from outgoing artifact \'[sell_art.name]\'. "
		if(pap)
			message += "Analysis was [(pap.lastAnalysis/3)*100]% correct."
		else
			message += "Artifact was not analyzed."
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(MGD_CARGO, MGD_SCIENCE, MGA_SALES), "sender"="00000000", "message"=message)
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(null, pdaSignal)

	// Returns value of whatever the list of objects would sell for
	proc/appraise_value(var/list/obj/items, var/list/commodities_list, var/sell = 1)

		// TODO: Does this handle common containers like satchels?
		// If not, maybe they should?
		// Maybe some way to send them through mail chutes without
		// dumping the contents out would be good

		var/duckets = 0  // fuck yeah duckets  ((noun) Cash, money or bills, from "ducats")
		var/add = 0
		if (!commodities_list)
			for(var/obj/O in items)
				for (var/C in src.commodities) // Key is type of the commodity
					var/datum/commodity/CM = commodities[C]
					if (istype(O, CM.comtype))
						add = CM.price
						if (CM.indemand)
							add *= shippingmarket.demand_multiplier
						if (istype(O, /obj/item/raw_material) || istype(O, /obj/item/sheet) || istype(O, /obj/item/material_piece) || istype(O, /obj/item/plant) || istype(O, /obj/item/reagent_containers/food/snacks/plant))
							add *= O:amount // TODO: fix for snacks
							if (sell)
								pool(O)
						else
							if (sell)
								qdel(O)
						duckets += add
						break
					else if (istype(O, /obj/item/spacecash))
						duckets += 0.9 * O:amount
						if (sell)
							pool(O)
		else // Please excuse this duplicate code, I'm gonna change trader commodity lists into associative ones later I swear
			for(var/obj/O in items)
				for (var/datum/commodity/C in commodities_list)
					if (istype(O, C.comtype))
						add = C.price
						if (C.indemand)
							add *= shippingmarket.demand_multiplier
						if (istype(O, /obj/item/raw_material) || istype(O, /obj/item/sheet) || istype(O, /obj/item/material_piece) || istype(O, /obj/item/plant) || istype(O, /obj/item/reagent_containers/food/snacks/plant))
							add *= O:amount // TODO: fix for snacks
							if (sell)
								pool(O)
						else
							if (sell)
								qdel(O)
						duckets += add
						break
					else if (istype(O, /obj/item/spacecash))
						duckets += O:amount
						if (sell)
							pool(O)

		return duckets

	proc/sell_crate(obj/storage/crate/sell_crate, var/list/commodities_list)
		var/obj/item/card/id/scan = sell_crate.scan
		var/datum/data/record/account = sell_crate.account
		var/duckets

		if(length(active_orders))
			for(var/datum/special_order/order in active_orders)
				if(order.check_order(sell_crate))
					duckets += order.price
					active_orders -= order

		duckets += src.appraise_value(sell_crate, commodities_list, 1) + src.points_per_crate


		#ifdef SECRETS_ENABLED
		send_to_brazil(sell_crate)
		#endif

		qdel(sell_crate)

		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		if(scan && account)
			wagesystem.shipping_budget += duckets / 2
			account.fields["current_money"] += duckets / 2
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(MGD_CARGO, MGA_SALES), "sender"="00000000", "message"="Notification: [duckets] credits earned from last outgoing shipment. Splitting half of profits with [scan.registered].")
		else
			wagesystem.shipping_budget += duckets
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(MGD_CARGO, MGA_SALES), "sender"="00000000", "message"="Notification: [duckets] credits earned from last outgoing shipment.")

		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(null, pdaSignal)

	proc/receive_crate(atom/movable/shipped_thing)

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

		shipped_thing.set_loc(spawnpoint)

		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT", "group"=list(MGD_CARGO, MGA_SHIPPING), "sender"="00000000", "message"="Shipment arriving to Cargo Bay: [shipped_thing.name].")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		transmit_connection.post_signal(null, pdaSignal)



		for(var/obj/machinery/door/poddoor/P in by_type[/obj/machinery/door])
			if (P.id == "qm_dock")
				playsound(P.loc, "sound/machines/bellalert.ogg", 50, 0)
				SPAWN_DBG(SUPPLY_OPEN_TIME)
					if (P?.density)
						P.open()
				SPAWN_DBG(SUPPLY_CLOSE_TIME)
					if (P && !P.density)
						P.close()

		shipped_thing.throw_at(target, 100, 1)

	proc/clear_path_to_market()
		var/list/bounds = get_area_turfs(/area/supply/delivery_point)
		bounds += get_area_turfs(/area/supply/sell_point)
		bounds += get_area_turfs(/area/supply/spawn_point)
		var/min_x = INFINITY
		var/max_x = 0
		var/min_y = INFINITY
		var/max_y = 0
		for(var/turf/boundry as anything in bounds)
			min_x = min(min_x, boundry.x)
			min_y = min(min_y, boundry.y)
			max_x = max(max_x, boundry.x)
			max_y = max(max_y, boundry.y)

		var/list/turf/to_clear = block(locate(min_x, min_y, Z_LEVEL_STATION), locate(max_x, max_y, Z_LEVEL_STATION))
		for(var/turf/T as anything in to_clear)
			//Wacks asteroids and skip normal turfs that belong
			if(istype(T, /turf/simulated/wall/asteroid))
				T.ReplaceWith(/turf/simulated/floor/plating/airless/asteroid, force=TRUE)
				continue
			else if(!istype(T, /turf/unsimulated))
				continue

			//Uh, make sure we don't block the shipping lanes!
			for(var/atom/A in T)
				if(A.density)
					qdel(A)


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
