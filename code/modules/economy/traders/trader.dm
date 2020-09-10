/datum/trader
	var/name = "trader"   // The name of the trader (duh)
	var/picture = "generic.png" // What they look like on comms
	var/crate_tag = "trader"    // What to label a crate if selling to them
	var/list/base_patience = list(0,0) // min and max patience for this trader
	var/patience = 0      // how many times you can haggle the price before they get pissed off and leave, randomise it
	var/hiketolerance = 20// if the haggled price hike is this % or greater of the current price, reject it
	var/hidden = 0              // Makes the trader not show up on the QM console
	var/chance_leave = 20       // Chance for a trader to go hidden during a market shift
	var/chance_arrive = 33      // Chance for a trader to stop hiding during a market shift
	var/asshole = 0 // will accept wrong-direction haggles

	// lists of commodity datums that the trader will buy or sell, and the cart
	// these are the base lists of commodities this trader will have
	var/list/base_goods_buy = list()
	var/list/base_goods_sell = list()
	// these are the max amount of entries the trader will have on each list
	var/max_goods_buy = 1
	var/max_goods_sell = 1
	// and these three are the active ones used for gameplay
	var/list/goods_buy = list()
	var/list/goods_sell = list()
	var/list/shopping_cart = list()

	var/current_message = "what"// draws from dialogue to display a message
	// dialogue banks
	var/list/dialogue_greet = list("Hello there. Care to take a look at my wares?")
	var/list/dialogue_leave = list("This is going nowhere. I'm outta here.")
	var/list/dialogue_purchase = list("Thank you for your purchase! Your goods should arrive shortly.")
	var/list/dialogue_haggle_accept = list("Alright, how's this sound?",
	"You drive a hard bargain. How's this price?",
	"You're busting my balls here. How's this?",
	"I'm being more than generous here, I think you'll agree.",
	"This is my final offer. Can't do better than this.")
	var/list/dialogue_haggle_reject = list("No way. That's too much of a stretch.",
	"You're kidding, right?",
	"That's just not reasonable.",
	"I can't go for that.",
	"I'm afraid that's unacceptable.")
	var/list/dialogue_wrong_haggle_accept = list("...huh. If you say so!")
	var/list/dialogue_wrong_haggle_reject = list("Are you sure about that?")
	var/list/dialogue_cant_afford_that = list("I'm sorry, but you can't afford that.")
	var/list/dialogue_out_of_stock = list("Sorry, that item is out of stock.")

	var/currently_selling = 0 //Are we currently processing an order?

	New()
		..()
		src.current_message = pick(src.dialogue_greet)
		src.patience = rand(src.base_patience[1],src.base_patience[2])
		if (src.max_goods_buy > src.base_goods_buy.len)
			src.max_goods_buy = src.base_goods_buy.len
		if (src.max_goods_sell > src.base_goods_sell.len)
			src.max_goods_sell = src.base_goods_sell.len
		src.set_up_goods()

	proc/set_up_goods()
		// This is called in New and also when the trader comes back from being away for a while
		// It basically clears out and rejumbles their commodity lists to keep things fresh
		src.goods_buy = new/list()
		src.goods_sell = new/list()
		src.wipe_cart()

		var/list/goods_buy_temp = list()
		goods_buy_temp |= base_goods_buy
		var/list/goods_sell_temp = list()
		goods_sell_temp |= base_goods_sell

		var/howmanybuy = rand(1,src.max_goods_buy)
		while(howmanybuy > 0)
			howmanybuy--
			var/the_commodity = pick(goods_buy_temp)
			var/datum/commodity/COM = new the_commodity(src)
			src.goods_buy += COM
			goods_buy_temp -= the_commodity

		var/howmanysell = rand(1,src.max_goods_sell)
		while(howmanysell > 0)
			howmanysell--
			var/the_commodity = pick(goods_sell_temp)
			var/datum/commodity/COM = new the_commodity(src)
			if(COM.type == /datum/commodity) logTheThing("debug", src, null, "<B>SpyGuy/Traders:</B> [src] got a /datum/commodity when trying to set up stock with [the_commodity]")
			src.goods_sell += COM
			goods_sell_temp -= the_commodity

	proc/haggle(var/datum/commodity/goods,var/askingprice,var/buying = 0)
		// if something's gone wrong and there's no input, reject the haggle
		// also reject if there's no change in the price at all
		if (!askingprice || !goods) return
		if (askingprice == goods.price) return

		// if the player is being dumb and haggling in the wrong direction, tell them
		// unless the trader is a dick in which case accept the terrible haggle outright
		if ((buying && askingprice > goods.price) || (!buying && askingprice < goods.price))
			if (src.asshole)
				src.current_message = pick(src.dialogue_wrong_haggle_accept)
				goods.price = askingprice
				return
			else
				src.current_message = pick(src.dialogue_wrong_haggle_reject)
				return

		// check if the price increase % of the haggle is more than this trader will tolerate
		var/adjustedTolerance = src.hiketolerance

		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(H.traitHolder && H.traitHolder.hasTrait("smoothtalker"))
				adjustedTolerance = round(adjustedTolerance * 1.5)

		var/hikeperc = askingprice - goods.price
		hikeperc = (hikeperc / goods.price) * 100
		var/negatol = 0 - adjustedTolerance

		if ((buying && hikeperc <= negatol) || (!buying && hikeperc >= adjustedTolerance))
			// you are being a rude nerd and pushing it too far!
			src.current_message = pick(src.dialogue_haggle_reject)
			src.patience--
			if (src.patience == 0)
				src.current_message = src.dialogue_haggle_reject[src.dialogue_haggle_reject.len]
			return

		// now, the actual haggling part! find the middle ground between the two prices
		var/middleground = (goods.price + askingprice) / 2
		// now slide it in the trader's favor slightly (hey, they're haggling too)
		var/negotiate = abs(goods.price-middleground)-1
		if (buying)
			goods.price = round(middleground + rand(0,negotiate))
		else
			if(middleground-goods.price <= 0.5)
				goods.price = round(middleground + 1)
			else
				goods.price = round(middleground - rand(0,negotiate))
		src.current_message = pick(src.dialogue_haggle_accept)
		src.patience--
		// warn the player if the trader isn't going to take any more haggling
		if (src.patience == 0)
			src.current_message = src.dialogue_haggle_accept[src.dialogue_haggle_accept.len]

	proc/buy_from()
		src.currently_selling = 1
		var/obj/storage/S = new /obj/storage/crate
		S.name = "Goods Crate ([src.name])"
		var/obj/item/paper/invoice = new /obj/item/paper(S)
		invoice.name = "Sale Invoice ([src.name])"
		invoice.info = "Invoice of Sale from [src.name]<br><br>"

		var/total_price = 0
		for (var/datum/commodity/trader/C in src.shopping_cart)
			if (!C.comtype || C.amount < 1) continue

			total_price += C.price * C.amount
			invoice.info += "* [C.amount] units of [C.comname], [C.price * C.amount] credits<br>"
			var/putamount = C.amount
			while(putamount > 0)
				putamount--
				new C.comtype(S)
			invoice.info += "<br>Final Cost of Goods: [total_price] credits."

			wagesystem.shipping_budget -= total_price

			src.wipe_cart(1) //This tells wipe_cart to not increase the amount in stock when clearing it out.
		src.currently_selling = 0 //At this point the shopping cart has been processed
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=MGD_CARGO, "sender"="00000000", "message"="Deal with \"[src.name]\" concluded. Total Cost: [total_price] credits")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		transmit_connection.post_signal(null, pdaSignal)
		shippingmarket.receive_crate(S)

	proc/wipe_cart(var/sold_stuff)
		for (var/datum/commodity/trader/incart/COM in src.shopping_cart)
			if (COM.reference && istype(COM.reference,/datum/commodity/))
				if (COM.reference.amount > -1 && !sold_stuff) //If we sold shit then don't increase the amount. Fuck.
					COM.reference.amount += COM.amount
			src.shopping_cart -= COM
		src.shopping_cart.Cut()

/datum/commodity/trader/
	var/listed_name = "a thing!!!"   // What it shows up as outside the shopping cart
	var/list/possible_names = list() // List of names the trader will call this commodity
	var/list/possible_alt_types = list() // List of things this trade can be other than the base path
	var/alt_type_chance = 0              // The chance it will be one of those alternate things
	var/list/price_boundary = list(0,0)  // Minimum and maximum price for this commodity

	New()
		..()
		if(src.possible_names.len)
			src.listed_name = pick(src.possible_names)
		else
			src.listed_name = src.comname
		if(prob(src.alt_type_chance) && src.possible_alt_types.len)
			src.comtype = pick(src.possible_alt_types)
		src.price = rand(src.price_boundary[1],src.price_boundary[2])

/datum/commodity/trader/incart/
	var/datum/commodity/reference = null
