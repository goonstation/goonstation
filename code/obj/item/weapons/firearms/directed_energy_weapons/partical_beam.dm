/obj/item/gun/energy/heavyion
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
