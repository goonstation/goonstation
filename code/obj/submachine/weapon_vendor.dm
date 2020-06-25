/*
	==>	Syndicate Weapons Vendor	<==
	Designed for use on the Syndicate Battlecruiser Cairngorm.
	Stocked with weapons and gear for nuclear operatives to pick between, instead of using traditional uplinks.
	Operatives recieve a token on spawn that provides them with one sidearm credit and one loadout credit in the vendor.

	Index:
	- Vendor
	- Materiel
	- Requisition tokens
*/

/obj/submachine/weapon_vendor
	name = "Syndicate Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon"
	desc = "An automated quartermaster service for supplying your nuclear operative team with weapons and gear."
	density = 1
	opacity = 0
	anchored = 1

	var/sound_token = 'sound/machines/capsulebuy.ogg'
	var/sound_buy = 'sound/machines/spend.ogg'
	var/current_sidearm_credits = 0
	var/current_loadout_credits = 0
	var/current_storage_credits = 0
	var/temp = null
	var/list/datum/materiel_stock = list()

	New()
		..()
		// List of avaliable objects for purchase
		materiel_stock += new/datum/materiel/sidearm/pistol
		materiel_stock += new/datum/materiel/sidearm/revolver

		materiel_stock += new/datum/materiel/loadout/assault
		materiel_stock += new/datum/materiel/loadout/heavy
		materiel_stock += new/datum/materiel/loadout/grenadier
		materiel_stock += new/datum/materiel/loadout/infiltrator
		materiel_stock += new/datum/materiel/loadout/medic
		materiel_stock += new/datum/materiel/loadout/firebrand
		materiel_stock += new/datum/materiel/loadout/engineer
		materiel_stock += new/datum/materiel/loadout/marksman

		materiel_stock += new/datum/materiel/storage/backpack
		materiel_stock += new/datum/materiel/storage/belt
		materiel_stock += new/datum/materiel/storage/satchel

		//materiel_stock += new/datum/materiel/utility/

	attackby(var/obj/item/I as obj, user as mob)
		if(istype(I, /obj/item/requisition_token))
			qdel(I)
			boutput(user, "<span class='notice'>You insert the requisition token into the vendor.</span>")
			src.current_sidearm_credits++
			src.current_loadout_credits++
			src.current_storage_credits++
			src.updateUsrDialog()
			playsound(src.loc, sound_token, 80, 1)
		else
			src.attack_hand(user)
		return

	attack_hand(var/mob/user as mob)
		if(..())
			return

		src.add_dialog(user)
		var/dat = "<span style=\"inline-flex\">"
		dat += "<br><b>Current balance:</b> <font color='blue'>[src.current_sidearm_credits] sidearm credit, [src.current_loadout_credits] loadout credit, [src.current_storage_credits] storage credit.</font>"

		if (src.temp)
			dat += src.temp
		else
			dat += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits</a>"

		dat += "<br><a href='?action=mach_close&window=swv'>Close</a></span>"
		user.Browse(dat, "window=swv;size=600x500;title=Syndicate Weapons Vendor")
		onclose(user, "swv")

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)

		if(href_list["redeem"])
			src.temp = "<br>Please select the materiel that you wish to spend your requisition tokens on:<br><br>"

			src.temp += {"
			<style>
				table {border-collapse: collapse;}
				th {padding: 5px; text-align: center; background-color: #800000; color: white; height: 25px;}
				td {padding: 5px; text-align: center;}
				tr:hover {background-color: #707070;}
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
			src.temp += "<tr><th>Materiel</th><th>Catagory</th><th>Description</th></tr>"

			for (var/datum/materiel/M in materiel_stock)
				src.temp += "<tr><td><a href='?src=\ref[src];buy=\ref[M]'><b><u>[M.name]</u></b></a></td><td>[M.catagory]</td><td>[M.description]</td></tr>"

			src.temp += "</table></div>"

		if (href_list["buy"])
			var/datum/materiel/sidearm/S = locate(href_list["buy"]) in materiel_stock
			if(istype(S))
				if(src.current_sidearm_credits < S.cost)
					src.temp = "<br><font color='red'>Insufficient credits.</font><br>"
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
				else
					src.current_sidearm_credits -= S.cost
					src.temp = "<br>Transaction complete."
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
					new S.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)
			var/datum/materiel/loadout/L = locate(href_list["buy"]) in materiel_stock
			if(istype(L))
				if(src.current_loadout_credits < L.cost)
					src.temp = "<br><font color='red'>Insufficient credits.</font><br>"
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
				else
					src.current_loadout_credits -= L.cost
					src.temp = "<br>Transaction complete."
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
					new L.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)
			var/datum/materiel/storage/T = locate(href_list["buy"]) in materiel_stock
			if(istype(T))
				if(src.current_storage_credits < T.cost)
					src.temp = "<br><font color='red'>Insufficient credits.</font><br>"
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
				else
					src.current_storage_credits -= T.cost
					src.temp = "<br>Transaction complete."
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
					new T.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)

		src.updateUsrDialog()

// Materiel avaliable for purchase:

/datum/materiel
	var/name = "intimidating military object"
	var/cost = 1
	var/catagory = null
	var/path = null
	var/description = "If you see me, gannets is an idiot."

/datum/materiel/sidearm/pistol
	name = "9mm pistol"
	path = /obj/item/storage/belt/pistol
	catagory = "Sidearm"
	description = "A gun-belt containing a semi-automatic, 9mm caliber service pistol and three magazines."

/datum/materiel/sidearm/revolver
	name = "Predator revolver"
	path = /obj/item/storage/belt/revolver
	catagory = "Sidearm"
	description = "A gun-belt containing a hefty combat revolver and 2 .357 caliber speedloaders."

/datum/materiel/loadout/assault
	name = "Class Crate - Assault Trooper"
	path = /obj/storage/crate/classcrate/assault
	catagory = "Loadout"
	description = "A crate containing an assault rifle, several standard and AP magazines as well as an assortment of breach and clear grenades."

/datum/materiel/loadout/heavy
	name = "Class Crate - Heavy Weapons Specialist"
	path = /obj/storage/crate/classcrate/heavy
	catagory = "Loadout"
	description = "A crate containing a light machine gun, several belts of ammunition and a couple of grenades."

/datum/materiel/loadout/grenadier
	name = "Class Crate - Grenadier"
	path = /obj/storage/crate/classcrate/demo
	catagory = "Loadout"
	description = "A crate containing a hand-held grenade launcher, bandolier and a pile of ordnance."

/datum/materiel/loadout/infiltrator
	name = "Class Crate - Infiltrator"
	path = /obj/storage/crate/classcrate/agent_rework
	catagory = "Loadout"
	description = "A crate containing a Specialist Operative loadout."

/datum/materiel/loadout/medic
	name = "Class Crate - Combat Medic"
	path = /obj/storage/crate/classcrate/medic
	catagory = "Loadout"
	description = "A crate containing a Specialist Operative loadout. This one is packed with medical supplies, along with a syringe gun delivery system."

/datum/materiel/loadout/firebrand
	name = "Class Crate - Firebrand"
	path = /obj/storage/crate/classcrate/pyro
	catagory = "Loadout"
	description = "A crate containing a Specialist Operative loadout. This one contains a flamethrower and a hefty fire-axe that can be two-handed."

/datum/materiel/loadout/engineer
	name = "Class Crate - Combat Engineer"
	path = /obj/storage/crate/classcrate/engineer
	catagory = "Loadout"
	description = "A crate containing a Specialist Operative loadout. This one contains a deployable automated gun turret, high-capacity welder and a combat wrench."

/datum/materiel/loadout/marksman
	name = "Class Crate - Marksman"
	path = /obj/storage/crate/classcrate/sniper
	catagory = "Loadout"
	description = "A crate containing a Specialist Operative loadout. This one includes a high-powered sniper rifle, some smoke grenades and a chameleon generator."

/datum/materiel/loadout/custom
	name = "Custom Class Uplink"
	path = /obj/item/uplink/syndicate
	catagory = "Loadout"
	description = "A standard syndicate uplink loaded with 12 telecrytals, allowing you to pick and choose from an array of syndicate items."

/datum/materiel/storage/backpack
	name = "tactical backpack"
	path = /obj/item/storage/backpack/syndie/tactical
	catagory = "Storage"
	description = "A 10 slot military backpack made of high density fabric, designed to fit a wide array of tools for comprehensive storage support."

/datum/materiel/storage/belt
	name = "tactical espionage belt"
	path = /obj/item/storage/fanny/syndie
	catagory = "Storage"
	description = "It's different than a fanny pack. It's tactical and action-packed!"

/datum/materiel/storage/satchel
	name = "syndicate satchel"
	path = /obj/item/storage/backpack/satchel/syndie
	catagory = "Storage"
	description = "An ordinary messenger bag in menacing red and black."

// Requisition tokens

/obj/item/requisition_token
	name = "Requisition token"
	desc = "It's a ticket."
	icon = 'icons/obj/discountdans.dmi'
	icon_state = "golden"
	w_class = 1.0
