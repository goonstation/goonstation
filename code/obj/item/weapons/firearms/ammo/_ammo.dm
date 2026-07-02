////////////////////////////////////////// _Ammo parent //////////////////////////////////////////////////
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

ABSTRACT_TYPE(/obj/item/ammo)
/obj/item/ammo
	name = "ammo"
	var/sname = "Generic Ammo"
	icon = 'icons/obj/items/ammo.dmi'
	flags = TABLEPASS | CONDUCT
	item_state = "syringe_kit"
	m_amt = 40000
	g_amt = 0
	throwforce = 2
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	var/datum/projectile/ammo_type
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	inventory_counter_enabled = 1
	///Can this ammo be cooked off by heating?
	var/cookable = TRUE

	proc
		swap(var/obj/item/ammo/A)
			return

		use(var/amt = 0)
			return 0
