/proc/most_applicable_trade(var/list/datum/commodity/goods_buy, var/obj/item/sell_item)
	var/list/goods_buy_types = new /list(0)
	for(var/datum/commodity/N as anything in goods_buy)
		if (N.subtype_valid ? istype(sell_item, N.comtype) : N.comtype == sell_item.type)
			goods_buy_types[N.comtype] = N
	return goods_buy_types[maximal_subtype(goods_buy_types)]


/obj/npc/trader
	name="Trader"
	layer = 4  //Same layer as most mobs, should stop them from sometimes being drawn under their shuttle chairs out of sight
	var/bullshit = 0
	var/hiketolerance = 20 //How much they will tolerate price hike
	var/list/droplist = null //What the merchant will drop upon their death
	var/list/goods_sell = new/list() //What products the trader sells
	var/illegal = 0 // maybe trading with illegal bots could flag the user's criminal record for smuggling
	var/goods_illegal = list() // Illegal goods
	var/list/goods_buy = new/list() //what products the merchant buys
	var/list/shopping_cart = new/list() //What has been bought
	var/list/mob/barter_customers = list() // Customer credit
	var/obj/item/sell = null //Item to sell
	var/portrait_setup = null
	var/obj/item/sellitem = null
	var/item_name = "--------"
	var/obj/item/card/id/scan = null
	var/barter = FALSE
	var/currency = "Credits"
	//Trader dialogue
	var/sell_dialogue = null
	var/buy_dialogue = null
	var/list/successful_sale_dialogue = null
	var/list/failed_sale_dialogue = null
	var/list/successful_purchase_dialogue = null
	var/list/failed_purchase_dialogue = null
	var/pickupdialogue = null
	var/pickupdialoguefailure = null
	var/list/trader_area = null
	var/doing_a_thing = 0
	var/log_trades = TRUE

	///A business card or other item type to occasionally include with orders
	///copy pasted from /datum/trader because we have two separate trader types APPARENTLY
	var/business_card = null
	var/business_card_chance = 20

	var/datum/dialogueMaster/dialogue = null //dialogue will open on click if available. otherwise open trade directly.
	var/lastWindowName = ""
	var/angrynope = "Not interested." //What the trader says when he declines trade because angry.
	var/whotext = "" //What the trader says when asked who they are.

		// This list is in a specific order!!
	// String 1 - player is being dumb and hiked a price up when buying, trader accepted it because they're a dick
	// String 2 - same as above only the trader is being nice about it
	// String 3 - same as string 1 except we're selling
	// String 4 - same as string 3 except with a nice trader
	// String 5 - player haggled further than the trader is willing to tolerate
	// String 6 - trader has had enough of your bullshit and is leaving
	var/list/errormsgs = list("...huh. If you say so!",
								"Huh? You want to pay <i>more</i> for my wares than i'm offering?",
								"Wha.. well, okay! I'm not gonna complain!",
								"Wait, what? You want me to pay you <i>less</i> for your wares?",
								"What the f... umm, no? Make me a serious offer.",
								"Sorry, you're terrible at this. I must be going.")
	// Next list - the last entry will always be used on the trader's final haggling offer
	// otherwise the trader picks randomly from the list including the "final offer" in order to bluff players
	var/list/hagglemsgs = list("Alright, how's this sound?",
								"You drive a hard bargain. How's this price?",
								"You're busting my balls here. How's this?",
								"I'm being more than generous here, I think you'll agree.",
								"This is my final offer. Can't do better than this.")

	New()
		dialogue = new/datum/dialogueMaster/traderGeneric(src)
		src.trader_area = get_area(src)
		..()

	anger()
		for(var/mob/M in AIviewers(src))
			boutput(M, SPAN_ALERT("<B>[src.name]</B> becomes angry!"))
		src.desc = "[src] looks angry."
		SPAWN(rand(1000,3000))
			src.visible_message("<b>[src.name] calms down.</b>")
			src.desc = "[src] looks a bit annoyed."
			src.temp = "[src.name] has calmed down.<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
			src.angry = 0
		return

	proc/openTrade(var/mob/user, var/windowName = "trader", var/windowSize = "400x700")
		if(angry)
			boutput(user, SPAN_ALERT("[src] is angry and won't trade with anyone right now."))
			return
		src.add_dialog(user)
		lastWindowName = windowName

		var/dat = updatemenu(user)
		if(!temp)
			dat += {"[src.greeting]<HR>
			<A href='?src=\ref[src];purchase=1'>Purchase Items</A><BR>
			<A href='?src=\ref[src];sell=1'>Sell Items</A><BR>
			<A href='?src=\ref[src];viewcart=1'>View Cart</A><BR>
			<A href='?src=\ref[src];pickuporder=1'>I'm Ready to Pick Up My Order</A><BR>
			<A href='?action=mach_close&window=[lastWindowName]'>Goodbye</A>"}

		user.Browse(dat, "window=[windowName];size=[windowSize]", 1)
		onclose(user, windowName)
		return

	attackby(obj/item/I, mob/user)
		var/obj/item/card/id/id_card = get_id_card(I)
		if (istype(id_card))
			boutput(user, SPAN_NOTICE("You swipe the ID card in the card reader."))
			var/datum/db_record/account = null
			account = FindBankAccountByName(id_card.registered)
			if(account)
				var/enterpin = user.enter_pin("Card Reader")
				if (enterpin == id_card.pin)
					boutput(user, SPAN_NOTICE("Card authorized."))
					src.scan = id_card
				else
					boutput(user, SPAN_ALERT("PIN incorrect."))
					src.scan = null
			else
				boutput(user, SPAN_ALERT("No bank account associated with this ID found."))
				src.scan = null

	attack_hand(var/mob/user)
		if(..())
			return
		if(dialogue != null)
			dialogue.showDialogue(user)
		else
			openTrade(user)
		return

	disposing()
		goods_sell = null
		goods_buy = null
		shopping_cart = null
		..()

	proc/barter_lookup(mob/M)
		. = M.real_name

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)
		///////////////////////////////
		///////Generate Purchase List//
		///////////////////////////////
		var/list/goods_for_purchase = goods_sell.Copy()
		// Illegal goods for syndicate traitors
		if (illegal)
			if(usr.mind && (istraitor(usr) || isspythief(usr) || isnukeop(usr) || usr.mind.special_role == ROLE_SLEEPER_AGENT || usr.mind.special_role == ROLE_OMNITRAITOR))
				goods_for_purchase += goods_illegal
		if (href_list["purchase"])
			src.temp =buy_dialogue + "<HR><BR>"
			for(var/datum/commodity/N in goods_for_purchase)
				// Have to send the type instead of a reference to the obj because it would get caught by the garbage collector. oh well.
				src.temp += {"<A href='?src=\ref[src];doorder=\ref[N]'><B><U>[N.comname]</U></B></A><BR>
				<B>Cost:</B> [N.price] [currency]<BR>
				<B>Description:</B> [N.desc] Amount: [N.amount > -1 ? N.amount : "Infinite"]<BR>
				<A href='?src=\ref[src];haggleb=\ref[N]'><B><U>Haggle</U></B></A><BR><BR>"}
			src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Ok</A>"
		//////////////////////////////////////////////
		///////Handle the buying of a specific item //
		//////////////////////////////////////////////
		else if (href_list["doorder"])
			var/datum/db_record/account = null
			var/datum/commodity/P = locate(href_list["doorder"]) in goods_for_purchase
			var/amount_to_sell = INFINITY
			var/amount_per_order = 50
			if(P?.amount > -1)
				amount_to_sell = P.amount
			amount_to_sell = min(amount_per_order,amount_to_sell)
			if(!barter)
				if(!scan)
					src.temp = {"You have to scan a card in first.<BR>
								<BR><A href='?src=\ref[src];purchase=1'>OK</A>"}
					src.updateUsrDialog()
					return
				if (src.scan.registered in FrozenAccounts)
					boutput(usr, SPAN_ALERT("Your account cannot currently be liquidated due to active borrows."))
					return

				account = FindBankAccountByName(src.scan.registered)
			if (barter || account)
				var/quantity = 1
				quantity = input("How many units do you want to purchase? Maximum: [amount_to_sell]", "Trader Purchase", null, null) as num
				if(!isnum_safe(quantity))
					return
				if (quantity < 1)
					quantity = 0
					return
				else if (quantity >= amount_to_sell)
					quantity = amount_to_sell

				////////////

				if(P)
					var/current_funds = src.barter ? barter_customers[barter_lookup(usr)] : account["current_money"]
					if(shopping_cart.len + quantity > amount_per_order)
						src.temp = {"Error. Maximum purchase limit of [amount_per_order] items exceeded.<BR>
						<BR><A href='?src=\ref[src];purchase=1'>OK</A>"}
					else if(current_funds >= P.price * quantity)
						if(barter)
							barter_customers[barter_lookup(usr)] -= P.price * quantity
							if(P.amount > 0)
								P.amount -= quantity
						else
							account["current_money"] -= P.price * quantity
							if(P.amount > 0)
								P.amount -= quantity
						if(log_trades)
							logTheThing(LOG_STATION, usr, "bought ([quantity]) [P.comtype] from [src] at [log_loc(get_turf(src))]")
						while(quantity-- > 0)
							shopping_cart += new P.comtype()
						src.temp = {"[pick(successful_purchase_dialogue)]<BR>
									<BR><A href='?src=\ref[src];purchase=1'>What other things have you got for sale?</A>
									<BR><A href='?src=\ref[src];pickuporder=1'>I want to pick up my order.</A>
									<BR><A href='?src=\ref[src];mainmenu=1'>I've got some other business.</A>"}
					else
						src.temp = {"[pick(failed_purchase_dialogue)]<BR>
									<BR><A href='?src=\ref[src];purchase=1'>OK</A>"}
				else
					src.temp = {"[src] looks bewildered for a second. Seems like they can't find your item.<BR>
								<BR><A href='?src=\ref[src];purchase=1'>OK</A>"}
			else
				src.temp = {"That's odd I can't seem to find your account
							<BR><A href='?src=\ref[src];purchase=1'>OK</A>"}

		///////////////////////////////////////////
		///Handles haggling for buying ////////////
		///////////////////////////////////////////
		else if (href_list["haggleb"])

			var/askingprice= input(usr, "Please enter your asking price.", "Haggle", 0) as null|num
			if(isnum_safe(askingprice))
				var/datum/commodity/N = locate(href_list["haggleb"]) in goods_for_purchase
				if(N)
					if(patience == N.haggleattempts)
						src.temp = "[src.name] becomes angry and won't trade anymore."
						src.add_fingerprint(usr)
						src.updateUsrDialog()
						angry = 1
						anger()
					else
						haggle(askingprice, 1, N)
						src.temp +="<BR><A href='?src=\ref[src];purchase=1'>Ok</A>"


		/////////////////////////////////////////////
		///////Generate list of items user can sell//
		/////////////////////////////////////////////
		else if (href_list["sell"])
			src.temp = "[src.sell_dialogue]<HR><BR>"
			for(var/datum/commodity/N in goods_buy)
				if(N.hidden)
					continue
				else
					temp+={"<B>[N.comname] for [N.price] [currency]:</B> [N.indemand ? N.desc_buy_demand : N.desc_buy]<BR>
							<A href='?src=\ref[src];haggles=[N]'><B><U>Haggle</U></B></A><BR><BR>"}
			if(src.sellitem)
				src.item_name = src.sellitem.name
			else
				src.item_name = "--------"
			src.temp += {"<HR>What do you wish to sell? <a href='?src=\ref[src];sellitem=1'>[src.item_name]</a><br>
						<BR><A href='?src=\ref[src];selltheitem=1'>Sell Item</A>
						<BR><A href='?src=\ref[src];mainmenu=1'>Ok</A>"}

		///////////////////////////////////////////
		///Haggle for selling /////////////////////
		///////////////////////////////////////////
		else if (href_list["haggles"])

			var/askingprice= input(usr, "Please enter your asking price.", "Haggle", 0) as null|num
			if(isnum_safe(askingprice))
				var/datum/commodity/N = locate(href_list["haggles"]) in goods_buy
				if(N)
					if(patience == N.haggleattempts)

						src.temp = "[src.name] becomes angry and won't trade anymore."
						src.add_fingerprint(usr)
						src.updateUsrDialog()
						angry = 1
						anger()
					else
						haggle(askingprice, 0, N)
						src.temp +="<BR><A href='?src=\ref[src];sell=1'>Ok</A>"

		////////////////////////////////////////
		////////Slot holder for the current item///
		///////////////////////////////////////
		else if (href_list["sellitem"])
			if (src.sellitem)
				if (!doing_a_thing)
					src.sellitem.set_loc(src.loc)
					src.sellitem = null
			else
				var/obj/item/I = usr.equipped()
				if (!I)
					return
				usr.drop_item()
				// in case dropping the item somehow deletes it?? idk there was a runtime error still
				if (!I)
					return
				I.set_loc(src)
				src.sellitem = I
				src.item_name = I.name
			src.temp = "[src.sell_dialogue]<HR><BR>"
			for(var/datum/commodity/N  in goods_buy)
				if(N.hidden)
					continue
				else
					temp+="<B>[N.comname] for [N.price] [currency]:</B> [N.indemand ? N.desc_buy_demand : N.desc_buy]<BR><BR>"
			if(src.sellitem)
				src.item_name = src.sellitem.name
			else
				src.item_name = "--------"
			src.temp += {"<HR>What do you wish to sell? <a href='?src=\ref[src];sellitem=1'>[src.item_name]</a><br>
							<BR><A href='?src=\ref[src];selltheitem=1'>Sell Item</A>
							<BR><A href='?src=\ref[src];mainmenu=1'>Ok</A>
							<BR><i>To sell large quantities at once, clickdrag a crate onto [src].</i>"}

		///////////////////////////////////////////
		/////////Actually Sell the item //////////
		//////////////////////////////////////////
		else if (href_list["selltheitem"])
			var/datum/db_record/account = null
			if(!src.sellitem)
				src.updateUsrDialog()
				return
			if (doing_a_thing)
				src.updateUsrDialog()
				return
			if(!barter)
				if(!src.scan)
					src.temp = {"You have to scan a card in first.<BR>
								<BR><A href='?src=\ref[src];sell=1'>OK</A>"}
					src.updateUsrDialog()
					return
				account = FindBankAccountByName(src.scan.registered)

			var/datum/commodity/tradetype = most_applicable_trade(src.goods_buy, src.sellitem)
			if(tradetype)
				if (!barter && !account)
					src.temp = {" [src] looks slightly agitated when he realizes there is no bank account associated with the ID card.<BR>
								<BR><A href='?src=\ref[src];sell=1'>OK</A>"}
					src.add_fingerprint(usr)
					src.updateUsrDialog()
					return
				else
					doing_a_thing = 1
					src.temp = pick(src.successful_sale_dialogue) + "<BR>"
					src.temp += "<BR><A href='?src=\ref[src];sell=1'>OK</A>"

					var/value = sold_item(tradetype, sellitem, src.sellitem.amount, usr)
					if(log_trades)
						logTheThing(LOG_STATION, usr, "sold ([src.sellitem.amount])[sellitem.type] to [src] for [value] at [log_loc(get_turf(src))]")
					qdel (src.sellitem)
					if(account)
						account["current_money"] += value
					else
						barter_customers[barter_lookup(usr)]  += value
					src.sellitem = null
					src.add_fingerprint(usr)
					src.updateUsrDialog()
					doing_a_thing = 0
					return
			src.temp = {"[pick(failed_sale_dialogue)]<BR>
						<BR><A href='?src=\ref[src];sell=1'>OK</A>"}

		///////////////////////////////////
		////////Handle Bank account Set-Up ///////
		//////////////////////////////////
		else if (href_list["card"])
			card_scan()

		////////////////////////////////////////////////////
		//////View what still needs to be picked up/////////
		///////////////////////////////////////////////////
		else if (href_list["viewcart"])
			src.temp = "<B>Current Items in Cart: </B>"
			for(var/obj/S in shopping_cart)
				temp+= "<BR>[S.name]"
			src.temp += "<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		////////////////////////////////////////////////////
		/////Pick up the goods ordered from merchant////////
		//////////////////////////////////////////////////////
		else if (href_list["pickuporder"])
			if(shopping_cart.len)
				spawncrate()
				src.temp = pickupdialogue
			else
				src.temp = pickupdialoguefailure
			src.temp += "<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		else if (href_list["mainmenu"])
			src.temp = null
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return

	proc/card_scan()
		if (src.scan) src.scan = null
		else
			var/obj/item/card/id/id_card = get_id_card(usr.equipped())
			if (istype(id_card))
				boutput(usr, SPAN_NOTICE("You swipe the ID card in the card reader."))
				var/datum/db_record/account = null
				account = FindBankAccountByName(id_card.registered)
				if(account)
					var/enterpin = usr.enter_pin("Card Reader")
					if (enterpin == id_card.pin)
						boutput(usr, SPAN_NOTICE("Card authorized."))
						src.scan = id_card
					else
						boutput(usr, SPAN_ALERT("PIN incorrect."))
						src.scan = null
				else
					boutput(usr, SPAN_ALERT("No bank account associated with this ID found."))
					src.scan = null

	/////////////////////////////////////////////
	/////Update the menu with the default items
	////////////////////////////////////////////
	proc/updatemenu(mob/user)
		var/dat
		dat = portrait_setup

		if(barter)
			if(!barter_customers[barter_lookup(user)])
				barter_customers[barter_lookup(user)] = 0
			dat+="<B>Barter value</B>: [barter_customers[barter_lookup(user)]] [currency]<HR>"
		else
			dat +="<B>Scanned Card:</B> <A href='?src=\ref[src];card=1'>([src.scan])</A><BR>"
			if(scan)
				var/datum/db_record/account = null
				account = FindBankAccountByName(src.scan.registered)
				if (account)
					dat+="<B>Current Funds</B>: [account["current_money"]] [currency]<HR>"
				else
					dat+="<HR>"
		if(temp)
			dat+=temp
		return dat

	///////////////////////////////////////
	///////Spawn the crates full of goods///
	////////////////////////////////////////
	proc/spawncrate(var/list/custom)
		var/list/markers = new/list()
		var/pickedloc = 0
		var/found = 0

		var/list/area_turfs = get_area_turfs(trader_area)
		if (!area_turfs || !length(area_turfs))
			area_turfs = get_area_turfs( get_area(src) )

		for(var/turf/T in area_turfs)
			for(var/obj/marker/supplymarker/D in T)
				markers += D

		for(var/C in markers)
			if (locate(/obj/storage/crate) in get_turf(C))
				continue
			found = 1
			pickedloc = get_turf(C)
		if (!found)
			if (islist(markers) && length(markers))
				pickedloc = get_turf(pick(markers))
			else
				pickedloc = get_turf(src) // put it SOMEWHERE

		var/obj/storage/crate/A = new /obj/storage/crate(pickedloc)
		showswirl(pickedloc)
		A.name = "Goods Crate ([src.name])"
		if (src.business_card && prob(src.business_card_chance))
			new src.business_card(A)
		if (!custom)
			for(var/atom/movable/purchased as anything in shopping_cart)
				purchased.set_loc(A)
			shopping_cart = new/list()
		else
			new custom(A)

	////////////////////////////////////////////////////
	/////////Proc for haggling with dealer ////////////
	///////////////////////////////////////////////////
	proc/haggle(var/askingprice, var/buying, var/datum/commodity/H)
		// if something's gone wrong and there's no input, reject the haggle
		// also reject if there's no change in the price at all
		if (!askingprice) return
		if (askingprice == H.price) return
		// if the player is being dumb and haggling in the wrong direction, tell them (unless the trader is an asshole)
		if (buying == 1)
			// we're buying, so we want to pay less per unit
			if(askingprice > H.price)
				if (src.bullshit >= 5)
					src.temp = src.errormsgs[1]
					H.price = askingprice
					return
				else
					src.temp = src.errormsgs[2]
					return
		else
			// we're selling, so we want to be paid MORE per unit
			if(askingprice < H.price)
				if (src.bullshit >= 5)
					H.price = askingprice
					src.temp = "<B>Cost:</B> [H.price] [currency]<BR>"
					src.temp += src.errormsgs[3]
					return
				else
					src.temp = "<B>Cost:</B> [H.price] [currency]<BR>"
					src.temp += src.errormsgs[4]
					return
		//check if we're trying to scam a trader that is, for whatever reason, buying and selling the exact same commodity
		if(buying == 1)
			for(var/datum/commodity/arbitrage in src.goods_buy)
				if(arbitrage.type == H.type && askingprice < arbitrage.price)
					src.temp = "<B>Cost:</B> [H.price] [currency]<BR>"
					src.temp += src.errormsgs[5]
					H.haggleattempts++
					return
		else
			for(var/datum/commodity/arbitrage in src.goods_sell)
				if(arbitrage.type == H.type && askingprice > arbitrage.price)
					src.temp = "<B>Cost:</B> [H.price] [currency]<BR>"
					src.temp += src.errormsgs[5]
					H.haggleattempts++
					return

		// check if the price increase % of the haggle is more than this trader will tolerate
		var/hikeperc = askingprice - H.price
		hikeperc = (hikeperc / H.price) * 100
		var/negatol = 0 - src.hiketolerance
		if (buying == 1) // we're buying, so price must be checked for negative
			if (hikeperc <= negatol || askingprice < H.baseprice / 5)
				src.temp = "<B>Cost:</B> [H.price] [currency]<BR>"
				src.temp += src.errormsgs[5]
				H.haggleattempts++
				return
		else
			if (hikeperc >= src.hiketolerance || askingprice > H.baseprice * 5) // we're selling, so check hike for positive
				src.temp = src.errormsgs[5]
				H.haggleattempts++
				return
		// now, the actual haggling part! find the middle ground between the two prices
		var/middleground = (H.price + askingprice) / 2
		var/negotiate = abs(H.price-middleground)-1
		if (buying == 1)
			H.price =round(middleground + rand(0,negotiate))
		else
			if(middleground-H.price <= 0.5)
				H.price = round(middleground + 1)
			else
				H.price = round(middleground - rand(0,negotiate))

		src.temp = "<B>New Cost:</B> [H.price] [currency]<BR><HR>"
		H.haggleattempts++
		// warn the player if the trader isn't going to take any more haggling
		if (patience == H.haggleattempts)
			src.temp += src.hagglemsgs[src.hagglemsgs.len]
		else
			src.temp += pick(src.hagglemsgs)

	///////////////////////////////////////////////
	////// special handling for selling an item ///
	///////////////////////////////////////////////
	proc/sold_item(datum/commodity/C, obj/S, count, mob/user as mob)
		. = C.price * count

	///////////////////////////////////
	////// batch selling - cogwerks ///
	///////////////////////////////////

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		var/datum/db_record/account = null
		if(BOUNDS_DIST(O, user) > 0) return
		if(!isliving(user)) return
		if(!barter)
			if(!src.scan)
				boutput(user, SPAN_ALERT("You have to scan your ID first!"))
				return
			account = FindBankAccountByName(src.scan.registered)
			if(!account)
				boutput(user, SPAN_ALERT("[src]There is no account registered with this card!"))
				return
		if(angry)
			boutput(user, SPAN_ALERT("[src] is angry and won't trade with anyone right now."))
			return
		if(!alive)
			boutput(user, SPAN_ALERT("[src] is dead!"))
			return
		/*if (isitem(O))
			user.visible_message(SPAN_NOTICE("[src] rummages through [user]'s goods."))
			var/staystill = user.loc
			for(var/datum/commodity/N in goods_buy)
				if (N.comtype == O.type)
					user.visible_message(SPAN_NOTICE("[src] is willing to buy all of [O]."))
					for(N.comtype in view(1,user))
						account["current_money"] += N.price
						qdel(N.comtype)
						sleep(0.2 SECONDS)
						if (user.loc != staystill) break*/
		if (istype(O, /obj/storage/crate/))
			var/obj/storage/crate/C = O
			if (C.locked)
				user.show_text("[src] stares at the locked [C], unamused. Maybe you should make sure the thing's open, first.", "red")
				return
			SPAWN(1 DECI SECOND)
				user.visible_message(SPAN_NOTICE("[src] rummages through [user]'s [O]."))
				playsound(src.loc, "rustle", 60, 1)
				var/cratevalue = null
				var/list/sold_string = list()
				for (var/obj/item/sellitem in O.contents)
					var/datum/commodity/tradetype = most_applicable_trade(src.goods_buy, sellitem)
					if(tradetype)
						cratevalue += sold_item(tradetype, sellitem, sellitem.amount, user)
						qdel(sellitem)
						sold_string[sellitem.type] += sellitem.amount
				if(log_trades && length(sold_string))
					logTheThing(LOG_STATION, user, "sold ([json_encode(sold_string)]) to [src] for [cratevalue] at [log_loc(get_turf(src))]")
				if(cratevalue)
					boutput(user, SPAN_NOTICE("[src] takes what they want from [O]. [cratevalue] [currency] have been transferred to your account."))
					if(account)
						account["current_money"] += cratevalue
					else
						barter_customers[barter_lookup(user)] += cratevalue
				else
					boutput(user, SPAN_NOTICE("[src] finds nothing of interest in [O]."))

// trader except money never comes out. You sell to accrue credit that can then be spent so it is a closed system.
/obj/npc/trader/barter
	name="Trader"
	barter=TRUE

	attackby(obj/item/I as obj, mob/user as mob)
		return

	card_scan()
		return

/////////////////////////////////////////////////////
///////////////THE TRADERS ///////////////////////////
//////////////////////////////////////////////////////

/obj/landmark/spawner/random_trader
	spawn_the_thing()
		var/type = pick(concrete_typesof(/obj/npc/trader/random) - /obj/npc/trader/random/contraband)
		new type(src.loc)
		qdel(src)

/obj/landmark/spawner/random_trader/diner
	spawn_the_thing()
		var/type = pick(concrete_typesof(/obj/npc/trader/random))
		new type(src.loc)
		qdel(src)

//////Generic Randomized visitor
ABSTRACT_TYPE(/obj/npc/trader/random)
/obj/npc/trader/random
	icon_state = "welder"
	picture = "generic.png"
	angrynope = "Not right now..."
	whotext = ""
	///What base type do they buy/sell?
	var/commercetype = null
	///What do they buy (overrides commercetype)
	var/buy_commercetype_override = null
	///What do they sell (overrides commercetype)
	var/sell_commercetype_override = null
	var/list/possible_icon_states = list("welder")
	var/list/descriptions = list("Broken", "ohgodwhy", "1800-coder")

	New()
		..()
		icon_state = pick(src.possible_icon_states)
		if (icon_state in list("owl","goose","swan","gull"))
			icon = 'icons/misc/bird.dmi'
		else if (icon_state == "parrot")
			var/obj/critter/parrot/P
			if (prob(1) && islist(special_parrot_species))
				icon_state = pick(special_parrot_species)
				P = special_parrot_species[icon_state]
				if (ispath(P))
					icon = initial(P.icon)
			else if (islist(parrot_species))
				icon_state = pick(parrot_species)
				P = parrot_species[icon_state]
				if (ispath(P))
					icon = initial(P.icon)

		var/pickprename = pick("Honest","Fair","Merchant","Trader","Kosher","Real Deal","Dealer", "Old", "Ol'", "Zesty", "Sassy", "Bargain", "Discount", "Uncle", "Big", "Little")
		//var/pickfirstname = pick(first_names)
		var/picklastname = pick_string_autokey("names/last.txt")
		src.name = "[pickprename] [picklastname]"

		greeting= {"WELL HI THERE, STEP RIGHT UP AND BUY MY STUFF!"}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "Ah, an entrepreneur after my own heart!  I have a few friends who are looking for things to buy!"

		buy_dialogue = "YES, COME RIGHT UP AND BUY MY FRIEND!"

		successful_purchase_dialogue = list("ANOTHER SATISFIED CUSTOMER!",
			"Thank you and HAVE A NICE DAY!",
			"SOLD, TO THE PERSON IN THE FUNNY JUMPSUIT!")

		failed_sale_dialogue = list("Don't waste my time, kid, I can't buy that!",
			"I've got nobody who wants to buy that junk!",
			"What, do you think I'm stupid?!?  Get out of here!",
			"Haha, nice try kid, but I've been in the business longer than that.")

		successful_sale_dialogue = list("Thank you very much!",
			"I'll take it!",
			"Come back anytime!")

		failed_purchase_dialogue = list("Come back when you can afford this stuff!",
			"You ain't got the cash, kid!",
			"Might want to check your account, 'cause I don't see the money in it!")

		pickupdialogue = "THANK YOU!"

		pickupdialoguefailure = "You need to BUY things before you pick them up!"

		src.hiketolerance = rand(2,4)
		src.hiketolerance *= 10

		var/items_for_sale = rand(5,8)
		var/items_wanted = rand(2,5)

		var/list/selltypes = typesof(sell_commercetype_override ? sell_commercetype_override : commercetype)
		var/list/buytypes = typesof(buy_commercetype_override ? buy_commercetype_override : commercetype)

		while(length(selltypes) > 0 && length(src.goods_sell) < items_for_sale)
			var/pickedselltype = pick(selltypes)
			var/datum/commodity/sellitem = new pickedselltype(src)
			selltypes -= pickedselltype
			if(sellitem.comtype != null)
				src.goods_sell += sellitem

		while(length(buytypes) > 0 && length(src.goods_buy) < items_wanted)
			var/pickedbuytype = pick(buytypes)
			var/datum/commodity/buyitem = new pickedbuytype(src)
			buytypes -= pickedbuytype
			if(buyitem.comtype != null)
				src.goods_buy += buyitem

		src.AddComponent(/datum/component/minimap_marker/minimap, MAP_INFO, "trader")

	activatesecurity()
		for(var/mob/M in AIviewers(src))
			boutput(M, "<B>[src.name]</B> yells, \"Get 'em boys!\"")
		for(var/turf/T in get_area_turfs( get_area(src) ))
			for(var/obj/fakeobject/teleport_pad/D in T)
				var/N = pick(1,2)
				var/mob/living/critter/martian/P = null
				if (N == 1)
					P = new /mob/living/critter/martian/soldier
				else
					P = new /mob/living/critter/martian/warrior
				P.set_loc(D.loc)
				showswirl(P.loc)

/obj/npc/trader/random/ore
	commercetype = /datum/commodity/ore
	possible_icon_states = list("lavacrab")
	descriptions = list("raw materials", "ore", "rocks and stones")

/obj/npc/trader/random/pod
	commercetype = /datum/commodity/podparts
	possible_icon_states = list("owl","gull","parrot")
	descriptions = list("pod", "spare vehicle parts", "space catalytic converter")

/obj/npc/trader/random/drugs
	commercetype = /datum/commodity/drugs
	buy_commercetype_override = /datum/commodity/drugs/buy
	sell_commercetype_override = /datum/commodity/drugs/sell
	possible_icon_states = list("petbee","possum","bumblespider")
	descriptions = list("off-brand pharmaceutical", "recreational chemicals")

/obj/npc/trader/random/contraband
	commercetype = /datum/commodity/contraband
	descriptions = list("legitimate goods", "perfectly legitimate goods", "extremely legitimate goods")

	New()
		src.possible_icon_states = list("big_spide[pick("","-red","-blue","-green")]")
		..()

//actually this just seems to be robotics upgrades and scrap metal?
// /obj/npc/trader/random/salvage
// 	commercetype = /datum/commodity/salvage
// 	possible_icon_states = list("welder")

/obj/npc/trader/random/junk
	commercetype = /datum/commodity/junk
	possible_icon_states = list("welder")
	descriptions = list("space junk", "miscellanea", "surplus bargains")

/obj/npc/trader/random/diner
	commercetype = /datum/commodity/diner
	possible_icon_states = list("walrus")
	descriptions = list("catering", "fast food", "discount burger")

/obj/npc/trader/random/bodyparts
	commercetype = /datum/commodity/bodyparts
	possible_icon_states = list("martian","martianP","martianW","martianSP")
	descriptions = list("organ", "body parts", "biomatter")

/obj/npc/trader/random/medical
	commercetype = /datum/commodity/medical
	possible_icon_states = list("goose","swan")
	descriptions = list("medical supplies", "pharmaceutical")

//////Martian
/obj/npc/trader/martian
	icon_state = "martianP"
	picture = "martian.png"
	angrynope = "Not now, human."
	whotext = "I am a simple martian, looking to trade."

	New()
		..()
		src.goods_sell += new /datum/commodity/ore/uqill(src,5) // cogwerks - changed from molitz, who the hell ever needs that
		src.goods_sell += new /datum/commodity/ore/plasmastone(src,5) // no guns, no, bad
		src.goods_sell += new /datum/commodity/ore/bohrum(src,20)
		src.goods_sell += new /datum/commodity/ore/cerenkite(src,10)
		src.goods_sell += new /datum/commodity/ore/telecrystal(src,5)

		src.goods_buy += new /datum/commodity/laser_gun(src)
		src.goods_buy += new /datum/commodity/relics/skull(src)
		src.goods_buy += new /datum/commodity/relics/relic(src)
		src.goods_buy += new /datum/commodity/relics/gnome(src)
		src.goods_buy += new /datum/commodity/relics/crown(src)
		src.goods_buy += new /datum/commodity/relics/armor(src)





		src.name = pick( "L'zeurk Xin", "Norzamed Bno", "Kleptar Sde", "Z'orrel Ryvc", "Kleeborp Sie", "Kleebarp Yee", "Kleebop Zho")
		greeting= {"As you approach the martian, thoughts begins to enter your head.
			<I>\"Greetings Human, unlike most martians, I am quite friendly. All I desire is to sell my wares\"</I>.
			<b>[src.name]</b> gestures towards his goods and awaits for you to make your choice."}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "You receive visions of various individuals who are looking to purchase something, and get the feeling that <B>[src.name]</B> will act as the middle man."

		buy_dialogue = "You hear a voice in your head,<I>\"Please select what you would like to buy\".</I>"

		successful_sale_dialogue = list("<i>A wave of joy washes over you upon the completion of the sale.</i>",
			"In your head you hear a voice say, <i>\"Thank you for your business. Perhaps we shouldn't wipe you all out.\"</i>",
			"[src.name] quickly begans putting his new merchandise away. Despite that, you somehow know that the martian is grateful for the sale")

		failed_sale_dialogue = list("<i>You feel an intense feeling of irritation come over you</i>. A foreign thought enters your head, <i>\"Please don't waste my time. I have better things to do than to look at worthless junk.\"</i>",
			"[src] telepathically communicates to you, <i>\"I'm sorry I currently have no interest in that item, perhaps you should try another trader.\"",
			"You suddenly and unnaturally feel incredibly stupid and embarassed about your mistake. You hang your head in shame.",
			"The martian pats you gently on the head, and shakes it head. It seems [src] feels sorry for you")

		successful_purchase_dialogue = list("[src.name] communicates to you, <i>\"Thank you for your business\"</i>.",
			"A thought enters your head, <i>\"An excellent choice. Tell me when you are ready to pick it up\".</i>")

		failed_purchase_dialogue = list("[src.name] communicates to you, <i>\"I am sorry, but you currenty do not have enough funds to purchase this.\"</I>",
			"[src.name] communicates to you, <i>\"Are you trying to pull a trick on me because I am a martian? You don't have enough credits to purchase this.\"</I>")

		pickupdialogue = "A foreign thought enters your head, <i>\"Thank you for your business. Please come again\"</i>"

		pickupdialoguefailure = "[src.name] checks something on a strange device. <i>\"I'm sorry, but you don't have anything to pick up\"</i>."

	activatesecurity()
		for(var/mob/M in AIviewers(src))
			boutput(M, "<B>[src.name]</B> yells, \"mortigi c^iujn!\"")
		for(var/turf/T in get_area_turfs( get_area(src) ))
			for(var/obj/fakeobject/teleport_pad/D in T)
				var/mob/living/critter/martian/soldier/P = new /mob/living/critter/martian/soldier
				P.set_loc(D.loc)
				showswirl(P.loc)

////////Robot parent
ABSTRACT_TYPE(/obj/npc/trader/robot)
/obj/npc/trader/robot
	angrynope = "Unable to process request."
	whotext = "I am a trading unit. I have been authorized to engage in trade with you."
	picture = "robot.png"

	New()
		..()
		greeting= {"[src.name]'s eyes light up, and he states, \"Salutations organic, welcome to my shop. Please browse my wares.\""}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "[src.name] states, \"There are several individuals in my database that are looking to procure goods."

		buy_dialogue = "[src.name] states,\"Please select what you would like to buy\"."

		successful_sale_dialogue = list("[src.name] states, \"Thank you for the business organic.\"",
			"[src.name], \"I am adding you to the Good Customer Database.\"")

		failed_sale_dialogue = list("[src.name] states, \"<ERROR> Item not in purchase database.\"",
			"[src.name] states, \"I'm sorry I currently have no interest in that item, perhaps you should try another trader.\"",
			"[src.name] starts making a loud and irritating noise. [src.name] states, \"Fatal Exception Error: Cannot locate item\"",
			"[src.name] states, \"Invalid Input\"")

		successful_purchase_dialogue = list("[src.name] states, \"Thank you for your business\".",
			"[src.name] states, \"My logic drives calculate that was a wise purchase\".")

		failed_purchase_dialogue = list("[src.name] states, \"I am sorry, but you currenty do not have enough funds to purchase this.\"",
			"[src.name] states, \"Is this organic unit malfunctioning? You do not have enough funds to buy this\"")

		pickupdialogue = "[src.name] states, \"Thank you for your business. Please come again\"."

		pickupdialoguefailure = "[src.name] states, \"I'm sorry, but you don't have anything to pick up\"."

	activatesecurity()
		for(var/mob/M in AIviewers(src))
			boutput(M, "<B>[src.name]</B> exclaims, \"SECURITY SYSTEM COMING ONLINE\"")
		for(var/turf/T in get_area_turfs( get_area(src) ))
			for (var/obj/machinery/bot/guardbot/G in T)
				G.turn_on()

/obj/npc/trader/robot/medical
	name = "D.O.C."
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "medibot0"

	New()
		..()
		src.goods_sell += new /datum/commodity/medical/injectorbelt(src)
		src.goods_sell += new /datum/commodity/medical/strange_reagent(src)
		src.goods_sell += new /datum/commodity/medical/firstaidR(src)
		src.goods_sell += new /datum/commodity/medical/firstaidBr(src)
		src.goods_sell += new /datum/commodity/medical/firstaidB(src)
		src.goods_sell += new /datum/commodity/medical/firstaidT(src)
		src.goods_sell += new /datum/commodity/medical/firstaidO(src)
		src.goods_sell += new /datum/commodity/medical/firstaidN(src)
		src.goods_sell += new /datum/commodity/medical/firstaidC(src)
		src.goods_sell += new /datum/commodity/medical/injectorPent(src)
		src.goods_sell += new /datum/commodity/medical/injectorPerf(src)
		src.goods_sell += new /datum/commodity/bodyparts/cyberheart(src)
		src.goods_sell += new /datum/commodity/bodyparts/cyberbutt(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_sunglass(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_sechud(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_thermal(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_meson(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_spectro(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_prodoc(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_camera(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_monitor(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_laser(src)
		src.goods_sell += new /datum/commodity/bodyparts/cybereye_ecto(src)
		src.goods_sell += new /datum/commodity/bodyparts/l_cyberlung(src)
		src.goods_sell += new /datum/commodity/bodyparts/r_cyberlung(src)
		src.goods_sell += new /datum/commodity/bodyparts/l_cyberkidney(src)
		src.goods_sell += new /datum/commodity/bodyparts/r_cyberkidney(src)
		src.goods_sell += new /datum/commodity/bodyparts/cyberliver(src)
		src.goods_sell += new /datum/commodity/bodyparts/cyberspleen(src)
		src.goods_sell += new /datum/commodity/bodyparts/cyberstomach(src)
		src.goods_sell += new /datum/commodity/bodyparts/cyberintestines(src)
		src.goods_sell += new /datum/commodity/bodyparts/cyberpancreas(src)
		src.goods_sell += new /datum/commodity/bodyparts/cyberappendix(src)

		src.goods_buy += new /datum/commodity/bodyparts/armL(src)
		src.goods_buy += new /datum/commodity/bodyparts/armR(src)
		src.goods_buy += new /datum/commodity/bodyparts/legL(src)
		src.goods_buy += new /datum/commodity/bodyparts/legR(src)
		src.goods_buy += new /datum/commodity/bodyparts/brain(src)
		src.goods_buy += new /datum/commodity/bodyparts/synthbrain(src)
		src.goods_buy += new /datum/commodity/bodyparts/aibrain(src)
		src.goods_buy += new /datum/commodity/bodyparts/butt(src)
		src.goods_buy += new /datum/commodity/bodyparts/synthbutt(src)
		src.goods_buy += new /datum/commodity/bodyparts/heart(src)
		src.goods_buy += new /datum/commodity/bodyparts/synthheart(src)
		src.goods_buy += new /datum/commodity/bodyparts/l_eye(src)
		src.goods_buy += new /datum/commodity/bodyparts/r_eye(src)
		src.goods_buy += new /datum/commodity/bodyparts/syntheye(src)
		src.goods_buy += new /datum/commodity/bodyparts/l_lung(src)
		src.goods_buy += new /datum/commodity/bodyparts/r_lung(src)
		src.goods_buy += new /datum/commodity/bodyparts/l_kidney(src)
		src.goods_buy += new /datum/commodity/bodyparts/r_kidney(src)
		src.goods_buy += new /datum/commodity/bodyparts/liver(src)
		src.goods_buy += new /datum/commodity/bodyparts/spleen(src)
		src.goods_buy += new /datum/commodity/bodyparts/stomach(src)
		src.goods_buy += new /datum/commodity/bodyparts/intestines(src)
		src.goods_buy += new /datum/commodity/bodyparts/pancreas(src)
		src.goods_buy += new /datum/commodity/bodyparts/appendix(src)

/obj/npc/trader/robot/syndicate
	name = "C.A.R.L."
	icon = 'icons/mob/robots.dmi'
	icon_state = "syndibot"
	illegal = TRUE

	New()
		..()
		var/carlsell = rand(1,10)
		src.goods_illegal += new /datum/commodity/contraband/command_suit(src)
		src.goods_illegal += new /datum/commodity/contraband/command_helmet(src)
		src.goods_illegal += new /datum/commodity/contraband/disguiser(src)
		src.goods_illegal += new /datum/commodity/contraband/birdbomb(src)
		src.goods_illegal += new /datum/commodity/contraband/syndicate_headset(src)
		if (carlsell <= 3)
			src.goods_illegal += new /datum/commodity/contraband/radiojammer(src)
		if (carlsell >= 2 && carlsell <= 6)
			src.goods_illegal += new /datum/commodity/contraband/stealthstorage(src)
		if (carlsell >= 5 && carlsell <= 8)
			src.goods_illegal += new /datum/commodity/contraband/voicechanger(src)
		if (carlsell >= 9)
			src.goods_illegal += new /datum/commodity/contraband/radiojammer(src)
			src.goods_illegal += new /datum/commodity/contraband/stealthstorage(src)
			src.goods_illegal += new /datum/commodity/contraband/voicechanger(src)

		src.goods_sell += new /datum/commodity/contraband/spy_sticker_kit(src)
		src.goods_sell += new /datum/commodity/contraband/flare(src)
		src.goods_sell += new /datum/commodity/contraband/eguncell_highcap(src)
		src.goods_sell += new /datum/commodity/podparts/cloak(src)
		src.goods_sell += new /datum/commodity/podparts/redarmor(src)
		src.goods_sell += new /datum/commodity/podparts/ballistic_22(src)
		src.goods_sell += new /datum/commodity/podparts/ballistic_9mm(src)
		src.goods_sell += new /datum/commodity/podparts/ballistic(src)
		src.goods_sell += new /datum/commodity/podparts/artillery(src)
		src.goods_sell += new /datum/commodity/contraband/artillery_ammo(src)
		src.goods_sell += new /datum/commodity/contraband/ai_kit_syndie(src)
		src.goods_sell += new /datum/commodity/clothing_restock(src)
#ifdef UNDERWATER_MAP
		src.goods_sell += new /datum/commodity/HEtorpedo(src)
#endif

		src.goods_buy += new /datum/commodity/contraband/egun(src)
		src.goods_buy += new /datum/commodity/contraband/secheadset(src)
		src.goods_buy += new /datum/commodity/contraband/hosberet(src)
		src.goods_buy += new /datum/commodity/contraband/spareid(src)
		src.goods_buy += new /datum/commodity/contraband/captainid(src)
		src.goods_buy += new /datum/commodity/goldbar(src)

ABSTRACT_TYPE(/obj/npc/trader/robot/robuddy)
/obj/npc/trader/robot/robuddy
	icon = 'icons/obj/bots/robuddy/pr-1.dmi'
	icon_state = "body"

	New()
		..()
		src.UpdateOverlays(SafeGetOverlayImage("face", 'icons/obj/bots/robuddy/pr-1.dmi' ,"face-happy"), "face")
		src.UpdateOverlays(SafeGetOverlayImage("lights", 'icons/obj/bots/robuddy/pr-1.dmi' ,"lights-on"), "lights")

/obj/npc/trader/robot/robuddy/salvage
	name = "Thrifty B.O.B.";
	picture = "loungebuddy.png";

	New()
		..()
		src.goods_sell += new /datum/commodity/fuel(src)
		src.goods_sell += new /datum/commodity/junk/horsemask(src)
		src.goods_sell += new /datum/commodity/junk/batmask(src)
		src.goods_sell += new /datum/commodity/junk/johnny(src)
		src.goods_sell += new /datum/commodity/junk/buddy(src)
		src.goods_sell += new /datum/commodity/junk/cowboy_boots(src)
		src.goods_sell += new /datum/commodity/junk/cowboy_hat(src)
		src.goods_sell += new /datum/commodity/medical/injectormask(src)
		src.goods_sell += new /datum/commodity/contraband/briefcase(src)
		src.goods_sell += new /datum/commodity/boogiebot(src)
		src.goods_sell += new /datum/commodity/junk/voltron(src)
		src.goods_sell += new /datum/commodity/junk/cloner_upgrade(src)
		src.goods_sell += new /datum/commodity/junk/grinder_upgrade(src)
		src.goods_sell += new /datum/commodity/junk/speedyclone(src)
		src.goods_sell += new /datum/commodity/junk/efficientclone(src)
		src.goods_sell += new /datum/commodity/podparts/goldarmor(src)

		src.goods_buy += new /datum/commodity/salvage/scrap(src)
		src.goods_buy += new /datum/commodity/relics/gnome(src)
		src.goods_buy += new /datum/commodity/goldbar(src)

/obj/npc/trader/robot/robuddy/drugs
	name = "Sketchy D-5"
	desc = "The robot equivalent of that guy back on Earth who tried to sell you stolen military gear and drugs in the bathroom of an old greasy spoon."
	picture = "loungebuddy.png"
	greeting = "I got what you need."

	New()
		..()
		src.goods_sell += new /datum/commodity/podparts/engine(src)
		src.goods_sell += new /datum/commodity/podparts/laser(src)
		src.goods_sell += new /datum/commodity/podparts/asslaser(src)
		src.goods_sell += new /datum/commodity/podparts/blackarmor(src)
		src.goods_sell += new /datum/commodity/podparts/skin_stripe_r(src)
		src.goods_sell += new /datum/commodity/podparts/skin_stripe_b(src)
		src.goods_sell += new /datum/commodity/podparts/skin_flames(src)
		src.goods_sell += new /datum/commodity/contraband/ntso_uniform(src)
		src.goods_sell += new /datum/commodity/contraband/ntso_beret(src)
		src.goods_sell += new /datum/commodity/contraband/ntso_vest(src)
		src.goods_sell += new /datum/commodity/contraband/swatmask/NT(src)
		src.goods_sell += new /datum/commodity/drugs/sell/methamphetamine(src)
		src.goods_sell += new /datum/commodity/drugs/sell/crank(src)
		src.goods_sell += new /datum/commodity/drugs/sell/catdrugs(src)
		src.goods_sell += new /datum/commodity/drugs/sell/morphine(src)
		src.goods_sell += new /datum/commodity/drugs/sell/krokodil(src)
		src.goods_sell += new /datum/commodity/drugs/sell/lsd(src)
		src.goods_sell += new /datum/commodity/drugs/sell/lsd_bee(src)
		src.goods_sell += new /datum/commodity/relics/bootlegfirework(src)
		src.goods_sell += new /datum/commodity/pills/uranium(src)

		src.goods_buy += new /datum/commodity/drugs/buy/shrooms(src)
		src.goods_buy += new /datum/commodity/drugs/buy/cannabis(src)
		src.goods_buy += new /datum/commodity/drugs/buy/cannabis_mega(src)
		src.goods_buy += new /datum/commodity/drugs/buy/cannabis_white(src)
		src.goods_buy += new /datum/commodity/drugs/buy/cannabis_omega(src)

/obj/npc/trader/robot/robuddy/diner
	name = "B.I.F.F."
	desc = "The robot proprietor of the Diner. Deals in food that's to dine for!"
	picture = "loungebuddy.png"

	New()
		..()
		src.goods_sell += new /datum/commodity/diner/mysteryburger(src)
		src.goods_sell += new /datum/commodity/diner/sloppyjoe(src)
		src.goods_sell += new /datum/commodity/diner/mashedpotatoes(src)
		src.goods_sell += new /datum/commodity/diner/waffles(src)
		src.goods_sell += new /datum/commodity/diner/pancake(src)
		src.goods_sell += new /datum/commodity/diner/meatloaf(src)
		src.goods_sell += new /datum/commodity/diner/slurrypie(src)
		src.goods_sell += new /datum/commodity/diner/daily_special(src)

		src.goods_buy += new /datum/commodity/diner/monster(src)
		src.goods_buy += new /datum/commodity/produce/special/gmelon(src)
		src.goods_buy += new /datum/commodity/produce/special/greengrape(src)
		src.goods_buy += new /datum/commodity/produce/special/ghostchili(src)
		src.goods_buy += new /datum/commodity/produce/special/chilly(src)
		src.goods_buy += new /datum/commodity/produce/special/lashberry(src)
		src.goods_buy += new /datum/commodity/produce/special/purplegoop(src)
		src.goods_buy += new /datum/commodity/produce/special/glowfruit(src)

/// BZZZZZZZZZZZ

/obj/npc/trader/bee
	icon = 'icons/obj/trader.dmi'
	icon_state = "bee"
	picture = "bee.png"
	name = "Bombini" // like the tribe of bumblebees

	New()
		..()
		/////////////////////////////////////////////////////////
		//// sell list //////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_sell += new /datum/commodity/guardbot_kit(src)
		src.goods_sell += new /datum/commodity/guardbot_medicator(src)
		src.goods_sell += new /datum/commodity/guardbot_flash(src)
		src.goods_sell += new /datum/commodity/guardbot_taser(src)
		src.goods_sell += new /datum/commodity/guardbot_smoker(src)
		src.goods_sell += new /datum/commodity/royaljelly(src)
		src.goods_sell += new /datum/commodity/beeegg(src)
		src.goods_sell += new /datum/commodity/b33egg(src)
		src.goods_sell += new /datum/commodity/bee_kibble(src)
		/////////////////////////////////////////////////////////
		//// buy list ///////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_buy += new /datum/commodity/honey(src)
		src.goods_buy += new /datum/commodity/contraband/spareid/bee(src)
		src.goods_buy += new /datum/commodity/contraband/captainid/bee(src)
		src.goods_buy += new /datum/commodity/goldbar(src)
		/////////////////////////////////////////////////////////

		greeting= {"[src.name] buzzes cheerfully."}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "[src.name] bumbles a bit."

		buy_dialogue = "[src.name] buzzes inquisitively."

		angrynope = "[src.name] buzzes angrily."
		whotext = "[src.name] makes a bunch of buzzing noises. You are not sure what they mean."

		successful_sale_dialogue = list("[src.name] does a little dance. He looks pretty pleased.")

		failed_sale_dialogue = list("[src.name] grumbles.",
			"[src.name] buzzes grumpily.",
			"[src.name] grumpily bumbles.",
			"[src.name] looks sad. Look what you've gone and done.")

		successful_purchase_dialogue = list("[src.name] grustles.",
			"[src.name] buzzes happily. You feel happier too.")

		failed_purchase_dialogue = list("[src.name] gives a somber little buzz.",
			"[src.name] pouts. You feel pretty bad about yourself.")

		pickupdialogue = "[src.name] bumbles a bunch."

		pickupdialoguefailure = "[src.name] grumps."

	activatesecurity()
		for(var/mob/M in AIviewers(src))
			boutput(M, "<B>[src.name]</B> exclaims, \"BZZZZZZZZZZZ!\"")
		for(var/turf/T in get_area_turfs( get_area(src) ))
			for (var/obj/critter/domestic_bee/B in T)
				B.aggressive = 1 // be, aggressive. bee be aggressive
				B.atkcarbon = 1

	// OKAY we're tryin to do something here with the medal for the rescue allright?

	attackby(obj/item/W, mob/living/user)
		if (istype(W, /obj/item/coin/bombini))
			for(var/mob/M in AIviewers(src))
				boutput(M, "<B>[src.name]</B> buzzes excitedly! \"BZZ?? BZZ!!\"")
				M.unlock_medal("Bombini is Missing!", 1)
				M.add_karma(15) // This line originally tried to give the karma to Bombini. Definitely a bug but I like to imagine that she just managed to pickpocket your karma or something.
			user.u_equip(W)
			qdel(W)
		else
			..()



// Hon- I mean, hello sir.

/obj/npc/trader/exclown
	icon = 'icons/obj/trader.dmi'
	icon_state = "exclown"
	picture = "exclown.png"
	name = "Geoff Honkington"
	angrynope = "HO--nngh. Leave me alone."
	whotext = "Just an honest trader tryin' to make a living. Mind the banana peel, ya hear?"
	business_card = /obj/item/paper/businesscard/clowntown
	var/honk = 0

	New()
		..()
		/////////////////////////////////////////////////////////
		//// sell list //////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_sell += new /datum/commodity/costume/bee(src)
		src.goods_sell += new /datum/commodity/costume/monkey(src)
		src.goods_sell += new /datum/commodity/costume/robuddy(src)
		src.goods_sell += new /datum/commodity/costume/waltwhite(src)
		src.goods_sell += new /datum/commodity/costume/spiderman(src)
		src.goods_sell += new /datum/commodity/costume/wonka(src)
		src.goods_sell += new /datum/commodity/costume/goku(src)
		src.goods_sell += new /datum/commodity/costume/light_borg(src)
		src.goods_sell += new /datum/commodity/costume/utena(src)
		src.goods_sell += new /datum/commodity/costume/roller_disco(src)
		src.goods_sell += new /datum/commodity/costume/werewolf(src)
		src.goods_sell += new /datum/commodity/costume/vampire(src)
		src.goods_sell += new /datum/commodity/costume/abomination(src)
		src.goods_sell += new /datum/commodity/costume/hotdog(src)
		src.goods_sell += new /datum/commodity/costume/purpwitch(src)
		src.goods_sell += new /datum/commodity/costume/mintwitch(src)
		src.goods_sell += new /datum/commodity/costume/mime(src)
		src.goods_sell += new /datum/commodity/costume/mime/alt(src) //suspenders and such
		src.goods_sell += new /datum/commodity/costume/jester(src)
		src.goods_sell += new /datum/commodity/costume/blorbosuit(src)
		src.goods_sell += new /datum/commodity/backpack/breadpack(src)
		src.goods_sell += new /datum/commodity/backpack/bearpack(src)
		src.goods_sell += new /datum/commodity/backpack/turtlebrown(src)
		src.goods_sell += new /datum/commodity/backpack/turtlegreen(src)
		src.goods_sell += new /datum/commodity/balloons(src)
		src.goods_sell += new /datum/commodity/crayons(src)
		src.goods_sell += new /datum/commodity/sticker/googly_eyes(src)
		src.goods_sell += new /datum/commodity/sticker/googly_eyes_angry(src)
		src.goods_sell += new /datum/commodity/toygun(src)
		src.goods_sell += new /datum/commodity/toygunammo(src)
		src.goods_sell += new /datum/commodity/clownsabre(src)
		src.goods_sell += new /datum/commodity/junk/circus_board(src)
		src.goods_sell += new /datum/commodity/junk/pie_launcher(src)
		src.goods_sell += new /datum/commodity/junk/laughbox(src)
		src.goods_sell += new /datum/commodity/junk/ai_kit_clown(src)
		src.goods_sell += new /datum/commodity/junk/ai_kit_mime(src)
		src.goods_sell += new /datum/commodity/foam_dart_grenade(src)
		src.goods_sell += new /datum/commodity/costume/rabbitsuit(src)



		/////////////////////////////////////////////////////////
		//// buy list ///////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_buy += new /datum/commodity/goldbar(src)
		/////////////////////////////////////////////////////////

		greeting= {"Psst, I've got what you need HON- Ahem, disregard that."}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "Waddya have to sell?"

		buy_dialogue = "Feel free to browse my wares, but you better hurry!"

		successful_purchase_dialogue = list("Another satisfied customer.",
			"Thank you.",
			"It's been a pleasure doing business with you.")

		failed_sale_dialogue = list("Don't waste my time, kid, I can't buy that!",
			"I've got nobody who wants to buy that junk!",
			"What, do you think I'm stupid?!?  Get out of here!",
			"Haha, nice try kid, but I've been in the business longer than that.")

		successful_sale_dialogue = list("Thank you very much!",
			"I'll take it!",
			"Come back anytime!")

		failed_purchase_dialogue = list("Come back when you can afford this stuff!",
			"You ain't got the cash, kid!",
			"Might want to check your account, 'cause I don't see the money in it!")

		pickupdialogue = "Thank you very mhHHHONK- Uh, nothing."

		pickupdialoguefailure = "You need to BUY things before you pick them up!"

/obj/npc/trader/exclown/attackby(obj/item/W, mob/living/user)
	if (!src.honk && user.mind && user.mind.assigned_role == "Clown" && istype(W, /obj/item/toy/diploma))
		src.visible_message(SPAN_ALERT("<B>[user]</B> pokes [src] with [W]. [src] nods knowingly."))
		src.spawncrate(/obj/item/storage/box/banana_grenade_kit)
		src.honk = 1
	else
		..()

// Clack!

/obj/npc/trader/skeleton
	icon = 'icons/obj/trader.dmi'
	icon_state = "skeleton"
	picture = "skeleton.png"
	name = "Clack Hat"
	angrynope = "Not now."
	whotext = "I am a trader."

	New()
		..()
		/////////////////////////////////////////////////////////
		//// sell list //////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_sell += new /datum/commodity/hat/bandana(src)
		src.goods_sell += new /datum/commodity/hat/beret(src)
		src.goods_sell += new /datum/commodity/hat/spacehelmet(src)
		src.goods_sell += new /datum/commodity/hat/spacehelmet/red(src)
		src.goods_sell += new /datum/commodity/hat/pinkwizard(src)
		src.goods_sell += new /datum/commodity/hat/purplebutt(src)
		src.goods_sell += new /datum/commodity/hat/dailyspecial(src)
		src.goods_sell += new /datum/commodity/hat/laurels(src)
		src.goods_sell += new /datum/commodity/tech/laptop(src)
		/////////////////////////////////////////////////////////
		//// buy list ///////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_buy += new /datum/commodity/contraband/hosberet(src)
		/////////////////////////////////////////////////////////

		greeting= {"Hello there, space-faring friend."}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "What can I relieve you of?"

		buy_dialogue = "What would you like to purchase?"

		successful_purchase_dialogue = list("Lovely, lovely.",
			"Enjoy.",
			"Cheers.")

		failed_sale_dialogue = list("I'm not interested in that.",
			"Don't you have anything else?")

		successful_sale_dialogue = list("Sounds good to me.",
			"Sure, I'll take it.")

		failed_purchase_dialogue = list("You're a bit lacking in funds.",
			"Take a second look at my prices.")

		pickupdialogue = "Here are your things."

		pickupdialoguefailure = "I don't believe you've bought anything yet."

// It's Chad from Sealab!

/obj/npc/trader/chad
	icon = 'icons/obj/trader.dmi'
	icon_state = "chad"
	picture = "chad.png"
	name = "Chad"
	angrynope = "Piss off, bro!"
	whotext = "What does it look like, man?"

	New()
		..()
		/////////////////////////////////////////////////////////
		//// sell list //////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_sell += new /datum/commodity/diner/onigiri(src)
		src.goods_sell += new /datum/commodity/diner/nigiri_roll(src)
		src.goods_sell += new /datum/commodity/diner/sushi_roll(src)
		src.goods_sell += new /datum/commodity/diner/fishfingers(src)
		src.goods_sell += new /datum/commodity/diner/fishburger(src)
		src.goods_sell += new /datum/commodity/diner/luauburger(src)
		src.goods_sell += new /datum/commodity/diner/tikiburger(src)
		src.goods_sell += new /datum/commodity/diner/coconutburger(src)
		/////////////////////////////////////////////////////////
		//// buy list ///////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_buy += new /datum/commodity/produce/special/gmelon(src)
		src.goods_buy += new /datum/commodity/produce/special/lashberry(src)
		src.goods_buy += new /datum/commodity/produce/special/glowfruit(src)
		src.goods_buy += new /datum/commodity/produce/special/goldfishcracker(src)
		/////////////////////////////////////////////////////////

		greeting= {"Sup, man!"}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "Got anythin' good for me?"

		buy_dialogue = "You want to see my catch, bro?"

		successful_purchase_dialogue = list("Thanks, bro!",
			"Pleasure doin' business.")

		failed_sale_dialogue = list("No can do.",
			"I'm not takin' that.")

		successful_sale_dialogue = list("Lookin' good.",
			"You know me well.")

		failed_purchase_dialogue = list("I'd lend you some money, but I gotta eat, man!",
			"You sure you got the cash?")

		pickupdialogue = "Have at it pal."

		pickupdialoguefailure = "There ain't nothin' to pick up, bro!"

/obj/npc/trader/hand
	icon = 'icons/obj/trader.dmi'
	icon_state = "hand"
	picture = "hand.png"
	name = "A hand sticking out from a toilet"

	New()
		..()
		/////////////////////////////////////////////////////////
		//// sell list //////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_sell += new /datum/commodity/pills/uranium(src)
		src.goods_sell += new /datum/commodity/drugs/sell/methamphetamine(src)
		src.goods_sell += new /datum/commodity/drugs/sell/crank(src)
		src.goods_sell += new /datum/commodity/drugs/sell/catdrugs(src)
		src.goods_sell += new /datum/commodity/drugs/sell/morphine(src)
		src.goods_sell += new /datum/commodity/drugs/sell/krokodil(src)
		src.goods_sell += new /datum/commodity/drugs/sell/lsd(src)
		src.goods_sell += new /datum/commodity/drugs/sell/lsd_bee(src)
		src.goods_sell += new /datum/commodity/medical/ether(src)
		src.goods_sell += new /datum/commodity/medical/toxin(src)
		src.goods_sell += new /datum/commodity/medical/cyanide(src)
		src.goods_sell += new /datum/commodity/medical/omnizine(src)
		src.goods_sell += new /datum/commodity/medical/strange_reagent(src)
		src.goods_sell += new /datum/commodity/medical/injectorbelt(src)
		/////////////////////////////////////////////////////////
		//// buy list ///////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_buy += new /datum/commodity/drugs/buy/poppies(src)
		src.goods_buy += new /datum/commodity/drugs/buy/shrooms(src)
		src.goods_buy += new /datum/commodity/drugs/buy/cannabis(src)
		src.goods_buy += new /datum/commodity/drugs/buy/cannabis_mega(src)
		src.goods_buy += new /datum/commodity/drugs/buy/cannabis_white(src)
		src.goods_buy += new /datum/commodity/drugs/buy/cannabis_omega(src)
		/////////////////////////////////////////////////////////

		greeting= {"<i>A hand sticking out from a toilet waves in your direction.</i>"}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "<i>A hand sticking out from a toilet points at itself.</i>"

		buy_dialogue = "<i>A hand sticking out from a toilet points at you and beckons.</i>"

		angrynope = "<i>A hand sticking out from a toilet gives you the middle finger. Rude.</i>"
		whotext = "<i>A hand sticking out from a toilet waves at you.</i>"

		successful_purchase_dialogue = list("<i>A hand sticking out from a toilet flashes the peace sign.</i>",
			"<i>A hand sticking out from a toilet gives you the thumbs up.</i>",
			"<i>A hand sticking out from a toilet snaps.</i>")

		failed_sale_dialogue = list("<i>A hand sticking out from a toilet flips you off.</i>",
			"<i>A hand sticking out from a toilet gestures angrily.</i>")

		successful_sale_dialogue = list("<i>A hand sticking out from a toilet does a jazz hand.</i>",
			"<i>A hand sticking out from a toilet gives you the universal gesture for OK.</i>")

		failed_purchase_dialogue = list("<i>A hand sticking out from a toilet twitches.</i>",
			"<i>A hand sticking out from a toilet gives you the bird.</i>")

		pickupdialogue = "<i>A hand sticking out from a toilet points at you and then at itself.</i>"

		pickupdialoguefailure = "<i>A hand sticking out from a toilet flails around for a bit.</i>"

/obj/npc/trader/twins
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "twins"
	picture = "twins.png"
	name = "Carol and Lynn"

	bound_width = 64
	bound_height = 32

	New()
		..()
		/////////////////////////////////////////////////////////
		//// sell list //////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_sell += new /datum/commodity/hat/laurels(src)
		src.goods_sell += new /datum/commodity/contraband/ntso_beret(src)
		src.goods_sell += new /datum/commodity/clothing/psyche(src)
		src.goods_sell += new /datum/commodity/clothing/chameleon(src)
		src.goods_sell += new /datum/commodity/banana_grenade(src)
		src.goods_sell += new /datum/commodity/cheese_grenade(src)
		src.goods_sell += new /datum/commodity/corndog_grenade(src)
		src.goods_sell += new /datum/commodity/gokart(src)
		src.goods_sell += new /datum/commodity/car(src)
		/////////////////////////////////////////////////////////
		//// buy list ///////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_buy += new /datum/commodity/menthol_cigarettes(src)
		src.goods_buy += new /datum/commodity/propuffs(src)
		/////////////////////////////////////////////////////////

		greeting= {"Oh thank God, we have a customer!"}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "Please, use as much money as you can!"

		buy_dialogue = "Oh! You sell things?"

		angrynope = "Nope! Not interested. Come back later."
		whotext = "We're here to sell you stuff!"

		successful_purchase_dialogue = list("Like taking candy from a baby - I mean - it sure is swell to have customers!",\
		    "Thank God! And thank you for buyin' somethin'!",\
		    "Ah! You startled me! With your kindness!")

		failed_sale_dialogue = list("Hell no!",
		    "Not even my sister would buy this!")

		successful_sale_dialogue = list("You're actually selling that?",\
		    "Thank you!!")

		failed_purchase_dialogue = list("We want money!",\
		    "Cheapskate!")

		pickupdialogue = "Here you are."

		pickupdialoguefailure = "No."



/*

/obj/npc/trader/flexx
	icon = 'icons/obj/64.dmi'
	icon_state = "flexx"
	picture = "flexx.png"
	name = "Flexx"
	angrynope = "Not cool, champ!"
	whotext = "Yo, buddy, name's Flexx. Whaddup?"

	New()
		..()
		/////////////////////////////////////////////////////////
		//// sell list //////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_sell += new /datum/commodity/hat/bandana(src)
		src.goods_sell += new /datum/commodity/hat/beret(src)
		src.goods_sell += new /datum/commodity/hat/spacehelmet(src)
		src.goods_sell += new /datum/commodity/hat/spacehelmet/red(src)
		src.goods_sell += new /datum/commodity/hat/pinkwizard(src)
		src.goods_sell += new /datum/commodity/hat/purplebutt(src)
		src.goods_sell += new /datum/commodity/hat/dailyspecial(src)
		src.goods_sell += new /datum/commodity/hat/laurels(src)
		src.goods_sell += new /datum/commodity/tech/laptop(src)
		/////////////////////////////////////////////////////////
		//// buy list ///////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_buy += new /datum/commodity/contraband/hosberet(src)
		/////////////////////////////////////////////////////////

		greeting= {"Hello there, space-faring friend."}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "What can I relieve you of?"

		buy_dialogue = "What would you like to purchase?"

		successful_purchase_dialogue = list("Lovely, lovely.",
			"Enjoy.",
			"Cheers.")

		failed_sale_dialogue = list("I'm not interested in that.",
			"Don't you have anything else?")

		successful_sale_dialogue = list("Sounds good to me.",
			"Sure, I'll take it.")

		failed_purchase_dialogue = list("You're a bit lacking in funds.",
			"Take a second look at my prices.")

		pickupdialogue = "Here are your things."

		pickupdialoguefailure = "I don't believe you've bought anything yet."


*/
