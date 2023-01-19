/*
	==>	Syndicate Weapons Vendor	<==
	Designed for use on the Syndicate Battlecruiser Cairngorm.
	Stocked with weapons and gear for nuclear operatives to pick between, instead of using traditional uplinks.
	Operatives receive a token on spawn that provides them with one sidearm credit and one loadout credit in the vendor.

	Index:
	- Vendor
	- Materiel
	- Requisition tokens

	Coder note: This is all stolen/based upon the Discount Dan's GTM, so my code crimes are really the fault of whoever made those. Thanks and god bless.

*/

#define WEAPON_VENDOR_CATEGORY_SIDEARM "sidearm"
#define WEAPON_VENDOR_CATEGORY_LOADOUT "loadout"
#define WEAPON_VENDOR_CATEGORY_AMMO "ammo"
#define WEAPON_VENDOR_CATEGORY_UTILITY "utility"
#define WEAPON_VENDOR_CATEGORY_ASSISTANT "assistant"

/obj/submachine/weapon_vendor
	name = "Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon"
	desc = "dont see this"
	density = 1
	opacity = 0
	anchored = 1
	flags = TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER //cry about it
	layer = OBJ_LAYER - 0.1	// Match vending machines

	var/sound_token = 'sound/machines/capsulebuy.ogg'
	var/sound_buy = 'sound/machines/spend.ogg'
	var/list/credits = list(WEAPON_VENDOR_CATEGORY_SIDEARM = 0, WEAPON_VENDOR_CATEGORY_LOADOUT = 0, WEAPON_VENDOR_CATEGORY_UTILITY = 0, WEAPON_VENDOR_CATEGORY_AMMO = 0, WEAPON_VENDOR_CATEGORY_ASSISTANT = 0)
	var/list/datum/materiel_stock = list()
	var/token_accepted = /obj/item/requisition_token
	var/log_purchase = FALSE

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "WeaponVendor", src.name)
			ui.open()

	ui_static_data(mob/user)
		. = list("stock" = list())

		for (var/datum/materiel/M as anything in materiel_stock)
			if(!M.vr_allowed && istype(get_area(src), /area/sim))
				continue
			.["stock"] += list(list(
				"ref" = "\ref[M]",
				"name" = M.name,
				"description" = M.description,
				"cost" = M.cost,
				"category" = M.category,
			))

	ui_data(mob/user)
		. = list(
			"credits" = src.credits,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return

		switch(action)
			if ("redeem")
				var/datum/materiel/M = locate(params["ref"]) in materiel_stock
				if (src.credits[M.category] >= M.cost)
					src.credits[M.category] -= M.cost
					var/atom/A = new M.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)
					src.vended(A)
					usr.put_in_hand_or_eject(A)
					return TRUE

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, token_accepted))
			user.drop_item(I)
			qdel(I)
			accepted_token(I, user)
		else
			..()



	proc/accepted_token(var/token, var/mob/user)
		src.ui_interact(user)
		playsound(src.loc, sound_token, 80, 1)
		boutput(user, "<span class='notice'>You insert the requisition token into [src].</span>")
		if(log_purchase)
			logTheThing(LOG_DEBUG, user, "inserted [token] into [src] at [log_loc(get_turf(src))]")


	proc/vended(var/atom/A)
		if(log_purchase)
			logTheThing(LOG_DEBUG, usr, "bought [A] from [src] at [log_loc(get_turf(src))]")
		.= 0

/obj/submachine/weapon_vendor/security
	name = "Security Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon-sec"
	desc = "An automated quartermaster service for supplying your security team with weapons and gear."
	token_accepted = /obj/item/requisition_token/security
	log_purchase = TRUE
	New()
		..()
		materiel_stock += new/datum/materiel/loadout/standard
		materiel_stock += new/datum/materiel/loadout/offense
		materiel_stock += new/datum/materiel/loadout/control
		materiel_stock += new/datum/materiel/loadout/suppression
		materiel_stock += new/datum/materiel/loadout/justabaton
		materiel_stock += new/datum/materiel/utility/morphineinjectors
		materiel_stock += new/datum/materiel/utility/donuts
		materiel_stock += new/datum/materiel/utility/crowdgrenades
		materiel_stock += new/datum/materiel/utility/detscanner
		materiel_stock += new/datum/materiel/utility/nightvisionsechudgoggles
		materiel_stock += new/datum/materiel/utility/markerrounds
		materiel_stock += new/datum/materiel/utility/prisonerscanner
		materiel_stock += new/datum/materiel/ammo/medium
		materiel_stock += new/datum/materiel/ammo/self_charging
		materiel_stock += new/datum/materiel/assistant/basic

	vended(var/atom/A)
		..()
		if (istype(A,/obj/item/storage/belt/security))
			SPAWN(2 DECI SECONDS) //ugh belts do this on spawn and we need to wait
				var/list/tracklist = list()
				for(var/atom/C in A.contents)
					if (istype(C,/obj/item/gun) || istype(C,/obj/item/baton))
						tracklist += C

				if (length(tracklist))
					var/obj/item/pinpointer/secweapons/P = new(src.loc)
					P.track(tracklist)

	accepted_token(var/token)
		if (istype(token, /obj/item/requisition_token/security/assistant))
			src.credits[WEAPON_VENDOR_CATEGORY_ASSISTANT]++
			src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
		else if (istype(token, /obj/item/requisition_token/security/utility))
			src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
		else
			src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
			src.credits[WEAPON_VENDOR_CATEGORY_AMMO]++
			src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
			src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
		..()

/obj/submachine/weapon_vendor/syndicate
	name = "Syndicate Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon"
	desc = "An automated quartermaster service for supplying your nuclear operative team with weapons and gear."
	token_accepted = /obj/item/requisition_token/syndicate
	log_purchase = TRUE

	ex_act()
		return

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		// List of avaliable objects for purchase
		materiel_stock += new/datum/materiel/sidearm/smartgun
		materiel_stock += new/datum/materiel/sidearm/pistol
		materiel_stock += new/datum/materiel/sidearm/revolver

		materiel_stock += new/datum/materiel/loadout/assault
		materiel_stock += new/datum/materiel/loadout/heavy
		materiel_stock += new/datum/materiel/loadout/grenadier
		materiel_stock += new/datum/materiel/loadout/infiltrator
		materiel_stock += new/datum/materiel/loadout/scout
		materiel_stock += new/datum/materiel/loadout/medic
		materiel_stock += new/datum/materiel/loadout/firebrand
		materiel_stock += new/datum/materiel/loadout/engineer
		materiel_stock += new/datum/materiel/loadout/marksman
		materiel_stock += new/datum/materiel/loadout/knight
		materiel_stock += new/datum/materiel/loadout/bard
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
		//materiel_stock += new/datum/materiel/utility/noslip_boots
		materiel_stock += new/datum/materiel/utility/bomb_decoy
		materiel_stock += new/datum/materiel/utility/comtac
		materiel_stock += new/datum/materiel/utility/beartraps
		materiel_stock += new/datum/materiel/utility/miscpouch
		materiel_stock += new/datum/materiel/utility/sawflies

	accepted_token()
		src.credits[WEAPON_VENDOR_CATEGORY_SIDEARM]++
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]+=2
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

// Materiel avaliable for purchase:

/datum/materiel
	var/name = "intimidating military object"
	var/cost = 1
	var/category = null
	var/path = null
	var/description = "If you see me, gannets is an idiot."
	var/vr_allowed = TRUE

/datum/materiel/sidearm
	category = WEAPON_VENDOR_CATEGORY_SIDEARM

/datum/materiel/loadout
	category = WEAPON_VENDOR_CATEGORY_LOADOUT

/datum/materiel/utility
	category = WEAPON_VENDOR_CATEGORY_UTILITY

/datum/materiel/assistant
	category = WEAPON_VENDOR_CATEGORY_ASSISTANT

/datum/materiel/ammo
	category = WEAPON_VENDOR_CATEGORY_AMMO

//SECURITY

/datum/materiel/sidearm/barrier
	name = "Security Barrier"
	path = /obj/item/barrier
	description = "A barrier that grants great protection while held and can deploy shields that reflect projectiles."

/datum/materiel/sidearm/EOD
	name = "EOD Suit"
	path = /obj/item/clothing/suit/armor/EOD
	description = "Protective armor with high explosion resistance."

/datum/materiel/sidearm/flaregun
	name = "Flare Gun"
	path = /obj/item/storage/box/flaregun
	description = "Ignite one target. Must be reloaded after each use."

/datum/materiel/loadout/standard
	name = "Standard"
	path = /obj/item/storage/belt/security/standard
	description = "One belt containing a taser, a baton, and a barrier. Classic!"

/datum/materiel/loadout/offense
	name = "Offense"
	path = /obj/item/storage/belt/security/offense
	description = "One belt containing a wavegun, a baton, and a barrier."

/datum/materiel/loadout/support
	name = "Support"
	path = /obj/item/storage/belt/security/support
	description = "One belt containing a baton, two robust donuts, and some morphine auto-injectors."

/datum/materiel/loadout/control
	name = "Control"
	path = /obj/item/storage/belt/security/control
	description = "One belt containing a taser shotgun, a baton, and a barrier."

/datum/materiel/loadout/suppression
	name = "Suppression"
	path = /obj/item/storage/belt/security/tasersmg
	description = "One belt containing a taser SMG, a baton, and a barrier."

/datum/materiel/loadout/justabaton
	name = "Just a Baton"
	path = /obj/item/storage/belt/security/baton
	description = "One belt containing a baton, a barrier, and a spare utility token. Does NOT come with a ranged weapon. Only for officers who DO NOT want a ranged weapon!"

/datum/materiel/utility/morphineinjectors
	name = "Morphine Autoinjectors"
	path = /obj/item/storage/box/morphineinjectors
	description = "Six Morphine Autoinjectors, capable of ensuring you move at the best possible speed while injured without slowdowns...or used as a makeshift tranquilizer if overdosed."

/datum/materiel/utility/donuts
	name = "Robust(ed) Donuts"
	path = /obj/item/storage/lunchbox/robustdonuts
	description = "One Robust Donut and one Robusted Donut, which are loaded with helpful chemicals that help you resist stuns and heal you!"

/datum/materiel/utility/crowdgrenades
	name = "Crowd Dispersal Grenades"
	path = /obj/item/storage/box/crowdgrenades
	description = "Four 'Crowd Dispersal' pepper gas grenades, capable of clearing out riots. Also seasons food quite well!"

/datum/materiel/utility/detscanner
	name = "Forensics Scanner"
	path = /obj/item/device/detective_scanner
	description = "A scanner capable of reading fingerprints on objects and looking up the records in real time. A favorite of investigators."

/datum/materiel/utility/nightvisiongoggles //Leaving old goggles in for any other uses
	name = "Night Vision Goggles"
	path = /obj/item/clothing/glasses/nightvision
	description = "A pair of Night Vision Goggles. Helps you see in the dark, but doesn't give you any protection from flashes or a SecHud."

/datum/materiel/utility/nightvisionsechudgoggles
	name = "Night Vision SecHUD Goggles"
	path = /obj/item/clothing/glasses/nightvision/sechud
	description = "A pair of Night Vision Sechud Goggles. Helps you see in the dark, but doesn't give you any protection from flashes."

/datum/materiel/utility/markerrounds
	name = "40mm Paint Marker Rounds"
	path = /obj/item/ammo/bullets/marker
	description = "One case of 40mm Paint Marker Rounds, totalling 5 rounds, for the Riot Launcher."

/datum/materiel/utility/prisonerscanner
	name = "RecordTrak Scannner"
	path = /obj/item/device/prisoner_scanner
	description = "A device used to scan in prisoners and update their security records."

/datum/materiel/ammo/medium
	name = "Spare Power Cell"
	path = /obj/item/ammo/power_cell/med_power
	description = "A spare (200u) power cell. Fits in standard issue energy weapons."

/datum/materiel/ammo/self_charging
	name = "Disruptor Power Cell"
	path = /obj/item/ammo/power_cell/self_charging/disruptor
	description = "A small(100u) self-charging power cell repurposed from a decommissioned disruptor blaster."

/datum/materiel/assistant/basic
	name = "Assistant"
	path = /obj/item/storage/belt/security/assistant
	description = "One belt containing a security barrier, a forensic scanner, and a security ticket writer."

//SYNDIE

/datum/materiel/sidearm/smartgun
	name = "Hydra Smart Pistol"
	path = /obj/item/storage/belt/gun/smartgun
	description = "A gun-belt containing a pistol capable of locking onto multiple targets and firing on them in rapid sequence and four magazines."

/datum/materiel/sidearm/pistol
	name = "Branwen Pistol"
	path = /obj/item/storage/belt/gun/pistol
	description = "A gun-belt containing a semi-automatic, 9mm caliber service pistol and three magazines."

/datum/materiel/sidearm/revolver
	name = "Predator Revolver"
	path = /obj/item/storage/belt/gun/revolver
	description = "A gun-belt containing a hefty combat revolver and two .357 caliber speedloaders."

/datum/materiel/loadout/assault
	name = "Assault Trooper"
	path = /obj/storage/crate/classcrate/assault
	description = "A good all-rounder combat class centered around an assault rifle with selectable fire-modes as well as standard and armor-piercing rounds."

/datum/materiel/loadout/heavy
	name = "Heavy Weapons Specialist"
	path = /obj/storage/crate/classcrate/heavy
	description = "Light machine gun, three boxes of ammunition and a pouch of high explosive grenades."

/datum/materiel/loadout/grenadier
	name = "Grenadier"
	path = /obj/storage/crate/classcrate/demo
	description = "Grenade launcher, two pouches containing 40mm grenade rounds and mixed explosive grenades."

/datum/materiel/loadout/infiltrator
	name = "Infiltrator"
	path = /obj/storage/crate/classcrate/infiltrator
	description = "Tranquilizer pistol with a pouch of darts, emag, tools to help you blend in with the crew and pod beacon deployer to help get your team closer to the target location."

/datum/materiel/loadout/scout
	name = "Scout"
	path = /obj/storage/crate/classcrate/scout
	description = "Burst-fire submachine gun, personal cloaking device, light breaker and an emag for sneaky flanking actions."

/datum/materiel/loadout/medic
	name = "Field Medic"
	path = /obj/storage/crate/classcrate/medic_rework
	description = "Comprehensive combat casualty care supplies provided in a satchel, belt and pouch."

/datum/materiel/loadout/firebrand
	name = "Firebrand"
	path = /obj/storage/crate/classcrate/pyro
	description = "Napalm flamethrower, incendiery grenade pouch and a door-breaching fire-axe that can be two-handed to increase damage to both foes and airlocks."

/datum/materiel/loadout/engineer
	name = "Combat Engineer"
	path = /obj/storage/crate/classcrate/engineer
	description = "Automated gun turret with an important guide on how to deploy it, full toolbelt with high-capacity welder and a combat shotgun."

/datum/materiel/loadout/marksman
	name = "Marksman"
	path = /obj/storage/crate/classcrate/sniper
	description = "High-powered sniper rifle that can fire through two solid walls, optical thermal scanner and a pouch of smoke grenades"

/datum/materiel/loadout/knight
	name = "Knight"
	path = /obj/storage/crate/classcrate/melee
	description = "A powerful melee focused class. Equipped with massive, heavy armour and a versatile sword that can switch special attack modes."

/datum/materiel/loadout/bard
	name = "Bard (Prototype)"
	path = /obj/storage/crate/classcrate/bard
	description = "An experimental musician class that supports their team with area of effect buffs centered around amp stacks and hitting things with a cool guitar."

/datum/materiel/loadout/custom
	name = "Custom Class Uplink"
	path = /obj/item/uplink/syndicate/nukeop
	description = "A standard syndicate uplink loaded with 12 telecrystals, allowing you to pick and choose from an array of syndicate items."
/*
/datum/materiel/storage/rucksack
	name = "Assault Rucksack"
	path = /obj/item/storage/backpack/syndie/tactical
	category = "Storage"
	description = "A large 10 slot military backpack, designed to fit a wide array of tools for comprehensive storage support."

/datum/materiel/storage/belt
	name = "Tactical Espionage Belt"
	path = /obj/item/storage/fanny/syndie
	category = "Storage"
	description = "The classic 7 slot syndicate belt pack. Has no relation to the fanny pack."

/datum/materiel/storage/satchel
	name = "Syndicate Satchel"
	path = /obj/item/storage/backpack/satchel/syndie
	category = "Storage"
	description = "An ordinary 6 slot messenger bag in menacing red and black."
*/
/datum/materiel/utility/belt
	name = "Tactical Espionage Belt"
	path = /obj/item/storage/fanny/syndie
	description = "The classic 7 slot syndicate belt pack. Has no relation to the fanny pack."

/datum/materiel/utility/knife
	name = "Combat Knife"
	path = /obj/item/dagger/syndicate/specialist
	description = "A field-tested 10 inch combat knife, helps you move faster when held & knocks down targets when thrown."

/datum/materiel/utility/rpg_ammo
	name = "MPRT Rocket Ammunition"
	path = /obj/item/storage/pouch/rpg
	description = "A pouch for keeping MPRT ammunition in. Comes with two additional rockets."

/datum/materiel/utility/donk
	name = "Warm Donk Pocket"
	path = /obj/item/reagent_containers/food/snacks/donkpocket_w
	description = "A tasty donk pocket, heated by futuristic vending machine technology!"

/datum/materiel/utility/sarin_grenade
	name = "Sarin Grenade"
	path = /obj/item/chem_grenade/sarin
	description = "A terrifying grenade containing a potent nerve gas. Try not to get caught in the smoke."

/datum/materiel/utility/noslip_boots
	name = "Hi-grip Assault Boots"
	path = /obj/item/clothing/shoes/swat/noslip
	description = "Avoid slipping in firefights with these combat boots designed to provide enhanced grip and ankle stability."
	cost = 2

/datum/materiel/utility/bomb_decoy
	name = "Decoy Bomb Balloon"
	path = /obj/bomb_decoy
	description = "A realistic inflatable nuclear bomb decoy, it'll fool anyone not looking closely but won't take much punishment before it pops."

/datum/materiel/utility/comtac
	name = "Military Headset"
	path = /obj/item/device/radio/headset/syndicate/comtac
	description = "A two-way radio headset designed to protect against any incoming hazardous noise, including flashbangs."
	vr_allowed = FALSE

/datum/materiel/utility/beartraps
	name = "Beartraps"
	path = /obj/item/storage/beartrap_pouch
	description = "A pouch of 4 pressure sensitive beartraps used to snare and maim unexpecting victims entering your target area."

/datum/materiel/utility/miscpouch
	name = "High capacity tactical pouch"
	path = /obj/item/storage/pouch/highcap
	description = "A 6-slot pouch for carrying multiple different ammunitions at once"

/datum/materiel/utility/sawflies
	name = "Sawfly pouch"
	path = /obj/item/storage/sawfly_pouch
	description = "A pouch of 3 reusable anti-personnel drones."
// Requisition tokens

/obj/item/requisition_token
	name = "requisition token"
	desc = "A Syndicate credit card charged with currency compatible with the Syndicate Weapons Vendor."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "req-token"
	object_flags = NO_GHOSTCRITTER
	w_class = W_CLASS_TINY


	syndicate
		desc = "A Syndicate credit card charged with currency compatible with the Syndicate Weapons Vendor."
		icon_state = "req-token"

		vr
			name = "syndicoin requisition token"

	security
		desc = "An NT-provided token compatible with the Security Weapons Vendor."
		icon_state = "req-token-sec"

		assistant
			desc = "An NT-provided token compatible with the Security Weapons Vendor. This one says <i>for security assistant use only</i>."
			icon_state = "req-token-secass"

		utility
			desc = "An NT-provided token that entitles the owner to one additional utility purchase."
			icon_state = "req-token-secass"

#undef WEAPON_VENDOR_CATEGORY_SIDEARM
#undef WEAPON_VENDOR_CATEGORY_LOADOUT
#undef WEAPON_VENDOR_CATEGORY_UTILITY
#undef WEAPON_VENDOR_CATEGORY_ASSISTANT
