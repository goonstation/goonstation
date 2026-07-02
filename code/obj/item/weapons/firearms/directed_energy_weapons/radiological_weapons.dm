///////////////////////////////////////Particle Blasters
TYPEINFO(/obj/item/firearm/energy/blaster_pistol)
	analyser_flags = ANALYSER_BLACKLIST

/obj/item/firearm/energy/blaster_pistol
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

TYPEINFO(/obj/item/firearm/energy/blaster_smg)
	analyser_flags = ANALYSER_BLACKLIST

/obj/item/firearm/energy/blaster_smg
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

/obj/item/firearm/energy/blaster_carbine
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

/obj/item/firearm/energy/blaster_cannon
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
	analyser_flags = ANALYSER_BLACKLIST

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

///Crossbow that fires irradiating neutron projectiles like the nuclear reactor
///DEBUG ITEM - don't actually use this for things. Unless you really want to, or it might be funny.
TYPEINFO(/obj/item/firearm/energy/neutron)
	analyser_flags = parent_type::analyser_flags | ANALYSER_SYNDIE_ONLY
/obj/item/firearm/energy/neutron
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
	silenced = 1
	custom_cell_max_capacity = 100

	New()
		set_current_projectile(new/datum/projectile/neutron(50))
		projectiles = list(current_projectile)
		..()
