//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Weapons ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

//40mm launcher ( skin )
/obj/item/gun/kinetic/riot40mm/morrigan
	icon_state = "s40mm"
	item_state = "s40mm"

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Railgun ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
TYPEINFO(/obj/item/gun/energy/railgun_experimental)
	mats = null
/obj/item/gun/energy/railgun_experimental
	name = "Mod.54 Electro Slinger"
	cell_type = /obj/item/ammo/power_cell/self_charging/railgun_experimental
	icon = 'icons/obj/adventurezones/morrigan/weapons/gunlarge.dmi'
	icon_state = "railgun"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	desc = "An experimental Morrigan weapon that draws a lot of power to fling projectiles are dangerous speeds, it seems to be in working condition."
	item_state = "railgun"
	force = 10
	shoot_delay = 1 SECONDS
	two_handed = TRUE
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_elec"
	charge_icon_state = "railgun"
	w_class = W_CLASS_BULKY
	c_flags = ONBACK | ONBELT
	cantshootsound = 'sound/weapons/railgunwait.ogg'

	New()
		set_current_projectile(new/datum/projectile/bullet/optio/hitscanrail)
		projectiles = list(new/datum/projectile/bullet/optio/hitscanrail)
		..()

	equipped(var/mob/user, var/slot)
		if (slot == SLOT_BELT)
			wear_image_icon = 'icons/mob/clothing/belt.dmi'
			wear_layer = MOB_BACK_SUIT_LAYER
		else if (slot == SLOT_BACK)
			wear_image_icon = 'icons/mob/clothing/back.dmi'
			wear_layer = MOB_BACK_LAYER
		..()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Laser Pistol ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
TYPEINFO(/obj/item/gun/energy/hafpistol)
	mats = null
/obj/item/gun/energy/hafpistol
	name = "Mod.21 Deneb"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/self_charging/hafpistol
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
	icon_state = "laser"
	desc = "A popular self defense handgun favored by security and adventuring spacefarers alike! Features a lethal and less than lethal mode."
	item_state = "hafpistol"
	force = 5
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_laser"
	charge_icon_state = "laser"

	New()
		set_current_projectile(new/datum/projectile/laser/hafplethal)
		projectiles = list(current_projectile,new/datum/projectile/laser/hafpless)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/laser/hafplethal)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "laser"
			muzzle_flash = "muzzle_flash_laser"
			item_state = "hafpistol"
		else if (current_projectile.type == /datum/projectile/laser/hafpless)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "laserless"
			muzzle_flash = "muzzle_flash_bluezap"
			item_state = "hafpistoless"
		..()

	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Laser Revolver ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
TYPEINFO(/obj/item/gun/energy/peacebringer)
	mats = null
/obj/item/gun/energy/peacebringer
	name = "The Aberrant"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/self_charging/peacebringer
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
	icon_state = "peacebringer"
	desc = "A scary albeit it, silly, energy revolver custom made for the Morrigan head of security."
	item_state = "peacebringer"
	force = 10
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_laser"
	charge_icon_state = "peacebringer"

	New()
		set_current_projectile(new/datum/projectile/bullet/optio/peacebringer)
		projectiles = list(current_projectile,new/datum/projectile/bullet/optio/peacebringerlesslethal)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/bullet/optio/peacebringer)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "peacebringer"
			muzzle_flash = "muzzle_flash_laser"
			item_state = "peacebringer"
		else if (current_projectile.type == /datum/projectile/bullet/optio/peacebringerlesslethal)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "peaceless"
			muzzle_flash = "muzzle_flash_waveg"
			item_state = "peacebringerless"
		..()

	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Hybrid SMG ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
TYPEINFO(/obj/item/gun/energy/smgmine)
	mats = null
/obj/item/gun/energy/smgmine
	name = "HMT Lycon"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
	icon_state = "minesmg"
	desc = "A tool issued to miners thoughout space, deemed extremely reliable for both punching through rock and punching through hostile fauna."
	item_state = "smgmine"
	force = 5
	can_swap_cell = TRUE
	rechargeable = TRUE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_laser"
	charge_icon_state = "minesmgfire"
	spread_angle = 4

	New()
		set_current_projectile(new/datum/projectile/laser/mining/smgmine)
		projectiles = list(current_projectile,new/datum/projectile/laser/smgminelethal)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/laser/mining/smgmine)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "minesmgfire"
			muzzle_flash = "muzzle_flash_elec"
			item_state = "smgmining"
		else if (current_projectile.type == /datum/projectile/laser/smgminelethal)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "minesmg"
			muzzle_flash = "muzzle_flash_wavep"
			item_state = "smgmine"
			spread_angle = 10
		..()
	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Energy Shotgun ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
TYPEINFO(/obj/item/gun/energy/lasershotgun)
	mats = null
/obj/item/gun/energy/lasershotgun
	name = "Mod. 77 Nosaxa"
	uses_multiple_icon_states = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/lasershotgun
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun48.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "lasershotgun"
	desc = "A burst shotgun with short range. Sold for heavy crowd control and shock tactics."
	item_state = "lasershotgun"
	c_flags = ONBACK | ONBELT
	force = 10
	two_handed = TRUE
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_red"
	charge_icon_state = "lasershotgun"
	var/racked_slide = FALSE
	var/shotcount = 0

	New()
		set_current_projectile(new/datum/projectile/special/spreader/tasershotgunspread/morriganshotgun)
		projectiles = list(new/datum/projectile/special/spreader/tasershotgunspread/morriganshotgun)
		..()

	canshoot(mob/user)
		return(..() && src.racked_slide)

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (!shoot_check(user))
			return
		..()
		if (src.shotcount++ >= 1)
			src.racked_slide = FALSE

	shoot_point_blank(atom/target, mob/user, second_shot)
		if (!shoot_check(user))
			return
		..()
		if (src.shotcount++ >= 2)
			src.racked_slide = FALSE

	equipped(var/mob/user, var/slot)
		if (slot == SLOT_BELT)
			wear_image_icon = 'icons/mob/clothing/belt.dmi'
			wear_layer = MOB_BACK_SUIT_LAYER
		else if (slot == SLOT_BACK)
			wear_image_icon = 'icons/mob/clothing/back.dmi'
			wear_layer = MOB_BACK_LAYER
		..()

	proc/shoot_check(var/mob/user)
		if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, amount) & CELL_INSUFFICIENT_CHARGE)
			boutput(user, "<span class ='notice'>You are out of energy!</span>")
			return FALSE

		if (!src.racked_slide)
			boutput(user, "<span class='notice'>You need to vent before you can fire!</span>")
			return FALSE

		if (GET_COOLDOWN(src, "rack delay"))
			boutput(user, "<span class ='notice'>Still cooling!</span>")
			return FALSE
		return TRUE

	attack_self(mob/user as mob)
		..()
		src.rack(user)

	proc/rack(var/mob/user)
		if (!src.racked_slide)
			if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, amount) & CELL_INSUFFICIENT_CHARGE)
				boutput(user, "<span class ='notice'>You are out of energy!</span>")

			else
				src.racked_slide = TRUE
				src.shotcount = 0
				boutput(user, "<span class='notice'>You release some heat from the shotgun!</span>")
				playsound(src, 'sound/ambience/morrigan/steamrelease.ogg', 70, 1)
				ON_COOLDOWN(src, "rack delay", 1 SECONDS)

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Barrier ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/itemspecialeffect/barrier/morrigan
		name = "energy barrier"
		icon = 'icons/effects/effects.dmi'
		icon_state = "morriganbarrier"
/obj/item/barrier/morrigan
	item_state = "morriganbarrier0"
	icon_state = "morriganbarrier_0"

	update_icon()
		icon_state = status ? "morriganbarrier_1" : "morriganbarrier_0"
		item_state = status ? "morriganbarrier1" : "morriganbarrier0"

	toggle(mob/user, new_state = null)
		if(!user && ismob(src.loc))
			user = src.loc

		if(isnull(new_state))
			new_state = !status

		if (!use_two_handed || setTwoHanded(!src.status))
			playsound(src, "sparks", 75, 1, -1)
			src.status = new_state
			if (new_state)
				w_class = W_CLASS_BULKY
				c_flags &= ~ONBELT //haha NO
				setProperty("meleeprot_all", 9)
				setProperty("rangedprot", 1.5)
				setProperty("movespeed", 0.3)
				setProperty("disorient_resist", 65)
				setProperty("disorient_resist_eye", 65)
				setProperty("disorient_resist_ear", 50) //idk how lol ok
				stamina_damage = stamina_damage_active
				stamina_cost = stamina_cost_active
				setProperty("deflection", 20)
				flick("morriganbarrier_a",src)
				c_flags |= BLOCK_TOOLTIP
				src.setItemSpecial(/datum/item_special/barrier/morrigan)
			else
				w_class = W_CLASS_SMALL
				c_flags |= ONBELT
				delProperty("meleeprot_all", 0)
				delProperty("rangedprot", 0)
				delProperty("movespeed", 0)
				delProperty("disorient_resist", 0)
				delProperty("disorient_resist_eye", 0)
				delProperty("disorient_resist_ear", 0)
				setProperty("deflection", 0)
				c_flags &= ~BLOCK_TOOLTIP
				stamina_damage = initial(stamina_damage)
				stamina_cost = initial(stamina_cost)
				src.setItemSpecial(/datum/item_special/simple)

			user?.update_equipped_modifiers()

			destroy_deployed_barrier(user)

			can_disarm = src.status

			src.UpdateIcon()
			user?.update_inhands()
		else
			user?.show_text("You need two free hands in order to activate the [src.name].", "red")

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Laser Rifle ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//rifle unused but there for completion reasons i'm sick please help - rex
TYPEINFO(/obj/item/gun/energy/laser_rifle)
	mats = null
/obj/item/gun/energy/laser_rifle
	name = "Mod. 201 Mimosa"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/self_charging/medium
	icon = 'icons/obj/adventurezones/morrigan/weapons/gunlarge.dmi'
	icon_state = "laser_rifle"
	desc = "The lastest product from Morrigan, a self charging rifle made for peace..or..war keeping with not stolen technology."
	item_state = "laser_rifle"
	force = 10
	two_handed = TRUE
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	charge_icon_state = "laser_rifle"
	spread_angle = 3

	New()
		set_current_projectile(new /datum/projectile/laser/rifle)
		projectiles = list(current_projectile, new /datum/projectile/laser/rifle/stun)
		..()

	update_icon()
		if (istype_exact(current_projectile, /datum/projectile/laser/rifle))
			charge_icon_state = "laser_rifle"
			muzzle_flash = "muzzle_flash_laser"
			item_state = "laser_rifle"
		else
			charge_icon_state = "laser_rifleless"
			muzzle_flash = "muzzle_flash_waveg"
			item_state = "laser_rifleless"
		..()

	attack_self(var/mob/M)
		..()
		src.UpdateIcon()
		M.update_inhands()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Hammer ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/item/tactical_hammer

	name = "tactical survival hammer"
	desc = "A tactical hammer used by the syndicate operatives for destroying obstacles and self-defense. Sure will hurt if you hit someone with it!"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "tactical_hammer"

	force = 17
	throwforce = 20
	stamina_cost = 25
	stamina_damage = 35
	click_delay = 15

	contraband = 5
	is_syndicate = TRUE
	hit_type = DAMAGE_BLUNT
	w_class = W_CLASS_NORMAL
	two_handed = FALSE
	c_flags = ONBELT
	flags = FPRINT | TABLEPASS | USEDELAY | NOSHIELD

	proc/set_properties()
		if (two_handed)
			force = 30
			stamina_cost = 30
			stamina_damage = 45
			click_delay = 20
		else
			force = initial(src.force)
			stamina_cost = initial(src.stamina_cost)
			stamina_damage = initial(src.stamina_damage)
			click_delay = initial(src.click_delay)

	attack_self(mob/user as mob)
		if(ishuman(user))
			if(two_handed)
				setTwoHanded(FALSE)
				set_properties()
			else
				if(!setTwoHanded(TRUE))
					boutput(user, "<span class='alert'>Can't switch to 2-handed while your other hand is full.</span>")
				else
					set_properties()
		..()

	attack(mob/M, mob/user)
		if (!isdead(M))
			if (src.two_handed)
				M.changeStatus("slowed", 5 SECONDS)
			else
				M.changeStatus("slowed", 2 SECONDS)
		. = ..()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Stun Baton ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
TYPEINFO(/obj/item/baton/windup/morrigan)
	mats = null
/obj/item/baton/windup/morrigan
	name = "Mod. 41 Izar"
	desc = "An experimental stun baton, designed to incapacitate targets consistently. It has safeties against users stunning themselves."
	icon = 'icons/obj/adventurezones/morrigan/weapons/weapon.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	cell_type = /obj/item/ammo/power_cell/self_charging/disruptor
	icon_state = "synd_baton"
	item_state = "synd_baton-off"
	icon_on = "synd_baton-A"
	icon_off = "synd_baton"
	item_on = "synd_baton-A"
	item_off = "synd_baton-D"
	force = 12
	throwforce = 7
	contraband = 4
	can_swap_cell = FALSE

	attack_self(var/mob/user)
		if (src.flipped)
			user.show_text("The internal safeties kick in stopping you from turning on the [src]", "red")
			return
		..()

	the_stun(var/mob/target)
		target.changeStatus("weakened", 5 SECONDS)
		src.delStatus("defib_charged")
		src.is_active = FALSE
		src.UpdateIcon()
		target.update_inhands()

	intent_switch_trigger(var/mob/user)
		if (src.is_active)
			src.is_active = FALSE
			src.UpdateIcon()
			user?.update_inhands()
			user?.show_text("The internal safeties kick in turning off the [src]!", "red")
		..()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Medic SMG ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/item/gun/kinetic/medsmg
	name = "Mod. 101 'Cardea'"
	desc = "A kinetic weapon made by Mabinogi, but produced aboard Morrigan. It has two modes, a healing mode for comrades and a poison mode."
	uses_multiple_icon_states = 1
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun48.dmi'
	icon_state = "medsmgdmg"
	item_state = "medsmg"
	max_ammo_capacity = 21
	has_empty_state = TRUE
	can_dual_wield = FALSE
	contraband = 6
	default_magazine = /obj/item/ammo/bullets/morriganmed

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/syringefilled/morrigan/medsmg)
		projectiles = list(current_projectile, new /datum/projectile/syringefilled/morrigan/medsmgheal)
		spread_angle = 3
		..()
	update_icon()
		if (istype_exact(current_projectile, /datum/projectile/syringefilled/morrigan/medsmgheal))
			set_current_projectile(new/datum/projectile/syringefilled/morrigan/medsmgheal)
			icon_state = "medsmgheal"
		else
			set_current_projectile(new/datum/projectile/syringefilled/morrigan/medsmg)
			icon_state = "medsmgdmg"
		..()

	attack_self(var/mob/M)
		..()
		src.UpdateIcon()
		M.update_inhands()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Bullets ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/item/ammo/bullets/morriganmed
	sname = "9mm Poison Darts"
	name = "9mm Poison Darts"
	desc = "A magazine of 21 poison darts,for giving up on the oath."
	icon_state = "medsmg_magazine"
	amount_left = 21
	max_amount = 21
	icon_dynamic = 0
	ammo_cat = AMMO_TRANQ_9MM
	ammo_type = new/datum/projectile/syringefilled/morrigan/medsmg

/obj/item/ammo/bullets/morriganmedheal
	sname = "9mm Heal Darts"
	name = "9mm Heal Darts"
	desc = "A magazine of 21 heal darts,for upholding the oath."
	icon_state = "medsmgheal_magazine"
	amount_left = 21
	max_amount = 21
	icon_dynamic = 1
	icon_empty = "medsmgheal_magazine-0"
	ammo_cat = AMMO_TRANQ_9MM
	ammo_type = new/datum/projectile/syringefilled/morrigan/medsmgheal



//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Projectiles ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/datum/projectile/bullet/optio/hitscanrail
	name = "hardlight beam"
	sname = "electro magnetic shot"
	damage = 61
	cost = 900
	max_range = PROJ_INFINITE_RANGE
	shot_sound = 'sound/weapons/railgunfire.ogg'
	dissipation_rate = 0
	projectile_speed = 2400
	armor_ignored = 0.33
	window_pass = FALSE


	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/Sx = P.orig_turf.x*32 + P.orig_turf.pixel_x
		var/Sy = P.orig_turf.y*32 + P.orig_turf.pixel_y

		var/Hx = hit.x*32 + hit.pixel_x
		var/Hy = hit.y*32 + hit.pixel_y

		var/dist = sqrt((Hx-Sx)**2 + (Hy-Sy)**2)

		var/Px = Sx + sin(P.angle) * dist
		var/Py = Sy + cos(P.angle) * dist

		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrail",1,0,"HalfStartTrail","HalfEndTrail",OBJ_LAYER, 0, Sx, Sy, Px, Py)
		for(var/obj/O in affected)
			O.color = list(-0.8, 0, 0, 0, -0.8, 0, 0, 0, -0.8, 1.5, 1.5, 1.5)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)

/datum/projectile/laser/hafpless
	name = "Mod. 21 less lethal"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "hafpistol_less"
	shot_sound = 'sound/weapons/hafpless.ogg'
	cost = 35
	damage = 10

	sname = "less-lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30
	brightness = 1
	color_red = 1
	color_green = 1
	color_blue = 0

	disruption = 2

	on_hit(atom/hit, angle, obj/projectile/O)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(stamina_damage = 0, weakened = 0 SECOND, stunned = 0 SECOND, disorient = 2 SECONDS, remove_stamina_below_zero = 0)

/datum/projectile/laser/hafplethal
	name = "Mod. 21 lethal"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "signifer2_burn"
	shot_sound = 'sound/weapons/hafplethal.ogg'
	cost = 35
	damage = 22

	sname = "lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30
	color_red = 0.1
	color_green = 0.1
	color_blue = 0.8

/datum/projectile/bullet/optio/peacebringer
	name = "Peacekeeper"
	icon = 'icons/obj/projectiles.dmi'
	shot_sound = 'sound/weapons/peacebringer.ogg'
	cost = 7
	damage = 30
	sname = "lethal"
	damage_type = D_ENERGY
	hit_type = DAMAGE_BURN
	hit_ground_chance = 30
	impact_image_state = "burn1"
	color_red = 0.8
	color_green = 0.1
	color_blue = 0.2
	projectile_speed = 1500
	max_range = PROJ_INFINITE_RANGE
	dissipation_rate = 0
	armor_ignored = 0.2
	window_pass = FALSE


	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/Sx = P.orig_turf.x*32 + P.orig_turf.pixel_x
		var/Sy = P.orig_turf.y*32 + P.orig_turf.pixel_y

		var/Hx = hit.x*32 + hit.pixel_x
		var/Hy = hit.y*32 + hit.pixel_y

		var/dist = sqrt((Hx-Sx)**2 + (Hy-Sy)**2)

		var/Px = Sx + sin(P.angle) * dist
		var/Py = Sy + cos(P.angle) * dist

		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrailRed",1,0,"HalfStartTrailRed","HalfEndTrailRed",OBJ_LAYER, 0, Sx, Sy, Px, Py)
		for(var/obj/O in affected)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)

/datum/projectile/bullet/optio/peacebringerlesslethal
	name = "Peacekeeper"
	icon = 'icons/obj/projectiles.dmi'
	shot_sound = 'sound/weapons/peacebringerlesslethal.ogg'
	cost = 7
	damage = 5

	sname = "less-lethal"
	damage_type = D_ENERGY
	hit_type = DAMAGE_BURN
	hit_ground_chance = 30
	impact_image_state = "burn1"
	color_red = 0.1
	color_green = 0.8
	color_blue = 0.2
	projectile_speed = 1000
	max_range = PROJ_INFINITE_RANGE
	dissipation_rate = 0
	armor_ignored = 0
	window_pass = FALSE
	color_red = 0.1
	color_green = 1
	color_blue = 0.3

	disruption = 2

	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/Sx = P.orig_turf.x*32 + P.orig_turf.pixel_x
		var/Sy = P.orig_turf.y*32 + P.orig_turf.pixel_y

		var/Hx = hit.x*32 + hit.pixel_x
		var/Hy = hit.y*32 + hit.pixel_y

		var/dist = sqrt((Hx-Sx)**2 + (Hy-Sy)**2)

		var/Px = Sx + sin(P.angle) * dist
		var/Py = Sy + cos(P.angle) * dist

		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrailGreen",1,0,"HalfStartTrailGreen","HalfEndTrailGreen",OBJ_LAYER, 0, Sx, Sy, Px, Py)
		for(var/obj/O in affected)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)
		if(isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(stamina_damage = 35, weakened = 0 SECONDS, stunned = 0 SECONDS, disorient = 7 SECONDS, remove_stamina_below_zero = 0)

/datum/projectile/laser/mining/smgmine
	name = "AC Shot"
	icon_state = "crescentmine"
	damage = 5
	cost = 20
	dissipation_delay = 3
	dissipation_rate = 8
	sname = "mining laser"
	shot_sound = 'sound/weapons/smgmine.ogg'
	damage_type = D_BURNING
	brightness = 0.8
	window_pass = 0
	color_red = 0.9
	color_green = 0.6
	color_blue = 0

	on_launch(obj/projectile/O)
		. = ..()
		O.AddComponent(/datum/component/proj_mining, 0.2, 2)

/datum/projectile/special/spreader/tasershotgunspread/morriganshotgun
	name = "laser"
	sname = "shotgun spread"
	cost = 50
	damage = 20
	damage_type = D_ENERGY
	pellets_to_fire = 3
	spread_projectile_type = /datum/projectile/laser/lasershotgun
	split_type = 0
	shot_sound = 'sound/weapons/shotgunlaser.ogg'

/datum/projectile/laser/lasershotgun
	name = "Lethal Mode"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "redbolt"
	shot_sound = 'sound/weapons/shotgunlaser.ogg'
	cost = 50
	damage = 15
	shot_number = 1
	sname = "lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if(!ismob(hit))
			shot_volume = 0
			shoot_reflected_bounce(proj, hit, 2, PROJ_NO_HEADON_BOUNCE)
			shot_volume = 100
		if(proj.reflectcount >= 2)
			elecflash(get_turf(hit),radius=0, power=1, exclude_center = 0)

/datum/projectile/laser/rifle
	name = "Lethal Mode"
	icon_state = "redbolt"
	shot_sound = 'sound/weapons/laserifle.ogg'
	cost = 45
	damage = 19
	shot_number = 2
	sname = "lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30

/datum/projectile/laser/rifle/stun
	name = "Less-Lethal Mode"
	icon_state = "laserifleless"
	shot_sound = 'sound/weapons/laser_a.ogg'
	cost = 35
	pierces = -1
	damage = 7
	shot_number = 1
	sname = "less-lethal"

	on_hit(atom/hit, angle, obj/projectile/O)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(stamina_damage = 35, weakened = 0 SECOND, stunned = 0 SECOND, disorient = 5 SECONDS, remove_stamina_below_zero = 0)

/datum/projectile/shieldpush
	name = "AP Repulsion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "crescent_white"
	shot_sound = 'sound/weapons/pushrobo.ogg'
	damage = 10

	on_hit(atom/hit, angle, var/obj/projectile/O)
		var/dir = get_dir(O.shooter, hit)
		var/pow = O.power
		if (isliving(hit))
			O.die()
			var/mob/living/mob = hit
			mob.do_disorient(stamina_damage = 20, weakened = 0, stunned = 0, disorient = pow, remove_stamina_below_zero = 0)
			var/throw_type = mob.can_lie ? THROW_GUNIMPACT : THROW_NORMAL
			mob.throw_at(get_edge_target_turf(hit, dir),(pow-7)/2,1, throw_type = throw_type)
			mob.emote("twitch_v")

/datum/projectile/laser/smgminelethal
	name = "Lethal Mode"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "signifer2_burn"
	shot_sound = 'sound/weapons/hafplethal.ogg'
	cost = 35
	damage = 6
	shot_number = 3

	sname = "lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30
	color_red = 0.1
	color_green = 0.1
	color_blue = 0.8

/datum/projectile/syringefilled/morrigan/medsmg
	shot_sound = 'sound/weapons/medsmg.ogg'
	venom_id = list("haloperidol", "cyanide")
	damage = 5
	shot_number = 3
	cost = 3
	casing = /obj/item/casing/small
	implanted = /obj/item/implant/projectile/body_visible/dart/tranq_dart_sleepy_barbed

/datum/projectile/syringefilled/morrigan/medsmgheal
	shot_sound = 'sound/weapons/medsmg.ogg'
	venom_id = list("salicylic_acid", "saline")
	inject_amount = 7.5
	damage = 0
	cost = 3
	casing = /obj/item/casing/small
	implanted = /obj/item/implant/projectile/body_visible/dart/tranq_dart_sleepy_barbed
