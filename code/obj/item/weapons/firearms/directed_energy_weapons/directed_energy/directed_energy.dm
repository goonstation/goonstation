////////////////////////////////////////// Directed energy weapon child //////////////////////////////////////////////////
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

/////////////////////////////////////LASERGUN
/obj/item/firearm/energy/laser_gun
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
TYPEINFO(/obj/item/firearm/energy/antique)
	analyser_flags = ANALYSER_BLACKLIST
/obj/item/firearm/energy/antique
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

////////////////////////////////////TASERGUN
/obj/item/firearm/energy/taser_gun
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

/obj/item/firearm/energy/taser_gun/bouncy
	name = "richochet taser gun"
	desc = "A modified Five Points Armory taser gun. This one appears to be capable of firing ricochet stun charges."

	New()
		..()
		set_current_projectile(new/datum/projectile/energy_bolt/bouncy)
		projectiles = list(current_projectile)

//////////////////////////////////////// Phaser
/obj/item/firearm/energy/phaser_gun
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

/obj/item/firearm/energy/phaser_gun/extended_mag
	cell_type = /obj/item/ammo/power_cell/med_plus_power

TYPEINFO(/obj/item/firearm/energy/phaser_small)
	mats = 20

/obj/item/firearm/energy/phaser_small
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

TYPEINFO(/obj/item/firearm/energy/phaser_huge)
	mats = list("metal" = 15,
				"metal_dense" = 10,
				"conductive_high" = 10,
				"energy_high" = 15,
				"crystal" = 10)
/obj/item/firearm/energy/phaser_huge
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

/obj/item/firearm/energy/phaser_smg
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

/obj/item/firearm/energy/phaser_smg/extended_mag
	cell_type = /obj/item/ammo/power_cell/med_plus_power

////////////////////////////////////////EGun
TYPEINFO(/obj/item/firearm/energy/egun)
	mats = list("metal" = 15,
				"conductive" = 5,
				"energy" = 5)
/obj/item/firearm/energy/egun
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
		src.verbs -= /obj/item/firearm/energy/egun/verb/claim_lawbringer
		src.verbs -= /obj/item/firearm/energy/egun/verb/claim_sword
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

	pickup(mob/user)
		. = ..()
		if (user.mind?.assigned_role == "Head of Security")
			src.verbs |= /obj/item/firearm/energy/egun/verb/claim_lawbringer
		else if (user.mind?.assigned_role == "Captain")
			src.verbs |= /obj/item/firearm/energy/egun/verb/claim_sword

	dropped(mob/user)
		. = ..()
		src.verbs -= /obj/item/firearm/energy/egun/verb/claim_lawbringer
		src.verbs -= /obj/item/firearm/energy/egun/verb/claim_sword

	verb/claim_lawbringer()
		set src in usr
		set category = "Local"
		set name = "Convert to Lawbringer"

		var/datum/jobXpReward/reward = global.xpRewards["The Lawbringer"]
		reward.try_claim(usr, FALSE)

	verb/claim_sword()
		set src in usr
		set category = "Local"
		set name = "Convert to Sabre"

		var/datum/jobXpReward/reward = global.xpRewards["Commander's Sabre"]
		reward.try_claim(usr, FALSE)

	proc/noreward()
		src.nojobreward = 1

	captain
		desc = "The Five Points Armory Energy Gun. Double emitters with switchable fire modes, for stun bolts or lethal laser fire. Decorated to match standard NT captain attire."
		icon_state = "energy-cap"

	head_of_security
		desc = "The Five Points Armory Energy Gun. Double emitters with switchable fire modes, for stun bolts or lethal laser fire. 'HOS' is engraved in the side."
		icon_state = "energy-hos"

		New()
			. = ..()
			src.verbs -= /obj/item/firearm/energy/egun/verb/claim_sword

TYPEINFO(/obj/item/firearm/energy/egun_jr)
	analyser_flags = ANALYSER_BLACKLIST

/obj/item/firearm/energy/egun_jr
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
/obj/item/firearm/energy/ntgun
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
/obj/item/firearm/energy/tasershotgun
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

//////////////////////// Alastor

TYPEINFO(/obj/item/firearm/energy/alastor)
	analyser_flags = parent_type::analyser_flags | ANALYSER_SYNDIE_ONLY
	mats = list("metal_dense" = 15,
				"conductive_high" = 10,
				"energy_high" = 10)
/obj/item/firearm/energy/alastor
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

/obj/item/firearm/energy/optio1
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

TYPEINFO(/obj/item/firearm/energy/signifer2)
	mats = list("energy_high" = 15,
				"conductive_high" = 15,
				"metal_superdense" = 20)
/obj/item/firearm/energy/signifer2
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

TYPEINFO(/obj/item/firearm/energy/cornicen3)
	mats = list("iridiumalloy" = 50,
				"starstone" = 30,
				"plutonium" = 25,
				"electrum" = 50,
				"exoweave" = 5)
/obj/item/firearm/energy/cornicen3
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

TYPEINFO(/obj/item/firearm/energy/vexillifer4)
	mats = list("iridiumalloy" = 50,
				"starstone" = 10,
				"metal_superdense" = 150,
				"crystal_dense" = 100,
				"conductive_high" = 100,
				"energy_extreme" = 50)
/obj/item/firearm/energy/vexillifer4
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

/obj/item/firearm/energy/tasersmg
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
/obj/item/firearm/energy/raygun
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
TYPEINFO(/obj/item/firearm/energy/makeshift)
	analyser_flags = ANALYSER_BLACKLIST

/obj/item/firearm/energy/makeshift
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
		if(C?.use(10))
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
						SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, /obj/item/firearm/energy/makeshift/proc/finish_repairs,\
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

/obj/item/firearm/energy/makeshift/spawnable // for testing purposes

	New()
		..()
		var/obj/item/cell/supercell/charged/C = new /obj/item/cell/supercell/charged
		C.UpdateIcon() // fix visual bug
		src.attach_cell(C)
		var/obj/item/light/tube/T = new /obj/item/light/tube
		src.attach_light(T)


/obj/item/firearm/energy/lasergat
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

TYPEINFO(/obj/item/firearm/energy/lasershotgun)
	analyser_flags = ANALYSER_BLACKLIST
/obj/item/firearm/energy/lasershotgun
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
		if (src.shotcount > 0 && !ON_COOLDOWN(src, "rack delay", 1 SECONDS))
			boutput(user, "<span class='notice'>You release some heat from the shotgun!</span>")
			playsound(src, 'sound/effects/steamrelease.ogg', 70, 1)
			SPAWN(1 SECOND)
				src.overheated = FALSE
				src.shotcount = 0
				src.UpdateParticles(null, "overheat_steam")
