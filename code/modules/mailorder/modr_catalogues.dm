//catalogue cartridges: the main event
/obj/item/disk/data/cartridge/catalogue
	name = "unprogrammed mail-order cartridge"
	desc = "An electronic mail-order cartridge for PDAs with built-in payment handling."

	audiovideo
		name = "\improper Tanhony & Sons mail-order cartridge"
		icon_state = "cart-records"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/audiovideo(src))
			src.file_amount = src.file_used
			src.read_only = 1

	recreation
		name = "\improper Henry's Recreational mail-order cartridge"
		icon_state = "cart-fancy"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/recreation(src))
			src.file_amount = src.file_used
			src.read_only = 1

	produce
		name = "\improper Farmer Melons' Market Cart"
		icon_state = "cart-hydro"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/produce(src))
			src.file_amount = src.file_used
			src.read_only = 1

	survmart
		name = "\improper Survival Mart mail-order cartridge"
		icon_state = "cart-med"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/survmart(src))
			src.file_amount = src.file_used
			src.read_only = 1

	chem
		name = "\improper Chems-R-Us mail-order cartridge"
		icon_state = "cart-rd2"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/chem(src))
			src.file_amount = src.file_used
			src.read_only = 1


//catalogue program itself - handles purchase and initialization of shipment

#define DELIVERED_TO_MAIL 1
#define DELIVERED_TO_QM 2
#define MODE_LIST 0
#define MODE_CART 1

/datum/computer/file/pda_program/catalogue
	name = "The Omega Catalogue"
	size = 32
	var/mode = 0
	var/entries_to_index = /datum/mail_order
	var/list/cart = list() //mail order entries selected for purchase
	var/cartsize = 0 // based on amount of items in selected entries, not amount of entries
	var/cartcost = 0 // how much your selection costs
	var/list/canbuy = list() //list of catalog entries

	audiovideo
		name = "Tanhony & Sons"
		entries_to_index = /datum/mail_order/audiovideo

	recreation
		name = "Henry's Recreational"
		entries_to_index = /datum/mail_order/recreation

	produce
		name = "Farmer's Market"
		entries_to_index = /datum/mail_order/produce

	survmart
		name = "Survival Mart"
		entries_to_index = /datum/mail_order/survmart

	chem
		name = "Chems-r-Us"
		entries_to_index = /datum/mail_order/chem

	New()
		..()
		for(var/S in concrete_typesof(entries_to_index))
			var/datum/mail_order/mo_entry = new S()
			src.canbuy[mo_entry.cleanname] = mo_entry

	return_text()
		. = src.return_text_header()
		. += " | <a href='byond://?src=\ref[src];viewlist=1'>Catalogue</a>"
		if(length(src.cart) > 0)
			var/cartlength = length(src.cart)
			. += " | <a href='byond://?src=\ref[src];viewcart=1'>Cart ([cartlength])</a>"
		else
			. += " | <a href='byond://?src=\ref[src];viewcart=1'>Cart</a>"
		. += "<h4>[src.name]</h4><hr>"

		if(!src.master.host_program)
			. += "ERROR 404: File not found."
		switch(src.mode)
			if(MODE_LIST)
				. += "<h4>Catalogue</h4><br>"
				if(length(src.canbuy) < 1)
					. += "None!"
				else
					for(var/P in src.canbuy)
						var/datum/mail_order/F = src.canbuy[P]
						if(!istype(F))
							continue
						var/itemct = length(F.order_items)
						. += {"<a href='byond://?src=\ref[src];add_to_cart=[F.cleanname]'>[F.name]</a> - [itemct] Item(s) - $[F.cost]<br>
						[F.desc]<br>"}
						if(length(F.order_perm))
							. += "Requires Access (1 or more of)"
							for(var/acval in F.order_perm)
								var/accessname = get_access_desc(acval)
								. += " | [accessname]"
							. += "<br>"
						. += "<hr>"

			if(MODE_CART)
				. += "<h4>Shopping Cart</h4><br>"
				if(length(src.cart) < 1)
					. += "Empty - please use Catalogue."
				else
					var/entryct = length(src.cart)
					. += "[entryct] Selections - [cartsize] Items - $[cartcost]<br>"
					. += "<a href='byond://?src=\ref[src];checkout=1'>Check Out</a> | <a href='byond://?src=\ref[src];clearcart=1'>Clear Cart</a><br><hr>"
					for(var/P in src.cart)
						var/datum/mail_order/F = P
						if(!istype(F, /datum/mail_order))
							continue
						var/itemct = length(F.order_items)
						var/requiresid
						if(length(F.order_perm))
							requiresid = " | Requires ID"
						else
							requiresid = ""
						. += {"[F.name]<br>
						[itemct] Items | $[F.cost][requiresid]<br><hr>"}

	Topic(href, href_list)
		if(..())
			return

		if (href_list["viewlist"])
			src.mode = MODE_LIST

		if (href_list["viewcart"])
			src.mode = MODE_CART

		if (href_list["checkout"])
			if(length(src.cart) > 0)
				var/alert_beep = null
				if(!src.master.host_program.message_silent)
					alert_beep = src.master.host_program.message_tone

				if (signal_loss >= 25)
					src.master.display_alert(alert_beep)
					var/displayMessage = "[bicon(master)] Unable to place order due to connection failure. Please try again later."
					src.master.display_message(displayMessage)

				else
					var/creditCheck = src.authCard(usr)
					if(creditCheck == "SUCCESS")
						var/destination = "Send to QM"
						if(pick_landmark(LANDMARK_MAILORDER_SPAWN)) //pick a destination if mail insertion is supported by map
							var/list/possible_mail_dests = list("Send to QM")
							for_by_tcl(S, /obj/machinery/disposal/mail)
								possible_mail_dests += S.mail_tag
							destination = input(usr, "Pick destination chute, or Send to QM for secure crate-based delivery", src.name, null) as null|anything in possible_mail_dests
						if(destination && isalive(usr))
							var/final_bill = src.cartcost //da-na-na na, da-na-na na na
							var/buy_success = src.shipCart(destination)
							src.master.display_alert(alert_beep)
							var/displayMessage = "[bicon(master)] Purchase unsuccessful due to lack of mail-order service to your area."
							if(buy_success)
								var/datum/db_record/spender = FindBankAccountByName(src.master.ID_card.registered)
								if(spender)
									spender["current_money"] -= final_bill
								else
									CRASH("[src] tried to charge a card that doesn't exist, yell at kubius")
								displayMessage = "[bicon(master)] Thank you for your purchase! Order will arrive when cleared by local quartermasters."
								src.mode = MODE_LIST
							src.master.display_message(displayMessage)
					else
						src.master.display_alert(alert_beep)
						var/displayMessage = "[bicon(master)] Purchase failed | [creditCheck]" //period omitted intentionally
						src.master.display_message(displayMessage)

		if (href_list["clearcart"])
			if(length(src.cart) > 0)
				src.voidCart()

		if (href_list["add_to_cart"])
			var/datum/mail_order/F = src.canbuy[href_list["add_to_cart"]]
			if(istype(F, /datum/mail_order))
				if(length(F.order_items) + src.cartsize <= 7)
					src.cartsize += length(F.order_items)
					src.cartcost += F.cost
					src.cart += F
				else
					var/alert_beep = null
					if(!src.master.host_program.message_silent)
						alert_beep = src.master.host_program.message_tone
					src.master.display_alert(alert_beep)
					var/displayMessage = "[bicon(master)] Your cart is full! Please place your order or remove an item."
					src.master.display_message(displayMessage)

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	// arrange for package assessment by QM, then clear cart
	proc/shipCart(var/destination)
		var/datum/mailorder_manifest/manifest = new /datum/mailorder_manifest
		var/success_style = DELIVERED_TO_QM //tracks type of order placement for reply purposes

		if(destination != "Send to QM")
			success_style = DELIVERED_TO_MAIL
			if(!pick_landmark(LANDMARK_MAILORDER_SPAWN) || !pick_landmark(LANDMARK_MAILORDER_TARGET)) //tried to mail-ship without map support
				src.voidCart() //therefore can't ship, fail without paying
				return 0

		manifest.orderedby = src.master.ID_card?.registered
		manifest.order_cost = src.cartcost
		manifest.order_catalogue = src.name
		manifest.dest_tag = destination
		manifest.notify_netid = src.master.net_id

		for(var/datum/mail_order/F in src.cart)
			manifest.stock += F.order_items
			manifest.stock_frontend += "[F.name]<br>"

		shippingmarket.mailorders += manifest

		//successful purchase, clear out the cart and let purchase proc know
		src.voidCart()
		return success_style

	proc/voidCart()
		src.cartsize = 0
		src.cartcost = 0
		src.cart.Cut()

	proc/authCard(var/mob/user as mob) //handles clearance requirements and payment check
		if(!src.master.ID_card)
			return "NO CARD INSERTED"
		if(!src.master.ID_card.registered)
			return "NO CARDHOLDER"
		var/purchase_authed = 1
		for(var/datum/mail_order/F in src.cart)
			if(!length(F.order_perm))
				continue
			purchase_authed = 0
			//a loop inside a loop oh no
			for(var/acval in F.order_perm)
				if(acval in src.master.ID_card.access)
					purchase_authed = 1
				break
		if(!purchase_authed)
			return "INSUFFICIENT AUTHORIZATION"
		var/datum/db_record/account = null
		account = FindBankAccountByName(src.master.ID_card.registered)
		if (account)
			var/enterpin = user.enter_pin("Authorize Purchase")
			if (enterpin == src.master.ID_card.pin)
				var/bux = account["current_money"]
				if (bux < src.cartcost)
					return "INSUFFICIENT FUNDS ([bux] OF [src.cartcost])"
				return "SUCCESS"
			else
				return "MISSING OR INCORRECT PIN"
		else
			return "NO ACCOUNT ON FILE"

#undef DELIVERED_TO_QM
#undef DELIVERED_TO_MAIL
#undef MODE_LIST
#undef MODE_CART
