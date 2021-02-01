var/list/forensic_IDs = new/list() //Global list of all guns, based on bioholder uID stuff

/obj/item/gun
	name = "gun"
	icon = 'icons/obj/items/gun.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY | EXTRADELAY
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab/gunpoint

	item_state = "gun"
	m_amt = 2000
	force = 10.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 4
	throw_range = 6
	contraband = 4
	hide_attack = 2 //Point blanking... gross
	pickup_sfx = "sound/items/pickup_gun.ogg"
	inventory_counter_enabled = 1

	var/continuous = 0 //If 1, fire pixel based while button is held.
	var/c_interval = 3 //Interval between shots while button is held.
	var/c_windup = 0 //Time before we start firing while button is held - think minigun.
	var/c_windup_sound = null //Sound to play during windup. TBI

	var/c_firing = 0
	var/c_mouse_down = 0
	var/datum/gunTarget/c_target = null

	var/suppress_fire_msg = 0

	var/rechargeable = 0 // Can we put this gun in a recharger?
	var/robocharge = 800
	var/custom_cell_max_capacity = null // Is there a limit as to what power cell (in PU) we can use?
	var/wait_cycle = 0 // Using a self-charging cell should auto-update the gun's sprite.

	/// Currently loaded magazine, shoot will read whatever's in its mag_contents to determine what to shoot
	/// Should be null here
	var/obj/item/ammo/loaded_magazine
	/// Magazine to load into the gun when spawned. AMMO_MAGAZINEs and AMMO_BELTMAGes only, please
	/// Should *not* be null, empty guns should have at least some kind of obj/item/ammo/bullets/empty
	var/obj/item/ammo/ammo = /obj/item/ammo/bullets/empty
	/// Checks against the magazine's caliber to see if it'll hold it
	var/caliber = CALIBER_ANY // Can be a list too. The .357 Mag revolver can also chamber .38 Spc rounds, for instance (Convair880).
	/// What kind(s) of magazine do we accept?
	/// Set to AMMO_ENERGY to make the gun an energy weapon
	var/list/accepted_mag = list(AMMO_PILE, AMMO_CLIP)
	/// Is the magazine fixed in place and cant be removed, like a shotgun? Makes most sense with accepted_mag AMMO_PILE and AMMO_CLIP
	var/fixed_mag = FALSE
	/// Are we allowed to unload the gun at all?
	var/can_unload = TRUE
	/// Are we allowed to reload the gun at all?
	var/can_reload = TRUE

	/// List of sounds to play when messing with the gun (loading, unloading, pretty much just that)
	var/datum/gun_sounds/gunsounds = new/datum/gun_sounds/test
	/// List of sounds to play when shooting, if any
	var/datum/shoot_sounds/shootsounds

	/// Infinite Ammo -- Magazine list isnt changed on firing
	/// Projectile Override -- Shoot default projectile instead of what's in the mag's list

	var/has_empty_state = 0 //does this gun have a special icon state for having no ammo lefT?
	var/gildable = 0 //can this gun be affected by the [Helios] medal reward?

	var/auto_eject = 0 // Do we eject casings on firing, or on reload?
	/// Stores whatever casings dont get ejected
	var/list/casings_to_eject = list() // If we don't automatically ejected them, we need to keep track (Convair880).

	var/allowReverseReload = 1 //Use gun on ammo to reload
	var/allowDropReload = 1    //Drag&Drop ammo onto gun to reload

	// On non-energy weapons, this is set by the top index in src.loaded_magazine.mag_contents when asked to shoot
	// On energy weapons, this is set by the firemode's "projectile" setting
	// In either case, this should probably stay null
	var/datum/projectile/current_projectile = null

	var/silenced = 0
	var/can_dual_wield = 1

	var/slowdown = 0 //Movement delay attack after attack
	var/slowdown_time = 10 //For this long

	var/forensic_ID = null
	var/add_residue = 0 // Does this gun add gunshot residue when fired (Convair880)?

	var/charge_up = 0 //Does this gun have a charge up time and how long is it? 0 = normal instant shots.

	/// Number of times to shoot the gun when asked to shoot
	var/burst_count = 1
	/// Time after clicking the gun before it'll allow you to click with the gun again
	var/shoot_delay = 4
	/// Time between shots in a burst
	var/refire_delay = (0.7 DECI SECONDS)
	/// If not 0, the bullet will shoot off course by between 0 and this number degrees
	var/spread_angle = 0
	/// Firemode datum, changes how the gun fires
	var/list/firemodes = list(new/datum/firemode/single)
	/// Our current firemode's index
	var/firemode_index = 1

	/// Currently shooting, so don't accept more requests to shoot
	var/shooting = 0

	var/muzzle_flash = null //set to a different icon state name if you want a different muzzle flash when fired, flash anims located in icons/mob/mob.dmi

	buildTooltipContent()
		. = ..()
		if(current_projectile)
			. += "<br><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/ranged.png")]\" width=\"10\" height=\"10\" /> Bullet Power: [current_projectile.power] - [current_projectile.ks_ratio * 100]% lethal"
		lastTooltipContent = .

	New(var/loc, var/list/loaded_magazine, var/list/_firemodes)
		if(_firemodes)
			src.firemodes = _firemodes
		if(!islist(src.caliber))
			src.caliber = list(src.caliber)
		if(!islist(src.accepted_mag))
			src.accepted_mag = list(src.accepted_mag)
		src.loaded_magazine = loaded_magazine
		if(!src.loaded_magazine)
			src.loaded_magazine = new src.ammo
			src.loaded_magazine.loaded_in = src
		src.set_firemode(initialize = TRUE)
		if (!(src in processing_items)) // No self-charging cell? Will be kicked out after the first tick (Convair880).
			processing_items.Add(src)
		SPAWN_DBG(2 SECONDS)
			src.forensic_ID = src.CreateID()
			forensic_IDs.Add(src.forensic_ID)
		update_icon()
		return ..()

	disposing()
		processing_items -= src
		..()

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
	SPAWN_DBG(c_windup)
		if(!c_firing && c_mouse_down)
			continuousFire(object, params, usr)

/obj/item/gun/onMouseUp(object,location,control,params)
	c_mouse_down = 0

// Thanks, material.dm!
/obj/item/gun/MouseDrop(over_object, src_location, over_location) //src dragged onto over_object
	if (isobserver(usr))
		boutput(usr, "<span class='alert'>Hey! Keep your cold, dead hands off of that!</span>")
		return

	if(!istype(over_object, /atom/movable/screen/hud))
		if (get_dist(usr,src) > 1)
			boutput(usr, "<span class='alert'>You're too far away from [src] to do that.</span>")
			return
		if (get_dist(usr,over_object) > 1)
			boutput(usr, "<span class='alert'>You're too far away from [over_object] to do that.</span>")
			return

	if(isturf(over_object)) // Drag this gun to that turf? Unload gun and put whatever comes out there
		boutput(usr, "Unloading [src] to [over_object] via clickdragon.")
		var/mob/user = usr
		if(src.unload_gun(user = user, put_it_here = over_object))
			return

	else if(istype(over_object, /atom/movable/screen/hud)) // Drag it to an inventory slot? Throw the mag in there
		var/atom/movable/screen/hud/H = over_object
		var/mob/living/carbon/human/dude = usr
		switch(H.id)
			if("lhand")
				if(dude.l_hand && dude.l_hand != src && src.unload_gun(user = dude))
					return
			if("rhand")
				if(dude.r_hand && dude.r_hand != src && src.unload_gun(user = dude))
					return
		// can't unload to any other slot until I can figure out how that works
		// till then, mags from two-handed guns go right on the floor where they belong

	return ..()


/obj/item/gun/proc/continuousFire(atom/target, params, mob/user)
	if(!continuous) return
	if(c_target == null) c_target = new()
	c_target.params = params2list(params)
	c_target.target = target
	c_target.user = user

	if(!c_firing)
		c_firing = 1
		SPAWN_DBG(0)
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
///return FALSE for fail
/obj/item/gun/proc/check_lock(var/user as mob)
	return TRUE

///CHECK_VALID_SHOT
///Call to check and make sure the shot is ok
///Not called much atm might remove, is now inside shoot
/obj/item/gun/proc/check_valid_shot(atom/target as mob|obj|turf|area, mob/user as mob)
	var/turf/T = get_turf(user)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return FALSE
	if (U == T)
		//user.bullet_act(current_projectile)
		return FALSE
	return TRUE

/obj/item/gun/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (user)
		boutput(user, "<span class='alert'>No lock to break!</span>")
	return FALSE

/obj/item/gun/proc/set_firemode(var/mob/user, var/initialize = 0)
	if(initialize)
		for(var/datum/firemode/F in src.firemodes)
			if(F.gunmaster != src)
				F.gunmaster = src
		src.firemode_index = 1
	else
		src.firemode_index += 1
		if(src.firemode_index > round(src.firemodes.len) || src.firemode_index < 1)
			src.firemode_index = 1
	var/datum/firemode/FM = src.firemodes[src.firemode_index]
	src.shoot_delay = FM.shoot_delay
	src.burst_count = FM.burst_count
	src.refire_delay = FM.refire_delay
	src.spread_angle = FM.spread_angle
	src.shootsounds = FM.sounds
	if(istype(FM.projectile, /datum/projectile))
		src.current_projectile = FM.projectile
	FM.switch_to_firemode(user)

/obj/item/gun/attackby(obj/item/ammo/b as obj, mob/user as mob)
	if(istype(b, /obj/item/ammo/) || istype(b, /obj/item/chem_grenade) || istype(b, /obj/item/grenade))
		if(src.load_gun(b, user))
			return
	..()

/obj/item/gun/attack_self(mob/user)
	if(src.firemodes.len > 1)
		src.set_firemode(user)

	return ..()

/obj/item/gun/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		if(src.unload_gun(user = user))
			return
		else
			return ..()
	else
		return ..()

	/// Move into *this* gun *that* ammo
/obj/item/gun/proc/load_gun(var/obj/item/ammo/A, var/mob/user)
	// Also see attackby() in kinetic.dm.
	if (!user) return
	if (!A)
		boutput(user, "No ammo to load!")
		return FALSE // Error message.

	src.handle_casings(eject_stored = TRUE, user = user)

	if(istype(A, /obj/item/chem_grenade) || istype(A, /obj/item/grenade)) // darn grenades
		if(istype(A, /obj/item/grenade))
			var/obj/item/grenade/G = A
			if(!G.launcher_ready)
				boutput(user, "[G] doesn't seem to fit in [src]!")
				return FALSE
		if(((CALIBER_ANY) in src.caliber) || (CALIBER_GRENADE in src.caliber))
			src.loaded_magazine.grenade_to_ammo(A, user = user)
			playsound(get_turf(user), src.gunsounds.soundLoadSingle, src.gunsounds.soundLoadSingleVolume)
			user.visible_message("[user] loads \a [A] into [src].", "You stuff \a [A] into your [src].")
		else
			boutput(user, "[A] is nowhere near the right size for [src]!")
		src.update_icon()
		return FALSE

	if (!istype(A, /obj/item/ammo))
		boutput(user, "That's not ammunition!")
		return FALSE // Error message.
	if (!src.can_reload)
		boutput(user, "[src] can't be reloaded!")
		return FALSE
	if(!(A.mag_type in src.accepted_mag))
		boutput(user, "[A] doesn't fit in [src]!")
		return FALSE

	src.add_fingerprint(user)
	A.add_fingerprint(user)

	// pile -> gun, check if the gun has a fixed magazine, then check if top_bullet is in the pile,
	//              check if top_bullet's caliber is valid with the gun's loaded magazine, then transfer that one bullet
	//              delete the pile if it ends up empty. Most of this is handled by the ammo pile item itself
	// magazine/box/energy -> gun, check if the gun's magazine isnt fixed and accepts magazines,
	//                        check if the magazine's stated caliber is in the gun's list of calibers, then swap the magazines
	//                        delete what comes out of the gun if its a dummy null magazine
	// clip -> gun, check if the gun's magazine is fixed, check if the magazine's stated caliber is in the gun's magazine's list of calibers,
	//              then transfer the bullets to the magazine
	//              don't delete the clip if it gets empty

	var/caliber_check
	if(!islist(src.caliber))
		src.caliber = list(src.caliber)
	if(!islist(A.caliber))
		A.caliber = list(A.caliber)
	// piles bypass the caliber check, it needs a bit more checking
	if((A.mag_type == AMMO_PILE) || ((CALIBER_ANY) in src.loaded_magazine.caliber))
		caliber_check = TRUE
	else
		for(var/this_caliber in A.caliber)
			if(this_caliber in src.caliber)
				caliber_check = TRUE
				break

	if(!caliber_check)
		var/list/caliber_list = A.caliber
		if(caliber_list.len > 3) caliber_list.len = 3
		boutput(user, "[A] ([A.caliber]) is the wrong caliber for \the [src] ([src.caliber]).")
		return FALSE

	switch(A.mag_type)
		if(AMMO_PILE, AMMO_CLIP) // Piles can only ever go into a loaded gun if the gun's magazine is fixed (revolver, shotgun, RPG, etc.)
			if(src.fixed_mag && src.loaded_magazine)
				var/loaded = src.loaded_magazine.load_ammo(A, user = user)
				if(loaded == 1)
					playsound(user, src.gunsounds.soundLoadSingle, src.gunsounds.soundLoadSingleVolume)
				else if (loaded > 1)
					playsound(user, src.gunsounds.soundLoadMultiple, src.gunsounds.soundLoadMultipleVolume)
			else
				boutput(user, "You can't load anything into [src.loaded_magazine] while it's inside \the [src]! Try removing the magazine first.")
				return FALSE
		if(AMMO_MAGAZINE, AMMO_BELTMAG, AMMO_ENERGY)
			if(src.fixed_mag) // Kinda hard to load a magazine into a revolver
				boutput(user, "\The [src] doesn't have a magazine you can remove or swap out, try feeding it some loose bullets or a clip.")
				return FALSE
			else
				src.swap(A, user) // Theres always a magazine inside the gun, even if its empty

	src.update_icon()
	A.update_icon()
	return TRUE

/obj/item/gun/proc/unload_gun(var/mob/user, var/atom/put_it_here)
	if(!user || !src.loaded_magazine) return FALSE

	if(src.loaded_magazine.is_null_mag) // but only if there is one in there
		boutput(user, "\The [src] doesn't have a magazine loaded!")
		return FALSE
	else if(!src.can_unload) // Something's preventing this gun from being unloaded
		boutput(user, "\The [src] can't be unloaded!")

	if(length(src.loaded_magazine.projectile_items) >= 1) // darn grenades
		if(length(src.loaded_magazine.projectile_items) == 1)
			playsound(user, src.gunsounds.soundUnloadSingle, src.gunsounds.soundUnloadSingleVolume)
		else
			playsound(user, src.gunsounds.soundUnloadMultiple, src.gunsounds.soundUnloadMultipleVolume)
		var/list/yanked = list()
		for(var/datum/projectile/P in src.loaded_magazine.projectile_items)
			yanked += src.loaded_magazine.projectile_items[P]
		boutput(user, "You remove [english_list(yanked)] from [src].")
		src.loaded_magazine.ammo_to_grenade() // Grenades? Yank em!
		src.handle_casings(eject_stored = TRUE, user = user)
		src.update_icon()
		return TRUE

	if(src.fixed_mag) // Cant remove the magazine, so lets try removing whats inside it!
		if(src.loaded_magazine.mag_type == AMMO_ENERGY) // Fixed battery? Cant remove it
			boutput(user, "\The [src] doesn't have a removable battery!")
			return FALSE
		else
			var/unloaded = src.loaded_magazine.unload_magazine(user = user, put_that_here = put_it_here)
			src.handle_casings(eject_stored = TRUE, user = user)
			src.update_icon()
			if(unloaded == 1)
				playsound(user, src.gunsounds.soundUnloadSingle, src.gunsounds.soundUnloadSingleVolume)
			else if (unloaded > 1)
				playsound(user, src.gunsounds.soundUnloadMultiple, src.gunsounds.soundUnloadMultipleVolume)
			return TRUE
	else // Removable magazine, lets remove it!
		var/obj/item/ammo/W = src.loaded_magazine
		W.loaded_in = null
		W.update_icon()
		if(put_it_here && isturf(put_it_here))
			W.set_loc(put_it_here)
		else
			user.put_in_hand_or_drop(W)
		src.loaded_magazine = new /obj/item/ammo/bullets/empty(src)
		src.loaded_magazine.loaded_in = src
		src.update_icon()
		src.add_fingerprint(user)
		src.handle_casings(eject_stored = TRUE, user = user) // Some kind of gun that stores its casings in the mag, I guess
		playsound(user, src.gunsounds.soundUnloadMagazine, src.gunsounds.soundUnloadMagazineVolume)
		boutput(user, "You unload \the [W] from \the [src]!")
		if (put_it_here)
			boutput(user, "You put [W] on \the [put_it_here].")
		else if (user.r_hand != W && user.l_hand != W)
			boutput(user, "Your hands were full, so [W] fell on the ground. Whoops.")
		return TRUE

/obj/item/gun/proc/swap(var/obj/item/ammo/A, var/mob/user)
	var/list/allowed_kinds = list(AMMO_MAGAZINE, AMMO_ENERGY, AMMO_BELTMAG)
	if(!(A.mag_type in allowed_kinds))
		boutput(user, "Wrong kind of thing to put into this thing!")
		return FALSE

	A.set_loc(src)
	src.handle_casings(eject_stored = TRUE, user = user)
	if(ismob(user))
		user.u_equip(A)
	if(src.loaded_magazine.is_null_mag)
		qdel(src.loaded_magazine)
	else
		var/obj/item/ammo/old_mag = src.loaded_magazine
		old_mag.loaded_in = null
		old_mag.update_bullet_manifest()
		old_mag.update_icon()
		playsound(user, src.gunsounds.soundUnloadMagazine, src.gunsounds.soundUnloadMagazineVolume)
		if(ismob(user))
			user.put_in_hand_or_drop(old_mag)
		else
			old_mag.set_loc(get_turf(user))
	src.loaded_magazine = A
	src.loaded_magazine.loaded_in = src
	src.loaded_magazine.update_bullet_manifest()
	src.loaded_magazine.update_icon()
	SPAWN_DBG(0.5 SECONDS)
		playsound(user, src.gunsounds.soundLoadMagazine, src.gunsounds.soundLoadMagazineVolume)
	src.update_icon()
	return TRUE

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
		ownerGun.shoot_manager(target_turf, user_turf, owner, pox, poy)

/obj/item/gun/pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
	if (reach)
		return FALSE
	if (!isturf(user.loc))
		return FALSE
	if(continuous && !continuousFire)
		return FALSE

	var/pox = text2num(params["icon-x"]) - 16
	var/poy = text2num(params["icon-y"]) - 16
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	if(charge_up && !can_dual_wield && canshoot())
		actions.start(new/datum/action/bar/icon/guncharge(src, pox, poy, user_turf, target_turf, charge_up, icon, icon_state), user)
	else
		shoot_manager(target_turf, user_turf, user, pox, poy)

	//if they're holding a gun in each hand... why not shoot both!
	if (can_dual_wield && (!charge_up))
		if(ishuman(user))
			if(user.hand && istype(user.r_hand, /obj/item/gun) && user.r_hand:can_dual_wield)
				if (user.r_hand:canshoot())
					user.next_click = max(user.next_click, world.time + user.r_hand:shoot_delay)
				SPAWN_DBG(0.2 SECONDS)
					user.r_hand:shoot_manager(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2))
			else if(!user.hand && istype(user.l_hand, /obj/item/gun)&& user.l_hand:can_dual_wield)
				if (user.l_hand:canshoot())
					user.next_click = max(user.next_click, world.time + user.l_hand:shoot_delay)
				SPAWN_DBG(0.2 SECONDS)
					user.l_hand:shoot_manager(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2))
		else if(ismobcritter(user))
			var/mob/living/critter/M = user
			var/list/obj/item/gun/guns = list()
			for(var/datum/handHolder/H in M.hands)
				if(H.item && H.item != src && istype(H.item, /obj/item/gun) && H.item:can_dual_wield)
					if (H.item:canshoot())
						guns += H.item
						user.next_click = max(user.next_click, world.time + H.item:shoot_delay)
			SPAWN_DBG(0)
				for(var/obj/item/gun/gun in guns)
					sleep(0.2 SECONDS)
					gun.shoot_manager(target_turf,user_turf,user, pox+rand(-2,2), poy+rand(-2,2))
	return TRUE

// Gun can't fire
/obj/item/gun/proc/dry_fire(var/mob/user, var/mob/M, var/point_blank)
	if (!silenced)
		if(point_blank)
			user.visible_message("<span class='alert'><B>[user] tries to shoot [user == M ? "[him_or_her(user)]self" : M] with [src] point-blank, but it was empty!</B></span>")
		playsound(user, src.shootsounds?.soundShootEmpty, src.shootsounds?.soundShootEmptyVolume)
	else
		user.show_text("*click* *click*", "red")


/obj/item/gun/attack(mob/M as mob, mob/user as mob)
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
			src.shoot_manager(M, user, user)
	else
		..()
		attack_particle(user,M)

#ifdef DATALOGGER
		game_stats.Increment("violence")
#endif
		return

/// Handles bursts, fire-rate, updating loaded magazine, etc
/obj/item/gun/proc/shoot_manager(var/target,var/start,var/mob/user,var/POX,var/POY,var/second_shot = 0)
	if(src.shooting) return
	if (isghostdrone(user))
		user?.show_text("<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [src]!</span>")
		return FALSE
	var/canshoot = src.canshoot()
	if (!canshoot)
		src.dry_fire(user)
		return
	else if (canshoot == GUN_IS_SHOOTING)
		return
	else if(canshoot == TRUE && ismob(user))
		user?.next_click = max(user.next_click, world.time + src.shoot_delay)
	SPAWN_DBG(0)
		src.shooting = 1
		for(var/burst in 1 to src.burst_count)
			if (!process_ammo(user)) // handles magazine stuff, sets current projectile if needed
				break
			var/shoot_result = shoot(target, start, user, POX, POY)
			if(shoot_result == FALSE)
				break
			sleep(src.refire_delay)
		src.shooting = 0

/obj/item/gun/proc/shoot(var/target,var/start,var/mob/user,var/POX,var/POY,var/second_shot = 0)
	if (get_dist(user,target)<=1 && ismob(target))
		src.shoot_point_blank(M = target, user = user, second_shot = second_shot)
		return

	if(!isturf(target))
		target = get_turf(target)
	if(!isturf(start))
		start = get_turf(start)
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
			SPAWN_DBG(-1)
				M.movement_delay_modifier += slowdown
				sleep(slowdown_time)
				M.movement_delay_modifier -= slowdown

	var/spread = 0
	if (user.reagents)
		var/how_drunk = 0
		var/amt = user.reagents.get_reagent_amount("ethanol")
		switch(amt)
			if (110 to INFINITY)
				how_drunk = 2
			if (1 to 110)
				how_drunk = 1
		how_drunk = max(0, how_drunk - isalcoholresistant(user) ? 1 : 0)
		spread += 5 * how_drunk
	spread = max(spread, spread_angle)
	handle_casings(user = user)
	if(silenced)
		playsound(user, src.shootsounds?.soundShootSilent, src.shootsounds?.soundShootSilentVolume, 1)
	else
		playsound(user, src.shootsounds?.soundShoot, src.shootsounds?.soundShootVolume, 1)
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
		logTheThing("combat", user, null, "fires \a [src] from [log_loc(user)], vector: ([T.x - user.x], [T.y - user.y]), dir: <I>[dir2text(get_dir(user, target))]</I>, projectile: <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", [P.proj_data.type]" : null]")

	if (ismob(user))
		var/mob/M = user
		if (ishuman(M) && src.add_residue) // Additional forensic evidence for kinetic firearms (Convair880).
			var/mob/living/carbon/human/H = user
			H.gunshot_residue = 1
	src.update_icon()

// Checks if the gun is able to shoot
/obj/item/gun/proc/canshoot()
	if(src.loaded_magazine)
		return 1
	return 0

/obj/item/gun/proc/shoot_point_blank(var/mob/M as mob, var/mob/user as mob, var/second_shot = 0)
	if (!ismob(M) || !user)
		return FALSE

	if (!istype(src.current_projectile,/datum/projectile/))
		return FALSE

	//Ok. i know it's kind of dumb to add this param 'second_shot' to the shoot_point_blank proc just to make sure pointblanks don't repeat forever when we could just move these checks somewhere else.
	//but if we do the double-gun checks here, it makes stuff like double-hold-at-gunpoint-pointblanks easier!
	if (can_dual_wield && !second_shot)
		//brutal double-pointblank shots
		if (ishuman(user))
			if(user.hand && istype(user.r_hand, /obj/item/gun) && user.r_hand:can_dual_wield)
				var/target_turf = get_turf(M)
				SPAWN_DBG(0.2 SECONDS)
					if (get_dist(user,M)<=1)
						user.r_hand:shoot_point_blank(M,user,second_shot = 1)
					else
						user.r_hand:shoot(target_turf,get_turf(user), user, rand(-5,5), rand(-5,5))
			else if(!user.hand && istype(user.l_hand, /obj/item/gun) && user.l_hand:can_dual_wield)
				var/target_turf = get_turf(M)
				SPAWN_DBG(0.2 SECONDS)
					if (get_dist(user,M)<=1)
						user.l_hand:shoot_point_blank(M,user,second_shot = 11)
					else
						user.l_hand:shoot(target_turf,get_turf(user), user, rand(-5,5), rand(-5,5))

	if (ishuman(user) && src.add_residue) // Additional forensic evidence for kinetic firearms (Convair880).
		var/mob/living/carbon/human/H = user
		H.gunshot_residue = 1

	if (!src.silenced)
		for (var/mob/O in AIviewers(M, null))
			if (O.client)
				O.show_message("<span class='alert'><B>[user] shoots [user == M ? "[him_or_her(user)]self" : M] point-blank with [src]!</B></span>")
	else
		boutput(user, "<span class='alert'>You silently shoot [user == M ? "yourself" : M] point-blank with [src]!</span>") // Was non-functional (Convair880).

	if (src.muzzle_flash)
		if (isturf(user.loc))
			muzzle_flash_attack_particle(user, user.loc, M, src.muzzle_flash)


	if(slowdown && ismob(user))
		SPAWN_DBG(-1)
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
		how_drunk = max(0, how_drunk - isalcoholresistant(user) ? 1 : 0)
		spread += 5 * how_drunk
	spread = max(spread, spread_angle)

	var/obj/projectile/P = initialize_projectile_pixel_spread(user, current_projectile, M, 0, 0, spread, alter_proj = new/datum/callback(src, .proc/alter_projectile))
	if (!P)
		return
	if (user == M)
		P.shooter = null
		P.mob_shooter = user

	P.forensic_ID = src.forensic_ID // Was missing (Convair880).
	if(get_dist(user,M) <= 1)
		hit_with_existing_projectile(P, M) // Includes log entry.
		P.was_pointblank = 1
	else
		P.launch()
	if(silenced)
		playsound(user, src.shootsounds?.soundShootSilent, src.shootsounds?.soundShootSilentVolume, 1)
	else
		playsound(user, src.shootsounds?.soundShoot, src.shootsounds?.soundShootVolume, 1)
	handle_casings(user = user)

	var/mob/living/L = M
	if (M && isalive(M))
		L.lastgasp()
	M.set_clothing_icon_dirty()
	src.update_icon()
	sleep(current_projectile.shot_delay)

/obj/item/gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	src.add_fingerprint(user)
	src.update_icon()
	if(continuous) return
	if (flag)
		return

/obj/item/gun/proc/alter_projectile(var/obj/projectile/P)
	return

/obj/item/gun/proc/handle_casings(var/eject_stored = 0, var/atom/user)

	if (src.casings_to_eject.len > 30 || src.current_projectile?.shot_number > 30)
		logTheThing("debug", usr, null, "<b>Convair880</b>: [usr]'s gun ([src]) ran into the casings_to_eject cap. Capping casings to cap.")
	src.casings_to_eject.len = clamp(src.casings_to_eject.len, 0, 30)
	if(eject_stored)
		if(src.casings_to_eject.len < 1) // Nothing to eject? Job well done!
			src.casings_to_eject.len = 0
			boutput(user, "<span class='alert'>You don't find any casings to eject. Huh.</span>")
			return
		// If it accepts a clip at all, unload all of them. Like a revolver
		// If not, eject one casing. Like a revolver, the kind that takes one bullet at a time
		if ((AMMO_CLIP) in src.accepted_mag)
			boutput(user, "<span class='notice'>You eject [src.casings_to_eject.len > 1 ? "[src.casings_to_eject.len] casings" : "a casing"] from [src].</span>")
			var/turf/T = get_turf(src)
			if(T)
				var/obj/item/casing/C = null
				while (src.casings_to_eject.len >= 1)
					C = new src.current_projectile.casing(T)
					C.forensic_ID = src.forensic_ID
					C.set_loc(T)
					src.casings_to_eject -= src.casings_to_eject[1]
			return
		else
			boutput(user, "<span class='notice'>You eject a casing from [src].</span>")
			var/turf/T = get_turf(src)
			if(T)
				var/obj/item/casing/C = null
				C = new src.current_projectile.casing(T)
				C.forensic_ID = src.forensic_ID
				C.set_loc(T)
				src.casings_to_eject -= src.casings_to_eject[1]
			return
	else // Trying to eject null casings makes runtimes. Looking at you, artguns!
		if (!istype(src.current_projectile, /datum/projectile) || !src.current_projectile.casing)
			return

		if (src.auto_eject)
			var/turf/T = get_turf(src)
			if(T)
				if (src?.current_projectile?.casing)
					var/number_of_casings = max(1, src.current_projectile?.shot_number)
					//DEBUG_MESSAGE("Ejected [number_of_casings] casings from [src].")
					for (var/i in 1 to number_of_casings)
						var/obj/item/casing/C = new src.current_projectile.casing(T)
						C.forensic_ID = src.forensic_ID
						C.set_loc(T)
		else
			if (src.casings_to_eject.len < 0)
				src.casings_to_eject.len = 0
			src.casings_to_eject += new src.current_projectile.casing(src)

/obj/item/gun/examine()
	if (src.artifact)
		return list("You have no idea what the hell this thing is!")
	return ..()

/obj/item/gun/proc/update_icon()
	if (src.loaded_magazine)
		inventory_counter?.update_number(src.loaded_magazine.mag_contents.len)
	else
		inventory_counter?.update_text("-")

	if(src.has_empty_state)
		if (src.loaded_magazine.mag_contents.len < 1 && !findtext(src.icon_state, "-empty")) //sanity check
			src.icon_state = "[src.icon_state]-empty"
		else
			src.icon_state = replacetext(src.icon_state, "-empty", "")
	return FALSE

/// Checks if it can shoot, loads the projectile into the chamber (src.current_projectile), then deducts it from the ammothing
/// Same thing for energy weapons, but it only checks if it has enough energy, then eats the energy
/obj/item/gun/proc/process_ammo(var/mob/user)
	if(src.loaded_magazine.mag_type == AMMO_ENERGY) // Has a battery
		if(!src.current_projectile?.name) // Firemode didnt set a projectile on an energy weapon? Lets fix that!
			var/datum/firemode/F = src.firemodes[src.firemode_index]
			if(istype(F.projectile, /datum/projectile)) // Does the firemode have a projectile associated?
				src.current_projectile = F.projectile
			else // No?
				src.dry_fire(user) // rip
				return FALSE
		if (src.loaded_magazine.charge >= src.current_projectile.cost)
			src.loaded_magazine.charge -= src.current_projectile.cost
			return TRUE
	else // uses bullets
		if(src.loaded_magazine.mag_contents.len >= 1 && istype(src.loaded_magazine.mag_contents[1], /datum/projectile))
			src.current_projectile = src.loaded_magazine.mag_contents[1]
			if(length(src.loaded_magazine.projectile_items))
				if(istype(src.current_projectile, /datum/projectile/bullet/grenade_shell))
					var/datum/projectile/bullet/grenade_shell/GS = src.current_projectile
					var/obj/item/GCG
					if(istype(GS.internal_grenade))
						GCG = GS.internal_grenade
					else if(istype(GS.internal_chem_grenade))
						GCG = GS.internal_chem_grenade
					if(istype(GCG))
						for(var/datum/projectile/L_P in src.loaded_magazine.projectile_items)
							if(GS != L_P)
								continue
							else
								src.loaded_magazine.projectile_items -= L_P
								break
			src.loaded_magazine.mag_contents.Cut(1,2)
			return TRUE
	src.dry_fire(user)
	return FALSE

// Could be useful in certain situations (Convair880).
/obj/item/gun/proc/logme_temp(mob/user as mob, obj/item/gun/G as obj, obj/item/ammo/A as obj)
	if (!user || !G || !A)
		return

	else if (istype(G, /obj/item/gun/kinetic) && istype(A, /obj/item/ammo/bullets))
		logTheThing("combat", user, null, "reloads [G] (<b>Ammo type:</b> <i>[G.current_projectile.type]</i>) at [log_loc(user)].")
		return

	else if (istype(G, /obj/item/gun/energy) && istype(A, /obj/item/ammo/power_cell))
		logTheThing("combat", user, null, "reloads [G] (<b>Cell type:</b> <i>[A.type]</i>) at [log_loc(user)].")
		return

	else return

/obj/item/gun/custom_suicide = 1
/obj/item/gun/suicide(var/mob/living/carbon/human/user as mob)
	if (!src.user_can_suicide(user))
		return FALSE
	if (!src.canshoot())
		return FALSE

	if(!src.process_ammo(user)) return FALSE
	user.visible_message("<span class='alert'><b>[user] places [src] against [his_or_her(user)] head!</b></span>")
	var/dmg = user.get_brute_damage() + user.get_burn_damage()
	src.shoot_manager(user, user)
	var/new_dmg = user.get_brute_damage() + user.get_burn_damage()
	if (new_dmg >= (dmg + 20)) // it did some appreciable amount of damage
		user.TakeDamage("head", 500, 0)
	else if (new_dmg < (dmg + 20))
		user.visible_message("<span class='alert'>[user] hangs their head in shame because they chose such a weak gun.</span>")
	return TRUE

/obj/item/gun/on_spin_emote(var/mob/living/carbon/human/user as mob)
	. = ..(user)
	if ((user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50)) || (user.reagents && prob(user.reagents.get_reagent_amount("ethanol") / 2)) || prob(5))
		user.visible_message("<span class='alert'><b>[user] accidentally shoots [him_or_her(user)]self with [src]!</b></span>")
		src.shoot_manager(user, user)
		JOB_XP(user, "Clown", 3)

/obj/item/gun/proc/charge(var/amt)
	if(src.loaded_magazine && rechargeable)
		return src.loaded_magazine.charge(amt)
	else
		//No cell, or not rechargeable. Tell anything trying to charge it.
		return -1

/obj/item/gun/emp_act()
	if (src.loaded_magazine && istype(src.loaded_magazine))
		src.loaded_magazine.charge = 0
		src.update_icon()
	return

/obj/item/gun/process()
	src.wait_cycle = !src.wait_cycle // Self-charging cells recharge every other tick (Convair880).
	if (src.wait_cycle)
		return

	if (!(src in processing_items))
		logTheThing("debug", null, null, "<b>Convair880</b>: Process() was called for an egun ([src]) that wasn't in the item loop. Last touched by: [src.fingerprintslast]")
		processing_items.Add(src)
		return
	if (!src?.loaded_magazine?.self_charging)
		processing_items.Remove(src)
		return
	if (src.loaded_magazine.charge == src.loaded_magazine.max_charge) // Keep them in the loop, as we might fire the gun later (Convair880).
		return

	src.update_icon()
	return

///setter for current_projectile so we can have a signal attached. do not set current_projectile on guns without this proc
/obj/item/gun/proc/set_current_projectile(datum/projectile/newProj)
	src.current_projectile = newProj
	SEND_SIGNAL(src, COMSIG_GUN_PROJECTILE_CHANGED, newProj)
