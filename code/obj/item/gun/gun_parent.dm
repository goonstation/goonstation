var/list/forensic_IDs = new/list() //Global list of all guns, based on bioholder uID stuff

/obj/item/gun
	name = "gun"
	icon = 'icons/obj/items/gun.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY | EXTRADELAY
	object_flags = NO_GHOSTCRITTER
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab/gunpoint

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

	var/continuous = 0 //If 1, fire pixel based while button is held.
	var/c_interval = 3 //Interval between shots while button is held.
	var/c_windup = 0 //Time before we start firing while button is held - think minigun.
	var/c_windup_sound = null //Sound to play during windup. TBI

	var/c_firing = 0
	var/c_mouse_down = 0
	var/datum/gunTarget/c_target = null

	var/suppress_fire_msg = 0

	var/spread_angle = 0
	var/datum/projectile/current_projectile = null
	var/list/projectiles = null
	var/current_projectile_num = 1
	var/silenced = 0
	var/can_dual_wield = 1

	var/slowdown = 0 //Movement delay attack after attack
	var/slowdown_time = 10 //For this long

	var/forensic_ID = null
	var/add_residue = 0 // Does this gun add gunshot residue when fired (Convair880)?

	var/charge_up = 0 //Does this gun have a charge up time and how long is it? 0 = normal instant shots.
	var/shoot_delay = 4

	var/muzzle_flash = null //set to a different icon state name if you want a different muzzle flash when fired, flash anims located in icons/mob/mob.dmi

	var/fire_animation = FALSE //Used for guns that have animations when firing

	buildTooltipContent()
		. = ..()
		if(current_projectile)
			. += "<br><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/ranged.png")]\" width=\"10\" height=\"10\" /> Bullet Power: [current_projectile.power] - [current_projectile.ks_ratio * 100]% lethal"
		lastTooltipContent = .

	New()
		SPAWN(2 SECONDS)
			src.forensic_ID = src.CreateID()
			forensic_IDs.Add(src.forensic_ID)
		return ..()

/datum/gunTarget
	var/params = null
	var/target = null
	var/user = 0

/obj/item/gun/onMouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(!continuous) return
	if(c_target == null) c_target = new()
	c_target.params = params2list(params)
	c_target.target = over_object
	c_target.user = usr

/obj/item/gun/onMouseDown(atom/object,location,control,params) //This doesnt work with reach, will pistolwhip once. FIX.
	if(!continuous) return
	if(object == src || (!isturf(object.loc) && !isturf(object))) return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.in_throw_mode) return
	c_mouse_down = 1
	SPAWN(c_windup)
		if(!c_firing && c_mouse_down)
			continuousFire(object, params, usr)

/obj/item/gun/onMouseUp(object,location,control,params)
	c_mouse_down = 0

/obj/item/gun/proc/continuousFire(atom/target, params, mob/user)
	if(!continuous) return
	if(c_target == null) c_target = new()
	c_target.params = params2list(params)
	c_target.target = target
	c_target.user = user

	if(!c_firing)
		c_firing = 1
		SPAWN(0)
			while(src?.c_mouse_down)
				pixelaction(src.c_target.target, src.c_target.params, src.c_target.user, 0, 1)
				suppress_fire_msg = 1
				sleep(src.c_interval)
			src.c_firing = 0
			suppress_fire_msg = 0

/obj/item/gun/proc/CreateID() //Creates a new tracking id for the gun and returns it.
	. = ""

	do
		for(var/i = 1 to 10) // 20 characters are way too fuckin' long for anyone to care about
			. += "[pick(numbersAndLetters)]"
	while(. in forensic_IDs)


///CHECK_LOCK
///Call to run a weaponlock check vs the users implant
///Return 0 for fail
/obj/item/gun/proc/check_lock(var/user as mob)
	return 1

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
		boutput(user, "<span class='alert'>No lock to break!</span>")
		return 1
	return 0
*/
/obj/item/gun/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (user)
		boutput(user, "<span class='alert'>No lock to break!</span>")
	return 0

/obj/item/gun/attack_self(mob/user as mob)
	..()
	if(src.projectiles && src.projectiles.len > 1)
		src.current_projectile_num = ((src.current_projectile_num) % src.projectiles.len) + 1
		src.set_current_projectile(src.projectiles[src.current_projectile_num])
		boutput(user, "<span class='notice'>You set the output to [src.current_projectile.sname].</span>")
	return

/datum/action/bar/icon/guncharge
	duration = 150
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "guncharge"
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	icon_state = "screwdriver"
	var/obj/item/gun/ownerGun
	var/pox
	var/poy
	var/user_turf
	var/target_turf

	New(_gun, _pox, _poy, _uturf, _tturf, _time, _icon, _icon_state)
		ownerGun = _gun
		pox = _pox
		poy = _poy
		user_turf = _uturf
		target_turf = _tturf
		icon = _icon
		icon_state = _icon_state
		duration = _time
		..()

	onEnd()
		..()
		ownerGun.shoot(target_turf, user_turf, owner, pox, poy)

/datum/action/bar/icon/guncharge_pointblank
	duration = 150
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "guncharge"
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	icon_state = "screwdriver"
	var/obj/item/gun/ownerGun
	var/atom/target
	var/mob/user
	var/second_shot

	New(_gun, _target, _user, _second_shot, _time, _icon, _icon_state)
		ownerGun = _gun
		target = _target
		user = _user
		second_shot = _second_shot
		icon = _icon
		icon_state = _icon_state
		duration = _time
		..()

	onEnd()
		..()
		ownerGun.shoot_point_blank(target, user, second_shot, TRUE)

/obj/item/gun/pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
	if (reach)
		return 0
	if (!isturf(user.loc))
		return 0
	if(continuous && !continuousFire)
		return 0

	var/pox = text2num(params["icon-x"]) - 16 + target.pixel_x
	var/poy = text2num(params["icon-y"]) - 16 + target.pixel_y
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)

	//if they're holding a gun in each hand... why not shoot both!
	var/is_dual_wield = 0
	if (can_dual_wield && (!charge_up))
		if(ishuman(user))
			var/obj/item/gun/G
			if(user.hand && istype(user.r_hand, /obj/item/gun))
				G = user.r_hand
			else if(!user.hand && istype(user.l_hand, /obj/item/gun))
				G = user.l_hand

			if (G && G.can_dual_wield && G.canshoot(user))
				is_dual_wield = 1
				if(!ON_COOLDOWN(G, "shoot_delay", G.shoot_delay))
					SPAWN(0.2 SECONDS)
						if(!(G in user.equipped_list())) return
						G.shoot(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2), is_dual_wield)

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
					if(!ON_COOLDOWN(gun, "shoot_delay", gun.shoot_delay))
						sleep(0.2 SECONDS)
						if(!(gun in user.equipped_list())) return
						gun.shoot(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2), is_dual_wield)

	if(!ON_COOLDOWN(src, "shoot_delay", src.shoot_delay))
		if(charge_up && !can_dual_wield && canshoot(user))
			actions.start(new/datum/action/bar/icon/guncharge(src, pox, poy, user_turf, target_turf, charge_up, icon, icon_state), user)
		else
			shoot(target_turf, user_turf, user, pox, poy, is_dual_wield)


	return 1

/obj/item/gun/attack(mob/M, mob/user)
	if (!M || !ismob(M)) //Wire note: Fix for Cannot modify null.lastattacker
		return ..()

	user.lastattacked = M
	M.lastattacker = user
	M.lastattackertime = world.time

	if(user.a_intent != INTENT_HELP && isliving(M))
		if (user.a_intent == INTENT_GRAB)
			attack_particle(user,M)
			return ..()
		else
			src.shoot_point_blank(M, user)
	else
		..()
		attack_particle(user,M)

#ifdef DATALOGGER
		game_stats.Increment("violence")
#endif
		return

/obj/item/gun/proc/shoot_point_blank(atom/target, var/mob/user as mob, var/second_shot = 0, var/skip_charge_up = FALSE)
	if (!target || !user)
		return FALSE

	if (isghostdrone(user))
		user.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
		return FALSE

	if (charge_up && !skip_charge_up && !can_dual_wield && canshoot(user))
		actions.start(new/datum/action/bar/icon/guncharge_pointblank(src, target, user, second_shot, charge_up, icon, icon_state), user)
		return

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
						second_gun.shoot_point_blank(target,user,second_shot = 1)
					else
						second_gun.shoot(target_turf,get_turf(user), user, rand(-5,5), rand(-5,5), is_dual_wield)
			else if(!user.hand && istype(user.l_hand, /obj/item/gun) && user.l_hand:can_dual_wield)
				second_gun = user.l_hand
				var/target_turf = get_turf(target)
				is_dual_wield = 1
				SPAWN(0.2 SECONDS)
					if(user.l_hand != second_gun) return
					if (BOUNDS_DIST(user, target) == 0)
						second_gun.shoot_point_blank(target,user,second_shot = 1)
					else
						second_gun.shoot(target_turf,get_turf(user), user, rand(-5,5), rand(-5,5), is_dual_wield)


	if (src.artifact && istype(src.artifact, /datum/artifact))
		var/datum/artifact/art_gun = src.artifact
		if (!art_gun.activated)
			return

	if (!canshoot(user))
		if (!silenced)
			target.visible_message("<span class='alert'><B>[user] tries to shoot [user == target ? "[him_or_her(user)]self" : target] with [src] point-blank, but it was empty!</B></span>")
			playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
		else
			user.show_text("*click* *click*", "red")
		return FALSE

	if (ishuman(user) && src.add_residue) // Additional forensic evidence for kinetic firearms (Convair880).
		var/mob/living/carbon/human/H = user
		H.gunshot_residue = 1

	if (!src.silenced)
		for (var/mob/O in AIviewers(target, null))
			if (O.client)
				O.show_message("<span class='alert'><B>[user] shoots [user == target ? "[him_or_her(user)]self" : target] point-blank with [src]!</B></span>")
	else
		boutput(user, "<span class='alert'>You silently shoot [user == target ? "yourself" : target] point-blank with [src]!</span>")

	if (!process_ammo(user))
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
	for (var/i = 0; i < current_projectile.shot_number; i++)
		var/obj/projectile/P = initialize_projectile_pixel_spread(user, current_projectile, target, 0, 0, spread, alter_proj = new/datum/callback(src, .proc/alter_projectile))
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
		sleep(current_projectile.shot_delay)

/obj/item/gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	src.add_fingerprint(user)
	if(continuous) return
	if (flag)
		return

/obj/item/gun/proc/alter_projectile(var/obj/projectile/P)
	return

/obj/item/gun/proc/shoot(var/target,var/start,var/mob/user,var/POX,var/POY,var/is_dual_wield)
	if (isghostdrone(user))
		user.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
		return FALSE
	if (!canshoot(user))
		if (ismob(user))
			user.show_text("*click* *click*", "red") // No more attack messages for empty guns (Convair880).
			if (!silenced)
				playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
		return FALSE
	if (!process_ammo(user))
		return FALSE
	if (!isturf(target) || !isturf(start))
		return FALSE
	if (!istype(src.current_projectile,/datum/projectile/))
		return FALSE

	if (src.muzzle_flash)
		if (isturf(user.loc))
			var/turf/origin = user.loc
			muzzle_flash_attack_particle(user, origin, target, src.muzzle_flash)


	if (ismob(user))
		var/mob/M = user
		if (M.mob_flags & AT_GUNPOINT)
			for(var/obj/item/grab/gunpoint/G in M.grabbed_by)
				G.shoot()
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

	var/obj/projectile/P = shoot_projectile_ST_pixel_spread(user, current_projectile, target, POX, POY, spread, alter_proj = new/datum/callback(src, .proc/alter_projectile))
	if (P)
		P.forensic_ID = src.forensic_ID

	if(user && !suppress_fire_msg)
		if(!src.silenced)
			for(var/mob/O in AIviewers(user, null))
				O.show_message("<span class='alert'><B>[user] fires [src] at [target]!</B></span>", 1, "<span class='alert'>You hear a gunshot</span>", 2)
		else
			if (ismob(user)) // Fix for: undefined proc or verb /obj/item/mechanics/gunholder/show text().
				user.show_text("<span class='alert'>You silently fire the [src] at [target]!</span>") // Some user feedback for silenced guns would be nice (Convair880).

		var/turf/T = target
		src.log_shoot(user, T, P)

	SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

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

/obj/item/gun/proc/process_ammo(var/mob/user)
	boutput(user, "<span class='alert'>*click* *click*</span>")
	if (!src.silenced)
		playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
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

	user.visible_message("<span class='alert'><b>[user] places [src] against [his_or_her(user)] head!</b></span>")
	var/dmg = user.get_brute_damage() + user.get_burn_damage()
	src.shoot_point_blank(user, user)
	var/new_dmg = user.get_brute_damage() + user.get_burn_damage()
	if (new_dmg >= (dmg + 20)) // it did some appreciable amount of damage
		user.TakeDamage("head", 500, 0)
	else if (new_dmg < (dmg + 20))
		user.visible_message("<span class='alert'>[user] hangs their head in shame because they chose such a weak gun.</span>")
	return 1

/obj/item/gun/on_spin_emote(var/mob/living/carbon/human/user as mob)
	. = ..(user)
	if ((user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50)) || (user.reagents && prob(user.reagents.get_reagent_amount("ethanol") / 2)) || prob(5))
		user.visible_message("<span class='alert'><b>[user] accidentally shoots [him_or_her(user)]self with [src]!</b></span>")
		src.shoot_point_blank(user, user)
		JOB_XP(user, "Clown", 3)


///setter for current_projectile so we can have a signal attached. do not set current_projectile on guns without this proc
/obj/item/gun/proc/set_current_projectile(datum/projectile/newProj)
	src.current_projectile = newProj
	SEND_SIGNAL(src, COMSIG_GUN_PROJECTILE_CHANGED, newProj)
