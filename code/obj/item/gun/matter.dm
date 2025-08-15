ABSTRACT_TYPE(/obj/item/gun/energy/matter)
/obj/item/gun/energy/matter
	var/matter = 0
	var/max_matter = 50

/obj/item/gun/energy/matter/attackby(var/obj/item/rcd_ammo/ammo, mob/user)
	if (!istype(ammo, /obj/item/rcd_ammo))
		return ..()


	if (!ammo.matter)
		return
	if (matter == max_matter)
		boutput(user, "\The [src] can't hold any more matter.")
		return
	if (src.matter + ammo.matter > src.max_matter)
		ammo.matter -= (src.max_matter - src.matter)
		boutput(user, "The cartridge now contains [ammo.matter] units of matter.")
		src.matter = src.max_matter
	else
		src.matter += ammo.matter
		ammo.matter = 0
		qdel(ammo)
	ammo.tooltip_rebuild = TRUE
	src.UpdateIcon()
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	boutput(user, "\The [src] now holds [src.matter]/[src.max_matter] matter-units.")

/obj/item/gun/energy/matter/update_icon()
	var/list/ret = list()
	var/charge_part = "-"
	if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
		charge_part = "[round((ret["charge"] / ret["max_charge"]) * 100)]%"
		if(uses_charge_overlay)
			update_charge_overlay()
	var/matter_part = "[src.matter]MU"
	src.inventory_counter.update_text("[matter_part]<br><br>[charge_part]")

/obj/item/gun/energy/matter/canshoot(mob/user)
	if (istype(src.current_projectile, /datum/projectile/energy_bolt))
		return ..()
	if (src.current_projectile.cost > src.matter)
		return FALSE
	if (istype(src.current_projectile, /datum/projectile/bullet/aex))
		var/list/ret = list()
		if(!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST) || ret["charge"] < 150)
			return FALSE
	return TRUE

/obj/item/gun/energy/matter/process_ammo(mob/user)
	if (istype(src.current_projectile, /datum/projectile/energy_bolt))
		return ..()
	if (istype(src.current_projectile, /datum/projectile/bullet/aex))
		SEND_SIGNAL(src, COMSIG_CELL_USE, 150)
	src.matter -= src.current_projectile.cost
	return TRUE

TYPEINFO(/obj/item/gun/energy/matter/lawbringer)
	mats = list("metal" = 15,
				"conductive_high" = 5,
				"energy_high" = 5)
	start_listen_effects = list(LISTEN_EFFECT_LAWBRINGER)
	start_listen_modifiers = null
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD_RANGE_0, LISTEN_INPUT_EQUIPPED)
	start_listen_languages = list(LANGUAGE_ENGLISH)

/obj/item/gun/energy/matter/lawbringer
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
	matter = 50
	var/emagged = FALSE

	New(var/mob/M)
		set_current_projectile(new/datum/projectile/energy_bolt/aoe)
		projectiles = list(
			"detain" = current_projectile,
			"execute" = new/datum/projectile/bullet/revolver_38/lawbringer,
			"smokeshot" = new/datum/projectile/bullet/smoke,
			"knockout" = new/datum/projectile/bullet/tranq_dart/lawbringer,
			"hotshot" = new/datum/projectile/bullet/flare,
			"assault" = new/datum/projectile/bullet/aex/lawbringer,
			"clownshot" = new/datum/projectile/bullet/clownshot,
			"pulse" = new/datum/projectile/energy_bolt/pulse
		)

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
				current_projectile.cost = 7
				item_state = "lawg-execute"
				if (sound)
					playsound(M, "sound/vox/[text == "cluwneshot" ? "cluwne" : "exterminate"].ogg", 50)
				src.toggle_recoil(FALSE)
			if ("smokeshot","fog")
				set_current_projectile(projectiles["smokeshot"])
				current_projectile.cost = 15
				item_state = "lawg-smokeshot"
				if (sound)
					playsound(M, 'sound/vox/smoke.ogg', 50)
				src.toggle_recoil(TRUE)
			if ("knockout", "sleepshot")
				set_current_projectile(projectiles["knockout"])
				current_projectile.cost = 10
				item_state = "lawg-knockout"
				if (sound)
					playsound(M, 'sound/vox/sleep.ogg', 50)
				src.toggle_recoil(FALSE)
			if ("hotshot","incendiary","fired")
				set_current_projectile(projectiles["hotshot"])
				current_projectile.cost = 15
				item_state = "lawg-hotshot"
				if (sound)
					playsound(M, 'sound/vox/hot.ogg', 50)
				src.toggle_recoil(TRUE)
			if ("assault","high power", "bigshot")
				set_current_projectile(projectiles["assault"])
				current_projectile.cost = 30
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
			else if (current_projectile.type == /datum/projectile/bullet/revolver_38/lawbringer)			//execute - cyan
				indicator_display.color = "#00FFFF"
				muzzle_flash = "muzzle_flash_bluezap"
			else if (current_projectile.type == /datum/projectile/bullet/smoke)			//smokeshot - dark-blue
				indicator_display.color = "#0000FF"
				muzzle_flash = "muzzle_flash"
			else if (current_projectile.type == /datum/projectile/bullet/tranq_dart/lawbringer)	//knockout - green
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

/obj/item/gun/energy/matter/lawbringer/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (user)
		src.emagged = TRUE
		boutput(user, SPAN_ALERT("Anyone can use this gun now. Be careful! (use it in-hand to register your fingerprints)"))
		owner_prints = null
		return TRUE

//stolen from firebreath in powers.dm
/obj/item/gun/energy/matter/lawbringer/proc/shoot_fire_hotspots(var/target,var/start,var/mob/user)
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
