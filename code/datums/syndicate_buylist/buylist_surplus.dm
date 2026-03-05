/////////////////////////////////////////// Surplus-exclusive items //////////////////////////////////////////////////

ABSTRACT_TYPE(/datum/syndicate_buylist/surplus)
/datum/syndicate_buylist/surplus
	name = "You shouldn't see me!"
	cost = 0
	desc = "You shouldn't see me!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_HEAD_REV | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/dagger
	name = "Syndicate Dagger"
	items = list(/obj/item/dagger/syndicate)
	cost = 2
	desc = "An ornamental dagger for stabbing people with."

/datum/syndicate_buylist/surplus/advanced_laser
	name = "Laser Rifle"
	items = list(/obj/item/gun/energy/plasma_gun)
	cost = 6
	desc = "An experimental laser design with a self-charging cerenkite battery."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/breachingT
	name = "Thermite Breaching Charge"
	items = list(/obj/item/breaching_charge/thermite)
	cost = 1
	desc = "A self-contained thermite breaching charge, useful for destroying walls."

/datum/syndicate_buylist/surplus/breaching
	name = "Breaching Charge"
	items = list(/obj/item/breaching_charge)
	cost = 1
	desc = "A self-contained explosive breaching charge, useful for destroying walls."

/datum/syndicate_buylist/surplus/flaregun
	name = "Flare Gun"
	items = list(/obj/item/storage/box/flaregun) // Gave this thing a box of spare ammo. Having only one shot was kinda lackluster (Convair880).
	cost = 2
	desc = "A signal flaregun for emergency use. Or for setting jerks on fire"
	br_allowed = TRUE

/datum/syndicate_buylist/surplus/rifle
	name = "Old Hunting Rifle"
	items = list(/obj/item/storage/box/hunting_rifle)
	cost = 6
	desc = "An old hunting rifle, comes with a scope and eight bullets. Use them wisely."
	can_buy = UPLINK_TRAITOR | UPLINK_NUKE_OP

	spy
		cost = 5
		vr_allowed = FALSE
		not_in_crates = TRUE
		can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/akm
	name = "AKM Assault Rifle"
	items = list(/obj/item/gun/kinetic/akm)
	cost = 12
	desc = "A Cold War relic, loaded with thirty rounds of 7.62x39."
	can_buy = null

/datum/syndicate_buylist/surplus/bananagrenades
	name = "Banana Grenades"
	items = list(/obj/item/storage/banana_grenade_pouch)
	cost = 2
	desc = "Honk."
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/concussiongrenades
	name = "Concussion Grenades"
	items = list(/obj/item/storage/concussion_grenade_pouch)
	cost = 2
	desc = "A pouch full of corpo-war surplus concussion grenades."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/surplus/turboflash_box
	name = "Flash/cell assembly box"
	items = list(/obj/item/storage/box/turbo_flash_kit)
	cost = 1
	desc = "A box full of common stun weapons with power cells hastily wired into them. Looks dangerous."

/datum/syndicate_buylist/surplus/syndicate_armor
	name = "Syndicate Command Armor"
	items = list(/obj/item/clothing/suit/space/industrial/syndicate, /obj/item/clothing/head/helmet/space/industrial/syndicate)
	cost = 5
	desc = "A set of syndicate command armor. I guess the last owner must have died."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/egun_upgrade
	name = "Advanced Energy Cell"
	items = list(/obj/item/ammo/power_cell/self_charging/medium)
	cost = 2
	desc = "An advanced self-charging power cell, the ideal upgrade for an energy weapon!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/micronuke
	name = "Micronuke"
	items = list(/obj/machinery/nuclearbomb/event/micronuke)
	desc = "A miniaturized version of the nuclear bomb given to our nuclear operative teams. Blow (a small portion) of the station to smithereens!"
	cost = 5
	surplus_weight = 5
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR

	defended
		name = "Defended Micronuke"
		items = list(/obj/machinery/nuclearbomb/event/micronuke/defended)
		desc = "A miniaturized version of the nuclear bomb given to our nuclear operative teams. Now with minature nuclear operatives!"
		cost = 9
		surplus_weight = 1

// Why not, I guess? Cleaned up the old mine code, might as well use it (Convair880).
/datum/syndicate_buylist/surplus/landmine
	name = "Land Mine Pouch"
	items = list(/obj/item/storage/landmine_pouch)
	cost = 1
	desc = "A pouch of old anti-personnel mines we found in the warehouse."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/beartrap
	name = "Bear Trap Pouch"
	items = list(/obj/item/storage/beartrap_pouch)
	cost = 1
	desc = "Just in case you happen to run into some space bears."
	br_allowed = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/cybereye_kit_sechud
	name = "Ocular Prosthesis Kit (SecHUD)"
	items = list(/obj/item/device/ocular_implanter)
	cost = 1
	desc = "A pair of surplus cybereyes that can access the Security HUD system. Comes with a convenient but terrifying implanter."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_SPY | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/emaghypo
	name = "Hacked Hypospray"
	items = list(/obj/item/reagent_containers/hypospray/emagged)
	cost = 1
	desc = "A special hacked hypospray, capable of holding any chemical!"
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/saxitoxin_grenade
	name = "Saxitoxin Grenade"
	items = list(/obj/item/chem_grenade/saxitoxin)
	cost = 1
	desc = "A terrifying grenade containing a potent nerve gas. Try not to get caught in the smoke."
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_NUKE_OP

/datum/syndicate_buylist/surplus/switchblade
	name = "Switchblade"
	items = list(/obj/item/switchblade)
	cost = 2
	desc = "A stylish knife you can hide in your clothes. Special attacks are exceptional at causing heavy bleeding"

/datum/syndicate_buylist/surplus/quickhack
	name = "Quickhack"
	items = list(/obj/item/tool/quickhack/syndicate)
	cost = 1
	desc = "An illegal, home-made tool able to fake up to 10 AI 'open' signals to unbolted doors."

/datum/syndicate_buylist/surplus/basketball
	name = "Extremely illegal basketball"
	items = list(/obj/item/basketball/lethal)
	cost = 3
	desc = "An even more illegal basketball capable of dangerous levels of balling."
