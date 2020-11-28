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
	name = "Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon"
	desc = "dont see this"
	density = 1
	opacity = 0
	anchored = 1

	var/sound_token = 'sound/machines/capsulebuy.ogg'
	var/sound_buy = 'sound/machines/spend.ogg'
	var/current_sidearm_credits = 0
	var/current_loadout_credits = 0
	var/current_storage_credits = 0
	var/current_utility_credits = 0
	var/temp = null
	var/list/datum/materiel_stock = list()
	var/token_accepted = /obj/item/requisition_token

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, token_accepted))
			user.drop_item(I)
			qdel(I)
			accepted_token()
		else
			..()

	proc/accepted_token(var/mob/user)
		src.updateUsrDialog()
		playsound(src.loc, sound_token, 80, 1)
		boutput(user, "<span class='notice'>You insert the requisition token into [src].</span>")

	attack_hand(var/mob/user as mob)
		if(..())
			return

		src.add_dialog(user)
		var/list/dat = list("<span style=\"inline-flex\">")
		dat += "<br><b>Balance remaining:</b> <font color='blue'>[src.current_sidearm_credits] sidearm credit, [src.current_loadout_credits] loadout credit, [src.current_utility_credits] utility credit.</font>"

		if (src.temp)
			dat += src.temp
		else
			dat += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits</a>"

		dat += "<br><a href='?action=mach_close&window=swv'>Close</a></span>"
		user.Browse(dat.Join(), "window=swv;size=600x500;title=Syndicate Weapons Vendor")
		onclose(user, "swv")

	proc/vended(var/atom/A)
		.= 0

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)

		if(href_list["redeem"])
			src.temp = list("<br>Please select the material that you wish to spend your credits on:<br><br>")

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
					var/atom/A = new S.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)
					src.vended(A)
			var/datum/materiel/loadout/L = locate(href_list["buy"]) in materiel_stock
			if(istype(L))
				if(src.current_loadout_credits < L.cost)
					src.temp = "<br><font color='red'>Insufficient credits.</font><br>"
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
				else
					src.current_loadout_credits -= L.cost
					src.temp = "<br>Transaction complete."
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
					var/atom/A = new L.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)
					src.vended(A)
			var/datum/materiel/utility/U = locate(href_list["buy"]) in materiel_stock
			if(istype(U))
				if(src.current_utility_credits < U.cost)
					src.temp = "<br><font color='red'>Insufficient credits.</font><br>"
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
				else
					src.current_utility_credits -= U.cost
					src.temp = "<br>Transaction complete."
					src.temp += "<br><a href='?src=\ref[src];redeem=1'>Redeem credits.</a>"
					var/atom/A = new U.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)
					src.vended(A)

		src.updateUsrDialog()


/obj/submachine/weapon_vendor/security
	name = "Security Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon-sec"
	desc = "An automated quartermaster service for supplying your security team with weapons and gear."
	token_accepted = /obj/item/requisition_token/security
	New()
		..()
		materiel_stock += new/datum/materiel/loadout/standard
		materiel_stock += new/datum/materiel/loadout/offense
		materiel_stock += new/datum/materiel/loadout/support
		materiel_stock += new/datum/materiel/loadout/control

	vended(var/atom/A)
		..()
		if (istype(A,/obj/item/storage/belt/security))
			SPAWN_DBG(2 DECI SECONDS) //ugh belts do this on spawn and we need to wait
				var/list/tracklist = list()
				for(var/atom/C in A.contents)
					if (istype(C,/obj/item/gun) || istype(C,/obj/item/baton))
						tracklist += C

				var/obj/item/pinpointer/secweapons/P = new(src.loc)
				P.track(tracklist)

	accepted_token()
		src.current_loadout_credits++
		..()

/obj/submachine/weapon_vendor/syndicate
	name = "Syndicate Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon"
	desc = "An automated quartermaster service for supplying your nuclear operative team with weapons and gear."
	token_accepted = /obj/item/requisition_token/syndicate
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
/*
		materiel_stock += new/datum/materiel/storage/rucksack
		materiel_stock += new/datum/materiel/storage/belt
		materiel_stock += new/datum/materiel/storage/satchel
*/
		materiel_stock += new/datum/materiel/utility/belt
		materiel_stock += new/datum/materiel/utility/knife
		materiel_stock += new/datum/materiel/utility/rpg_ammo
		materiel_stock += new/datum/materiel/utility/donk
		materiel_stock += new/datum/materiel/utility/sarin_grenade

	accepted_token()
		src.current_sidearm_credits++
		src.current_loadout_credits++
		src.current_utility_credits++
		..()
// Materiel avaliable for purchase:

/datum/materiel
	var/name = "intimidating military object"
	var/cost = 1
	var/catagory = null
	var/path = null
	var/description = "If you see me, gannets is an idiot."


//SECURITY

/datum/materiel/sidearm/barrier
	name = "Security Barrier"
	path = /obj/item/barrier
	catagory = "Sidearm"
	description = "A barrier that grants great protection while held and can deploy shields that reflect projectiles."

/datum/materiel/sidearm/EOD
	name = "EOD Suit"
	path = /obj/item/clothing/suit/armor/EOD
	catagory = "Sidearm"
	description = "Protective armor with high explosion resistance."

/datum/materiel/sidearm/flaregun
	name = "Flare Gun"
	path = /obj/item/storage/box/flaregun
	catagory = "Sidearm"
	description = "Ignite one target. Must be reloaded after each use."

/datum/materiel/loadout/standard
	name = "Standard"
	path = /obj/item/storage/belt/security/standard
	catagory = "Loadout"
	description = "One belt containing a taser and a baton. Classic!"

/datum/materiel/loadout/offense
	name = "Offense"
	path = /obj/item/storage/belt/security/offense
	catagory = "Loadout"
	description = "One belt containing a wavegun and a baton."

/datum/materiel/loadout/support
	name = "Support"
	path = /obj/item/storage/belt/security/support
	catagory = "Loadout"
	description = "One belt containing a baton, two robust donuts, and some morphine auto-injectors."

/datum/materiel/loadout/control
	name = "Control"
	path = /obj/item/storage/belt/security/control
	catagory = "Loadout"
	description = "One belt containing a taser shotgun, crowd dispersal grenades, and a baton."


//SYNDIE

/datum/materiel/sidearm/pistol
	name = "Branwen Pistol"
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
	description = "Tranquilizer pistol with a pouch of dart magazines, five use cloaking device, electromagnetic card and night-vision goggles."

/datum/materiel/loadout/medic
	name = "Combat Medic"
	path = /obj/storage/crate/classcrate/medic
	catagory = "Loadout"
	description = "Comprehensive medical supplies in a satchel, belt and pouch, including donk injector and an experimental Juggernaut injector."

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
/*
/datum/materiel/storage/rucksack
	name = "Assault Rucksack"
	path = /obj/item/storage/backpack/syndie/tactical
	catagory = "Storage"
	description = "A large 10 slot military backpack, designed to fit a wide array of tools for comprehensive storage support."

/datum/materiel/storage/belt
	name = "Tactical Espionage Belt"
	path = /obj/item/storage/fanny/syndie
	catagory = "Storage"
	description = "The classic 7 slot syndicate belt pack. Has no relation to the fanny pack."

/datum/materiel/storage/satchel
	name = "Syndicate Satchel"
	path = /obj/item/storage/backpack/satchel/syndie
	catagory = "Storage"
	description = "An ordinary 6 slot messenger bag in menacing red and black."
*/
/datum/materiel/utility/belt
	name = "Tactical Espionage Belt"
	path = /obj/item/storage/fanny/syndie
	catagory = "Utility"
	description = "The classic 7 slot syndicate belt pack. Has no relation to the fanny pack."

/datum/materiel/utility/knife
	name = "Combat Knife"
	path = /obj/item/dagger/syndicate/specialist
	catagory = "Utility"
	description = "A field-tested 10 inch combat knife, helps you move faster when held."

/datum/materiel/utility/rpg_ammo
	name = "MPRT Rocket Ammunition"
	path = /obj/item/storage/pouch/rpg
	catagory = "Utility"
	description = "An additional four MPRT rockets."

/datum/materiel/utility/donk
	name = "Warm Donk Pocket"
	path = /obj/item/reagent_containers/food/snacks/donkpocket_w
	catagory = "Utility"
	description = "A tasty donk pocket, heated by futuristic vending machine technology!"

/datum/materiel/utility/sarin_grenade
	name = "Sarin Grenade"
	path = /obj/item/chem_grenade/sarin
	catagory = "Utility"
	description = "A terrifying grenade containing a potent nerve gas. Try not to get caught in the smoke."

// Requisition tokens

/obj/item/requisition_token
	name = "requisition token"
	desc = "A Syndicate credit card charged with currency compatible with the Syndicate Weapons Vendor."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "req-token"
	w_class = 1.0


	syndicate
		desc = "A Syndicate credit card charged with currency compatible with the Syndicate Weapons Vendor."
		icon_state = "req-token"

	security
		desc = "An NT-provided token compatible with the Security Weapons Vendor."
		icon_state = "req-token-sec"



