// Stolen from GTMs
// Meant for nuclear operatives to use to order gear on the battlecruiser

/obj/submachine/weapon_vendor
	name = "Syndicate Weapons Vendor"
	icon = 'icons/obj/discountdans.dmi'
	icon_state = "gtm"
	desc = "An automated quartermaster service for supplying your syndicate nuclear operative team with weapons and gear."
	density = 1
	opacity = 0
	anchored = 1

	deconstruct_flags = DECON_MULTITOOL

	//var/current_supply_credits = 0
	var/current_sidearm_credits = 0
	var/current_loadout_credits = 0
	var/temp = null
	var/list/datum/materiel_stock = list()
	//var/datum/light/light

	New()
		..()
		// List of avaliable objects for purchase
		materiel_stock += new/datum/materiel/sidearm/pistol
		materiel_stock += new/datum/materiel/sidearm/revolver
		materiel_stock += new/datum/materiel/loadout/assault
/*
		light = new/datum/light/point
		light.set_brightness(0.4)
		light.attach(src)
		light.enable()
*/
	attackby(var/obj/item/I as obj, user as mob)
		if(istype(I, /obj/item/supply_credit))
			qdel(I)
			boutput(user, "<span class='notice'>You insert the supply credit into the vendor.</span>")
			src.current_sidearm_credits++
			src.current_loadout_credits++
			src.updateUsrDialog()
		else
			src.attack_hand(user)
		return

	attack_hand(var/mob/user as mob)
		if(..())
			return

		user.machine = src
		var/dat = "<span style=\"inline-flex\">"
		dat += "<BR>Current balance: [src.current_sidearm_credits] sidearm credits, [src.current_loadout_credits] loadout credits."

		if (src.temp)
			dat += src.temp
		else
			dat += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem credits</A>"

		dat += "<BR><A HREF='?action=mach_close&window=swv'>Close</A></span>"
		user.Browse(dat, "window=swv;size=400x500;title=Syndicate Weapons Vendor")
		onclose(user, "swv")

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
			src.temp += "<tr><th>Materiel</th><th>Catagory</th><th>Cost</th><th>Description</th></tr>"

			for (var/datum/materiel/M in materiel_stock)
				src.temp += "<tr><td><a href='?src=\ref[src];buy=\ref[M]'><b><u>[M.name]</u></b></a></td><td>[M.catagory]</td><td>[M.cost]</td><td>[M.description]</td></tr>"

			src.temp += "</table></div>"

		if (href_list["buy"])
			var/datum/materiel/sidearm/S = locate(href_list["buy"]) in materiel_stock
			if(istype(S))
				if(src.current_sidearm_credits < S.cost)
					src.temp = "<BR>Insufficient credits.<BR>"
					src.temp += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem credits.</A>"
				else
					src.current_sidearm_credits -= S.cost
					src.temp = "<BR>Transaction complete."
					src.temp += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem credits.</A>"
					new S.path(src.loc)
			var/datum/materiel/loadout/L = locate(href_list["buy"]) in materiel_stock
			if(istype(L))
				if(src.current_loadout_credits < L.cost)
					src.temp = "<BR>Insufficient credits.<BR>"
					src.temp += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem credits.</A>"
				else
					src.current_loadout_credits -= L.cost
					src.temp = "<BR>Transaction complete."
					src.temp += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem credits.</A>"
					new L.path(src.loc)

		src.updateUsrDialog()

// Materiel avaliable for purchase:

/datum/materiel
	var/name = "Totally scary gun"
	var/cost = 1
	var/catagory = null
	var/path = null
	var/description = "If you see me, gannets is an idiot."

/datum/materiel/sidearm/pistol
	name = "9mm pistol"
	path = /obj/item/gun/kinetic/pistol
	catagory = "Sidearm"
	description = "A semi-automatic, 9mm caliber service pistol issued by the Syndicate."

/datum/materiel/sidearm/revolver
	name = "Predator revolver"
	path = /obj/item/gun/kinetic/revolver
	catagory = "Sidearm"
	description = "A hefty combat revolver developed by Cormorant Precision Arms. Uses .357 caliber rounds."

/datum/materiel/loadout/assault
	name = "Assault trooper class crate"
	path = /obj/storage/crate/classcrate/assault
	catagory = "Loadout"
	cost = 1
	description = "A crate containing a Specialist Operative loadout. This one includes a customized assault rifle, several additional magazines as well as an assortment of breach and clear grenades."

	// supply credits

/obj/item/supply_credit
	name = "ticket"
	desc = "It's a ticket."
	icon = 'icons/obj/discountdans.dmi'
	w_class = 1.0
/*
/obj/item/ticket/golden
	name = "golden ticket"
	desc = "A (partially) golden ticket! It has the Discount Dan's logo emblazoned on it. The fine print tells you that you can redeem this shimmery piece of foil at your nearest vending machine. Huh!"
	icon_state = "golden"
*/
