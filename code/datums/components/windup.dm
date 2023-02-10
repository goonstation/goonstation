//TODO: support for variable-charge-state weapons? maybe?
//TODO: power drain when holding charge?
//TODO: sfx?
TYPEINFO(/datum/component/holdertargeting/windup)
	initialization_args = list(
		ARG_INFO("duration", DATA_INPUT_NUM, "windup time (seconds)", 1),
	)

/datum/component/holdertargeting/windup
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	mobtype = /mob/living

	var/turf/target
	var/duration
	var/interrupt = FALSE
	var/datum/action/bar/icon/windup/winder

	var/list/atom/movable/screen/fullautoAimHUD/hudSquares = list()
	var/client/aimer

	InheritComponent(datum/component/holdertargeting/windup/C, i_am_original, _duration)
		if(C)
			src.duration = C.duration
		else
			if (isnum_safe(_duration))
				src.duration = _duration

	Initialize(duration = 1 SECOND)
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			var/obj/item/gun/G = parent
			src.duration = duration

			for(var/x in 1 to WIDE_TILE_WIDTH)
				for(var/y in 1 to 15)
					var/atom/movable/screen/fullautoAimHUD/hudSquare = new /atom/movable/screen/fullautoAimHUD
					hudSquare.screen_loc = "[x],[y]"
					hudSquare.xOffset = x
					hudSquare.yOffset = y
					hudSquares["[x],[y]"] = hudSquare


			RegisterSignal(G, COMSIG_ITEM_SWAP_TO, .proc/init_aim_mode)
			RegisterSignal(G, COMSIG_ITEM_SWAP_AWAY, .proc/end_aim_mode)
			if(ismob(G.loc))
				on_pickup(null, G.loc)

	UnregisterFromParent()
		for(var/hudSquare in hudSquares)
			aimer?.screen -= hudSquares[hudSquare]
		aimer = null

		if(current_user)
			interrupt = TRUE
			end_shootloop(current_user)
		. = ..()

	disposing()
		for(var/hudSquare in hudSquares)
			qdel(hudSquares[hudSquare])
		hudSquares = null
		. = ..()


	on_pickup(datum/source, mob/user)
		. = ..()
		if(user.equipped() == parent)
			init_aim_mode(source, user)


	on_dropped(datum/source, mob/user)
		end_aim_mode(source, user)
		. = ..()


/datum/component/holdertargeting/windup/proc/init_aim_mode(datum/source, mob/user)
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

/datum/component/holdertargeting/windup/proc/end_aim_mode(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN)
	interrupt = TRUE
	end_shootloop(user)
	if(aimer)
		for(var/x in 1 to (istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				aimer.screen -= hudSquares["[x],[y]"]
	aimer = null

/datum/component/holdertargeting/windup/proc/moveRetarget(mob/M, newLoc, direct)
	if(src.target)
		src.target = get_step(src.target, direct)

/datum/component/holdertargeting/windup/proc/retarget(mob/M, object, location, control, params)

	var/turf/T
	var/atom/movable/screen/fullautoAimHUD/F = object
	if(istype(F) && aimer)
		T = locate(M.x + (F.xOffset + -1 - ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2),\
							M.y + (F.yOffset + -1 - 7),\
							M.z)

		if(T && T != get_turf(parent))
			src.target = T

/datum/component/holdertargeting/windup/proc/begin_shootloop(mob/living/user, object, location, control, params)
	src.retarget(user, object, location, control, params)
	interrupt = FALSE
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

	src.do_windup(user)

/datum/component/holdertargeting/windup/proc/do_windup(mob/living/L)
	set waitfor = 0
	var/obj/item/gun/G = parent
	winder = new(G, duration)
	actions.start(winder, L)

/datum/component/holdertargeting/windup/proc/end_shootloop(mob/living/user, object, location, control, params)
	if(winder)
		if(!interrupt && TIME > winder.started + winder.duration)
			if(params)
				var/list/paramlist = params2list(params)
				winder.pox = text2num(paramlist["vis-x"] || paramlist["icon-x"]) - 16
				winder.poy = text2num(paramlist["vis-x"] || paramlist["icon-y"]) - 16
			winder.target_turf = target
			winder.user_turf = get_turf(user)
			winder.onEnd() //crime, but we don't want to wait for the preocess
		else
			winder.interrupt(INTERRUPT_ALWAYS)
		winder = null
	
	interrupt = FALSE

	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG)
	UnregisterSignal(user, COMSIG_MOB_MOUSEUP)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	target = null
	if(aimer)
		for(var/x in ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 - 1 to ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)+1)/2 + 1)
			for(var/y in 7 to 9)
				aimer.screen -= hudSquares["[x],[y]"]


/datum/action/bar/icon/windup
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED
	id = "guncharge"
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	icon_state = "screwdriver"
	var/obj/item/gun/ownerGun
	var/time
	var/pox = 0
	var/poy = 0
	var/user_turf
	var/target_turf
	resumable = FALSE


	New(_gun,  _time)
		ownerGun = _gun
		icon = ownerGun.icon
		icon_state = ownerGun.icon_state
		duration = _time
		..()

	onStart()
		. = ..()
		state = ACTIONSTATE_INFINITE

	onEnd()
		..()
		ownerGun.shoot(target_turf, user_turf, owner, pox, poy)
