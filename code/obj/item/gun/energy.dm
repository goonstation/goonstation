TYPEINFO(/obj/item/gun/energy)
	mats = 32

/obj/item/gun/energy
	name = "energy weapon"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "gun"
	m_amt = 2000
	g_amt = 1000
	add_residue = 0 // Does this gun add gunshot residue when fired? Energy guns shouldn't.
	var/rechargeable = 1 // Can we put this gun in a recharger? False should be a very rare exception.
	var/robocharge = 800
	var/cell_type = /obj/item/ammo/power_cell // Type of cell to spawn by default.
	var/from_frame_cell_type = /obj/item/ammo/power_cell
	var/custom_cell_max_capacity = null // Is there a limit as to what power cell (in PU) we can use?
	var/wait_cycle = 0 // Using a self-charging cell should auto-update the gun's sprite.
	var/can_swap_cell = 1
	muzzle_flash = null
	inventory_counter_enabled = 1

	New()
		var/cell = null
		if(cell_type)
			cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, rechargeable, custom_cell_max_capacity, can_swap_cell)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		..()
		UpdateIcon()

	disposing()
		processing_items -= src
		..()

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		if(src.can_swap_cell && from_frame_cell_type)
			AddComponent(/datum/component/cell_holder, new from_frame_cell_type)

		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY) //also drain the cell out of spite

	examine()
		. = ..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "[src.projectiles ? "It is set to [src.current_projectile.sname]. " : ""]There are [ret["charge"]]/[ret["max_charge"]] PUs left!"
		else
			. += "There is no cell loaded!"
		if(current_projectile)
			. += "Each shot will currently use [src.current_projectile.cost] PUs!"
		else
			. += "<span class='alert'>*ERROR* No output selected!</span>"

	update_icon()

		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
		else
			inventory_counter.update_text("-")
		return 0

	emp_act()
		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
		src.visible_message("[src] sparks briefly as it overloads!")
		playsound(src, "sparks", 75, 1, -1)
		src.UpdateIcon()
		return

/*
	process()
		src.wait_cycle = !src.wait_cycle // Self-charging cells recharge every other tick (Convair880).
		if (src.wait_cycle)
			return

		if (!(src in processing_items))
			logTheThing(LOG_DEBUG, null, "<b>Convair880</b>: Process() was called for an egun ([src]) that wasn't in the item loop. Last touched by: [src.fingerprintslast]")
			processing_items.Add(src)
			return
		if (!src.cell)
			processing_items.Remove(src)
			return
		if (!istype(src.cell, /obj/item/ammo/power_cell/self_charging)) // Plain cell? No need for dynamic updates then (Convair880).
			processing_items.Remove(src)
			return
		if (src.cell.charge == src.cell.max_charge) // Keep them in the loop, as we might fire the gun later (Convair880).
			return

		src.UpdateIcon()
		return
*/

	canshoot(mob/user)
		if(src.current_projectile)
			if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, current_projectile.cost) & CELL_SUFFICIENT_CHARGE)
				return 1
		return 0

	process_ammo(var/mob/user)
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.cell)
				if(R.cell.charge >= src.robocharge)
					R.cell.charge -= src.robocharge
					return 1
			return 0
		else
			if(canshoot(user))
				SEND_SIGNAL(src, COMSIG_CELL_USE, src.current_projectile.cost)
				return 1
			boutput(user, "<span class='alert'>*click* *click*</span>")
			if (!src.silenced)
				playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
			return 0


/obj/item/gun/energy/heavyion
	name = "\improper Tianfei heavy ion blaster"
	icon = 'icons/obj/large/48x32.dmi'
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
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	New()
		set_current_projectile(new/datum/projectile/heavyion)
		projectiles = list(current_projectile)
		AddComponent(/datum/component/holdertargeting/windup, 1.5 SECONDS)
		..()

	pixelaction(atom/target, params, mob/user, reach)
		if(..(target, params, user, reach))
			playsound(user, 'sound/weapons/heavyioncharge.ogg', 90)

////////////////////////////////////TASERGUN
/obj/item/gun/energy/taser_gun
	name = "taser gun"
	icon_state = "taser"
	item_state = "taser"
	uses_multiple_icon_states = 1
	force = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	desc = "The Five Points Armory Taser Mk.I, a weapon that produces a cohesive electrical charge to stun and subdue its target."
	muzzle_flash = "muzzle_flash_elec"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt)
		projectiles = list(current_projectile)
		..()

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "taser[ratio]"
		..()

	borg
		cell_type = /obj/item/ammo/power_cell/self_charging/disruptor

/obj/item/gun/energy/taser_gun/bouncy
	name = "richochet taser gun"
	desc = "A modified Five Points Armory taser gun. This one appears to be capable of firing ricochet stun charges."

	New()
		..()
		set_current_projectile(new/datum/projectile/energy_bolt/bouncy)
		projectiles = list(current_projectile)

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt/bouncy)
				src.icon_state = "taser[ratio]"
		..()

/////////////////////////////////////LASERGUN
/obj/item/gun/energy/laser_gun
	name = "laser gun"
	icon_state = "laser"
	item_state = "laser"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_plus_power
	force = 7
	desc = "The venerable Hafgan Mod.28 laser gun, causes substantial damage in close quarters and space environments. Not suitable for use in dust storms."
	muzzle_flash = "muzzle_flash_laser"

	New()
		set_current_projectile(new/datum/projectile/laser)
		projectiles = list(current_projectile)
		..()

	virtual
		icon = 'icons/effects/VR.dmi'
		New()
			..()
			set_current_projectile(new /datum/projectile/laser/virtual)
			projectiles.len = 0
			projectiles += current_projectile

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "laser[ratio]"
			return
		..()

////////////////////////////////////// Antique laser gun
// Part of a mini-quest thing (see displaycase.dm). Typically, the gun's properties (cell, projectile)
// won't be the default ones specified here, it's here to make it admin-spawnable (Convair880).
/obj/item/gun/energy/laser_gun/antique
	name = "antique laser gun"
	icon_state = "caplaser"
	uses_multiple_icon_states = 1
	desc = "It's a kit model of the Mod.00 'Lunaport Legend' laser gun from Super! Protector Friend. With realistic sound fx and exciting LED display! This one has been hazardously upgraded."
	muzzle_flash = "muzzle_flash_laser"
	cell_type = null

	New()
		if (!src.current_projectile)
			src.set_current_projectile(new /datum/projectile/laser/glitter)
		if (isnull(src.projectiles))
			src.projectiles = list(src.current_projectile)
		..()
		src.UpdateIcon()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "caplaser[ratio]"
			return

//////////////////////////////////////// Phaser
/obj/item/gun/energy/phaser_gun
	name = "RP-4 phaser gun"
	icon_state = "phaser-new"
	uses_multiple_icon_states = 1
	item_state = "phaser"
	force = 7
	desc = "An amplified carbon-arc weapon designed by Radnor Photonics. Popular among frontier adventurers and explorers."
	muzzle_flash = "muzzle_flash_phaser"
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/laser/light)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "phaser-new[ratio]"
			return

TYPEINFO(/obj/item/gun/energy/phaser_small)
	mats = 20

/obj/item/gun/energy/phaser_small
	name = "RP-3 micro phaser"
	icon_state = "phaser-tiny"
	uses_multiple_icon_states = 1
	item_state = "phaser"
	force = 4
	desc = "A diminutive carbon-arc sidearm produced by Radnor Photonics. It's not much, but it might just save your life."
	muzzle_flash = "muzzle_flash_phaser"
	cell_type = /obj/item/ammo/power_cell
	w_class = W_CLASS_SMALL

	New()
		set_current_projectile(new/datum/projectile/laser/light/tiny)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "phaser-tiny[ratio]"
			return

TYPEINFO(/obj/item/gun/energy/phaser_huge)
	mats = list("MET-1"=15, "MET-2"=10, "CON-2"=10, "POW-2"=15, "CRY-1"=10)

/obj/item/gun/energy/phaser_huge
	name = "RP-5 macro phaser"
	icon_state = "phaser-xl"
	uses_multiple_icon_states = 1
	item_state = "phaser_xl"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD | ONBACK
	desc = "The largest amplified carbon-arc weapon from Radnor Photonics. A big gun for big problems."
	muzzle_flash = "muzzle_flash_phaser"
	cell_type = /obj/item/ammo/power_cell/med_plus_power
	shoot_delay = 10
	can_dual_wield = FALSE
	force = MELEE_DMG_RIFLE
	two_handed = 1
	New()
		set_current_projectile(new/datum/projectile/laser/light/huge) // light/huge - whatev!!!! this should probably be refactored
		projectiles = list(current_projectile)
		AddComponent(/datum/component/holdertargeting/windup, 1 SECOND)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "[initial(src.icon_state)][ratio]"
			src.wear_state = "[initial(src.icon_state)]"
			return

///////////////////////////////////////Rad Crossbow
TYPEINFO(/obj/item/gun/energy/crossbow)
	mats = list("MET-1"=5, "CON-2"=5, "POW-2"=10)

/obj/item/gun/energy/crossbow
	name = "\improper Wenshen mini rad-poison-crossbow"
	desc = "The XIANG|GIESEL Wenshen (瘟神) crossbow favored by many of the Syndicate's stealth specialists, which does damage over time using a slow-acting radioactive poison. Utilizes a self-recharging atomic power cell from Giesel Radiofabrik."
	icon_state = "crossbow"
	uses_multiple_icon_states = 1
	w_class = W_CLASS_SMALL
	item_state = "crossbow"
	force = 4
	throw_speed = 3
	throw_range = 10
	rechargeable = 0 // Cannot be recharged manually.
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	silenced = 1 // No conspicuous text messages, please (Convair880).
	hide_attack = ATTACK_FULLY_HIDDEN
	custom_cell_max_capacity = 100 // Those self-charging ten-shot radbows were a bit overpowered (Convair880)
	muzzle_flash = null

	New()
		set_current_projectile(new/datum/projectile/rad_bolt)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			if(ret["charge"] >= 37) //this makes it only enter its "final" sprite when it's actually able to fire, if you change the amount of charge regen or max charge the bow has, make this number one charge increment before full charge
				set_icon_state("crossbow")
				return
			else
				var/ratio = min(1, ret["charge"] / ret["max_charge"])
				ratio = round(ratio, 0.25) * 100
				set_icon_state("crossbow[ratio]")
				return

////////////////////////////////////////EGun
TYPEINFO(/obj/item/gun/energy/egun)
	mats = list("MET-1"=15, "CON-1"=5, "POW-1"=5)

/obj/item/gun/energy/egun
	name = "energy gun"
	icon_state = "energy"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_plus_power
	desc = "The Five Points Armory Energy Gun. Double emitters with switchable fire modes, for stun bolts or lethal laser fire."
	item_state = "egun"
	force = 5
	var/nojobreward = 0 //used to stop people from scanning it and then getting both a lawbringer/sabre AND an egun.
	muzzle_flash = "muzzle_flash_elec"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt)
		projectiles = list(current_projectile,new/datum/projectile/laser)
		RegisterSignal(src, COMSIG_ATOM_ANALYZE, .proc/noreward)
		..()
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt)
				src.item_state = "egun"
				src.icon_state = "energystun[ratio]"
				muzzle_flash = "muzzle_flash_elec"
			else if (current_projectile.type == /datum/projectile/laser)
				src.item_state = "egun-kill"
				src.icon_state = "energykill[ratio]"
				muzzle_flash = "muzzle_flash_laser"
			else
				src.item_state = "egun"
				src.icon_state = "energy[ratio]"
				muzzle_flash = "muzzle_flash_elec"
	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

	proc/noreward()
		src.nojobreward = 1


TYPEINFO(/obj/item/gun/energy/egun_jr)
	mats = list("MET-1"=10, "CON-1"=5, "POW-1"=5)

/obj/item/gun/energy/egun_jr
	name = "energy gun junior"
	icon_state = "egun-jr"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_minus_power
	desc = "A smaller, disposable version of the Five Points Armory energy gun, with dual modes for stun and kill."
	item_state = "egun"
	force = 3
	muzzle_flash = "muzzle_flash_elec"
	can_swap_cell = FALSE
	rechargeable = FALSE
	spread_angle = 10

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/diffuse)
		projectiles = list(current_projectile,new/datum/projectile/laser/diffuse)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt/diffuse)
				src.item_state = "egun-jrstun"
				src.icon_state = "egun-jrstun[ratio]"
				muzzle_flash = "muzzle_flash_elec"
			else if (current_projectile.type == /datum/projectile/laser/diffuse)
				src.item_state = "egun-jrkill"
				src.icon_state = "egun-jrkill[ratio]"
				muzzle_flash = "muzzle_flash_laser"
			else
				src.item_state = "egun-jr"
				src.icon_state = "egun-jr[ratio]"
				muzzle_flash = "muzzle_flash_elec"

	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

//////////////////////// nanotrasen gun
//Azungar's Nanotrasen inspired Laser Assault Rifle for RP gimmicks
/obj/item/gun/energy/ntgun
	name = "laser assault rifle"
	icon_state = "ntneutral100"
	desc = "Rather futuristic assault rifle with two firing modes."
	item_state = "ntgun"
	force = 10
	contraband = 8
	two_handed = 1
	spread_angle = 6
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/ntburst)
		projectiles = list(current_projectile,new/datum/projectile/laser/ntburst)
		..()
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt/ntburst)
				src.icon_state = "ntstun[ratio]"
			else if (current_projectile.type == /datum/projectile/laser/ntburst)
				src.icon_state = "ntlethal[ratio]"
			else
				src.icon_state = "ntneutral[ratio]"
	attack_self()
		..()
		UpdateIcon()



//////////////////////// Taser Shotgun
//Azungar's Improved, more beefy weapon for security that can only be acquired via QM.
/obj/item/gun/energy/tasershotgun
	name = "taser shotgun"
	icon_state = "tasers100"
	desc = "The Five Points Armory Taser Mk.II, a shotgun-format weapon that produces a spreading electrical charge to stuns its targets."
	item_state = "tasers"
	cell_type = /obj/item/ammo/power_cell/med_power
	force = 12
	two_handed = 1
	can_dual_wield = 0
	shoot_delay = 6 DECI SECONDS
	muzzle_flash = "muzzle_flash_elec"

	New()
		set_current_projectile(new/datum/projectile/special/spreader/tasershotgunspread)
		projectiles = list(current_projectile,new/datum/projectile/energy_bolt/tasershotgunslug)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			set_icon_state("tasers[ratio]")
			return


////////////////////////////////////VUVUV
TYPEINFO(/obj/item/gun/energy/vuvuzela_gun)
	mats = list("MET-1"=5, "CON-2"=5, "POW-2"=10)

/obj/item/gun/energy/vuvuzela_gun
	name = "amplified vuvuzela"
	icon_state = "vuvuzela"
	uses_multiple_icon_states = 1
	item_state = "bike_horn"
	desc = "BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT, *fart*"
	cell_type = /obj/item/ammo/power_cell/med_power
	is_syndicate = 1

	New()
		set_current_projectile(new/datum/projectile/energy_bolt_v)
		projectiles = list(current_projectile)
		..()
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "vuvuzela[ratio]"

//////////////////////////////////////Crabgun
/obj/item/gun/energy/crabgun
	name = "a strange crab"
	desc = "Years of extreme genetic tinkering have finally led to the feared combination of crab and gun."
	icon = 'icons/obj/crabgun.dmi'
	icon_state = "crabgun"
	item_state = "crabgun-world"
	inhand_image_icon = 'icons/obj/crabgun.dmi'
	w_class = W_CLASS_BULKY
	force = 12
	throw_speed = 8
	throw_range = 12
	rechargeable = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	custom_cell_max_capacity = 100 //endless crab

	New()
		set_current_projectile(new/datum/projectile/claw)
		projectiles = list(current_projectile)
		..()

	attackby(obj/item/b, mob/user)
		if(istype(b, /obj/item/ammo/power_cell))
			boutput(user, "<span class='alert'>You attempt to swap the cell but \the [src] bites you instead.</span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1, -6)
			user.TakeDamage(user.zone_sel.selecting, 3, 0)
			take_bleeding_damage(user, user, 3, DAMAGE_CUT)
			return
		. = ..()




////////////////////////////////////Wave Gun
/obj/item/gun/energy/wavegun
	name = "\improper Sancai wave gun"
	icon = 'icons/obj/items/gun.dmi'
	desc = "The versatile XIANG|GIESEL model '三才' with three monlethal functions: inverse '炎帝', transverse '地皇' and reflective '天皇' ."
	icon_state = "wavegun100"
	item_state = "wave"
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_multiple_icon_states = 1
	m_amt = 4000
	force = 6
	muzzle_flash = "muzzle_flash_wavep"

	New()
		set_current_projectile(new/datum/projectile/wavegun)
		projectiles = list(current_projectile,new/datum/projectile/wavegun/transverse,new/datum/projectile/wavegun/bouncy)
		..()

	// Old phasers aren't around anymore, so the wave gun might as well use their better sprite (Convair880).
	// Flaborized has made a lovely new wavegun sprite! - Gannets
	// Flaborized has made even more wavegun sprites!
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/wavegun)
				src.icon_state = "wavegun[ratio]"
				item_state = "wave"
				muzzle_flash = "muzzle_flash_wavep"
			else if (current_projectile.type == /datum/projectile/wavegun/transverse)
				src.icon_state = "wavegun_green[ratio]"
				item_state = "wave-g"
				muzzle_flash = "muzzle_flash_waveg"
			else
				src.icon_state = "wavegun_emp[ratio]"
				item_state = "wave-emp"
				muzzle_flash = "muzzle_flash_waveb"

	attack_self(mob/user as mob)
		..()
		UpdateIcon()
		user.update_inhands()

////////////////////////////////////BFG
/obj/item/gun/energy/bfg
	name = "\improper BFG 9000"
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "bfg"
	m_amt = 4000
	force = 6
	desc = "I think it stands for Banned For Griefing?"
	cell_type = /obj/item/ammo/power_cell/high_power

	New()
		set_current_projectile(new/datum/projectile/bfg)
		projectiles = list(new/datum/projectile/bfg)
		..()

	update_icon()
		..()
		return

	shoot(var/target,var/start,var/mob/user)
		if (canshoot(user)) // No more attack messages for empty guns (Convair880).
			playsound(user, 'sound/weapons/DSBFG.ogg', 75)
			sleep(0.9 SECONDS)
		return ..(target, start, user)

/obj/item/gun/energy/bfg/vr
	icon = 'icons/effects/VR.dmi'

///////////////////////////////////////Telegun
TYPEINFO(/obj/item/gun/energy/teleport)
	mats = 0

/obj/item/gun/energy/teleport
	name = "teleport gun"
	desc = "A hacked together combination of a taser gun and a handheld teleportation unit."
	icon_state = "teleport"
	uses_multiple_icon_states = 1
	w_class = W_CLASS_NORMAL
	item_state = "gun"
	force = 10
	throw_speed = 2
	throw_range = 10
	cell_type = /obj/item/ammo/power_cell/med_power
	var/obj/item/our_target = null
	var/obj/machinery/computer/teleporter/our_teleporter = null // For checks before firing (Convair880).

	New()
		set_current_projectile(new /datum/projectile/tele_bolt)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "teleport[ratio]"
		else
			icon_state = "teleport"
	// I overhauled everything down there. Old implementation made the telegun unreliable and crap, to be frank (Convair880).
	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		var/list/L = list()
		L += "None (Cancel)" // So we'll always get a list, even if there's only one teleporter in total.

		for(var/obj/machinery/teleport/portal_generator/PG as anything in machine_registry[MACHINES_PORTALGENERATORS])
			if (!PG.linked_computer || !PG.linked_rings)
				continue
			var/turf/PG_loc = get_turf(PG)
			if (PG && isrestrictedz(PG_loc.z)) // Don't show teleporters in "somewhere", okay.
				continue

			var/obj/machinery/computer/teleporter/Control = PG.linked_computer
			if (Control)
				switch (Control.check_teleporter())
					if (0) // It's busted, Jim.
						continue
					if (1)
						var/index = "Tele at [get_area(Control)]: Locked in ([ismob(Control.locked.loc) ? "[Control.locked.loc.name]" : "[get_area(Control.locked)]"])"
						if (L[index])
							L[dedupe_index(L, index)] = Control
						else
							L[index] = Control
					if (2)
						var/index = "Tele at [get_area(Control)]: *NOPOWER*"
						if (L[index])
							L[dedupe_index(L, index)] = Control
						else
							L[index] = Control
					if (3)
						var/index = "Tele at [get_area(Control)]: Inactive"
						if (L[index])
							L[dedupe_index(L, index)] = Control
						else
							L[index] = Control
			else
				continue

		if (L.len < 2)
			user.show_text("Error: no working teleporters detected.", "red")
			return

		var/t1 = tgui_input_list(user, "Please select a teleporter to lock in on.", "Target Selection", L)
		if ((user.equipped() != src) || user.stat || user.restrained())
			return
		if (t1 == "None (Cancel)")
			return

		var/obj/machinery/computer/teleporter/Control2 = L[t1]
		if (Control2)
			src.our_teleporter = null
			src.our_target = null
			switch (Control2.check_teleporter())
				if (0)
					user.show_text("Error: selected teleporter is out of order.", "red")
					return
				if (1)
					src.our_target = Control2.locked
					if (!our_target)
						user.show_text("Error: selected teleporter is locked in to invalid coordinates.", "red")
						return
					else
						user.show_text("Teleporter selected. Locked in on [ismob(Control2.locked.loc) ? "[Control2.locked.loc.name]" : "beacon"] in [get_area(Control2.locked)].", "blue")
						src.our_teleporter = Control2
						return
				if (2)
					user.show_text("Error: selected teleporter is unpowered.", "red")
					return
				if (3)
					user.show_text("Error: selected teleporter is not locked in.", "red")
					return
		else
			user.show_text("Error: couldn't establish connection to selected teleporter.", "red")
			return

	attack(mob/M, mob/user)
		if (!src.our_target)
			user.show_text("Error: no target set. Please select a teleporter first.", "red")
			return
		if (!src.our_teleporter || (src.our_teleporter.check_teleporter() != 1))
			user.show_text("Error: linked teleporter is out of order.", "red")
			return

		var/datum/projectile/tele_bolt/TB = current_projectile
		TB.target = our_target
		return ..(M, user)

	shoot(var/target, var/start, var/mob/user)
		if (!src.our_target)
			user.show_text("Error: no target set. Please select a teleporter first.", "red")
			return
		if (!src.our_teleporter || (src.our_teleporter.check_teleporter() != 1))
			user.show_text("Error: linked teleporter is out of order.", "red")
			return

		var/datum/projectile/tele_bolt/TB = current_projectile
		TB.target = our_target
		return ..(target, start, user)

	proc/dedupe_index(list/L, index)
		var/index_base = index
		var/i = 2
		while(L[index])
			index = index_base
			index += " [i]"
			i++
		return index

///////////////////////////////////////Ghost Gun
TYPEINFO(/obj/item/gun/energy/ghost)
	mats = 0

/obj/item/gun/energy/ghost
	name = "ectoplasmic destabilizer"
	desc = "If this had streams, it would be inadvisable to cross them. But no, it fires bolts instead.  Don't throw it into a stream, I guess?"
	icon_state = "ghost"
	w_class = W_CLASS_NORMAL
	item_state = "gun"
	force = 10
	throw_speed = 2
	throw_range = 10
	cell_type = /obj/item/ammo/power_cell/med_power
	muzzle_flash = "muzzle_flash_waveg"

	New()
		set_current_projectile(new /datum/projectile/energy_bolt_antighost)
		projectiles = list(current_projectile)
		..()

///////////////////////////////////////Modular Blasters
TYPEINFO(/obj/item/gun/energy/blaster_pistol)
	mats = 0

/obj/item/gun/energy/blaster_pistol
	name = "blaster pistol"
	desc = "A dangerous-looking blaster pistol. It's self-charging by a radioactive power cell."
	icon = 'icons/obj/items/gun_mod.dmi'
	icon_state = "pistol"
	w_class = W_CLASS_NORMAL
	force = 5
	cell_type = /obj/item/ammo/power_cell/self_charging/medium
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/disruptor


	/*
	var/obj/item/gun_parts/emitter/emitter = null
	var/obj/item/gun_parts/back/back = null
	var/obj/item/gun_parts/top_rail/top_rail = null
	var/obj/item/gun_parts/bottom_rail/bottom_rail = null
	var/heat = 0 // for overheating stuff

	New()
		if (!emitter)
			emitter = new /obj/item/gun_parts/emitter
		if(!current_projectile)
			set_current_projectile(src.emitter.projectile)
		projectiles = list(current_projectile)
		..() */



	//handle gun mods at a workbench


	New()
		set_current_projectile(new /datum/projectile/laser/blaster)
		projectiles = list(current_projectile)
		..()


	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "pistol[ratio]"
			return




	/*examine()
		set src in view()
		boutput(usr, "<span class='notice'>Installed components:</span><br>")
		if(emitter)
			boutput(usr, "<span class='notice'>[src.emitter.name]</span>")
		if(cell)
			boutput(usr, "<span class='notice'>[src.cell.name]</span>")
		if(back)
			boutput(usr, "<span class='notice'>[src.back.name]</span>")
		if(top_rail)
			boutput(usr, "<span class='notice'>[src.top_rail.name]</span>")
		if(bottom_rail)
			boutput(usr, "<span class='notice'>[src.bottom_rail.name]</span>")
		..()*/

	/*proc/generate_overlays()
		src.overlays = null
		if(extension_mod)
			src.overlays += icon('icons/obj/items/gun_mod.dmi',extension_mod.overlay_name)
		if(converter_mod)
			src.overlays += icon('icons/obj/items/gun_mod.dmi',converter_mod.overlay_name)*/

TYPEINFO(/obj/item/gun/energy/blaster_smg)
	mats = 0

/obj/item/gun/energy/blaster_smg
	name = "burst blaster"
	desc = "A special issue blaster weapon, configured for burst fire. It's self-charging by a radioactive power cell."
	icon = 'icons/obj/items/gun_mod.dmi'
	icon_state = "smg"
	can_dual_wield = 0
	w_class = W_CLASS_NORMAL
	force = 7
	cell_type = /obj/item/ammo/power_cell/self_charging/medium


	New()
		set_current_projectile(new /datum/projectile/laser/blaster/burst)
		projectiles = list(current_projectile)
		..()


	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "smg[ratio]"
			return

/obj/item/gun/energy/blaster_cannon
	name = "blaster cannon"
	desc = "A heavily overcharged blaster weapon, modified for extreme firepower. It's self-charging by a larger radioactive power cell."
	icon = 'icons/obj/items/gun_mod.dmi'
	icon_state = "cannon"
	item_state = "rifle"
	can_dual_wield = 0
	two_handed = 1
	w_class = W_CLASS_BULKY
	force = 15
	cell_type = /obj/item/ammo/power_cell/self_charging/big

	New()
		set_current_projectile(new /datum/projectile/special/spreader/uniform_burst/blaster)
		projectiles = list(current_projectile)
		c_flags |= ONBACK
		..()


	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "cannon[ratio]"
			return


///////////modular components - putting them here so it's easier to work on for now////////

TYPEINFO(/obj/item/gun_parts)
	mats = 0

/obj/item/gun_parts
	name = "gun parts"
	desc = "Components for building custom sidearms."
	item_state = "table_parts"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon = 'icons/obj/items/gun_mod.dmi'
	icon_state = "frame" // todo: make more item icons

/obj/item/gun_parts/emitter
	name = "optical pulse emitter"
	desc = "Generates a pulsed burst of energy."
	icon_state = "emitter"
	var/datum/projectile/laser/light/projectile = new/datum/projectile/laser/light
	var/obj/item/device/flash/flash = new/obj/item/device/flash
	//use flash as the core of the device

	// inherit material vars from the flash

/obj/item/gun_parts/back
	name = "phaser stock"
	desc = "A gun stock for a modular phaser. Does this even do anything? Probably not."
	icon_state = "mod-stock"

/obj/item/gun_parts/top_rail
	name = "phaser pulse modifier"
	desc = "Modifies the beam path of modular phaser."
	icon_state = "mod-range"

	range
		name = "beam collimator"
		icon_state = "mod-range"

	width
		name = "beam spreader"
		icon_state = "mod-aoe"

/obj/item/gun_parts/bottom_rail
	name = "Phaser accessory"

	sight
		name = "phaser dot accessory"
		icon_state = "mod-sight"
		// idk what the hell this would even do

	flashlight
		name = "phaser flashlight accessory"
		icon_state = "mod-flashlight"

	heatsink
		name = "phaser heatsink"
		icon_state = "mod-heatsink"

	grip // tacticool
		name = "fore grip"
		icon_state = "mod-grip"

///////////////////////////////////////Owl Gun
/obj/item/gun/energy/owl
	name = "owl gun"
	desc = "Its a gun that has two modes, Owl and Owler"
	item_state = "gun"
	force = 5
	icon_state = "ghost"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/owl)
		projectiles = list(current_projectile,new/datum/projectile/owl/owlate)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ghost[ratio]"

/obj/item/gun/energy/owl_safe
	name = "owl gun"
	desc = "Hoot!"
	item_state = "gun"
	force = 5
	icon_state = "ghost"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/owl)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ghost[ratio]"

///////////////////////////////////////Frog Gun (Shoots :getin: and :getout:)
/obj/item/gun/energy/frog
	name = "frog gun"
	item_state = "gun"
	m_amt = 1000
	force = 0
	icon_state = "frog"
	cell_type = /obj/item/ammo/power_cell/self_charging/big //gotta have power for the frog
	desc = "It appears to be shivering and croaking in your hand. How creepy." //it must be unhoppy :^)

	New()
		set_current_projectile(new/datum/projectile/bullet/frog)
		projectiles = list(current_projectile,new/datum/projectile/bullet/frog/getout)
		..()


///////////////////////////////////////Shrink Ray
/obj/item/gun/energy/shrinkray
	name = "shrink ray"
	item_state = "gun"
	force = 5
	icon_state = "ghost"
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_multiple_icon_states = 1

	New()
		set_current_projectile(new/datum/projectile/shrink_beam)
		projectiles = list(current_projectile)
		..()
	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ghost[ratio]"

/obj/item/gun/energy/shrinkray/growray
	name = "grow ray"
	New()
		..()
		set_current_projectile(new/datum/projectile/shrink_beam/grow)
		projectiles = list(current_projectile)

// stinky ray
/obj/item/gun/energy/stinkray
	name = "stink ray"
	item_state = "gun"
	force = 5
	icon_state = "ghost"
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_multiple_icon_states = 1

	New()
		set_current_projectile(new/datum/projectile/bioeffect_beam/stinky)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ghost[ratio]"

///////////////////////////////////////Glitch Gun
/obj/item/gun/energy/glitch_gun
	name = "glitch gun"
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "airzooka"
	m_amt = 4000
	force = 0
	cell_type = /obj/item/ammo/power_cell/high_power
	desc = "It's humming with some sort of disturbing energy. Do you really wanna hold this?"

	New()
		set_current_projectile(new/datum/projectile/bullet/glitch/gun)
		projectiles = list(new/datum/projectile/bullet/glitch/gun)
		..()

	shoot(var/target,var/start,var/mob/user,var/POX,var/POY)
		if (canshoot(user)) // No more attack messages for empty guns (Convair880).
			playsound(user, 'sound/weapons/DSBFG.ogg', 75)
			sleep(0.1 SECONDS)
		return ..(target, start, user)

///////////////////////////////////////Hunter
TYPEINFO(/obj/item/gun/energy/plasma_gun)
	mats = list("MET-3"=7, "CRY-1"=13, "POW-2"=10)

/obj/item/gun/energy/plasma_gun/ // Made use of a spare sprite here (Convair880).
	name = "plasma rifle"
	desc = "This advanced bullpup rifle contains a self-recharging power cell."
	icon_state = "bullpup"
	item_state = "bullpup"
	var/base_item_state = "bullpup"
	uses_multiple_icon_states = 1
	force = 5
	cell_type = /obj/item/ammo/power_cell/self_charging/mediumbig
	muzzle_flash = "muzzle_flash_plaser"

	New()
		set_current_projectile(new/datum/projectile/laser/plasma)
		projectiles = list(new/datum/projectile/laser/plasma)
		..()

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "[base_item_state][ratio]"
			return
		..()

/obj/item/gun/energy/plasma_gun/vr
	name = "advanced laser gun"
	icon = 'icons/effects/VR.dmi'
	icon_state = "wavegun"
	base_item_state = "wavegun"

	update_icon() // Necessary. Parent's got a different sprite now (Convair880).

		return

TYPEINFO(/obj/item/gun/energy/plasma_gun/hunter)
	mats = null

/obj/item/gun/energy/plasma_gun/hunter
	name = "Hunter's plasma rifle"
	desc = "This unusual looking rifle contains a self-recharging power cell."
	icon_state = "hunter"
	item_state = "hunter"
	base_item_state = "hunter"
	var/hunter_key = "" // The owner of this rifle.

	New()
		..()
		if(istype(src.loc, /mob/living))
			var/mob/M = src.loc
			src.AddComponent(/datum/component/self_destruct, M)
			src.AddComponent(/datum/component/send_to_target_mob, src)
			src.hunter_key = M.mind.key
			START_TRACKING_CAT(TR_CAT_HUNTER_GEAR)
			flick("[src.base_item_state]-tele", src)

	disposing()
		. = ..()
		if (hunter_key)
			STOP_TRACKING_CAT(TR_CAT_HUNTER_GEAR)

/////////////////////////////////////// Pickpocket Grapple, Grayshift's grif gun
TYPEINFO(/obj/item/gun/energy/pickpocket)
	mats = list("MET-1"=5, "CON-2"=5, "POW-2"=10)

/obj/item/gun/energy/pickpocket
	name = "pickpocket grapple gun" // absurdly shitty name
	desc = "A complicated, camoflaged claw device on a tether capable of complex and stealthy interactions. It steals shit."
	icon_state = "pickpocket"
	w_class = W_CLASS_SMALL
	item_state = "pickpocket"
	force = 4
	throw_speed = 3
	throw_range = 10
	rechargeable = 0 // Cannot be recharged manually.
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	silenced = 1
	hide_attack = ATTACK_FULLY_HIDDEN
	custom_cell_max_capacity = 100
	var/obj/item/heldItem = null
	tooltip_flags = REBUILD_DIST

	New()
		set_current_projectile(new/datum/projectile/pickpocket/steal)
		projectiles = list(current_projectile, new/datum/projectile/pickpocket/plant, new/datum/projectile/pickpocket/harass)
		..()

	get_desc(dist)
		..()
		if (dist < 1) // on our tile or our person
			if (.) // we're returning something
				. += " " // add a space
			if (src.heldItem)
				. += "It's currently holding \a [src.heldItem]."
			else
				. += "It's not holding anything."

	attack_hand(mob/user)
		if (src.loc == user && (src == user.l_hand || src == user.r_hand))
			if (heldItem)
				boutput(user, "You remove \the [heldItem.name] from the gun.")
				user.put_in_hand_or_drop(heldItem)
				heldItem = null
				tooltip_rebuild = 1
			else
				boutput(user, "The gun does not contain anything.")
		else
			return ..()

	attackby(obj/item/I, mob/user)
		if (I.cant_drop) return
		if (heldItem)
			boutput(user, "The gun is already holding [heldItem.name].")
		else
			heldItem = I
			user.u_equip(I)
			I.dropped(user)
			boutput(user, "You insert \the [heldItem.name] into the gun's gripper.")
			tooltip_rebuild = 1
		return ..()

	attack(mob/M, mob/user)
		if (istype(current_projectile, /datum/projectile/pickpocket/steal) && heldItem)
			boutput(user, "Cannot steal while gun is holding something!")
			return
		if (istype(current_projectile, /datum/projectile/pickpocket/plant) && !heldItem)
			boutput(user, "Cannot plant item if gun is not holding anything!")
			return

		var/datum/projectile/pickpocket/shot = current_projectile
		shot.linkedGun = src
		shot.firer = user.key
		shot.targetZone = user.zone_sel.selecting
		var/turf/us = get_turf(src)
		var/turf/tgt = get_turf(M)
		if(isrestrictedz(us.z) || isrestrictedz(tgt.z))
			boutput(user, "\The [src.name] jams!")
			return
		return ..(M, user)

	shoot(var/target, var/start, var/mob/user)
		if (istype(current_projectile, /datum/projectile/pickpocket/steal) && heldItem)
			boutput(user, "Cannot steal items while gun is holding something!")
			return
		if (istype(current_projectile, /datum/projectile/pickpocket/plant) && !heldItem)
			boutput(user, "Cannot plant item if gun is not holding anything!")
			return

		var/turf/us = get_turf(src)
		var/turf/tgt = get_turf(target)
		if(isrestrictedz(us.z) || isrestrictedz(tgt.z))
			boutput(user, "\The [src.name] jams!")
			message_admins("[key_name(user)] is a nerd and tried to fire a pickpocket gun in a restricted z-level at [log_loc(us)].")
			return


		var/datum/projectile/pickpocket/shot = current_projectile
		shot.linkedGun = src
		shot.targetZone = user.zone_sel.selecting
		shot.firer = user.key
		return ..(target, start, user)

/obj/item/gun/energy/pickpocket/testing // has a beefier cell in it
	cell_type = /obj/item/ammo/power_cell/self_charging/big

TYPEINFO(/obj/item/gun/energy/alastor)
	mats = list("MET-2"=15, "CON-2"=10, "POW-2"=10)

/obj/item/gun/energy/alastor
	name = "\improper Alastor pattern laser rifle"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "alastor100"
	item_state = "alastor"
	icon = 'icons/obj/large/38x38.dmi'
	uses_multiple_icon_states = 1
	force = 7
	can_dual_wield = 0
	two_handed = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	desc = "A gun that produces a harmful laser, causing substantial damage."
	muzzle_flash = "muzzle_flash_laser"
	is_syndicate = 1

	New()
		set_current_projectile(new/datum/projectile/laser/alastor)
		projectiles = list(current_projectile)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "alastor[ratio]"
			return

///////////////////////////////////////////////////
TYPEINFO(/obj/item/gun/energy/lawbringer)
	mats = list("MET-1"=15, "CON-2"=5, "POW-2"=5)

/obj/item/gun/energy/lawbringer
	name = "\improper Lawbringer"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "lawg-detain"
	icon_state = "lawbringer0"
	desc = "A gun with a microphone. Fascinating."
	var/old = 0
	m_amt = 5000
	g_amt = 2000
	cell_type = /obj/item/ammo/power_cell/self_charging/lawbringer
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/lawbringer/bad
	var/owner_prints = null
	var/image/indicator_display = null
	rechargeable = 0
	can_swap_cell = 0
	muzzle_flash = "muzzle_flash_elec"

	New(var/mob/M)
		set_current_projectile(new/datum/projectile/energy_bolt/aoe)
		projectiles = list("detain" = current_projectile, "execute" = new/datum/projectile/bullet/revolver_38/lb, "smokeshot" = new/datum/projectile/bullet/smoke, "knockout" = new/datum/projectile/bullet/tranq_dart/law_giver, "hotshot" = new/datum/projectile/bullet/flare, "bigshot" = new/datum/projectile/bullet/aex/lawbringer, "clownshot" = new/datum/projectile/bullet/clownshot, "pulse" = new/datum/projectile/energy_bolt/pulse)
		// projectiles = list(current_projectile,new/datum/projectile/bullet/revolver_38/lb,new/datum/projectile/bullet/smoke,new/datum/projectile/bullet/tranq_dart/law_giver,new/datum/projectile/bullet/flare,new/datum/projectile/bullet/aex/lawbringer,new/datum/projectile/bullet/clownshot)

		src.indicator_display = image('icons/obj/items/gun.dmi', "")
		assign_name(M)

		..()

	disposing()
		indicator_display = null
		..()

	attack_hand(mob/user)
		if (!owner_prints)
			boutput(user, "<span class='alert'>[src] has accepted your DNA string. You are its owner!</span>")
			assign_name(user)
		..()


	//if it has no owner prints scanned, the next person to attack_self it is the owner.
	//you have to use voice activation to change modes. haha!
	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if (!owner_prints)
			boutput(user, "<span class='alert'>[src] has accepted your DNA string. You are its owner!</span>")
			assign_name(user)
		else
			boutput(user, "<span class='notice'>There don't seem to be any buttons on [src] to press.</span>")

	proc/assign_name(var/mob/M)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.bioHolder)
				owner_prints = H.bioHolder.Uid
				src.name = "HoS [H.real_name]'s Lawbringer"
				tooltip_rebuild = 1

	//stolen the heartalk of microphone. the microphone can hear you from one tile away. unless you wanna
	hear_talk(mob/M as mob, msg, real_name, lang_id)
		var/turf/T = get_turf(src)
		if (M in range(1, T))
			src.talk_into(M, msg, real_name, lang_id)

	//can only handle one name at a time, if it's more it doesn't do anything
	talk_into(mob/M as mob, msg, real_name, lang_id)
		//Do I need to check for this? I can't imagine why anyone would pass the wrong var here...
		if (!islist(msg))
			return
		if (lang_id != "english")
			return
		//only work if the voice is the same as the voice of your owner fingerprints.
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (owner_prints && (H.bioHolder.Uid != owner_prints))
				are_you_the_law(M, msg[1])
				return
		else
			are_you_the_law(M, msg[1])
			return //AFAIK only humans have fingerprints/"palmprints(in judge dredd)" so just ignore any talk from non-humans arlight? it's not a big deal.

		if(!src.projectiles && !src.projectiles.len > 1)
			boutput(M, "<span class='notice'>Gun broke. Call 1-800-CODER.</span>")
			set_current_projectile(new/datum/projectile/energy_bolt/aoe)
			item_state = "lawg-detain"
			M.update_inhands()
			UpdateIcon()

		var/text = msg[1]
		text = sanitize_talk(text)
		if (fingerprints_can_shoot(M))
			switch(text)
				if ("detain")
					set_current_projectile(projectiles["detain"])
					item_state = "lawg-detain"
					playsound(M, 'sound/vox/detain.ogg', 50)
				if ("execute", "exterminate")
					set_current_projectile(projectiles["execute"])
					current_projectile.cost = 30
					item_state = "lawg-execute"
					playsound(M, 'sound/vox/exterminate.ogg', 50)
				if ("smokeshot","fog")
					set_current_projectile(projectiles["smokeshot"])
					current_projectile.cost = 50
					item_state = "lawg-smokeshot"
					playsound(M, 'sound/vox/smoke.ogg', 50)
				if ("knockout", "sleepshot")
					set_current_projectile(projectiles["knockout"])
					current_projectile.cost = 60
					item_state = "lawg-knockout"
					playsound(M, 'sound/vox/sleep.ogg', 50)
				if ("hotshot","incendiary")
					set_current_projectile(projectiles["hotshot"])
					current_projectile.cost = 60
					item_state = "lawg-hotshot"
					playsound(M, 'sound/vox/hot.ogg', 50)
				if ("bigshot","highexplosive","he")
					set_current_projectile(projectiles["bigshot"])
					current_projectile.cost = 170
					item_state = "lawg-bigshot"
					playsound(M, 'sound/vox/high.ogg', 50)
					SPAWN(0.4 SECONDS)
						playsound(M, 'sound/vox/explosive.ogg', 50)
				if ("clownshot","clown")
					set_current_projectile(projectiles["clownshot"])
					item_state = "lawg-clownshot"
					playsound(M, 'sound/vox/clown.ogg', 30)
				if ("pulse", "push", "throw")
					set_current_projectile(projectiles["pulse"])
					item_state = "lawg-pulse"
					playsound(M, 'sound/vox/push.ogg', 50)

					/datum/projectile/energy_bolt/pulse
		else		//if you're not the owner and try to change it, then fuck you
			switch(text)
				if ("detain","execute","knockout","hotshot","incendiary","bigshot","highexplosive","he","clownshot","clown", "pulse", "punch")
					random_burn_damage(M, 50)
					M.changeStatus("weakened", 4 SECONDS)
					elecflash(src,power=2)
					M.visible_message("<span class='alert'>[M] tries to fire [src]! The gun initiates its failsafe mode.</span>")
					return

		M.update_inhands()
		UpdateIcon()

	//Are you really the law? takes the mob as speaker, and the text spoken, sanitizes it. If you say "i am the law" and you in fact are NOT the law, it's gonna blow. Moved out of the switch statement because it that switch is only gonna run if the owner speaks
	proc/are_you_the_law(mob/M as mob, text)
		text = sanitize_talk(text)
		if (findtext(text, "iamthelaw"))
			//you must be holding/wearing the weapon
			//this check makes it so that someone can't stun you, stand on top of you and say "I am the law" to kill you
			if (src in M.contents)
				if (M.job != "Head of Security")
					src.cant_self_remove = 1
					playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
					logTheThing(LOG_COMBAT, src, "Is not the law. Caused explosion with Lawbringer.")

					SPAWN(2 SECONDS)
						src.blowthefuckup(15)
					return 0
				else
					return 1

	//all gun modes use the same base sprite icon "lawbringer0" depending on the current projectile/current mode, we apply a coloured overlay to it.
	update_icon()
		..()
		var/prefix = ""
		if(old)
			prefix = "old-"

		src.icon_state = "[prefix]lawbringer0"
		src.overlays = null

		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			//if we're showing zero charge, don't do any overlay, since the main image shows an empty gun anyway
			if (ratio == 0)
				return
			indicator_display.icon_state = "[prefix]lawbringer-d[ratio]"

			if(current_projectile.type == /datum/projectile/energy_bolt/aoe)			//detain - yellow
				indicator_display.color = "#FFFF00"
				muzzle_flash = "muzzle_flash_elec"
			else if (current_projectile.type == /datum/projectile/bullet/revolver_38/lb)			//execute - cyan
				indicator_display.color = "#00FFFF"
				muzzle_flash = "muzzle_flash"
			else if (current_projectile.type == /datum/projectile/bullet/smoke)			//smokeshot - dark-blue
				indicator_display.color = "#0000FF"
				muzzle_flash = "muzzle_flash"
			else if (current_projectile.type == /datum/projectile/bullet/tranq_dart/law_giver)	//knockout - green
				indicator_display.color = "#008000"
				muzzle_flash = null
			else if (current_projectile.type == /datum/projectile/bullet/flare)			//hotshot - red
				indicator_display.color = "#FF0000"
				muzzle_flash = null
			else if (current_projectile.type == /datum/projectile/bullet/aex/lawbringer)	//bigshot - purple
				indicator_display.color = "#551A8B"
				muzzle_flash = null
			else if (current_projectile.type == /datum/projectile/bullet/clownshot)		//clownshot - pink
				indicator_display.color = "#FFC0CB"
				muzzle_flash = null
			else if (current_projectile.type == /datum/projectile/energy_bolt/pulse)		//clownshot - pink
				indicator_display.color = "#EEEEFF"
				muzzle_flash = "muzzle_flash_bluezap"
			else
				indicator_display.color = "#000000"				//default, should never reach. make it black
			src.overlays += indicator_display

	//just remove all capitalization and non-letter characters
	proc/sanitize_talk(var/msg)
		//find all characters that are not letters and remove em
		var/regex/r = regex("\[^a-z\]+", "g")
		msg = lowertext(msg)
		msg = r.Replace(msg, "")
		return msg

	// Checks if the gun can shoot based on the fingerprints of the shooter.
	//returns true if the prints match or there are no prints stored on the gun(emagged). false if it fails
	proc/fingerprints_can_shoot(var/mob/user)
		if (!owner_prints || (user.bioHolder.Uid == owner_prints))
			return 1
		return 0

	shoot(var/target,var/start,var/mob/user)
		if (canshoot(user))
			//removing this for now so anyone can shoot it. I PROBABLY will want it back, doing this for some light appeasement to see how it goes.
			//shock the guy who tries to use this if they aren't the proper owner. (or if the gun is not emagged)
			// if (!fingerprints_can_shoot(user))
			// 	// shock(user, 70)
			// 	random_burn_damage(user, 50)
			// 	user.changeStatus("weakened", 4 SECONDS)
			// 	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			// 	s.set_up(2, 1, (get_turf(src)))
			// 	s.start()
			// 	user.visible_message("<span class='alert'>[user] tries to fire [src]! The gun initiates its failsafe mode.</span>")
			// 	return

			if (current_projectile.type == /datum/projectile/bullet/flare)
				shoot_fire_hotspots(target, start, user)
		return ..(target, start, user)

/obj/item/gun/energy/lawbringer/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (user)
		boutput(user, "<span class='alert'>Anyone can use this gun now. Be careful! (use it in-hand to register your fingerprints)</span>")
		owner_prints = null
		return TRUE

//stolen from firebreath in powers.dm
/obj/item/gun/energy/lawbringer/proc/shoot_fire_hotspots(var/target,var/start,var/mob/user)
	var/list/affected_turfs = getline(get_turf(start), get_turf(target))
	var/range = 6
	playsound(user.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
	var/turf/currentturf
	var/turf/previousturf
	for(var/turf/F in affected_turfs)
		previousturf = currentturf
		currentturf = F
		if(currentturf.density || istype(currentturf, /turf/space))
			break
		if(previousturf && LinkBlocked(previousturf, currentturf))
			break
		if (F == get_turf(user))
			continue
		if (GET_DIST(user,F) > range)
			continue
		tfireflash(F,0.5,2400)

// Pulse Rifle //
// An energy gun that uses the lawbringer's Pulse setting, to beef up the current armory.

/obj/item/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A sleek energy rifle with two different pulse settings: Kinetic and Electromagnetic."
	icon_state = "pulse_rifle"
	uses_multiple_icon_states = 1
	item_state = "pulse_rifle"
	force = 5
	two_handed = 1
	can_dual_wield = 0
	muzzle_flash = "muzzle_flash_bluezap"
	cell_type = /obj/item/ammo/power_cell/high_power //300 PU

	New()
		..()
		set_current_projectile(new/datum/projectile/energy_bolt/pulse)//uses 35PU per shot, so 8 shots
		projectiles = list(new/datum/projectile/energy_bolt/pulse, new/datum/projectile/energy_bolt/electromagnetic_pulse)

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "pulse_rifle[ratio]"
			return


///////////////////////////////////////Wasp Gun
TYPEINFO(/obj/item/gun/energy/wasp)
	mats = list("MET-1"=5, "CON-2"=5, "POW-2"=10)

/obj/item/gun/energy/wasp
	name = "mini wasp-egg-crossbow"
	desc = "A weapon favored by many of the syndicate's stealth apiarists, which does damage over time using swarms of angry wasps. Utilizes a self-recharging atomic power cell to synthesize more wasp eggs. Somehow."
	icon_state = "crossbow" //placeholder, would prefer a custom wasp themed icon
	w_class = W_CLASS_SMALL
	item_state = "crossbow" //ditto
	force = 4
	throw_speed = 3
	throw_range = 10
	rechargeable = 0 // Cannot be recharged manually.
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	silenced = 1
	custom_cell_max_capacity = 100

	New()
		set_current_projectile(new/datum/projectile/special/spreader/quadwasp)
		projectiles = list(current_projectile)
		..()

///Crossbow that fires irradiating neutron projectiles like the nuclear reactor
///DEBUG ITEM - don't actually use this for things. Unless you really want to, or it might be funny.
/obj/item/gun/energy/neutron
	name = "mini neutron-crossbow"
	desc = "A weapon that fires irradiating neutrons. Because it makes sense that a crossbow can fire subatomic particles at relativistic speeds."
	icon_state = "crossbow"
	w_class = W_CLASS_SMALL
	item_state = "crossbow"
	force = 4
	throw_speed = 3
	throw_range = 10
	rechargeable = 0 // Cannot be recharged manually.
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	is_syndicate = 1
	silenced = 1
	custom_cell_max_capacity = 100

	New()
		set_current_projectile(new/datum/projectile/neutron(50))
		projectiles = list(current_projectile)
		..()


// HOWIZTER GUN
// dumb meme admin item. not remotely fair, will probably kill person firing it.
/obj/item/gun/energy/howitzer
	name = "man-portable plasma howitzer"
	desc = "How can you even lift this?"
	icon_state = "bfg"
	uses_multiple_icon_states = 0
	force = 25
	two_handed = 1
	can_dual_wield = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/howitzer

	New()
		..()
		set_current_projectile(new/datum/projectile/special/howitzer)
		projectiles = list(new/datum/projectile/special/howitzer )

/obj/item/gun/energy/optio1
	name = "\improper Optio I"
	desc = "It's a laser? Yeah, you're pretty sure it's a handgun."
	w_class = W_CLASS_SMALL
	icon_state = "optio_1"
	item_state = "protopistol"
	cell_type = /obj/item/ammo/power_cell/self_charging/ntso_signifer
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/ntso_signifer/bad
	can_swap_cell = 0

	New()
		set_current_projectile(new/datum/projectile/bullet/optio)
		projectiles = list(current_projectile, new/datum/projectile/bullet/optio/hitscan)
		..()

/obj/item/gun/energy/signifer2
	name = "\improper Signifer II"
	desc = "It's a handgun? Or an smg? You can't tell."
	icon_state = "signifer_2"
	w_class = W_CLASS_NORMAL		//for clarity
	object_flags = NO_ARM_ATTACH
	force = 8
	two_handed = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/ntso_signifer
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/ntso_signifer/bad
	can_swap_cell = 0
	var/shotcount = 0

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/signifer_tase)
		projectiles = list(current_projectile,new/datum/projectile/laser/signifer_lethal)
		..()

	update_icon()
		..()
		if(!src.two_handed)// && current_projectile.type == /datum/projectile/energy_bolt)
			src.icon_state = "signifer_2"
			src.item_state = "signifer_2"
			muzzle_flash = "muzzle_flash_elec"
			shoot_delay = 2
			spread_angle = 0
			force = 9
			w_class = W_CLASS_NORMAL
		else //if (current_projectile.type == /datum/projectile/laser)
			src.item_state = "signifer_2-smg"
			src.icon_state = "signifer_2-smg"
			muzzle_flash = "muzzle_flash_bluezap"
			spread_angle = 3
			shoot_delay = 5
			force = 12
			w_class = W_CLASS_BULKY

	attack_self(var/mob/M)
		if (!setTwoHanded(!src.two_handed))
			boutput(M, "<span class='alert'>You need a free hand to switch modes!</span>")
			return 0

		..()
		src.can_dual_wield = !src.two_handed
		UpdateIcon()
		M.update_inhands()

	alter_projectile(obj/projectile/P)
		. = ..()
		if(++shotcount == 2 && istype(P.proj_data, /datum/projectile/laser/signifer_lethal/))
			P.proj_data = new/datum/projectile/laser/signifer_lethal/brute

	shoot()
		shotcount = 0
		. = ..()

	shoot_point_blank(atom/target, mob/user, second_shot)
		shotcount = 0
		. = ..()

/obj/item/gun/energy/cornicen3
	name = "\improper Cornicen III"
	desc = "Formal enough for the boardroom. Rugged enough for the battlefield."
	icon = 'icons/obj/large/48x32.dmi'
	muzzle_flash = "muzzle_flash_bluezap"
	icon_state = "cornicen_close"
	item_state = "ntgun2"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD | ONBACK
	w_class = W_CLASS_NORMAL		//for clarity
	two_handed = TRUE
	force = 9
	cell_type = /obj/item/ammo/power_cell/self_charging/big
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/mediumbig
	can_swap_cell = 0
	rechargeable = 0
	shoot_delay = 8 DECI SECONDS
	spread_angle = 3
	var/extended = FALSE

	New()
		set_current_projectile(new/datum/projectile/laser/plasma/auto)
		projectiles = list(current_projectile,new/datum/projectile/laser/plasma/burst)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.5, 1.5, 1)
		..()

	update_icon()
		..()
		if(!src.extended)
			src.icon_state = "cornicen_close"
			src.item_state = "cornicen"
			src.w_class = W_CLASS_NORMAL
			src.spread_angle = initial(src.spread_angle)
		else
			src.icon_state = "cornicen_ext"
			src.item_state = "cornicen_ext"
			src.w_class = W_CLASS_BULKY
			src.spread_angle = 0

	attack_self(var/mob/M)
		..()
		src.extended = !src.extended
		UpdateIcon()
		if(src.extended)
			flick("cornicen_open", src)
		M.update_inhands()

/obj/item/gun/energy/tasersmg
	name = "taser SMG"
	icon_state = "tsmg_burst100"
	desc = "The Five Points Armory Taser Mk.III. A weapon that produces a cohesive electrical charge to stun its target, capable of firing in two shot burst or full auto configurations."
	item_state = "tsmg"
	force = 5
	two_handed = 1
	can_dual_wield = 0
	cell_type = /obj/item/ammo/power_cell/med_power
	muzzle_flash = "muzzle_flash_elec"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/smgburst)

		projectiles = list(current_projectile,new/datum/projectile/energy_bolt/smgauto)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.2, 1.2, 1)
		..()

	update_icon()
		..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			if(current_projectile.type == /datum/projectile/energy_bolt/smgauto)
				src.icon_state = "tsmg_auto[ratio]"
			else if (current_projectile.type == /datum/projectile/energy_bolt/smgburst)
				src.icon_state = "tsmg_burst[ratio]"


	attack_self(mob/user as mob)
		..()
		if (istype(current_projectile, /datum/projectile/energy_bolt/smgauto))
			spread_angle = 8
		else
			spread_angle = 2
		UpdateIcon()

///////////////////////////////////////Ray Gun
/obj/item/gun/energy/raygun
	name = "experimental ray gun"
	icon_state = "raygun"
	desc = "A weapon that looks vaguely like a cheap toy and is definitely unsafe."
	item_state = "raygun"
	force = 5
	can_dual_wield = 0
	muzzle_flash = "muzzle_flash_laser"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/raybeam)
		projectiles = list(new/datum/projectile/energy_bolt/raybeam)
		..()

	update_icon()
		..()
		return

	shoot(var/target,var/start,var/mob/user) //it's experimental for a reason; use at your own risk!
		if (canshoot(user))
			if (GET_COOLDOWN(src, "raygun_cooldown"))
				return
			if (prob(30))
				user.TakeDamage("chest", 0, rand(5, 15), 0, DAMAGE_BURN, 1)
				boutput(user, "<span class='alert'>This piece of junk Ray Gun backfired! Ouch!</span>")
				user.do_disorient(stamina_damage = 20, disorient = 3 SECONDS)
				ON_COOLDOWN(src, "raygun_cooldown", 2 SECONDS)
		return ..(target, start, user)

/obj/item/gun/energy/dazzler
	name = "dazzler"
	icon_state = "taser" // wtb 1 sprite
	item_state = "taser"
	uses_multiple_icon_states = 1
	force = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	desc = "The Five Points Armory Dazzler Prototype, an experimental weapon that produces a cohesive electrical charge designed to disorient and slowdown a target. It can even shoot through windows!"
	muzzle_flash = "muzzle_flash_bluezap"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/dazzler)
		projectiles = list(current_projectile)
		..()

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "taser[ratio]"
			return
		..()
