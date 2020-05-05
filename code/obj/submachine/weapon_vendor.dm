// Stolen from GTMs
// Meant for nuclear operatives to use to order gear on the battlecruiser

/obj/submachine/weapon_vendor
	name = "Syndicate Weapons Vendor"
	icon = 'icons/obj/discountdans.dmi'
	icon_state = "gtm"
	desc = "An automated quartermaster service for supplying your syndciate nuclear operative team with materiel."
	density = 1
	opacity = 0
	anchored = 1

	deconstruct_flags = DECON_MULTITOOL

	var/current_supply_credits = 0
	var/temp = null
	var/datum/light/light
	var/list/datum/materiel_stock = list()

	New()
		..()
		materiel_stock += new/datum/materiel/todo
		materiel_stock += new/datum/materiel/todo

		light = new/datum/light/point
		light.set_brightness(0.4)
		light.attach(src)
		light.enable()

	attackby(var/obj/item/I as obj, user as mob)
		if(istype(I, /obj/item/ticket/golden))
			qdel(I)
			boutput(user, "<span class='notice'>You insert the supply credit into the vendor.</span>")
			src.current_supply_credits++
			src.updateUsrDialog()
		else
			src.attack_hand(user)
		return

	attack_hand(var/mob/user as mob)
		if(..())
			return

		user.machine = src
		var/dat = "<span style=\"inline-flex\">"
		dat += "<BR>Current balance: [src.current_supply_credits] supply credits"

		if (src.temp)
			dat += src.temp
		else
			dat += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem credits</A>"

		dat += "<BR><A HREF='?action=mach_close&window=gtm'>Close</A></span>"
		user.Browse(dat, "window=gtm;size=400x500;title=Syndicate Weapons Vendor")
		onclose(user, "gtm")

	Topic(href, href_list)
		if(..())
			return
		usr.machine = src

		if(href_list["redeem"])
			src.temp = "<BR><B>Please select the materiel that you wish to spend your supply credits on:</B><BR><BR>"

			src.temp += {"<style>
				table {border-collapse: collapse;}
				th,td {padding: 5px;}
				.reward {display:block; color:white; padding: 2px 5px; margin: -5px -5px 2px -5px;
																width: auto;
																height: auto;
																filter: glow(color=black,strength=1);
																text-shadow: -1px -1px 0 #000,
																							1px -1px 0 #000,
																							-1px 1px 0 #000,
																							 1px 1px 0 #000;}
			</style>"}

			src.temp += "<table border=1>"
			src.temp += "<tr><th>Materiel</th><th>Cost</th><th>Description</th></tr>"

			for (var/datum/materiel/R in materiel_stock)
				src.temp += "<tr><td><a href='?src=\ref[src];buy=\ref[R]'><b><u>[R.name]</u></b></a></td><td>[R.cost]</td><td>[R.description]</td></tr>"

			src.temp += "</table></div>"

		if (href_list["buy"])
			var/datum/materiel/R = locate(href_list["buy"]) in materiel_stock
			if(istype(R))
				if(src.current_supply_credits < R.cost)
					src.temp = "<BR>Insufficient tickets.<BR>"
					src.temp += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem tickets</A>"
				else
					src.current_supply_credits -= R.cost
					src.temp = "<BR>Thank you for your loyalty to Discount Dan's!"
					src.temp += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem tickets</A>"
					new R.path(src.loc)

		src.updateUsrDialog()

// Items to buy

/datum/materiel
	var/name = "Totally amazing item"
	var/cost = 1
	var/path = null
	var/description = "All these descriptions are such bullshit."

/datum/materiel/cap
	name = "Apprentice's Cap"
	path = /obj/item/clothing/head/apprentice/dan
	description = "A gorgeous piece of headwear, imbued with magical forces and pithy expressions."

	// supply credits

/obj/item/ticket
	name = "ticket"
	desc = "It's a ticket."
	icon = 'icons/obj/discountdans.dmi'
	w_class = 1.0

/obj/item/ticket/golden
	name = "golden ticket"
	desc = "A (partially) golden ticket! It has the Discount Dan's logo emblazoned on it. The fine print tells you that you can redeem this shimmery piece of foil at your nearest vending machine. Huh!"
	icon_state = "golden"
