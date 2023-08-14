
//represents a container of loose ammo
//that can be attached to a kinetic firearmm
/obj/item/ammo/magazine

	var/start_amount = 0
	var/max_amount = 1000
	var/loaded_ammo = /obj/item/ammo/bullets/bullet_9mm
	var/obj/item/ammo/bullets/ammo
	var/sound_load = 'sound/weapons/gunload_light.ogg'

	// Can you use this like a handful of bullets?
	var/auto_load = FALSE

	// Are you blocked from removing bullets from this magazine?
	// You might want to toggle this to 'true' if you don't want nukies emptying contents into their pockets & refilling mags.
	var/locked = FALSE
	attack_hand(mob/user)
		if (!user)
			return
		if (locked)
			return
		..()
	New()
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		ammo = new loaded_ammo()
		ammo.set_loc(src)
		ammo.max_amount = max_amount
		ammo.amount_left = start_amount
		inventory_counter?.update_number(src.ammo?.amount_left)
		..()



	update_icon()
		if (src.ammo)
			inventory_counter?.update_number(src.ammo?.amount_left)
		else
			inventory_counter?.update_text("-")

	proc/get_ammo_type()
		return ammo.ammo_type

	proc/ammo_left()
		return ammo?.amount_left

	proc/pull_ammo(var/quantity)
		var/obj/item/ammo/bullets/result
		if (ammo.amount_left == 0)
			return null
		else
			result = new ammo.type()
			var/amt = min(quantity,ammo.amount_left)
			result.amount_left = amt
			ammo.use(amt)
			return result

	use(var/amt = 0)
		var/res = ammo.use(amt)
		src.UpdateIcon()
		return res



	swap(var/obj/item/ammo/magazine/mag2, var/obj/item/gun/kinetic/K)
		usr.u_equip(src)
		usr.put_in_hand_or_drop(mag2)
		src.set_loc(K)
		K.magazine = src
		K.UpdateIcon()
		mag2.UpdateIcon()
		..()

	proc/loadammo(var/obj/item/gun/kinetic/K, var/mob/usr)
		if (auto_load)
			return ammo.loadammo(K,usr)
		// Also see attackby() in kinetic.dm.
		if (!K)
			return 0 // Error message.
		if (K.sanitycheck() == 0)
			return 0
		if (!K.can_hold_magazine)
			return AMMO_RELOAD_INCOMPATIBLE
		var/check = 0
		if (ammo.ammo_cat in K.ammo_cats)
			check = 1
		else if (K.ammo_cats == null) //someone forgot to set ammo cats. scream
			check = 1
		if (!check)
			return AMMO_RELOAD_INCOMPATIBLE

		K.add_fingerprint(usr)
		src.add_fingerprint(usr)
		if(K.sound_load_override)
			playsound(K, K.sound_load_override, 50, 1)
		else
			playsound(K, sound_load, 50, 1)

		if (ammo_left() < 1)
			return AMMO_RELOAD_SOURCE_EMPTY // Magazine's empty.
		if (K.magazine)
			return AMMO_RELOAD_TYPE_SWAP // Call swap().
		else
			K.magazine = src
			usr.u_equip(src)
			src.set_loc(K)
			K.update_icon()
			return AMMO_RELOAD_FULLY // Full reload or ammo left over.

	attackby(obj/b, mob/user)
		if(istype(b, /obj/item/ammo/bullets))
			if(b.type == src.ammo.type)
				src.ammo.attackby(b,user)
				UpdateIcon()
				return


	smg
		name = "9mm SMG magazine"
		desc = "An extended 9mm magazine for a sub machine gun."
		icon_state = "smg_magazine"
		start_amount = 30
		max_amount = 30
		loaded_ammo = /obj/item/ammo/bullets/bullet_9mm/smg

		incen
			icon_state = "smg_magazine_inc"
			loaded_ammo = /obj/item/ammo/bullets/bullet_9mm/smg/incendiary


	bullet_22

		icon_state = "pistol_magazine"
		start_amount = 10
		max_amount = 10
		desc = "A tiny magazine for tiny bullets."
		loaded_ammo = /obj/item/ammo/bullets/bullet_22
		faith
			start_amount = 4
			max_amount = 4
			name = ".22 Faith magazine"
			desc = "A cute little .22 mag! It holds 4 rounds"
			loaded_ammo = /obj/item/ammo/bullets/bullet_22

