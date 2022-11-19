ABSTRACT_TYPE(/obj/item/gun/kinetic)
/obj/item/gun/kinetic
	name = "kinetic weapon"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "gun"
	m_amt = 2000
	var/obj/item/ammo/bullets/ammo = null
	/// How much ammo can this gun hold? Don't make this null (Convair880).
	var/max_ammo_capacity = 1
	/// Can be a list too. The .357 Mag revolver can also chamber .38 Spc rounds, for instance (Convair880).
	var/ammo_cats = null
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
			current_projectile.shot_sound = 'sound/machines/click.ogg'
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
			. += "<span class='alert'>*ERROR* No output selected!</span>"

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
		boutput(user, "<span class='alert'>*click* *click*</span>")
		if (!src.silenced)
			playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
		return 0

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/item/ammo/bullets) && allowDropReload)
			src.Attackby(O, user)
		return ..()

	attackby(obj/item/ammo/bullets/b, mob/user)
		if(istype(b, /obj/item/ammo/bullets))
			if(ON_COOLDOWN(src, "reload_spam", 2 DECI SECONDS))
				return
			switch (src.ammo.loadammo(b,src))
				if(0)
					user.show_text("You can't reload this gun.", "red")
					return
				if(1)
					user.show_text("This ammo won't fit!", "red")
					return
				if(2)
					user.show_text("There's no ammo left in [b.name].", "red")
					return
				if(3)
					user.show_text("[src] is full!", "red")
					return
				if(4)
					user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>There wasn't enough ammo left in [b.name] to fully reload [src]. It only has [src.ammo.amount_left] rounds remaining.</span>")
					src.tooltip_rebuild = 1
					src.logme_temp(user, src, b) // Might be useful (Convair880).
					return
				if(5)
					user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>You fully reload [src] with ammo from [b.name]. There are [b.amount_left] rounds left in [b.name].</span>")
					src.tooltip_rebuild = 1
					src.logme_temp(user, src, b)
					return
				if(6)
					switch (src.ammo.swap(b,src))
						if(0)
							user.show_text("This ammo won't fit!", "red")
							return
						if(1)
							user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>You swap out the magazine. Or whatever this specific gun uses.</span>")
						if(2)
							user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>You swap [src]'s ammo with [b.name]. There are [b.amount_left] rounds left in [b.name].</span>")
					src.logme_temp(user, src, b)
					return
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

			user.visible_message("<span class='alert'>[user] unloads [src].</span>", "<span class='alert'>You unload [src].</span>")
			//DEBUG_MESSAGE("Unloaded [src]'s ammo manually.")
			return

		return ..()

	attack(mob/M, mob/user)
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
		..()

	shoot(var/target, var/start, var/mob/user)
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
			if(src.ammo?.amount_left > 1)
				var/flick_state = src.has_fire_anim_state && src.fire_anim_state ? src.fire_anim_state : src.icon_state
				flick(flick_state, src)

		if(..() && istype(user.loc, /turf/space) || user.no_gravity)
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)

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

	shoot(var/target, var/start, var/mob/user)
		..()
		hammer_cocked = FALSE
		src.UpdateIcon()

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (hammer_cocked)
			boutput(user, "<span class='notice'>You gently lower the weapon's hammer!</span>")
		else
			boutput(user, "<span class='alert'>You cock the hammer!</span>")
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

/obj/item/casing
	name = "bullet casing"
	desc = "A spent casing from a bullet of some sort."
	icon = 'icons/obj/items/casings.dmi'
	icon_state = "medium"
	w_class = W_CLASS_TINY
	var/forensic_ID = null
	burn_possible = 0

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
	icon_state = "railgun"
	force = MELEE_DMG_PISTOL
	contraband = 0
	max_ammo_capacity = 200
	default_magazine = /obj/item/ammo/bullets/vbullet

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/vbullet)
		..()

	shoot(var/target,var/start ,var/mob/user)
		var/turf/T = get_turf(src)

		if (!istype(T.loc, /area/sim))
			boutput(user, "<span class='alert'>You can't use the guns outside of the combat simulation, fuckhead!</span>")
			return
		else
			..()

/obj/item/gun/kinetic/zipgun
	name = "zip gun"
	desc = "An improvised and unreliable gun."
	icon_state = "zipgun"
	force = MELEE_DMG_PISTOL
	contraband = 6
	ammo_cats = list(AMMO_PISTOL_ALL, AMMO_REVOLVER_ALL, AMMO_SMG_9MM, AMMO_TRANQ_ALL, AMMO_RIFLE_308, AMMO_AUTO_308, AMMO_AUTO_556, AMMO_CASELESS_G11, AMMO_FLECHETTE)
	max_ammo_capacity = 2
	var/failure_chance = 6
	var/failured = 0
	default_magazine = /obj/item/ammo/bullets/bullet_22

	New()

		ammo = new default_magazine
		ammo.amount_left = 0 // start empty
		set_current_projectile(new/datum/projectile/bullet/bullet_22)
		..()


	shoot(var/target,var/start ,var/mob/user)
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
				boutput(user, "<span class='alert'>The [src]'s shodilly thrown-together [pick("breech", "barrel", "bullet holder", "firing pin", "striker", "staple-driver mechanism", "bendy metal part", "shooty-bit")][pick("", "...thing")] [pick("cracks", "pops off", "bends nearly in half", "comes loose")]!</span>")
			else						// Other times, less obvious
				playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
		..()
		return

/obj/item/gun/kinetic/revolver/vr
	icon = 'icons/effects/VR.dmi'

//0.22
/obj/item/gun/kinetic/faith
	name = "Faith"
	desc = "'Cause ya gotta have Faith."
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

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/bullet_22)
		..()

/obj/item/gun/kinetic/silenced_22
	name = "\improper Orion silenced pistol"
	desc = "A small pistol with an integrated flash and noise suppressor, developed by Specter Tactical Laboratory. Uses .22 rounds."
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

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/bullet_22/HP)
		..()


//0.308
/obj/item/gun/kinetic/minigun
	name = "minigun"
	desc = "The M134 Minigun is a 7.62×51mm NATO, six-barrel rotary machine gun with a high rate of fire."
	icon_state = "minigun"
	item_state = "heavy"
	force = MELEE_DMG_LARGE
	ammo_cats = list(AMMO_AUTO_308)
	max_ammo_capacity = 100
	auto_eject = 1

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	spread_angle = 25
	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 15

	two_handed = 1
	w_class = W_CLASS_BULKY
	default_magazine = /obj/item/ammo/bullets/minigun

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/minigun)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.4)

/obj/item/gun/kinetic/akm
	name = "\improper AKM Assault Rifle"
	desc = "An old Cold War relic chambered in 7.62x39. Rusted, but not busted."
	icon = 'icons/obj/large/48x32.dmi'
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
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK | EXTRADELAY
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	w_class = W_CLASS_BULKY
	ammobag_magazines = list(/obj/item/ammo/bullets/akm)
	ammobag_restock_cost = 3

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/akm)
		..()


/obj/item/gun/kinetic/hunting_rifle
	name = "old hunting rifle"
	desc = "A powerful antique hunting rifle."
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "ohr"
	item_state = "ohr"
	wear_state = "ohr" // prevent empty state from breaking the worn image
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
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

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/rifle_3006)
		..()

/obj/item/gun/kinetic/dart_rifle
	name = "tranquilizer rifle"
	desc = "A veterinary tranquilizer rifle chambered in .308 caliber."
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "tranq"
	item_state = "tranq"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
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

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/tranq_dart)
		..()

//9mm/0.355
/obj/item/gun/kinetic/clock_188
	desc = "A reliable weapon used the world over... 50 years ago. Uses 9mm NATO rounds."
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
			AddComponent(/datum/component/holdertargeting/fullauto, 1.2, 1.2, 1)
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
				user.visible_message("<span class='alert'><B>[user] fumbles the catch and accidentally discharges [src]!</B></span>")
				src.shoot_point_blank(user, user)
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
					src.shoot_point_blank(M, M)
					M.visible_message("<span class='alert'><B>[src] fires, hitting [M] point blank!</B></span>")
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

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/veritate)
		projectiles = list(current_projectile,new/datum/projectile/bullet/veritate/burst)
		..()

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/veritate/burst/))
			spread_angle = 6
			shoot_delay = 3 DECI SECONDS
		else
			spread_angle = 0
			shoot_delay = 2 DECI SECONDS

/obj/item/gun/kinetic/SMG_briefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "secure"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system. This one has a small hole in the side of it. Odd."
	force = MELEE_DMG_SMG
	ammo_cats = list(AMMO_SMG_9MM)
	max_ammo_capacity = 30
	auto_eject = 0

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

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
			boutput(user, "<span class='alert'>You can't unload the [src] while it is closed.</span>")

	attackby(obj/item/ammo/bullets/b as obj, mob/user)
		if(open)
			.=..()
		else
			boutput(user, "<span class='alert'>You can't access the gun inside the [src] while it's closed! You'll have to open the [src]!</span>")

	attack_self(mob/user)
		if(open)
			open = FALSE
			UpdateIcon()
			boutput(user, "<span class='alert'>You close the [src]!</span>")
		else
			boutput(user, "<span class='alert'>You open the [src].</span>")
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
	name = "\improper Predator revolver"
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

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/revolver_357)
		..()

//0.38
/obj/item/gun/kinetic/detectiverevolver
	name = "\improper Detective Special revolver"
	desc = "A snubnosed police-issue revolver developed by Cormorant Precision Arms. Uses .38-Special rounds."
	icon_state = "detective"
	item_state = "detective"
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_REVOLVER
	ammo_cats = list(AMMO_REVOLVER_DETECTIVE)
	max_ammo_capacity = 7
	gildable = 1
	default_magazine = /obj/item/ammo/bullets/a38/stun
	fire_animation = TRUE

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/revolver_38/stunners)
		..()

//0.393
/obj/item/gun/kinetic/foamdartgun
	name = "foam dart gun"
	icon_state = "foamdartgun"
	desc = "A toy gun that fires foam darts. Keep out of reach of clowns, staff assistants and scientists."
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

	shoot(var/target,var/start ,var/mob/user)
		if(!src.canshoot(user))
			boutput(user, "<span class='notice'>You need to pull back the pully tab thingy first!</span>")
			playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
			return
		..()
		pulled = FALSE
		UpdateIcon()

	shoot_point_blank(atom/target, var/mob/user, second_shot)
		if(!src.canshoot(user))
			boutput(user, "<span class='notice'>You need to pull back the pully tab thingy first!</span>")
			playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
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

	shoot(target, start, mob/user)
		if (src.canshoot(user))
			. = ..() // this checks canshoot twice; could be refactored
		else
			boutput(user, "<span class='alert'>You're too low on power to synthesize a dart!</span>")

	shoot_point_blank(atom/target, mob/user, second_shot)
		if (src.canshoot(user))
			. = ..()
		else
			boutput(user, "<span class='alert'>You're too low on power to synthesize a dart!</span>")

	process_ammo(mob/user)
		if (issilicon(user))
			var/mob/living/silicon/S = user
			S.cell?.charge -= src.power_requirement
		return TRUE


/obj/item/gun/kinetic/foamdartrevolver
	name = "foam dart revolver"
	icon_state = "foamdartrevolver"
	desc = "An advanced dart gun for experienced pros. Just holding it imbues you with a sense of great power."
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "toyrevolver"
	contraband = 1
	force = 1
	ammo_cats = list(AMMO_FOAMDART)
	max_ammo_capacity = 6
	muzzle_flash = null
	default_magazine = /obj/item/ammo/bullets/foamdarts

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/foamdart)
		..()

//0.40
/obj/item/gun/kinetic/blowgun
	name = "flute"
	desc = "Wait, this isn't a flute. It's a blowgun!"
	icon_state = "blowgun"
	item_state = "cane-f"
	force = MELEE_DMG_PISTOL
	contraband = 2
	ammo_cats = list(AMMO_DART_ALL)
	max_ammo_capacity = 1.
	can_dual_wield = 0
	hide_attack = ATTACK_FULLY_HIDDEN
	gildable = 1
	w_class = W_CLASS_SMALL
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/blow_darts/single

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/blow_dart)
		..()

//0.41
/obj/item/gun/kinetic/derringer
	name = "derringer"
	desc = "A small and easy-to-hide gun that comes with 2 shots. (Can be hidden in worn clothes and retrieved by using the wink emote)"
	icon_state = "derringer"
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_PISTOL_41)
	max_ammo_capacity = 2
	w_class = W_CLASS_SMALL
	muzzle_flash = null
	default_magazine = /obj/item/ammo/bullets/derringer
	fire_animation = TRUE

	afterattack(obj/O as obj, mob/user as mob)
		if (O.loc == user && O != src && istype(O, /obj/item/clothing))
			boutput(user, "<span class='hint'>You hide the derringer inside \the [O]. (Use the wink emote while wearing the clothing item to retrieve it.)</span>")
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
	name = "colt saa revolver"
	desc = "A nearly adequate replica of a nearly ancient single action revolver. Used by war reenactors for the last hundred years or so."
	icon_state = "colt_saa"
	item_state = "colt_saa"
	w_class = W_CLASS_NORMAL
	force = MELEE_DMG_REVOLVER
	ammo_cats = list(AMMO_REVOLVER_45)
	spread_angle = 1
	max_ammo_capacity = 7
	default_magazine = /obj/item/ammo/bullets/c_45

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
/obj/item/gun/kinetic/flintlockpistol
	name = "flintlock pistol"
	desc = "A powerful antique flintlock pistol."
	icon_state = "flintlock"
	item_state = "flintlock"
	force = MELEE_DMG_PISTOL
	contraband = 0 //It's so old that futuristic security scanners don't even recognize it.
	ammo_cats = list(AMMO_FLINTLOCK)
	max_ammo_capacity = 1 // It's magazine-fed (Convair880).
	auto_eject = null
	default_magazine = /obj/item/ammo/bullets/flintlock
	var/failure_chance = 1

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/flintlock)
		..()

	shoot(target, start, mob/user)
		if(ammo?.amount_left && current_projectile.power)
			failure_chance = clamp(round(current_projectile.power/2), 10, 33)
		if(canshoot(user) && prob(failure_chance))
			var/turf/T = get_turf(src)
			boutput(T, "<span class='alert'>[src] blows up!</span>")
			explosion(src, T,0,1,1,2)
			qdel(src)
		else
			..()
			return


//0.72
/obj/item/gun/kinetic/spes
	name = "SPES-12"
	desc = "Multi-purpose high-grade military shotgun. Very spiffy."
	icon_state = "spas"
	item_state = "spas"
	force = MELEE_DMG_RIFLE
	contraband = 7
	ammo_cats = list(AMMO_SHOTGUN_ALL)
	max_ammo_capacity = 8
	auto_eject = 1
	can_dual_wield = 0
	default_magazine = /obj/item/ammo/bullets/a12
	ammobag_magazines = list(/obj/item/ammo/bullets/a12, /obj/item/ammo/bullets/aex)
	ammobag_restock_cost = 2

	New()
		if(prob(10))
			name = pick("SPEZZ-12", "SPESS-12", "SPETZ-12", "SPOCK-12", "SCHPATZL-12", "SABRINA-12", "SAURUS-12", "SABER-12", "SOSIG-12", "DINOHUNTER-12", "PISS-12", "ASS-12", "SPES-12", "SHIT-12", "SHOOT-12", "SHOTGUN-12", "FAMILYGUY-12", "SPAGOOTER-12")
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
		user.visible_message("<span class='alert'><b>[user] places [src]'s barrel in [hisher] mouth and pulls the trigger with [hisher] foot!</b></span>")
		var/obj/head = user.organHolder.drop_organ("head")
		qdel(head)
		playsound(src, 'sound/weapons/shotgunshot.ogg', 100, 1)
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

/obj/item/gun/kinetic/riotgun
	name = "riot shotgun"
	desc = "A police-issue shotgun meant for suppressing riots."
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "shotty"
	item_state = "shotty"
	wear_state = "shotty" // prevent empty state from breaking the worn image
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	force = MELEE_DMG_RIFLE
	contraband = 5
	ammo_cats = list(AMMO_SHOTGUN_ALL)
	max_ammo_capacity = 8
	auto_eject = 0
	can_dual_wield = 0
	two_handed = 1
	has_empty_state = 1
	gildable = 1
	default_magazine = /obj/item/ammo/bullets/abg
	var/racked_slide = FALSE



	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/abg)
		..()

	update_icon()
		. = ..()
		src.icon_state = "shotty" + (gilded ? "-golden" : "") + (racked_slide ? "" : "-empty" )

	canshoot(mob/user)
		return(..() && src.racked_slide)

	shoot(var/target,var/start ,var/mob/user)
		if(ammo.amount_left > 0 && !racked_slide)
			boutput(user, "<span class='notice'>You need to rack the slide before you can fire!</span>")
		..()
		src.racked_slide = FALSE
		src.casings_to_eject = src.ammo.amount_left ? 1 : 0
		src.UpdateIcon()

	shoot_point_blank(atom/target, mob/user, second_shot)
		if(ammo.amount_left > 0 && !racked_slide)
			boutput(user, "<span class='notice'>You need to rack the slide before you can fire!</span>")
			return
		..()
		src.racked_slide = FALSE
		src.casings_to_eject = src.ammo.amount_left ? 1 : 0
		src.UpdateIcon()

	attack_self(mob/user as mob)
		..()
		src.rack(user)

	proc/rack(var/atom/movable/user)
		var/mob/mob_user = null
		if(ismob(user))
			mob_user = user
		if (!src.racked_slide) //Are we racked?
			if (src.ammo.amount_left == 0)
				boutput(mob_user, "<span class ='notice'>You are out of shells!</span>")
				UpdateIcon()
			else
				src.racked_slide = TRUE
				if (src.icon_state == "shotty[src.gilded ? "-golden" : ""]") //"animated" racking
					src.icon_state = "shotty[src.gilded ? "-golden-empty" : "-empty"]" // having UpdateIcon() here breaks
					animate(src, time = 0.2 SECONDS)
					animate(icon_state = "shotty[gilded ? "-golden" : ""]")
				else
					UpdateIcon() // Slide already open? Just close the slide
				boutput(mob_user, "<span class='notice'>You rack the slide of the shotgun!</span>")
				playsound(user.loc, 'sound/weapons/shotgunpump.ogg', 50, 1)
				src.casings_to_eject = 0
				if (src.ammo.amount_left < 8) // Do not eject shells if you're racking a full "clip"
					var/turf/T = get_turf(src)
					if (T && src.current_projectile.casing) // Eject shells on rack instead of on shoot()
						new src.current_projectile.casing(T, src.forensic_ID)

/obj/item/gun/kinetic/single_action/mts_255
	name = "\improper MTs-255 Revolver Shotgun"
	desc = "A single-action revolving cylinder shotgun, popular with Soviet hunters, produced by the Zvezda Design Bureau."
	icon = 'icons/obj/large/48x32.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "mts255"
	item_state = "mts255"
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	force = MELEE_DMG_RIFLE
	contraband = 5
	ammo_cats = list(AMMO_SHOTGUN_ALL)
	max_ammo_capacity = 5
	auto_eject = FALSE
	can_dual_wield = FALSE
	two_handed = TRUE
	has_empty_state = FALSE
	has_uncocked_state = TRUE
	fire_animation = TRUE
	gildable = TRUE
	default_magazine = /obj/item/ammo/bullets/pipeshot/scrap/five

	New()
		ammo = new default_magazine
		set_current_projectile(new /datum/projectile/special/spreader/buckshot_burst/scrap)
		..()

/obj/item/gun/kinetic/flaregun
	desc = "A 12-gauge flaregun."
	name = "flare gun"
	icon_state = "flare"
	item_state = "flaregun"
	force = MELEE_DMG_PISTOL
	contraband = 2
	ammo_cats = list(AMMO_SHOTGUN_LOW)
	max_ammo_capacity = 1
	has_empty_state = 1
	default_magazine = /obj/item/ammo/bullets/flare/single

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
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	default_magazine = /obj/item/ammo/bullets/a12
	sound_load_override = 'sound/weapons/gunload_sawnoff.ogg'


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
				update_icon()
				two_handed = 0

			user.update_inhands()
		else
			if(user.updateTwoHanded(src, TRUE))
				w_class = W_CLASS_BULKY
				force = MELEE_DMG_RIFLE
				src.icon_state = "slamgun-ready"
				update_icon()
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
			update_icon()

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
		if (usr.stat || usr.restrained() || !can_reach(usr, src) || usr.getStatusDuration("paralysis") || usr.sleeping || usr.lying || isAIeye(usr) || isAI(usr) || isghostcritter(usr))
			return ..()
		if (over_object == usr && src.icon_state == "slamgun-open-loaded") // sorry for doing it like this, but i have no idea how to do it cleaner.
			attack_hand(usr)
			return

	attackby(obj/item/b, mob/user)
		if (istype(b, /obj/item/ammo/bullets) && src.icon_state == "slamgun-ready")
			boutput(user, "<span class='alert'>You can't shove shells down the barrel! You'll have to open \the [src]!</span>")
			return
		if (istype(b, /obj/item/ammo/bullets) && (src.ammo.amount_left > 0 || src.casings_to_eject > 0))
			boutput(user, "<span class='alert'>\The [src] already has a shell inside! You'll have to unload \the [src]!</span>")
			return
		..()

	alter_projectile(var/obj/projectile/P)
		. = ..()
		P.proj_data.shot_sound = 'sound/weapons/sawnoff.ogg'

	pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
		if (src.icon_state == "slamgun-ready")
			..()
		else
			boutput(user, "<span class='alert'>You can't fire \the [src] when it is open!</span>")


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

//1.57
/obj/item/gun/kinetic/riot40mm
	desc = "A 40mm riot control gun. It can accept standard 40mm rounds and hand-thrown grenades."
	name = "riot launcher"
	icon_state = "40mm"
	item_state = "40mm"
	force = MELEE_DMG_SMG
	contraband = 7
	ammo_cats = list(AMMO_GRENADE_ALL)
	max_ammo_capacity = 1
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/smoke/single
	fire_animation = TRUE

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/smoke)
		..()

	attackby(obj/item/b, mob/user)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if(src.ammo.amount_left > 0)
				boutput(user, "<span class='alert'>The [src] already has something in it! You can't use the conversion chamber right now! You'll have to manually unload the [src]!</span>")
				return
			else
				SETUP_GENERIC_ACTIONBAR(user, src, 1 SECOND, .proc/convert_grenade, list(b, user), b.icon, b.icon_state,"", null)
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
// Ported from old, non-gun RPG-7 object class (Convair880).
/obj/item/gun/kinetic/rpg7
	desc = "A rocket-propelled grenade launcher licensed by the Space Irish Republican Army."
	name = "\improper MPRT-7"
	icon = 'icons/obj/large/64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "rpg7"
	uses_multiple_icon_states = 1
	item_state = "rpg7"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags = ONBACK
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
	desc = "A  6-barrel multiple rocket launcher armed with guided micro-missiles."
	name = "Fomalhaut MRL"
	icon = 'icons/obj/large/64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "mrls"
	item_state = "mrls"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags = ONBACK
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
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "ntlauncher"
	item_state = "ntlauncher"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
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

	New()
		ammo = new default_magazine
		ammo.amount_left = 0 // Spawn empty.
		set_current_projectile(new /datum/projectile/bullet/antisingularity)
		..()
		return

	setupProperties()
		..()
		setProperty("movespeed", 0.8)


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
	name = "airzooka"
	desc = "The new double action air projection device from Donk Co!"
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
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	spread_angle = 0
	can_dual_wield = 0
	slowdown = 0
	slowdown_time = 0
	two_handed = 1
	w_class = W_CLASS_BULKY
	default_magazine = /obj/item/ammo/bullets/meowitzer

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/meowitzer)
		..()

	afterattack(atom/A, mob/user as mob)
		if(src.ammo.amount_left < max_ammo_capacity && istype(A, /mob/living/critter/small_animal/cat))
			src.ammo.amount_left += 1
			user.visible_message("<span class='alert'>[user] loads \the [A] into \the [src].</span>", "<span class='alert'>You load \the [A] into \the [src].</span>")
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
	icon = 'icons/obj/large/48x32.dmi'
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
			else
				if(!setTwoHanded(1)) //Go 2-handed.
					boutput(user, "<span class='alert'>Can't switch to 2-handed while your other hand is full.</span>")
				else
					src.spread_angle = 4
		..()

/obj/item/gun/kinetic/smg/empty

	New()
		..()
		ammo.amount_left = 0
		UpdateIcon()

/obj/item/gun/kinetic/tranq_pistol
	name = "\improper Gwydion tranquilizer pistol"
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

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/tranq_dart/syndicate/pistol)
		..()

// scout
/obj/item/gun/kinetic/tactical_shotgun //just a reskin, unused currently
	name = "tactical shotgun"
	desc = "Multi-purpose high-grade military shotgun, painted a menacing black colour."
	icon_state = "tactical_shotgun"
	item_state = "shotgun"
	force = MELEE_DMG_RIFLE
	contraband = 7
	ammo_cats = list(AMMO_SHOTGUN_ALL)
	max_ammo_capacity = 8
	auto_eject = 1
	two_handed = 1
	can_dual_wield = 0
	default_magazine = /obj/item/ammo/bullets/buckshot_burst

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/spreader/buckshot_burst/)
		..()

// assault
/obj/item/gun/kinetic/assault_rifle
	name = "\improper Sirius assault rifle"
	desc = "A bullpup assault rifle capable of semi-automatic and burst fire modes, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "assault_rifle"
	item_state = "assault_rifle"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
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



// heavy
/obj/item/gun/kinetic/light_machine_gun
	name = "\improper Antares light machine gun"
	desc = "A 100 round light machine gun, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "lmg"
	item_state = "lmg"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_RIFLE
	ammo_cats = list(AMMO_AUTO_308)
	max_ammo_capacity = 100
	auto_eject = 0

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	spread_angle = 8
	can_dual_wield = 0

	two_handed = 1
	w_class = W_CLASS_BULKY
	default_magazine = /obj/item/ammo/bullets/lmg
	ammobag_magazines = list(/obj/item/ammo/bullets/lmg)
	ammobag_restock_cost = 3

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/lmg)
		projectiles = list(current_projectile, new/datum/projectile/bullet/lmg/auto)
		AddComponent(/datum/component/holdertargeting/fullauto, 1.5 DECI SECONDS, 1.5 DECI SECONDS, 1)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 1)


/obj/item/gun/kinetic/cannon
	name = "\improper Alphard 20mm cannon"
	desc = "A 20mm anti-materiel recoiling cannon. Slow but enormously powerful."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "cannon"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_LARGE
	ammo_cats = list(AMMO_CANNON_20MM)
	max_ammo_capacity = 1
	auto_eject = 1
	fire_animation = TRUE

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	can_dual_wield = 0

	slowdown = 10
	slowdown_time = 15

	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/cannon/single
	ammobag_magazines = list(/obj/item/ammo/bullets/cannon)
	ammobag_spec_required = TRUE
	ammobag_restock_cost = 3


	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/cannon)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.3)

/obj/item/gun/kinetic/recoilless
	name = "\improper Carinae RCL/120"
	desc = "An absurdly destructive 120mm recoilless gun-mortar, the largest man-portable weapon in the Almagest line."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "recoilless"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_LARGE
	ammo_cats = list(AMMO_HOWITZER)
	max_ammo_capacity = 1
	auto_eject = 1
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	can_dual_wield = 0

	slowdown = 10
	slowdown_time = 15

	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/howitzer
	ammobag_magazines = list(/obj/item/ammo/bullets/howitzer)
	ammobag_spec_required = TRUE
	ammobag_restock_cost = 5

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/howitzer)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.2)


// demo
/obj/item/gun/kinetic/grenade_launcher
	name = "\improper Rigil grenade launcher"
	desc = "A 40mm hand-held grenade launcher, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "grenade_launcher"
	item_state = "grenade_launcher"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
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

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		ammo.amount_left = max_ammo_capacity
		set_current_projectile(new/datum/projectile/bullet/grenade_round/explosive)
		..()

	attackby(obj/item/b, mob/user)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if((src.ammo.amount_left > 0 && !istype(current_projectile, /datum/projectile/bullet/grenade_shell)) || src.ammo.amount_left >= src.max_ammo_capacity)
				boutput(user, "<span class='alert'>The [src] already has something in it! You can't use the conversion chamber right now! You'll have to manually unload the [src]!</span>")
				return
			else
				var/datum/projectile/bullet/grenade_shell/custom_shell = src.current_projectile
				if(src.ammo.amount_left > 0 && istype(custom_shell) && custom_shell.get_nade().type != b.type)
					boutput(user, "<span class='alert'>The [src] has a different kind of grenade in the conversion chamber, and refuses to mix and match!</span>")
					return
				else
					SETUP_GENERIC_ACTIONBAR(user, src, 0.3 SECONDS, .proc/convert_grenade, list(b, user), b.icon, b.icon_state,"", null)
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
	icon = 'icons/obj/large/64x32.dmi' // big guns get big icons
	icon_state = "sniper"
	item_state = "sniper"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_RIFLE
	ammo_cats = list(AMMO_RIFLE_308)
	max_ammo_capacity = 6
	auto_eject = 1
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	slowdown = 7
	slowdown_time = 5

	can_dual_wield = 0
	two_handed = 1
	w_class = W_CLASS_BULKY

	shoot_delay = 1 SECOND
	default_magazine = /obj/item/ammo/bullets/rifle_762_NATO
	ammobag_magazines = list(/obj/item/ammo/bullets/rifle_762_NATO)
	ammobag_restock_cost = 3

	var/datum/movement_controller/snipermove = null

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/rifle_762_NATO)
		snipermove = new/datum/movement_controller/sniper_look()
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		snipermove = null
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.8)


	dropped(mob/M)
		remove_self(M)
		..()

	move_callback(var/mob/living/M, var/turf/source, var/turf/target)
		if (M.use_movement_controller)
			if (source != target)
				just_stop_snipe(M)

	proc/remove_self(var/mob/living/M)
		if (islist(M.move_laying))
			M.move_laying -= src
		else
			M.move_laying = null

		if (ishuman(M))
			M:special_sprint &= ~SPRINT_SNIPER

		just_stop_snipe(M)

	proc/just_stop_snipe(var/mob/living/M) // remove overlay here
		if (M.client)
			M.client.pixel_x = 0
			M.client.pixel_y = 0

		M.use_movement_controller = null
		M.keys_changed(0,0xFFFF) //This is necessary for the designator to work
		M.removeOverlayComposition(/datum/overlayComposition/sniper_scope)

	attack_hand(mob/user)
		if (..() && ishuman(user))
			user:special_sprint |= SPRINT_SNIPER
			var/mob/living/L = user

			//set move callback (when user moves, sniper go down)
			if (islist(L.move_laying))
				L.move_laying += src
			else
				if (L.move_laying)
					L.move_laying = list(L.move_laying, src)
				else
					L.move_laying = list(src)

	get_movement_controller()
		.= snipermove

/mob/living/proc/begin_sniping() //add overlay + sound here
	for (var/obj/item/gun/kinetic/sniper/S in equipped_list(check_for_magtractor = 0))
		src.use_movement_controller = S
		src.keys_changed(0,0xFFFF)
		if(!src.hasOverlayComposition(/datum/overlayComposition/sniper_scope))
			src.addOverlayComposition(/datum/overlayComposition/sniper_scope)
		playsound(src, 'sound/weapons/scope.ogg', 50, 1)
		break


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

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 10

	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_launch"


	New()
		ammo = new/obj/item/ammo/bullets/cannon
		set_current_projectile(new/datum/projectile/bullet/cannon)
		snipermove = new/datum/movement_controller/sniper_look()
		..()


	setupProperties()
		..()
		setProperty("movespeed", 0.3)*/

/obj/item/gun/kinetic/sawnoff
	name = "double-barreled shotgun"
	desc = "A double-barreled sawn-off break-action shotgun, mostly used by people who think it looks cool."
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

	var/broke_open = FALSE
	var/shells_to_eject = 0

	New() //uses a special box of ammo that only starts with 2 shells to prevent issues with overloading
		if (prob(25))
			name = pick ("Bessie", "Mule", "Loud Louis", "Boomstick", "Coach Gun", "Shorty", "Sawn-off Shotgun", "Street Sweeper", "Street Howitzer", "Big Boy", "Slugger", "Closing Time", "Garbage Day", "Rooty Tooty Point and Shooty", "Twin 12 Gauge", "Master Blaster", "Ass Blaster", "Blunderbuss", "Dr. Bullous' Thunder-Clapper", "Super Shotgun", "Insurance Policy", "Last Call", "Super-Duper Shotgun")

		ammo = new/obj/item/ammo/bullets/abg/two
		set_current_projectile(new/datum/projectile/bullet/abg)
		..()

	update_icon()
		. = ..()
		src.icon_state = "coachgun" + (gilded ? "-golden" : "") + (!src.broke_open ? "" : "-empty" )

	canshoot(mob/user)
		if (!src.broke_open)
			return TRUE
		..()

	shoot(target, start, mob/user)
		if (src.broke_open)
			boutput(user, "<span class='alert'>You need to close [src] before you can fire!</span>")
		if (!src.broke_open && src.ammo.amount_left > 0)
			src.shells_to_eject++
		..()

	attack_self(mob/user)
		if (src.broke_open)
			src.broke_open = FALSE
		else
			src.broke_open = TRUE
			src.casings_to_eject = src.shells_to_eject

			if (src.casings_to_eject > 0) //this code exists because without it the gun ejects double the amount of shells
				src.ejectcasings()
				src.shells_to_eject = 0

		playsound(user.loc, 'sound/weapons/gunload_click.ogg', 15, TRUE)

		update_icon()
		..()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/ammo/bullets) && !src.broke_open)
			boutput(user, "<span class='alert'>You can't load shells into the chambers! You'll have to open [src] first!</span>")
			return
		..()

	attack_hand(mob/user)
		if (!src.broke_open && user.find_in_hand(src))
			boutput(user, "<span class='alert'>[src] is still closed, you need to open the action to take the shells out!</span>")
			return
		..()

	alter_projectile(obj/projectile/P)
		. = ..()
		P.proj_data.shot_sound = 'sound/weapons/sawnoff.ogg'
