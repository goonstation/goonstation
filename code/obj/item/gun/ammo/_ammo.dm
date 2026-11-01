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
