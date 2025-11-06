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
#define WEAPON_VENDOR_CATEGORY_FISHING "fishing"
#define WEAPON_VENDOR_CATEGORY_ARMOR "armor"

/obj/submachine/weapon_vendor
	name = "Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon"
	desc = "dont see this"
	density = 1
	opacity = 0
	anchored = ANCHORED
	flags = TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER //cry about it
	layer = OBJ_LAYER - 0.1	// Match vending machines

	var/sound_token = 'sound/machines/capsulebuy.ogg'
	var/sound_buy = 'sound/machines/spend.ogg'
#ifdef BONUS_POINTS
	var/list/credits = list(WEAPON_VENDOR_CATEGORY_LOADOUT = 999, WEAPON_VENDOR_CATEGORY_SIDEARM = 999, WEAPON_VENDOR_CATEGORY_UTILITY = 999, WEAPON_VENDOR_CATEGORY_AMMO = 999, WEAPON_VENDOR_CATEGORY_ASSISTANT = 999, WEAPON_VENDOR_CATEGORY_ARMOR = 999)
#else
	var/list/credits = list(WEAPON_VENDOR_CATEGORY_LOADOUT = 0, WEAPON_VENDOR_CATEGORY_SIDEARM = 0, WEAPON_VENDOR_CATEGORY_UTILITY = 0, WEAPON_VENDOR_CATEGORY_AMMO = 0, WEAPON_VENDOR_CATEGORY_ASSISTANT = 0, WEAPON_VENDOR_CATEGORY_ARMOR = 0)
#endif
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
		if (. || GET_COOLDOWN(src, "anti-spam"))
			return

		switch(action)
			if ("redeem")
				var/datum/materiel/M = locate(params["ref"]) in materiel_stock
				if (src.credits[M.category] >= M.cost)
					src.credits[M.category] -= M.cost
					if (!M.cost)
						ON_COOLDOWN(src, "anti-spam", 1 SECOND)
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
		playsound(src.loc, sound_token, 80, 0)
		boutput(user, SPAN_NOTICE("You insert the requisition token into [src]."))
		if(log_purchase)
			logTheThing(LOG_STATION, user, "inserted [token] into [src] at [log_loc(get_turf(src))]")


	proc/vended(var/atom/A)
		if(log_purchase)
			logTheThing(LOG_STATION, usr, "bought [A] from [src] at [log_loc(get_turf(src))]")
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
		materiel_stock += new/datum/materiel/utility/flashbangs
		materiel_stock += new/datum/materiel/utility/detscanner
		materiel_stock += new/datum/materiel/utility/nightvisionsechudgoggles
		materiel_stock += new/datum/materiel/utility/markerrounds
		materiel_stock += new/datum/materiel/utility/prisonerscanner
		materiel_stock += new/datum/materiel/utility/sechudeye

		materiel_stock += new/datum/materiel/ammo/medium
		materiel_stock += new/datum/materiel/ammo/self_charging

		materiel_stock += new/datum/materiel/assistant/basic

	vended(var/atom/A)
		..()
		if (istype(A,/obj/item/storage/belt/security))
			var/list/tracklist = list()
			for(var/atom/C in A.storage.get_contents())
				if (istype(C,/obj/item/gun) || istype(C,/obj/item/baton))
					tracklist += C

			if (length(tracklist))
				var/obj/item/pinpointer/secweapons/P = new(src.loc)
				P.track(tracklist)
				P.name_suffix("([usr.real_name])")
				P.UpdateName()
				usr.put_in_hand_or_eject(P)


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
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()
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
		materiel_stock += new/datum/materiel/utility/saxitoxin_grenade
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

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		switch(action) // Keep track of each purchase for the crew credits
			if ("redeem")
				var/datum/materiel/M = locate(params["ref"]) in materiel_stock
				if (src.credits[M.category] >= M.cost && usr.mind.is_antagonist())
					var/datum/antagonist/nuclear_operative/nukie = usr.mind.get_antagonist(ROLE_NUKEOP) || usr.mind.get_antagonist(ROLE_NUKEOP_COMMANDER)
					nukie?.purchased_items.Add(M)
		..()


/obj/submachine/weapon_vendor/pirate
	name = "Pirate Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon-pirates"
	desc = "An automated quartermaster service for supplying your pirate crew with weapons and gear."
	token_accepted = /obj/item/requisition_token/pirate
	log_purchase = TRUE
	layer = 4

	ex_act()
		return

	New()
		materiel_stock += new/datum/materiel/loadout/musketeer
		materiel_stock += new/datum/materiel/loadout/buccaneer
		..()

	accepted_token()
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		..()

/obj/submachine/weapon_vendor/fishing
	name = "Fishing Supplies Vendor"
	desc = "An automated quartermaster service for obtaining and upgrading your fishing gear."
	icon_state = "fishing"
	credits = list(WEAPON_VENDOR_CATEGORY_FISHING = 0)
	token_accepted = /obj/item/currency/fishing
	sound_token = 'sound/effects/insert_ticket.ogg'
	log_purchase = FALSE
	layer = 4

	ex_act()
		return

	New()
		materiel_stock += new/datum/materiel/fishing_gear/rod
		materiel_stock += new/datum/materiel/fishing_gear/upgraded_rod
		materiel_stock += new/datum/materiel/fishing_gear/master_rod
		materiel_stock += new/datum/materiel/fishing_gear/uniform
		materiel_stock += new/datum/materiel/fishing_gear/hat
		materiel_stock += new/datum/materiel/fishing_gear/fish_box
		materiel_stock += new/datum/materiel/fishing_gear/fish_mount
		..()

	accepted_token(var/obj/item/currency/fishing/token)
		if (istype(token, /obj/item/currency/fishing))
			src.credits[WEAPON_VENDOR_CATEGORY_FISHING]+=token.amount
		..()

	attack_ai(mob/user)
		return ui_interact(user)

	MouseDrop_T(var/obj/item/I, var/mob/user)

		if (istype(I, /obj/item/currency/fishing))
			src.Attackby(I, user)

/obj/submachine/weapon_vendor/fishing/portable
	anchored = UNANCHORED

	attackby(obj/item/W, mob/user)
		if (istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [src.anchored ? "unanchors" : "anchors"] the [src].")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
			src.anchored = !(src.anchored)
			return
		else
			return ..()

/obj/submachine/weapon_vendor/podwars
	name = "Weapons Vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "weapon"
	desc = "An automated quartermaster service for supplying your team with weapons and gear."
	token_accepted = /obj/item/requisition_token/podwars
	log_purchase = TRUE

	accepted_token(var/token)
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_SIDEARM]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
		src.credits[WEAPON_VENDOR_CATEGORY_ARMOR]++
		..()

/obj/submachine/weapon_vendor/podwars/neutral // Neutral for admin gimmicks, spawns non-team aligned gear usable by anyone

	New()
		..()
		materiel_stock += new/datum/materiel/loadout/pw_pistol
		materiel_stock += new/datum/materiel/loadout/pw_smg
		materiel_stock += new/datum/materiel/loadout/pw_shotgun

		materiel_stock += new/datum/materiel/sidearm/knife
		materiel_stock += new/datum/materiel/sidearm/machete
		materiel_stock += new/datum/materiel/sidearm/axe

		materiel_stock += new/datum/materiel/utility/pw_pouch
		materiel_stock += new/datum/materiel/utility/pw_advanced_belt
		materiel_stock += new/datum/materiel/utility/preparedtoolbelt
		materiel_stock += new/datum/materiel/utility/pw_medical_pouch
		materiel_stock += new/datum/materiel/utility/noslip_boots
		materiel_stock += new/datum/materiel/utility/beartraps
		materiel_stock += new/datum/materiel/utility/supernightvisiongoggles
		materiel_stock += new/datum/materiel/utility/comtac


/obj/submachine/weapon_vendor/podwars/NT
	token_accepted = /obj/item/requisition_token/podwars/NT
	color = "#3399ff" // so it's easy to tell which one you spawned

	New()
		..()
		materiel_stock += new/datum/materiel/loadout/pw_NTpistol
		materiel_stock += new/datum/materiel/loadout/pw_NTsmg
		materiel_stock += new/datum/materiel/loadout/pw_NTshotgun

		materiel_stock += new/datum/materiel/sidearm/knife/NT
		materiel_stock += new/datum/materiel/sidearm/machete/NT
		materiel_stock += new/datum/materiel/sidearm/axe/NT

		materiel_stock += new/datum/materiel/utility/pw_pouch
		materiel_stock += new/datum/materiel/utility/pw_advanced_belt
		materiel_stock += new/datum/materiel/utility/preparedtoolbelt
		materiel_stock += new/datum/materiel/utility/pw_medical_pouch
		materiel_stock += new/datum/materiel/utility/pw_medical_belt
		materiel_stock += new/datum/materiel/utility/noslip_boots
		materiel_stock += new/datum/materiel/utility/beartraps
		materiel_stock += new/datum/materiel/utility/supernightvisiongoggles
		materiel_stock += new/datum/materiel/utility/pw_NTcomtac

		materiel_stock += new/datum/materiel/armor/pw_NT_medic
		materiel_stock += new/datum/materiel/armor/pw_NT_eng

/obj/submachine/weapon_vendor/podwars/SY
	token_accepted = /obj/item/requisition_token/podwars/SY
	color = "#ff9966" // so it's easy to tell which one you spawned

	New()
		..()
		materiel_stock += new/datum/materiel/loadout/pw_SYpistol
		materiel_stock += new/datum/materiel/loadout/pw_SYsmg
		materiel_stock += new/datum/materiel/loadout/pw_SYshotgun

		materiel_stock += new/datum/materiel/sidearm/knife/SY
		materiel_stock += new/datum/materiel/sidearm/machete/SY
		materiel_stock += new/datum/materiel/sidearm/axe/SY

		materiel_stock += new/datum/materiel/utility/pw_pouch
		materiel_stock += new/datum/materiel/utility/pw_advanced_belt
		materiel_stock += new/datum/materiel/utility/preparedtoolbelt
		materiel_stock += new/datum/materiel/utility/pw_medical_pouch
		materiel_stock += new/datum/materiel/utility/pw_medical_belt
		materiel_stock += new/datum/materiel/utility/noslip_boots
		materiel_stock += new/datum/materiel/utility/beartraps
		materiel_stock += new/datum/materiel/utility/supernightvisiongoggles
		materiel_stock += new/datum/materiel/utility/pw_SYcomtac

		materiel_stock += new/datum/materiel/armor/pw_SY_medic
		materiel_stock += new/datum/materiel/armor/pw_SY_eng

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

/datum/materiel/fishing_gear
	category = WEAPON_VENDOR_CATEGORY_FISHING

/datum/materiel/armor
	category = WEAPON_VENDOR_CATEGORY_ARMOR

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
	description = "One belt containing a baton (or three), a barrier, and a spare utility token. Does NOT come with a ranged weapon. Only for officers who DO NOT want a ranged weapon!"

/datum/materiel/utility/morphineinjectors
	name = "Morphine Autoinjectors"
	path = /obj/item/storage/box/morphineinjectors
	description = "Six Morphine Autoinjectors, capable of ensuring you move at the best possible speed while injured without slowdowns...or used as a makeshift tranquilizer if overdosed."

/datum/materiel/utility/donuts
	name = "Robust(ed) Donuts"
	path = /obj/item/storage/lunchbox/robustdonuts
	description = "One Robust Donut and one Robusted Donut, which are loaded with helpful chemicals that help you resist stuns and heal you!"

/datum/materiel/utility/flashbangs
	name = "Flashbang Grenades"
	path = /obj/item/storage/box/flashbang_kit/vendor
	description = "Four flash bangs, capable of inhibiting riots."

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
	name = "RecordTrak Scanner"
	path = /obj/item/device/prisoner_scanner
	description = "A device used to scan in prisoners and update their security records."

/datum/materiel/utility/sechudeye
	name = "Security HUD CyberEye"
	path = /obj/item/organ/eye/cyber/sechud
	description = "A fancy electronic eye. It has a Security HUD system installed. Note: Does not come with any installation tools."

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
	description = "A gun-belt containing a semi-automatic, 9mm caliber service pistol and four magazines."

/datum/materiel/sidearm/revolver
	name = "Kestrel Revolver"
	path = /obj/item/storage/belt/gun/revolver
	description = "A gun-belt containing a hefty combat revolver and three .357 caliber speedloaders."

/datum/materiel/loadout/assault
	name = "Assault Trooper"
	path = /obj/storage/crate/classcrate/assault
	description = "A good all-rounder combat class centered around an assault rifle with selectable fire-modes as well as standard and armor-piercing rounds."

/datum/materiel/loadout/heavy
	name = "Heavy Weapons Specialist"
	path = /obj/storage/crate/classcrate/heavy
	description = "Light machine gun, five boxes of ammunition and a pouch of high explosive grenades."

/datum/materiel/loadout/grenadier
	name = "Grenadier"
	path = /obj/storage/crate/classcrate/demo
	description = "Grenade launcher, two pouches containing 40mm grenade rounds and mixed explosive grenades."

/datum/materiel/loadout/infiltrator
	name = "Infiltrator"
	path = /obj/storage/crate/classcrate/infiltrator
	description = "Tranquilizer pistol with a pouch of darts, EMAG and a variety of tools to help you blend in with regular crew."

/datum/materiel/loadout/scout
	name = "Scout"
	path = /obj/storage/crate/classcrate/scout
	description = "Burst-fire submachine gun, personal cloaking device, light breaker and an EMAG for sneaky flanking actions."

/datum/materiel/loadout/medic
	name = "Field Medic"
	path = /obj/storage/crate/classcrate/medic_rework
	description = "Comprehensive combat casualty care supplies provided in a satchel, belt and pouch. As well as an armor-piercing personal defence weapon with single and burst fire capability."

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
	name = "Bard"
	path = /obj/storage/crate/classcrate/bard
	description = "A musical support class that buffs their team with area of effect songs centered around amp stacks and hitting things with their cool guitar."

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
	path = /obj/item/storage/fanny/syndie/large
	description = "The classic 7 slot syndicate belt pack. Has no relation to the fanny pack."

/datum/materiel/utility/knife
	name = "Combat Knife"
	path = /obj/item/dagger/specialist
	description = "A field-tested 10 inch combat knife, helps you move faster when held & knocks down targets when thrown."

/datum/materiel/utility/rpg_ammo
	name = "MPRT Rocket Ammunition"
	path = /obj/item/storage/pouch/rpg
	description = "A pouch for keeping MPRT ammunition in. Comes with two additional rockets."

/datum/materiel/utility/donk
	name = "Warm Donk Pocket"
	path = /obj/item/reagent_containers/food/snacks/donkpocket_w
	description = "A tasty donk pocket, heated by futuristic vending machine technology!"

/datum/materiel/utility/saxitoxin_grenade
	name = "Saxitoxin Grenade"
	path = /obj/item/chem_grenade/saxitoxin
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

// PIRATE
/datum/materiel/loadout/musketeer
	name = "Musketeer"
	path = /obj/item/storage/backpack/satchel/flintlock_rifle_satchel
	description = "Flintlock rifle and 15 rounds of ammunition provided in a specialised satchel."

/datum/materiel/loadout/buccaneer
	name = "Buccaneer"
	path = /obj/item/storage/backpack/satchel/flintlock_pistol_satchel
	description = "A set of two flintlock pistols and 15 rounds of ammunition."

//FISHING
/datum/materiel/fishing_gear/rod
	name = "Basic fishing rod"
	path = /obj/item/fishing_rod/basic
	description = "A basic fishing rod."
	cost = 0

/datum/materiel/fishing_gear/upgraded_rod
	name = "Upgraded fishing rod"
	path = /obj/item/fishing_rod/upgraded
	description = "An upgraded fishing rod, able to fish in a variety of more difficult locations."
	cost = 25

/datum/materiel/fishing_gear/master_rod
	name = "Master fishing rod"
	path = /obj/item/fishing_rod/master
	description = "The ultimate fishing rod, capable of fishing in the most extreme circumstances."
	cost = 50

/datum/materiel/fishing_gear/fish_box
	name = "Portable aquarium"
	path = /obj/item/storage/fish_box
	description = "A temporary solution for bulk-fish transportation. Holds 6 fish in relative comfort."
	cost = 10

/datum/materiel/fishing_gear/uniform
	name = "Angler's overalls"
	path = /obj/item/clothing/under/rank/angler
	description = "Smells fishy; It's wearer must have a keen appreciation for the piscine."
	cost = 5

/datum/materiel/fishing_gear/hat
	name = "Fish fear me cap"
	path = /obj/item/clothing/head/fish_fear_me
	description = "The ultimate angling headwear. Comes with a new, personalised message every time."
	cost = 15

/datum/materiel/fishing_gear/fish_mount
	name = "Fish Wall Mount"
	path = /obj/item/wall_trophy/fish_trophy
	description = "A Wall Mount to attach fish to and show it off."
	cost = 10

// Pod wars stuff
// Includes neutral loadouts for admin gimmicks

//Pod wars weapon loadouts
/datum/materiel/loadout/pw_pistol
	name = "Blaster Pistol"
	path = /obj/item/storage/belt/podwars/pistol
	description = "A small holster containing a high power blaster pistol."

/datum/materiel/loadout/pw_NTpistol
	name = "Blaster Pistol"
	path = /obj/item/storage/belt/podwars/NTpistol
	description = "A small holster containing a high power blaster pistol."

/datum/materiel/loadout/pw_SYpistol
	name = "Blaster Pistol"
	path = /obj/item/storage/belt/podwars/SYpistol
	description = "A small holster containing a high power blaster pistol."

/datum/materiel/loadout/pw_smg
	name = "SMG"
	path = /obj/item/storage/belt/podwars/smg
	description = "A small holster containing a rapid fire SMG."

/datum/materiel/loadout/pw_NTsmg
	name = "SMG"
	path = /obj/item/storage/belt/podwars/NTsmg
	description = "A small holster containing a rapid fire SMG."

/datum/materiel/loadout/pw_SYsmg
	name = "SMG"
	path = /obj/item/storage/belt/podwars/SYsmg
	description = "A small holster containing a rapid fire SMG."

/datum/materiel/loadout/pw_shotgun
	name = "Shotgun"
	path = /obj/item/storage/belt/podwars/shotgun
	description = "A small holster containing a shotgun."

/datum/materiel/loadout/pw_NTshotgun
	name = "Shotgun"
	path = /obj/item/storage/belt/podwars/NTshotgun
	description = "A small holster containing a shotgun."

/datum/materiel/loadout/pw_SYshotgun
	name = "Shotgun"
	path = /obj/item/storage/belt/podwars/SYshotgun
	description = "A small holster containing a shotgun."

// Pod wars specific utilities
/datum/materiel/utility/pw_medical_pouch
	name = "Medical Injector Pouch"
	path = /obj/item/storage/pw_medical_pouch
	description = "A small pouch containing four advanced medical autoinjectors."
	cost = 2
/datum/materiel/utility/pw_pouch
	name = "High Capacity Tactical Pouch"
	path = /obj/item/storage/pouch/highcap/pod_wars
	description = "A pouch that can hold up to 4 normal sized items. Fits in your pocket."

/datum/materiel/utility/pw_advanced_belt
	name = "Tactical Belt"
	path = /obj/item/storage/belt/podwars/advanced
	description = "A belt to replace your standard issue holster, capable of carrying up to 6 bulky items into battle."

/datum/materiel/utility/preparedtoolbelt
	name = "Loaded Utility Toolbelt"
	path = /obj/item/storage/belt/utility/prepared
	description = "A fully loaded utility toolbelt."

/datum/materiel/utility/supernightvisiongoggles
	name = "Advanced Night Vision Goggles"
	path = /obj/item/clothing/glasses/nightvision/flashblocking
	description = "An advanced pair of night vision goggles. These goggles protect the wearer from flashes"

/datum/materiel/utility/pw_NTcomtac
	name = "Military Headset"
	path = /obj/item/device/radio/headset/pod_wars/nanotrasen/comtac
	description = "A two-way radio headset designed to protect against any incoming hazardous noise, including flashbangs."

/datum/materiel/utility/pw_SYcomtac
	name = "Military Headset"
	path = /obj/item/device/radio/headset/pod_wars/syndicate/comtac
	description = "A two-way radio headset designed to protect against any incoming hazardous noise, including flashbangs."

/datum/materiel/utility/pw_medical_belt
	name = "Loaded Medical Belt"
	path = /obj/item/storage/belt/medical/podwars
	description = "A medical belt preloaded with menders, hypospray, suture, defibrilator, an upgraded health analyzer, and upgraded health hud goggles."

/datum/materiel/armor/pw_NT_pilot
	name = "nanotrasen pod pilot suit"
	path = /obj/item/clothing/suit/space/pod_wars/NT
	description = "Standard suit worn by Pod Pilots (Only difference between these suits is cosmetic)"

/datum/materiel/armor/pw_NT_medic
	name = "nanotrasen pod medic suit"
	path = /obj/item/clothing/suit/space/pod_wars/NT/medic
	description = "Standard suit worn by Pod Medics (Only difference between these suits is cosmetic)"

/datum/materiel/armor/pw_NT_eng
	name = "nanotrasen pod engineer suit"
	path = /obj/item/clothing/suit/space/pod_wars/NT/eng
	description = "Standard suit worn by Pod Engineers (Only difference between these suits is cosmetic)"

/datum/materiel/armor/pw_SY_pilot
	name = "syndicate pod pilot suit"
	path = /obj/item/clothing/suit/space/pod_wars/SY
	description = "Standard suit worn by Pod Pilots (Only difference between these suits is cosmetic)"

/datum/materiel/armor/pw_SY_medic
	name = "syndicate pod medic suit"
	path = /obj/item/clothing/suit/space/pod_wars/SY/medic
	description = "Standard suit worn by Pod Medics (Only difference between these suits is cosmetic)"

/datum/materiel/armor/pw_SY_eng
	name = "syndicate pod engineer suit"
	path = /obj/item/clothing/suit/space/pod_wars/SY/eng
	description = "Standard suit worn by Pod Engineers (Only difference between these suits is cosmetic)"

// Pod wars sidearms (melee)
/datum/materiel/sidearm/knife
	name = "pilot survival knife"
	path = /obj/item/survival_knife
	description = "A low damage knife that speeds you up in combat."

/datum/materiel/sidearm/knife/NT
	path = /obj/item/survival_knife/NT

/datum/materiel/sidearm/knife/SY
	path = /obj/item/survival_knife/SY

/datum/materiel/sidearm/machete
	name = "pilot survival machete"
	path = /obj/item/survival_machete
	description = "A medium damage machete."

/datum/materiel/sidearm/machete/NT
	path = /obj/item/survival_machete/NT

/datum/materiel/sidearm/machete/SY
	path = /obj/item/survival_machete/SY

/datum/materiel/sidearm/axe
	name = "pilot survival axe"
	path = /obj/item/survival_axe
	description = "A high damage axe that can be dual wielded for increased damage. Slows you down when carried."

/datum/materiel/sidearm/axe/NT
	path = /obj/item/survival_axe/NT

/datum/materiel/sidearm/axe/SY
	path = /obj/item/survival_axe/SY

// End of pod wars stuff


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

	pirate
		name = "doubloon"
		desc = "A finely stamped gold coin compatible with the Pirate Weapons Vendor."
		icon_state = "doubloon"

	podwars
		desc = "A credit token compatible with an advanced armory vendor."
		icon_state = "req-token-secass"

		NT
			icon_state = "req-token-sec"

		SY
			icon_state ="req-token"

#undef WEAPON_VENDOR_CATEGORY_SIDEARM
#undef WEAPON_VENDOR_CATEGORY_LOADOUT
#undef WEAPON_VENDOR_CATEGORY_UTILITY
#undef WEAPON_VENDOR_CATEGORY_ASSISTANT
#undef WEAPON_VENDOR_CATEGORY_FISHING
#undef WEAPON_VENDOR_CATEGORY_ARMOR
