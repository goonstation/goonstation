/obj/item/disk/data/cartridge/catalogue
	name = "\improper unprogrammed mail-order cartridge"
	desc = "An electronic mail-order cartridge for PDAs with built-in payment handling."
/*
	nt
		name = "\improper Nanotrasen mail-order cartridge"
		icon_state = "cart-fancy"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/nt(src))
			src.file_amount = src.file_used
			src.read_only = 1

	takeout
		name = "\improper Golden Gannets mail-order cartridge"
		icon_state = "cart-qm"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/takeout(src))
			src.file_amount = src.file_used
			src.read_only = 1
*/
	medical
		name = "\improper Survival Mart mail-order cartridge"
		icon_state = "cart-med"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/catalogue/medical(src))
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

	medical
		name = "Survival Mart"
		entries_to_index = /datum/mail_order/medical

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
						[F.desc]<br><hr>"}

			if(MODE_CART)
				. += "<h4>Shopping Cart</h4><br>"
				if(length(src.cart) < 1)
					. += "Empty - please use Catalogue."
				else
					var/entryct = length(src.cart)
					. += "[entryct] Selections - [cartsize] Items - $[cartcost]<br>"
					. += "<a href='byond://?src=\ref[src];checkout'>Check Out</a> | <a href='byond://?src=\ref[src];clearcart'>Clear Cart</a><br><hr>"
					for(var/P in src.cart)
						var/datum/mail_order/F = P
						if(!istype(F, /datum/mail_order))
							continue
						var/itemct = length(F.order_items)
						var/requiresid
						if(length(F.order_perm))
							requiresid = "Requires ID"
						else
							requiresid = ""
						. += {"<table cellspacing=5>
						<tr>
						<td>[F.name]</td>
						<td>[requiresid]</td></tr>
						<tr>
						<td>[itemct] Items</td>
						<td>$[F.cost]</td>
						</tr>
						</table><hr>"}

	Topic(href, href_list)
		if(..())
			return

		if (href_list["viewlist"])
			src.mode = MODE_LIST

		if (href_list["viewcart"])
			src.mode = MODE_CART

		if (href_list["checkout"])
			if(length(src.cart) > 0)
				if(src.master.ID_card && src.master.ID_card.money >= src.cartcost)
					var/destination = input(usr, "Select destination mail tag", src.name, null) as text
					if (destination && isalive(usr))
						src.master.ID_card.money -= src.cartcost
						src.shipcart()
						var/alert_beep = null
						if(!src.master.host_program.message_silent)
							alert_beep = src.master.host_program.message_tone
						src.master.display_alert(alert_beep)
						var/displayMessage = "[bicon(master)] Thank your for your purchase! Delivery to '[destination]' in progress."
						src.master.display_message(displayMessage)
				else
					var/alert_beep = null
					if(!src.master.host_program.message_silent)
						alert_beep = src.master.host_program.message_tone
					src.master.display_alert(alert_beep)
					var/displayMessage = "[bicon(master)] Card error detected! Please insert a card with sufficient loaded credits."
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
		for(var/P in src.cart)
			var/datum/mail_order/F = P
			if(!istype(F, /datum/mail_order))
				continue
			for(var/loaditem in F.order_items)
				boxstock += loaditem
		var/obj/item/storage/package = new /obj/item/storage/box/mailorder(spawn_contents = boxstock)
		if(src.master.ID_card && src.master.ID_card.registered)
			package.name = "mail-order box ([src.master.ID_card.registered])"
		package.loc = get_turf(src.master) // put it in shipping location instead
		src.cartsize = 0
		src.cartcost = 0
		src.cart.Cut()

#undef MODE_LIST
#undef MODE_CART

/obj/item/storage/box/mailorder
	name = "mail-order box"
	icon_state = "evidence"
	desc = "A box containing mail-ordered items."
