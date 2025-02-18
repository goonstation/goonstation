ABSTRACT_TYPE(/obj/item/gun/kinetic)
/obj/item/gun/kinetic
	name = "kinetic weapon"
	icon = 'icons/obj/items/guns/kinetic.dmi'
	item_state = "gun"
	m_amt = 2000
	camera_recoil_sway_min = 5 // kinetics can be more shuddery than lasers
	recoil_inaccuracy_max = 10 // +10 degrees of seperation at max recoil
	var/obj/item/ammo/bullets/ammo = null
	/// How much ammo can this gun hold? Don't make this null (Convair880).
	var/max_ammo_capacity = 1
	/// Can be a list too. The .357 Mag revolver can also chamber .38 Spc rounds, for instance (Convair880).
	var/ammo_cats = list()
	/// Does this gun have a special icon state for having no ammo lefT?
	var/has_empty_state = FALSE
	/// Does this gun have a special icon state it should flick to when fired?
	var/has_fire_anim_state = FALSE
	var/fire_anim_state = null
	/// Can this gun be affected by the [Helios] medal reward?
	var/gildable = FALSE
	/// Is this gun currently gilded by the [Helios] medal reward?
	var/gilded = FALSE
	/// Do we eject casings on firing, or on reload?
	var/auto_eject = FALSE
	/// If we don't automatically ejected them, we need to keep track (Convair880).
	var/casings_to_eject = 0
	/// What's the default magazine used in this gun? Set this in place of putting the type in New()
	var/default_magazine = null
	/// Assoc list of magazine types, standard ammo first, special ammo second
	var/list/ammobag_magazines = list()
	/// Can only special-ammo ammobags restock these?
	var/ammobag_spec_required = FALSE
	/// How many charges it costs an ammobag to fabricate ammo for this gun
	var/ammobag_restock_cost = 1
	/// Does this gun have a special sound it makes when loading instead of the assigned ammo sound?
	var/sound_load_override = null

	/// How many bullets get moved into this gun per action?
	var/max_move_amount = -1
	/// What's the fastest speed we can reload this? 2 deciseconds is the default spam limiter.
	var/reload_cooldown = 2 DECI SECONDS
	/// Does this gun add gunshot residue when fired? Kinetic guns should (Convair880).
	add_residue = TRUE

	/// Can you use the gun on ammo to reload?
	var/allowReverseReload = TRUE

	/// Can you Drag & Drop ammo onto the gun to reload?
	var/allowDropReload = TRUE

	/// `icon_state` of the muzzle flash of the gun (if any)
	muzzle_flash = "muzzle_flash"

	// caliber list: update as needed
	// 0.22 - pistols
	// 0.308 - rifles
	// 0.357 - revolver
	// 0.38 - detective
	// 0.41 - derringer
	// 0.72 - shotgun shell, 12ga
	// 1.57 - 40mm shell
	// 1.58 - RPG-7 (Tube is 40mm too, though warheads are usually larger in diameter.)

	New()
		if(silenced)
			current_projectile.shot_sound = 'sound/weapons/suppressed_22.ogg'
		..()
		src.UpdateIcon()

	examine()
		. = ..()
		if (src.ammo && (src.ammo.amount_left > 0))
			var/datum/projectile/ammo_type = src.ammo.ammo_type
			. += "There are [src.ammo.amount_left][(ammo_type.material && istype(ammo_type.material, /datum/material/metal/silver)) ? " silver " : " "]bullets of [src.ammo.sname] left!"
		else
			. += "There are 0 bullets left!"
		if (current_projectile)
			. += "Each shot will currently use [src.current_projectile.cost] bullets!"
		else
			. += SPAN_ALERT("*ERROR* No output selected!")

	update_icon()

		if (src.ammo)
			inventory_counter?.update_number(src.ammo.amount_left)
		else
			inventory_counter?.update_text("-")

		if(src.has_empty_state)
			if (src.ammo.amount_left < 1 && !findtext(src.icon_state, "-empty")) //sanity check
				src.icon_state = "[src.icon_state]-empty"
			else
				src.icon_state = replacetext(src.icon_state, "-empty", "")
		return 0

	canshoot(mob/user)
		if(src.ammo && src.current_projectile)
			if(src.ammo:amount_left >= src.current_projectile:cost)
				return 1
		return 0

	process_ammo(var/mob/user)
		if(src.ammo && src.current_projectile)
			if(src.ammo.use(current_projectile.cost))
				return 1
		if (src.click_sound)
			boutput(user, SPAN_ALERT(src.click_msg))
			if (!src.silenced)
				playsound(user, click_sound, 60, TRUE)
		return 0

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/item/ammo/bullets) && allowDropReload)
			src.Attackby(O, user)
		return ..()

	attackby(obj/item/ammo/bullets/b, mob/user)
		if(istype(b, /obj/item/ammo/bullets))
			if(ON_COOLDOWN(src, "reload_spam", src.reload_cooldown))
				return
			switch (src.ammo.loadammo(b,src))
				if(0)
					user.show_text("You can't reload this gun.", "red")
					return
				if(AMMO_RELOAD_INCOMPATIBLE)
					user.show_text("This ammo won't fit!", "red")
					return
				if(AMMO_RELOAD_SOURCE_EMPTY)
					user.show_text("There's no ammo left in [b.name].", "red")
					return
				if(AMMO_RELOAD_ALREADY_FULL)
					user.show_text("[src] is full!", "red")
					return
				if(AMMO_RELOAD_PARTIAL)
					user.visible_message(SPAN_ALERT("[user] reloads [src]."), SPAN_ALERT("There wasn't enough ammo left in [b.name] to fully reload [src]. It only has [src.ammo.amount_left] rounds remaining."))
					src.tooltip_rebuild = 1
					src.logme_temp(user, src, b) // Might be useful (Convair880).
					return
				if(AMMO_RELOAD_FULLY)
					user.visible_message(SPAN_ALERT("[user] reloads [src]."), SPAN_ALERT("You fully reload [src] with ammo from [b.name]. There are [b.amount_left] rounds left in [b.name]."))
					src.tooltip_rebuild = 1
					src.logme_temp(user, src, b)
					return
				if(AMMO_RELOAD_TYPE_SWAP)
					switch (src.ammo.swap(b,src))
						if(AMMO_SWAP_INCOMPATIBLE)
							user.show_text("This ammo won't fit!", "red")
							return
						if(AMMO_SWAP_SOURCE_EMPTY)
							user.visible_message(SPAN_ALERT("[user] reloads [src]."), SPAN_ALERT("You swap out the magazine. Or whatever this specific gun uses."))
						if(AMMO_SWAP_ALREADY_FULL)
							user.visible_message(SPAN_ALERT("[user] reloads [src]."), SPAN_ALERT("You swap [src]'s ammo with [b.name]. There are [b.amount_left] rounds left in [b.name]."))
					src.logme_temp(user, src, b)
					return
				if(AMMO_RELOAD_CAPPED)
					if(!ON_COOLDOWN(src, "reload_single_spam", 3 SECONDS))
						user.visible_message("<span class='alert'>[user] loads some ammo into [src].</span>", "<span class='alert'>You load [src] with ammo from [b.name]. There are [b.amount_left] rounds left in [b.name].</span>")
					src.tooltip_rebuild = TRUE
					src.logme_temp(user, src, b)

		else
			..()

	//attack_self(mob/user as mob)
	//	return

	attack_hand(mob/user)
	// Added this to make manual reloads possible (Convair880).

		if ((src.loc == user) && user.find_in_hand(src)) // Make sure it's not on the belt or in a backpack.
			src.add_fingerprint(user)
			if(ON_COOLDOWN(src, "reload_spam", 2 DECI SECONDS))
				return
			if (src.sanitycheck(0, 1) == 0)
				user.show_text("You can't unload this gun.", "red")
				return
			src.eject_magazine(user)
		return ..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	// Finished Cogwerks' former WIP system (Convair880).
		if (src.canshoot(user) && user.a_intent != "help" && user.a_intent != "grab")
			if (src.auto_eject)
				var/turf/T = get_turf(src)
				if(T)
					if (src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
						var/number_of_casings = max(1, src.current_projectile.shot_number)
						//DEBUG_MESSAGE("Ejected [number_of_casings] casings from [src].")
						for (var/i in 1 to number_of_casings)
							new src.current_projectile.casing(T, src.forensic_ID)
			else
				if (src.casings_to_eject < 0)
					src.casings_to_eject = 0
				src.casings_to_eject += src.current_projectile.shot_number
		. = ..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (src.canshoot(user) && !isghostdrone(user))
			if (src.auto_eject)
				var/turf/T = get_turf(src)
				if(T)
					if (src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
						var/number_of_casings = max(1, src.current_projectile.shot_number)
						//DEBUG_MESSAGE("Ejected [number_of_casings] casings from [src].")
						for (var/i in 1 to number_of_casings)
							new src.current_projectile.casing(T, src.forensic_ID)
			else
				if (src.casings_to_eject < 0)
					src.casings_to_eject = 0
				src.casings_to_eject += src.current_projectile.shot_number

		if (fire_animation)
			if(src.ammo?.amount_left >= 1)
				var/flick_state = src.has_fire_anim_state && src.fire_anim_state ? src.fire_anim_state : src.icon_state
				flick(flick_state, src)

		if(..() && istype(user.loc, /turf/space) || user.no_gravity)
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)

	proc/eject_magazine(mob/user)
		if (src.ammo.amount_left <= 0)
			// The gun may have been fired; eject casings if so.
			if ((src.casings_to_eject > 0) && src.current_projectile.casing)
				if (src.sanitycheck(1, 0) == 0)
					logTheThing(LOG_DEBUG, usr, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the casings_to_eject cap, aborting.")
					src.casings_to_eject = 0
					return
				else
					user.show_text("You eject [src.casings_to_eject] casings from [src].", "red")
					src.ejectcasings()
					playsound(src, src.ammo.sound_load, rand(30, 60), TRUE)
					return
			else
				user.show_text("[src] is empty!", "red")
				return

		// Make a copy here to avoid item teleportation issues.
		var/obj/item/ammo/bullets/ammoHand = new src.ammo.type
		ammoHand.amount_left = src.ammo.amount_left
		ammoHand.name = src.ammo.name
		ammoHand.icon = src.ammo.icon
		ammoHand.icon_state = src.ammo.icon_state
		ammoHand.ammo_type = src.ammo.ammo_type
		ammoHand.delete_on_reload = 1 // No duplicating empty magazines, please (Convair880).
		ammoHand.UpdateIcon()
		user.put_in_hand_or_drop(ammoHand)
		ammoHand.after_unload(user)

		// The gun may have been fired; eject casings if so.
		src.ejectcasings()
		src.casings_to_eject = 0

		src.ammo.amount_left = 0
		src.ammo.refillable = FALSE
		src.UpdateIcon()
		src.add_fingerprint(user)
		ammoHand.add_fingerprint(user)

		user.visible_message(SPAN_ALERT("[user] unloads [src]."), SPAN_ALERT("You unload [src]."))
		//DEBUG_MESSAGE("Unloaded [src]'s ammo manually.")
		return

	proc/ejectcasings()
		if ((src.casings_to_eject > 0) && src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
			var/turf/T = get_turf(src)
			if(T)
				//DEBUG_MESSAGE("Ejected [src.casings_to_eject] [src.current_projectile.casing] from [src].")
				while (src.casings_to_eject > 0)
					new src.current_projectile.casing(T, src.forensic_ID)
					src.casings_to_eject--
		return

	// Don't set this too high. Absurdly large reloads and item spawning can cause a lot of lag. (Convair880).
	proc/sanitycheck(var/casings = 0, var/ammo = 1)
		if (casings && (src.casings_to_eject > 30 || src.current_projectile.shot_number > 30))
			logTheThing(LOG_DEBUG, usr, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the casings_to_eject cap, aborting.")
			if (src.casings_to_eject > 0)
				src.casings_to_eject = 0
			return 0
		if (ammo && (src.max_ammo_capacity > 200 || src.ammo.amount_left > 200))
			logTheThing(LOG_DEBUG, usr, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the magazine cap, aborting.")
			return 0
		return 1

ABSTRACT_TYPE(/obj/item/gun/kinetic/single_action)
/obj/item/gun/kinetic/single_action
	// We need a separate uncocked state if a gun has a fire animation
	var/has_uncocked_state = FALSE
	var/hammer_cocked = FALSE

	// Handles the odd scenario of gilding and hammer cocking
	update_icon()
		. = ..()
		src.icon_state = src.gen_icon_state(FALSE)
		src.wear_state = src.gen_icon_state(TRUE)
		if (src.has_uncocked_state && src.fire_animation)
			src.has_fire_anim_state = TRUE
			src.fire_anim_state = src.gen_icon_state(TRUE)

	canshoot(mob/user)
		if (hammer_cocked)
			return ..()
		else
			return FALSE

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		. = ..()
		hammer_cocked = FALSE
		src.UpdateIcon()

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (hammer_cocked)
			boutput(user, SPAN_NOTICE("You gently lower the weapon's hammer!"))
		else
			boutput(user, SPAN_ALERT("You cock the hammer!"))
			playsound(user.loc, 'sound/weapons/gun_cocked_colt45.ogg', 70, 1)
		src.hammer_cocked = !src.hammer_cocked
		src.UpdateIcon()

	proc/gen_icon_state(ignore_hammer_state)
		var/state = "[initial(src.icon_state)]" + (src.gilded ? "-golden" : "")
		if (!ignore_hammer_state && src.hammer_cocked)
			state += "-c"
		// Gun is uncocked and has a separate uncock icon_state
		else if (!ignore_hammer_state && src.has_uncocked_state)
			state +="-uc"
		return state


ABSTRACT_TYPE(/obj/item/survival_rifle_barrel)
/obj/item/survival_rifle_barrel
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	var/caliber_name = ""
	var/rifle_icon_state = ""
	var/ammo_cats = list()
	var/max_ammo_capacity = 1
	var/default_magazine = null
	var/default_projectile = null
	var/recoil_strength = 6
	New()
		name = "[src.caliber_name] rifle barrel"
		desc = "An interchangable barrel for the Efnysien survival rifle. This one is designed to fire [src.caliber_name]."
		..()

	barrel_22
		caliber_name = ".22 LR"
		rifle_icon_state = "survival_rifle_22"
		ammo_cats = list(AMMO_PISTOL_22)
		max_ammo_capacity = 10
		default_magazine = /obj/item/ammo/bullets/bullet_22
		default_projectile = /datum/projectile/bullet/bullet_22
		recoil_strength = 6


	barrel_9mm
		caliber_name = "9x19mm Parabellum"
		rifle_icon_state = "survival_rifle_9mm"
		ammo_cats = list(AMMO_PISTOL_9MM_ALL)
		max_ammo_capacity = 15
		default_magazine = /obj/item/ammo/bullets/bullet_9mm
		default_projectile = /datum/projectile/bullet/bullet_9mm
		recoil_strength = 9

	barrel_556
		caliber_name = "5.56x45mm NATO"
		rifle_icon_state = "survival_rifle_556"
		ammo_cats = list(AMMO_AUTO_556)
		max_ammo_capacity = 20
		default_magazine = /obj/item/ammo/bullets/assault_rifle
		default_projectile = /datum/projectile/bullet/assault_rifle
		recoil_strength = 12

/obj/item/casing
	name = "bullet casing"
	desc = "A spent casing from a bullet of some sort."
	icon = 'icons/obj/items/casings.dmi'
	icon_state = "medium"
	w_class = W_CLASS_TINY
	burn_possible = FALSE

	small
		icon_state = "small"
		desc = "Seems to be a small pistol cartridge."
		New()
			..()
			SPAWN(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-small-0[rand(1,6)].ogg", 20, 0.1)

	medium
		icon_state = "medium"
		desc = "Seems to be a common revolver cartridge."
		New()
			..()
			SPAWN(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1)

	rifle
		icon_state = "rifle"
		desc = "Seems to be a rifle cartridge."
		New()
			..()
			SPAWN(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1, 0, 0.8)


	rifle_loud
		icon_state = "rifle"
		desc = "Seems to be a rifle cartridge."
		New()
			..()
			SPAWN(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-large-0[rand(1,4)].ogg", 25, 0.1)

	derringer
		icon_state = "medium"
		desc = "A fat and stumpy bullet casing. Looks pretty old."
		New()
			..()
			SPAWN(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1)

	deagle
		icon_state = "medium"
		desc = "An uncomfortably large pistol cartridge."
		New()
			..()
			SPAWN(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1, 0, 0.9)
	shotgun
		red
			icon_state = "shotgun_red"
			desc = "A red shotgun shell."

		blue
			icon_state = "shotgun_blue"
			desc = "A blue shotgun shell."

		orange
			icon_state = "shotgun_orange"
			desc = "An orange shotgun shell."

		gray
			icon_state = "shotgun_gray"
			desc = "An gray shotgun shell."

		pipe
			icon_state = "shotgun_pipe"
			desc = "A slightly scorched length of pipe with an open end."
		New()
			..()
			SPAWN(rand(4, 7))
				playsound(src.loc, "sound/weapons/casings/casing-shell-0[rand(1,7)].ogg", 20, 0.1)

	cannon
		icon_state = "rifle"
		desc = "A cannon shell."
		w_class = W_CLASS_SMALL
		New()
			..()
			SPAWN(rand(2, 4))
				playsound(src.loc, "sound/weapons/casings/casing-large-0[rand(1,4)].ogg", 35, 0.1, 0, 0.8)

	grenade
		w_class = W_CLASS_SMALL
		icon_state = "40mm"
		desc = "A 40mm grenade round casing. Huh."
		New()
			..()
			SPAWN(rand(3, 6))
				playsound(src.loc, "sound/weapons/casings/casing-xl-0[rand(1,6)].ogg", 15, 0.1)


/obj/item/casing/New(loc, forensic_ID)
	. = ..()
	src.pixel_y += rand(-12,12)
	src.pixel_x += rand(-12,12)
	src.set_dir(pick(alldirs))
	src.forensic_ID = forensic_ID

//no caliber and ALL
/obj/item/gun/kinetic/vgun
	name = "virtual pistol"
	desc = "This thing would be better if it wasn't such a piece of shit."
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "railgun"
	force = MELEE_DMG_PISTOL
	contraband = 0
	max_ammo_capacity = 200
	default_magazine = /obj/item/ammo/bullets/vbullet

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/vbullet)
		..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		var/turf/T = get_turf(src)

		if (!istype(T.loc, /area/sim))
			boutput(user, SPAN_ALERT("You can't use the guns outside of the combat simulation, fuckhead!"))
			return
		else
			..()

/obj/item/gun/kinetic/zipgun
	name = "zip gun"
	desc = "An improvised and unreliable gun."
	icon_state = "zipgun"
	force = MELEE_DMG_PISTOL
	contraband = 6
	ammo_cats = list(AMMO_PISTOL_ALL, AMMO_REVOLVER_ALL, AMMO_SMG_9MM, AMMO_TRANQ_ALL, AMMO_RIFLE_308, AMMO_AUTO_308, AMMO_AUTO_556, AMMO_CASELESS_G11, AMMO_FLECHETTE, AMMO_STAPLE)
	max_ammo_capacity = 2
	var/failure_chance = 6
	var/failured = 0
	default_magazine = /obj/item/ammo/bullets/staples
	icon_recoil_cap = 30
	New()

		ammo = new default_magazine
		ammo.amount_left = 1 // start empty
		set_current_projectile(new/datum/projectile/bullet/staple)
		..()

	set_current_projectile(datum/projectile/newProj)
		..()
		if(src.current_projectile.cost > 1)
			if(src.current_projectile.shot_number < src.current_projectile.cost)
				src.current_projectile.power = src.current_projectile.cost/src.current_projectile.shot_number
			src.current_projectile.cost = 1
		if(src.current_projectile.shot_number > 1)
			src.current_projectile.shot_number = 1


	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if(failured)
			if(canshoot(user))
				var/turf/T = get_turf(src)
				explosion(src, T,-1,-1,1,2)
				qdel(src)
			return
		if(ammo?.amount_left && current_projectile.power)
			failure_chance = clamp(round(current_projectile.power/2 - 9), 0, 33)
		if(canshoot(user) && prob(failure_chance)) // Empty zip guns had a chance of blowing up. Stupid (Convair880).
			failured = 1
			if(prob(failure_chance))	// Sometimes the failure is obvious
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)
				boutput(user, SPAN_ALERT("The [src]'s shodilly thrown-together [pick("breech", "barrel", "bullet holder", "firing pin", "striker", "staple-driver mechanism", "bendy metal part", "shooty-bit")][pick("", "...thing")] [pick("cracks", "pops off", "bends nearly in half", "comes loose")]!"))
			else						// Other times, less obvious
				playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
		..()
		return

/obj/item/gun/kinetic/survival_rifle
	name = "\improper Efnysien survival rifle"
	desc = "A semi-automatic rifle, renowned for it's easily convertible caliber, developed by Mabinogi Firearms Company. Popular with pilots and scouts."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "survival_rifle_22"
	item_state = "survival_rifle"
	wear_state = "survival_rifle"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_RIFLE
	c_flags = ONBACK
	contraband = 8
	two_handed = TRUE
	can_dual_wield = FALSE
	auto_eject = TRUE
	fire_animation = TRUE
	var/obj/item/survival_rifle_barrel/barrel = new /obj/item/survival_rifle_barrel/barrel_22

	New()
		src.set_barrel_stats(src.barrel)
		ammo = new default_magazine
		..()

	attackby(obj/item/b, mob/user)
		if (istype(b, /obj/item/survival_rifle_barrel))
			var/obj/item/survival_rifle_barrel/new_barrel = b
			src.try_swap_barrel(user, new_barrel, TRUE)
			return
		..()

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (istype(target, /obj/item/survival_rifle_barrel))
			var/obj/item/survival_rifle_barrel/new_barrel = target
			src.try_swap_barrel(user, new_barrel, FALSE)
			return
		..()

	proc/try_swap_barrel(var/mob/user, var/obj/item/survival_rifle_barrel/new_barrel, var/holding_barrel)
		if (istype(new_barrel, src.barrel.type))
			user.show_text("There's no point swapping the barrel. They're the same caliber!", "red")
			return
		// Eject the mag first so we don't dissapear ammo
		src.eject_magazine(user)

		// Swap the barrel objs
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("[user] begins swapping the barrel on [his_or_her(user)] [src].", "You begin swapping the barrel on \the [src].")
		SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, /obj/item/gun/kinetic/survival_rifle/proc/swap_barrel, list(user, new_barrel, holding_barrel), src.icon, src.icon_state,"[user] finishes swapping the barrel on [his_or_her(user)] [src].", null)
		return

	proc/swap_barrel(var/mob/user, var/obj/item/survival_rifle_barrel/new_barrel, var/holding_barrel)
		if (holding_barrel)
			// Drop the barrel if you're holding it, so we can set_loc on it
			user.drop_item()
		new_barrel.set_loc(src)
		user.put_in_hand_or_drop(src.barrel)
		src.barrel = new_barrel

		// Set the gun's stats to the new barrel
		src.set_barrel_stats(barrel)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

	proc/set_barrel_stats(var/obj/item/survival_rifle_barrel/barrel)
		src.icon_state = barrel.rifle_icon_state
		src.ammo_cats = barrel.ammo_cats
		src.max_ammo_capacity = barrel.max_ammo_capacity
		src.default_magazine = barrel.default_magazine
		src.recoil_strength = barrel.recoil_strength
		set_current_projectile(new barrel.default_projectile)
		src.projectiles = list(current_projectile)
		src.desc = desc = "A semi-automatic rifle, renowned for it's easily convertible caliber, developed by Mabinogi Firearms Company. It's currently fitted with a [src.barrel.name]."
		src.tooltip_rebuild = 1

/obj/item/gun/kinetic/revolver/vr
	icon = 'icons/effects/VR.dmi'

//0.22
/obj/item/gun/kinetic/faith
	name = "Faith"
	desc = "'Cause ya gotta have Faith. A custom upgrade to the the Auklet .22 pocket pistol from Cormorant Precision Arms."
	icon_state = "faith"
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_PISTOL_22)
	max_ammo_capacity = 4
	auto_eject = 1
	w_class = W_CLASS_SMALL
	muzzle_flash = null
	has_empty_state = 1
	default_magazine = /obj/item/ammo/bullets/bullet_22/faith
	fire_animation = TRUE
	recoil_strength = 4
	icon_recoil_cap = 30
	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/bullet_22)
		..()

/obj/item/gun/kinetic/silenced_22
	name = "\improper Orion silenced pistol"
	desc = "A small pistol with an integrated flash and noise suppressor, bearing the emblem of Sceptre Tactical Laboratories. Uses .22 rounds."
	icon_state = "silenced"
	w_class = W_CLASS_SMALL
	silenced = 1
	force = MELEE_DMG_PISTOL
	contraband = 4
	ammo_cats = list(AMMO_PISTOL_22)
	max_ammo_capacity = 10
	auto_eject = 1
	hide_attack = ATTACK_FULLY_HIDDEN
	muzzle_flash = null
	has_empty_state = 1
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/bullet_22HP
	ammobag_magazines = list(/obj/item/ammo/bullets/bullet_22, /obj/item/ammo/bullets/bullet_22HP)
	ammobag_restock_cost = 1
	recoil_strength = 3
	icon_recoil_cap = 30
	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/bullet_22/HP)
		..()


//0.308
/obj/item/gun/kinetic/minigun // it is now STRONK
	name = "\improper Alpha Hydrae minigun"
	desc = "The Almagest M134 Alpha Hydrae is a six-barrel rotary machine gun chambered in 7.62×51mm NATO. The nuclear option for suppressive fire."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "minigun"
	item_state = "heavy"
	force = MELEE_DMG_LARGE
	ammo_cats = list(AMMO_AUTO_308)
	max_ammo_capacity = 200 //its a minigun it can have some ammo
	two_handed = TRUE
	auto_eject = 0
	has_empty_state = 1
	spread_angle = 15 //15 degrees is a lot
	can_dual_wield = TRUE //if you can figure it out, you can do it
	fire_animation = TRUE
	recoil_strength = 12

	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD

	w_class = W_CLASS_BULKY
	default_magazine = /obj/item/ammo/bullets/minigun

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/minigun)
		AddComponent(/datum/component/holdertargeting/fullauto/ramping, 2.5, 0.4, 0.9) //you only get full auto, why would you burst fire with a minigun?
		..()

	setupProperties()
		..()
		setProperty("carried_movespeed", 1.5) //the addative slow down does not play nice with the full auto so you get this instead

/obj/item/gun/kinetic/akm
	name = "\improper AKM Assault Rifle"
	desc = "An old Cold War relic chambered in 7.62x39. Rusted, but not busted. Vast numbers were brought back into service for the Martian war."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "ak47"
	item_state = "ak47"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_RIFLE
	contraband = 8
	ammo_cats = list(AMMO_AUTO_762)
	spread_angle = 9
	shoot_delay = 3 DECI SECONDS
	max_ammo_capacity = 30
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	gildable = 1
	default_magazine = /obj/item/ammo/bullets/akm
	fire_animation = TRUE
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = ONBACK
	w_class = W_CLASS_BULKY
	ammobag_magazines = list(/obj/item/ammo/bullets/akm)
	ammobag_restock_cost = 3
	recoil_strength = 10

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/akm)
		..()


/obj/item/gun/kinetic/hunting_rifle
	name = "old hunting rifle"
	desc = "The Kittiwake .308 from Cormorant Precision Arms, a classic high-powered hunting and police rifle, reliable in almost any environment. This one shows years of use."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "ohr"
	item_state = "ohr"
	wear_state = "ohr" // prevent empty state from breaking the worn image
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBACK
	force = MELEE_DMG_RIFLE
	contraband = 8
	ammo_cats = list(AMMO_RIFLE_308)
	max_ammo_capacity = 4 // It's magazine-fed (Convair880).
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	has_empty_state = 1
	gildable = 1
	default_magazine = /obj/item/ammo/bullets/rifle_3006
	fire_animation = TRUE
	recoil_strength = 14
	recoil_max = 14
	recoil_inaccuracy_max = 20

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/rifle_3006)
		..()

/obj/item/gun/kinetic/dart_rifle
	name = "tranquilizer rifle"
	desc = "A veterinary tranquilizer rifle chambered in .308 caliber."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "tranq"
	item_state = "tranq"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBACK
	force = MELEE_DMG_RIFLE
	//contraband = 8
	ammo_cats = list(AMMO_TRANQ_308)
	max_ammo_capacity = 4 // It's magazine-fed (Convair880).
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	gildable = 1
	default_magazine = /obj/item/ammo/bullets/tranq_darts
	fire_animation = TRUE
	recoil_strength = 4

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/tranq_dart)
		..()

//9mm/0.355
/obj/item/gun/kinetic/clock_188
	desc = "A NATO-surplus 9mm sidearm, still popular with Frontier military-police and peacekeeping forces. Highly customizable, often issued with frangible rounds for use in pressurized compartments."
	name = "\improper Clock 188"
	icon_state = "glock"
	item_state = "glock"
	shoot_delay = 2
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_PISTOL_9MM_ALL)
	max_ammo_capacity = 18
	auto_eject = 1
	has_empty_state = 1
	gildable = 1
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/nine_mm_NATO
	recoil_stacking_enabled = TRUE
	recoil_strength = 6
	icon_recoil_cap = 30
	New()
		if (prob(70))
			icon_state = "glocktan"
			item_state = "glocktan"

		if(throw_return)
			default_magazine = /obj/item/ammo/bullets/nine_mm_NATO/boomerang
		ammo = new default_magazine

		set_current_projectile(new/datum/projectile/bullet/nine_mm_NATO)

		if(throw_return)
			projectiles = list(current_projectile)
		else
			projectiles = list(current_projectile, new/datum/projectile/bullet/nine_mm_NATO/auto)
			AddComponent(/datum/component/holdertargeting/fullauto, 1.2)
		..()

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/nine_mm_NATO/auto))
			spread_angle = 10
			shoot_delay = 4
		else
			spread_angle = 0
			shoot_delay = 2

/obj/item/gun/kinetic/clock_188/boomerang
	desc = "Jokingly called a \"Gunarang\" in some circles. Uses 9mm NATO rounds."
	name = "\improper Clock 180"
	force = MELEE_DMG_PISTOL
	throw_range = 10
	throwforce = 1
	throw_speed = 1
	throw_return = 1
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/nine_mm_NATO
	var/prob_clonk = 0

	throw_begin(atom/target)
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		var/mob/user = thr.user
		if(hit_atom == user)
			if(prob(prob_clonk))
				user.visible_message(SPAN_ALERT("<B>[user] fumbles the catch and accidentally discharges [src]!</B>"))
				src.ShootPointBlank(user, user)
				user.force_laydown_standup()
			else
				src.Attackhand(user)
			return
		else
			var/mob/M = hit_atom
			if(istype(M))
				var/mob/living/carbon/human/H = user
				if(istype(H) && istype(H.wear_suit, /obj/item/clothing/suit/security_badge))
					src.silenced = 1
					src.ShootPointBlank(M, M)
					M.visible_message(SPAN_ALERT("<B>[src] fires, hitting [M] point blank!</B>"))
					src.silenced = initial(src.silenced)

			prob_clonk = min(prob_clonk + 5, 100)
			SPAWN(1 SECONDS)
				prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)

	ntso // A Clock 180 that comes preloaded with 9mm rounds for NTSOs.
		desc = "Jokingly called a \"Gunarang\" in some circles. Uses 9mm rounds."

		New()
			..()
			default_magazine = /obj/item/ammo/bullets/bullet_9mm
			ammo = new default_magazine
			set_current_projectile(new/datum/projectile/bullet/bullet_9mm)
			projectiles = list(current_projectile)
			UpdateIcon()

/obj/item/gun/kinetic/uzi
	desc = "A stamped metal PDW, produced to respond to Mortian raids. A favorite of armed bodyguards, hired muscle, henchmen, and gangsters."
	name = "\improper MOR-30"
	icon_state = "uzi"
	item_state = "uzi"
	spread_angle = 8
	shoot_delay = 5
	has_empty_state = TRUE
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_SMG_9MM)
	max_ammo_capacity = 30
	auto_eject = TRUE
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/nine_mm_surplus/mag_mor
	icon_recoil_cap = 15
	tooltip_flags = REBUILD_USER
	get_desc(dist, mob/user)
		if (user.get_gang() != null)
			. += "For when you need MOR' DAKKA. Uses 9mm Surplus rounds."
		else
			. += "Its firemodes are labelled 'DAKKA' and 'MOR'... Uses 9mm Surplus rounds."

	New()
		ammo = new default_magazine

		set_current_projectile(new/datum/projectile/bullet/nine_mm_surplus/burst)
		projectiles = list(current_projectile, new/datum/projectile/bullet/nine_mm_surplus/auto)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.5)
		..()

	attack_self(mob/user)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/nine_mm_surplus/auto))
			spread_angle = 10
			shoot_delay = 4
		else
			spread_angle = 8
			shoot_delay = 5

	//warcrimes brought to you by bullets telling guns how to shoot!
	attackby(obj/item/ammo/bullets/b, mob/user)
		var/obj/previous_ammo = ammo
		var/mode_was_auto = current_projectile.fullauto_valid
		..()
		if(previous_ammo.type != ammo.type)  // we switched ammo types
			if(istype(ammo, /obj/item/ammo/bullets/nine_mm_surplus))
				if(mode_was_auto)
					set_current_projectile(new/datum/projectile/bullet/nine_mm_surplus/auto)
					projectiles = list(new/datum/projectile/bullet/nine_mm_surplus/burst, current_projectile)
				else
					set_current_projectile(new/datum/projectile/bullet/nine_mm_surplus/burst)
					projectiles = list(current_projectile, new/datum/projectile/bullet/nine_mm_surplus/auto)
			else if(istype(ammo, /obj/item/ammo/bullets/bullet_9mm/smg))
				if(mode_was_auto)
					set_current_projectile(new/datum/projectile/bullet/bullet_9mm/smg/auto)
					projectiles = list(new/datum/projectile/bullet/bullet_9mm/smg, current_projectile)
				else
					set_current_projectile(new/datum/projectile/bullet/bullet_9mm/smg)
					projectiles = list(current_projectile, new/datum/projectile/bullet/bullet_9mm/smg/auto)

/obj/item/gun/kinetic/greasegun
	name = "\improper Grease Gun"
	desc = "A really clunky stamped-metal SMG. Tons of these were mass-produced in Mars colony machine shops during the War, and many have ended up in the Frontier."
	icon_state = "grease"
	item_state = "grease"
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	spread_angle = 14
	shoot_delay = 5
	has_empty_state = TRUE
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_SMG_9MM)
	max_ammo_capacity = 30
	auto_eject = TRUE
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/nine_mm_surplus/mag_grease
	var/grease = 0 //guh
	icon_recoil_cap = 20

	New()
		if (prob(33))
			name = "\improper [pick ("Greafe","Grief","Greef","Griff","Greece")] Gun"
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/nine_mm_surplus/auto)
		var/datum/callback/delay_callback = new(src, PROC_REF(set_auto_delay))
		AddComponent(/datum/component/holdertargeting/fullauto/callback, 1.2, delay_callback)
		..()

	get_desc(dist, mob/user)
		if (grease == 0)
			. += "It's all seized up and could do with maintenance."
		else if (grease < 0)
			. += "It's, er, all sticky and covered glue. WHY is it covered with glue???"
		else
			. += "It's greasy, alright..."

	attack_self(mob/user as mob)
		if(ishuman(user))
			if(two_handed)
				setTwoHanded(0) //Go 1-handed.
				src.spread_angle = initial(src.spread_angle)
				icon_recoil_cap = initial(src.icon_recoil_cap)
				recoil_max = initial(src.recoil_max)
				icon_state = "grease"
			else
				if(!setTwoHanded(1)) //Go 2-handed.
					boutput(user, SPAN_ALERT("Can't switch to 2-handed while your other hand is full."))
				else
					icon_recoil_cap = 10
					icon_state = "greaseunfolded"
					recoil_max = 100 // double how easy it is to control
					src.spread_angle = 6
		..()

	reagent_act(reagent_id,volume)
		if ((reagent_id in list("oil","lube", "superlube", "grease", "badgrease", "fishoil")) && volume >= 5)
			grease = 15
		if (reagent_id == "spaceglue" && volume >= 5)
			grease = -30

	//copy pastes brought to you by bullets telling guns how to shoot!
	attackby(obj/item/ammo/bullets/b, mob/user)
		var/obj/previous_ammo = ammo
		..()
		if(previous_ammo.type != ammo.type)  // we switched ammo types
			if(istype(ammo, /obj/item/ammo/bullets/nine_mm_surplus))
				set_current_projectile(new/datum/projectile/bullet/nine_mm_surplus/auto)
			else if(istype(ammo, /obj/item/ammo/bullets/bullet_9mm/smg))
				set_current_projectile(new/datum/projectile/bullet/bullet_9mm/smg/auto)

	proc/set_auto_delay(delay)
		. = delay * 10
		if (grease > 0)
			. = 18 - (grease)
			grease--
		else if (grease < 0)
			. = 30
			grease++
		else
			. = clamp(. + rand(-8,8),10,26)
		. /= 10

/obj/item/gun/kinetic/draco
	name = "\improper Draco Pistol"
	desc = "A full size 7.62x39mm 'Pistol'. With no stock. You should shoot this in bursts."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "draco"
	item_state = "draco"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_RIFLE
	contraband = 8
	ammo_cats = list(AMMO_AUTO_762)
	spread_angle = 3
	shoot_delay = 3
	max_ammo_capacity = 30
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	gildable = 1
	default_magazine = /obj/item/ammo/bullets/akm/draco
	fire_animation = TRUE
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	w_class = W_CLASS_BULKY
	recoil_strength = 7
	recoil_stacking_enabled = TRUE
	recoil_stacking_max_stacks = 4 //make this thing go HARD if you hold it down
	recoil_stacking_amount = 3
	recoil_inaccuracy_max = 25
	recoil_max = 100 // can eat more recoil for worse effects
	icon_recoil_cap = 30


	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/draco)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.6)
		..()

/obj/item/gun/kinetic/draco/empty

	New()
		..()
		ammo.amount_left = 0
		UpdateIcon()

/obj/item/gun/kinetic/webley
	name = "Webley 'Holdout' Snubnose"
	desc = "A cut down Webley break-action revolver. There's some extra weight in the grip for spinning action."
	icon_state = "webleysnub"
	force = MELEE_DMG_REVOLVER
	ammo_cats = list(AMMO_WEBLEY)
	w_class = W_CLASS_SMALL
	fire_animation = TRUE
	has_fire_anim_state = TRUE
	fire_anim_state = "webleysnubfire"
	max_ammo_capacity = 6
	auto_eject = FALSE
	can_dual_wield = FALSE
	two_handed = FALSE
	add_residue = TRUE
	gildable = TRUE
	spread_angle = 2
	default_magazine = /obj/item/ammo/bullets/webley
	safe_spin = TRUE // so you dont shoot yourself drawing the gun

	HELP_MESSAGE_OVERRIDE({"If your hands are empty, drawing this gun from a pocket grants a brief, large firerate increase, at the cost of accuracy."})

	var/broke_open = FALSE
	var/locked_shut = FALSE // stop folk doing weird stuff while fanning the hammer
	var/shells_to_eject = 0

	New() //uses a special box of ammo that only starts with 2 shells to prevent issues with overloading
		ammo = new/obj/item/ammo/bullets/webley
		set_current_projectile(new/datum/projectile/bullet/webley)
		..()

	update_icon()
		. = ..()
		src.icon_state = "webleysnub" + (!src.broke_open ? "" : "open" )

	canshoot(mob/user)
		if (!src.broke_open)
			return TRUE
		..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (src.broke_open)
			boutput(user, SPAN_ALERT("You need to close [src] before you can fire!"))
		if (!src.broke_open && src.ammo.amount_left > 0)
			src.shells_to_eject++
		..()

	attack_self(mob/user)
		src.toggle_action(user)
		..()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/ammo/bullets) && !src.broke_open)
			boutput(user, SPAN_ALERT("You can't load rounds into the cylinder! You'll have to open [src] first!"))
			return
		..()

	attack_hand(mob/user)
		if (!src.broke_open && user.find_in_hand(src))
			boutput(user, SPAN_ALERT("[src] is still closed, you need to open the action to take the rounds out!"))
			return
		..()

	on_spin_emote(mob/living/carbon/human/user)
		if(src.broke_open) // Only allow spinning to close the gun, doesn't make as much sense spinning it open.
			src.toggle_action(user)
			user.visible_message(SPAN_ALERT("<b>[user]</b> snaps shut [src] with a [pick("spin", "twirl")]!"))
		..()
	attack_hand(mob/user)
		if (ishuman(loc))
			var/mob/living/carbon/human/H = src.loc
			if ( (H.l_store == src || H.r_store == src) && H.l_hand == null && H.r_hand == null)
				fan_the_hammer(user)
		..()

	proc/fan_the_hammer(mob/user)
		if (!ON_COOLDOWN(src, "twirl_spam", 2 SECONDS))
			src.on_spin_emote(user)
			animate_spin(src, prob(50) ? "L" : "R", 1, 0)
			locked_shut = TRUE
			shoot_delay = 2
			spread_angle = 15
			user.show_message(SPAN_ALERT("[user] whips \the [src] out of [his_or_her(user)] pocket, seating their free hand over the hammer!"), 1)
			src.current_projectile.power *= 0.7 //a full pelting puts you INCHES from death
			SPAWN (4 SECONDS)
				locked_shut = FALSE
				spread_angle = 2
				shoot_delay = 4
				src.current_projectile.generate_stats() //regenerate power

	proc/toggle_action(mob/user)
		if (locked_shut)
			return
		if (!src.broke_open)
			src.casings_to_eject = src.shells_to_eject

			if (src.casings_to_eject > 0) //this code exists because without it the gun ejects double the amount of shells
				src.ejectcasings()
				src.shells_to_eject = 0
		src.broke_open = !src.broke_open

		playsound(user.loc, 'sound/weapons/gunload_click.ogg', 15, TRUE)

		UpdateIcon()



/obj/item/gun/kinetic/american180
	name = "\improper Razorbill-180"
	desc = "A .22 submachine gun from Cormorant Precision Arms loaded with a huge pancake magazine, marketed towards max-security prison guards and security forces facing massed wave attacks."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "american180"
	item_state = "a180"
	spread_angle = 3
	shoot_delay = 1
	has_empty_state = FALSE // non detachable mag, for now...
	w_class = W_CLASS_BULKY
	force = MELEE_DMG_RIFLE
	ammo_cats = 0
	max_ammo_capacity = 177
	two_handed = TRUE
	auto_eject = TRUE
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/bullet_22/american_180
	recoil_max = 100

	eject_magazine(mob/user)
		user.show_message(SPAN_ALERT("They tell stories of how BORING these magazines are to load! Let's not do that."))
		return

	New()
		ammo = new default_magazine

		set_current_projectile(new/datum/projectile/bullet/bullet_22/a180)
		AddComponent(/datum/component/holdertargeting/fullauto, 0.6)
		..()

/obj/item/gun/kinetic/makarov
	name = "\improper PM Pistol"
	desc = "An time-proven semi-automatic, 9x18mm caliber service pistol, still produced by the Zvezda Design Bureau."
	icon_state = "makarov"
	item_state = "makarov"
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	contraband = 4
	ammo_cats = list(AMMO_PISTOL_9MM_SOVIET)
	max_ammo_capacity = 8
	shoot_delay = 2
	auto_eject = TRUE
	has_empty_state = TRUE
	fire_animation = TRUE
	gildable = TRUE
	default_magazine = /obj/item/ammo/bullets/nine_mm_soviet

	New()
		ammo = new default_magazine
		set_current_projectile(new /datum/projectile/bullet/nine_mm_soviet)
		..()

//medic primary
/obj/item/gun/kinetic/veritate
	desc = "A personal defence weapon, developed by Almagest Weapons Fabrication."
	name = "\improper Veritate PDW"
	icon_state = "vector"
	item_state = "glocksyn"
	shoot_delay = 1
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_FLECHETTE)
	max_ammo_capacity = 21
	auto_eject = 1
	has_empty_state = 1
	gildable = 0
	fire_animation = FALSE
	default_magazine = /obj/item/ammo/bullets/veritate
	ammobag_magazines = list(/obj/item/ammo/bullets/veritate)
	ammobag_restock_cost = 2

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/veritate)
		projectiles = list(current_projectile,new/datum/projectile/bullet/veritate/burst)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/veritate/burst/))
			spread_angle = 6
			shoot_delay = 3 DECI SECONDS
		else
			spread_angle = 0
			shoot_delay = 2 DECI SECONDS

/obj/item/gun/kinetic/lopoint
	desc = "Cheap and disposable, having a Lo-Point is the first step towards a life of crime. Just remember to throw it away when you're done."
	name = "Lo-Point"
	icon_state = "hipoint"
	item_state = "hipoint"
	shoot_delay = 4
	spread_angle = 3
	throwforce = 14 // literally throw it away
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_PISTOL_9MM)
	fire_animation = TRUE
	max_ammo_capacity = 10
	auto_eject = TRUE
	has_empty_state = TRUE
	gildable = FALSE
	default_magazine = /obj/item/ammo/bullets/bullet_9mm/lopoint

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/bullet_9mm)
		RegisterSignal(src, COMSIG_MOVABLE_HIT_THROWN, PROC_REF(selfdestruct))
		..()

	// teehee. get it? 'throw' it away?
	proc/selfdestruct(obj/item/parent, atom/target, mob/user, reach, params)
		if(!isliving(target) || src.ammo?.amount_left > 0)
			return
		var/mob/living/H = target
		H.changeStatus("knockdown", 3 SECONDS)
		H.force_laydown_standup()
		src.visible_message("<span class='alert'>The [src] hits [target] <b>hard</b>, shattering into dozens of tiny pieces!</span>")
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, TRUE)
		var/obj/decal/cleanable/gib = make_cleanable( /obj/decal/cleanable/machine_debris,src.loc)
		gib.streak_cleanable()
		qdel(src)


/obj/item/gun/kinetic/SMG_briefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "secure"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system. This one has a small hole in the side of it and the emblem of Sceptre Tactical Laboratories. Odd."
	force = MELEE_DMG_SMG
	ammo_cats = list(AMMO_9MM_ALL)
	max_ammo_capacity = 30
	auto_eject = 0

	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	object_flags = NO_ARM_ATTACH
	c_flags = ONBELT

	spread_angle = 2
	can_dual_wield = 0
	default_magazine = /obj/item/ammo/bullets/nine_mm_NATO
	var/cases_to_eject = 0
	var/open = FALSE


	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/nine_mm_NATO/burst)
		..()

	attack_hand(mob/user)
		if(!user.find_in_hand(src))
			..() //this works, dont touch it
		else if(open)
			.=..()
		else
			boutput(user, SPAN_ALERT("You can't unload the [src] while it is closed."))

	attackby(obj/item/ammo/bullets/b as obj, mob/user)
		if(open)
			.=..()
		else
			boutput(user, SPAN_ALERT("You can't access the gun inside the [src] while it's closed! You'll have to open the [src]!"))

	attack_self(mob/user)
		if(open)
			open = FALSE
			UpdateIcon()
			boutput(user, SPAN_ALERT("You close the [src]!"))
		else
			boutput(user, SPAN_ALERT("You open the [src]."))
			open = TRUE
			UpdateIcon()
			if (src.loc == user && user.find_in_hand(src)) // Make sure it's not on the belt or in a backpack.
				src.add_fingerprint(user)
				if (!src.sanitycheck(0, 1))
					user.show_text("You can't unload this gun.", "red")
					return
				if (src.casings_to_eject > 0 && src.current_projectile.casing)
					if (!src.sanitycheck(1, 0))
						logTheThing(LOG_DEBUG, user, "<b>Convair880</b>: [user]'s gun ([src]) ran into the casings_to_eject cap, aborting.")
						src.casings_to_eject = 0
						return
					else
						user.show_text("You eject [src.casings_to_eject] casings from [src].", "red")
						src.ejectcasings()
						return
				else
					user.show_text("[src] is empty!", "red")
					return

	canshoot(mob/user)
		if(open)
			return 0
		else
			. = ..()

	update_icon()

		if(open)
			icon_state="guncase"
		else
			icon_state="secure"

//0.357
/obj/item/gun/kinetic/revolver
	name = "\improper Kestrel revolver"
	desc = "A hefty combat revolver developed by Cormorant Precision Arms. Uses .357 caliber rounds."
	icon_state = "revolver"
	item_state = "revolver"
	force = MELEE_DMG_REVOLVER
	ammo_cats = list(AMMO_REVOLVER_SYNDICATE, AMMO_REVOLVER_DETECTIVE) // Just like in RL (Convair880).
	max_ammo_capacity = 7
	default_magazine = /obj/item/ammo/bullets/a357
	fire_animation = TRUE
	ammobag_magazines = list(/obj/item/ammo/bullets/a357, /obj/item/ammo/bullets/a357/AP)
	ammobag_restock_cost = 2
	recoil_strength = 12
	icon_recoil_cap = 30
	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/revolver_357)
		..()

//0.38
/obj/item/gun/kinetic/detectiverevolver
	name = "\improper Piper .38 revolver"
	desc = "A snubnosed police-issue revolver developed by Cormorant Precision Arms. Uses .38-Special rounds. A favorite of the Detective's Union, always reliable in times of strife."
	icon_state = "detective"
	item_state = "detective"
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_REVOLVER
	ammo_cats = list(AMMO_REVOLVER_DETECTIVE)
	max_ammo_capacity = 7
	gildable = 1
	default_magazine = /obj/item/ammo/bullets/a38/stun
	fire_animation = TRUE
	recoil_strength = 10

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/revolver_38/stunners)
		..()

//0.393
/obj/item/gun/kinetic/foamdartgun
	name = "\improper Super! Gun Friend"
	desc = "A toy gun that fires foam darts. Keep out of reach of clowns, staff assistants and scientists."
	icon = 'icons/obj/items/guns/toy.dmi'
	icon_state = "foamdartgun"
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "toygun"
	contraband = 1
	force = 1
	ammo_cats = list(AMMO_FOAMDART)
	max_ammo_capacity = 1
	muzzle_flash = null
	default_magazine = /obj/item/ammo/bullets/foamdarts
	var/pulled = FALSE
	add_residue = FALSE
	recoil_enabled = FALSE

	New()
		ammo = new default_magazine
		ammo.amount_left = 1
		set_current_projectile(new/datum/projectile/bullet/foamdart)
		..()

	attack_self(mob/user as mob)
		..()
		if(!pulled)
			pulled = TRUE
			playsound(user.loc, 'sound/weapons/gunload_click.ogg', 60, 1)
			UpdateIcon()

	update_icon()
		..()
		if(pulled)
			icon_state="foamdartgun-pull"
		else
			icon_state="foamdartgun"

	canshoot(mob/user)
		if(!pulled)
			return FALSE
		else
			return ..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if(!src.canshoot(user))
			boutput(user, SPAN_NOTICE("You need to pull back the pully tab thingy first!"))
			playsound(user, 'sound/weapons/Gunclick.ogg', 60, TRUE)
			return
		..()
		pulled = FALSE
		UpdateIcon()

	shoot_point_blank(atom/target, var/mob/user, second_shot)
		if(!src.canshoot(user))
			boutput(user, SPAN_NOTICE("You need to pull back the pully tab thingy first!"))
			playsound(user, 'sound/weapons/Gunclick.ogg', 60, TRUE)
			return
		..()
		pulled = FALSE
		UpdateIcon()

/obj/item/gun/kinetic/foamdartgun/borg
	name = "cybernetic foam dart gun"
	desc = "A law enforcement weapon that fires foam darts. Synthesizes darts directly from the battery and includes new auto-load technology."
	icon_state="foamdartgun-pull"
	inventory_counter_enabled = FALSE
	allowReverseReload = FALSE
	var/power_requirement = 100 //! The amount of power deducted from a borg's cell when they fire this.

	New()
		. = ..()
		set_current_projectile(new /datum/projectile/bullet/foamdart/biodegradable)

	canshoot(mob/user)
		// no parent call so we don't care if it's pulled
		if (issilicon(user))
			var/mob/living/silicon/S = user
			return S.cell?.charge >= power_requirement
		else // guess someone spawned one???
			return TRUE

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (src.canshoot(user))
			. = ..() // this checks canshoot twice; could be refactored
		else
			boutput(user, SPAN_ALERT("You're too low on power to synthesize a dart!"))

	shoot_point_blank(atom/target, mob/user, second_shot)
		if (src.canshoot(user))
			. = ..()
		else
			boutput(user, SPAN_ALERT("You're too low on power to synthesize a dart!"))

	process_ammo(mob/user)
		if (issilicon(user))
			var/mob/living/silicon/S = user
			S.cell?.use(src.power_requirement)
		return TRUE


/obj/item/gun/kinetic/foamdartrevolver
	name = "\improper Super! Revolver Friend"
	desc = "An advanced dart gun for experienced pros. Just holding it imbues you with a sense of great power."
	icon = 'icons/obj/items/guns/toy.dmi'
	icon_state = "foamdartrevolver"
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "toyrevolver"
	contraband = 1
	force = 1
	ammo_cats = list(AMMO_FOAMDART)
	max_ammo_capacity = 6
	muzzle_flash = null
	default_magazine = /obj/item/ammo/bullets/foamdarts
	add_residue = FALSE
	recoil_enabled = FALSE

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/foamdart)
		..()
/obj/item/gun/kinetic/foamdartshotgun
	name = "\improper Super! Shotgun Friend"
	desc = "An even more powerful, bigger brother of the dart gun. Kicks like a horse, a foam horse. A horse made of foam."
	icon = 'icons/obj/items/guns/toy.dmi'
	icon_state = "foamdartshotgun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "foamdartshotgun"
	wear_state = "foamdartshotgun"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	contraband = 1
	two_handed = TRUE
	auto_eject = FALSE
	c_flags = ONBACK
	force = 2
	ammo_cats = list(AMMO_FOAMDART)
	max_ammo_capacity = 12
	muzzle_flash = null
	default_magazine = /obj/item/ammo/bullets/foamdarts
	add_residue = FALSE
	recoil_strength = 3

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/spreader/buckshot_burst/foamdarts)
		..()

//0.40
/obj/item/gun/kinetic/blowgun
	name = "flute"
	desc = "Wait, this isn't a flute. It's a blowgun!"
	icon = 'icons/obj/items/guns/syringe.dmi'
	icon_state = "blowgun"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "c_tube"
	force = MELEE_DMG_PISTOL
	contraband = 2
	ammo_cats = list(AMMO_DART_ALL)
	max_ammo_capacity = 1.
	can_dual_wield = 0
	hide_attack = ATTACK_FULLY_HIDDEN
	w_class = W_CLASS_SMALL
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/tranq_darts/blow_darts/single
	recoil_strength = 4
	click_sound = null

	tranq
		default_magazine = /obj/item/ammo/bullets/tranq_darts/blow_darts/ketamine/single

	New()
		ammo = new default_magazine
		set_current_projectile(src.ammo.ammo_type)
		..()

//0.41
/obj/item/gun/kinetic/derringer
	name = "derringer"
	desc = "The Deadlock .41, a small and easy-to-hide gun from Cormorant Precision Arms. Loaded with 2 shots, brutal at close range."
	icon_state = "derringer"
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_PISTOL_41)
	max_ammo_capacity = 2
	w_class = W_CLASS_SMALL
	muzzle_flash = null
	default_magazine = /obj/item/ammo/bullets/derringer
	fire_animation = TRUE
	HELP_MESSAGE_OVERRIDE(null)
	recoil_strength = 6

	get_help_message(dist, mob/user)
		var/keybind = "Default CTRL + W"
		var/datum/keymap/current_keymap = user.client.keymap
		for (var/key in current_keymap.keys)
			if (current_keymap.keys[key] == "wink")
				keybind = current_keymap.unparse_keybind(key)
				break
		return "Hit the gun on a piece of clothing to hide it inside. Retrieve it by using the <b>*wink</b> ([keybind]) emote."

	afterattack(obj/O as obj, mob/user as mob)
		if (O.loc == user && O != src && istype(O, /obj/item/clothing))
			boutput(user, SPAN_HINT("You hide the derringer inside \the [O]. (Use the wink emote while wearing the clothing item to retrieve it.)"))
			user.u_equip(src)
			src.set_loc(O)
			src.dropped(user)
		else
			..()
		return

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/derringer)
		..()

/obj/item/gun/kinetic/derringer/empty
	New()
		..()
		ammo.amount_left = 0
		UpdateIcon()

//0.45

/obj/item/gun/kinetic/single_action/colt_saa
	name = "single action army revolver"
	desc = "A nearly adequate replica of a nearly ancient single action revolver. Used by war reenactors for the last hundred years or so."
	icon_state = "colt_saa"
	item_state = "colt_saa"
	w_class = W_CLASS_NORMAL
	force = MELEE_DMG_REVOLVER
	ammo_cats = list(AMMO_REVOLVER_45)
	spread_angle = 1
	max_ammo_capacity = 7
	default_magazine = /obj/item/ammo/bullets/c_45
	recoil_strength = 11

	detective
		name = "\improper Peacemaker"
		desc = "A barely adequate replica of a nearly ancient single action revolver. Used by war reenactors for the last hundred years or so. Its caliber is obviously the wrong size, though."
		w_class = W_CLASS_SMALL
		force = MELEE_DMG_REVOLVER
		ammo_cats = list(AMMO_REVOLVER_DETECTIVE)
		default_magazine = /obj/item/ammo/bullets/a38/stun
		New()
			..()
			ammo = new default_magazine
			set_current_projectile(new/datum/projectile/bullet/revolver_38/stunners)

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/revolver_45)
		..()

//0.58
/obj/item/gun/kinetic/single_action/flintlock
	name = "flintlock pistol"
	desc = "In recent years, flintlocks have again become increasingly popular among space privateers due to the replacement of the gun flint with a shaped plasma crystal, resulting in a significantly higher firepower."
	icon_state = "flintlock"
	item_state = "flintlock"
	fire_animation = TRUE
	has_uncocked_state = TRUE
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_FLINTLOCK)
	max_ammo_capacity = 1
	default_magazine = /obj/item/ammo/bullets/flintlock/single
	recoil_strength = 12

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/flintlock)
		..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		sleep(0.3)
		if (src.canshoot(user) && !isghostdrone(user))
			var/obj/effects/flintlock_smoke/E = new /obj/effects/flintlock_smoke(get_turf(src))
			var/dir_x = target.x + POX/32 - start.x - POY/32
			var/dir_y = target.y - start.y
			var/len = vector_magnitude(dir_x, dir_y)
			dir_x /= len
			dir_y /= len
			E.setdir(dir_x, dir_y)
		. = ..()

//0.72
/obj/item/gun/kinetic/spes
	name = "SPES-12"
	desc = "An expensive imported combat shotgun, popular with frontier militias and private military operators."
	icon_state = "spas"
	item_state = "spas"
	force = MELEE_DMG_RIFLE
	contraband = 7
	ammo_cats = list(AMMO_SHOTGUN_AUTOMATIC)
	max_ammo_capacity = 8
	auto_eject = 1
	can_dual_wield = 0
	default_magazine = /obj/item/ammo/bullets/a12
	ammobag_magazines = list(/obj/item/ammo/bullets/a12, /obj/item/ammo/bullets/aex)
	ammobag_restock_cost = 2
	recoil_strength = 10
	recoil_max = 60

	New()
		if(prob(10))
			name = pick("SPEZZ-12", "SPESS-12", "SPETZ-12", "SPOCK-12", "SCHPATZL-12", "SABRINA-12", "SAURUS-12", "SABER-12", "SOSIG-12", "DINOHUNTER-12", "COMBAT-12", "SHOTASS-12", "SPES-12", "SHOOTY-12", "BLAM-12", "SPICY-12", "ANTKILLER-12", "SLAPS-12", "SPAGOOTER-12", "MARTIANSLAYER-12")
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/a12)
		..()

	custom_suicide = 1
	suicide(var/mob/living/carbon/human/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (!istype(user) || !src.canshoot(user))//!hasvar(user,"organHolder")) STOP IT STOP IT HOLY SHIT STOP WHY DO YOU USE HASVAR FOR THIS, ONLY HUMANS HAVE ORGANHOLDERS
			return 0

		src.process_ammo(user)
		var/hisher = his_or_her(user)
		user.visible_message(SPAN_ALERT("<b>[user] places [src]'s barrel in [hisher] mouth and pulls the trigger with [hisher] foot!</b>"))
		var/obj/head = user.organHolder.drop_organ("head")
		qdel(head)
		playsound(src, 'sound/weapons/shotgunshot.ogg', 100, TRUE)
		var/obj/decal/cleanable/blood/gibs/gib = make_cleanable( /obj/decal/cleanable/blood/gibs,get_turf(user))
		gib.streak_cleanable(turn(user.dir,180))
		health_update_queue |= user
		return 1

	engineer
		ammobag_magazines = list(/obj/item/ammo/bullets/a12/weak, /obj/item/ammo/bullets/a12)
		New()
			..()
			src.name = replacetext("[src.name]", "12", "6") //only half as good
			ammo = new/obj/item/ammo/bullets/a12/weak
			set_current_projectile(new/datum/projectile/bullet/a12/weak)


/obj/item/gun/kinetic/pumpweapon
	/// Whether this shotgun needs an action to pump in each direction
	var/is_heavy = FALSE
	/// Whether this shotgun's action is open (pump is pulled backwards)
	var/pump_back = FALSE
	/// Whether this shotgun is ready to fire (if the slide is not racked)
	var/hammer_ready = FALSE
	var/base_icon_state = ""
	/// The path to the sound played when the shotgun is pumped, or if is_heavy, pulled back
	var/pumpsound = 'sound/weapons/shotgunpump.ogg'
	/// The path to the sound played when the shotgun is pushed forwards, if is_heavy
	var/pushsound = FALSE
	/// The delay between racking this gun
	var/rack_delay = 0


	New()
		if (!is_heavy)
			pump_back = TRUE
			hammer_ready = TRUE
		..()

	canshoot(mob/user)
		return(..() && hammer_ready && !src.pump_back)

	attack_self(mob/user as mob)
		..()
		src.rack(user)


	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if(ammo.amount_left > 0 && (pump_back || !hammer_ready))
			boutput(user, SPAN_NOTICE("You need to rack the slide before you can fire!"))
		..()
		src.hammer_ready = FALSE
		if (!is_heavy)
			src.pump_back = TRUE //lighter guns get this half-done for you
		else
			ON_COOLDOWN(src,"rack_delay",rack_delay)
		src.UpdateIcon()


	shoot_point_blank(atom/target, mob/user, second_shot)
		if(ammo.amount_left > 0 && (pump_back || !hammer_ready))
			boutput(user, SPAN_NOTICE("You need to rack the slide before you can fire!"))
			return
		..()
		src.hammer_ready = FALSE
		if (!is_heavy)
			src.pump_back = TRUE //lighter guns get this half-done for you
		else
			ON_COOLDOWN(src,"rack_delay",rack_delay)
		src.UpdateIcon()


	update_icon()
		. = ..()
		src.icon_state = base_icon_state + (gilded ? "-golden" : "") + ((!pump_back || !has_empty_state) ? "" : "-empty" )



	proc/rack(var/atom/movable/user)
		var/mob/mob_user = null
		if(ismob(user))
			mob_user = user
		if (ON_COOLDOWN(src,"rack_delay",rack_delay))
			return
		if (!src.hammer_ready || src.pump_back) //Are we racked?
			if (src.ammo.amount_left == 0)
				if (!pump_back)
					playsound(user.loc, pumpsound, 50, 1)
					ejectcasings()
				src.pump_back = TRUE
				src.hammer_ready = TRUE
				boutput(mob_user, "<span class ='notice'>You are out of shells!</span>")
				UpdateIcon()
			else
				if (is_heavy)
					if (pump_back)
						src.pump_back = FALSE
						src.hammer_ready = TRUE
						src.icon_state = base_icon_state+"[src.gilded ? "-golden" : ""]" // having UpdateIcon() here breaks
						playsound(user.loc, pushsound, 50, 1)
					else
						ejectcasings()
						src.pump_back = TRUE
						src.hammer_ready = TRUE
						src.icon_state = base_icon_state+"[src.gilded ? "-golden-empty" : "-empty"]" // having UpdateIcon() here breaks
						playsound(user.loc, pumpsound, 50, 1)
				else
					src.hammer_ready = TRUE
					src.pump_back = FALSE
					playsound(user.loc, pumpsound, 50, 1)

					ejectcasings()
					if (src.icon_state == base_icon_state+"[src.gilded ? "-golden" : ""]") //"animated" racking
						animate(icon_state = base_icon_state+"[gilded ? "-golden" : ""]")
					else
						UpdateIcon() // Slide already open? Just close the slide
				boutput(mob_user, SPAN_NOTICE("You rack the slide of the shotgun!"))

/obj/item/gun/kinetic/pumpweapon/riotgun
	name = "\improper Guillemot riot shotgun"
	desc = "A police-issue shotgun from Cormorant Precision Arms, customized for riot suppression and prison guard duty."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "shotty"
	item_state = "shotty"
	wear_state = "shotty" // prevent empty state from breaking the worn image
	base_icon_state = "shotty"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBACK
	force = MELEE_DMG_RIFLE
	contraband = 5
	ammo_cats = list(AMMO_SHOTGUN_AUTOMATIC)
	max_ammo_capacity = 8
	auto_eject = FALSE
	can_dual_wield = FALSE
	two_handed = TRUE
	has_empty_state = TRUE
	gildable = TRUE
	default_magazine = /obj/item/ammo/bullets/abg
	recoil_strength = 14
	recoil_max = 60


	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/abg)
		..()

/obj/item/gun/kinetic/pumpweapon/ks23
	name = "Kuvalda Carbine"
	desc = "A *huge* 4-gauge shotgun built with a repurposed 23mm cannon barrel. It's unlikely there's any moral justification for using this against humans."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "ks23"
	item_state = "ks23"
	wear_state = "ks23" // prevent empty state from breaking the worn image
	base_icon_state = "ks23"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags = TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBACK
	force = MELEE_DMG_RIFLE
	contraband = 6
	is_heavy = TRUE
	ammo_cats = list(AMMO_KUVALDA)
	max_ammo_capacity = 4
	reload_cooldown = 12 DECI SECONDS
	auto_eject = FALSE
	can_dual_wield = FALSE
	two_handed = TRUE
	has_empty_state = TRUE
	gildable = TRUE
	recoil_reset = 15 DECI SECONDS
	default_magazine = /obj/item/ammo/bullets/kuvalda
	recoil_strength = 18
	recoil_max = 40
	max_move_amount = 1
	rack_delay = 5
	pumpsound = 'sound/weapons/kuvalda_pull2.ogg'
	pushsound = 'sound/weapons/kuvalda_push2.ogg'
	empty
		default_magazine = /obj/item/ammo/bullets/kuvalda/empty

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/spreader/uniform_burst/kuvalda_shrapnel)
		..()


/obj/item/gun/kinetic/single_action/mts_255
	name = "\improper MTs-255 Revolver Shotgun"
	desc = "A single-action revolving cylinder shotgun, popular with Soviet hunters, produced by the Zvezda Design Bureau."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "mts255"
	item_state = "mts255"
	flags =  TABLEPASS | CONDUCT
	c_flags = ONBACK
	force = MELEE_DMG_RIFLE
	contraband = 5
	ammo_cats = list(AMMO_SHOTGUN_AUTOMATIC)
	max_ammo_capacity = 5
	auto_eject = FALSE
	can_dual_wield = FALSE
	two_handed = TRUE
	has_empty_state = FALSE
	has_uncocked_state = TRUE
	fire_animation = TRUE
	gildable = TRUE
	default_magazine = /obj/item/ammo/bullets/a12/bird/five
	recoil_strength = 10
	recoil_max = 60

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/spreader/uniform_burst/bird12)
		..()

/obj/item/gun/kinetic/striker
	name = "\improper Striker-7"
	desc = "A terrifying looking drum shotgun, legally declared as a 'destructive device'."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "striker12"
	item_state = "striker"
	flags =  TABLEPASS | CONDUCT
	c_flags = EQUIPPED_WHILE_HELD
	force = MELEE_DMG_RIFLE
	contraband = 7
	ammo_cats = list(AMMO_SHOTGUN_AUTOMATIC)
	max_ammo_capacity = 7
	max_move_amount = 1
	reload_cooldown = 8 DECI SECONDS
	auto_eject = FALSE
	can_dual_wield = FALSE
	two_handed = TRUE
	has_empty_state = FALSE
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/a12/bird/seven

	var/is_loading = FALSE //are we reloading?

	shoot(var/atom/target, var/atom/start, var/mob/user, var/POX, var/POY, var/is_dual_wield)
		if (src.is_loading)
			return
		if (casings_to_eject > 0) //bully gun nerds 2day (striker doesnt auto-	eject your first shell)
			auto_eject = TRUE
		else
			auto_eject = FALSE
		..()


	attackby(obj/item/b, mob/user)
		if (istype(b, /obj/item/ammo/bullets) && !src.is_loading)
			if (!ON_COOLDOWN(src, "reload_spam", src.reload_cooldown))
				boutput(user, "<span class='alert'>It's too [pick("fiddly","frustrating","awkward")] to load \the [src] like this! You'll need to lower it first.</span>")
			return
		..()

	canshoot(mob/user)
		return(..() && !src.is_loading)

	New()
		ammo = new default_magazine
		set_current_projectile(new /datum/projectile/special/spreader/uniform_burst/bird12)
		..()

	attack_self(mob/user as mob)
		if (is_loading)
			if (setTwoHanded(TRUE))
				is_loading = FALSE
				src.transform = src.transform.Turn(-45)
				boutput(user, "<span class='alert'>You raise the striker, ready to shoot!</span>")
			else
				boutput(user, "<span class='alert'>Can't switch to 2-handed while your other hand is full.</span>")
		else
			boutput(user, "<span class='alert'>You lower the [src] for reloading.</span>")
			setTwoHanded(FALSE)
			is_loading = TRUE
			src.transform = src.transform.Turn(45)

/obj/item/gun/kinetic/flaregun
	desc = "A 12-gauge signal launcher from Cormorant Precision Arms. A perennial lifesaver at sea, on land, and in space."
	name = "\improper Pelican flare gun"
	icon_state = "flare"
	item_state = "flaregun"
	force = MELEE_DMG_PISTOL
	contraband = 2
	ammo_cats = list(AMMO_SHOTGUN_LOW)
	max_ammo_capacity = 1
	has_empty_state = 1
	default_magazine = /obj/item/ammo/bullets/flare/single
	recoil_strength = 10
	recoil_max = 20
	icon_recoil_cap = 30
	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/flare)
		..()

/obj/item/gun/kinetic/slamgun
	name = "slamgun"
	desc = "A 12 gauge shotgun. Apparently. It's just two pipes stacked together."
	icon = 'icons/obj/slamgun.dmi'
	icon_state = "slamgun-ready"
	inhand_image_icon = 'icons/obj/slamgun.dmi'
	item_state = "slamgun-ready-world"
	force = MELEE_DMG_RIFLE
	ammo_cats = list(AMMO_SHOTGUN_ALL)
	max_ammo_capacity = 1
	auto_eject = 0
	object_flags = NO_GHOSTCRITTER | NO_ARM_ATTACH
	spread_angle = 10 // sorry, no sniping with slamguns

	can_dual_wield = 0
	two_handed = 1
	w_class = W_CLASS_BULKY
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	default_magazine = /obj/item/ammo/bullets/a12
	sound_load_override = 'sound/weapons/gunload_sawnoff.ogg'
	recoil_strength = 14
	recoil_max = 14

	New()
		set_current_projectile(new/datum/projectile/bullet/a12)
		ammo = new /obj/item/ammo/bullets/a12
		ammo.amount_left = 0 // Spawn empty.
		..()

	attack_self(mob/user as mob)
		if (src.icon_state == "slamgun-ready")
			if(user.updateTwoHanded(src, FALSE)) // should never fail, but respect error codes
				w_class = W_CLASS_NORMAL
				force = MELEE_DMG_REVOLVER
				if (src.ammo.amount_left > 0 || src.casings_to_eject > 0)
					src.icon_state = "slamgun-open-loaded"
				else
					src.icon_state = "slamgun-open"
				UpdateIcon()
				two_handed = 0

			user.update_inhands()
		else
			if(user.updateTwoHanded(src, TRUE))
				w_class = W_CLASS_BULKY
				force = MELEE_DMG_RIFLE
				src.icon_state = "slamgun-ready"
				UpdateIcon()
				two_handed = 1
				user.update_inhands()

	canshoot(mob/user)
		if (src.icon_state == "slamgun-ready")
			return ..()
		else
			return 0

	attack_hand(mob/user as mob)
		. = src.casings_to_eject
		..()
		if(. != src.casings_to_eject)
			UpdateIcon()

	update_icon()
		if(src.icon_state == "slamgun-ready")
			src.item_state = "slamgun-ready-world"
		else
			src.item_state = "slamgun-open-world"
			if (src.ammo.amount_left > 0 || src.casings_to_eject > 0)
				src.icon_state = "slamgun-open-loaded"
			else
				src.icon_state = "slamgun-open"

		..()

	mouse_drop(atom/over_object, src_location, over_location, params)
		if (usr.stat || usr.restrained() || !can_reach(usr, src) || usr.getStatusDuration("unconscious") || usr.sleeping || usr.lying || isAIeye(usr) || isAI(usr) || isghostcritter(usr))
			return ..()
		if (over_object == usr && src.icon_state == "slamgun-open-loaded") // sorry for doing it like this, but i have no idea how to do it cleaner.
			src.Attackhand(usr)
			return

	attackby(obj/item/b, mob/user)
		if (istype(b, /obj/item/ammo/bullets) && src.icon_state == "slamgun-ready")
			boutput(user, SPAN_ALERT("You can't shove shells down the barrel! You'll have to open \the [src]!"))
			return
		if (istype(b, /obj/item/ammo/bullets) && (src.ammo.amount_left > 0 || src.casings_to_eject > 0))
			boutput(user, SPAN_ALERT("\The [src] already has a shell inside! You'll have to unload \the [src]!"))
			return
		..()

	alter_projectile(var/obj/projectile/P)
		. = ..()
		P.proj_data.shot_sound = 'sound/weapons/sawnoff.ogg'

	pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
		if (src.icon_state == "slamgun-ready")
			..()
		else
			boutput(user, SPAN_ALERT("You can't fire \the [src] when it is open!"))

#define ONE_BARREL 1
#define TWO_BARRELS 2
#define ALL_BARRELS 4
#define MAX_USES 9

/obj/item/gun/kinetic/sawnoff/quadbarrel //for salvagers

	name = "\improper Four Letter Word"
	desc = "For when you REALLY need to get the point across."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "quadb"
	item_state = "quadbarrel" //custom inhands, though.
	default_magazine = /obj/item/ammo/bullets/a12/bird/four

	camera_recoil_sway_min = 10 //VIOLENCE!
	recoil_strength = 15
	recoil_max = 60

	var/guaranteed_uses = MAX_USES	// allows for just over two volleys before it starts breaking
	var/firemode = ONE_BARREL
	var/priorammo

	force = MELEE_DMG_RIFLE
	max_ammo_capacity = 4
	two_handed = TRUE

	New()
		..()
		ammo = new default_magazine
		set_current_projectile(new /datum/projectile/special/spreader/uniform_burst/bird12)
		name = initial(name) //I kinda like the fact that it'll pull from the DB name pool buuut I kinda don't.
		UpdateIcon()

	get_help_message(dist, mob/user)
		.+= "You can use a <b>welding tool</b> to repair its state. \n You can also use a <b>screwdriver</b> to cycle firing modes."

	examine()
		. = ..()
		. += "\n \n It is set to fire " //differentiate the FLW examine text from the default gun examine text
		switch(firemode)
			if(ONE_BARREL)
				. += "one barrel."
			if(TWO_BARRELS)
				. += "two barrels."
			if(ALL_BARRELS)
				. += "all four barrels!"
		if (guaranteed_uses == MAX_USES)
			. += "It's in perfect condition!"
		else if (guaranteed_uses <= 0) //negative damage
			. += " It seems severely damaged!"
		else if (guaranteed_uses < 4) //0-4
			. += " It seems pretty damaged."
		else if(guaranteed_uses < 7) //4-7
			. += " It's damaged."
		else  //7+
			. += " It's barely damaged."


	update_icon()
		. = ..()
		src.icon_state = "quadb" + (!src.broke_open ? "" : "-empty" )

	shoot(var/target, var/start, var/mob/user)

		priorammo = src.ammo.amount_left

		//Go up to the limit defined by the firing mode, but don't exceed however many bullets are in the gun BEFORE we started firing
		for(var/i=1, ((i <= priorammo) && (i <= firemode)), i++)
			..() //shoot an additional ith time (just goes once if it's in single shot)
			guaranteed_uses-- //damage the gun an additional ith time

		//check the gun's condition, break as needed
		if((priorammo > 0) && !(src.broke_open)) //make sure the gun isn't empty and also closed (shooting conditions) before we roll to break
			//you're shooting multiple shotgun shells out of a garbage gun at the same time. don't think there won't be consequences
			if((firemode != ONE_BARREL) && (priorammo == 2)) // two shells are shot, can be in 2 or 4 mode
				boutput(user, SPAN_ALERT("The [src] jumps in your hands!"))
				user.do_disorient(stamina_damage = 20, knockdown = 0, stunned = 0, disorient = 5, remove_stamina_below_zero = 0)
			else if((firemode == ALL_BARRELS) && (priorammo >= 3)) //3 or more shells, can only be in all barrel mode
				SPAWN(0.3 DECI SECONDS) //give it a micro-delay
				if (src.canshoot(user))
					boutput(user, SPAN_ALERT("The [src] kicks like a damn mule!"))
					//this might seem punishing but keep in mind it's FOUR whole shotgun shells at once.
					user.do_disorient(stamina_damage = 40, knockdown = 0, stunned = 0, disorient = 20, remove_stamina_below_zero = 0)

			if(guaranteed_uses < 0)
				//warn the user that they're in the danger zone
				playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
				user.visible_message(SPAN_COMBAT("The [src] [pick(list("rattles!", "bulges!", "pops!", "thunks!", "jolts!", "makes a concerning click...", "cracks!"))]"))
				if (prob(guaranteed_uses*-5)) //roll for failure. Since [uses] is now negative, we need another minus sign to cancel out

					user.visible_message(SPAN_ALERT("[user]'s [src] makes a severe-sounding bang!"), SPAN_ALERT("The [src] gives out!"))

					if((firemode == ALL_BARRELS) && (priorammo == 4)) //ohhh, you REALLY fucked up now.
						explosion(src, get_turf(src), 0, 0.5, 1.5, 4)

					//replace the gun with broken version
					var/obj/item/brokenquadbarrel/broken = new /obj/item/brokenquadbarrel
					user.drop_item(src)
					user.put_in_hand_or_drop(broken)
					qdel(src)

	proc/repairdamage(obj/item/gun/kinetic/sawnoff/quadbarrel/Q, mob/user)
		if(guaranteed_uses < MAX_USES)
			Q.guaranteed_uses ++

		if(guaranteed_uses == MAX_USES)
			boutput(user, SPAN_NOTICE("You fully repair the [src]!"))
			actions.interrupt(user, INTERRUPT_ACT) //break the loop
		else if(guaranteed_uses <= 0) //negative
			boutput(user, SPAN_NOTICE("You patch up some of the cracks and bulges on the [src]. It's still severely damaged..."))
		else if(guaranteed_uses < 5) //0-4
			boutput(user, SPAN_NOTICE("You patch up some of the cracks and bulges on the [src]. It's still pretty damaged..."))
		else //5+
			boutput(user, SPAN_NOTICE("You patch up some of the cracks and bulges on the [src]. It's starting to look better..."))

	proc/get_welding_positions()

		var/startpos = list(rand(7, 16), rand(4, -4))
		var/stoppos = list(rand(7, 16), rand(4, -4))
		return list(startpos, stoppos)

	attackby(obj/item/I, mob/user)

		//are we repairing?
		if (isweldingtool(I))
			var/obj/item/weldingtool/welder = I
			if(guaranteed_uses == MAX_USES)
				boutput(user, SPAN_NOTICE("The [src] doesn't seem to be all that damaged."))
			else //We are good to repair!
				var/datum/action/bar/icon/callback/action_bar
				boutput(user, SPAN_NOTICE("You start to repair the [src]..."))

				//create the action bar
				var/positions = src.get_welding_positions()
				action_bar = new /datum/action/bar/private/welding/loop(user, src, 1.5 SECONDS, \
				proc_path = /obj/item/gun/kinetic/sawnoff/quadbarrel/proc/repairdamage, \
				proc_args=list(src, user), \
				start = positions[1], \
				stop = positions[2], \
				tool = welder, \
				cost = 2)

				//begin repairing!
				actions.start(action_bar, user)
		//are we cycling through firing modes?
		else if(isscrewingtool(I))
			if(firemode == ONE_BARREL)
				firemode = TWO_BARRELS
				boutput(user, SPAN_NOTICE("You set [src] to fire two barrels at a time."))
			else if(firemode == TWO_BARRELS)
				firemode = ALL_BARRELS
				boutput(user, SPAN_NOTICE("You set [src] to fire all four barrels! You're not so sure about this..."))
			else
				firemode = ONE_BARREL
				boutput(user, SPAN_NOTICE("You set [src] to fire one barrel at a time."))
		else //no special interactions, so default to whatever
			..()

/obj/item/brokenquadbarrel
	two_handed = TRUE
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "quadb-broken"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi' //gotta make it use gun inhands
	item_state = "quadbarrel"
	name = "Broken Four Letter Word"
	desc = "This thing is TOTALED well beyond repair. You feel like you can recover a slamgun from it, though."
	force = MELEE_DMG_RIFLE

	attack_self(mob/user as mob)

		user.drop_item(src) //clear hands
		boutput(user, SPAN_NOTICE("You rip apart the [src]!"))
		playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)

		// give an OPEN slamgun
		var/obj/item/gun/kinetic/slamgun/newgun = new /obj/item/gun/kinetic/slamgun
		user.put_in_hand_or_drop(newgun)
		newgun.AttackSelf(user)

		//give some other random junk that'd reasonably be pulled off, for flavor
		var/turf/T = get_turf(src)

		var/obj/item/raw_material/scrap_metal/W = new /obj/item/raw_material/scrap_metal
		W.setMaterial(getMaterial("wood"))
		W.name = "mangled chunk of wood"
		W.desc = "If you tilt your head and squint, it looks like it possibly might've been a stock at one point."
		W.icon = 'icons/obj/materials.dmi'
		W.icon_state = "scrap4"

		var/obj/decal/cleanable/machine_debris/G = new /obj/decal/cleanable/machine_debris
		G.icon_state = "gib1"

		var/obj/item/rods/steel/R = new /obj/item/rods/steel
		var/obj/item/scrap/S1 = new /obj/item/scrap
		S1.icon_state = "2metal0"

		var/flavordebris = list(W, G, R, S1)
		var/obj/item/currentitem
		var/i
		for(i=1, i<=4, i++)
			currentitem = flavordebris[i]
			currentitem.set_loc(T)
			currentitem.pixel_x = rand(-8,8)
			currentitem.pixel_y = rand(-8,8)

		qdel(src)

//0.75
/obj/item/gun/kinetic/single_action/flintlock/rifle
	name = "flintlock rifle"
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "flintlock_rifle"
	item_state = "flintlock_rifle"
	ammo_cats = list(AMMO_FLINTLOCK_RIFLE)
	flags =  TABLEPASS | CONDUCT
	c_flags = ONBACK
	force = MELEE_DMG_RIFLE
	two_handed = TRUE
	w_class = W_CLASS_BULKY
	default_magazine = /obj/item/ammo/bullets/flintlock/rifle/single
	recoil_strength = 18

	New()
		..()
		set_current_projectile(new/datum/projectile/bullet/flintlock/rifle)

//1.0
/obj/item/gun/kinetic/coilgun_TEST
	name = "coil gun"
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "coilgun_2"
	item_state = "flaregun"
	force = MELEE_DMG_RIFLE
	contraband = 6
	ammo_cats = list(AMMO_COILGUN)
	max_ammo_capacity = 2
	default_magazine = /obj/item/ammo/bullets/rod

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/rod)
		..()

/obj/item/gun/kinetic/four_bore_albatross
	name = "\improper Albatross four-bore rifle"
	desc = "A behemoth of a scoped rifle developed by Cormorant Precision Arms. Intended for suppression or elimination of monstrous targets."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "four_bore"
	item_state = "four_bore"
	w_class = W_CLASS_BULKY
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBACK
	slowdown = 10
	slowdown_time = 8
	force = MELEE_DMG_RIFLE
	two_handed = TRUE
	can_dual_wield = FALSE
	contraband = 7
	ammo_cats = list(AMMO_FOUR_BORE)
	spread_angle = 2
	shoot_delay = 0.8 SECONDS
	max_ammo_capacity = 2
	default_magazine = /obj/item/ammo/bullets/four_bore/stun/two
	fire_animation = FALSE
	recoil_strength = 20

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/four_bore_stunners)
		AddComponent(/datum/component/holdertargeting/sniper_scope, 12, 512, /datum/overlayComposition/sniper_scope, 'sound/weapons/scope.ogg')
		..()

	setupProperties()
		..()
		setProperty("carried_movespeed", 0.6)

//1.57
/obj/item/gun/kinetic/riot40mm
	desc = "A classic 40mm riot-control launcher from Cormorant Precision Arms. It can accept standard 40mm rounds and hand-thrown grenades."
	name = "\improper Puffin 40mm riot launcher"
	icon_state = "40mm"
	item_state = "40mm"
	force = MELEE_DMG_SMG
	contraband = 7
	ammo_cats = list(AMMO_GRENADE_ALL)
	max_ammo_capacity = 1
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/smoke/single
	fire_animation = TRUE
	recoil_strength = 12

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/smoke)
		..()

	attackby(obj/item/b, mob/user)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if(src.ammo.amount_left > 0)
				boutput(user, SPAN_ALERT("The [src] already has something in it! You can't use the conversion chamber right now! You'll have to manually unload the [src]!"))
				return
			else
				SETUP_GENERIC_ACTIONBAR(user, src, 1 SECOND, PROC_REF(convert_grenade), list(b, user), b.icon, b.icon_state,"", null)
				return
		else
			..()

	proc/convert_grenade(obj/item/nade, mob/user)
		var/obj/item/ammo/bullets/grenade_shell/TO_LOAD = new /obj/item/ammo/bullets/grenade_shell
		TO_LOAD.Attackby(nade, user)
		src.Attackby(TO_LOAD, user)

	breach
		default_magazine = /obj/item/ammo/bullets/breach_flashbang/single
		New()
			..()
			ammo = new default_magazine
			set_current_projectile(new/datum/projectile/bullet/breach_flashbang)

//1.58
/obj/item/gun/kinetic/missile_launcher
	name = "pod-targeting missile launcher"
	desc = "A collapsible, infantry portable, pod-targeting missile launcher."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "missile_launcher"
	item_state = "missile_launcher"
	has_empty_state = TRUE
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 4
	force = MELEE_DMG_LARGE
	contraband = 8
	ammo_cats = list(AMMO_ROCKET_ALL)
	max_ammo_capacity = 1
	can_dual_wield = FALSE
	two_handed = TRUE
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/pod_seeking_missile
	var/collapsed
	recoil_strength = 13

	New()
		ammo = new default_magazine
		ammo.amount_left = 0
		set_current_projectile(new /datum/projectile/bullet/homing/pod_seeking_missile)
		AddComponent(/datum/component/holdertargeting/smartgun/homing/pod, 1)
		src.set_collapsed_state(TRUE)
		..()

	update_icon()
		if (src.collapsed)
			src.icon = 'icons/obj/items/guns/kinetic.dmi'
			src.icon_state = "missile_launcher-collapsed"
			src.item_state = "missile_launcher-collapsed"

		else
			src.icon = 'icons/obj/items/guns/kinetic64x32.dmi'
			src.icon_state = "missile_launcher"

			if (src.ammo.amount_left < 1)
				src.item_state = "missile_launcher-empty"
			else
				src.item_state = "missile_launcher"

		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			H.update_inhands()

		. = ..()

	canshoot(mob/user)
		if (src.collapsed)
			boutput(user, SPAN_ALERT("You need to extend the [src.name] before you can fire!"))
			return FALSE
		. = ..()

	attack_self(mob/user)
		src.set_collapsed_state(!src.collapsed)

		..()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/ammo/bullets) && src.collapsed)
			boutput(user, SPAN_ALERT("You can't load a missile into the chamber! You'll have to extend the [src.name] first!"))
			return
		..()

	proc/set_collapsed_state(var/collapsed)
		if (src.setTwoHanded(!collapsed))
			src.collapsed = collapsed

			if (src.collapsed)
				src.item_function_flags &= ~UNSTORABLE
				src.w_class = W_CLASS_NORMAL
				src.has_empty_state = FALSE

			else
				src.item_function_flags |= UNSTORABLE
				src.w_class = W_CLASS_BULKY
				src.has_empty_state = TRUE

			src.UpdateIcon()
			// Update HUD inhands, as they seem to dislike icon file changes paired with changing twohandedness.
			if (ishuman(src.loc))
				var/mob/living/carbon/human/H = src.loc
				H.updateTwoHanded(src, !src.collapsed)

			if (src.collapsed)
				src.unload()

	proc/unload()
		if (src.ammo.amount_left <= 0)
			return

		var/obj/item/ammo/bullets/missile = new src.ammo.type
		missile.amount_left = src.ammo.amount_left
		missile.name = src.ammo.name
		missile.icon = src.ammo.icon
		missile.icon_state = src.ammo.icon_state
		missile.ammo_type = src.ammo.ammo_type
		missile.UpdateIcon()

		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			H.put_in_hand_or_drop(missile)

		src.ammo.amount_left = 0
		src.ammo.refillable = FALSE
		src.UpdateIcon()


// Ported from old, non-gun RPG-7 object class (Convair880).
/obj/item/gun/kinetic/rpg7
	desc = "A rocket-propelled grenade launcher licensed by the Space Irish Republican Army."
	name = "\improper MPRT-7"
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "rpg7"
	item_state = "rpg7"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	c_flags = ONBACK
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 4
	force = MELEE_DMG_LARGE
	contraband = 8
	ammo_cats = list(AMMO_ROCKET_ALL)
	max_ammo_capacity = 1
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"
	has_empty_state = 1
	default_magazine = /obj/item/ammo/bullets/rpg
	ammobag_magazines = list(/obj/item/ammo/bullets/rpg)
	ammobag_spec_required = TRUE
	ammobag_restock_cost = 4
	recoil_strength = 13

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		ammo.amount_left = 0 // Spawn empty.
		set_current_projectile(new /datum/projectile/bullet/rpg)
		..()

	update_icon()
		..()
		if (src.ammo.amount_left < 1)
			src.item_state = "rpg7_empty"
		else
			src.item_state = "rpg7"
		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			H.update_inhands()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	loaded
		New()
			..()
			ammo.amount_left = 1
			src.UpdateIcon()
			return

/obj/item/gun/kinetic/mrl
	desc = "A 6-barrel multiple rocket launcher armed with guided micro-missiles."
	name = "Fomalhaut MRL"
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "mrls"
	item_state = "mrls"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	c_flags = ONBACK
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 4
	force = MELEE_DMG_LARGE
	contraband = 8
	ammo_cats = list(AMMO_ROCKET_MRL)
	max_ammo_capacity = 6
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/mrl
	ammobag_magazines = list(/obj/item/ammo/bullets/mrl)
	ammobag_spec_required = TRUE
	ammobag_restock_cost = 6
	recoil_strength = 12

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		ammo.amount_left = 0 // Spawn empty.
		set_current_projectile(new /datum/projectile/bullet/homing/mrl)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	loaded
		New()
			..()
			ammo.amount_left = 6
			UpdateIcon()
			return

/obj/item/gun/kinetic/antisingularity
	desc = "An experimental rocket launcher designed to deliver various payloads in rocket format."
	name = "\improper Singularity Buster rocket launcher"
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "ntlauncher"
	item_state = "ntlauncher"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBACK
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 4
	force = MELEE_DMG_LARGE
	ammo_cats = list(AMMO_ROCKET_ALL)//based on the fact that it's funny to fire an RPG rocket out of this thing
	max_ammo_capacity = 1
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/antisingularity
	recoil_strength = 12

	New()
		ammo = new default_magazine
		ammo.amount_left = 0 // Spawn empty.
		set_current_projectile(new /datum/projectile/bullet/antisingularity)
		..()
		return

	setupProperties()
		..()
		setProperty("carried_movespeed", 0.8)

//2.5
/obj/item/gun/kinetic/single_action/flintlock/mortar
	name = "hand mortar"
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "hand_mortar"
	item_state = "hand_mortar"
	ammo_cats = list(AMMO_FLINTLOCK_MORTAR)
	force = MELEE_DMG_RIFLE
	two_handed = TRUE
	default_magazine = /obj/item/ammo/bullets/flintlock/mortar/single
	recoil_strength = 14

	New()
		..()
		set_current_projectile(new/datum/projectile/bullet/flintlock/mortar)

//3.0
/obj/item/gun/kinetic/gungun //meesa jarjar binks
	name = "\improper Gun"
	desc = "A gun that shoots... something. It looks like a modified grenade launcher."
	icon_state = "gungun"
	item_state = "gungun"
	w_class = W_CLASS_NORMAL
	ammo_cats = list(AMMO_DERRINGER_LITERAL)
	max_ammo_capacity = 6 //6 guns
	force = MELEE_DMG_SMG
	default_magazine = /obj/item/ammo/bullets/gun

	New()
		ammo = new default_magazine
		ammo.amount_left = 6 //spawn full please
		set_current_projectile(new /datum/projectile/special/spawner/gun)
		..()

//4.6
/obj/item/gun/kinetic/airzooka //This is technically kinetic? I guess?
	name = "Super! Bazooka Friend"
	desc = "The new double action air projection device from Super! Friend."
	icon = 'icons/obj/items/guns/toy.dmi'
	icon_state = "airzooka"
	force = MELEE_DMG_PISTOL
	max_ammo_capacity = 10
	ammo_cats = list(AMMO_AIRZOOKA)
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/airzooka

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/airzooka)
		..()

//20.0
/obj/item/gun/kinetic/meowitzer
	name = "\improper Meowitzer"
	desc = "It purrs gently in your hands."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "blaster"

	color = "#ff7b00"
	force = MELEE_DMG_LARGE
	ammo_cats = list(AMMO_HOWITZER)
	max_ammo_capacity = 1
	auto_eject = 0
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	spread_angle = 0
	can_dual_wield = 0
	slowdown = 0
	slowdown_time = 0
	two_handed = 1
	w_class = W_CLASS_BULKY
	default_magazine = /obj/item/ammo/bullets/meowitzer
	recoil_strength = 17

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/meowitzer)
		..()

	afterattack(atom/A, mob/user as mob)
		if(src.ammo.amount_left < max_ammo_capacity && istype(A, /mob/living/critter/small_animal/cat))
			src.ammo.amount_left += 1
			user.visible_message(SPAN_ALERT("[user] loads \the [A] into \the [src]."), SPAN_ALERT("You load \the [A] into \the [src]."))
			src.current_projectile.icon_state = A.icon_state //match the cat sprite that we load
			qdel(A)
			return
		else
			..()

/obj/item/gun/kinetic/meowitzer/inert
	default_magazine = /obj/item/ammo/bullets/meowitzer
	New()
		..()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/meowitzer/inert)


//  <([['v') - Gannets Nuke Ops Class Guns - ('u']])>  //

// agent
/obj/item/gun/kinetic/pistol
	name = "\improper Branwen pistol"
	desc = "A semi-automatic, 9mm caliber service pistol, developed by Mabinogi Firearms Company."
	icon_state = "9mm_pistol"
	w_class = W_CLASS_NORMAL
	force = MELEE_DMG_PISTOL
	contraband = 4
	ammo_cats = list(AMMO_PISTOL_9MM_ALL)
	max_ammo_capacity = 15
	auto_eject = 1
	has_empty_state = 1
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/bullet_9mm
	ammobag_magazines = list(/obj/item/ammo/bullets/bullet_9mm)
	ammobag_restock_cost = 1
	recoil_strength = 8
	icon_recoil_cap = 30
	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/bullet_9mm)
		..()

/obj/item/gun/kinetic/pistol/empty

	New()
		..()
		ammo.amount_left = 0
		UpdateIcon()

/obj/item/gun/kinetic/pistol/smart/mkII
	name = "\improper Hydra smart pistol"
	desc = "A pistol capable of locking onto multiple targets and firing on them in rapid sequence. \"Anderson Para-Munitions\" is engraved on the slide."
	icon_state = "smartgun"
	max_ammo_capacity = 20
	ammo_cats = list(AMMO_PISTOL_22)
	default_magazine = /obj/item/ammo/bullets/bullet_22/smartgun
	ammobag_magazines = list(/obj/item/ammo/bullets/bullet_22/smartgun)
	recoil_enabled = 0

	New()
		..()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/bullet_22/smartgun)
		AddComponent(/datum/component/holdertargeting/smartgun/nukeop, 4)


/datum/component/holdertargeting/smartgun/nukeop/is_valid_target(mob/user, mob/M)
	return ..() && !(istype(M.get_id(), /obj/item/card/id/syndicate) || isnukeopgunbot(M) || istype(M, /mob/living/critter/robotic/sawfly))

/obj/item/gun/kinetic/smg
	name = "\improper Bellatrix submachine gun"
	desc = "A semi-automatic, 9mm submachine gun, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "mp52"
	w_class = W_CLASS_SMALL
	object_flags = NO_GHOSTCRITTER | NO_ARM_ATTACH
	force = MELEE_DMG_SMG
	contraband = 4
	ammo_cats = list(AMMO_SMG_9MM)
	max_ammo_capacity = 30
	auto_eject = 1
	spread_angle = 10
	has_empty_state = 1
	default_magazine = /obj/item/ammo/bullets/bullet_9mm/smg
	ammobag_magazines = list(/obj/item/ammo/bullets/bullet_9mm/smg)
	ammobag_restock_cost = 2
	recoil_strength = 8

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/bullet_9mm/smg)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	attack_self(mob/user as mob)
		if(ishuman(user))
			if(two_handed)
				setTwoHanded(0) //Go 1-handed.
				src.spread_angle = initial(src.spread_angle)
				icon_recoil_cap = initial(src.icon_recoil_cap)
				recoil_max = initial(src.recoil_max)
				recoil_strength = initial(src.recoil_strength)
			else
				if(!setTwoHanded(1)) //Go 2-handed.
					boutput(user, SPAN_ALERT("Can't switch to 2-handed while your other hand is full."))
				else
					icon_recoil_cap = 10
					recoil_max = 100
					src.spread_angle = 4
					recoil_strength = 5
		..()

/obj/item/gun/kinetic/smg/empty

	New()
		..()
		ammo.amount_left = 0
		UpdateIcon()

/obj/item/gun/kinetic/tranq_pistol
	name = "\improper Ceridwen tranquilizer pistol"
	desc = "A silenced 9mm tranquilizer pistol, developed by Mabinogi Firearms Company."
	icon_state = "tranq_pistol"
	item_state = "tranq_pistol"
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	contraband = 4
	ammo_cats = list(AMMO_TRANQ_9MM)
	max_ammo_capacity = 15
	auto_eject = 1
	hide_attack = ATTACK_FULLY_HIDDEN
	muzzle_flash = null
	default_magazine = /obj/item/ammo/bullets/tranq_darts/syndicate/pistol
	fire_animation = TRUE
	ammobag_magazines = list(/obj/item/ammo/bullets/tranq_darts/syndicate/pistol)
	ammobag_restock_cost = 2
	recoil_strength = 7
	icon_recoil_cap = 30
	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/tranq_dart/syndicate/pistol)
		..()

// scout
/obj/item/gun/kinetic/tactical_shotgun //just a reskin, unused currently
	name = "\improper Pryderi tactical shotgun"
	desc = "A compact multi-purpose shotgun from Mabinogi Firearms Company, standard-issue for Hafgan's mine guards and convoy security throughout the Martian War."
	icon_state = "tactical_shotgun"
	item_state = "shotgun"
	force = MELEE_DMG_RIFLE
	contraband = 7
	ammo_cats = list(AMMO_SHOTGUN_AUTOMATIC)
	max_ammo_capacity = 5
	auto_eject = 1
	two_handed = 1
	can_dual_wield = 0
	default_magazine = /obj/item/ammo/bullets/buckshot_burst
	fire_animation = TRUE
	has_empty_state = TRUE
	recoil_strength = 10
	recoil_max = 60

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/spreader/buckshot_burst/)
		..()


// assault
/obj/item/gun/kinetic/assault_rifle
	name = "\improper Sirius assault rifle"
	desc = "A bullpup assault rifle capable of semi-automatic and burst fire modes, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "assault_rifle"
	item_state = "assault_rifle"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBACK
	force = MELEE_DMG_RIFLE
	contraband = 8
	ammo_cats = list(AMMO_AUTO_556)
	max_ammo_capacity = 20
	auto_eject = 1
	ammobag_magazines = list(/obj/item/ammo/bullets/assault_rifle, /obj/item/ammo/bullets/assault_rifle/armor_piercing)
	ammobag_restock_cost = 2

	two_handed = 1
	can_dual_wield = 0
	spread_angle = 0
	default_magazine = /obj/item/ammo/bullets/assault_rifle
	recoil_strength = 9 // two handed guns can probably take lower recoil
	recoil_stacking_enabled = TRUE

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/assault_rifle)
		projectiles = list(current_projectile,new/datum/projectile/bullet/assault_rifle/burst)
		..()

	attackby(obj/item/ammo/bullets/b, mob/user)  // has to account for whether regular or armor-piercing ammo is loaded AND which firing mode it's using
		var/obj/previous_ammo = ammo
		var/mode_was_burst = (istype(current_projectile, /datum/projectile/bullet/assault_rifle/burst/))  // was previous mode burst fire?
		..()
		if(previous_ammo.type != ammo.type)  // we switched ammo types
			if(istype(ammo, /obj/item/ammo/bullets/assault_rifle/armor_piercing)) // we switched from normal to armor_piercing
				if(mode_was_burst) // we were in burst shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle/burst/armor_piercing)
					projectiles = list(new/datum/projectile/bullet/assault_rifle/armor_piercing, current_projectile)
				else // we were in single shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle/armor_piercing)
					projectiles = list(current_projectile, new/datum/projectile/bullet/assault_rifle/burst/armor_piercing)
			else // we switched from armor penetrating ammo to normal
				if(mode_was_burst) // we were in burst shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle/burst)
					projectiles = list(new/datum/projectile/bullet/assault_rifle, current_projectile)
				else // we were in single shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle)
					projectiles = list(current_projectile, new/datum/projectile/bullet/assault_rifle/burst)

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/assault_rifle/burst/))
			spread_angle = 12.5
			shoot_delay = 4 DECI SECONDS
		else
			spread_angle = 0
			shoot_delay = 3 DECI SECONDS

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()



// assault
/obj/item/gun/kinetic/m16
	name = "\improper M16"
	desc = "This gun's seen a lot of conflict! And you're probably going to make it see more. Uses 5.56 rounds."
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "m16"
	item_state = "m16"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = EQUIPPED_WHILE_HELD
	force = MELEE_DMG_RIFLE
	contraband = 8
	ammo_cats = list(AMMO_AUTO_556)
	max_ammo_capacity = 20
	auto_eject = TRUE
	two_handed = TRUE
	can_dual_wield = FALSE
	spread_angle = 0
	fire_animation = TRUE
	has_empty_state = TRUE
	default_magazine = /obj/item/ammo/bullets/assault_rifle/remington

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/assault_rifle/remington)
		projectiles = list(current_projectile,new/datum/projectile/bullet/assault_rifle/burst/remington)
		..()

	attackby(obj/item/ammo/bullets/b, mob/user)  // has to account for whether regular or armor-piercing ammo is loaded AND which firing mode it's using
		var/obj/previous_ammo = ammo
		var/mode_was_burst = (istype(current_projectile, /datum/projectile/bullet/assault_rifle/burst))  // was previous mode burst fire?
		..()
		if(previous_ammo.type != ammo.type)  // we switched ammo types
			if(istype(ammo, /obj/item/ammo/bullets/assault_rifle/armor_piercing)) // we switched from normal to armor_piercing
				if(mode_was_burst) // we were in burst shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle/burst/armor_piercing)
					projectiles = list(new/datum/projectile/bullet/assault_rifle/armor_piercing, current_projectile)
				else // we were in single shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle/armor_piercing)
					projectiles = list(current_projectile, new/datum/projectile/bullet/assault_rifle/burst/armor_piercing)
			else if(istype(ammo, /obj/item/ammo/bullets/assault_rifle/remington))
				if(mode_was_burst) // we were in burst shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle/remington)
					projectiles = list(new/datum/projectile/bullet/assault_rifle/remington, current_projectile)
				else // we were in single shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle/burst/remington)
					projectiles = list(current_projectile, new/datum/projectile/bullet/assault_rifle/burst/remington)
			else // we switched from armor penetrating ammo to normal
				if(mode_was_burst) // we were in burst shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle/burst)
					projectiles = list(new/datum/projectile/bullet/assault_rifle, current_projectile)
				else // we were in single shot mode
					set_current_projectile(new/datum/projectile/bullet/assault_rifle)
					projectiles = list(current_projectile, new/datum/projectile/bullet/assault_rifle/burst)

	attack_self(mob/user)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/assault_rifle/burst))
			spread_angle = 7.5
			shoot_delay = 4 DECI SECONDS
		else
			spread_angle = 0
			shoot_delay = 3 DECI SECONDS



// heavy
/obj/item/gun/kinetic/light_machine_gun
	name = "\improper Antares light machine gun"
	desc = "A 100 round light machine gun, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "lmg"
	item_state = "lmg"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_RIFLE
	ammo_cats = list(AMMO_AUTO_308)
	max_ammo_capacity = 100
	auto_eject = 0
	shoot_delay = 7

	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBACK

	spread_angle = 6
	can_dual_wield = 0

	contraband = 7
	two_handed = 1
	w_class = W_CLASS_BULKY
	default_magazine = /obj/item/ammo/bullets/lmg
	ammobag_magazines = list(/obj/item/ammo/bullets/lmg)
	ammobag_restock_cost = 3

	camera_recoil_multiplier = 0.65 // this thing packs possibly excessive punch
	camera_recoil_sway_max = 10 // lower the wobblies when shooting huge volumes of lead

	recoil_strength = 5
	recoil_stacking_enabled = TRUE
	recoil_stacking_safe_stacks = 8
	recoil_stacking_max_stacks = 8
	recoil_stacking_amount = 0.5
	recoil_max = 100 // eat more recoil

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/lmg)
		projectiles = list(current_projectile, new/datum/projectile/bullet/lmg/auto)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.5 DECI SECONDS)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	setupProperties()
		..()
		setProperty("carried_movespeed", 1)


/obj/item/gun/kinetic/cannon
	name = "\improper Alphard 20mm cannon"
	desc = "A 20mm anti-materiel recoiling cannon from Almagest. Slow but enormously powerful."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "cannon"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_LARGE
	ammo_cats = list(AMMO_CANNON_20MM)
	max_ammo_capacity = 1
	auto_eject = 1
	fire_animation = TRUE

	recoil_strength = 20
	recoil_max = 25 //seriously how are you going to fire this more than once

	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBACK

	can_dual_wield = 0

	slowdown = 10
	slowdown_time = 15

	contraband = 8
	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/cannon/single
	ammobag_magazines = list(/obj/item/ammo/bullets/cannon)
	ammobag_spec_required = TRUE
	ammobag_restock_cost = 3


	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/cannon)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	setupProperties()
		..()
		setProperty("carried_movespeed", 0.3)

/obj/item/gun/kinetic/recoilless
	name = "\improper Carinae RCL/120"
	desc = "An absurdly destructive 120mm recoilless gun-mortar, the largest man-portable weapon in the Almagest line."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "recoilless"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_LARGE
	ammo_cats = list(AMMO_HOWITZER)
	max_ammo_capacity = 1
	auto_eject = 1
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBACK

	can_dual_wield = 0

	slowdown = 10
	slowdown_time = 15

	recoil_strength = 0 // saving the discord from this joke

	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/howitzer
	ammobag_magazines = list(/obj/item/ammo/bullets/howitzer)
	ammobag_spec_required = TRUE
	ammobag_restock_cost = 5

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/howitzer)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	setupProperties()
		..()
		setProperty("carried_movespeed", 0.2)

// demo
/obj/item/gun/kinetic/grenade_launcher
	name = "\improper Rigil grenade launcher"
	desc = "A 40mm hand-held grenade launcher, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "grenade_launcher"
	item_state = "grenade_launcher"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBACK
	force = MELEE_DMG_RIFLE
	contraband = 7
	ammo_cats = list(AMMO_GRENADE_ALL)
	max_ammo_capacity = 4 // to fuss with if i want 6 packs of ammo
	two_handed = 1
	can_dual_wield = 0
	auto_eject = 0
	default_magazine = /obj/item/ammo/bullets/grenade_round/explosive
	ammobag_magazines = list(/obj/item/ammo/bullets/grenade_round/explosive)
	ammobag_spec_required = TRUE
	ammobag_restock_cost = 3
	sound_load_override = 'sound/weapons/gunload_rigil.ogg'
	recoil_strength = 12
	recoil_max = 40

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		ammo.amount_left = max_ammo_capacity
		set_current_projectile(new/datum/projectile/bullet/grenade_round/explosive)
		..()

	attackby(obj/item/b, mob/user)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if((src.ammo.amount_left > 0 && !istype(current_projectile, /datum/projectile/bullet/grenade_shell)) || src.ammo.amount_left >= src.max_ammo_capacity)
				boutput(user, SPAN_ALERT("The [src] already has something in it! You can't use the conversion chamber right now! You'll have to manually unload the [src]!"))
				return
			else
				var/datum/projectile/bullet/grenade_shell/custom_shell = src.current_projectile
				if(src.ammo.amount_left > 0 && istype(custom_shell) && custom_shell.get_nade().type != b.type)
					boutput(user, SPAN_ALERT("The [src] has a different kind of grenade in the conversion chamber, and refuses to mix and match!"))
					return
				else
					SETUP_GENERIC_ACTIONBAR(user, src, 0.3 SECONDS, PROC_REF(convert_grenade), list(b, user), b.icon, b.icon_state,"", null)
					return
		else
			..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	proc/convert_grenade(obj/item/nade, mob/user)
		var/obj/item/ammo/bullets/grenade_shell/TO_LOAD = new /obj/item/ammo/bullets/grenade_shell/rigil
		TO_LOAD.Attackby(nade, user)
		src.Attackby(TO_LOAD, user)

// sniper
/obj/item/gun/kinetic/sniper
	name = "\improper Betelgeuse sniper rifle"
	desc = "A semi-automatic bullpup sniper rifle, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "sniper"
	item_state = "sniper"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_RIFLE
	ammo_cats = list(AMMO_RIFLE_308)
	max_ammo_capacity = 6
	auto_eject = 1
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBACK
	slowdown = 7
	slowdown_time = 5

	can_dual_wield = 0
	contraband = 7
	two_handed = 1
	w_class = W_CLASS_BULKY

	shoot_delay = 1 SECOND
	default_magazine = /obj/item/ammo/bullets/rifle_762_NATO
	ammobag_magazines = list(/obj/item/ammo/bullets/rifle_762_NATO)
	ammobag_restock_cost = 3
	recoil_strength = 15
	recoil_inaccuracy_max = 0 // just to be nice :)
	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/rifle_762_NATO)
		AddComponent(/datum/component/holdertargeting/sniper_scope, 12, 3200, /datum/overlayComposition/sniper_scope, 'sound/weapons/scope.ogg')
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	setupProperties()
		..()
		setProperty("carried_movespeed", 0.8)

// WIP //////////////////////////////////
/*/obj/item/gun/kinetic/sniper/antimateriel
	name = "M20-S antimateriel cannon"
	desc = "A ruthlessly powerful rifle chambered for a 20mm cannon round. Built to destroy vehicles and infrastructure at range."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "antimateriel"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = 10
	ammo_cats = list(AMMO_CANNON_20MM)
	max_ammo_capacity = 5
	auto_eject = 1

	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBACK

	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 10

	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_launch"


	New()
		ammo = new/obj/item/ammo/bullets/cannon
		set_current_projectile(new/datum/projectile/bullet/cannon)
		AddComponent(/datum/component/holdertargeting/sniper_scope, 12, 0, /datum/overlayComposition/sniper_scope, 'sound/weapons/scope.ogg')
		..()


	setupProperties()
		..()
		setProperty("carried_movespeed", 0.3)*/

/obj/item/gun/kinetic/sawnoff
	name = "\improper Fulmar 1881 coach gun"
	desc = "A stylish historic-reproduction short-barreled shotgun from Cormorant Precision Arms, a favorite of the Bartender's Guild."
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "coachgun"
	icon_state = "coachgun"
	force = MELEE_DMG_REVOLVER //it's one handed, no reason for it to be rifle-levels of melee damage
	contraband = 4
	ammo_cats = list(AMMO_SHOTGUN_ALL)
	max_ammo_capacity = 2
	auto_eject = FALSE
	can_dual_wield = FALSE
	two_handed = FALSE
	add_residue = TRUE
	gildable = TRUE
	sound_load_override = 'sound/weapons/gunload_sawnoff.ogg'
	recoil_strength = 10
	recoil_max = 60
	default_magazine = /obj/item/ammo/bullets/abg/two
	var/broke_open = FALSE
	var/shells_to_eject = 0

	New() //uses a special box of ammo that only starts with 2 shells to prevent issues with overloading
		if (prob(25))
			name = pick ("Bessie", "Mule", "Loud Louis", "Boomstick", "Coach Gun", "Shorty", "Sawn-off Shotgun", "Street Sweeper", "Street Howitzer", "Big Boy", "Slugger", "Closing Time", "Garbage Day", "Rooty Tooty Point and Shooty", "Twin 12 Gauge", "Master Blaster", "Ass Blaster", "Blunderbuss", "Dr. Bullous' Thunder-Clapper", "Super Shotgun", "Insurance Policy", "Last Call", "Super-Duper Shotgun")
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/abg)
		..()

	birdshot
		default_magazine = /obj/item/ammo/bullets/a12/bird/two
		New()
			..()
			set_current_projectile(new/datum/projectile/special/spreader/uniform_burst/bird12)

	update_icon()
		. = ..()
		src.icon_state = "coachgun" + (gilded ? "-golden" : "") + (!src.broke_open ? "" : "-empty" )

	canshoot(mob/user)
		if (!src.broke_open)
			return TRUE
		..()

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (src.broke_open)
			src.toggle_action(user)
			if (src.ammo.amount_left > 0)
				user.visible_message(SPAN_ALERT("<b>[user]</b> slams shut [src] and fires in one fluid motion. Wow!"))
		if (!src.broke_open && src.ammo.amount_left > 0)
			src.shells_to_eject++
		..()

	attack_self(mob/user)
		src.toggle_action(user)
		..()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/ammo/bullets) && !src.broke_open)
			boutput(user, SPAN_ALERT("You can't load shells into the chambers! You'll have to open [src] first!"))
			return
		..()

	attack_hand(mob/user)
		if (!src.broke_open && user.find_in_hand(src))
			boutput(user, SPAN_ALERT("[src] is still closed, you need to open the action to take the shells out!"))
			return
		..()

	alter_projectile(obj/projectile/P)
		. = ..()
		P.proj_data.shot_sound = 'sound/weapons/sawnoff.ogg'

	on_spin_emote(mob/living/carbon/human/user)
		if(src.broke_open) // Only allow spinning to close the gun, doesn't make as much sense spinning it open.
			src.toggle_action(user)
			user.visible_message(SPAN_ALERT("<b>[user]</b> snaps shut [src] with a [pick("spin", "twirl")]!"))
		..()

	proc/toggle_action(mob/user)
		if (!src.broke_open)
			src.casings_to_eject = src.shells_to_eject

			if (src.casings_to_eject > 0) //this code exists because without it the gun ejects double the amount of shells
				src.ejectcasings()
				src.shells_to_eject = 0
		src.broke_open = !src.broke_open

		playsound(user.loc, 'sound/weapons/gunload_click.ogg', 15, TRUE)

		UpdateIcon()

