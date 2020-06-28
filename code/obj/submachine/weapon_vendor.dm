/*
	==>	Syndicate Weapons Vendor	<==
	Designed for use on the Syndicate Battlecruiser Cairngorm.
	Stocked with weapons and gear for nuclear operatives to pick between, instead of using traditional uplinks.
	Operatives recieve a token on spawn that provides them with one sidearm credit and one loadout credit in the vendor.

	Index:
	- Vendor
	- Materiel
	- Requisition tokens

	Coder note: This is all stolen/based upon the Discount Dan's GTM, so my code crimes are really the fault of whoever made those. Thanks and god bless.

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
		materiel_stock += new/datum/materiel/loadout/custom

		materiel_stock += new/datum/materiel/storage/rucksack
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
		var/list/dat = list("<span style=\"inline-flex\">")
		dat += "<br><b>Balance remaining:</b> <font color='blue'>[src.current_sidearm_credits] sidearm credit, [src.current_loadout_credits] loadout credit, [src.current_storage_credits] storage credit.</font>"

		if (src.temp)
			dat += src.temp
		else
			dat += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits</a>"

		dat += "<br><a href='?action=mach_close&window=swv'>Close</a></span>"
		user.Browse(dat.Join(), "window=swv;size=600x500;title=Syndicate Weapons Vendor")
		onclose(user, "swv")

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)

		if(href_list["redeem"])
			src.temp = list("<br>Please select the materiel that you wish to spend your credits on:<br><br>")

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
			src.temp = jointext(src.temp, "")

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
	name = "M1992 Pistol"
	path = /obj/item/storage/belt/pistol
	catagory = "Sidearm"
	description = "A gun-belt containing a semi-automatic, 9mm caliber service pistol and three magazines."

/datum/materiel/sidearm/revolver
	name = "Predator Revolver"
	path = /obj/item/storage/belt/revolver
	catagory = "Sidearm"
	description = "A gun-belt containing a hefty combat revolver and two .357 caliber speedloaders."

/datum/materiel/loadout/assault
	name = "Assault Trooper"
	path = /obj/storage/crate/classcrate/assault
	catagory = "Loadout"
	description = "Bullpup assault rifle with single shot and burst fire modes, mag pouch containing standard and AP magazines, mixed grenade pouch and breaching charges."

/datum/materiel/loadout/heavy
	name = "Heavy Weapons Specialist"
	path = /obj/storage/crate/classcrate/heavy
	catagory = "Loadout"
	description = "Light machine gun, three boxes of ammunition and a pouch of high explosive grenades."

/datum/materiel/loadout/grenadier
	name = "Grenadier"
	path = /obj/storage/crate/classcrate/demo
	catagory = "Loadout"
	description = "Grenade launcher, two pouches containing 40mm grenade rounds and mixed explosive grenades."

/datum/materiel/loadout/infiltrator
	name = "Infiltrator"
	path = /obj/storage/crate/classcrate/agent_rework
	catagory = "Loadout"
	description = "Tranquilizer pistol with a pouch of dart magazines, combat knife which increases run speed when held, five use cloaking device, electromagnetic card and night-vision goggles."

/datum/materiel/loadout/medic
	name = "Combat Medic"
	path = /obj/storage/crate/classcrate/medic
	catagory = "Loadout"
	description = "Comprehensive medical supplies in a satchel, belt and pouch, including donk pockets and an experimental Juggernaut injector."

/datum/materiel/loadout/firebrand
	name = "Firebrand"
	path = /obj/storage/crate/classcrate/pyro
	catagory = "Loadout"
	description = "Napalm flamethrower, incendiery grenade pouch and a door-breaching fire-axe that can be two-handed to increase damage to both foes and airlocks."

/datum/materiel/loadout/engineer
	name = "Combat Engineer"
	path = /obj/storage/crate/classcrate/engineer
	catagory = "Loadout"
	description = "Automated gun turret with an important guide on how to deploy it, full toolbelt with high-capacity welder and a combat shotgun."

/datum/materiel/loadout/marksman
	name = "Marksman"
	path = /obj/storage/crate/classcrate/sniper
	catagory = "Loadout"
	description = "High-powered sniper rifle that can fire through two solid walls,optical thermal scanner and a pouch of smoke grenades"

/datum/materiel/loadout/custom
	name = "Custom Class Uplink"
	path = /obj/item/uplink/syndicate
	catagory = "Loadout"
	description = "A standard syndicate uplink loaded with 12 telecrytals, allowing you to pick and choose from an array of syndicate items."

/datum/materiel/storage/rucksack
	name = "Assault Rucksack"
	path = /obj/item/storage/backpack/syndie/tactical
	catagory = "Storage"
	description = "A large 10 slot military backpack, designed to fit a wide array of tools for comprehensive storage support."

/datum/materiel/storage/belt
	name = "Tactical Espionage Belt"
	path = /obj/item/storage/fanny/syndie
	catagory = "Storage"
	description = "The classic 6 slot syndicate belt pack. Has no relation to the fanny pack."

/datum/materiel/storage/satchel
	name = "Syndicate Satchel"
	path = /obj/item/storage/backpack/satchel/syndie
	catagory = "Storage"
	description = "An ordinary 6 slot messenger bag in menacing red and black."

// Requisition tokens

/obj/item/requisition_token
	name = "requisition token"
	desc = "A Syndicate credit card charged with currency compatible with the Syndicate Weapons Vendor."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "req-token"
	w_class = 1.0
