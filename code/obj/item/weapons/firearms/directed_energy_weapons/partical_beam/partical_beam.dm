////////////////////////////////////////// Particle beam child //////////////////////////////////////////////////
// To be completed refactores file location for weapons pre-2026-era code here. All weapons code parents should be placed inside the primary folders as primary directives.
// All files secondary to such must be placed in a new secondary folder within the primary folder. This is to ensure that all weapons code is properly-
// organized and as easy to navigate for future development and maintenance. Ensure they are named appropriately.
//
// Contains:
// - Primary Folder
// -- example_parent.dm
// -- Secondary Folder
// --- example_child.dm
//

/obj/item/firearm/energy/heavyion
	name = "\improper Tianfei heavy ion blaster"
	icon = 'icons/obj/items/guns/energy48x32.dmi'
	icon_state = "heavyion"
	item_state = "rifle"
	force = 1
	desc = "The XIANG|GIESEL model '天妃', a hefty laser-induced ionic disruptor with a self-charging radio-isotopic power core. Feared by rogue cyborgs across the Frontier."
	can_dual_wield = FALSE
	two_handed = 1
	slowdown = 5
	slowdown_time = 5
	cell_type = /obj/item/ammo/power_cell/self_charging/disruptor
	w_class = W_CLASS_BULKY
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	New()
		set_current_projectile(new/datum/projectile/heavyion)
		projectiles = list(current_projectile)
		AddComponent(/datum/component/holdertargeting/windup, 1.5 SECONDS)
		..()

	pixelaction(atom/target, params, mob/user, reach)
		if(..(target, params, user, reach))
			playsound(user, 'sound/weapons/heavyioncharge.ogg', 90)
