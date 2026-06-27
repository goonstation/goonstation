////////////////////////////////////VUVUV
TYPEINFO(/obj/item/gun/energy/vuvuzela_gun)
	analyser_flags = parent_type::analyser_flags | ANALYSER_SYNDIE_ONLY
	mats = list("metal" = 5,
				"conductive_high" = 5,
				"energy_high" = 10)
/obj/item/gun/energy/vuvuzela_gun
	name = "amplified vuvuzela"
	icon_state = "vuvuzela"
	item_state = "bike_horn"
	desc = "BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT, *fart*"
	cell_type = /obj/item/ammo/power_cell/med_power
	uses_charge_overlay = TRUE
	charge_icon_state = "vuvuzela"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt_v)
		projectiles = list(current_projectile)
		..()

//////////////////////////////////////Crabgun
TYPEINFO(/obj/item/gun/energy/crabgun)
	analyser_flags = parent_type::analyser_flags | ANALYSER_SYNDIE_ONLY
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
	analyser_flags = ANALYSER_BLACKLIST

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
	analyser_flags = ANALYSER_BLACKLIST

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

/////////////////////////////////////// Pickpocket Grapple, Grayshift's grif gun
TYPEINFO(/obj/item/gun/energy/pickpocket)
	analyser_flags = parent_type::analyser_flags | ANALYSER_SYNDIE_ONLY
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
				tooltip_rebuild = TRUE
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
			tooltip_rebuild = TRUE
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

///////////////////////////////////////////////////
TYPEINFO(/obj/item/gun/energy/lawbringer)
	mats = list("metal" = 15,
				"conductive_high" = 5,
				"energy_high" = 5)
	start_listen_effects = list(LISTEN_EFFECT_LAWBRINGER)
	start_listen_modifiers = null
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD_RANGE_0, LISTEN_INPUT_EQUIPPED, LISTEN_INPUT_DEADCHAT)
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
				tooltip_rebuild = TRUE

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
			if ("hotshot","incendiary","fired")
				set_current_projectile(projectiles["hotshot"])
				current_projectile.cost = 60
				item_state = "lawg-hotshot"
				if (sound)
					playsound(M, 'sound/vox/hot.ogg', 50)
				src.toggle_recoil(TRUE)
			if ("assault","high power", "bigshot")
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
		if (findtext(text, "i am the law"))
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

	//just remove all capitalization and non-letter, non-space characters
	proc/sanitize_talk(var/msg)
		//find all characters that are not letters or whitespace and remove em
		var/regex/r = regex("\[^a-z\\s\]+", "g")
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
	analyser_flags = parent_type::analyser_flags | ANALYSER_SYNDIE_ONLY
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
	silenced = 1
	custom_cell_max_capacity = 100

	New()
		set_current_projectile(new/datum/projectile/special/spreader/quadwasp)
		projectiles = list(current_projectile)
		..()


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
	var/bubble_type = /datum/projectile/special/bubble/bomb
	shoot_delay = 50

/obj/item/gun/energy/bubble_gun/bomb/turf_safe
	bubble_type = /datum/projectile/special/bubble/bomb/turf_safe

#undef HEAT_REMOVED_PER_PROCESS
#undef FIRE_THRESHOLD

/obj/item/gun/energy/resonator
	name = "Resonator"
	cell_type = /obj/item/ammo/power_cell/siren_orb
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "resonator"
	desc = "The combination of the creature's excess energy and the cultist's artifact has created a proficient weapon utilising the creature's innate vibration energy."
	item_state = "resonator"
	charge_icon_state = "resonator"
	can_swap_cell = 0
	force = 10
	two_handed = TRUE
	uses_charge_overlay = TRUE
	camera_recoil_enabled = TRUE
	abilities = list(/obj/ability_button/toggle_scope)

	New()
		set_current_projectile(new/datum/projectile/special/piercing/resonator)
		projectiles = list(new/datum/projectile/special/piercing/resonator)
		AddComponent(/datum/component/holdertargeting/windup, 1 SECOND)
		AddComponent(/datum/component/holdertargeting/sniper_scope, 8, 0, /datum/overlayComposition/sniper_scope/resonator, 'sound/machines/found.ogg')
		..()
