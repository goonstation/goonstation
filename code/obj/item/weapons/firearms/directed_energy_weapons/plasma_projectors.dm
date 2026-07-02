///////////////////////////////////////Hunter
TYPEINFO(/obj/item/firearm/energy/plasma_gun)
	mats = list("metal_superdense" = 7,
				"crystal" = 13,
				"energy_high" = 10)
/obj/item/firearm/energy/plasma_gun/ // Made use of a spare sprite here (Convair880).
	name = "plasma rifle"
	desc = "This advanced bullpup rifle contains a self-recharging power cell."
	icon_state = "bullpup"
	item_state = "bullpup"
	var/base_item_state = "bullpup"
	force = 5
	cell_type = /obj/item/ammo/power_cell/self_charging/mediumbig
	muzzle_flash = "muzzle_flash_plaser"
	uses_charge_overlay = TRUE
	charge_icon_state = "bullpup"

	New()
		set_current_projectile(new/datum/projectile/laser/plasma)
		projectiles = list(new/datum/projectile/laser/plasma)
		..()

/obj/item/firearm/energy/plasma_gun/vr
	name = "advanced laser gun"
	icon = 'icons/effects/VR.dmi'
	icon_state = "wavegun"
	base_item_state = "wavegun"
	uses_charge_overlay = TRUE
	charge_icon_state = "wavegun"

TYPEINFO(/obj/item/firearm/energy/plasma_gun/hunter)
	analyser_flags = ANALYSER_BLACKLIST

/obj/item/firearm/energy/plasma_gun/hunter
	name = "Hunter's plasma rifle"
	desc = "This unusual looking rifle contains a self-recharging power cell."
	icon_state = "hunter"
	item_state = "hunter"
	base_item_state = "hunter"
	uses_charge_overlay = TRUE
	charge_icon_state = "hunter"
	var/hunter_key = "" // The owner of this rifle.

	New()
		..()
		if(istype(src.loc, /mob/living))
			var/mob/M = src.loc
			src.AddComponent(/datum/component/self_destruct, M)
			src.AddComponent(/datum/component/send_to_target_mob, src)
			src.hunter_key = M.mind.key
			START_TRACKING_CAT(TR_CAT_HUNTER_GEAR)
			FLICK("[src.base_item_state]-tele", src)

	disposing()
		. = ..()
		if (hunter_key)
			STOP_TRACKING_CAT(TR_CAT_HUNTER_GEAR)

// HOWIZTER GUN
// dumb meme admin item. not remotely fair, will probably kill person firing it.
/obj/item/firearm/energy/howitzer
	name = "man-portable plasma howitzer"
	desc = "How can you even lift this?"
	icon_state = "bfg"
	force = 25
	two_handed = 1
	can_dual_wield = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/howitzer
	camera_recoil_enabled = TRUE
	recoil_strength = 50

	New()
		..()
		set_current_projectile(new/datum/projectile/special/howitzer)
		projectiles = list(new/datum/projectile/special/howitzer )

TYPEINFO(/obj/item/firearm/energy/optio1)
	mats = list("iridiumalloy" = 30,
				"plutonium" = 15,
				"electrum" = 25)
