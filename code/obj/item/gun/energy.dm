TYPEINFO(/obj/item/gun/energy)
	mats = 32

/obj/item/gun/energy
	name = "energy weapon"
	icon = 'icons/obj/items/guns/energy.dmi'
	item_state = "gun"
	m_amt = 2000
	g_amt = 1000
	add_residue = 0 // Does this gun add gunshot residue when fired? Energy guns shouldn't.
	recoil_inaccuracy_max = 0 //lasers probably dont shudder as you shoot them
	icon_recoil_enabled = FALSE // same, this is probably better to visualize inaccuracy anyway
	camera_recoil_enabled = FALSE // no camera recoil on tasers etc please

	var/rechargeable = 1 // Can we put this gun in a recharger? False should be a very rare exception.
	var/robocharge = 800
	var/cell_type = /obj/item/ammo/power_cell // Type of cell to spawn by default.
	var/from_frame_cell_type = /obj/item/ammo/power_cell
	var/custom_cell_max_capacity = null // Is there a limit as to what power cell (in PU) we can use?
	var/wait_cycle = 0 // Using a self-charging cell should auto-update the gun's sprite.
	var/can_swap_cell = 1
	var/uses_charge_overlay = FALSE //! Does this gun use charge overlays on the sprite?
	var/charge_icon_state
	var/restrict_cell_type
	var/image/charge_image = null
	muzzle_flash = null
	inventory_counter_enabled = 1

	New()
		var/cell = null
		if(cell_type)
			cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, rechargeable, custom_cell_max_capacity, can_swap_cell, restrict_cell_type)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		..()
		UpdateIcon()

	disposing()
		processing_items -= src
		..()

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		if(from_frame_cell_type)
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
			. += SPAN_ALERT("*ERROR* No output selected!")

	update_icon()

		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
			if(uses_charge_overlay)
				update_charge_overlay()
		else
			inventory_counter.update_text("-")
		return 0

	emp_act()
		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
		src.visible_message("[src] sparks briefly as it overloads!")
		playsound(src, "sparks", 75, 1, -1)
		src.UpdateIcon()
		return

	proc/update_charge_overlay()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret))
			if (!src.charge_image)
				src.charge_image = image(src.icon)
				src.charge_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.charge_image.icon_state = "[src.charge_icon_state][ratio]"
			src.UpdateOverlays(src.charge_image, "charge")

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
					R.cell.use(src.robocharge)
					return 1
			return 0
		else
			if(canshoot(user))
				SEND_SIGNAL(src, COMSIG_CELL_USE, src.current_projectile.cost)
				return 1
			if (src.click_sound)
				boutput(user, SPAN_ALERT(src.click_msg))
				if (!src.silenced)
					playsound(user, src.click_sound, 60, TRUE)
			return 0


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

////////////////////////////////////TASERGUN
/obj/item/gun/energy/taser_gun
	name = "taser gun"
	icon_state = "taser"
	item_state = "taser"
	force = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	desc = "The Five Points Armory Taser Mk.I, a weapon that produces a cohesive electrical charge to stun and subdue its target."
	muzzle_flash = "muzzle_flash_elec"
	uses_charge_overlay = TRUE
	charge_icon_state = "taser"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt)
		projectiles = list(current_projectile)
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

/////////////////////////////////////LASERGUN
/obj/item/gun/energy/laser_gun
	name = "laser gun"
	icon_state = "laser"
	item_state = "laser"
	cell_type = /obj/item/ammo/power_cell/med_plus_power
	force = 7
	desc = "The venerable Hafgan Mod.28 laser gun, causes substantial damage in close quarters and space environments. Not suitable for use in dust storms."
	muzzle_flash = "muzzle_flash_laser"
	uses_charge_overlay = TRUE
	charge_icon_state = "laser"

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


////////////////////////////////////// Antique laser gun
TYPEINFO(/obj/item/gun/energy/antique)
	mats = 0
/obj/item/gun/energy/antique
	HELP_MESSAGE_OVERRIDE("You can use a <b>screwdriver</b> to open or close the maintenance panel. While the panel is open, you can insert lens and small coil to upgrade the weapon.")
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = "capgun"
	cell_type = /obj/item/ammo/power_cell/tiny
	force = 7
	desc = "It's a kit model of the Mod.00 'Lunaport Legend' laser gun from Super! Protector Friend. With realistic sound fx and exciting LED display!"
	muzzle_flash = "muzzle_flash_laser"
	uses_charge_overlay = TRUE
	charge_icon_state = "caplaser"

	var/obj/item/coil/small/myCoil = null
	var/obj/item/lens/myLens = null
	var/panelOpen = FALSE

	examine(mob/user)
		. = ..()
		if(src.panelOpen)
			. += "The maintenance panel is open."

	attackby(obj/item/item, mob/user)
		. = ..()
		if(isscrewingtool(item))
			user.show_text("You [src.panelOpen ? "close" : "open"] the maintenance panel.", "blue")
			src.panelOpen = !src.panelOpen
			if(!src.panelOpen)
				if(src.determineProjectiles() >= 3)//highest tier
					user.unlock_medal("Tinkerer", 1)
		if(istype(item, /obj/item/coil/small))
			if(panelOpen)
				user.show_text("You insert [item]", "blue")
				user.drop_item(item)
				if(src.myCoil)
					user.put_in_hand_or_drop(src.myCoil)
				src.myCoil = item
				item.set_loc(src)
			else
				user.show_text("You need to unscrew the maintenance panel first!", "red")
		if (istype(item, /obj/item/lens))
			if(panelOpen)
				user.show_text("You insert [item]", "blue")
				user.drop_item(item)
				if(src.myLens)
					user.put_in_hand_or_drop(src.myLens)
				src.myLens = item
				item.set_loc(src)
			else
				user.show_text("You need to unscrew the maintenance panel first!", "red")

	canshoot(mob/user)
		//configures the projectiles and makes sure it can actually shoot
		if(!src.myCoil || !src.myLens || !src.myCoil.material || !src.myLens.material)
			user.show_text("It's just a display model!", "red")
			return FALSE
		if(src.panelOpen)
			user.show_text("You need to secure the maintenance panel first!", "red")
			return FALSE
		. = ..()

	proc/evaluateQuality()
		//a quantification of how good the build was.
		//0 = nonfunctional
		//1 or 2 = 25 damage laser
		//3 or 4 = 45 damage laser
		//5 or 6 = 45 damage laser with alt-fire 3-round burst of 25 damage lasers
		var/evaluationScore = 0
		if(!src.myCoil || !src.myLens || !src.myCoil.material || !src.myLens.material)
			//not all components present
			return 0
		switch(src.myLens.material.getAlpha())
			if(-INFINITY to 80)
				evaluationScore += 3
			if(80 to 130)
				evaluationScore += 2
			if(130 to 180)
				evaluationScore += 1
			if(180 to INFINITY)
				//not good enough to be functional
				return 0
		switch(src.myCoil.material.getProperty("electrical") + ((src.myCoil.material.getMaterialFlags() & MATERIAL_ENERGY) ? 2 : 0))
			if(10 to INFINITY)
				evaluationScore += 3
			if(8 to 10)
				evaluationScore += 2
			if(6 to 8)
				evaluationScore += 1
			if(-INFINITY to 6)
				//not good enough to be functional
				return 0
		//grading finished, return score
		return evaluationScore

	proc/determineProjectiles()
		//returns a number for each tier
		switch(src.evaluateQuality())
			if(5 to INFINITY)
				src.current_projectile = new/datum/projectile/laser
				src.projectiles = list(current_projectile, new/datum/projectile/laser/glitter/burst)
				return 3
			if(3 to 5)
				src.current_projectile = new/datum/projectile/laser
				src.projectiles = list(current_projectile)
				return 2
			if(1 to 3)
				src.current_projectile = new/datum/projectile/laser/glitter
				src.projectiles = list(current_projectile)
				return 1
			if(-INFINITY to 1)
				src.current_projectile = null
				src.projectiles = null
				return 0

//////////////////////////////////////// Phaser
/obj/item/gun/energy/phaser_gun
	name = "RP-4 phaser gun"
	icon_state = "phaser"
	item_state = "phaser"
	force = 7
	desc = "An amplified carbon-arc weapon designed by Radnor Photonics. Popular among frontier adventurers and explorers."
	muzzle_flash = "muzzle_flash_phaser"
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_charge_overlay = TRUE
	charge_icon_state = "phaser"

	New()
		set_current_projectile(new/datum/projectile/laser/light)
		projectiles = list(current_projectile)
		..()

/obj/item/gun/energy/phaser_gun/extended_mag
	cell_type = /obj/item/ammo/power_cell/med_plus_power

TYPEINFO(/obj/item/gun/energy/phaser_small)
	mats = 20

/obj/item/gun/energy/phaser_small
	name = "RP-3 micro phaser"
	icon_state = "phaser-tiny"
	item_state = "phaser"
	force = 4
	desc = "A diminutive carbon-arc sidearm produced by Radnor Photonics. It's not much, but it might just save your life."
	muzzle_flash = "muzzle_flash_phaser"
	cell_type = /obj/item/ammo/power_cell
	w_class = W_CLASS_SMALL
	uses_charge_overlay = TRUE
	charge_icon_state = "phaser-tiny"

	New()
		set_current_projectile(new/datum/projectile/laser/light/tiny)
		projectiles = list(current_projectile)
		..()

TYPEINFO(/obj/item/gun/energy/phaser_huge)
	mats = list("metal" = 15,
				"metal_dense" = 10,
				"conductive_high" = 10,
				"energy_high" = 15,
				"crystal" = 10)
/obj/item/gun/energy/phaser_huge
	name = "RP-5 macro phaser"
	icon_state = "phaser-xl"
	item_state = "phaser_xl"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	c_flags = ONBACK
	desc = "The largest amplified carbon-arc weapon from Radnor Photonics. A big gun for big problems."
	muzzle_flash = "muzzle_flash_phaser"
	cell_type = /obj/item/ammo/power_cell/med_plus_power
	shoot_delay = 8
	can_dual_wield = FALSE
	force = MELEE_DMG_RIFLE
	two_handed = 1
	uses_charge_overlay = TRUE
	charge_icon_state = "phaser-xl"

	New()
		set_current_projectile(new/datum/projectile/laser/light/huge) // light/huge - whatev!!!! this should probably be refactored
		projectiles = list(current_projectile)
		AddComponent(/datum/component/holdertargeting/windup, 1 SECOND)
		..()

/obj/item/gun/energy/phaser_smg
	name = "RP-4S phaser smg"
	icon_state = "phaser-smg"
	item_state = "phaser"
	force = 7
	desc = "An amplified carbon-arc weapon designed by Radnor Photonics, modified to fire in fully automatic mode. Popular among frontier adventurers and explorers."
	muzzle_flash = "muzzle_flash_phaser"
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_charge_overlay = TRUE
	charge_icon_state = "phaser-smg"
	spread_angle = 10

	New()
		set_current_projectile(new/datum/projectile/laser/light/smg)
		projectiles = list(current_projectile)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.2)
		..()

/obj/item/gun/energy/phaser_smg/extended_mag
	cell_type = /obj/item/ammo/power_cell/med_plus_power

///////////////////////////////////////Rad Crossbow
TYPEINFO(/obj/item/gun/energy/crossbow)
	mats = list("metal" = 5,
				"conductive_high" = 5,
				"energy_high" = 10)
/obj/item/gun/energy/crossbow
	name = "\improper Wenshen mini rad-poison-crossbow"
	desc = "The XIANG|GIESEL Wenshen (瘟神) crossbow favored by many of the Syndicate's stealth specialists, which does damage over time using a slow-acting radioactive poison. Utilizes a self-recharging atomic power cell from Giesel Radiofabrik."
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
	silenced = 1 // No conspicuous text messages, please (Convair880).
	hide_attack = ATTACK_FULLY_HIDDEN
	custom_cell_max_capacity = 100 // Those self-charging ten-shot radbows were a bit overpowered (Convair880)
	muzzle_flash = null
	uses_charge_overlay = TRUE
	charge_icon_state = "crossbow"

	New()
		set_current_projectile(new/datum/projectile/rad_bolt)
		projectiles = list(current_projectile)
		..()


	update_charge_overlay()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret))
			if (!src.charge_image)
				src.charge_image = image(src.icon)
				src.charge_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			// the -0.125 is so we only show the final state when we're actually ready to fire
			ratio = round(ratio-0.125, 0.25) * 100
			src.charge_image.icon_state = "[src.charge_icon_state][ratio]"
			src.UpdateOverlays(src.charge_image, "charge")

////////////////////////////////////////EGun
TYPEINFO(/obj/item/gun/energy/egun)
	mats = list("metal" = 15,
				"conductive" = 5,
				"energy" = 5)
/obj/item/gun/energy/egun
	name = "energy gun"
	icon_state = "energy"
	cell_type = /obj/item/ammo/power_cell/med_plus_power
	desc = "The Five Points Armory Energy Gun. Double emitters with switchable fire modes, for stun bolts or lethal laser fire."
	item_state = "egun"
	force = 5
	var/nojobreward = 0 //used to stop people from scanning it and then getting both a lawbringer/sabre AND an egun.
	muzzle_flash = "muzzle_flash_elec"
	uses_charge_overlay = TRUE
	charge_icon_state = "energystun"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt)
		projectiles = list(current_projectile,new/datum/projectile/laser)
		RegisterSignal(src, COMSIG_ATOM_ANALYZE, PROC_REF(noreward))
		..()
	update_icon()
		if (current_projectile.type == /datum/projectile/laser)
			charge_icon_state = "energykill"
			muzzle_flash = "muzzle_flash_laser"
			item_state = "egun-kill"
		else if (current_projectile.type == /datum/projectile/energy_bolt)
			charge_icon_state = "energystun"
			muzzle_flash = "muzzle_flash_elec"
			item_state = "egun"
		..()
	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

	proc/noreward()
		src.nojobreward = 1

	captain
		desc = "The Five Points Armory Energy Gun. Double emitters with switchable fire modes, for stun bolts or lethal laser fire. Decorated to match standard NT captain attire."
		icon_state = "energy-cap"

	head_of_security
		desc = "The Five Points Armory Energy Gun. Double emitters with switchable fire modes, for stun bolts or lethal laser fire. 'HOS' is engraved in the side."
		icon_state = "energy-hos"


TYPEINFO(/obj/item/gun/energy/egun_jr)
	mats = null

/obj/item/gun/energy/egun_jr
	name = "energy gun junior"
	icon_state = "egun-jr"
	cell_type = /obj/item/ammo/power_cell/med_minus_power
	desc = "A smaller, disposable version of the Five Points Armory energy gun, with dual modes for stun and kill."
	item_state = "egun"
	force = 3
	muzzle_flash = "muzzle_flash_elec"
	can_swap_cell = FALSE
	rechargeable = FALSE
	spread_angle = 10
	uses_charge_overlay = TRUE
	charge_icon_state = "egunjr"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/diffuse)
		projectiles = list(current_projectile,new/datum/projectile/laser/diffuse)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/laser/diffuse)
			charge_icon_state = "[initial(charge_icon_state)]kill"
			muzzle_flash = "muzzle_flash_laser"
			item_state = "egun-jrkill"
		else if(current_projectile.type == /datum/projectile/energy_bolt/diffuse)
			charge_icon_state = "[initial(charge_icon_state)]stun"
			muzzle_flash = "muzzle_flash_elec"
			item_state = "egun-jrstun"
		..()

	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

//////////////////////// nanotrasen gun
//Azungar's Nanotrasen inspired Laser Assault Rifle for RP gimmicks
/obj/item/gun/energy/ntgun
	name = "laser assault rifle"
	icon_state = "nt"
	desc = "Rather futuristic assault rifle with two firing modes."
	item_state = "ntgun"
	force = 10
	contraband = 8
	two_handed = 1
	spread_angle = 6
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_charge_overlay = TRUE
	charge_icon_state = "ntstun"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/ntburst)
		projectiles = list(current_projectile,new/datum/projectile/laser/ntburst)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/energy_bolt/ntburst)
			charge_icon_state = "[icon_state]stun"
		else
			charge_icon_state = "[icon_state]lethal"
		..()
	attack_self()
		..()
		UpdateIcon()



//////////////////////// Taser Shotgun
//Azungar's Improved, more beefy weapon for security that can only be acquired via QM.
/obj/item/gun/energy/tasershotgun
	name = "taser shotgun"
	icon_state = "tasershotgun"
	desc = "The Five Points Armory Taser Mk.II, a shotgun-format weapon that produces a spreading electrical charge to stuns its targets."
	item_state = "tasers"
	cell_type = /obj/item/ammo/power_cell/med_power
	force = 12
	two_handed = 1
	can_dual_wield = 0
	shoot_delay = 6 DECI SECONDS
	muzzle_flash = "muzzle_flash_elec"
	uses_charge_overlay = TRUE
	charge_icon_state = "tasershotgun"

	New()
		set_current_projectile(new/datum/projectile/special/spreader/tasershotgunspread)
		projectiles = list(current_projectile,new/datum/projectile/energy_bolt/tasershotgunslug)
		..()


////////////////////////////////////VUVUV
TYPEINFO(/obj/item/gun/energy/vuvuzela_gun)
	mats = list("metal" = 5,
				"conductive_high" = 5,
				"energy_high" = 10)
/obj/item/gun/energy/vuvuzela_gun
	name = "amplified vuvuzela"
	icon_state = "vuvuzela"
	item_state = "bike_horn"
	desc = "BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT, *fart*"
	cell_type = /obj/item/ammo/power_cell/med_power
	is_syndicate = 1
	uses_charge_overlay = TRUE
	charge_icon_state = "vuvuzela"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt_v)
		projectiles = list(current_projectile)
		..()

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
			boutput(user, SPAN_ALERT("You attempt to swap the cell but \the [src] bites you instead."))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1, -6)
			user.TakeDamage(user.zone_sel.selecting, 3, 0)
			take_bleeding_damage(user, user, 3, DAMAGE_CUT)
			return
		. = ..()

////////////////////////////////////Wave Gun
/obj/item/gun/energy/wavegun
	name = "\improper Sancai wave gun"
	desc = "The versatile XIANG|GIESEL model '三�' with three nonlethal functions: inverse '炎�', transverse '地皇' and reflective '天皇' ."
	icon_state = "wavegun"
	item_state = "wave"
	cell_type = /obj/item/ammo/power_cell/med_power
	m_amt = 4000
	force = 6
	muzzle_flash = "muzzle_flash_wavep"
	uses_charge_overlay = TRUE
	charge_icon_state = "wavegun"

	New()
		set_current_projectile(new/datum/projectile/wavegun)
		projectiles = list(current_projectile,new/datum/projectile/wavegun/transverse,new/datum/projectile/wavegun/bouncy)
		..()

	// Old phasers aren't around anymore, so the wave gun might as well use their better sprite (Convair880).
	// Flaborized has made a lovely new wavegun sprite! - Gannets
	// Flaborized has made even more wavegun sprites!

	update_icon()
		if (current_projectile.type == /datum/projectile/wavegun)
			charge_icon_state = "[icon_state]"
			muzzle_flash = "muzzle_flash_wavep"
			item_state = "wave"
		else if (current_projectile.type == /datum/projectile/wavegun/transverse)
			charge_icon_state = "[icon_state]_green"
			muzzle_flash = "muzzle_flash_waveg"
			item_state = "wave-g"
		else
			charge_icon_state = "[icon_state]_emp"
			muzzle_flash = "muzzle_flash_waveb"
			item_state = "wave-emp"
		..()
	attack_self(mob/user as mob)
		..()
		UpdateIcon()
		user.update_inhands()

////////////////////////////////////BFG
/obj/item/gun/energy/bfg
	name = "\improper BFG 9000"
	icon_state = "bfg"
	m_amt = 4000
	force = 6
	desc = "I think it stands for Banned For Griefing?"
	cell_type = /obj/item/ammo/power_cell/high_power
	recoil_strength = 20
	camera_recoil_enabled = TRUE

	New()
		set_current_projectile(new/datum/projectile/bfg)
		projectiles = list(new/datum/projectile/bfg)
		..()

	update_icon()
		..()
		return

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
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
	w_class = W_CLASS_NORMAL
	item_state = "gun"
	force = 10
	throw_speed = 2
	throw_range = 10
	cell_type = /obj/item/ammo/power_cell/med_power
	var/obj/item/our_target = null
	var/obj/machinery/computer/teleporter/our_teleporter = null // For checks before firing (Convair880).
	uses_charge_overlay = TRUE
	charge_icon_state = "teleport"
	HELP_MESSAGE_OVERRIDE({"Use the teleport gun in hand to set it's destination. Destination list is pulled from all the currently activated teleporters."})

	New()
		set_current_projectile(new /datum/projectile/tele_bolt)
		projectiles = list(current_projectile)
		..()

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

		if (length(L) < 2)
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

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!src.our_target)
			user.show_text("Error: no target set. Please select a teleporter first.", "red")
			return
		if (!src.our_teleporter || (src.our_teleporter.check_teleporter() != 1))
			user.show_text("Error: linked teleporter is out of order.", "red")
			return

		var/datum/projectile/tele_bolt/TB = current_projectile
		TB.target = our_target
		return ..(target, user)

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
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
	uses_charge_overlay = TRUE
	charge_icon_state = "ghost"

	New()
		set_current_projectile(new /datum/projectile/energy_bolt_antighost)
		projectiles = list(current_projectile)
		..()

///////////////////////////////////////Particle Blasters
TYPEINFO(/obj/item/gun/energy/blaster_pistol)
	mats = 0

/obj/item/gun/energy/blaster_pistol
	name = "GRF Zap-Pistole"
	desc = "A dangerous-looking particle blaster pistol from Giesel Radiofabrik. It's self-charging by a radioactive power cell. Beware of Bremsstrahlung backscatter."
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "pistol"
	charge_icon_state = "pistol"
	uses_charge_overlay = TRUE
	w_class = W_CLASS_NORMAL
	force = MELEE_DMG_PISTOL
	cell_type = /obj/item/ammo/power_cell/self_charging/medium
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/disruptor
	rarity = 3
	muzzle_flash = "muzzle_flash_bluezap"
	shoot_delay = 2


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

	/*examine()
		set src in view()
		boutput(usr, "[SPAN_NOTICE("Installed components:")]<br>")
		if(emitter)
			boutput(usr, SPAN_NOTICE("[src.emitter.name]"))
		if(cell)
			boutput(usr, SPAN_NOTICE("[src.cell.name]"))
		if(back)
			boutput(usr, SPAN_NOTICE("[src.back.name]"))
		if(top_rail)
			boutput(usr, SPAN_NOTICE("[src.top_rail.name]"))
		if(bottom_rail)
			boutput(usr, SPAN_NOTICE("[src.bottom_rail.name]"))
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
	name = "GRF Zap-Maschine"
	desc = "A special issue particle blaster from Giesel Radiofabrik, designed for burst fire. It's self-charging by a radioactive power cell. Beware of Bremsstrahlung backscatter."
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "smg"
	charge_icon_state = "smg"
	uses_charge_overlay = TRUE
	can_dual_wield = FALSE
	w_class = W_CLASS_NORMAL
	force = MELEE_DMG_PISTOL
	cell_type = /obj/item/ammo/power_cell/self_charging/medium
	rarity = 4
	spread_angle = 10
	muzzle_flash = "muzzle_flash_bluezap"

	New()
		set_current_projectile(new /datum/projectile/laser/blaster/burst)
		projectiles = list(current_projectile)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.2)
		..()

/obj/item/gun/energy/blaster_carbine
	name = "GRF Zap-Karabiner"
	desc = "A blaster carbine from Giesel Radiofabrik, designed for longer range engagements. It's self-charging by a radioactive power cell. Beware of Bremsstrahulung backscatter."
	icon = 'icons/obj/items/guns/energy48x32.dmi'
	icon_state = "blaster-carbine"
	charge_icon_state = "blaster-carbine"
	item_state = "rifle"
	uses_charge_overlay = TRUE
	can_dual_wield = FALSE
	two_handed = TRUE
	w_class = W_CLASS_BULKY
	force = MELEE_DMG_RIFLE
	cell_type = /obj/item/ammo/power_cell/self_charging/medium
	rarity = 4
	shoot_delay = 4
	muzzle_flash = "muzzle_flash_bluezap"

	New()
		set_current_projectile(new /datum/projectile/laser/blaster/carbine)
		projectiles = list(current_projectile)
		..()

/obj/item/gun/energy/blaster_cannon
	name = "GRF Zap-Kanone"
	desc = "A heavy particle blaster from Giesel Radiofabrik, designed for high damage. It's self-charging by a larger radioactive power cell. Beware of Bremsstrahlung backscatter."
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "cannon"
	charge_icon_state = "cannon"
	item_state = "rifle"
	uses_charge_overlay = TRUE
	can_dual_wield = FALSE
	two_handed = TRUE
	w_class = W_CLASS_BULKY
	force = MELEE_DMG_RIFLE
	shoot_delay = 8
	cell_type = /obj/item/ammo/power_cell/self_charging/big
	rarity = 5
	muzzle_flash = "muzzle_flash_bluezap"
	recoil_strength = 20
	camera_recoil_enabled = TRUE

	New()
		set_current_projectile(new /datum/projectile/laser/blaster/cannon)
		projectiles = list(current_projectile)
		c_flags |= ONBACK
		AddComponent(/datum/component/holdertargeting/windup, 1 SECOND)
		..()

///////////modular components - putting them here so it's easier to work on for now////////
/*
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
		icon_state = "mod-grip" */

///////////////////////////////////////Owl Gun
/obj/item/gun/energy/owl
	name = "owl gun"
	desc = "Its a gun that has two modes, Owl and Owler"
	item_state = "gun"
	force = 5
	icon_state = "ghost"
	uses_charge_overlay = TRUE
	charge_icon_state = "ghost"
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/owl)
		projectiles = list(current_projectile,new/datum/projectile/owl/owlate)
		..()

/obj/item/gun/energy/owl_safe
	name = "owl gun"
	desc = "Hoot!"
	item_state = "gun"
	force = 5
	icon_state = "ghost"
	uses_charge_overlay = TRUE
	charge_icon_state = "ghost"
	cell_type = /obj/item/ammo/power_cell/med_power

	New()
		set_current_projectile(new/datum/projectile/owl)
		projectiles = list(current_projectile)
		..()

///////////////////////////////////////Frog Gun (Shoots :getin: and :getout:)
/obj/item/gun/energy/frog
	name = "frog gun"
	desc = "It appears to be shivering and croaking in your hand. How creepy." //it must be unhoppy :^)
	icon = 'icons/obj/items/guns/gimmick.dmi'
	icon_state = "frog"
	item_state = "gun"
	m_amt = 1000
	force = 0

	cell_type = /obj/item/ammo/power_cell/self_charging/big //gotta have power for the frog

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
	uses_charge_overlay = TRUE
	charge_icon_state = "ghost"

	New()
		set_current_projectile(new/datum/projectile/shrink_beam)
		projectiles = list(current_projectile)
		..()

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
	uses_charge_overlay = TRUE
	charge_icon_state = "ghost"

	New()
		set_current_projectile(new/datum/projectile/bioeffect_beam/stinky)
		projectiles = list(current_projectile)
		..()


///////////////////////////////////////Glitch Gun
/obj/item/gun/energy/glitch_gun
	name = "glitch gun"
	desc = "It's humming with some sort of disturbing energy. Do you really wanna hold this?"
	icon = 'icons/obj/items/guns/toy.dmi'
	icon_state = "airzooka"
	m_amt = 4000
	force = 0
	cell_type = /obj/item/ammo/power_cell/high_power

	New()
		set_current_projectile(new/datum/projectile/bullet/glitch/gun)
		projectiles = list(new/datum/projectile/bullet/glitch/gun)
		..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (canshoot(user)) // No more attack messages for empty guns (Convair880).
			playsound(user, 'sound/weapons/DSBFG.ogg', 75)
			sleep(0.1 SECONDS)
		return ..(target, start, user)

///////////////////////////////////////Hunter
TYPEINFO(/obj/item/gun/energy/plasma_gun)
	mats = list("metal_superdense" = 7,
				"crystal" = 13,
				"energy_high" = 10)
/obj/item/gun/energy/plasma_gun/ // Made use of a spare sprite here (Convair880).
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

/obj/item/gun/energy/plasma_gun/vr
	name = "advanced laser gun"
	icon = 'icons/effects/VR.dmi'
	icon_state = "wavegun"
	base_item_state = "wavegun"
	uses_charge_overlay = TRUE
	charge_icon_state = "wavegun"

TYPEINFO(/obj/item/gun/energy/plasma_gun/hunter)
	mats = null

/obj/item/gun/energy/plasma_gun/hunter
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

/////////////////////////////////////// Pickpocket Grapple, Grayshift's grif gun
TYPEINFO(/obj/item/gun/energy/pickpocket)
	mats = list("metal" = 5,
				"conductive_high" = 5,
				"energy_high" = 10)
/obj/item/gun/energy/pickpocket
	name = "\improper Super! Grapple Friend" // like foam dart guns
	desc = "A complicated, camoflaged claw device on a tether capable of complex and stealthy interactions. It's definitely not just a repurposed janky toy that steals shit."
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
	HELP_MESSAGE_OVERRIDE({"Use the pickpocket gun in hand to alternate between three fire modes : <b>Steal</b>, <b>Plant</b> and <b>Harass</b>.\n
							To remove an item from the pickpocket gun, hold the gun in one hand, then use your other hand on it.\n
							To place an item into the pickpocket gun, hold the gun in one hand, then hit it with an item in your other hand.\n
							While on <b>Steal</b>, the gun will attempt to steal the item of the target who's body part you are aiming at.\n
							While on <b>Plant</b>, the gun will attempt to place an item on the target on the body part you are aiming at.\n
							While on <b>Harass</b>, the gun will perform a debilitating effect on the target depending on the body part you are aiming at."})

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

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
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
		if(isrestrictedz(us.z) && !in_shuttle_transit(us))
			boutput(user, "\The [src.name] jams!")
			return
		return ..(target, user)

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (istype(current_projectile, /datum/projectile/pickpocket/steal) && heldItem)
			boutput(user, "Cannot steal items while gun is holding something!")
			return
		if (istype(current_projectile, /datum/projectile/pickpocket/plant) && !heldItem)
			boutput(user, "Cannot plant item if gun is not holding anything!")
			return

		var/turf/us = get_turf(src)
		if (isrestrictedz(us.z) && !in_shuttle_transit(us))
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
	mats = list("metal_dense" = 15,
				"conductive_high" = 10,
				"energy_high" = 10)
/obj/item/gun/energy/alastor
	name = "\improper Alastor pattern laser rifle"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "alastor100"
	item_state = "alastor"
	icon = 'icons/obj/large/38x38.dmi'
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
	mats = list("metal" = 15,
				"conductive_high" = 5,
				"energy_high" = 5)
	start_listen_effects = list(LISTEN_EFFECT_LAWBRINGER)
	start_listen_modifiers = null
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD_RANGE_0, LISTEN_INPUT_EQUIPPED)
	start_listen_languages = list(LANGUAGE_ENGLISH)

/obj/item/gun/energy/lawbringer
	name = "\improper Lawbringer"
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
	tooltip_flags = REBUILD_USER
	var/emagged = FALSE

	New(var/mob/M)
		set_current_projectile(new/datum/projectile/energy_bolt/aoe)
		projectiles = list(
			"detain" = current_projectile,
			"execute" = new/datum/projectile/laser/blaster/lawbringer,
			"smokeshot" = new/datum/projectile/bullet/smoke,
			"knockout" = new/datum/projectile/bullet/tranq_dart/law_giver,
			"hotshot" = new/datum/projectile/bullet/flare,
			"assault" = new/datum/projectile/laser/asslaser,
			"clownshot" = new/datum/projectile/bullet/clownshot,
			"pulse" = new/datum/projectile/energy_bolt/pulse
		)
		// projectiles = list(current_projectile,new/datum/projectile/bullet/revolver_38/lb,new/datum/projectile/bullet/smoke,new/datum/projectile/bullet/tranq_dart/law_giver,new/datum/projectile/bullet/flare,new/datum/projectile/bullet/aex/lawbringer,new/datum/projectile/bullet/clownshot)

		src.indicator_display = image('icons/obj/items/guns/energy.dmi', "")
		src.assign_name(M)

		..()

	disposing()
		indicator_display = null
		..()

	get_desc(dist, mob/user)
		if (user.mind.is_antagonist())
			. += SPAN_ALERT("<b>It doesn't seem to like you...</b>")

	attack_hand(mob/user)
		if (!owner_prints)
			src.assign_name(user)
		..()

	//if it has no owner prints scanned, the next person to attack_self it is the owner.
	//you have to use voice activation to change modes. haha!
	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if (owner_prints != user.bioHolder.Uid)
			boutput(user, SPAN_NOTICE("There don't seem to be any buttons on [src] to press."))
			return
		else
			src.assign_name(user)


	proc/assign_name(var/mob/M)
		if (owner_prints)
			return
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.bioHolder)
				boutput(M, SPAN_ALERT("[src] has accepted the DNA string. You are now the owner!"))
				owner_prints = H.bioHolder.Uid
				src.name = "HoS [H.real_name]'s Lawbringer"
				tooltip_rebuild = 1

	proc/change_mode(var/mob/M, var/text, var/sound = TRUE)
		switch(text)
			if ("detain")
				set_current_projectile(projectiles["detain"])
				item_state = "lawg-detain"
				if (sound)
					playsound(M, 'sound/vox/detain.ogg', 50)
				src.toggle_recoil(FALSE)
			if ("execute", "exterminate", "cluwneshot") //heh
				set_current_projectile(projectiles["execute"])
				current_projectile.cost = 30
				item_state = "lawg-execute"
				if (sound)
					playsound(M, "sound/vox/[text == "cluwneshot" ? "cluwne" : "exterminate"].ogg", 50)
				src.toggle_recoil(FALSE)
			if ("smokeshot","fog")
				set_current_projectile(projectiles["smokeshot"])
				current_projectile.cost = 50
				item_state = "lawg-smokeshot"
				if (sound)
					playsound(M, 'sound/vox/smoke.ogg', 50)
				src.toggle_recoil(TRUE)
			if ("knockout", "sleepshot")
				set_current_projectile(projectiles["knockout"])
				current_projectile.cost = 60
				item_state = "lawg-knockout"
				if (sound)
					playsound(M, 'sound/vox/sleep.ogg', 50)
				src.toggle_recoil(FALSE)
			if ("hotshot","incendiary")
				set_current_projectile(projectiles["hotshot"])
				current_projectile.cost = 60
				item_state = "lawg-hotshot"
				if (sound)
					playsound(M, 'sound/vox/hot.ogg', 50)
				src.toggle_recoil(TRUE)
			if ("assault","highpower", "bigshot")
				set_current_projectile(projectiles["assault"])
				current_projectile.cost = 170
				item_state = "lawg-bigshot"
				if (sound)
					playsound(M, 'sound/vox/high.ogg', 50)
					SPAWN(0.6 SECONDS)
						playsound(M, 'sound/vox/power.ogg', 50)
				src.toggle_recoil(FALSE)
			if ("clownshot","clown")
				set_current_projectile(projectiles["clownshot"])
				item_state = "lawg-clownshot"
				if (sound)
					playsound(M, 'sound/vox/clown.ogg', 30)
				src.toggle_recoil(FALSE)
			if ("pulse", "push", "throw")
				set_current_projectile(projectiles["pulse"])
				item_state = "lawg-pulse"
				if (sound)
					playsound(M, 'sound/vox/push.ogg', 50)
				src.toggle_recoil(FALSE)

	//Are you really the law? takes the mob as speaker, and the text spoken, sanitizes it. If you say "i am the law" and you in fact are NOT the law, it's gonna blow. Moved out of the switch statement because it that switch is only gonna run if the owner speaks
	proc/are_you_the_law(mob/M as mob, text)
		text = sanitize_talk(text)
		if (findtext(text, "iamthelaw"))
			//you must be holding/wearing the weapon
			//this check makes it so that someone can't stun you, stand on top of you and say "I am the law" to kill you
			if (src in M.contents)
				if (M.job != "Head of Security" || src.emagged)
					src.cant_self_remove = 1
					playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
					logTheThing(LOG_COMBAT, src, "Is not the law. Caused explosion with Lawbringer.")

					SPAWN(2 SECONDS)
						src.blowthefuckup(15)
					return 0
				else
					return 1

	proc/toggle_recoil(on)
		if(on)
			recoil_inaccuracy_max = 5
			icon_recoil_enabled = TRUE
			camera_recoil_enabled = TRUE
		else
			recoil_inaccuracy_max = 0
			icon_recoil_enabled = FALSE
			camera_recoil_enabled = FALSE

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
			else if (current_projectile.type == /datum/projectile/laser/blaster/lawbringer)			//execute - cyan
				indicator_display.color = "#00FFFF"
				muzzle_flash = "muzzle_flash_bluezap"
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

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)

		if (src.emagged)
			src.change_mode(user, pick(src.projectiles), sound = FALSE)

		if (canshoot(user))
			//removing this for now so anyone can shoot it. I PROBABLY will want it back, doing this for some light appeasement to see how it goes.
			//shock the guy who tries to use this if they aren't the proper owner. (or if the gun is not emagged)
			// if (!fingerprints_can_shoot(user))
			// 	// shock(user, 70)
			// 	random_burn_damage(user, 50)
			// 	user.changeStatus("knockdown", 4 SECONDS)
			// 	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			// 	s.set_up(2, 1, (get_turf(src)))
			// 	s.start()
			// 	user.visible_message(SPAN_ALERT("[user] tries to fire [src]! The gun initiates its failsafe mode."))
			// 	return

			if (current_projectile.type == /datum/projectile/bullet/flare)
				shoot_fire_hotspots(target, start, user)
			else if (current_projectile.type == /datum/projectile/laser/asslaser)
				for (var/mob/living/mob in viewers(1, user))
					mob.flash(1.5 SECONDS)
				user.changeStatus("disorient", 2 SECONDS)
				playsound(get_turf(src), 'sound/weapons/ACgun1.ogg', 50, pitch = 1.2)
		return ..(target, start, user)

/obj/item/gun/energy/lawbringer/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (user)
		src.emagged = TRUE
		boutput(user, SPAN_ALERT("Anyone can use this gun now. Be careful! (use it in-hand to register your fingerprints)"))
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
		fireflash(F, 0.5, 2400, chemfire = CHEM_FIRE_RED)

// Pulse Rifle //
// An energy gun that uses the lawbringer's Pulse setting, to beef up the current armory.

/obj/item/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A sleek energy rifle with two different pulse settings: Kinetic and Electromagnetic."
	icon_state = "pulse_rifle"
	item_state = "pulse_rifle"
	force = 5
	two_handed = 1
	can_dual_wield = 0
	muzzle_flash = "muzzle_flash_bluezap"
	cell_type = /obj/item/ammo/power_cell/high_power //300 PU
	uses_charge_overlay = TRUE
	charge_icon_state = "pulse_rifle"

	New()
		..()
		set_current_projectile(new/datum/projectile/energy_bolt/pulse)//uses 35PU per shot, so 8 shots
		projectiles = list(new/datum/projectile/energy_bolt/pulse, new/datum/projectile/energy_bolt/electromagnetic_pulse)


///////////////////////////////////////Wasp Gun
TYPEINFO(/obj/item/gun/energy/wasp)
	mats = list("metal" = 5,
				"conductive_high" = 5,
				"energy_high" = 10)
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

TYPEINFO(/obj/item/gun/energy/optio1)
	mats = list("iridiumalloy" = 30,
				"plutonium" = 15,
				"electrum" = 25)
/obj/item/gun/energy/optio1
	name = "\improper Optio I"
	desc = "It's a laser gun? Or a handgun? Yeah, you're pretty sure it's a handgun."
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

TYPEINFO(/obj/item/gun/energy/signifer2)
	mats = list("energy_high" = 15,
				"conductive_high" = 15,
				"metal_superdense" = 20)
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
			boutput(M, SPAN_ALERT("You need a free hand to switch modes!"))
			return 0

		..()
		src.can_dual_wield = !src.two_handed
		UpdateIcon()
		M.update_inhands()

	alter_projectile(obj/projectile/P)
		. = ..()
		if(++shotcount == 2 && istype(P.proj_data, /datum/projectile/laser/signifer_lethal/))
			P.proj_data = new/datum/projectile/laser/signifer_lethal/brute

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		shotcount = 0
		. = ..()

	shoot_point_blank(atom/target, mob/user, second_shot)
		shotcount = 0
		. = ..()

TYPEINFO(/obj/item/gun/energy/cornicen3)
	mats = list("iridiumalloy" = 50,
				"starstone" = 30,
				"plutonium" = 25,
				"electrum" = 50,
				"exoweave" = 5)
/obj/item/gun/energy/cornicen3
	name = "\improper Cornicen III"
	desc = "Formal enough for the boardroom. Rugged enough for the battlefield."
	icon = 'icons/obj/items/guns/energy48x32.dmi'
	muzzle_flash = "muzzle_flash_bluezap"
	icon_state = "cornicen_close"
	item_state = "ntgun2"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBACK
	w_class = W_CLASS_NORMAL		//for clarity
	two_handed = TRUE
	force = 9
	cell_type = /obj/item/ammo/power_cell/self_charging/big
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/mediumbig
	can_swap_cell = 0
	rechargeable = 0
	shoot_delay = 8 DECI SECONDS
	spread_angle = 3
	can_dual_wield = 0
	var/extended = FALSE

	New()
		set_current_projectile(new/datum/projectile/laser/plasma/auto)
		projectiles = list(current_projectile,new/datum/projectile/laser/plasma/burst)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.5)
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
			FLICK("cornicen_open", src)
		M.update_inhands()

TYPEINFO(/obj/item/gun/energy/vexillifer4)
	mats = list("iridiumalloy" = 50,
				"starstone" = 10,
				"metal_superdense" = 150,
				"crystal_dense" = 100,
				"conductive_high" = 100,
				"energy_extreme" = 50)
/obj/item/gun/energy/vexillifer4
	name = "Vexillifer IV"
	desc = "It's a cannon? A laser gun? You can't tell."
	icon = 'icons/obj/items/guns/energy64x32.dmi'
	icon_state = "lasercannon"
	item_state = "vexillifer"
	wear_state = "vexillifer"
	var/active_state = "lasercannon"
	var/collapsed_state = "lasercannon-empty"
	var/state = TRUE
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_LARGE
	camera_recoil_enabled = TRUE
	recoil_strength = 20


	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBACK

	can_dual_wield = 0
	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_bluezap"
	cell_type = /obj/item/ammo/power_cell/self_charging/mediumbig
	shoot_delay = 0.8 SECONDS

	New()
		set_current_projectile(new/datum/projectile/laser/ntso_cannon)
		AddComponent(/datum/component/holdertargeting/windup, 2 SECOND)
		..()

	attack_self(mob/user)
		. = ..()
		src.swap_state()

	proc/swap_state()
		if(state)
			RemoveComponentsOfType(/datum/component/holdertargeting/windup)
			src.icon_state = collapsed_state
			w_class = W_CLASS_NORMAL
		else
			AddComponent(/datum/component/holdertargeting/windup, 2 SECOND)
			src.icon_state = active_state
			w_class = W_CLASS_BULKY
		state = !state

	canshoot(mob/user)
		. = ..() && state

	setupProperties()
		..()
		setProperty("carried_movespeed", 0.3)

	flashy
		active_state = "lasercannon-anim"
		icon_state = "lasercannon-anim"

		shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
			if(src.canshoot(user))
				FLICK("lasercannon-fire", src)
			. = ..()

/obj/item/gun/energy/tasersmg
	name = "taser SMG"
	icon_state = "tasersmg"
	desc = "The Five Points Armory Taser Mk.III. A weapon that produces a cohesive electrical charge to stun its target, capable of firing in two shot burst or full auto configurations."
	item_state = "tsmg"
	force = 5
	two_handed = 1
	can_dual_wield = 0
	cell_type = /obj/item/ammo/power_cell/med_power
	muzzle_flash = "muzzle_flash_elec"
	uses_charge_overlay = TRUE
	charge_icon_state = "tasersmg"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/smgburst)

		projectiles = list(current_projectile,new/datum/projectile/energy_bolt/smgauto)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.2)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/energy_bolt/smgauto)
			charge_icon_state = "[icon_state]_auto"
		else
			charge_icon_state = "[icon_state]_burst"
		..()

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
	desc = "A weapon that looks vaguely like a cheap toy and is definitely unsafe."
	icon = 'icons/obj/items/guns/gimmick.dmi'
	icon_state = "raygun"
	item_state = "raygun"
	force = 5
	can_dual_wield = 0
	muzzle_flash = "muzzle_flash_laser"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/raybeam)
		projectiles = list(new/datum/projectile/energy_bolt/raybeam)
		..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null) //it's experimental for a reason; use at your own risk!
		if (canshoot(user))
			if (GET_COOLDOWN(src, "raygun_cooldown"))
				return
			if (prob(30))
				user.TakeDamage("chest", 0, rand(5, 15), 0, DAMAGE_BURN, 1)
				boutput(user, SPAN_ALERT("This piece of junk Ray Gun backfired! Ouch!"))
				user.do_disorient(stamina_damage = 20, disorient = 3 SECONDS)
				ON_COOLDOWN(src, "raygun_cooldown", 2 SECONDS)
		return ..(target, start, user)

// Makeshift Laser Rifle
#define HEAT_REMOVED_PER_PROCESS 30
#define FIRE_THRESHOLD 125
TYPEINFO(/obj/item/gun/energy/makeshift)
	mats = 0

/obj/item/gun/energy/makeshift
	name = "makeshift laser rifle"
	icon = 'icons/obj/items/guns/energy64x32.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "makeshift-energy"
	item_state = "makeshift_laser"
	wear_state = "makeshift_laser"
	c_flags = ONBACK
	cell_type = null
	can_swap_cell = FALSE
	rechargeable = FALSE
	force = 7
	two_handed = TRUE
	can_dual_wield = FALSE
	desc = "A laser rifle cobbled together from various appliances, Prone to overheating."
	muzzle_flash = "muzzle_flash_phaser"
	charge_icon_state = "laser"
	spread_angle = 10
	shoot_delay = 5 DECI SECONDS
	///What light source we use for the rifle
	var/obj/item/light/tube/our_light
	///What battery this gun uses
	var/obj/item/cell/our_cell
	///How much heat this weapon has after firing, the weapon breaks if this gets too high
	var/heat = 0
	///What step of repair are we on if we have broken? 0 = functional
	var/heat_repair = 0

	proc/attach_cell(obj/item/cell/C, mob/user)
		if (user)
			user.u_equip(C)
		RegisterSignal(C, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(remove_cell))
		our_cell = C
		our_cell.set_loc(src)
		our_cell.AddComponent(/datum/component/power_cell, our_cell.maxcharge, our_cell.charge, our_cell.genrate, 0, FALSE)
		SEND_SIGNAL(src, COMSIG_CELL_SWAP, our_cell)
		UpdateIcon()

	proc/attach_light(obj/item/light/tube/T, mob/user)
		if (user)
			user.u_equip(T)
		our_light = T
		our_light.set_loc(src)
		UpdateIcon()
		var/datum/projectile/laser/makeshift/new_laser = new /datum/projectile/laser/makeshift
		new_laser.color_icon = rgb(our_light.color_r * 255, our_light.color_g * 255, our_light.color_b * 255)
		new_laser.color_red = our_light.color_r
		new_laser.color_green = our_light.color_g
		new_laser.color_blue = our_light.color_b
		set_current_projectile(new_laser)

	proc/do_explode()
		explosion(src, get_turf(src), -1, -1, 1, 2)
		qdel(src)

	proc/finish_repairs(obj/item/cable_coil/C, mob/user)
		C.change_stack_amount(-10)
		heat_repair = 0
		playsound(src, 'sound/effects/pop.ogg', 50, TRUE)
		src.icon_state = "makeshift-energy"
		UpdateIcon()

	proc/add_heat(var/heat_to_add, var/mob/user)
		heat += heat_to_add
		if (heat >= FIRE_THRESHOLD)
			if (user)
				boutput(user,SPAN_ALERT("[src] bursts into flame!"))
			if (our_cell)
				our_cell.use(our_cell.charge)
				SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
			elecflash(get_turf(src), 1, 3)
			our_light.light_status = LIGHT_BURNED
			our_light.update()
			heat_repair = 1
			src.icon_state = "makeshift-burnt-1"
			heat += FIRE_THRESHOLD // spicy!
			UpdateIcon()

	proc/remove_cell()
		var/obj/item/cell/C = our_cell
		C.UpdateIcon()
		UnregisterSignal(C, COMSIG_PARENT_PRE_DISPOSING)
		var/datum/component/power_cell/comp = C.GetComponent(/datum/component/power_cell)
		comp.UnregisterFromParent()
		comp.RemoveComponent()
		our_cell = null
		// need to reset our component or else a runtime occurs
		var/datum/component/cell_holder/holder = src.GetComponent(/datum/component/cell_holder)
		holder.cell = null
		UpdateIcon()

	emp_act()
		if (our_cell)
			src.visible_message(SPAN_ALERT("[src]'s cell violently overheats!"))
			src.add_heat(FIRE_THRESHOLD)

	New()
		processing_items |= src
		set_current_projectile(new/datum/projectile/laser/makeshift)
		projectiles = list(current_projectile)
		..()

	Exited(Obj, newloc)
		var/obj/item/cell/C = Obj
		if (istype(C) && !QDELETED(C))
			src.remove_cell()
		. = ..()


	process()
		if (heat > 0)
			if (heat > FIRE_THRESHOLD)
				var/mob/living/victim = src.loc
				if (istype(victim))
					victim.changeStatus("burning", 7 SECONDS)
					if (!ON_COOLDOWN(victim, "makeshift_burn", 5 SECONDS))
						boutput(victim, SPAN_ALERT("You are set on fire due to the extreme temperature of [src]!"))
						victim.emote("scream")
			heat = max(0, heat - HEAT_REMOVED_PER_PROCESS)
			UpdateIcon()
		return

	canshoot(mob/user)
		if (heat_repair != 0)
			boutput(user,SPAN_ALERT("[src] will need repairs before being able to function!"))
			return FALSE
		if (!our_light)
			boutput(user,SPAN_ALERT("[src] needs a light source to function!"))
			return FALSE
		else if (our_light.light_status != LIGHT_OK)
			boutput(user,SPAN_ALERT("[src] has no reaction when you pull the trigger!"))
			return FALSE
		else
			return ..()

	attackby(obj/item/W, mob/user, params)
		if (heat < FIRE_THRESHOLD)
			if(heat_repair) // gun machine broke, we need to repair it
				if (issnippingtool(W) && heat_repair == 1)
					boutput(user,SPAN_NOTICE("You remove the burnt wiring from [src]."))
					playsound(src, 'sound/items/Wirecutter.ogg', 50, TRUE)
					heat_repair++
					src.icon_state = "makeshift-burnt-2"
					UpdateIcon()
					return
				else if (istype(W, /obj/item/cable_coil) && heat_repair == 2)
					if (W.amount >= 10)
						SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, /obj/item/gun/energy/makeshift/proc/finish_repairs,\
						list(W,user), W.icon, W.icon_state, SPAN_NOTICE("[user] replaces the burnt wiring within [src]."), null)
					else
						boutput(user,SPAN_NOTICE("You need at least 10 wire to repair the wiring."))
					return
			else if (iswrenchingtool(W) && our_cell)
				var/obj/item/removed_cell = our_cell
				SEND_SIGNAL(src, COMSIG_CELL_SWAP, null)
				boutput(user,SPAN_NOTICE("You disconnect [our_cell] from [src]."))
				playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)
				user.put_in_hand_or_drop(removed_cell)
				return
			else if (istype(W, /obj/item/cell) && !our_cell)
				user.u_equip(W)
				boutput(user,SPAN_NOTICE("You attach [W] to [src]."))
				attach_cell(W, user)
				return
			else if (issnippingtool(W) && our_light)
				boutput(user,SPAN_NOTICE("You remove the wiring attaching [our_light] to the barrel."))
				playsound(src, 'sound/items/Wirecutter.ogg', 50, TRUE)
				user.put_in_hand_or_drop(our_light)
				our_light = null
				UpdateIcon()
				return
			else if (istype(W, /obj/item/light/tube) && !our_light)
				boutput(user,SPAN_NOTICE("You place [W] inside of the barrel and redo the wiring."))
				playsound(src, 'sound/effects/pop.ogg', 50, TRUE)
				attach_light(W, user)
				UpdateIcon()
				return
			..()
		else
			boutput(user,SPAN_NOTICE("Attempting to work on [src] while its on fire might be a bad idea..."))
			return

	get_desc()
		. = ..()
		if (!heat_repair)
			if (!our_cell && isnull(cell_type))
				. += SPAN_ALERT("<b> [src] is lacking a power source!</b>")
			if (!our_light)
				. += SPAN_ALERT("<b> [src] is lacking a light source!</b>")
			else if(our_light.light_status != LIGHT_OK)
				. += SPAN_ALERT("<b> [src]'s light source is nonfunctional!</b>")
		else
			. += SPAN_ALERT("<b> [src] is broken and requires repairs!</b>")

	get_help_message(dist, mob/user)
		switch(src.heat_repair)
			if(0)
				if(cell_type)
					; //noop
				else if(!our_cell)
					. += "You can use a large energy cell on [src] to attach it to the gun."
				else
					. += "You can use a <b>wrench</b> to remove [src]'s energy cell."
				if(!our_light)
					. += "You can use a light tube on [src] to insert it into the gun."
				else
					. += "You can use <b>wirecutters</b> to remove [src]'s light tube."
			if(1)
				. = "You can use <b>wirecutters</b> to remove the burnt wiring."
			if(2)
				. = "You can add 10 wire to replace the wiring."

	attack_self(mob/user)
		var/I = tgui_input_number(user, "Input a firerate (In deciseconds)", "Timer Adjustment", shoot_delay, 10, 2)
		if (!I || BOUNDS_DIST(src, user) > 0)
			return
		shoot_delay = I
		boutput(user, SPAN_NOTICE("You adjust [src] to fire every [I / 10] seconds."))

	update_icon()
		if (our_cell)
			var/image/overlay_image
			if (istype(our_cell, /obj/item/cell/artifact))
				var/obj/item/cell/artifact/C = our_cell
				var/datum/artifact/powercell/AS = C.artifact
				var/datum/artifact_origin/AO = AS.artitype
				overlay_image = SafeGetOverlayImage("gun_cell", src.icon, "makeshift-[AO.name]")
			else
				overlay_image = SafeGetOverlayImage("gun_cell", src.icon, "makeshift-[our_cell.icon_state]")
			src.UpdateOverlays(overlay_image, "gun_cell")
		else
			src.UpdateOverlays(null, "gun_cell")

		if (our_light)
			var/image/overlay_image = SafeGetOverlayImage("gun_light", src.icon, "makeshift-light")
			src.UpdateOverlays(overlay_image, "gun_light")
		else
			src.UpdateOverlays(null, "gun_light")

		if (heat > FIRE_THRESHOLD)
			var/image/overlay_image = SafeGetOverlayImage("gun_smoke", src.icon, "makeshift-burn")
			src.UpdateOverlays(overlay_image, "gun_smoke")
		else if (heat > 70)
			var/image/overlay_image = SafeGetOverlayImage("gun_smoke", src.icon, "makeshift-smoke")
			src.UpdateOverlays(overlay_image, "gun_smoke")
		else
			src.UpdateOverlays(null, "gun_smoke")
		..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (canshoot(user))
			if (our_light.rigged) // bad idea
				src.visible_message(SPAN_ALERT("[src]'s light tube violently explodes!"))
				do_explode()
				return
			var/datum/projectile/laser/makeshift/possible_laser
			if (istype(possible_laser))
				src.add_heat(rand(possible_laser.heat_low, possible_laser.heat_high), user)
			else // allow varedit shenanigans
				src.add_heat(rand(15,20), user)
			UpdateIcon()
			our_cell?.use(current_projectile.cost)
		return ..(target, start, user)

/obj/item/gun/energy/makeshift/spawnable // for testing purposes

	New()
		..()
		var/obj/item/cell/supercell/charged/C = new /obj/item/cell/supercell/charged
		C.UpdateIcon() // fix visual bug
		src.attach_cell(C)
		var/obj/item/light/tube/T = new /obj/item/light/tube
		src.attach_light(T)


/obj/item/gun/energy/lasergat
	name = "\improper HAFGAN Mod.93R Repeating Laser"
	rechargeable = 0
	icon_state = "burst_laser_idle"
	cell_type = /obj/item/ammo/power_cell/lasergat
	desc = "Introduced to compete with the Clock line of military sidearms. The Mod. 93R repeating laser masked early laser tech's heat problems with expendable liquid coolant cartridges, whose off-gassing caused unpredictable recoil that made it widely unpopular."
	item_state = "egun-kill"
	force = 5
	add_residue = 1 // this is unique in that it spews energy-gun-gas or something
	muzzle_flash = "muzzle_flash_elec"
	uses_charge_overlay = TRUE
	charge_icon_state = "burst_laser"
	shoot_delay = 4
	spread_angle = 2
	recoil_enabled = TRUE
	recoil_max = 50
	recoil_inaccuracy_max = 10
	icon_recoil_enabled = TRUE

	restrict_cell_type = /obj/item/ammo/power_cell/lasergat
	New()
		set_current_projectile(new/datum/projectile/laser/lasergat/burst)
		projectiles = list(current_projectile)
		..()
	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (canshoot(user))
			..()
			FLICK("burst_laser", src)
			FLICK(src.charge_image, src.charge_image)
			SPAWN(6 DECI SECONDS)
				playsound(user, 'sound/effects/tinyhiss.ogg', 60, TRUE)
			return
		..()

	update_icon()
		if (!canshoot())
			src.icon_state = "burst_laser_empty"
		else
			src.icon_state = "burst_laser_idle"
		..()
	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

/obj/item/gun/energy/bubble_gun
	name = "Bubble Max XSTREAM"
	icon_state = "phaser-tiny"
	item_state = "phaser"
	force = 4
	desc = "The foremost name in bubble based warfare."
	muzzle_flash = "muzzle_flash_launch"
	cell_type = /obj/item/ammo/power_cell
	w_class = W_CLASS_SMALL
	var/bubble_type = /datum/projectile/special/bubble

	New()
		. = ..()
		color = list(0,0,1,1,0,0,0,1,0)
		set_current_projectile(new bubble_type)
		projectiles = list(current_projectile)

/obj/item/gun/energy/bubble_gun/bomb
	name = "Bubble Bomb Max ULTRAimpact"
	desc = "Looks to be a modified Bubble Max XSTREAM. There appears to be a warning label on the side, \"Fire at a distance.\""
	bubble_type = /datum/projectile/special/bubble/bomb
	shoot_delay = 50

/obj/item/gun/energy/bubble_gun/bomb/turf_safe
	bubble_type = /datum/projectile/special/bubble/bomb/turf_safe

#undef HEAT_REMOVED_PER_PROCESS
#undef FIRE_THRESHOLD


TYPEINFO(/obj/item/gun/energy/lasershotgun)
	mats = null
/obj/item/gun/energy/lasershotgun
	name = "Mod. 77 'Nosaxa'"
	cell_type = /obj/item/ammo/power_cell/high_power
	icon = 'icons/obj/items/guns/energy48x32.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "lasershotgun"
	desc = "Originally developed as a mining laser, the Nosaxa was quickly rebranded after the dangers of firing it in confined spaces were discovered."
	item_state = "lasershotgun"
	c_flags = ONBACK
	force = 10
	two_handed = TRUE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_red"
	charge_icon_state = "lasershotgun"
	var/overheated = FALSE
	var/shotcount = 0

	New()
		set_current_projectile(new/datum/projectile/special/spreader/tasershotgunspread/laser)
		projectiles = list(new/datum/projectile/special/spreader/tasershotgunspread/laser)
		..()

	canshoot(mob/user)
		return(..() && !src.overheated)

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (!shoot_check(user))
			return
		..()
		if (src.shotcount++ >= 1)
			src.overheat()

	shoot_point_blank(atom/target, mob/user, second_shot)
		if (!shoot_check(user))
			return
		..()
		if (src.shotcount++ >= 1)
			src.overheat()

	proc/overheat()
		src.overheated = TRUE
		SPAWN(0.3 SECONDS)
			playsound(src, 'sound/impact_sounds/burn_sizzle.ogg')
		src.UpdateParticles(new /particles/steam_leak, "overheat_steam", plane = src.plane + (src.plane == PLANE_HUD ? 1 : 0))

	dropped(mob/user)
		. = ..()
		for (var/key in src.particle_refs)
			var/obj/effects/particle_holder/holder = src.particle_refs[key]
			holder.plane = src.plane

	pickup(mob/user)
		. = ..()
		for (var/key in src.particle_refs)
			var/obj/effects/particle_holder/holder = src.particle_refs[key]
			holder.plane = PLANE_ABOVE_HUD

	proc/shoot_check(var/mob/user)
		if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, amount) & CELL_INSUFFICIENT_CHARGE)
			boutput(user, "<span class ='notice'>You are out of energy!</span>")
			return FALSE

		if (GET_COOLDOWN(src, "rack delay"))
			boutput(user, "<span class ='notice'>Still cooling!</span>")
			return FALSE

		if (src.overheated)
			boutput(user, "<span class='notice'>You need to vent before you can fire!</span>")
			playsound(src.loc, 'sound/machines/button.ogg', 50, 1, -5)
			return FALSE
		return TRUE

	attack_self(mob/user as mob)
		..()
		src.rack(user)

	proc/rack(var/mob/user)
		if (src.overheated)
			if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, amount) & CELL_INSUFFICIENT_CHARGE)
				boutput(user, "<span class ='notice'>You are out of energy!</span>")
			else
				boutput(user, "<span class='notice'>You release some heat from the shotgun!</span>")
				playsound(src, 'sound/effects/steamrelease.ogg', 70, 1)
				ON_COOLDOWN(src, "rack delay", 1 SECONDS)
				SPAWN(1 SECOND)
					src.overheated = FALSE
					src.shotcount = 0
					src.UpdateParticles(null, "overheat_steam")
