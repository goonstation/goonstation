var/list/forensic_IDs = new/list() //Global list of all guns, based on bioholder uID stuff

/obj/item/gun
	name = "gun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab/threat/gunpoint

	item_state = "gun"
	m_amt = 2000
	force = 10
	throwforce = 5
	health = 7
	w_class = W_CLASS_NORMAL
	throw_speed = 4
	throw_range = 6
	contraband = 4
	hide_attack = 2 //Point blanking... gross
	pickup_sfx = 'sound/items/pickup_gun.ogg'
	inventory_counter_enabled = 1

	var/suppress_fire_msg = 0

	var/spread_angle = 0
	var/datum/projectile/current_projectile = null
	var/list/firemodes // List of projectile:firemode this gun can use
	/// What firemode is this gun set to use? If null, defaults to the current projectile's default firemode.
	var/datum/firemode/current_firemode = null

	/// TRUE if this gun can fire multiple different projectile types. Used to reduce redundant info in firemode cycling.
	var/multiple_projectiles = FALSE
	/// TRUE if this gun can use multiple different firemodes. Used to reduce redundant info in firemode cycling.
	var/multiple_firemodes = FALSE
	var/current_firemode_num = 1
	var/silenced = 0
	///the "out of ammo oh no" click
	var/click_sound = 'sound/weapons/Gunclick.ogg'
	var/click_msg = "*click* *click*"
	var/can_dual_wield = 1

	var/slowdown = 0 //Movement delay attack after attack
	var/slowdown_time = 10 //For this long

	var/add_residue = 0 // Does this gun add gunshot residue when fired (Convair880)?

	var/shoot_delay = 4

	var/muzzle_flash = null //set to a different icon state name if you want a different muzzle flash when fired, flash anims located in icons/mob/mob.dmi

	var/fire_animation = FALSE //Used for guns that have animations when firing
	var/safe_spin = FALSE //! Can this gun be *spin emoted without a chance to shoot yourself?



	var/recoil = 0 //! current cumulative recoil value, for inaccuracy. leave at 0
	var/recoil_last_shot //! last time this was fired, for recoil purposes
	var/current_anim_recoil = 0 //! current icon rotation, used to make sure the icon resets properly
	var/recoil_stacks = 0 //! current number of shots fired before recoil_reset elapsed.

	// RECOIL SETUP
	var/recoil_enabled = TRUE

	// RECOIL STRENGTH
	// Basic recoil strength, this is how hard the weapon kicks by default
	// recoil_strength is added to recoil every shot, and kicks the camera similarly.
	var/recoil_strength = 10 //! How strong this gun's base recoil impulse is.
	var/recoil_max = 50		//! What's the max cumulative recoil this gun can hit?
	var/recoil_inaccuracy_max = 0 //! at recoil_max, the weapon has this much additional spread

	// Recoil-induced icon tilting. Good for smaller guns. 64x32 icons might look a bit silly with high values.
	// If your gun uses recoil, it's *strongly* recommended to keep this enabled.
	var/icon_recoil_enabled = TRUE //! Should this gun's icon tilt?
	var/icon_recoil_cap = 10 //! At maximum recoil, what angle should the icon state be at?

	// Recoil strength stacking, increases recoil strength as you shoot more
	// Good for making spray & pray kick harder, so just use it on automatic weapons.
	var/recoil_stacking_enabled = FALSE			//! Should this gun gain more recoil strength as it shoots?
	var/recoil_stacking_safe_stacks = 3 //! Ignore this many shots before stacking up (if you want 3-shot bursts not to be penalsied)
	var/recoil_stacking_amount = 1 		//! How much should recoil_strength go up by, every shot
	var/recoil_stacking_max_stacks = 3 	//! How many times can recoil-stacking_amount apply?

	// RECOIL RESET
	// The following values should be pretty sane for most cases
	// If you really must have 'gun that takes a long time to reset', kick recoil_reset_mult closer to 1
	var/recoil_reset = 6 DECI SECONDS //! how long it takes for recoil to start resetting (6 deci seconds feels nice)
	var/recoil_reset_mult = 0.75 //! multiplier to apply to recoil every .1 seconds (affects high recoil recovery)
	var/recoil_reset_add = 0.2 //! additive reduction to accumulated recoil (affects low recoil recovery better than mult)

	// CAMERA KNOCKING
	// Whenever the gun shoots, it will punt the users' camera back at (recoil_strength + recoil_stacks*recoil_stacking_amount)* pixels per decisecond.
	var/camera_recoil_enabled = TRUE //! Should this gun kickback the camera when fired?
	var/camera_recoil_multiplier = 1 //! Multiply the recoil value by this for camera movement
	var/camera_recoil_sway = TRUE //! If enabled, camera recoil rattles perpendicular to the aim direction too (recommended)
	var/camera_recoil_sway_multiplier = 2 // Multiply the recoil value by this for camera variance (probably fine at 2)
	var/camera_recoil_sway_min = 0 //! Minimum recoil variance
	var/camera_recoil_sway_max = 20 //! Maximum recoil variance


	buildTooltipContent()
		. = ..() + src.current_projectile?.get_tooltip_content()
		lastTooltipContent = .

	New()
		src.AddComponent(/datum/component/log_item_pickup, first_time_only=FALSE, authorized_job=null, message_admins_too=FALSE)
		SPAWN(2 SECONDS)
			src.forensic_ID = src.CreateID()
			forensic_IDs.Add(src.forensic_ID)
		return ..()

	// equip handling for weapons that fit on your back
	try_specific_equip(mob/user)
		. = ..()
		if (!(src.c_flags & ONBACK))
			return
		if (!user.back?.storage)
			return
		if (!user.s_active)
			return
		if (user.s_active.master != user.back.storage)
			return
		if (user.back.storage.check_can_hold(src) == STORAGE_CAN_HOLD)
			user.back.Attackby(src, user)
			return TRUE

///CHECK_LOCK
///Call to run a weaponlock check vs the users implant
///Return 0 for fail
/obj/item/gun/proc/check_lock(var/user as mob)
	return 1

///ADD_FIREMODE
/// Add a firemode to the gun.
/// If a firemode is not passed, it will use the projectile's default firemode.
/// If a projectile is passed, it will explicitly use that projectile.
/// If P is null, it will instead respect the currently loaded ammo.
/obj/item/gun/proc/add_firemode(var/datum/firemode/F, var/datum/projectile/P)
	if (!src.firemodes)
		src.firemodes = list()
	var/len = length(firemodes)
	if (len == 0)
		src.current_firemode = F ? F : P.default_firemode

	if (len > 0)
		if (firemodes[len][2] != P)
			multiple_projectiles = TRUE
		if (firemodes[len][1] != F)
			multiple_firemodes = TRUE
	src.firemodes += null
	src.firemodes[len+1] = list(F, P)
	return

///OVERRIDE_FIREMODE
///Return a non-null firemode to override the projectile's default firemode
/obj/item/gun/proc/override_firemode()
	return

///CHECK_VALID_SHOT
///Call to check and make sure the shot is ok
///Not called much atm might remove, is now inside shoot
/obj/item/gun/proc/check_valid_shot(atom/target as mob|obj|turf|area, mob/user as mob)
	var/turf/T = get_turf(user)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return 0
	if (U == T)
		//user.bullet_act(current_projectile)
		return 0
	return 1
/*
/obj/item/gun/proc/emag(obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/card/emag))
		boutput(user, SPAN_ALERT("No lock to break!"))
		return 1
	return 0
*/
/obj/item/gun/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (user)
		boutput(user, SPAN_ALERT("No lock to break!"))
	return 0

/obj/item/gun/attack_self(mob/user as mob)
	..()
	if(src.firemodes && length(src.firemodes) > 1)
		src.current_firemode_num = ((src.current_firemode_num) % src.firemodes.len) + 1
		src.set_current_firemode(src.firemodes[src.current_firemode_num][1])
		if (src.firemodes[src.current_firemode_num][2])
			src.set_current_projectile(src.firemodes[src.current_firemode_num][2])
		var/multivariate = multiple_firemodes && multiple_projectiles
		boutput(user, SPAN_NOTICE("You set the output to [multiple_firemodes ? "[src.current_firemode.name]":""][multivariate ? ", ":""][multiple_projectiles ? "[src.current_projectile.sname]":""]."))
	return

/obj/item/gun/pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
	if (reach)
		return 0
	if (!isturf(user.loc))
		return 0

	var/pox = text2num(params["icon-x"]) - 16 + target.pixel_x
	var/poy = text2num(params["icon-y"]) - 16 + target.pixel_y
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)

	//if they're holding a gun in each hand... why not shoot both!
	var/is_dual_wield = 0
	if (can_dual_wield)
		if(ishuman(user))
			var/obj/item/gun/G
			if(user.hand && istype(user.r_hand, /obj/item/gun))
				G = user.r_hand
			else if(!user.hand && istype(user.l_hand, /obj/item/gun))
				G = user.l_hand

			if (G && G.can_dual_wield && G.canshoot(user))
				is_dual_wield = 1
				if(!ON_COOLDOWN(G, "shot_delay", G.shoot_delay))
					SPAWN(0.2 SECONDS)
						if(!(G in user.equipped_list())) return
						G.Shoot(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2), is_dual_wield, target)

		else if(ismobcritter(user))
			var/mob/living/critter/M = user
			var/list/obj/item/gun/guns = list()
			for(var/datum/handHolder/H in M.hands)
				if(H.item && H.item != src && istype(H.item, /obj/item/gun) && H.item:can_dual_wield)
					is_dual_wield = 1
					if (H.item:canshoot(user))
						guns += H.item
			SPAWN(0)
				for(var/obj/item/gun/gun in guns)
					if(!ON_COOLDOWN(gun, "shot_delay", gun.shoot_delay))
						sleep(0.2 SECONDS)
						if(!(gun in user.equipped_list())) return
						gun.Shoot(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2), is_dual_wield, target)

	if(!ON_COOLDOWN(src, "shot_delay", src.shoot_delay))
		Shoot(target_turf, user_turf, user, pox, poy, is_dual_wield, target)


	return 1


/obj/item/gun/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (!target || !ismob(target)) //Wire note: Fix for Cannot modify null.lastattacker
		return ..()

	user.lastattacked = get_weakref(target)
	target.lastattacker = get_weakref(user)
	target.lastattackertime = world.time

	if(user.a_intent != INTENT_HELP && isliving(target))
		if (user.a_intent == INTENT_GRAB)
			var/datum/limb/current_limb = user.equipped_limb()
			if (current_limb.can_gun_grab)
				attack_particle(user,target)
				return ..()
		src.ShootPointBlank(target, user)
	else
		..()
		attack_particle(user,target)

#ifdef DATALOGGER
		game_stats.Increment("violence")
#endif
		return

/obj/item/gun/proc/ShootPointBlank(atom/target, var/mob/user as mob, var/second_shot = 0)
	if(!SEND_SIGNAL(src, COMSIG_GUN_TRY_POINTBLANK, target, user, second_shot))
		src.shoot_point_blank(target, user, second_shot)

/obj/item/gun/proc/shoot_point_blank(atom/target, var/mob/user as mob, var/second_shot = 0)
	if (!target || !user)
		return FALSE

	if (isghostdrone(user))
		user.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
		return FALSE

	var/is_dual_wield = 0
	var/obj/item/gun/second_gun
	//Ok. i know it's kind of dumb to add this param 'second_shot' to the shoot_point_blank proc just to make sure pointblanks don't repeat forever when we could just move these checks somewhere else.
	//but if we do the double-gun checks here, it makes stuff like double-hold-at-gunpoint-pointblanks easier!
	if (can_dual_wield && !second_shot)
		//brutal double-pointblank shots
		if (ishuman(user))
			if(user.hand && istype(user.r_hand, /obj/item/gun) && user.r_hand:can_dual_wield)
				second_gun = user.r_hand
				var/target_turf = get_turf(target)
				is_dual_wield = 1
				SPAWN(0.2 SECONDS)
					if(user.r_hand != second_gun) return
					if (BOUNDS_DIST(user, target) == 0)
						second_gun.ShootPointBlank(target,user,second_shot = 1)
					else
						second_gun.shoot(target_turf,get_turf(user), user, rand(-5,5), rand(-5,5), is_dual_wield, target)
			else if(!user.hand && istype(user.l_hand, /obj/item/gun) && user.l_hand:can_dual_wield)
				second_gun = user.l_hand
				var/target_turf = get_turf(target)
				is_dual_wield = 1
				SPAWN(0.2 SECONDS)
					if(user.l_hand != second_gun) return
					if (BOUNDS_DIST(user, target) == 0)
						second_gun.ShootPointBlank(target,user,second_shot = 1)
					else
						second_gun.shoot(target_turf,get_turf(user), user, rand(-5,5), rand(-5,5), is_dual_wield, target)


	if (src.artifact && istype(src.artifact, /datum/artifact))
		var/datum/artifact/art_gun = src.artifact
		if (!art_gun.activated)
			return

	if (!canshoot(user))
		if (src.click_sound)
			if (!silenced)
				target.visible_message(SPAN_ALERT("<B>[user] tries to shoot [user == target ? "[him_or_her(user)]self" : target] with [src] point-blank, but it was empty!</B>"))
				playsound(user, click_sound, 60, TRUE)
			else
				user.show_text(src.click_msg, "red")
		return FALSE

	if (ishuman(user) && src.add_residue) // Additional forensic evidence for kinetic firearms (Convair880).
		var/mob/living/carbon/human/H = user
		H.gunshot_residue = 1

	if (!src.silenced)
		for (var/mob/O in AIviewers(target, null))
			if (O.client)
				O.show_message(SPAN_ALERT("<B>[user] shoots [user == target ? "[him_or_her(user)]self" : target] point-blank with [src]!</B>"))
	else
		boutput(user, SPAN_ALERT("You silently shoot [user == target ? "yourself" : target] point-blank with [src]!"))

	var/datum/firemode/FM = override_firemode()
	if (!process_ammo(user, FM || current_projectile.firemode))
		return FALSE

	if (src.muzzle_flash)
		if (isturf(user.loc))
			muzzle_flash_attack_particle(user, user.loc, target, src.muzzle_flash)


	if(slowdown && ismob(user))
		SPAWN(-1)
			user.movement_delay_modifier += slowdown
			sleep(slowdown_time)
			user.movement_delay_modifier -= slowdown

	var/spread = 0
	if (ismob(user) && user.reagents)
		var/how_drunk = 0
		var/amt = user.reagents.get_reagent_amount("ethanol")
		switch(amt)
			if (110 to INFINITY)
				how_drunk = 2
			if (1 to 110)
				how_drunk = 1
		how_drunk = max(0, how_drunk - isalcoholresistant(user))
		spread += 5 * how_drunk
	spread = max(spread, spread_angle)

	spread += (recoil/recoil_max) * recoil_inaccuracy_max
	for (var/i = 0; i < FM.shot_number; i++)
		var/obj/projectile/P = initialize_projectile_pixel_spread(user, current_projectile, target, 0, 0, spread, alter_proj = new/datum/callback(src, PROC_REF(alter_projectile)), firemode = FM)
		if (!P)
			return FALSE
		if (user == target)
			P.shooter = null
			P.mob_shooter = user

		P.forensic_ID = src.forensic_ID // Was missing (Convair880).
		if(BOUNDS_DIST(user, target) == 0)
			P.was_pointblank = 1
			hit_with_existing_projectile(P, target) // Includes log entry.
		else
			P.launch()

		var/mob/living/L = target
		if (istype(L))
			if (isalive(L))
				L.lastgasp()
			L.set_clothing_icon_dirty()
		src.UpdateIcon()
		sleep(FM.shot_delay)

/obj/item/gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	src.add_fingerprint(user)
	if (flag)
		return

/obj/item/gun/proc/alter_projectile(var/obj/projectile/P)
	return

/obj/item/gun/proc/Shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
	if(!SEND_SIGNAL(src, COMSIG_GUN_TRY_SHOOT, target, start, user, POX, POY, is_dual_wield, called_target))
		src.shoot(target, start, user, POX, POY, is_dual_wield, called_target)

/obj/item/gun/proc/shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
	if (isghostdrone(user))
		user.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
		return FALSE

	if(!isturf(target))
		target = get_turf(target)

	if(isnull(target))
		return FALSE

	if (!canshoot(user))
		if (ismob(user) && src.click_sound)
			user.show_text(src.click_msg, "red") // No more attack messages for empty guns (Convair880).
			if (!silenced)
				playsound(user, click_sound, 60, TRUE)
		return FALSE
	var/datum/firemode/fireMode = override_firemode()
	if (!process_ammo(user, fireMode || current_projectile.firemode))
		return FALSE
	if (!isturf(start))
		return FALSE
	if (!istype(src.current_projectile,/datum/projectile/))
		return FALSE

	if (src.muzzle_flash)
		if (isturf(user.loc))
			var/turf/origin = user.loc
			muzzle_flash_attack_particle(user, origin, target, src.muzzle_flash)


	if (ismob(user))
		var/mob/M = user
		SEND_SIGNAL(M, COMSIG_MOB_TRIGGER_THREAT)
		if(slowdown)
			SPAWN(-1)
				M.movement_delay_modifier += slowdown
				sleep(slowdown_time)
				M.movement_delay_modifier -= slowdown

	var/spread = is_dual_wield*10
	if (user.reagents)
		var/how_drunk = 0
		var/amt = user.reagents.get_reagent_amount("ethanol")
		switch(amt)
			if (110 to INFINITY)
				how_drunk = 2
			if (1 to 110)
				how_drunk = 1
		how_drunk = max(0, how_drunk - isalcoholresistant(user))
		spread += 5 * how_drunk
	spread = max(spread, spread_angle)

	spread += (recoil/recoil_max) * recoil_inaccuracy_max

	var/obj/projectile/P = shoot_projectile_ST_pixel_spread(user, current_projectile, target, POX, POY, spread, alter_proj = new/datum/callback(src, PROC_REF(alter_projectile)), firemode = fireMode)
	if (P)
		P.forensic_ID = src.forensic_ID
	P.spread = spread
	if(user && !suppress_fire_msg)
		if(!src.silenced)
			for(var/mob/O in AIviewers(user, null))
				O.show_message(SPAN_ALERT("<B>[user] fires [src] at [target]!</B>"), 1, SPAN_ALERT("You hear a gunshot"), 2)
		else
			if (ismob(user)) // Fix for: undefined proc or verb /obj/item/mechanics/gunholder/show text().
				user.show_text(SPAN_ALERT("You silently fire the [src] at [target]!")) // Some user feedback for silenced guns would be nice (Convair880).

		var/turf/T = target
		src.log_shoot(user, T, P)

	SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

	handle_recoil(user, start, target, POX, POY)

	if (ismob(user))
		var/mob/M = user
		if (ishuman(M) && src.add_residue) // Additional forensic evidence for kinetic firearms (Convair880).
			var/mob/living/carbon/human/H = user
			H.gunshot_residue = 1

	src.UpdateIcon()
	return TRUE

/// Check if the gun can shoot or not. `user` will be null if the gun is shot by a non-mob (gun component)
/obj/item/gun/proc/canshoot(mob/user)
	return 0

/obj/item/gun/proc/log_shoot(mob/user, turf/T, obj/projectile/P)
	logTheThing(LOG_COMBAT, user, "fires \a [src] from [log_loc(user)], vector: ([T.x - user.x], [T.y - user.y]), dir: <I>[dir2text(get_dir(user, T))]</I>, projectile: <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", [P.proj_data.type]" : null]")

/obj/item/gun/examine()
	if (src.artifact)
		return list("You have no idea what the hell this thing is!")
	return ..()

/obj/item/gun/proc/process_ammo(var/mob/user, var/datum/firemode/firemode = null)
	if (src.click_sound)
		boutput(user, SPAN_ALERT(src.click_msg))
		if (!src.silenced)
			playsound(user, click_sound, 60, TRUE)
	return 0

// Could be useful in certain situations (Convair880).
/obj/item/gun/proc/logme_temp(mob/user as mob, obj/item/gun/G as obj, obj/item/ammo/A as obj)
	if (!user || !G || !A)
		return

	else if (istype(G, /obj/item/gun/kinetic) && istype(A, /obj/item/ammo/bullets))
		logTheThing(LOG_COMBAT, user, "reloads [G] (<b>Ammo type:</b> <i>[G.current_projectile.type]</i>) at [log_loc(user)].")
		return

	else if (istype(G, /obj/item/gun/energy) && istype(A, /obj/item/ammo/power_cell))
		logTheThing(LOG_COMBAT, user, "reloads [G] (<b>Cell type:</b> <i>[A.type]</i>) at [log_loc(user)].")
		return

	else return

/obj/item/gun/custom_suicide = 1
/obj/item/gun/suicide(var/mob/living/carbon/human/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if (!src.canshoot(user))
		return 0

	user.visible_message(SPAN_ALERT("<b>[user] places [src] against [his_or_her(user)] head!</b>"))
	var/dmg = user.get_brute_damage() + user.get_burn_damage()
	src.ShootPointBlank(user, user)
	var/new_dmg = user.get_brute_damage() + user.get_burn_damage()
	if (new_dmg >= (dmg + 20)) // it did some appreciable amount of damage
		user.TakeDamage("head", 500, 0)
	else if (new_dmg < (dmg + 20))
		user.visible_message(SPAN_ALERT("[user] hangs [his_or_her(user)] head in shame because [he_or_she(user)] chose such a weak gun."))
	return 1

/obj/item/gun/on_spin_emote(var/mob/living/carbon/human/user as mob)
	. = ..(user)
	if (((user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50)) || (user.reagents && prob(user.reagents.get_reagent_amount("ethanol") / 2)) || prob(5)) && !safe_spin)
		user.visible_message(SPAN_ALERT("<b>[user] accidentally shoots [him_or_her(user)]self with [src]!</b>"))
		src.ShootPointBlank(user, user)
		JOB_XP(user, "Clown", 3)


///setter for current_projectile so we can have a signal attached. do not set current_projectile on guns without this proc
/obj/item/gun/proc/set_current_projectile(datum/projectile/newProj)
	if (!current_firemode)
		src.current_firemode = new newProj.default_firemode()
		SEND_SIGNAL(src, COMSIG_GUN_FIREMODE_CHANGED, current_firemode)
	src.current_projectile = newProj
	src.tooltip_rebuild = EVAL_BOOL_TRUE
	SEND_SIGNAL(src, COMSIG_GUN_PROJECTILE_CHANGED, newProj)

///setter for current_projectile so we can have a signal attached. do not set current_projectile on guns without this proc
/obj/item/gun/proc/set_current_firemode(datum/firemode/newFiremode)
	src.current_firemode = newFiremode
	SEND_SIGNAL(src, COMSIG_GUN_FIREMODE_CHANGED, newFiremode)

/obj/item/gun/proc/do_camera_recoil(mob/user, turf/start, turf/target, POX, POY)
	// calculate the mob's position relative to the target location
	// this is backwards so that the output angle is the angle we knock the camera back
	var/x_diff = (start.x - target.x) * world.icon_size - POX
	var/y_diff = (start.y - target.y) * world.icon_size - POY

	var/dir = arctan(x_diff, y_diff)
	var/total_strength = src.recoil_strength
	if (recoil_stacking_enabled)
		total_strength += clamp(round(recoil_stacks) - recoil_stacking_safe_stacks,0,recoil_stacking_max_stacks) * recoil_stacking_amount
	var/variance = clamp(total_strength * camera_recoil_sway_multiplier, camera_recoil_sway_min, camera_recoil_sway_max)

	recoil_camera(user, dir, total_strength * camera_recoil_multiplier, variance)


/obj/item/gun/proc/do_icon_recoil()
	if (!icon_recoil_enabled)
		return
	while(src.recoil > 0)
		var/timediff = TIME - recoil_last_shot
		if (timediff >= recoil_reset)
			recoil *= recoil_reset_mult
			recoil -= recoil_reset_add // small linear part to aid with low values
			recoil = clamp(recoil,0, recoil_max)
			recoil_stacks = clamp(round(recoil_stacks) - 0.25, 0, recoil_stacking_max_stacks)

		var/base_icon_recoil = round((recoil/recoil_max)*icon_recoil_cap)
		var/matrix/M = src.transform
		var/jitter = base_icon_recoil/5
		var/jittervalue = rand(-jitter, jitter)
		if (src.recoil < current_anim_recoil || timediff > 0.2 DECI SECONDS) // stop the gun jerking up after you stop shooting
			jittervalue = 0
		var/target_recoil = base_icon_recoil + jittervalue

		var/recoil_diff = (current_anim_recoil - target_recoil)
		current_anim_recoil = target_recoil
		animate(src, transform = matrix(M, recoil_diff, MATRIX_ROTATE | MATRIX_MODIFY), 0.1)
		sleep(0.1 SECONDS)
	recoil_stacks = 0

/obj/item/gun/proc/handle_recoil(mob/user, turf/start, turf/target, POX, POY, first_shot = TRUE)
	if (!recoil_enabled || !istype(user))
		return
	var/start_recoil = FALSE
	if (recoil == 0)
		start_recoil = TRUE // if recoil is 0, make sure do_recoil starts

	// Add recoil
	var/stacked_recoil = 0
	if (recoil_stacking_enabled)
		recoil_stacks += 1
		stacked_recoil = clamp(round(recoil_stacks) - recoil_stacking_safe_stacks,0,recoil_stacking_max_stacks) * recoil_stacking_amount

	recoil += (recoil_strength + stacked_recoil)
	recoil = clamp(recoil, 0, recoil_max)
	recoil_last_shot = TIME
	if (camera_recoil_enabled)
		do_camera_recoil(user, start,target,POX,POY)

	var/datum/firemode/fireMode = override_firemode() || src.current_projectile.firemode

	if (first_shot && fireMode.shot_number > 1 && fireMode.shot_delay > 0)
		for (var/i=1 to fireMode.shot_number-1)
			SPAWN(i*fireMode.shot_delay)
				handle_recoil(user,start,target,POX,POY, FALSE)
	if (start_recoil && icon_recoil_enabled)
		SPAWN(0)
			do_icon_recoil()
