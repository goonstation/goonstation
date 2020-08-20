/obj/item/gun/kinetic
	name = "kinetic weapon"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "gun"
	m_amt = 2000
	var/obj/item/ammo/bullets/ammo = null
	var/max_ammo_capacity = 1 // How much ammo can this gun hold? Don't make this null (Convair880).
	var/caliber = null // Can be a list too. The .357 Mag revolver can also chamber .38 Spc rounds, for instance (Convair880).

	var/auto_eject = 0 // Do we eject casings on firing, or on reload?
	var/casings_to_eject = 0 // If we don't automatically ejected them, we need to keep track (Convair880).

	add_residue = 1 // Does this gun add gunshot residue when fired? Kinetic guns should (Convair880).

	var/allowReverseReload = 1 //Use gun on ammo to reload
	var/allowDropReload = 1    //Drag&Drop ammo onto gun to reload

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
		src.update_icon()

	examine()
		. = ..()
		if (src.ammo && (src.ammo.amount_left > 0))
			var/datum/projectile/ammo_type = src.ammo
			. += "There are [src.ammo.amount_left][(ammo_type.material && istype(ammo_type, /datum/material/metal/silver)) ? " silver " : " "]bullets of [src.ammo.sname] left!"
		else
			. += "There are 0 bullets left!"
		if (current_projectile)
			. += "Each shot will currently use [src.current_projectile.cost] bullets!"
		else
			. += "<span class='alert'>*ERROR* No output selected!</span>"

	update_icon()
		if (src.ammo)
			inventory_counter.update_number(src.ammo.amount_left)
		else
			inventory_counter.update_text("-")
		return 0

	canshoot()
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
			playsound(user, "sound/weapons/Gunclick.ogg", 60, 1)
		return 0

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/item/ammo/bullets) && allowDropReload)
			attackby(O, user)
		return ..()

	attackby(obj/item/ammo/bullets/b as obj, mob/user as mob)
		if(istype(b, /obj/item/ammo/bullets))
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
					src.logme_temp(user, src, b) // Might be useful (Convair880).
					return
				if(5)
					user.visible_message("<span class='alert'>[user] reloads [src].</span>", "<span class='alert'>You fully reload [src] with ammo from [b.name]. There are [b.amount_left] rounds left in [b.name].</span>")
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

	attack_hand(mob/user as mob)
	// Added this to make manual reloads possible (Convair880).

		if ((src.loc == user) && user.find_in_hand(src)) // Make sure it's not on the belt or in a backpack.
			src.add_fingerprint(user)
			if (src.sanitycheck(0, 1) == 0)
				user.show_text("You can't unload this gun.", "red")
				return
			if (src.ammo.amount_left <= 0)
				// The gun may have been fired; eject casings if so.
				if ((src.casings_to_eject > 0) && src.current_projectile.casing)
					if (src.sanitycheck(1, 0) == 0)
						logTheThing("debug", usr, null, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the casings_to_eject cap, aborting.")
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
			ammoHand.update_icon()
			user.put_in_hand_or_drop(ammoHand)

			// The gun may have been fired; eject casings if so.
			src.ejectcasings()
			src.casings_to_eject = 0

			src.update_icon()
			src.ammo.amount_left = 0
			src.add_fingerprint(user)
			ammoHand.add_fingerprint(user)

			user.visible_message("<span class='alert'>[user] unloads [src].</span>", "<span class='alert'>You unload [src].</span>")
			//DEBUG_MESSAGE("Unloaded [src]'s ammo manually.")
			return

		return ..()

	attack(mob/M as mob, mob/user as mob)
	// Finished Cogwerks' former WIP system (Convair880).
		if (src.canshoot() && user.a_intent != "help" && user.a_intent != "grab")
			if (src.auto_eject)
				var/turf/T = get_turf(src)
				if(T)
					if (src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
						var/number_of_casings = max(1, src.current_projectile.shot_number)
						//DEBUG_MESSAGE("Ejected [number_of_casings] casings from [src].")
						for (var/i = 1, i <= number_of_casings, i++)
							var/obj/item/casing/C = new src.current_projectile.casing(T)
							C.forensic_ID = src.forensic_ID
							C.loc = T
			else
				if (src.casings_to_eject < 0)
					src.casings_to_eject = 0
				src.casings_to_eject += src.current_projectile.shot_number
		..()

	shoot(var/target,var/start ,var/mob/user)
		if (src.canshoot())
			if (src.auto_eject)
				var/turf/T = get_turf(src)
				if(T)
					if (src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
						var/number_of_casings = max(1, src.current_projectile.shot_number)
						//DEBUG_MESSAGE("Ejected [number_of_casings] casings from [src].")
						for (var/i = 1, i <= number_of_casings, i++)
							var/obj/item/casing/C = new src.current_projectile.casing(T)
							C.forensic_ID = src.forensic_ID
							C.loc = T
			else
				if (src.casings_to_eject < 0)
					src.casings_to_eject = 0
				src.casings_to_eject += src.current_projectile.shot_number
		..()

	proc/ejectcasings()
		if ((src.casings_to_eject > 0) && src.current_projectile.casing && (src.sanitycheck(1, 0) == 1))
			var/turf/T = get_turf(src)
			if(T)
				//DEBUG_MESSAGE("Ejected [src.casings_to_eject] [src.current_projectile.casing] from [src].")
				var/obj/item/casing/C = null
				while (src.casings_to_eject > 0)
					C = new src.current_projectile.casing(T)
					C.forensic_ID = src.forensic_ID
					C.loc = T
					src.casings_to_eject--
		return

	// Don't set this too high. Absurdly large reloads and item spawning can cause a lot of lag. (Convair880).
	proc/sanitycheck(var/casings = 0, var/ammo = 1)
		if (casings && (src.casings_to_eject > 30 || src.current_projectile.shot_number > 30))
			logTheThing("debug", usr, null, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the casings_to_eject cap, aborting.")
			if (src.casings_to_eject > 0)
				src.casings_to_eject = 0
			return 0
		if (ammo && (src.max_ammo_capacity > 200 || src.ammo.amount_left > 200))
			logTheThing("debug", usr, null, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the magazine cap, aborting.")
			return 0
		return 1

/obj/item/casing
	name = "bullet casing"
	desc = "A spent casing from a bullet of some sort."
	icon = 'icons/obj/items/casings.dmi'
	icon_state = "medium"
	w_class = 1
	var/forensic_ID = null

	small
		icon_state = "small"
		desc = "Seems to be a small pistol cartridge."

	medium
		icon_state = "medium"
		desc = "Seems to be a common revolver cartridge."

	rifle
		icon_state = "rifle"
		desc = "Seems to be a rifle cartridge."

	derringer
		icon_state = "medium"
		desc = "A fat and stumpy bullet casing. Looks pretty old."

	shotgun_red
		icon_state = "shotgun_red"
		desc = "A red shotgun shell."

	shotgun_blue
		icon_state = "shotgun_blue"
		desc = "A blue shotgun shell."

	shotgun_orange
		icon_state = "shotgun_orange"
		desc = "An orange shotgun shell."

	shotgun_gray
		icon_state = "shotgun_gray"
		desc = "An gray shotgun shell."

	cannon
		icon_state = "rifle"
		desc = "A cannon shell."
		w_class = 2

	grenade
		w_class = 2
		icon_state = "40mm"
		desc = "A 40mm grenade round casing. Huh."

	New()
		..()
		src.pixel_y += rand(-12,12)
		src.pixel_x += rand(-12,12)
		src.dir = pick(alldirs)
		return

/obj/item/gun/kinetic/minigun
	name = "Minigun"
	desc = "The M134 Minigun is a 7.62×51mm NATO, six-barrel rotary machine gun with a high rate of fire."
	icon_state = "minigun"
	item_state = "heavy"
	force = 5
	caliber = 0.308
	max_ammo_capacity = 100
	auto_eject = 1

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	spread_angle = 25
	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 15

	two_handed = 1
	w_class = 4

	New()
		ammo = new/obj/item/ammo/bullets/minigun
		current_projectile = new/datum/projectile/bullet/minigun
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.4)

/obj/item/gun/kinetic/revolver
	name = "CPA Predator MKII"
	desc = "A hefty combat revolver developed by Cormorant Precision Arms. Uses .357 caliber rounds."
	icon_state = "revolver"
	item_state = "revolver"
	force = 8.0
	caliber = list(0.38, 0.357) // Just like in RL (Convair880).
	max_ammo_capacity = 7

	New()
		ammo = new/obj/item/ammo/bullets/a357
		current_projectile = new/datum/projectile/bullet/revolver_357
		..()

/obj/item/gun/kinetic/revolver/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/gun/kinetic/derringer
	name = "derringer"
	desc = "A small and easy-to-hide gun that comes with 2 shots. (Can be hidden in worn clothes and retrieved by using the wink emote)"
	icon_state = "derringer"
	force = 5.0
	caliber = 0.41
	max_ammo_capacity = 2
	w_class = 2
	muzzle_flash = null

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
		ammo = new/obj/item/ammo/bullets/derringer
		current_projectile = new/datum/projectile/bullet/derringer
		..()

/obj/item/gun/kinetic/faith
	name = "Faith"
	desc = "'Cause ya gotta have Faith."
	icon_state = "faith"
	force = 5.0
	caliber = 0.22
	max_ammo_capacity = 4
	auto_eject = 1
	w_class = 2
	muzzle_flash = null

	New()
		ammo = new/obj/item/ammo/bullets/bullet_22/faith
		current_projectile = new/datum/projectile/bullet/bullet_22
		..()

	update_icon()
		..()
		if (src.ammo.amount_left < 1)
			src.icon_state = "faith-empty"
		else
			src.icon_state = "faith"
		return

/obj/item/gun/kinetic/detectiverevolver
	name = "CPA Detective Special"
	desc = "A snubnosed police-issue revolver developed by Cormorant Precision Arms. Uses .38-Special rounds."
	icon_state = "detective"
	item_state = "detective"
	w_class = 2.0
	force = 2.0
	caliber = 0.38
	max_ammo_capacity = 7

	New()
		ammo = new/obj/item/ammo/bullets/a38/stun
		current_projectile = new/datum/projectile/bullet/revolver_38/stunners
		..()

/obj/item/gun/kinetic/colt_saa
	name = "colt saa revolver"
	desc = "A nearly adequate replica of a nearly ancient single action revolver. Used by war reenactors for the last hundred years or so."
	icon_state = "colt_saa"
	item_state = "colt_saa"
	w_class = 3.0
	force = 5.0
	caliber = 0.45
	spread_angle = 1
	max_ammo_capacity = 7
	var/hammer_cocked = 0

	detective
		name = "peacemaker"
		desc = "A barely adequate replica of a nearly ancient single action revolver. Used by war reenactors for the last hundred years or so. Its calibur is obviously the wrong size though."
		w_class = 2.0
		force = 2.0
		caliber = 0.38
		New()
			..()
			ammo = new/obj/item/ammo/bullets/a38/stun
			current_projectile = new/datum/projectile/bullet/revolver_38/stunners

	New()
		ammo = new/obj/item/ammo/bullets/c_45
		current_projectile = new/datum/projectile/bullet/revolver_45
		..()

	canshoot()
		if (hammer_cocked)
			return ..()
		else
			return 0
	shoot(var/target,var/start ,var/mob/user)
		..()
		hammer_cocked = 0
		icon_state = "colt_saa"

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (hammer_cocked)
			hammer_cocked = 0
			icon_state = "colt_saa"
			boutput(user, "<span class='notice'>You gently lower the weapon's hammer!</span>")
		else
			hammer_cocked = 1
			icon_state = "colt_saa-c"
			boutput(user, "<span class='alert'>You cock the hammer!</span>")
			playsound(user.loc, "sound/weapons/gun_cocked_colt45.ogg", 70, 1)

/obj/item/gun/kinetic/clock_188
	desc = "A reliable weapon used the world over... 50 years ago. Uses 9mm NATO rounds."
	name = "Clock 188"
	icon_state = "clock-188-beige"
	item_state = "clock-188-beige"
	shoot_delay = 2
	w_class = 2.0
	force = 7.0
	caliber = 0.355
	max_ammo_capacity = 18
	auto_eject = 1

	New()
		if (prob(30))
			icon_state = "clock-188-black"
			item_state = "clock-188-black"

		ammo = new/obj/item/ammo/bullets/nine_mm_NATO
		current_projectile = new/datum/projectile/bullet/nine_mm_NATO
		projectiles = list(current_projectile,new/datum/projectile/bullet/nine_mm_NATO/burst)
		..()

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/nine_mm_NATO/burst))
			spread_angle = 5
		else
			spread_angle = 0

	update_icon()
		..()
		if (src.item_state == "clock-188-black")
			if (src.ammo.amount_left < 1)
				src.icon_state = "clock-188-black_empty"
			else
				src.icon_state = "clock-188-black"
		else
			if (src.ammo.amount_left < 1)
				src.icon_state = "clock-188-beige_empty"
			else
				src.icon_state = "clock-188-beige"
		return

/obj/item/gun/kinetic/spes
	name = "SPES-12"
	desc = "Multi-purpose high-grade military shotgun. Very spiffy."
	icon_state = "shotgun"
	item_state = "shotgun"
	force = 18.0
	contraband = 7
	caliber = 0.72
	max_ammo_capacity = 8
	auto_eject = 1
	can_dual_wield = 0

	New()
		if(prob(10))
			name = pick("SPEZZ-12", "SPESS-12", "SPETZ-12", "SPOCK-12", "SCHPATZL-12", "SABRINA-12", "SAURUS-12", "SABER-12", "SOSIG-12", "DINOHUNTER-12", "PISS-12", "ASS-12", "SPES-12", "SHIT-12", "SHOOT-12", "SHOTGUN-12", "FAMILYGUY-12", "SPAGOOTER-12")
		ammo = new/obj/item/ammo/bullets/a12
		current_projectile = new/datum/projectile/bullet/a12
		..()

	custom_suicide = 1
	suicide(var/mob/living/carbon/human/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (!istype(user) || !src.canshoot())//!hasvar(usr,"organHolder")) STOP IT STOP IT HOLY SHIT STOP WHY DO YOU USE HASVAR FOR THIS, ONLY HUMANS HAVE ORGANHOLDERS
			return 0

		src.process_ammo(user)
		var/hisher = his_or_her(user)
		user.visible_message("<span class='alert'><b>[user] places [src]'s barrel in [hisher] mouth and pulls the trigger with [hisher] foot!</b></span>")
		var/obj/head = user.organHolder.drop_organ("head")
		qdel(head)
		playsound(src, "sound/weapons/shotgunshot.ogg", 100, 1)
		var/obj/decal/cleanable/blood/gibs/gib = make_cleanable( /obj/decal/cleanable/blood/gibs,get_turf(user))
		gib.streak(turn(user.dir,180))
		health_update_queue |= user
		return 1

	engineer
		name = "SPES-6" // it's half as good

		New()
			..()
			ammo = new/obj/item/ammo/bullets/a12/weak
			current_projectile = new/datum/projectile/bullet/a12/weak


/obj/item/gun/kinetic/spes/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/gun/kinetic/riotgun
	name = "Riot Shotgun"
	desc = "A police-issue shotgun meant for suppressing riots."
	icon_state = "shotgund"
	item_state = "shotgund"
	force = 15.0
	contraband = 5
	caliber = 0.72
	max_ammo_capacity = 8
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1

	New()
		ammo = new/obj/item/ammo/bullets/abg
		current_projectile = new/datum/projectile/bullet/abg
		..()

/obj/item/gun/kinetic/riotgun/pbr

	New()
		ammo = new/obj/item/ammo/bullets/pbr
		current_projectile = new/datum/projectile/bullet/pbr
		..()

/obj/item/gun/kinetic/ak47
	name = "AK-744 Rifle"
	desc = "Based on an old Cold War relic, often used by paramilitary organizations and space terrorists."
	icon = 'icons/obj/64x32.dmi' // big guns get big icons
	icon_state = "ak47"
	item_state = "ak47"
	force = 30.0
	contraband = 8
	caliber = 0.308
	max_ammo_capacity = 30 // It's magazine-fed (Convair880).
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1

	New()
		ammo = new/obj/item/ammo/bullets/ak47
		current_projectile = new/datum/projectile/bullet/ak47
		..()

/obj/item/gun/kinetic/ak47/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/gun/kinetic/hunting_rifle
	name = "Old Hunting Rifle"
	desc = "A powerful antique hunting rifle."
	icon_state = "hunting_rifle"
	item_state = "hunting_rifle"
	force = 10
	contraband = 8
	caliber = 0.308
	max_ammo_capacity = 30 // It's magazine-fed (Convair880).
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1

	New()
		ammo = new/obj/item/ammo/bullets/rifle_3006
		current_projectile = new/datum/projectile/bullet/rifle_3006
		..()

/obj/item/gun/kinetic/hunting_rifle/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/gun/kinetic/dart_rifle
	name = "Tranquilizer Rifle"
	desc = "A veterinary tranquilizer rifle chambered in .308 caliber."
	icon_state = "dart_rifle"
	item_state = "hunting_rifle"
	force = 10
	//contraband = 8
	caliber = 0.308
	max_ammo_capacity = 30 // It's magazine-fed (Convair880).
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1

	New()
		ammo = new/obj/item/ammo/bullets/tranq_darts
		current_projectile = new/datum/projectile/bullet/tranq_dart
		..()

/obj/item/gun/kinetic/zipgun
	name = "Zip Gun"
	desc = "An improvised and unreliable gun."
	icon_state = "zipgun"
	force = 3
	contraband = 6
	caliber = null // use any ammo at all BA HA HA HA HA
	max_ammo_capacity = 2
	var/failure_chance = 6
	var/failured = 0

	New()
#if ASS_JAM
		var/turf/T = get_turf(src)
		playsound(T, "sound/items/Deconstruct.ogg", 50, 1)
		new/obj/item/gun/kinetic/slamgun(T)
		qdel(src)
		return // Sorry! No zipguns during ASS JAM
#else
		ammo = new/obj/item/ammo/bullets/derringer
		ammo.amount_left = 0 // start empty
		current_projectile = new/datum/projectile/bullet/derringer
		..()
#endif

	shoot(var/target,var/start ,var/mob/user)
		if(failured)
			var/turf/T = get_turf(src)
			explosion(src, T,-1,-1,1,2)
			qdel(src)
		if(ammo && ammo.amount_left && current_projectile && current_projectile.caliber && current_projectile.power)
			failure_chance = max(0,min(33,round(current_projectile.power/2 - 9)))
		if(canshoot() && prob(failure_chance)) // Empty zip guns had a chance of blowing up. Stupid (Convair880).
			failured = 1
			if(prob(failure_chance))	// Sometimes the failure is obvious
				playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 50, 1)
				boutput(user, "<span class='alert'>The [src]'s shodilly thrown-together [pick("breech", "barrel", "bullet holder", "firing pin", "striker", "staple-driver mechanism", "bendy metal part", "shooty-bit")][pick("", "...thing")] [pick("cracks", "pops off", "bends nearly in half", "comes loose")]!</span>")
			else						// Other times, less obvious
				playsound(src.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 50, 1)
		..()
		return

/obj/item/gun/kinetic/silenced_22
	name = "STL Orion"
	desc = "A small pistol with an integrated flash and noise suppressor, developed by Specter Tactical Laboratory. Uses .22 rounds."
	icon_state = "silenced"
	w_class = 2
	silenced = 1
	force = 3
	contraband = 4
	caliber = 0.22
	max_ammo_capacity = 10
	auto_eject = 1
	hide_attack = 1
	muzzle_flash = null

	New()
		ammo = new/obj/item/ammo/bullets/bullet_22HP
		current_projectile = new/datum/projectile/bullet/bullet_22/HP
		..()

	update_icon()
		..()
		if (src.ammo.amount_left < 1)
			src.icon_state = "silenced_empty"
		else
			src.icon_state = "silenced"
		return

/obj/item/gun/kinetic/vgun
	name = "Virtual Pistol"
	desc = "This thing would be better if it wasn't such a piece of shit."
	icon_state = "railgun"
	force = 10.0
	contraband = 0
	max_ammo_capacity = 200

	New()
		ammo = new/obj/item/ammo/bullets/vbullet
		current_projectile = new/datum/projectile/bullet/vbullet
		..()

	shoot(var/target,var/start ,var/mob/user)
		var/turf/T = get_turf_loc(src)

		if (!istype(T.loc, /area/sim))
			boutput(user, "<span class='alert'>You can't use the guns outside of the combat simulation, fuckhead!</span>")
			return
		else
			..()

/obj/item/gun/kinetic/flaregun
	desc = "A 12-gauge flaregun."
	name = "Flare Gun"
	icon_state = "flaregun"
	item_state = "flaregun"
	force = 5.0
	contraband = 2
	caliber = 0.72
	max_ammo_capacity = 1

	New()
		ammo = new/obj/item/ammo/bullets/flare/single
		current_projectile = new/datum/projectile/bullet/flare
		..()

/obj/item/gun/kinetic/riot40mm
	desc = "A 40mm riot control launcher."
	name = "Riot launcher"
	icon_state = "40mm"
	//item_state = "flaregun"
	force = 5.0
	contraband = 7
	caliber = 1.57
	max_ammo_capacity = 1
	muzzle_flash = "muzzle_flash_launch"

	New()
		ammo = new/obj/item/ammo/bullets/smoke/single
		current_projectile = new/datum/projectile/bullet/smoke
		..()

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if(src.ammo.amount_left > 0)
				boutput(user, "<span class='alert'>The [src] already has something in it! You can't use the conversion chamber right now! You'll have to manually unload the [src]!</span>")
				return
			else
				var/obj/item/ammo/bullets/grenade_shell/TO_LOAD = new /obj/item/ammo/bullets/grenade_shell
				TO_LOAD.attackby(b, user)
				src.attackby(TO_LOAD, user)
				return
		else
			..()


// Ported from old, non-gun RPG-7 object class (Convair880).
/obj/item/gun/kinetic/rpg7
	desc = "A rocket-propelled grenade launcher licensed by the Space Irish Republican Army."
	name = "MPRT-7"
	icon = 'icons/obj/64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "rpg7_empty"
	uses_multiple_icon_states = 1
	item_state = "rpg7_empty"
	wear_image_icon = 'icons/mob/back.dmi'
	flags = ONBACK
	w_class = 4
	throw_speed = 2
	throw_range = 4
	force = 5
	contraband = 8
	caliber = 1.58
	max_ammo_capacity = 1
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"

	New()
		ammo = new /obj/item/ammo/bullets/rpg
		ammo.amount_left = 0 // Spawn empty.
		current_projectile = new /datum/projectile/bullet/rpg
		..()
		return

	update_icon()
		..()
		if (src.ammo.amount_left < 1)
			src.icon_state = "rpg7_empty"
			src.item_state = "rpg7_empty"
		else
			src.icon_state = "rpg7"
			src.item_state = "rpg7"
		return

	loaded
		New()
			..()
			ammo.amount_left = 1
			src.update_icon()
			return

/obj/item/gun/kinetic/coilgun_TEST
	name = "coil gun"
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "coilgun_2"
	item_state = "flaregun"
	force = 10.0
	contraband = 6
	caliber = 1.0
	max_ammo_capacity = 2

	New()
		ammo = new/obj/item/ammo/bullets/rod
		current_projectile = new/datum/projectile/bullet/rod
		..()

/obj/item/gun/kinetic/airzooka //This is technically kinetic? I guess?
	name = "Airzooka"
	desc = "The new double action air projection device from Donk Co!"
	icon_state = "airzooka"
	max_ammo_capacity = 10
	caliber = 4.6 // I rolled a dice
	muzzle_flash = "muzzle_flash_launch"

	New()
		ammo = new/obj/item/ammo/bullets/airzooka
		current_projectile = new/datum/projectile/bullet/airzooka
		..()

/obj/item/gun/kinetic/smg //testing keelin's continuous fire POC
	name = "submachine gun"
	desc = "An automatic submachine gun"
	icon_state = "walthery1"
	w_class = 2
	force = 3
	contraband = 4
	caliber = 0.355
	max_ammo_capacity = 30
	auto_eject = 1

	continuous = 1
	c_interval = 1.1

	New()
		ammo = new/obj/item/ammo/bullets/bullet_9mm/smg
		current_projectile = new/datum/projectile/bullet/bullet_9mm/smg
		..()

//  <([['v') - Gannets Nuke Ops Class Guns - ('u']])>  //

// agent
/obj/item/gun/kinetic/pistol
	name = "M1992 pistol"
	desc = "A semi-automatic, 9mm caliber service pistol issued by the Syndicate."
	icon_state = "9mm_pistol"
	w_class = 2
	force = 3
	contraband = 4
	caliber = 0.355
	max_ammo_capacity = 15
	auto_eject = 1

	New()
		ammo = new/obj/item/ammo/bullets/bullet_9mm
		current_projectile = new/datum/projectile/bullet/bullet_9mm
		..()

	update_icon()
		..()
		if (src.ammo.amount_left < 1)
			src.icon_state = "9mm_pistol_empty"
		else
			src.icon_state = "9mm_pistol"
		return

/obj/item/gun/kinetic/tranq_pistol
	name = "tranquilizer pistol"
	desc = "A silenced tranquilizer pistol chambered in .308 caliber."
	icon_state = "tranq_pistol"
	item_state = "tranq_pistol"
	w_class = 2
	force = 3
	contraband = 4
	caliber = 0.355
	max_ammo_capacity = 30
	auto_eject = 0
	hide_attack = 1
	muzzle_flash = null

	New()
		ammo = new/obj/item/ammo/bullets/tranq_darts/syndicate/pistol
		current_projectile = new/datum/projectile/bullet/tranq_dart/syndicate/pistol
		..()

// scout
/obj/item/gun/kinetic/tactical_shotgun //just a reskin, unused currently
	name = "tactical shotgun"
	desc = "Multi-purpose high-grade military shotgun, painted a menacing black colour."
	icon_state = "tactical_shotgun"
	item_state = "shotgun"
	force = 5
	contraband = 7
	caliber = 0.72
	max_ammo_capacity = 8
	auto_eject = 1
	two_handed = 1
	can_dual_wield = 0

	New()
		ammo = new/obj/item/ammo/bullets/buckshot_burst
		current_projectile = new/datum/projectile/special/spreader/buckshot_burst/
		..()

/////////////////////////////////////////////////////////////////////////////////////////////
/*  //  how about not putting a goddamn irl suicide threat into the game??? fuck this content
/////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/gun/kinetic/tactical_shotgun/oblivion //"I've a gun named Oblivion that'll take all the pain away.. All our pain away..."
	name = "Oblivion"
	New()
		return

*/ /////////////////////////////////////////////////////////////////////////////////////////

// assault
/obj/item/gun/kinetic/assault_rifle
	name = "M19A4 assault rifle"
	desc = "A modified Syndicate battle rifle fitted with several fancy, tactically useless attachments."
	icon = 'icons/obj/64x32.dmi'
	icon_state = "assault_rifle"
	item_state = "assault_rifle"
	force = 20.0
	contraband = 8
	caliber = 0.223
	max_ammo_capacity = 30
	auto_eject = 1
	object_flags = NO_ARM_ATTACH

	two_handed = 1
	can_dual_wield = 0
	spread_angle = 0

	New()
		ammo = new/obj/item/ammo/bullets/assault_rifle
		current_projectile = new/datum/projectile/bullet/assault_rifle
		projectiles = list(current_projectile,new/datum/projectile/bullet/assault_rifle/burst)
		..()

	attackby(obj/item/ammo/bullets/b, mob/user)  // has to account for whether regular or armor-piercing ammo is loaded AND which firing mode it's using
		var/obj/previous_ammo = ammo
		var/mode_was_burst = (istype(current_projectile, /datum/projectile/bullet/assault_rifle/burst/))  // was previous mode burst fire?
		..()
		if(previous_ammo.type != ammo.type)  // we switched ammo types
			if(istype(ammo, /obj/item/ammo/bullets/assault_rifle/armor_piercing)) // we switched from normal to armor_piercing
				if(mode_was_burst) // we were in burst shot mode
					current_projectile = new/datum/projectile/bullet/assault_rifle/burst/armor_piercing
					projectiles = list(new/datum/projectile/bullet/assault_rifle/armor_piercing, current_projectile)
				else // we were in single shot mode
					current_projectile = new/datum/projectile/bullet/assault_rifle/armor_piercing
					projectiles = list(current_projectile, new/datum/projectile/bullet/assault_rifle/burst/armor_piercing)
			else // we switched from armor penetrating ammo to normal
				if(mode_was_burst) // we were in burst shot mode
					current_projectile = new/datum/projectile/bullet/assault_rifle/burst
					projectiles = list(new/datum/projectile/bullet/assault_rifle, current_projectile)
				else // we were in single shot mode
					current_projectile = new/datum/projectile/bullet/assault_rifle
					projectiles = list(current_projectile, new/datum/projectile/bullet/assault_rifle/burst)

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/assault_rifle/burst/))
			spread_angle = 8
		else
			spread_angle = 0



// heavy
/obj/item/gun/kinetic/light_machine_gun
	name = "M90 machine gun"
	desc = "Looks pretty heavy to me."
	icon = 'icons/obj/64x32.dmi'
	icon_state = "lmg"
	item_state = "lmg"
	wear_image_icon = 'icons/mob/back.dmi'
	force = 5
	caliber = 0.308
	max_ammo_capacity = 100
	auto_eject = 1

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	spread_angle = 8
	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 10

	two_handed = 1
	w_class = 4

	New()
		ammo = new/obj/item/ammo/bullets/lmg
		current_projectile = new/datum/projectile/bullet/lmg
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.5)


/obj/item/gun/kinetic/cannon
	name = "M20-CV tactical cannon"
	desc = "A shortened conversion of a 20mm military cannon. Slow but enormously powerful."
	icon = 'icons/obj/64x32.dmi'
	icon_state = "cannon"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/back.dmi'
	force = 10
	caliber = 0.787
	max_ammo_capacity = 1
	auto_eject = 1

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	can_dual_wield = 0

	slowdown = 10
	slowdown_time = 15

	two_handed = 1
	w_class = 4
	muzzle_flash = "muzzle_flash_launch"


	New()
		ammo = new/obj/item/ammo/bullets/cannon/single
		current_projectile = new/datum/projectile/bullet/cannon
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.3)



// demo
/obj/item/gun/kinetic/grenade_launcher
	desc = "A 40mm hand-held grenade launcher able to fire a variety of explosives."
	name = "grenade launcher"
	icon = 'icons/obj/64x32.dmi'
	icon_state = "grenade_launcher"
	item_state = "grenade_launcher"
	force = 5.0
	contraband = 7
	caliber = 1.57
	max_ammo_capacity = 4 // to fuss with if i want 6 packs of ammo
	two_handed = 1
	can_dual_wield = 0
	object_flags = NO_ARM_ATTACH

	New()
		ammo = new/obj/item/ammo/bullets/grenade_round/explosive
		current_projectile = new/datum/projectile/bullet/grenade_round/explosive
		..()

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if(src.ammo.amount_left > 0)
				boutput(user, "<span class='alert'>The [src] already has something in it! You can't use the conversion chamber right now! You'll have to manually unload the [src]!</span>")
				return
			else
				var/obj/item/ammo/bullets/grenade_shell/TO_LOAD = new /obj/item/ammo/bullets/grenade_shell
				TO_LOAD.attackby(b, user)
				src.attackby(TO_LOAD, user)
				return
		else
			..()

// slamgun
/obj/item/gun/kinetic/slamgun
	// perhaps refactor later to allow for easy creation of 'manual extract weapons'?
	// would allow easy implementation of other weps such as weldrods
	name = "slamgun"
	desc = "A 12 gauge shotgun. Apparently. It's just two pipes stacked together."
	icon = 'icons/obj/slamgun.dmi'
	icon_state = "slamgun-ready"
	inhand_image_icon = 'icons/obj/slamgun.dmi'
	item_state = "slamgun-ready-world"
	force = 9
	caliber = 0.72
	max_ammo_capacity = 1
	auto_eject = 0
	spread_angle = 10 // sorry, no sniping with slamguns

	can_dual_wield = 0
	two_handed = 1
	w_class = 4
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	New()
		current_projectile = new/datum/projectile/bullet/nails
		ammo = new /obj/item/ammo/bullets/a12
		ammo.amount_left = 0 // Spawn empty.
		..()

	attack_self(mob/user as mob)
		if (src.icon_state == "slamgun-ready")
			w_class = 3
			if (src.ammo.amount_left > 0 || src.casings_to_eject > 0)
				src.icon_state = "slamgun-open-loaded"
			else
				src.icon_state = "slamgun-open"
			update_icon()
			two_handed = 0
			user.updateTwoHanded(src, 0)
			user.update_inhands()
		else
			w_class = 4
			src.icon_state = "slamgun-ready"
			update_icon()
			two_handed = 1
			user.updateTwoHanded(src, 1)
			user.update_inhands()
		..()

	canshoot()
		if (src.icon_state == "slamgun-ready")
			return ..()
		else
			return 0

	attack_hand(mob/user as mob)
		if ((src.loc == user) && user.find_in_hand(src))
			return // Not unloading like that.
		..()

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

	MouseDrop(atom/over_object, src_location, over_location, params)
		if (usr.stat || usr.restrained() || !can_reach(usr, src) || usr.getStatusDuration("paralysis") || usr.sleeping || usr.lying || isAIeye(usr) || isAI(usr) || isghostcritter(usr))
			return ..()
		if (over_object == usr && src.icon_state == "slamgun-open-loaded") // sorry for doing it like this, but i have no idea how to do it cleaner.
			src.add_fingerprint(usr)
			if (src.sanitycheck(0, 1) == 0)
				usr.show_text("You can't unload this gun.", "red")
				return
			if (src.ammo.amount_left <= 0)
				if ((src.casings_to_eject > 0))
					if (src.sanitycheck(1, 0) == 0)
						src.casings_to_eject = 0
						return
					else
						usr.show_text("You eject [src.casings_to_eject] casings from [src].", "red")
						src.ejectcasings()
						src.casings_to_eject = 0 // needed for bullets that don't have casings (???)
						src.update_icon()
						return
				else
					usr.show_text("[src] is empty!", "red")
					return

			// Make a copy here to avoid item teleportation issues.
			var/obj/item/ammo/bullets/ammoHand = new src.ammo.type
			ammoHand.amount_left = src.ammo.amount_left
			ammoHand.name = src.ammo.name
			ammoHand.icon = src.ammo.icon
			ammoHand.icon_state = src.ammo.icon_state
			ammoHand.ammo_type = src.ammo.ammo_type
			ammoHand.delete_on_reload = 1 // No duplicating empty magazines, please (Convair880).
			ammoHand.update_icon()
			usr.put_in_hand_or_drop(ammoHand)

			// The gun may have been fired; eject casings if so.
			src.ejectcasings()
			src.casings_to_eject = 0

			src.ammo.amount_left = 0
			src.update_icon()

			src.add_fingerprint(usr)
			ammoHand.add_fingerprint(usr)

			usr.visible_message("<span class='alert'>[usr] unloads [src].</span>", "<span class='alert'>You unload [src].</span>")
			return
		..()

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/ammo/bullets) && src.icon_state == "slamgun-ready")
			boutput(user, "<span class='alert'>You can't shove shells down the barrel! You'll have to open the [src]!</span>")
			return
		if (istype(b, /obj/item/ammo/bullets) && (src.ammo.amount_left > 0 || src.casings_to_eject > 0))
			boutput(user, "<span class='alert'>The [src] already has a shell inside! You'll have to unload the [src]!</span>")
			return
		..()

// sniper
/obj/item/gun/kinetic/sniper
	name = "S90A1 marksman's rifle"
	desc = "The Syndicate standard issue bolt-action sniper rifle, for engaging hostiles at range."
	icon = 'icons/obj/64x32.dmi' // big guns get big icons
	icon_state = "sniper"
	item_state = "sniper"
	wear_image_icon = 'icons/mob/back.dmi'
	force = 5
	caliber = 0.308
	max_ammo_capacity = 4
	auto_eject = 1
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	slowdown = 7
	slowdown_time = 5

	can_dual_wield = 0
	two_handed = 1
	w_class = 4

	var/datum/movement_controller/snipermove = null

	New()
		ammo = new/obj/item/ammo/bullets/rifle_762_NATO
		current_projectile = new/datum/projectile/bullet/rifle_762_NATO
		snipermove = new/datum/movement_controller/sniper_look()
		..()

	disposing()
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
		M.keys_changed(0,0xFFFF)
		M.removeOverlayComposition(/datum/overlayComposition/sniper_scope)

	attack_hand(mob/user as mob)
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
		playsound(get_turf(src), "sound/weapons/scope.ogg", 50, 1)
		break


// WIP //////////////////////////////////
/*/obj/item/gun/kinetic/sniper/antimateriel
	name = "M20-S antimateriel cannon"
	desc = "A ruthlessly powerful rifle chambered for a 20mm cannon round. Built to destroy vehicles and infrastructure at range."
	icon = 'icons/obj/64x32.dmi'
	icon_state = "antimateriel"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/back.dmi'
	force = 10
	caliber = 0.787
	max_ammo_capacity = 5
	auto_eject = 1

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 10

	two_handed = 1
	w_class = 4
	muzzle_flash = "muzzle_flash_launch"


	New()
		ammo = new/obj/item/ammo/bullets/cannon
		current_projectile = new/datum/projectile/bullet/cannon
		snipermove = new/datum/movement_controller/sniper_look()
		..()


	setupProperties()
		..()
		setProperty("movespeed", 0.3)*/

/obj/item/gun/kinetic/flintlockpistol
	name = "flintlock pistol"
	desc = "A powerful antique flintlock pistol."
	icon_state = "flintlock"
	item_state = "flintlock"
	force = 4
	contraband = 0 //It's so old that futuristic security scanners don't even recognize it.
	caliber = 0.58
	max_ammo_capacity = 1 // It's magazine-fed (Convair880).
	auto_eject = null
	var/failure_chance = 1

	New()
		ammo = new/obj/item/ammo/bullets/flintlock
		current_projectile = new/datum/projectile/bullet/flintlock
		..()

	shoot()
		if(ammo && ammo.amount_left && current_projectile && current_projectile.caliber && current_projectile.power)
			failure_chance = max(10,min(33,round(current_projectile.caliber * (current_projectile.power/2))))
		if(canshoot() && prob(failure_chance))
			var/turf/T = get_turf(src)
			boutput(T, "<span class='alert'>[src] blows up!</span>")
			explosion(src, T,0,1,1,2)
			qdel(src)
		else
			..()
			return


/obj/item/gun/kinetic/antisingularity
	desc = "An experimental rocket launcher designed to deliver various payloads in rocket format."
	name = "Singularity Buster rocket launcher"
	icon = 'icons/obj/64x32.dmi'
	icon_state = "ntlauncher"
	item_state = "ntlauncher"
	w_class = 4
	throw_speed = 2
	throw_range = 4
	force = 5
	caliber = 1.12 //Based on APILAS
	max_ammo_capacity = 1
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"

	New()
		ammo = new /obj/item/ammo/bullets/antisingularity
		ammo.amount_left = 0 // Spawn empty.
		current_projectile = new /datum/projectile/bullet/antisingularity
		..()
		return

	setupProperties()
		..()
		setProperty("movespeed", 0.8)

/obj/item/gun/kinetic/gungun //meesa jarjar binks
	name = "Gun"
	desc = "A gun that shoots... something. It looks like a modified grenade launcher."
	icon_state = "gungun"
	item_state = "gungun"
	w_class = 3
	caliber = 3//fuck if i know lol, derringers are about 3 inches in size so ill just set this to 3
	max_ammo_capacity = 6 //6 guns
	force = 5

	New()
		ammo = new /obj/item/ammo/bullets/gun
		ammo.amount_left = 6 //spawn full please
		current_projectile = new /datum/projectile/special/spawner/gun
		..()

/obj/item/gun/kinetic/meowitzer
	name = "\improper Meowitzer"
	desc = "It purrs gently in your hands."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "blaster"

	color = "#ff7b00"
	force = 5
	caliber = 20
	max_ammo_capacity = 1
	auto_eject = 0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	spread_angle = 0
	can_dual_wield = 0
	slowdown = 0
	slowdown_time = 0
	two_handed = 1
	w_class = 4

	New()
		ammo = new/obj/item/ammo/bullets/meowitzer
		current_projectile = new/datum/projectile/special/meowitzer
		..()

	afterattack(atom/A, mob/user as mob)
		if(src.ammo.amount_left < max_ammo_capacity && istype(A, /obj/critter/cat))
			src.ammo.amount_left += 1
			user.visible_message("<span class='alert'>[user] loads \the [A] into \the [src].</span>", "<span class='alert'>You load \the [A] into \the [src].</span>")
			src.current_projectile.icon_state = A.icon_state //match the cat sprite that we load
			qdel(A)
			return
		else
			..()

/obj/item/gun/kinetic/meowitzer/inert
	New()
		..()
		ammo = new/obj/item/ammo/bullets/meowitzer/inert
		current_projectile = new/datum/projectile/special/meowitzer/inert
