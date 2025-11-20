/datum/trader
	var/name = "trader"   // The name of the trader (duh)
	var/picture = "generic.png" // What they look like on comms
	var/crate_tag = "trader"    // What to label a crate if selling to them
	var/list/base_patience = list(0,0) // min and max patience for this trader
	var/patience = 0      // how many times you can haggle the price before they get pissed off and leave, randomise it
	var/hiketolerance = 25// if the haggled price hike is this % or greater of the current price, reject it
	var/hidden = 0              // Makes the trader not show up on the QM console
	var/chance_leave = 35       // Chance for a trader to go hidden during a market shift
	var/chance_arrive = 45      // Chance for a trader to stop hiding during a market shift
	var/asshole = 0 // will accept wrong-direction haggles

	///A business card or other item type to occasionally include with orders
	var/business_card = null
	var/business_card_chance = 20

	// lists of commodity datums that the trader will buy or sell, and the cart
	// these are the base lists of commodities this trader will have
	var/list/base_goods_buy = list()
	var/list/base_goods_sell = list()

	// The rarities used to iterate over
	var/rarities = list(TRADER_RARITY_COMMON, TRADER_RARITY_UNCOMMON, TRADER_RARITY_RARE)
	// list to determine how many items per rarity we have
	// it's cumulative, meaning we will have at least X common, Y uncommon, etc.
	var/list/amount_of_items_per_rarity = alist(
		TRADER_RARITY_COMMON = 3,
		TRADER_RARITY_UNCOMMON = 2,
		TRADER_RARITY_RARE = 1,
	)
	// and these three are the active ones used for gameplay
	var/list/goods_buy = list()
	var/list/goods_sell = list()
	var/list/shopping_cart = list()

	var/current_message = "what"// draws from dialogue to display a message
	// dialogue banks
	var/list/dialogue_greet = list("Hello there. Care to take a look at my wares?",
	"Hey, got some new selection for you! Take a look.",
	"Just finished getting everything set up! Come and browse my selection.",
	"I've got some very impressive goods to sell today!",
	"I've finally gotten rid of the cargo holds. Please buy something, I need to make the money back.")
	var/list/dialogue_leave = list("This is going nowhere. I'm outta here.",
	"This is the best Nanotrasen has to offer? We're finished here, goodbye.",
	"What a joke. I can't believe I bothered with you. Bye.",
	"Yeah, clearly we aren't seeing eye to eye. I'll come back another time, alright?",
	"Are you expecting me to just give you what you want for free? Nah, I'm gone.")
	var/list/dialogue_purchase = list("Thank you for your purchase! Your goods should arrive shortly.",
	"Alright, we'll send the merchandise over now. Watch your head!",
	"Transaction complete! Your items should be on the way!",
	"That settles it. We'll ship the goods over now, I hope your conveyors can handle it!")
	var/list/dialogue_haggle_accept = list("Alright, how's this sound?",
	"You drive a hard bargain. How's this price?",
	"You're busting my balls here. How's this?",
	"Anything more than this and I'll go broke!",
	"Alright, that seems like a fair exchange.",
	"I think this price will benefit both of us!",
	"Agh! Alright fine, but no higher!",
	"Okay, this is my last offer. I'm being serious.",
	"Fine, but any higher and I won't make a profit anymore.",
	"I can't go any higher than this, alright?",
	"I'm being more than generous here, I think you'll agree.",
	"This is my final offer. Can't do better than this.")
	var/list/dialogue_haggle_reject = list("No way. That's too much of a stretch.",
	"You're kidding, right?",
	"That's just not reasonable.",
	"I can't go for that.",
	"No, I don't think I'll let that slide.",
	"I'm not an idiot, be more reasonable.",
	"There's no way you're actually expecting me to accept that, right?",
	"I don't think that's fair, how about this?",
	"Money doesn't grow on trees here, you know?",
	"Drop it down a notch and we'll see how I feel.",
	"I have a budget to maintain as well, sorry.",
	"There's no way I can do that.",
	"I'm afraid that's unacceptable.")
	var/list/dialogue_wrong_haggle_accept = list("...huh. If you say so!",
	"I mean if you're offering, sure!",
	"Well I'm not going to say no to a deal like that!",
	"Now I see why people told me trading with this station is profitable.")
	var/list/dialogue_wrong_haggle_reject = list("Are you sure about that?",
	"I'm gonna pretend I didn't see that, alright?",
	"Please make sure to proof read your messages, alright?",
	"Did you make a mistake or are you trying to get on my good side?")
	var/list/dialogue_cant_afford_that = list("I'm sorry, but you can't afford that.",
	"There's not enough to cover the purchase in your budget, sorry.",
	"Your card declined, should I try again?",
	"It looks like you don't have the budget for this purchase. Did someone nab it?",)
	var/list/dialogue_out_of_stock = list("Sorry, that item is out of stock.",
	"I just sold out a few minutes ago, sorry!",
	"We're fresh out, check back in a bit!",
	"You just bought everything I had, didn't you?")

	var/currently_selling = 0 //Are we currently processing an order?

	New()
		..()
		src.current_message = pick(src.dialogue_greet)
		src.patience = rand(src.base_patience[1],src.base_patience[2])
		src.set_up_goods()

	proc/set_up_goods(var/should_reset_buylist = TRUE)
		// This is called in New and also when the trader comes back from being away for a while
		// It basically clears out and rejumbles their commodity lists to keep things fresh
		if (should_reset_buylist) src.goods_buy = new/list()
		src.goods_sell = new/list()
		src.wipe_cart()

		var/list/goods_buy_temp[(length(rarities))]
		for(var/i in rarities)
			var/list/L = base_goods_buy[i]
			goods_buy_temp[i] = L.Copy()

		var/list/goods_sell_temp[(length(rarities))]
		for(var/i in rarities)
			var/list/L = base_goods_sell[i]
			goods_sell_temp[i] = L.Copy()

		// Iterate over all rarities and pick the corresponding amount of items from the respective lists
		for (var/rarity in src.rarities)
			for (var/i in 1 to src.amount_of_items_per_rarity[rarity])
				if(should_reset_buylist && length(goods_buy_temp[rarity]) >= i)
					var/buy_com = pick(goods_buy_temp[rarity])
					var/datum/commodity/new_buy_com = new buy_com(src)
					src.goods_buy += new_buy_com
					goods_buy_temp[rarity] -= buy_com
				if(length(goods_sell_temp[rarity]) >= i)
					var/sell_com = pick(goods_sell_temp[rarity])
					var/datum/commodity/new_sell_com = new sell_com(src)
					src.goods_sell += new_sell_com
					goods_sell_temp[rarity] -= sell_com

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
			if (H.traitHolder.hasTrait("smoothtalker") || H.traitHolder.hasTrait("training_quartermaster"))
				adjustedTolerance = round(adjustedTolerance * 1.5)

		var/hikeperc = askingprice - goods.price
		hikeperc = (hikeperc / goods.price) * 100
		var/negatol = 0 - adjustedTolerance

		if ((buying && (hikeperc <= negatol || askingprice < goods.baseprice / 5)) || (!buying && (hikeperc >= adjustedTolerance || askingprice > goods.baseprice * 5)))
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

		if (src.business_card && prob(src.business_card_chance))
			new src.business_card(S)

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
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT", "group"=list(MGD_CARGO, MGA_SALES), "sender"="00000000", "message"="Deal with \"[src.name]\" concluded. Total Cost: [total_price] credits")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)
		shippingmarket.receive_crate(S)

	proc/wipe_cart(var/sold_stuff)
		for (var/datum/commodity/trader/incart/COM in src.shopping_cart)
			if (COM.reference && istype(COM.reference,/datum/commodity/))
				if (COM.reference.amount > -1 && !sold_stuff) //If we sold shit then don't increase the amount. Fuck.
					COM.reference.amount += COM.amount
			COM.amount = 0
			src.shopping_cart -= COM
		src.shopping_cart.Cut()

/datum/commodity/trader
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
		if(prob(src.alt_type_chance) && length(src.possible_alt_types))
			src.comtype = pick(src.possible_alt_types)
		src.price = rand(src.price_boundary[1],src.price_boundary[2])
		src.baseprice = price

/datum/commodity/trader/incart
	var/datum/commodity/reference = null
