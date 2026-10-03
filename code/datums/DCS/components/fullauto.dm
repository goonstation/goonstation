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
	)

/datum/component/holdertargeting/fullauto
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	mobtype = /mob/living
	var/turf/target
	var/stopping = 0
	var/shooting
	var/delaystart
	var/delay
	/// If 0, don't fullauto. Otherwise, fullauto is true
	var/toggle = 0
	var/list/atom/movable/screen/fullautoAimHUD/hudSquares = list()
	var/atom/movable/screen/fullautoAimHUD/hudCenter
	var/client/aimer
	var/scoped = FALSE
	var/target_pox = 0
	var/target_poy = 0

	InheritComponent(datum/component/holdertargeting/fullauto/C, i_am_original, _delaystart)
		if(C)
			src.delaystart = C.delaystart
		else
			if (isnum_safe(_delaystart))
				src.delaystart = _delaystart


	Initialize(delaystart = 1.5 DECI SECONDS)
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			src.toggle = toggle
			var/obj/item/gun/G = parent
			src.delaystart = delaystart

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

			RegisterSignal(G, COMSIG_GUN_FIREMODE_CHANGED, PROC_REF(toggle_fullauto_firemode))
			RegisterSignal(G, COMSIG_SCOPE_TOGGLED, PROC_REF(scope_toggled))

			if(src.toggle)
				RegisterSignal(G, COMSIG_ITEM_SWAP_TO, PROC_REF(init_fullauto_mode))
				RegisterSignal(G, COMSIG_ITEM_SWAP_AWAY, PROC_REF(end_fullauto_mode))
				if(ismob(G.loc))
					on_pickup(null, G.loc)

	UnregisterFromParent()
		UnregisterSignal(parent, list(COMSIG_GUN_FIREMODE_CHANGED, COMSIG_ITEM_SWAP_TO, COMSIG_ITEM_SWAP_AWAY, COMSIG_SCOPE_TOGGLED))
		for(var/hudSquare in hudSquares)
			aimer?.screen -= hudSquares[hudSquare]
		aimer?.screen -= hudCenter
		aimer = null
		if(current_user)
			end_shootloop(current_user)
		. = ..()

	disposing()
		for(var/hudSquare in hudSquares)
			qdel(hudSquares[hudSquare])
		qdel(hudCenter)
		hudSquares = null
		hudCenter = null
		. = ..()


	on_pickup(datum/source, mob/user)
		var/obj/item/gun/G = parent
		. = ..()
		if(G?.current_firemode.full_auto)
			if(toggle)
				if(user.equipped() == parent)
					init_fullauto_mode(source, user)
			else
				if(user.equipped() == parent)
					toggle_fullauto_firemode(source, G.current_firemode)


	on_dropped(datum/source, mob/user)
		end_fullauto_mode(source, user)
		. = ..()

/datum/component/holdertargeting/fullauto/proc/scope_toggled(datum/source, scope_active)
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

/datum/component/holdertargeting/fullauto/proc/toggle_fullauto_firemode(datum/source, datum/firemode/newFiremode)
	var/obj/item/gun/G = parent
	if(current_user && newFiremode.full_auto != toggle)
		toggle = !toggle

		if(toggle)
			RegisterSignal(G, COMSIG_ITEM_SWAP_TO, PROC_REF(init_fullauto_mode))
			RegisterSignal(G, COMSIG_ITEM_SWAP_AWAY, PROC_REF(end_fullauto_mode))
			if(current_user.equipped() == G)
				init_fullauto_mode(source, current_user)
		else
			UnregisterSignal(G, COMSIG_ITEM_SWAP_TO)
			UnregisterSignal(G, COMSIG_ITEM_SWAP_AWAY)
			if(current_user.equipped() == G)
				end_fullauto_mode(source, current_user)

/datum/component/holdertargeting/fullauto/proc/init_fullauto_mode(datum/source, mob/user)
	RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN, PROC_REF(begin_shootloop))
	if(user.client)
		aimer = user.client
		for(var/atom/hudSquare in hudSquares)
			hudSquare.mouse_over_pointer = icon(cursors_selection[aimer.preferences.target_cursor], "all")
			aimer.screen += hudSquare
		aimer.screen -= hudCenter


/datum/component/holdertargeting/fullauto/proc/end_fullauto_mode(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN)
	end_shootloop(user)
	if(aimer)
		for(var/atom/hudSquare in hudSquares)
			aimer.screen -= hudSquare

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
		RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG, PROC_REF(retarget))
		RegisterSignal(user, COMSIG_MOB_MOUSEUP, PROC_REF(end_shootloop))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(moveRetarget))
		RegisterSignal(user, COMSIG_MOB_SCOPE_MOVED, PROC_REF(scope_moved))
		if(!src.scoped)
			aimer.screen += hudCenter

		src.shootloop(user)

/datum/component/holdertargeting/fullauto/proc/moveRetarget(mob/M, newLoc, direct)
	if(src.target)
		src.target = get_step(src.target, direct)

/datum/component/holdertargeting/fullauto/proc/retarget(mob/M, object, location, control, params)

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
			src.target = T

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

/datum/component/holdertargeting/fullauto/proc/scope_moved(mob/M, delta_x, delta_y)
	src.target_pox += delta_x
	src.target_poy += delta_y

/datum/component/holdertargeting/fullauto/proc/shootloop(mob/living/L)
	set waitfor = 0
	if(shooting)
		return

	var/obj/item/gun/G = parent
	shooting = 1

	delay = delaystart
	while(!stopping)
		if(G.canshoot(L))
			G.Shoot(target ? target : get_step(L, NORTH), get_turf(L), L, src.target_pox, src.target_poy, called_target = target)
			G.suppress_fire_msg = 1
		else
			end_shootloop(L)
		sleep(delay)
		src.iterate_delay()

	stopping = 0
	shooting = 0

/datum/component/holdertargeting/fullauto/proc/end_shootloop(mob/living/user)
	//loop ended - reset values
	var/obj/item/gun/G = parent
	G.suppress_fire_msg = initial(G.suppress_fire_msg)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG)
	UnregisterSignal(user, COMSIG_MOB_MOUSEUP)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_MOB_SCOPE_MOVED)
	target = null
	if(aimer && !src.scoped)
		aimer.screen -= hudCenter
	if(shooting)
		stopping = 1

/datum/component/holdertargeting/fullauto/proc/iterate_delay()
	return



TYPEINFO(/datum/component/holdertargeting/fullauto/ramping)
	initialization_args = list(
		ARG_INFO("delaystart", DATA_INPUT_NUM, "Initial delay between shots (in deciseconds)", 1.5),
		ARG_INFO("delaymin", DATA_INPUT_NUM, "Minimum delay between shots (in deciseconds)", 1.5),
		ARG_INFO("rampfactor", DATA_INPUT_NUM, "Multiplicitive decrease in delay after each shot, (0, 1]", 1),
	)
/datum/component/holdertargeting/fullauto/ramping
	var/delaymin
	var/rampfactor

/datum/component/holdertargeting/fullauto/ramping/Initialize(delaystart = 1.5 DECI SECONDS, delaymin = 1.5 DECI SECONDS, rampfactor = 1)
	if(..() == COMPONENT_INCOMPATIBLE)
		return COMPONENT_INCOMPATIBLE

	src.delaymin = delaymin
	src.rampfactor = rampfactor

/datum/component/holdertargeting/fullauto/ramping/InheritComponent(datum/component/holdertargeting/fullauto/ramping/C, i_am_original, _delaystart, _delaymin, _rampfactor)
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

/datum/component/holdertargeting/fullauto/ramping/iterate_delay()
	src.delay = max(src.delay *= rampfactor, delaymin)




TYPEINFO(/datum/component/holdertargeting/fullauto/callback)
	initialization_args = list(
		ARG_INFO("delaystart", DATA_INPUT_NUM, "Initial delay between shots (in deciseconds)", 1.5),
		ARG_INFO("delay_callback", DATA_INPUT_REF, "ref to a callback datum that will determine next shot delay", null),
	)
/datum/component/holdertargeting/fullauto/callback
	var/datum/callback/delay_callback

/datum/component/holdertargeting/fullauto/callback/Initialize(delaystart = 1.5 DECI SECONDS, delay_callback)
	if(..() == COMPONENT_INCOMPATIBLE)
		return COMPONENT_INCOMPATIBLE

	src.delay_callback = delay_callback

/datum/component/holdertargeting/fullauto/callback/InheritComponent(datum/component/holdertargeting/fullauto/callback/C, i_am_original, _delaystart, _delay_callback)
	if(C)
		src.delaystart = C.delaystart
		src.delay_callback = C.delay_callback
	else
		if (isnum_safe(_delaystart))
			src.delaystart = _delaystart
		if (istype(_delay_callback, /datum/callback))
			src.delay_callback = _delay_callback


/datum/component/holdertargeting/fullauto/callback/iterate_delay()
	src.delay = delay_callback.Invoke(delay)

