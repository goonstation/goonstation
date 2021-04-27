/obj/item/disk/data/cartridge/catalogue
	name = "\improper unprogrammed mail-order cartridge"
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
		name = "\improper Henry's Recreation mail-order cartridge"
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


//todo:
//LOTS of catalogue lineup stuff
//tie into the communication systems so you can't order things with messaging off (maybe more sophisticated than that?)
//consider category support if you can think of a way to make it not skullspiking
//also consider the idea of secure containers that are manually delivered

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
		name = "Henry's Recreation"
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
			src.canbuy[mo_entry.name] = mo_entry

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
						if(!istype(F, /datum/mail_order))
							continue
						var/itemct = length(F.order_items)
						. += {"<a href='byond://?src=\ref[src];add_to_cart=[F.name]'>[F.name]</a> - [itemct] Item(s) - $[F.cost]<br>
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

				if(src.master.ID_card && src.master.ID_card.money >= src.cartcost)
					var/destination = "SHIP_TO_QM"
					if(pick_landmark(LANDMARK_MAILORDER_SPAWN)) //pick a destination if mail insertion is supported by map
						destination = input(usr, "Enter mail tag without quotes, or SHIP_TO_QM for secure crate-based delivery", src.name, null) as text
					var/purchase_authed = 1
					for(var/P in src.cart)
						var/datum/mail_order/F = P
						if(!istype(F, /datum/mail_order))
							continue
						if(!length(F.order_perm))
							continue
						purchase_authed = 0
						//for for
						for(var/acval in F.order_perm)
							if(acval in src.master.ID_card.access)
								purchase_authed = 1
								break
					if(!purchase_authed)
						src.master.display_alert(alert_beep)
						var/displayMessage = "[bicon(master)] Purchase unsuccessful due to insufficient authorization on card."
						src.master.display_message(displayMessage)

					else if(destination && isalive(usr))
						var/buy_success = src.shipcart(destination)
						src.master.display_alert(alert_beep)
						var/displayMessage = "[bicon(master)] Purchase unsuccessful due to lack of mail-order service to your area."
						if(buy_success)
							src.master.ID_card.money -= src.cartcost
							switch(buy_success)
								if(DELIVERED_TO_MAIL)
									displayMessage = "[bicon(master)] Thank you for your purchase! Delivery to '[destination]' in progress."
								if(DELIVERED_TO_QM)
									displayMessage = "[bicon(master)] Thank you for your purchase! Your items will be sent to the quartermaster's office."
						src.master.display_message(displayMessage)
				else
					src.master.display_alert(alert_beep)
					var/displayMessage = "[bicon(master)] Card error - please insert a card with sufficient loaded credits."
					src.master.display_message(displayMessage)

		if (href_list["clearcart"])
			if(length(src.cart) > 0)
				src.cartsize = 0
				src.cartcost = 0
				src.cart.Cut()

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

	// arrange for package construction/shipping, then clear cart
	proc/shipcart(var/destination)
		var/list/boxstock = list()
		var/success_style = null
		var/spawn_package_at = null //used for targeting in mail delivery, and just as an integrity check for qm delivery
		var/fire_package_to = null //ditto

		if(destination == "SHIP_TO_QM")
			for(var/turf/T in get_area_turfs(/area/supply/spawn_point))
				spawn_package_at = T
				break
			for(var/turf/T in get_area_turfs(/area/supply/delivery_point))
				fire_package_to = T
				break
			if(!spawn_package_at || !fire_package_to)
			//tried to QM-ship without map support (???), fail gracefully without paying
				src.cartsize = 0
				src.cartcost = 0
				src.cart.Cut()
				return 0
			success_style = DELIVERED_TO_QM
		else
			if(!pick_landmark(LANDMARK_MAILORDER_SPAWN) || !pick_landmark(LANDMARK_MAILORDER_TARGET))
			//tried to mail-ship without map support, fail gracefully without paying
				src.cartsize = 0
				src.cartcost = 0
				src.cart.Cut()
				return 0
			spawn_package_at = pick_landmark(LANDMARK_MAILORDER_SPAWN)
			fire_package_to = pick_landmark(LANDMARK_MAILORDER_TARGET)
			success_style = DELIVERED_TO_MAIL

		for(var/P in src.cart)
			var/datum/mail_order/F = P
			if(!istype(F, /datum/mail_order))
				continue
			for(var/loaditem in F.order_items)
				boxstock += loaditem

		if(success_style == DELIVERED_TO_MAIL) //set up for direct yeet
			var/obj/item/storage/box/mailorder/package = new /obj/item/storage/box/mailorder()
			package.spawn_contents = boxstock
			if(src.master.ID_card && src.master.ID_card.registered)
				package.name = "mail-order box ([src.master.ID_card.registered])"
			package.set_loc(spawn_package_at)
			package.invisibility = 101
			package.anchored = 1
			package.mail_dest = destination
			package.yeetself(fire_package_to,success_style)
		else if(success_style == DELIVERED_TO_QM) //set up for qm delivery
			var/obj/storage/secure/crate/mailorder/package = new /obj/storage/secure/crate/mailorder()
			package.spawn_contents = boxstock
			if(src.master.ID_card && src.master.ID_card.registered)
				package.registered = src.master.ID_card.registered
			package.launch_procedure()
			shippingmarket.receive_crate(package)
		else //how did we get here? don't know. something's broken. no pay
			src.cartsize = 0
			src.cartcost = 0
			src.cart.Cut()
			return 0
		src.cartsize = 0
		src.cartcost = 0
		src.cart.Cut()
		return success_style

#undef DELIVERED_TO_QM
#undef DELIVERED_TO_MAIL
#undef MODE_LIST
#undef MODE_CART
