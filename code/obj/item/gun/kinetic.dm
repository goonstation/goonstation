ABSTRACT_TYPE(/obj/item/gun/kinetic)
/obj/item/gun/kinetic
	name = "kinetic weapon"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "gun"
	m_amt = 2000
	add_residue = 1 // Does this gun add gunshot residue when fired? Kinetic guns should (Convair880).
	muzzle_flash = "muzzle_flash"
	firemodes = list(new/datum/firemode/single)

	// Ammo caliber defines
	// see \_std\defines\item.dm for caliber defines!

	New()
		if(silenced)
			current_projectile.shot_sound = 'sound/machines/click.ogg'
		..()
		src.update_icon()

	examine()
		. = ..()
		if (src?.loaded_magazine)
			if(src.loaded_magazine.is_null_mag)
				. += "There isn't a magazine in the gun!"
			else if(src.loaded_magazine.mag_contents.len >= 1 && istype(src.loaded_magazine.mag_contents[1], /datum/projectile))
				var/datum/projectile/ammo_type = src.loaded_magazine.mag_contents[1]
				if(src.loaded_magazine.mag_contents.len == 1)
					. += "There is 1 [ammo_type.ammo_name] left!"
				else if(src.loaded_magazine.mag_contents.len > 1)
					. += "There are [src.loaded_magazine.mag_contents.len] [ammo_type.ammo_name_plural ? ammo_type.ammo_name_plural : (ammo_type.ammo_name + "s")] left!"
			else
				. += "There aren't any bullets left!"
		if (src.firemodes && src.firemode_index)
			. += "Each shot will currently use [src.firemodes[src.firemode_index]["burst_count"]] bullets!"
		else
			. += "<span class='alert'>*ERROR* No output selected!</span>"

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/item/ammo/bullets) && allowDropReload)
			attackby(O, user)
		return ..()

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
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-small-0[rand(1,6)].ogg", 20, 0.1)

	medium
		icon_state = "medium"
		desc = "Seems to be a common revolver cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1)

	rifle
		icon_state = "rifle"
		desc = "Seems to be a rifle cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1, 0, 0.8)


	rifle_loud
		icon_state = "rifle"
		desc = "Seems to be a rifle cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-large-0[rand(1,4)].ogg", 25, 0.1)

	derringer
		icon_state = "medium"
		desc = "A fat and stumpy bullet casing. Looks pretty old."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
				playsound(src.loc, "sound/weapons/casings/casing-0[rand(1,9)].ogg", 20, 0.1)

	deagle
		icon_state = "medium"
		desc = "An uncomfortably large pistol cartridge."
		New()
			..()
			SPAWN_DBG(rand(1, 3))
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
		New()
			..()
			SPAWN_DBG(rand(4, 7))
				playsound(src.loc, "sound/weapons/casings/casing-shell-0[rand(1,7)].ogg", 20, 0.1)

	cannon
		icon_state = "rifle"
		desc = "A cannon shell."
		w_class = 2
		New()
			..()
			SPAWN_DBG(rand(2, 4))
				playsound(src.loc, "sound/weapons/casings/casing-large-0[rand(1,4)].ogg", 35, 0.1, 0, 0.8)

	grenade
		w_class = 2
		icon_state = "40mm"
		desc = "A 40mm grenade round casing. Huh."
		New()
			..()
			SPAWN_DBG(rand(3, 6))
				playsound(src.loc, "sound/weapons/casings/casing-shell-0[rand(1,7)].ogg", 30, 0.1, 0.8)



	New()
		..()
		src.pixel_y += rand(-12,12)
		src.pixel_x += rand(-12,12)
		src.set_dir(pick(alldirs))
		return

/obj/item/gun/kinetic/minigun
	name = "Minigun"
	desc = "The M134 Minigun is a 7.62×51mm NATO, six-barrel rotary machine gun with a high rate of fire."
	icon_state = "minigun"
	item_state = "heavy"
	force = 5
	caliber = CALIBER_MINIGUN
	accepted_mag = AMMO_BELTMAG
	auto_eject = 1
	ammo = /obj/item/ammo/bullets/minigun
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	spread_angle = 25
	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 15

	two_handed = 1
	w_class = 4
	firemodes = list(new/datum/firemode/minigun_lowspeed,\
	                 new/datum/firemode/minigun_highspeed)


	setupProperties()
		..()
		setProperty("movespeed", 0.4)

/obj/item/gun/kinetic/revolver
	name = "Predator revolver"
	desc = "A hefty combat revolver developed by Cormorant Precision Arms. Uses .357 caliber rounds."
	icon_state = "revolver"
	item_state = "revolver"
	force = 8.0
	fixed_mag = TRUE
	caliber = list(CALIBER_REVOLVER, CALIBER_REVOLVER_MAGNUM) // Just like in RL (Convair880).
	ammo = /obj/item/ammo/bullets/internal/revolver/magnum

/obj/item/gun/kinetic/revolver/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/gun/kinetic/derringer
	name = "derringer"
	desc = "A small and easy-to-hide gun that comes with 2 shots. (Can be hidden in worn clothes and retrieved by using the wink emote)"
	icon_state = "derringer"
	force = 5.0
	fixed_mag = TRUE
	caliber = CALIBER_DERRINGER
	w_class = 2
	muzzle_flash = null
	ammo = /obj/item/ammo/bullets/internal/derringer
	w_class = 4
	firemodes = list(new/datum/firemode/single,\
	                 new/datum/firemode/double)

	afterattack(obj/O as obj, mob/user as mob)
		if (O.loc == user && O != src && istype(O, /obj/item/clothing))
			boutput(user, "<span class='hint'>You hide the derringer inside \the [O]. (Use the wink emote while wearing the clothing item to retrieve it.)</span>")
			user.u_equip(src)
			src.set_loc(O)
			src.dropped(user)
		else
			..()
		return

/obj/item/gun/kinetic/faith
	name = "Faith"
	desc = "'Cause ya gotta have Faith."
	icon_state = "faith"
	force = 5.0
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_PISTOL_SMALL
	auto_eject = 1
	w_class = 2
	muzzle_flash = null
	has_empty_state = 1
	ammo = /obj/item/ammo/bullets/bullet_22/faith

/obj/item/gun/kinetic/detectiverevolver
	name = "Detective Special revolver"
	desc = "A snubnosed police-issue revolver developed by Cormorant Precision Arms. Uses .38-Special rounds."
	icon_state = "detective"
	item_state = "detective"
	w_class = 2.0
	force = 2.0
	fixed_mag = TRUE
	caliber = CALIBER_REVOLVER
	gildable = 1
	ammo = /obj/item/ammo/bullets/internal/revolver/stun

/obj/item/gun/kinetic/colt_saa
	name = "colt saa revolver"
	desc = "A nearly adequate replica of a nearly ancient single action revolver. Used by war reenactors for the last hundred years or so."
	icon_state = "colt_saa"
	item_state = "colt_saa"
	w_class = 3.0
	force = 5.0
	fixed_mag = TRUE
	accepted_mag = AMMO_PILE // cus who doesnt love to reload during a battle?
	caliber = CALIBER_REVOLVER_OLDTIMEY
	spread_angle = 1
	firemodes = list(new/datum/firemode/single/singleaction)
	ammo = /obj/item/ammo/bullets/internal/revolver/oldtimey

	detective
		name = "Peacemaker"
		desc = "A barely adequate replica of a nearly ancient single action revolver. Used by war reenactors for the last hundred years or so. Its calibur is obviously the wrong size though."
		w_class = 2.0
		force = 2.0
		accepted_mag = AMMO_PILE
		caliber = CALIBER_REVOLVER
		ammo = /obj/item/ammo/bullets/internal/revolver/stun

/* 	canshoot()
		if (hammer_cocked)
			return ..()
		else
			return 0
	shoot(var/target,var/start ,var/mob/user)
		..()
		hammer_cocked = 0
		icon_state = "colt_saa"

	attack_self(mob/user as mob)
		..()
		if (hammer_cocked)
			hammer_cocked = 0
			icon_state = "colt_saa"
			boutput(user, "<span class='notice'>You gently lower the weapon's hammer!</span>")
		else
			hammer_cocked = 1
			icon_state = "colt_saa-c"
			boutput(user, "<span class='alert'>You cock the hammer!</span>")
			playsound(user.loc, "sound/weapons/gun_cocked_colt45.ogg", 70, 1) */

/obj/item/gun/kinetic/clock_188
	desc = "A reliable weapon used the world over... 50 years ago. Uses 9mm NATO rounds."
	name = "Clock 188"
	icon_state = "glock"
	item_state = "glock"
	shoot_delay = 2
	w_class = 2.0
	force = 7.0
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_PISTOL
	auto_eject = 1
	has_empty_state = 1
	gildable = 1
	ammo = /obj/item/ammo/bullets/nine_mm_NATO
	firemodes = list(new/datum/firemode/single,\
	                 new/datum/firemode/triple(refire = 0.7))

	New()
		if (prob(70))
			icon_state = "glocktan"
			item_state = "glocktan"
		..()

/obj/item/gun/kinetic/clock_188/boomerang
	desc = "Jokingly called a \"Gunarang\" in some circles. Uses 9mm NATO rounds."
	name = "Clock 180"
	throw_range = 10
	throwforce = 1
	throw_speed = 1
	throw_return = 1
	var/prob_clonk = 0
	firemodes = list(new/datum/firemode/single)


	throw_begin(atom/target)
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom)
		if(hit_atom == usr)
			if(prob(prob_clonk))
				var/mob/living/carbon/human/user = usr
				user.visible_message("<span class='alert'><B>[user] fumbles the catch and accidentally discharges [src]!</B></span>")
				src.shoot_manager(user, user)
				user.force_laydown_standup()
			else
				src.attack_hand(usr)
			return
		else
			var/mob/M = hit_atom
			if(istype(M))
				var/mob/living/carbon/human/user = usr
				if(istype(user.wear_suit, /obj/item/clothing/suit/security_badge))
					src.silenced = 1
					src.shoot_manager(user, user)
					M.visible_message("<span class='alert'><B>[src] fires, hitting [M] point blank!</B></span>")
					src.silenced = initial(src.silenced)

			prob_clonk = min(prob_clonk + 5, 100)
			SPAWN_DBG(1 SECONDS)
				prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)


/obj/item/gun/kinetic/spes
	name = "SPES-12"
	desc = "Multi-purpose high-grade military shotgun. Very spiffy."
	icon_state = "spas"
	item_state = "spas"
	force = 18.0
	contraband = 7
	fixed_mag = TRUE
	caliber = CALIBER_SHOTGUN
	auto_eject = 1
	can_dual_wield = 0
	ammo = /obj/item/ammo/bullets/internal/shotgun

	New()
		if(prob(10))
			name = pick("SPEZZ-12", "SPESS-12", "SPETZ-12", "SPOCK-12", "SCHPATZL-12", "SABRINA-12", "SAURUS-12", "SABER-12", "SOSIG-12", "DINOHUNTER-12", "PISS-12", "ASS-12", "SPES-12", "SHIT-12", "SHOOT-12", "SHOTGUN-12", "FAMILYGUY-12", "SPAGOOTER-12")
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
		ammo = /obj/item/ammo/bullets/internal/shotgun/weak
		New()
			..()
			src.name = replacetext("[src.name]", "12", "6") //only half as good

/obj/item/gun/kinetic/riotgun
	name = "Riot Shotgun"
	desc = "A police-issue shotgun meant for suppressing riots."
	icon = 'icons/obj/48x32.dmi'
	icon_state = "shotty"
	item_state = "shotty"
	force = 15.0
	contraband = 5
	fixed_mag = TRUE
	caliber = CALIBER_SHOTGUN
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	has_empty_state = 1
	gildable = 1
	ammo = /obj/item/ammo/bullets/internal/shotgun/rubber
	firemodes = list(new/datum/firemode/single/singleaction/shotgun)

/obj/item/gun/kinetic/ak47
	name = "AK-744 Rifle"
	desc = "Based on an old Cold War relic, often used by paramilitary organizations and space terrorists."
	icon = 'icons/obj/48x32.dmi' // big guns get big icons
	icon_state = "ak47"
	item_state = "ak47"
	force = 30.0
	contraband = 8
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_RIFLE_HEAVY
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	gildable = 1
	ammo = /obj/item/ammo/bullets/ak47
	firemodes = list(new/datum/firemode/single,\
	                 new/datum/firemode/triple)

/obj/item/gun/kinetic/hunting_rifle
	name = "Old Hunting Rifle"
	desc = "A powerful antique hunting rifle."
	icon = 'icons/obj/48x32.dmi'
	icon_state = "ohr"
	item_state = "ohr"
	force = 10
	contraband = 8
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_RIFLE_HEAVY
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	has_empty_state = 1
	gildable = 1
	ammo = /obj/item/ammo/bullets/rifle_3006

/obj/item/gun/kinetic/dart_rifle
	name = "Tranquilizer Rifle"
	desc = "A veterinary tranquilizer rifle chambered in .308 caliber."
	icon = 'icons/obj/48x32.dmi'
	icon_state = "tranq"
	item_state = "tranq"
	force = 10
	//contraband = 8
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_RIFLE_HEAVY
	auto_eject = 1
	can_dual_wield = 0
	two_handed = 1
	gildable = 1
	ammo = /obj/item/ammo/bullets/tranq_darts

/obj/item/gun/kinetic/zipgun
	name = "Zip Gun"
	desc = "An improvised and unreliable gun."
	icon_state = "zipgun"
	force = 3
	contraband = 6
	fixed_mag = TRUE
	caliber = CALIBER_ANY // use any ammo at all BA HA HA HA HA
	var/failure_chance = 6
	var/failured = 0
	ammo = /obj/item/ammo/bullets/internal/zipgun
	firemodes = list(new/datum/firemode/single,\
	                 new/datum/firemode/double)
#if ASS_JAM
	New()
		var/turf/T = get_turf(src)
		playsound(T, "sound/items/Deconstruct.ogg", 50, 1)
		new/obj/item/gun/kinetic/slamgun(T)
		qdel(src)
		return // Sorry! No zipguns during ASS JAM
#endif

	shoot(var/target,var/start ,var/mob/user)
		if(failured)
			var/turf/T = get_turf(src)
			explosion(src, T,-1,-1,1,2)
			qdel(src)
		if(src.current_projectile?.power)
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
	name = "Orion silenced pistol"
	desc = "A small pistol with an integrated flash and noise suppressor, developed by Specter Tactical Laboratory. Uses .22 rounds."
	icon_state = "silenced"
	w_class = 2
	silenced = 1
	force = 3
	contraband = 4
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_PISTOL_SMALL
	auto_eject = 1
	hide_attack = 1
	muzzle_flash = null
	has_empty_state = 1
	ammo = /obj/item/ammo/bullets/bullet_22/HP

/obj/item/gun/kinetic/vgun
	name = "Virtual Pistol"
	desc = "This thing would be better if it wasn't such a piece of shit."
	icon_state = "railgun"
	force = 10.0
	contraband = 0
	ammo = /obj/item/ammo/bullets/vbullet

	shoot(var/target,var/start ,var/mob/user)
		var/turf/T = get_turf(src)

		if (!istype(T.loc, /area/sim))
			boutput(user, "<span class='alert'>You can't use the guns outside of the combat simulation, fuckhead!</span>")
			return
		else
			..()

/obj/item/gun/kinetic/flaregun
	desc = "A 12-gauge flaregun."
	name = "Flare Gun"
	icon_state = "flare"
	item_state = "flaregun"
	force = 5.0
	contraband = 2
	fixed_mag = TRUE
	caliber = CALIBER_SHOTGUN
	has_empty_state = 1
	ammo = /obj/item/ammo/bullets/internal/shotgun/flare

/obj/item/gun/kinetic/riot40mm
	desc = "A 40mm riot control launcher."
	name = "Riot launcher"
	icon_state = "40mm"
	//item_state = "flaregun"
	force = 5.0
	contraband = 7
	fixed_mag = TRUE
	caliber = CALIBER_GRENADE
	muzzle_flash = "muzzle_flash_launch"
	ammo = /obj/item/ammo/bullets/internal/launcher/

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if(src.loaded_magazine.mag_contents.len > 0)
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
	icon_state = "rpg7"
	uses_multiple_icon_states = 1
	item_state = "rpg7"
	wear_image_icon = 'icons/mob/back.dmi'
	flags = ONBACK
	w_class = 4
	throw_speed = 2
	throw_range = 4
	force = 5
	contraband = 8
	fixed_mag = TRUE
	caliber = CALIBER_RPG
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"
	has_empty_state = 1
	ammo = /obj/item/ammo/bullets/internal/launcher/rpg/unloaded

	update_icon()
		..()
		if (src.loaded_magazine.mag_contents.len < 1)
			src.item_state = "rpg7_empty"
		else
			src.item_state = "rpg7"

	loaded
		ammo = /obj/item/ammo/bullets/internal/launcher/rpg

/obj/item/gun/kinetic/coilgun_TEST
	name = "coil gun"
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "coilgun_2"
	item_state = "flaregun"
	force = 10.0
	contraband = 6
	caliber = CALIBER_ROD
	ammo = /obj/item/ammo/bullets/rod

/obj/item/gun/kinetic/airzooka //This is technically kinetic? I guess?
	name = "Airzooka"
	desc = "The new double action air projection device from Donk Co!"
	icon_state = "airzooka"
	caliber = CALIBER_TRASHBAG // I rolled a dice
	muzzle_flash = "muzzle_flash_launch"
	ammo = /obj/item/ammo/bullets/internal/airzooka

/obj/item/gun/kinetic/smg //testing keelin's continuous fire POC
	name = "submachine gun"
	desc = "An automatic submachine gun"
	icon_state = "walthery1"
	w_class = 2
	force = 3
	contraband = 4
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_PISTOL
	auto_eject = 1

	continuous = 1
	c_interval = 1.1
	ammo = /obj/item/ammo/bullets/bullet_9mm/smg

//  <([['v') - Gannets Nuke Ops Class Guns - ('u']])>  //

// agent
/obj/item/gun/kinetic/pistol
	name = "Branwen pistol"
	desc = "A semi-automatic, 9mm caliber service pistol, developed by Mabinogi Firearms Company."
	icon_state = "9mm_pistol"
	w_class = 2
	force = 3
	contraband = 4
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_PISTOL
	auto_eject = 1
	has_empty_state = 1
	ammo = /obj/item/ammo/bullets/bullet_9mm

/obj/item/gun/kinetic/tranq_pistol
	name = "Gwydion tranquilizer pistol"
	desc = "A silenced tranquilizer pistol chambered in .308 caliber, developed by Mabinogi Firearms Company."
	icon_state = "tranq_pistol"
	item_state = "tranq_pistol"
	w_class = 2
	force = 3
	contraband = 4
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_PISTOL
	auto_eject = 0
	hide_attack = 1
	muzzle_flash = null
	ammo = /obj/item/ammo/bullets/tranq_darts/syndicate/pistol

// scout
/obj/item/gun/kinetic/tactical_shotgun //just a reskin, unused currently
	name = "tactical shotgun"
	desc = "Multi-purpose high-grade military shotgun, painted a menacing black colour."
	icon_state = "tactical_shotgun"
	item_state = "shotgun"
	force = 5
	contraband = 7
	fixed_mag = TRUE
	caliber = CALIBER_SHOTGUN
	auto_eject = 1
	two_handed = 1
	can_dual_wield = 0
	ammo = /obj/item/ammo/bullets/internal/shotgun

// assault
/obj/item/gun/kinetic/assault_rifle
	name = "Sirius assault rifle"
	desc = "A bullpup assault rifle capable of semi-automatic and burst fire modes, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/64x32.dmi'
	icon_state = "assault_rifle"
	item_state = "assault_rifle"
	force = 20.0
	contraband = 8
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_RIFLE_ASSAULT
	auto_eject = 1
	object_flags = NO_ARM_ATTACH

	two_handed = 1
	can_dual_wield = 0
	spread_angle = 0
	ammo = /obj/item/ammo/bullets/assault_rifle
	firemodes = list(new/datum/firemode/single,\
	                 new/datum/firemode/triple)

// heavy
/obj/item/gun/kinetic/light_machine_gun
	name = "Antares light machine gun"
	desc = "A 100 round light machine gun, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/64x32.dmi'
	icon_state = "lmg"
	item_state = "lmg"
	wear_image_icon = 'icons/mob/back.dmi'
	force = 5
	accepted_mag = list(AMMO_BELTMAG, AMMO_MAGAZINE)
	caliber = CALIBER_RIFLE_HEAVY
	auto_eject = 1
	burst_count = 8

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	spread_angle = 8
	can_dual_wield = 0

	slowdown = 0.5
	slowdown_time = 3

	two_handed = 1
	w_class = 4
	ammo = /obj/item/ammo/bullets/lmg
	firemodes = list(new/datum/firemode/single(spread = 12.5),\
	                 new/datum/firemode/auto)

	New()
		AddComponent(/datum/component/holdertargeting/fullauto, 4 DECI SECONDS, 1.5 DECI SECONDS, 0.5)
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
	fixed_mag = TRUE
	caliber = CALIBER_CANNON
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
	ammo = /obj/item/ammo/bullets/cannon/single

	setupProperties()
		..()
		setProperty("movespeed", 0.3)



// demo
/obj/item/gun/kinetic/grenade_launcher
	name = "Rigil grenade launcher"
	desc = "A 40mm hand-held grenade launcher, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/64x32.dmi'
	icon_state = "grenade_launcher"
	item_state = "grenade_launcher"
	force = 5.0
	contraband = 7
	fixed_mag = TRUE
	caliber = CALIBER_GRENADE
	two_handed = 1
	can_dual_wield = 0
	object_flags = NO_ARM_ATTACH
	auto_eject = 1
	ammo = /obj/item/ammo/bullets/internal/launcher/multi/explosive

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/old_grenade))
			if(src.loaded_magazine.mag_contents.len > 0)
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
	fixed_mag = TRUE
	caliber = CALIBER_SHOTGUN
	auto_eject = 0
	spread_angle = 10 // sorry, no sniping with slamguns

	can_dual_wield = 0
	two_handed = 1
	w_class = 4
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	ammo = /obj/item/ammo/bullets/internal/slamgun

	attack_self(mob/user as mob)
		if (src.icon_state == "slamgun-ready")
			w_class = 3
			if (src.loaded_magazine.mag_contents.len > 0 || src.casings_to_eject > 0)
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
			if (src.loaded_magazine.mag_contents.len > 0 || src.casings_to_eject > 0)
				src.icon_state = "slamgun-open-loaded"
			else
				src.icon_state = "slamgun-open"

		..()

	MouseDrop(atom/over_object, src_location, over_location, params)
		if (usr.stat || usr.restrained() || !can_reach(usr, src) || usr.getStatusDuration("paralysis") || usr.sleeping || usr.lying || isAIeye(usr) || isAI(usr) || isghostcritter(usr))
			return ..()
		if (src.icon_state != "slamgun-open-loaded") // sorry for doing it like this, but i have no idea how to do it cleaner.
			return ..()

	attackby(obj/item/b as obj, mob/user as mob)
		if (istype(b, /obj/item/ammo) && src.icon_state == "slamgun-ready")
			boutput(user, "<span class='alert'>You can't shove shells down the barrel! You'll have to open the [src]!</span>")
			return
		if (istype(b, /obj/item/ammo) && (src.loaded_magazine.mag_contents.len > 0 || src.casings_to_eject > 0))
			boutput(user, "<span class='alert'>The [src] already has a shell inside! You'll have to unload the [src]!</span>")
			return
		..()

// sniper
/obj/item/gun/kinetic/sniper
	name = "Betelgeuse sniper rifle"
	desc = "A semi-automatic bullpup sniper rifle, developed by Almagest Weapons Fabrication."
	icon = 'icons/obj/64x32.dmi' // big guns get big icons
	icon_state = "sniper"
	item_state = "sniper"
	wear_image_icon = 'icons/mob/back.dmi'
	force = 5
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_RIFLE_HEAVY // technically can accept LMG rounds if you really wanted to
	auto_eject = 1
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY | ONBACK
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	slowdown = 7
	slowdown_time = 5

	can_dual_wield = 0
	two_handed = 1
	w_class = 4
	ammo = /obj/item/ammo/bullets/rifle_762_NATO
	var/datum/movement_controller/snipermove = null

	New()
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
		ammo = /obj/item/ammo/bullets/cannon
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
	fixed_mag = TRUE
	caliber = CALIBER_PISTOL_FLINTLOCK
	auto_eject = null
	var/failure_chance = 1
	ammo = /obj/item/ammo/bullets/internal/flintlock

	shoot()
		if(src.loaded_magazine.mag_contents.len > 0 && istype(src.loaded_magazine.mag_contents[1], /datum/projectile))
			var/datum/projectile/check_this_bullet = src.loaded_magazine.mag_contents[1]
			failure_chance = max(10,min(33,round(check_this_bullet.caliber * (check_this_bullet.power/2))))
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
	fixed_mag = TRUE
	caliber = CALIBER_ROCKET //Based on APILAS
	can_dual_wield = 0
	two_handed = 1
	muzzle_flash = "muzzle_flash_launch"
	ammo = /obj/item/ammo/bullets/internal/launcher/antisingularity

	setupProperties()
		..()
		setProperty("movespeed", 0.8)

/obj/item/gun/kinetic/gungun //meesa jarjar binks
	name = "Gun"
	desc = "A gun that shoots... something. It looks like a modified grenade launcher."
	icon_state = "gungun"
	item_state = "gungun"
	w_class = 3
	fixed_mag = TRUE
	caliber = CALIBER_WHOLE_DERRINGER //fuck if i know lol, derringers are about 3 inches in size so ill just set this to 3
	force = 5
	ammo = new /obj/item/ammo/bullets/internal/launcher/multi/derringers

/obj/item/gun/kinetic/meowitzer
	name = "\improper Meowitzer"
	desc = "It purrs gently in your hands."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "blaster"

	color = "#ff7b00"
	force = 5
	fixed_mag = TRUE
	caliber = CALIBER_CAT
	auto_eject = 0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	spread_angle = 0
	can_dual_wield = 0
	slowdown = 0
	slowdown_time = 0
	two_handed = 1
	w_class = 4
	ammo = /obj/item/ammo/bullets/internal/launcher/cat

	afterattack(atom/A, mob/user as mob)
		if(src.loaded_magazine.mag_contents.len < src.loaded_magazine.max_amount && istype(A, /obj/critter/cat))
			src.loaded_magazine.mag_contents += new src.ammo
			user.visible_message("<span class='alert'>[user] loads \the [A] into \the [src].</span>", "<span class='alert'>You load \the [A] into \the [src].</span>")
			var/datum/projectile/special/meowitzer/cat = src.loaded_magazine.mag_contents[1]
			cat.icon_state = A.icon_state //match the cat sprite that we load
			qdel(A)
			return
		else
			..()

/obj/item/gun/kinetic/meowitzer/inert
	ammo = /obj/item/ammo/bullets/meowitzer/inert
/obj/item/gun/kinetic/SMG_briefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system. This one has a small hole in the side of it. Odd."
	force = 8.0
	accepted_mag = AMMO_MAGAZINE
	caliber = CALIBER_PISTOL
	auto_eject = 0

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	object_flags = NO_ARM_ATTACH
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD

	spread_angle = 2
	can_dual_wield = 0
	var/cases_to_eject = 0
	var/open = FALSE
	ammo = /obj/item/ammo/bullets/nine_mm_NATO

	attack_hand(mob/user as mob)
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
			update_icon()
			boutput(user, "<span class='alert'>You close the [src]!</span>")
		else
			boutput(user, "<span class='alert'>You open the [src].</span>")
			open = TRUE
			update_icon()
			if (src.loc == user && user.find_in_hand(src)) // Make sure it's not on the belt or in a backpack.
				src.add_fingerprint(user)
				src.handle_casings(1, user)

	canshoot()
		if(open)
			return 0
		else
			. = ..()

	update_icon()
		if(open)
			icon_state="guncase"
		else
			icon_state="secure"
