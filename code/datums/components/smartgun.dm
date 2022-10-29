TYPEINFO(/datum/component/holdertargeting/smartgun)
	initialization_args = list(
		ARG_INFO("maxlocks", DATA_INPUT_NUM, "Maximum number of lock-ons the gun will get on a given target at once", 3)
	)

/datum/component/holdertargeting/smartgun
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	mobtype = /mob/living
	var/maxlocks
	var/list/atom/movable/screen/fullautoAimHUD/hudSquares = list()
	var/client/aimer
	var/turf/mouse_target
	var/stopping
	var/shooting
	var/tracking
	var/list/tracked_targets
	var/list/image/targeting_images
	var/shotcount = 0

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
			for(var/x in 1 to WIDE_TILE_WIDTH)
				for(var/y in 1 to 15)
					var/atom/movable/screen/fullautoAimHUD/hudSquare = new /atom/movable/screen/fullautoAimHUD
					hudSquare.screen_loc = "[x],[y]"
					hudSquare.xOffset = x
					hudSquare.yOffset = y
					hudSquares["[x],[y]"] = hudSquare
			RegisterSignal(G, COMSIG_ITEM_SWAP_TO, .proc/init_smart_aim)
			RegisterSignal(G, COMSIG_ITEM_SWAP_AWAY, .proc/end_smart_aim)
			if(ismob(G.loc))
				on_pickup(null, G.loc)

	UnregisterFromParent()
		if(aimer)
			for(var/hudSquare in hudSquares)
				aimer?.screen -= hudSquares[hudSquare]
			aimer = null
		if(current_user)
			src.end_smart_aim(src, current_user)
		. = ..()

	disposing()
		for(var/hudSquare in hudSquares)
			qdel(hudSquares[hudSquare])
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

/datum/component/holdertargeting/smartgun/proc/init_smart_aim(datum/source, mob/user)
	RegisterSignal(user, COMSIG_FULLAUTO_MOUSEMOVE, .proc/retarget)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/moveRetarget)
	RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN, .proc/shoot_tracked_targets)
	if(user.client)
		aimer = user.client
		for(var/x in 1 to (istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				var/atom/movable/screen/fullautoAimHUD/FH = hudSquares["[x],[y]"]
				FH.mouse_over_pointer = icon(cursors_selection[aimer.preferences.target_cursor], "all")
				if((y >= 7 && y <= 9) && (x >= ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 - 1 && x <= ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 + 1))
					continue
				aimer.screen += hudSquares["[x],[y]"]
	track_targets(user)

/datum/component/holdertargeting/smartgun/proc/end_smart_aim(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEMOVE)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN)

	src.stop_tracking_targets(user)
	if(aimer)
		for(var/x in 1 to (istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				aimer.screen -= hudSquares["[x],[y]"]
	aimer = null

/datum/component/holdertargeting/smartgun/proc/moveRetarget(mob/M, newLoc, direct)
	if(src.mouse_target)
		src.mouse_target = get_step(src.mouse_target, direct)

/datum/component/holdertargeting/smartgun/proc/retarget(mob/M, object, location, control, params)

	var/turf/T
	var/atom/movable/screen/fullautoAimHUD/F = object
	if(istype(F) && aimer)
		T = locate(M.x + (F.xOffset + -1 - ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2),\
							M.y + (F.yOffset + -1 - 7),\
							M.z)

		if(T && T != get_turf(parent))
			src.mouse_target = T

/datum/component/holdertargeting/smartgun/proc/track_targets(mob/user)
	set waitfor = 0
	if(shooting || tracking)
		return
	tracking = 1
	shotcount = 0
	while(!stopping)
		if(!shooting && checkshots(parent, user) > shotcount)
			for(var/mob/living/M in range(2, mouse_target))
				ON_COOLDOWN(M, "smartgun_last_tracked_\ref[src]", 1.5 SECONDS)
				if(tracked_targets[M] < src.maxlocks && src.is_valid_target(user, M) && shotcount < src.checkshots(parent, user))
					tracked_targets[M] += 1
					shotcount++
					src.update_targeting_images(M)
			for(var/mob/living/M in tracked_targets)
				if(!GET_COOLDOWN(M, "smartgun_last_tracked_\ref[src]"))
					tracked_targets[M]--
					shotcount--
					src.update_targeting_images(M)
					if(tracked_targets[M] <= 0)
						tracked_targets -= M

		sleep(0.6 SECONDS)

	stopping = 0
	tracking = 0

/datum/component/holdertargeting/smartgun/proc/update_targeting_images(mob/M)
	if(!src.aimer)
		return
	if(tracked_targets[M] > 0)
		if(!targeting_images[M])
			targeting_images[M] = image(icon('icons/cursors/target/flat.dmi', "all"), M, pixel_y = 32)
			aimer.images += targeting_images[M]
			targeting_images[M].maptext_y = 3
		targeting_images[M].maptext = "<span class='pixel c ol'>[tracked_targets[M]]</span>"
	else
		aimer.images -= targeting_images[M]
		targeting_images -= M

/image/targeting_image

/datum/component/holdertargeting/smartgun/proc/shoot_tracked_targets(mob/user)
	if(shooting)
		return
	shooting = 1
	var/obj/item/gun/G = parent
	var/list/local_targets = tracked_targets.Copy()
	spawn(0)
		if(length(local_targets))
			G.suppress_fire_msg = 1
			for(var/mob/living/M in local_targets)
				for(var/i in 1 to local_targets[M])
					G.shoot(get_turf(M), get_turf(user), user)
					sleep(1 DECI SECOND)

			G.suppress_fire_msg = initial(G.suppress_fire_msg)
		else
			if(!ON_COOLDOWN(G, "shoot_delay", G.shoot_delay))
				G.shoot(mouse_target, get_turf(user), user)
		shooting = 0

	tracked_targets = list()
	shotcount = 0
	if(aimer)
		for(var/mob/M in targeting_images)
			aimer.images -= targeting_images[M]
			targeting_images -= M

/datum/component/holdertargeting/smartgun/proc/stop_tracking_targets(mob/user)
	if(tracking)
		stopping = 1
	tracked_targets = list()
	mouse_target = null
	if(aimer)
		for(var/mob/M in targeting_images)
			aimer.images -= targeting_images[M]
			targeting_images -= M

/datum/component/holdertargeting/smartgun/proc/is_valid_target(mob/user, mob/M)
	return M != user && !isdead(M)

/datum/component/holdertargeting/smartgun/proc/checkshots(obj/item/gun/G, mob/user)
	var/list/ret = list()
	if(istype(G, /obj/item/gun/kinetic))
		var/obj/item/gun/kinetic/K = G
		return round(K.ammo.amount_left * K.current_projectile.cost)
	else if(SEND_SIGNAL(G, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
		return round(ret["charge"] / G.current_projectile.cost)
	else return G.canshoot(user) * INFINITY //idk, just let it happen
