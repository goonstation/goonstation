TYPEINFO(/datum/component/holdertargeting/smartgun)
	initialization_args = list(
		ARG_INFO("maxlocks", DATA_INPUT_NUM, "Maximum number of lock-ons the gun will get on a given target at once", 3)
	)

/datum/component/holdertargeting/smartgun
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	mobtype = /mob/living
	var/maxlocks
	var/list/atom/movable/screen/fullautoAimHUD/hudSquares = list()
	var/atom/movable/screen/fullautoAimHUD/hudCenter
	var/client/aimer
	var/turf/mouse_target
	var/stopping
	var/shooting
	var/type_to_target = /mob/living
	var/tracking
	var/list/tracked_targets
	var/list/image/targeting_images
	var/shotcount = 0
	var/scoped = FALSE
	var/target_pox = 0
	var/target_poy = 0

	InheritComponent(datum/component/holdertargeting/smartgun/C, i_am_original, _maxlocks)
		if(C)
			src.maxlocks = C.maxlocks
		else
			src.maxlocks = _maxlocks

	Initialize(_maxlocks = 3)
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			var/obj/item/G = parent
			src.maxlocks = _maxlocks
			tracked_targets = list()
			targeting_images = list()

			var/atom/movable/screen/fullautoAimHUD/hudSquare

			hudSquare = new /atom/movable/screen/fullautoAimHUD
			hudSquare.screen_loc = "SOUTHWEST to CENTER-2,NORTH"
			hudSquares += hudSquare
			hudSquare = new /atom/movable/screen/fullautoAimHUD
			hudSquare.screen_loc = "CENTER+2,SOUTH to NORTHEAST"
			hudSquares += hudSquare
			hudSquare = new /atom/movable/screen/fullautoAimHUD
			hudSquare.screen_loc = "CENTER-1,CENTER+2 to CENTER+1,NORTH"
			hudSquares += hudSquare
			hudSquare = new /atom/movable/screen/fullautoAimHUD
			hudSquare.screen_loc = "CENTER-1,SOUTH to CENTER+1,CENTER-2"
			hudSquares += hudSquare

			hudSquare = new /atom/movable/screen/fullautoAimHUD
			hudSquare.screen_loc = "CENTER-1,CENTER-1 to CENTER+1,CENTER+1"
			hudSquares += hudSquare
			hudCenter = hudSquare

			RegisterSignal(G, COMSIG_ITEM_SWAP_TO, PROC_REF(init_smart_aim))
			RegisterSignal(G, COMSIG_ITEM_SWAP_AWAY, PROC_REF(end_smart_aim))
			RegisterSignal(G, COMSIG_SCOPE_TOGGLED, PROC_REF(scope_toggled))
			if(ismob(G.loc))
				on_pickup(null, G.loc)

	UnregisterFromParent()
		UnregisterSignal(parent, list(COMSIG_ITEM_SWAP_TO, COMSIG_ITEM_SWAP_AWAY, COMSIG_SCOPE_TOGGLED))
		if(aimer)
			for(var/hudSquare in hudSquares)
				aimer?.screen -= hudSquare
			aimer = null
		if(current_user)
			src.end_smart_aim(src, current_user)
		. = ..()

	disposing()
		for(var/hudSquare in hudSquares)
			qdel(hudSquare)
		tracked_targets = null
		targeting_images = null
		hudSquares = null
		. = ..()

	on_pickup(datum/source, mob/user)
		. = ..()
		if(user.equipped() == parent)
			src.init_smart_aim(source, user)

	on_dropped(datum/source, mob/user)
		. = ..()
		src.end_smart_aim(source, user)

/datum/component/holdertargeting/smartgun/proc/scope_toggled(datum/source, scope_active)
	var/old_scoped = src.scoped
	src.scoped = scope_active
	if(!aimer)
		return
	if(!old_scoped && src.scoped) //add aiming squares to center of screen
		aimer.screen += hudCenter
		return
	if(old_scoped && !src.scoped) //remove aiming squares from center of screen
		src.target_pox = 0
		src.target_poy = 0
		aimer.screen -= hudCenter
		return

/datum/component/holdertargeting/smartgun/proc/init_smart_aim(datum/source, mob/user)
	RegisterSignal(user, COMSIG_FULLAUTO_MOUSEMOVE, PROC_REF(retarget))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(moveRetarget))
	RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN, PROC_REF(shoot_tracked_targets))
	RegisterSignal(user, COMSIG_MOB_SCOPE_MOVED, PROC_REF(scope_moved))
	if(user.client)
		aimer = user.client
		for(var/atom/hudSquare in hudSquares)
			hudSquare.mouse_over_pointer = icon(cursors_selection[aimer.preferences.target_cursor], "all")
			aimer.screen += hudSquare
		aimer.screen -= hudCenter
	track_targets(user)

/datum/component/holdertargeting/smartgun/proc/end_smart_aim(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEMOVE)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN)
	UnregisterSignal(user, COMSIG_MOB_SCOPE_MOVED)

	src.stop_tracking_targets(user)
	if(aimer)
		for(var/atom/hudSquare in hudSquares)
			aimer.screen -= hudSquare
	aimer = null

/datum/component/holdertargeting/smartgun/proc/moveRetarget(mob/M, newLoc, direct)
	if(src.mouse_target)
		src.mouse_target = get_step(src.mouse_target, direct)

/datum/component/holdertargeting/smartgun/proc/retarget(mob/M, object, location, control, params)
	var/turf/T
	var/atom/movable/screen/fullautoAimHUD/F = object

	var/regex/locparser = new(@"^(\d+):(\d*),(\d+):(\d*)$")
	if(!locparser.Find(params2list(params)["screen-loc"]))
		return //FUCK
	var/x = text2num(locparser.group[1])
	var/pox = text2num(locparser.group[2])
	var/y = text2num(locparser.group[3])
	var/poy = text2num(locparser.group[4])

	if(istype(F) && aimer)
		T = get_turf(aimer.virtual_eye)
		T = locate(T.x + (aimer.pixel_x / 32) + (x + -1 - ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2),\
							T.y + (aimer.pixel_y / 32) + (y + -1 - 7),\
							M.z)

		if(T && T != get_turf(parent))
			src.mouse_target = T

		if(params)
			src.target_pox = pox - 16
			src.target_poy = poy - 16
			if(src.scoped)
				if(aimer.pixel_x)
					src.target_pox += aimer.pixel_x % 32
					if(aimer.pixel_x < 0)
						src.target_pox += 32
				if(aimer.pixel_y)
					src.target_poy += aimer.pixel_y % 32
					if(aimer.pixel_y < 0)
						src.target_poy += 32

/datum/component/holdertargeting/smartgun/proc/scope_moved(mob/M, delta_x, delta_y)
	src.target_pox += delta_x
	src.target_poy += delta_y

/datum/component/holdertargeting/smartgun/proc/track_targets(mob/user)
	set waitfor = 0
	if(shooting || tracking)
		return
	tracking = 1
	shotcount = 0
	while(!stopping)
		if(!shooting)
			if(src.mouse_target)
				var/turf/T = locate(src.mouse_target.x + round(src.target_pox / 32 + 0.5),\
					src.mouse_target.y + round(src.target_poy / 32 + 0.5),\
					src.mouse_target.z)
				if(T)
					for(var/atom/A in range(2, T))
						ON_COOLDOWN(A, "smartgun_last_tracked_\ref[src]", 1.5 SECONDS)
						if(tracked_targets[A] < src.maxlocks && src.is_valid_target(user, A) && shotcount < src.checkshots(parent, user))
							tracked_targets[A] += 1
							shotcount++
							src.update_targeting_images(A)
			for(var/atom/A as anything in tracked_targets)
				if(!GET_COOLDOWN(A, "smartgun_last_tracked_\ref[src]"))
					tracked_targets[A]--
					shotcount--
					src.update_targeting_images(A)
					if(tracked_targets[A] <= 0)
						tracked_targets -= A

		sleep(0.6 SECONDS)

	stopping = 0
	tracking = 0

/datum/component/holdertargeting/smartgun/proc/update_targeting_images(atom/A)
	if(!src.aimer)
		return
	if(tracked_targets[A] > 0)
		if(!targeting_images[A])
			targeting_images[A] = image(icon('icons/cursors/target/flat.dmi', "all"), A, pixel_y = 32)
			aimer.images += targeting_images[A]
			targeting_images[A].maptext_y = 3
		targeting_images[A].maptext = "<span class='pixel c ol'>[tracked_targets[A]]</span>"
	else
		aimer.images -= targeting_images[A]
		targeting_images -= A

/image/targeting_image

/datum/component/holdertargeting/smartgun/proc/shoot_tracked_targets(mob/user)
	if(shooting)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if ((aimer.check_key(KEY_THROW)) || H.in_throw_mode)
			H.throw_item(src.mouse_target)
			return
	else if(iscritter(user))
		var/mob/living/critter/C = user
		if (((aimer.check_key(KEY_THROW)) || C.in_throw_mode) && C.can_throw)
			C.throw_item(src.mouse_target)
			return
	var/obj/item/gun/G = parent
	var/list/local_targets = tracked_targets.Copy()
	shooting = 1
	spawn(0)
		if(length(local_targets))
			G.suppress_fire_msg = 1
			for(var/atom/A as anything in local_targets)
				for(var/i in 1 to local_targets[A])
					G.Shoot(get_turf(A), get_turf(user), user, called_target = A)
					sleep(1 DECI SECOND)

			G.suppress_fire_msg = initial(G.suppress_fire_msg)
		else
			if(!ON_COOLDOWN(G, "shoot_delay", G.shoot_delay))
				G.Shoot(src.mouse_target ? src.mouse_target : get_step(user, NORTH), get_turf(user), user, src.target_pox, src.target_poy, called_target = mouse_target)
		shooting = 0

	tracked_targets = list()
	shotcount = 0
	if(aimer)
		for(var/atom/A as anything in targeting_images)
			aimer.images -= targeting_images[A]
			targeting_images -= A

/datum/component/holdertargeting/smartgun/proc/stop_tracking_targets(mob/user)
	if(tracking)
		stopping = 1
	tracked_targets = list()
	mouse_target = null
	if(aimer)
		for(var/atom/A as anything in targeting_images)
			aimer.images -= targeting_images[A]
			targeting_images -= A

/datum/component/holdertargeting/smartgun/proc/is_valid_target(mob/user, mob/M)
	return (istype(M) && M != user && !isdead(M))

/datum/component/holdertargeting/smartgun/proc/checkshots(obj/item/gun/G, mob/user)
	var/list/ret = list()
	if(istype(G, /obj/item/gun/kinetic))
		var/obj/item/gun/kinetic/K = G
		return round(K.ammo.amount_left * K.current_projectile.cost)
	else if(SEND_SIGNAL(G, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
		return round(ret["charge"] / G.current_projectile.cost)
	else return G.canshoot(user) * INFINITY //idk, just let it happen
