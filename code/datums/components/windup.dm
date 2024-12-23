//TODO: support for variable-charge-state weapons? maybe?
//TODO: power drain when holding charge?
//TODO: sfx?
TYPEINFO(/datum/component/holdertargeting/windup)
	initialization_args = list(
		ARG_INFO("duration", DATA_INPUT_NUM, "windup time (deciseconds)", 10),
	)

/datum/component/holdertargeting/windup
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	mobtype = /mob/living

	var/turf/target
	var/duration
	var/interrupt = FALSE
	var/datum/action/bar/icon/windup/winder
	var/intercept_shoot = TRUE
	var/scoped = FALSE

	var/list/atom/movable/screen/fullautoAimHUD/hudSquares = list()
	var/atom/movable/screen/fullautoAimHUD/hudCenter
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

			RegisterSignal(G, COMSIG_ITEM_SWAP_TO, PROC_REF(init_aim_mode))
			RegisterSignal(G, COMSIG_ITEM_SWAP_AWAY, PROC_REF(end_aim_mode))
			RegisterSignal(G, COMSIG_GUN_TRY_SHOOT, PROC_REF(forced_shoot))
			RegisterSignal(G, COMSIG_GUN_TRY_POINTBLANK, PROC_REF(try_pointblank))
			RegisterSignal(G, COMSIG_SCOPE_TOGGLED, PROC_REF(scope_toggled))
			if(ismob(G.loc))
				on_pickup(null, G.loc)

	UnregisterFromParent()
		UnregisterSignal(parent, list(COMSIG_ITEM_SWAP_TO,\
			COMSIG_ITEM_SWAP_AWAY,\
			COMSIG_GUN_TRY_SHOOT,\
			COMSIG_GUN_TRY_POINTBLANK,\
			COMSIG_SCOPE_TOGGLED))
		for(var/hudSquare in hudSquares)
			aimer?.screen -= hudSquare
		aimer = null

		if(current_user)
			interrupt = TRUE
			end_shootloop(current_user)
		. = ..()

	disposing()
		for(var/hudSquare in hudSquares)
			qdel(hudSquare)
		hudSquares = null
		. = ..()


	on_pickup(datum/source, mob/user)
		. = ..()
		if(user.equipped() == parent)
			init_aim_mode(source, user)


	on_dropped(datum/source, mob/user)
		end_aim_mode(source, user)
		. = ..()

/datum/component/holdertargeting/windup/proc/scope_toggled(datum/source, scope_active)
	var/old_scoped = src.scoped
	src.scoped = scope_active
	if(!aimer)
		return
	if(!old_scoped && src.scoped) //add aiming squares to center of screen
		aimer.screen += hudCenter
		return
	if(old_scoped && !src.scoped) //add aiming squares to center of screen
		aimer.screen -= hudCenter
		return

/datum/component/holdertargeting/windup/proc/init_aim_mode(datum/source, mob/user)
	RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN, PROC_REF(on_mousedown))
	if(user.client)
		aimer = user.client
		for(var/atom/hudSquare in hudSquares)
			hudSquare.mouse_over_pointer = icon(cursors_selection[aimer.preferences.target_cursor], "all")
			aimer.screen += hudSquare
		aimer.screen -= hudCenter

/datum/component/holdertargeting/windup/proc/end_aim_mode(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN)
	interrupt = TRUE
	end_shootloop(user)
	if(aimer)
		for(var/atom/hudSquare in hudSquares)
			aimer.screen -= hudSquare
	aimer = null

/datum/component/holdertargeting/windup/proc/moveRetarget(mob/M, newLoc, direct)
	if(src.target)
		src.target = get_step(src.target, direct)

/datum/component/holdertargeting/windup/proc/retarget(mob/M, object, location, control, params)

	var/turf/T
	var/atom/movable/screen/fullautoAimHUD/F = object


	var/regex/locparser = new(@"^(\d+):(\d*),(\d+):(\d*)$")
	if(!locparser.Find(params2list(params)["screen-loc"]))
		return //FUCK
	var/x = text2num(locparser.group[1])
	var/y = text2num(locparser.group[3])

	if(istype(F) && aimer)
		T = get_turf(aimer.virtual_eye)
		T = locate(T.x + (aimer.pixel_x / 32) + (x + -1 - ((istext(aimer.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2),\
							T.y + (aimer.pixel_y / 32) + (y + -1 - 7),\
							M.z)

		if(T && T != get_turf(parent))
			src.target = T

/datum/component/holdertargeting/windup/proc/on_mousedown(mob/living/user, object, location, control, params)
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

	RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG, PROC_REF(retarget))
	RegisterSignal(user, COMSIG_MOB_MOUSEUP, PROC_REF(end_shootloop))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(moveRetarget))

	//add aiming squares to center of screen
	if(!src.scoped)
		aimer.screen += hudCenter

	src.do_windup(user)

/datum/component/holdertargeting/windup/proc/do_windup(mob/living/L)
	set waitfor = 0
	var/obj/item/gun/G = parent
	winder = new/datum/action/bar/icon/windup/infinite(G, duration)
	actions.start(winder, L)

/datum/component/holdertargeting/windup/proc/end_shootloop(mob/living/user, object, location, control, params)
	if(winder)
		if(!interrupt && TIME > winder.started + winder.duration) //if windup has passed full duration
			src.retarget(user, object, location, control, params)
			if(params)
				var/list/paramlist = params2list(params)
				winder.pox = text2num(paramlist["icon-x"]) - 16
				winder.poy = text2num(paramlist["icon-y"]) - 16
				if(user.client && src.scoped)
					if(user.client.pixel_x)
						winder.pox += user.client.pixel_x % 32
						if(user.client.pixel_x < 0)
							winder.pox += 32
					if(user.client.pixel_y)
						winder.poy += user.client.pixel_y % 32
						if(user.client.pixel_y < 0)
							winder.poy += 32
			winder.target = src.target
			winder.onEnd() //crime, but we don't want to wait for the preocess
		else
			winder.interrupt(INTERRUPT_ALWAYS)
		winder = null

	interrupt = FALSE

	UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG)
	UnregisterSignal(user, COMSIG_MOB_MOUSEUP)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	target = null

	//clear aiming squares around center of screen
	if(aimer && !src.scoped)
		aimer.screen -= hudCenter



//try_shoot - return 1 prevents normal shooting behaviour
/datum/component/holdertargeting/windup/proc/forced_shoot(source, atom/target, atom/start, shooter)
	. = 0
	if(QDELETED(winder) || winder.state == ACTIONSTATE_DELETE)
		. = 1

	if(.)
		var/obj/item/gun/G = parent
		winder = new/datum/action/bar/icon/windup(G, duration)
		winder.target = target
		actions.start(winder, shooter)


/datum/component/holdertargeting/windup/proc/try_pointblank(obj/source, atom/target, user, second_shot)
	. = 0
	if(QDELETED(winder) || winder.state == ACTIONSTATE_DELETE)
		. = 1

	if(.)
		var/obj/item/gun/G = parent
		winder = new/datum/action/bar/icon/windup(G, duration, TRUE)
		winder.target = target
		actions.start(winder, user)

/datum/action/bar/icon/windup
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	icon_state = "screwdriver"
	var/obj/item/gun/ownerGun
	var/mob/user
	var/pox = 0
	var/poy = 0
	var/target
	var/do_point_blank = FALSE
	resumable = FALSE


	New(_gun,  _time, _do_point_blank = FALSE)
		ownerGun = _gun
		icon = ownerGun.icon
		icon_state = ownerGun.icon_state
		duration = _time
		do_point_blank = _do_point_blank
		..()

	onEnd()
		if(BOUNDS_DIST(owner, target) <= 1 && do_point_blank)
			ownerGun.ShootPointBlank(target, owner)
		else
			ownerGun.Shoot(get_turf(target), get_turf(ownerGun), owner, pox, poy)
		..()

//will not end on its own, so that we can hold a charge
/datum/action/bar/icon/windup/infinite
	onStart()
		. = ..()
		state = ACTIONSTATE_INFINITE

