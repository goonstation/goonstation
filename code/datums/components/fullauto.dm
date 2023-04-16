/atom/movable/screen/fullautoAimHUD
	name = ""
	desc = ""
	layer = HUD_LAYER - 1
	flags = NOSPLASH
	alpha = 0
	mouse_opacity = 2
	var/xOffset
	var/yOffset

	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		SEND_SIGNAL(usr, COMSIG_FULLAUTO_MOUSEDRAG, over_object, over_location, over_control, params)

	MouseDown(location, control, params)
		. = ..()
		SEND_SIGNAL(usr, COMSIG_FULLAUTO_MOUSEDOWN, src, location, control, params)

	MouseMove(location, control, params)
		. = ..()
		SEND_SIGNAL(usr, COMSIG_FULLAUTO_MOUSEMOVE, src, location, control, params)

TYPEINFO(/datum/component/holdertargeting/fullauto)
	initialization_args = list(
		ARG_INFO("delaystart", DATA_INPUT_NUM, "Initial delay between shots (in deciseconds)", 1.5),
		ARG_INFO("delaymin", DATA_INPUT_NUM, "Minimum delay between shots (in deciseconds)", 1.5),
		ARG_INFO("rampfactor", DATA_INPUT_NUM, "Multiplicitive decrease in delay after each shot, (0, 1]", 1),
	)

/datum/component/holdertargeting/fullauto
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	mobtype = /mob/living
	var/turf/target
	var/stopping = 0
	var/shooting
	var/delaystart
	var/delaymin
	var/rampfactor
	/// If 0, don't fullauto. Otherwise, fullauto is true
	var/toggle = 0
	var/list/atom/movable/screen/fullautoAimHUD/hudSquares = list()
	var/client/aimer

	InheritComponent(datum/component/holdertargeting/fullauto/C, i_am_original, _delaystart, _delaymin, _rampfactor)
		if(C)
			src.delaystart = C.delaystart
			src.delaymin = C.delaymin
			src.rampfactor = C.rampfactor
		else
			if (isnum_safe(_delaystart))
				src.delaystart = _delaystart
			if (isnum_safe(_delaymin))
				src.delaymin = _delaymin
			if (isnum_safe(_rampfactor))
				src.rampfactor = _rampfactor


	Initialize(delaystart = 1.5 DECI SECONDS, delaymin = 1.5 DECI SECONDS, rampfactor = 1)
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			src.toggle = toggle
			var/obj/item/gun/G = parent
			src.delaystart = delaystart
			src.delaymin = delaymin
			src.rampfactor = rampfactor
			for(var/x in 1 to WIDE_TILE_WIDTH)
				for(var/y in 1 to 15)
					var/atom/movable/screen/fullautoAimHUD/hudSquare = new /atom/movable/screen/fullautoAimHUD
					hudSquare.screen_loc = "[x],[y]"
					hudSquare.xOffset = x
					hudSquare.yOffset = y
					hudSquares["[x],[y]"] = hudSquare

			RegisterSignal(G, COMSIG_GUN_PROJECTILE_CHANGED, .proc/toggle_fullauto_firemode)

			if(src.toggle)
				RegisterSignal(G, COMSIG_ITEM_SWAP_TO, .proc/init_fullauto_mode)
				RegisterSignal(G, COMSIG_ITEM_SWAP_AWAY, .proc/end_fullauto_mode)
				if(ismob(G.loc))
					on_pickup(null, G.loc)

	UnregisterFromParent()
		for(var/hudSquare in hudSquares)
			aimer?.screen -= hudSquares[hudSquare]
		aimer = null
		if(current_user)
			end_shootloop(current_user)
		. = ..()

	disposing()
		for(var/hudSquare in hudSquares)
			qdel(hudSquares[hudSquare])
		hudSquares = null
		. = ..()


	on_pickup(datum/source, mob/user)
		var/obj/item/gun/G = parent
		. = ..()
		if(G?.current_projectile?.fullauto_valid)
			if(toggle)
				if(user.equipped() == parent)
					init_fullauto_mode(source, user)
			else
				if(user.equipped() == parent)
					toggle_fullauto_firemode(source, G.current_projectile)


	on_dropped(datum/source, mob/user)
		end_fullauto_mode(source, user)
		. = ..()

/datum/component/holdertargeting/fullauto/proc/toggle_fullauto_firemode(datum/source, datum/projectile/newProj)
	var/obj/item/gun/G = parent
	if(current_user && newProj.fullauto_valid != toggle)
		toggle = !toggle

		if(toggle)
			RegisterSignal(G, COMSIG_ITEM_SWAP_TO, .proc/init_fullauto_mode)
			RegisterSignal(G, COMSIG_ITEM_SWAP_AWAY, .proc/end_fullauto_mode)
			if(current_user.equipped() == G)
				init_fullauto_mode(source, current_user)
		else
			UnregisterSignal(G, COMSIG_ITEM_SWAP_TO)
			UnregisterSignal(G, COMSIG_ITEM_SWAP_AWAY)
			if(current_user.equipped() == G)
				end_fullauto_mode(source, current_user)

/datum/component/holdertargeting/fullauto/proc/init_fullauto_mode(datum/source, mob/user)
	RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN, .proc/begin_shootloop)
	if(user.client)
		aimer = user.client
		for(var/x in 1 to (istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				var/atom/movable/screen/fullautoAimHUD/FH = hudSquares["[x],[y]"]
				FH.mouse_over_pointer = icon(cursors_selection[aimer.preferences.target_cursor], "all")
				if((y >= 7 && y <= 9) && (x >= ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 - 1 && x <= ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 + 1))
					continue
				aimer.screen += hudSquares["[x],[y]"]



/datum/component/holdertargeting/fullauto/proc/end_fullauto_mode(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN)
	end_shootloop(user)
	if(aimer)
		for(var/x in 1 to (istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				aimer.screen -= hudSquares["[x],[y]"]
	aimer = null



/datum/component/holdertargeting/fullauto/proc/begin_shootloop(mob/living/user, object, location, control, params)
	if(!stopping && !shooting)
		src.retarget(user, object, location, control, params)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if ((aimer.check_key(KEY_THROW)) || H.in_throw_mode)
				H.throw_item(target,params)
				return
		else if(iscritter(user))
			var/mob/living/critter/C = user
			if (((aimer.check_key(KEY_THROW)) || C.in_throw_mode) && C.can_throw)
				C.throw_item(target,params)
				return
		RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG, .proc/retarget)
		RegisterSignal(user, COMSIG_MOB_MOUSEUP, .proc/end_shootloop)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/moveRetarget)
		for(var/x in ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 - 1 to ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 + 1)
			for(var/y in 7 to 9)
				aimer.screen += hudSquares["[x],[y]"]

		src.shootloop(user)

/datum/component/holdertargeting/fullauto/proc/moveRetarget(mob/M, newLoc, direct)
	if(src.target)
		src.target = get_step(src.target, direct)

/datum/component/holdertargeting/fullauto/proc/retarget(mob/M, object, location, control, params)

	var/turf/T
	var/atom/movable/screen/fullautoAimHUD/F = object
	if(istype(F) && aimer)
		T = locate(M.x + (F.xOffset + -1 - ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2),\
							M.y + (F.yOffset + -1 - 7),\
							M.z)

		if(T && T != get_turf(parent))
			src.target = T

/datum/component/holdertargeting/fullauto/proc/shootloop(mob/living/L)
	set waitfor = 0
	if(shooting)
		return

	var/obj/item/gun/G = parent
	var/delay = delaystart
	shooting = 1

	while(!stopping)
		if(G.canshoot(L))
			G.shoot(target ? target : get_step(L, NORTH), get_turf(L), L)
			G.suppress_fire_msg = 1
		else
			end_shootloop(L)
		sleep(max(delay*=rampfactor, delaymin))

	stopping = 0
	shooting = 0

/datum/component/holdertargeting/fullauto/proc/end_shootloop(mob/living/user)
	//loop ended - reset values
	var/obj/item/gun/G = parent
	G.suppress_fire_msg = initial(G.suppress_fire_msg)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG)
	UnregisterSignal(user, COMSIG_MOB_MOUSEUP)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	target = null
	if(aimer)
		for(var/x in ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 - 1 to ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 + 1)
			for(var/y in 7 to 9)
				aimer.screen -= hudSquares["[x],[y]"]
	if(shooting)
		stopping = 1
