/obj/npc/station_trader //separate obj because he has a lot of different behaviours eg. no buying, no set area, no defence systems to activate
	name="Shady Robot"
	icon = 'icons/misc/evilreaverstation.dmi' //temporary
	icon_state = "pr1_b"
	picture = "robot.png"
	var/hiketolerance = 20 //How much they will tolerate price hike
	var/list/droplist = null //What the merchant will drop upon their death
	var/list/goods_sell = new/list() //What products the trader sells
	var/list/shopping_cart = new/list() //What has been bought
	var/obj/item/sell = null //Item to sell
	var/portrait_setup = null
	var/obj/item/sellitem = null
	var/item_name = "--------"
	var/obj/item/card/id/scan = null
	//Trader dialogue
	var/buy_dialogue = null
	var/list/successful_sale_dialogue = null
	var/list/failed_sale_dialogue = null
	var/list/successful_purchase_dialogue = null
	var/list/failed_purchase_dialogue = null
	var/pickupdialogue = null
	var/pickupdialoguefailure = null
	var/list/trader_areas = list(/area/station/maintenance/solar/south,/area/station/solar/south,/area/station/maintenance/east,/area/station/maintenance/southeast,/area/station/maintenance/solar/east,/area/station/solar/east,/area/station/maintenance/south,/area/station/maintenance/disposal,/area/station/maintenance/southwest,/area/station/maintenance/solar/west,/area/station/solar/west,/area/station/hallway/secondary/construction,/area/station/maintenance/northwest
,/area/station/crew_quarters/quartersA,/area/station/crew_quarters/quartersB,/area/station/crew_quarters/observatory,/area/station/wreckage,/area/station/maintenance/north,/area/station/maintenance/central
)
	var/doing_a_thing = 0

		// This list is in a specific order!!
	// String 1 - player is being dumb and hiked a price up when buying, trader accepted it because they're a dick
	// String 2 - same as above only the trader is being nice about it
	// String 3 - player haggled further than the trader is willing to tolerate
	// String 4 - trader has had enough of your bullshit and is leaving
	var/list/errormsgs = list("...huh. If you say so!",
								"Huh? You want to pay <i>more</i> for my wares than i'm offering?",
								"What the f... umm, no? Make me a serious offer.",
								"Sorry, you're terrible at this. I must be going.")
	// Next list - the last entry will always be used on the trader's final haggling offer
	// otherwise the trader picks randomly from the list including the "final offer" in order to bluff players
	var/list/hagglemsgs = list("Alright, how's this sound?",
								"You drive a hard bargain. How's this price?",
								"You're busting my balls here. How's this?",
								"I'm being more than generous here, I think you'll agree.",
								"This is my final offer. Can't do better than this.")

	//CARD VARS
	var/card_registered = null		//who is the card registered to?
	var/card_assignment = null		//what job does it have?
	var/card_icon_state = "id"		//which icon should we use?
	var/card_icon_price = 0			//how much does that icon cost (flat price)?
	var/card_duration = 60			//how long will the card's access last?
	var/list/card_access = list()	//what access will it have?
	var/card_price = 0				//total card price (calculated when updatecardprice() is called)
	var/card_timer = 0				//does the card display time remaining before its access runs out (costs 1000)?

	//ACCESS LISTS FOR PRICING & SORTING
	var/list/civilian_access_list = list(6, 12, 22, 23, 25, 26, 27, 28, 35, 36)
	var/list/engineering_access_list = list(13, 32, 40, 43, 44, 45, 46, 47, 48)
	var/list/supply_access_list = list(30, 31, 34, 47, 50, 51)
	var/list/research_access_list = list(5, 7, 8, 9, 10, 24, 29, 33)
	var/list/security_access_list = list(1, 2, 3, 4, 37, 38, 39)
	var/list/command_access_list = list(11, 14, 15, 16, 17, 18, 19, 20, 21, 49, 53)
	var/list/special_access_list = list(37)

	//PRODUCTS
	var/list/common_products = list(/datum/commodity/bodyparts/butt,
	/datum/commodity/contraband/ntso_uniform,
	/datum/commodity/contraband/ntso_vest,
	/datum/commodity/contraband/ntso_beret,
	/datum/commodity/drugs/methamphetamine,
	/datum/commodity/drugs/crank,
	/datum/commodity/drugs/catdrugs,
	/datum/commodity/drugs/morphine,
	/datum/commodity/drugs/krokodil,
	/datum/commodity/drugs/lsd,
	/datum/commodity/drug/lsd_bee,
	/datum/commodity/drugs/shrooms,
	/datum/commodity/drugs/cannabis,
	/datum/commodity/drugs/cannabis_mega,
	/datum/commodity/drugs/cannabis_white,
	/datum/commodity/drugs/cannabis_omega,
	/datum/commodity/produce/special/ghostchili,
	/datum/commodity/contraband/secheadset,
	/datum/commodity/medical/strange_reagent,
	/datum/commodity/drugs/cyberpunk,
	/datum/commodity/contraband/swatmask,
	/datum/commodity/contraband/briefcase,
	/datum/commodity/bodyparts/heart,
	/datum/commodity/bodyparts/r_eye,
	/datum/commodity/bodyparts/l_eye,
	/datum/commodity/sketchy_press_upgrade)

	var/num_common_products = 13 //how many of these to pick for sale

	var/list/rare_products = list(/datum/commodity/contraband/radiojammer,/datum/commodity/contraband/stealthstorage,/datum/commodity/medical/injectorbelt,/datum/commodity/medical/injectormask,/datum/commodity/junk/voltron,/datum/commodity/laser_gun,/datum/commodity/relics/crown,/datum/commodity/contraband/egun,/datum/commodity/relics/armor,/datum/commodity/contraband/voicechanger,/datum/commodity/contraband/chamsuit,/datum/commodity/contraband/dnascram)
	var/num_rare_products = 2 //how many of these to pick for sale

	New()
		..()
		teleport()
		process()

		for(var/i = 1 to num_common_products)
			var/datum/commodity/C = pick(common_products)
			goods_sell += new C(src)
			common_products -= C //so we don't get duplicates

		for(var/i = 1 to num_rare_products)
			var/datum/commodity/C = pick(rare_products)
			goods_sell += new C(src)
			rare_products -= C //so we don't get duplicates

	proc/process()
		SPAWN(30 SECONDS)
			if(prob(20) && !scan)
				teleport()
			process()

	anger()
		for(var/mob/M in AIviewers(src))
			boutput(M, "<span class='alert'><B>[src.name]</B> becomes angry!</span>")
		src.desc = "[src] looks angry."
		teleport()
		SPAWN(rand(1000,3000))
			src.visible_message("<b>[src.name] calms down.</b>")
			src.desc = "[src] looks a bit annoyed."
			src.temp = "[src.name] has calmed down.<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
			src.angry = 0
		return

	proc/teleport()
		var/area/A = pick(trader_areas)
		var/turf/target = null
		var/list/locs = list()

		for(var/turf/T in A)
			var/dense = 0
			if(T.density)
				dense = 1
			else
				for(var/obj/O in T)
					if(O.density)
						dense = 1
						break
			if(dense == 0) locs += T

		if(!locs.len) return

		target = pick(locs)

		showswirl(src.loc)
		src.set_loc(target)
		showswirl(target)

		//reset stuff to default
		card_registered = null
		card_assignment = null
		card_icon_state = "id"
		card_icon_price = 0
		card_duration = 60
		card_access = list()
		card_price = 0
		card_timer = 0

		return

	attack_hand(var/mob/user)
		if(..())
			return
		if(angry)
			boutput(user, "<span class='alert'>[src] is angry and won't trade with anyone right now.</span>")
			return
		src.add_dialog(user)
		var/dat = updatemenu()
		if(!temp)
			dat += {"[src.greeting]<HR>
			<A href='?src=\ref[src];temp_card=1'>Purchase Temporary ID</A><BR>
			<A href='?src=\ref[src];purchase=1'>Purchase Items</A><BR>
			<A href='?src=\ref[src];viewcart=1'>View Cart</A><BR>
			<A href='?src=\ref[src];pickuporder=1'>I'm Ready to Pick Up My Order</A><BR>
			<A href='?action=mach_close&window=trader'>Goodbye</A>"}

		user.Browse(dat, "window=trader;size=575x530")
		onclose(user, "trader")
		return

	disposing()
		goods_sell = null
		shopping_cart = null
		..()

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)
		///////////////////////////////
		///////Generate Purchase List//
		///////////////////////////////
		if (href_list["temp_card"])
			src.temp = "I can hook you up with a temporary ID, just let me know what you need.<HR><BR>"
			src.temp = "<b>Price: [card_price] credits</b><BR><BR>"
			src.temp += "Registered: <a href='?src=\ref[src];registered=1'>[card_registered ? card_registered : "--------"]</a><BR>"
			src.temp += "Assignment: <a href='?src=\ref[src];assignment=1'>[card_assignment ? card_assignment : "--------"]</a><BR>"
			src.temp += "Duration: <a href='?src=\ref[src];duration=1'>[card_duration ? card_duration : "--------"] seconds</a><BR>"
			if(card_timer)
				src.temp += "Timer (1000 credits): <b>Yes</b>/<a href='?src=\ref[src];timer=0'>No</a><BR>"
			else
				src.temp += "Timer (1000 credits): <a href='?src=\ref[src];timer=1'>Yes</a>/<b>No</b><BR>"

			//Change access to individual areas
			src.temp += "<br><br><u>Access</u>"
			src.temp += "<br>Prices are per second."

			//Organised into sections
			var/civilian_access = "<br>Staff (1):"
			var/engineering_access = "<br>Engineering (2):"
			/* Conor12: I removed some unused accesses as the page is large enough, add these if they ever get used:
			41 (access_engineering_storage)
			42 (access_engineering_eva)*/
			var/supply_access = "<br>Supply (2):"
			var/research_access = "<br>Science and Medical (5):"
			var/security_access = "<br>Security (10):"
			var/command_access = "<br>Command (10):"
			var/special_access = "<br>Special (50):"

			for(var/A in access_name_lookup)
				if(access_name_lookup[A] in src.card_access)
					//Click these to remove access
					if (access_name_lookup[A] in civilian_access_list)
						civilian_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=0'><font color=\"red\">[replacetext(A, " ", "&nbsp")]</font></a>"
					if (access_name_lookup[A] in engineering_access_list)
						engineering_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=0'><font color=\"red\">[replacetext(A, " ", "&nbsp")]</font></a>"
					if (access_name_lookup[A] in supply_access_list)
						supply_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=0'><font color=\"red\">[replacetext(A, " ", "&nbsp")]</font></a>"
					if (access_name_lookup[A] in research_access_list)
						research_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=0'><font color=\"red\">[replacetext(A, " ", "&nbsp")]</font></a>"
					if (access_name_lookup[A] in security_access_list)
						security_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=0'><font color=\"red\">[replacetext(A, " ", "&nbsp")]</font></a>"
					if (access_name_lookup[A] in command_access_list)
						command_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=0'><font color=\"red\">[replacetext(A, " ", "&nbsp")]</font></a>"
				else//Click these to add access
					if (access_name_lookup[A] in civilian_access_list)
						civilian_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=1'>[replacetext(A, " ", "&nbsp")]</a>"
					if (access_name_lookup[A] in engineering_access_list)
						engineering_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=1'>[replacetext(A, " ", "&nbsp")]</a>"
					if (access_name_lookup[A] in supply_access_list)
						supply_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=1'>[replacetext(A, " ", "&nbsp")]</a>"
					if (access_name_lookup[A] in research_access_list)
						research_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=1'>[replacetext(A, " ", "&nbsp")]</a>"
					if (access_name_lookup[A] in security_access_list)
						security_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=1'>[replacetext(A, " ", "&nbsp")]</a>"
					if (access_name_lookup[A] in command_access_list)
						command_access += " <a href='?src=\ref[src];access=[access_name_lookup[A]];allowed=1'>[replacetext(A, " ", "&nbsp")]</a>"

			if(37 in src.card_access)
				special_access += " <a href='?src=\ref[src];access=37;allowed=0'><font color=\"red\">Head of Security</font></a>"
			else
				special_access += " <a href='?src=\ref[src];access=37;allowed=1'>Head of Security</a>"

			src.temp += "[civilian_access][engineering_access][supply_access][research_access][security_access][command_access][special_access]"

			src.temp += "<br><br><u>Customise ID</u><br>"
			src.temp += "[src.card_icon_state == "id" ? "<font color=\"red\">" : ""]<a href='?src=\ref[src];colour=none'>Plain</a>[src.card_icon_state == "id" ? "</font> " : " "]"
			src.temp += "[src.card_icon_state == "id_civ" ? "<font color=\"red\">" : ""]<a href='?src=\ref[src];colour=blue'>Civilian</a>[src.card_icon_state == "id_civ" ? "</font> " : " "]"
			src.temp += "[src.card_icon_state == "id_clown" ? "<font color=\"red\">" : ""]<a href='?src=\ref[src];colour=clown'>Clown</a>[src.card_icon_state == "id_clown" ? "</font> " : " "]"
			src.temp += "[src.card_icon_state == "id_eng" ? "<font color=\"red\">" : ""]<a href='?src=\ref[src];colour=yellow'>Engineering</a>[src.card_icon_state == "id_eng" ? "</font> " : " "]"
			src.temp += "[src.card_icon_state == "id_res" ? "<font color=\"red\">" : ""]<a href='?src=\ref[src];colour=purple'>Research</a>[src.card_icon_state == "id_res" ? "</font> " : " "]"
			src.temp += "[src.card_icon_state == "id_sec" ? "<font color=\"red\">" : ""]<a href='?src=\ref[src];colour=red'>Security</a>[src.card_icon_state == "id_sec" ? "</font> " : " "]"
			src.temp += "[src.card_icon_state == "id_com" ? "<font color=\"red\">" : ""]<a href='?src=\ref[src];colour=green'>Command</a>[src.card_icon_state == "id_com" ? "</font> " : " "]"
			src.temp += "[src.card_icon_state == "gold" ? "<font color=\"red\">" : ""]<a href='?src=\ref[src];colour=gold'>Captain</a>[src.card_icon_state == "gold" ? "</font>" : ""]"

			src.temp += "<BR><A href='?src=\ref[src];buycard=1'>Purchase</A>"
			src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Back</A>"

		if (href_list["access"] && href_list["allowed"])
			var/access_type = text2num_safe(href_list["access"])
			var/access_allowed = text2num_safe(href_list["allowed"])

			if(access_type == 37)
				src.card_access -= access_type
				if(access_allowed == 1)
					src.card_access += access_type
			else if(access_type in get_all_accesses())
				src.card_access -= access_type
				if(access_allowed == 1)
					src.card_access += access_type

			updatecardprice()
			href = "temp_card=1"
			src.Topic(href, params2list(href))

		if(href_list["timer"])
			src.card_timer = text2num_safe(href_list["timer"])

			updatecardprice()
			href = "temp_card=1"
			src.Topic(href, params2list(href))

		if (href_list["colour"])
			var/newcolour = href_list["colour"]
			switch(newcolour)
				if ("none")
					src.card_icon_state = "id"
					src.card_icon_price = 0
				if ("blue")
					src.card_icon_state = "id_civ"
					src.card_icon_price = 0
				if ("clown")
					src.card_icon_state = "id_clown"
					src.card_icon_price = 0
				if ("yellow")
					src.card_icon_state = "id_eng"
					src.card_icon_price = 500
				if ("purple")
					src.card_icon_state = "id_res"
					src.card_icon_price = 500
				if ("red")
					src.card_icon_state = "id_sec"
					src.card_icon_price = 1000
				if ("green")
					src.card_icon_state = "id_com"
					src.card_icon_price = 2000
				if ("gold")
					src.card_icon_state = "gold"
					src.card_icon_price = 5000

			updatecardprice()
			href = "temp_card=1"
			src.Topic(href, params2list(href))

		if (href_list["registered"])
			src.card_registered = input("Registered name?","Temporary ID")

			href = "temp_card=1"
			src.Topic(href, params2list(href))

		if (href_list["assignment"])
			src.card_assignment = input("Job title?","Temporary ID")

			href = "temp_card=1"
			src.Topic(href, params2list(href))

		if (href_list["duration"])
			var/input = input("Duration in seconds (1-600)?","Temporary ID") as num
			if(isnum_safe(input))
				src.card_duration = clamp(input, 1, 600)

			updatecardprice()
			href = "temp_card=1"
			src.Topic(href, params2list(href))

		if (href_list["buycard"])
			if(!scan)
				src.temp = {"You have to scan a card in first.<BR>
							<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"}
				src.updateUsrDialog()
				return
			updatecardprice() //should be updated but just to be sure
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			if(!account)
				src.temp = {"That's odd I can't seem to find your account
							<BR><A href='?src=\ref[src];purchase=1'>OK</A>"}
			else if(account["current_money"] < src.card_price)
				src.temp = {"Sorry [pick("buddy","pal","mate","friend","chief","bud","boss","champ")], you can't afford that!<BR>
							<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"}
			else
				if(spawncard())
					account["current_money"] -= src.card_price
					src.temp = {"There ya go. You've got [src.card_duration] seconds to abuse that thing before its access is revoked.<BR>
								<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"}
					//reset to default so people can't go snooping and find out the last ordered card
					card_registered = null
					card_assignment = null
					card_icon_state = "id"
					card_icon_price = 0
					card_duration = 60
					card_access = list()
					card_price = 0
					card_timer = 0

		if (href_list["purchase"])
			src.temp =buy_dialogue + "<HR><BR>"
			for(var/datum/commodity/N in goods_sell)
				// Have to send the type instead of a reference to the obj because it would get caught by the garbage collector. oh well.
				src.temp += {"<A href='?src=\ref[src];doorder=\ref[N]'><B><U>[N.comname]</U></B></A><BR>
				<B>Cost:</B> [N.price] Credits<BR>
				<B>Description:</B> [N.desc]<BR>
				<A href='?src=\ref[src];haggleb=\ref[N]'><B><U>Haggle</U></B></A><BR><BR>"}
			src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Ok</A>"
		//////////////////////////////////////////////
		///////Handle the buying of a specific item //
		//////////////////////////////////////////////
		else if (href_list["doorder"])
			if(!scan)
				src.temp = {"You have to scan a card in first.<BR>
							<BR><A href='?src=\ref[src];purchase=1'>OK</A>"}
				src.updateUsrDialog()
				return
			if (src.scan.registered in FrozenAccounts)
				boutput(usr, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
				return
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			if (account)
				var/quantity = 1
				quantity = input("How many units do you want to purchase? Maximum: 10", "Trader Purchase", null, null) as num
				if(!isnum_safe(quantity))
					return
				if (quantity < 1)
					quantity = 0
					return
				else if (quantity >= 10)
					quantity = 10

				////////////
				var/datum/commodity/P = locate(href_list["doorder"])

				if(P)
					if(account["current_money"] >= P.price * quantity)
						account["current_money"] -= P.price * quantity
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
				var/datum/commodity/N = locate(href_list["haggleb"])
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

		///////////////////////////////////
		////////Handle Bank account Set-Up ///////
		//////////////////////////////////
		else if (href_list["card"])
			if (src.scan) src.scan = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/card/id) || (istype(I, /obj/item/device/pda2) && I:ID_card))
					if (istype(I, /obj/item/device/pda2) && I:ID_card) I = I:ID_card
					boutput(usr, "<span class='notice'>You swipe the ID card in the card reader.</span>")
					var/datum/db_record/account = null
					account = FindBankAccountByName(I:registered)
					if(account)
						var/enterpin = usr.enter_pin("Card Reader")
						if (enterpin == I:pin)
							boutput(usr, "<span class='notice'>Card authorized.</span>")
							src.scan = I
						else
							boutput(usr, "<span class='alert'>Pin number incorrect.</span>")
							src.scan = null
					else
						boutput(usr, "<span class='alert'>No bank account associated with this ID found.</span>")
						src.scan = null

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

	/////////////////////////////////////////////
	/////Update the menu with the default items
	////////////////////////////////////////////

	proc/updatemenu()

		var/dat
		dat = portrait_setup
		dat +="<B>Scanned Card:</B> <A href='?src=\ref[src];card=1'>([src.scan])</A><BR>"
		if(scan)
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			if (account)
				dat+="<B>Current Funds</B>: [account["current_money"]] Credits<HR>"
			else
				dat+="<HR>"
		else
			dat+="<HR>"
		if(temp)
			dat+=temp
		return dat

	/////////////////////////////////////////////
	/////Update card price
	////////////////////////////////////////////

	proc/updatecardprice()
		var/access_price = 0
		for(var/access in card_access)
			if(access in civilian_access_list)
				access_price += 1
			else if(access in engineering_access_list)
				access_price += 2
			else if(access in supply_access_list)
				access_price += 2
			else if(access in research_access_list)
				access_price += 5
			else if(access in security_access_list)
				access_price += 10
			else if(access in command_access_list)
				access_price += 10
			else if(access in special_access_list)
				access_price += 50

		src.card_price = src.card_icon_price + 1000*card_timer + src.card_duration*access_price

	////////////////////////////////////////
	/////// Spawn the crate or card ////////
	////////////////////////////////////////

	proc/spawncrate()
		var/turf/pickedloc = get_step(src.loc,src.dir)
		if(!pickedloc || pickedloc.density)
			var/list/locs = list()
			for(var/turf/T in view(1,src))
				var/dense = 0
				if(T.density)
					dense = 1
				else
					for(var/obj/O in T)
						if(O.density)
							dense = 1
							break
				if(dense == 0) locs += T
			pickedloc = pick(locs)

		if(!pickedloc)
			src.visible_message("[src.name] glances around as if confused, then shrugs.")
			teleport()
			return

		var/atom/A = new /obj/storage/crate(pickedloc)
		showswirl(pickedloc)
		A.name = "Goods Crate ([src.name])"
		for(var/obj/O in shopping_cart)
			O.set_loc(A)
		shopping_cart = new/list()

	proc/spawncard()
		var/turf/pickedloc = get_step(src.loc,src.dir)
		if(!pickedloc || pickedloc.density)
			var/list/locs = list()
			for(var/turf/T in view(1,src))
				var/dense = 0
				if(T.density)
					dense = 1
				else
					for(var/obj/O in T)
						if(O.density)
							dense = 1
							break
				if(dense == 0) locs += T
			pickedloc = pick(locs)

		if(!pickedloc)
			src.visible_message("[src.name] glances around as if confused, then shrugs.")
			teleport()
			return 0

		var/obj/item/card/id/temporary/I = new /obj/item/card/id/temporary(pickedloc)
		showswirl(pickedloc)
		I.name = "[src.card_registered]'s ID Card ([src.card_assignment])"
		I.registered = card_registered
		I.assignment = card_assignment
		I.icon_state = card_icon_state
		I.duration = card_duration
		I.access = card_access
		I.timer = card_timer

		return 1

	////////////////////////////////////////////////////
	/////////Proc for haggling with dealer ////////////
	///////////////////////////////////////////////////
	proc/haggle(var/askingprice, var/buying, var/datum/commodity/H)
		// if something's gone wrong and there's no input, reject the haggle
		// also reject if there's no change in the price at all
		if (!askingprice) return
		if (askingprice == H.price) return
		// if the player is being dumb and haggling in the wrong direction, tell them (unless the trader is an asshole)

		// we're buying, so we want to pay less per unit
		if(askingprice > H.price)
			src.temp = src.errormsgs[2]
			return

		// check if the price increase % of the haggle is more than this trader will tolerate
		var/hikeperc = askingprice - H.price
		hikeperc = (hikeperc / H.price) * 100
		var/negatol = 0 - src.hiketolerance

		if (hikeperc <= negatol)
			src.temp = "<B>Cost:</B> [H.price] Credits<BR>"
			src.temp += src.errormsgs[3]
			H.haggleattempts++
			return

		// now, the actual haggling part! find the middle ground between the two prices
		var/middleground = (H.price + askingprice) / 2
		var/negotiate = abs(H.price-middleground)-1

		H.price =round(middleground + rand(0,negotiate))

		src.temp = "<B>New Cost:</B> [H.price] Credits<BR><HR>"
		H.haggleattempts++
		// warn the player if the trader isn't going to take any more haggling
		if (patience == H.haggleattempts)
			src.temp += src.hagglemsgs[src.hagglemsgs.len]
		else
			src.temp += pick(src.hagglemsgs)
