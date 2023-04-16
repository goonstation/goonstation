/obj/machinery/turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "grey_target_prism"
	var/raised = 0
	var/enabled = 1
	anchored = ANCHORED
	layer = OBJ_LAYER
	plane = PLANE_NOSHADOW_BELOW
	invisibility = INVIS_CLOAK
	density = 0
	machine_registry_idx = MACHINES_TURRETS
	power_usage = 50
	var/lasers = 0
	var/health = 100
	var/obj/machinery/turretcover/cover = null
	var/popping = 0
	var/wasvalid = 0
	var/lastfired = 0
	var/shot_delay = 15 //1.5 seconds between shots (previously 3, way too much to be useful)
	var/shot_type = 0
	var/override_area_bullshit = 0
	var/datum/projectile/lethal = new/datum/projectile/laser/heavy/law_safe
	var/datum/projectile/stun = new/datum/projectile/energy_bolt/robust
	var/list/mob/target_list = null

/obj/machinery/turretcover
	name = "pop-up turret cover"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = ANCHORED
	layer = OBJ_LAYER+0.5
	density = 0

/obj/machinery/turret/New()
	..()
	var/area/station/turret_protected/TP = get_area(src)
	if(istype(TP))
		TP.turret_list += src
	START_TRACKING

	#ifdef LOW_SECURITY
	START_TRACKING_CAT(TR_CAT_DELETE_ME)
	#endif

/obj/machinery/turret/disposing()
	var/area/station/turret_protected/TP = get_area(src)
	if(istype(TP))
		TP.turret_list -= src
	STOP_TRACKING
	..()

/obj/machinery/turret/proc/isPopping()
	return (popping!=0)

/obj/machinery/turret/power_change()
	if(status & BROKEN)
		icon_state = "grey_target_prism"
	else
		if( powered() )
			if (src.enabled)
				if (src.lasers)
					icon_state = "orange_target_prism"
				else
					icon_state = "target_prism"
			else
				icon_state = "grey_target_prism"
			status &= ~NOPOWER
		else
			SPAWN(rand(0, 15))
				src.icon_state = "grey_target_prism"
				status |= NOPOWER

/obj/machinery/turret/proc/setState(var/enabled, var/lethal)
	src.enabled = enabled
	src.lasers = lethal
	src.power_change()

/obj/machinery/turret/process()
	if(status & BROKEN)
		return
	..()
	if(status & NOPOWER)
		return
	if(override_area_bullshit)
		return
	if(lastfired && world.time - lastfired < shot_delay)
		return

	if (src.cover==null)
		src.cover = new /obj/machinery/turretcover(src.loc)
	var/area/area = get_area(loc)
	if (istype(area))
		if(!target_list)
			target_list = get_target_list()	//Calculate a new batch of targets
			if(istype(area, /area/station/turret_protected)) //It'd be faster to just throw our turret buds our target list.
				var/area/station/turret_protected/TP = area
				for(var/obj/machinery/turret/T in TP.turret_list) //Sharing is caring - give it to our turret friends so they don't have to work out a target list
					T.target_list = src.target_list


		if (length(target_list))
			if (!isPopping())
				if (isDown())
					popUp()
				else
					var/atom/target = pick(target_list)
					src.set_dir(get_dir(src, target))
					lastfired = world.time //Setting this here to prevent immediate firing when enabled
					if (src.enabled)
						//if (isliving(target))
						src.shootAt(target)
		else if(!isDown() && !isPopping())
			popDown()

		target_list = null //Get ready for a new batch of targets during the next cycle

/obj/machinery/turret/proc/get_target_list()
	var/area/A = get_area(src)
	.= list()

	for(var/mob/living/C in mobs)
		if (!C)
			continue
		if (!iscarbon(C) && !ismobcritter(C))
			continue
		if (isdead(C) || isghostcritter(C))
			continue
		if (!(istype(C.loc,/turf) || istype(C.loc, /obj/vehicle)))
			continue
		if (!(get_area(C) == A))
			continue
		if ((src.req_access || src.req_access_txt) && src.allowed(C))
			continue //optional access whitelist
		. += C

	if (istype(A, /area/station/turret_protected))
		var/area/station/turret_protected/T = A
		if (T.blob_list.len)
			for(var/obj/blob/B in T.blob_list)
				if (!B)
					continue
				if (!istype(B.loc,/turf))
					continue
				if (!istype(B.loc.loc,A))
					continue
				. += B

	//slower
	/*
	for(var/atom/AT in A)
		var/mob/living/C = AT
		if( istype(C) )
			if (!iscarbon(C) && !ismobcritter(C))
				continue
			if (isdead(C))
				continue
			. += C
		else if( istype(AT, /obj/blob) )
			. += AT
	*/

/obj/machinery/turret/proc/isDown()
	return (invisibility != INVIS_NONE)

/obj/machinery/turret/proc/popUp()
	if (!isDown()) return
	if ((!isPopping()) || src.popping==-1)
		invisibility = INVIS_NONE
		popping = 1
		if (src.cover!=null)
			flick("popup", src.cover)
			src.cover.icon_state = "openTurretCover"
		SPAWN(1 SECOND)
			if (popping==1) popping = 0
			set_density(1)

/obj/machinery/turret/proc/popDown()
	if (isDown()) return
	if ((!isPopping()) || src.popping==1)
		popping = -1
		if (src.cover!=null)
			flick("popdown", src.cover)
			src.cover.icon_state = "turretCover"
		SPAWN(1.3 SECONDS)
			if (popping==-1)
				invisibility = INVIS_CLOAK
				popping = 0
				set_density(0)

/obj/machinery/turret/proc/shootAt(var/atom/movable/target)
	var/turf/T = loc
	var/atom/U = get_turf(target)
	if ((!( U ) || !( T )))
		return
	if (!( istype(T, /turf) ))
		return

	if(shot_type == 1)
		return
	else

		if (src.lasers)
			use_power(200)
			shoot_projectile_ST(src, lethal, U)
			muzzle_flash_any(src, get_angle(src,target), "muzzle_flash_laser")
		else
			use_power(100)
			shoot_projectile_ST(src, stun, U)
			muzzle_flash_any(src, get_angle(src,target), "muzzle_flash_elec")


	return

/obj/machinery/turret/bullet_act(var/obj/projectile/P)
	var/damage = 0
	var/area/station/turret_protected/ai/aiArea = get_area(src)
	if(istype(aiArea))
		var/mob/living/silicon/ai/theAI = locate() in aiArea
		if(theAI)
			theAI.notify_attacked()
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)

	if(src.material) src.material.triggerOnBullet(src, src, P)

	if(P.proj_data.damage_type == D_KINETIC)
		src.health -= damage
	else if(P.proj_data.damage_type == D_PIERCING)
		src.health -= (damage*2)
	else if(P.proj_data.damage_type == D_ENERGY)
		src.health -= damage / 2

	if (src.health <= 0)
		src.die()
	return


/obj/machinery/turret/ex_act(severity)
	if(severity < 3)
		SPAWN(0)
			src.die()

/obj/machinery/turret/emp_act()
	..()
	src.enabled = 0
	src.lasers = 0
	src.power_change()
	return

/obj/machinery/turret/proc/die()
	src.health = 0
	src.set_density(0)
	src.status |= BROKEN
	src.icon_state = "destroyed_target_prism"
	if (cover!=null)
		qdel(cover)
	sleep(0.3 SECONDS)
	flick("explosion", src)
	SPAWN(1.3 SECONDS)
		qdel(src)

/*
 *	Network turret, a turret controlled over the wire network instead of a turretid
 */

/obj/machinery/turret/network
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null

	New()
		..()
		SPAWN(0.6 SECONDS)
			src.net_id = generate_net_id(src)
			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

		return

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		if(signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/sender = signal.data["sender"]
		if((signal.data["address_1"] == "ping") && sender)
			SPAWN(0.5 SECONDS)
				src.post_status(sender, "command", "ping_reply", "device", "PNET_SEC_TURRT", "netid", src.net_id)
			return

		if(signal.data["address_1"] == src.net_id && signal.data["acc_code"] == netpass_security)
			var/command = lowertext(signal.data["command"])
			switch(command)
				if("status")
					var/status_string = "on=[!(status & NOPOWER)]&health=[src.health]&lethal=[src.lasers]&active=[src.enabled]"
					SPAWN(0.3 SECONDS)
						src.post_status(sender, "command", "device_reply", status_string)
				if("setmode")
					var/list/L = params2list(signal.data["data"])
					if(!L || !length(L)) return
					var/new_lethal_state = text2num_safe(L["lethal"])
					var/new_enabled_state = text2num_safe(L["active"])
					if(!isnull(new_lethal_state))
						if(new_lethal_state)
							src.lasers = 1
						else
							src.lasers = 0
					if(!isnull(new_enabled_state))
						if(new_enabled_state)
							src.enabled = 1
						else
							src.enabled = 0

			return
		return

	proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
		if(!src.link || !target_id)
			return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = TRANSMISSION_WIRE
		signal.data[key] = value
		if(key2)
			signal.data[key2] = value2
		if(key3)
			signal.data[key3] = value3

		signal.data["address_1"] = target_id
		signal.data["sender"] = src.net_id

		src.link.post_signal(src, signal)

ADMIN_INTERACT_PROCS(/obj/machinery/turretid, proc/toggle_active, proc/toggle_lethal)
/obj/machinery/turretid
	name = "Turret deactivation control"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "ai3"
	anchored = ANCHORED
	density = 0
	plane = PLANE_NOSHADOW_ABOVE
	var/enabled = 1
	var/lethal = 0
	var/locked = 1
	var/emagged = 0
	var/turretArea = null

	req_access = list(access_ai_upload)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	New()
		..()
		if (!src.turretArea)
			var/area/A = get_area(src)
			src.turretArea = A.type

/obj/machinery/turretid/attackby(obj/item/W, mob/user)
	if(status & BROKEN) return
	if (issilicon(user) || isAI(user))
		return src.Attackhand(user)
	else // trying to unlock the interface
		if (src.allowed(user))
			locked = !locked
			boutput(user, "You [ locked ? "lock" : "unlock"] the panel.")
			if (locked)
				if (user.using_dialog_of(src))
					src.remove_dialog(user)
					user.Browse(null, "window=turretid")
			else
				if (user.using_dialog_of(src))
					src.Attackhand(user)
		else
			boutput(user, "<span class='alert'>Access denied.</span>")

/obj/machinery/turretid/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/turretid/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurretControl")
		ui.open()

/obj/machinery/turretid/ui_data(mob/user)
	. = list(
		"enabled" = src.enabled,
		"lethal" = src.lethal,
		"emagged" = src.emagged
	)
	if (issilicon(user) || isAI(user))
		.["locked"] = FALSE
	else
		.["locked"] = src.locked

/obj/machinery/turretid/ui_static_data(mob/user)
	var/area/area = get_area(src)
	if (!istype(area))
		logTheThing(LOG_DEBUG, null, "Turret badly positioned.")
	. = list(
		"area" = istype(area) ? area.name : "Somewhere"
	)


/obj/machinery/turretid/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return

	if (src.locked)
		if (!issilicon(usr) && !isAI(usr))
			boutput(usr, "Control panel is locked!")
			return

	switch (action)
		if ("setEnabled")
			if (src.enabled == params["enabled"])
				return
			src.enabled = params["enabled"]
			logTheThing(LOG_COMBAT, usr, "turned [enabled ? "ON" : "OFF"] turrets from control \[[log_loc(src)]].")
			src.updateTurrets()
			. = TRUE
		if ("setLethal")
			if (src.lethal == params["lethal"])
				return
			src.lethal = params["lethal"]
			if(src.lethal)
				logTheThing(LOG_COMBAT, usr, "set turrets to LETHAL from control \[[log_loc(src)]].")
				message_admins("[key_name(usr)] set turrets to LETHAL from control \[[log_loc(src)]].")
			else
				logTheThing(LOG_COMBAT, usr, "set turrets to STUN from control \[[log_loc(src)]].")
				message_admins("[key_name(usr)] set turrets to STUN from control \[[log_loc(src)]].")
			src.updateTurrets()
			. = TRUE

/obj/machinery/turretid/receive_silicon_hotkey(var/mob/user)
	..()

	if (!isAI(user) && !issilicon(user))
		return

	if(user.client.check_key(KEY_OPEN))
		. = 1
		src.toggle_active()
	else if(user.client.check_key(KEY_BOLT))
		. = 1
		src.toggle_lethal()

/obj/machinery/turretid/proc/toggle_active(mob/user)
	src.enabled = !src.enabled
	boutput(user, "You have <B>[src.enabled ? "en" : "dis"]abled</B> the turrets.")
	logTheThing(LOG_COMBAT, user || usr, "turned [enabled ? "ON" : "OFF"] turrets from control \[[log_loc(src)]].")
	src.updateTurrets()

/obj/machinery/turretid/proc/toggle_lethal(mob/user)
	src.lethal = !src.lethal
	boutput(user, "You have set the turrets to <B>[src.lethal ? "laser" : "stun"]</B> mode.")
	if(src.lethal)
		logTheThing(LOG_COMBAT, user || usr, "set turrets to LETHAL from control \[[log_loc(src)]].")
		message_admins("[key_name(user || usr)] set turrets to LETHAL from control \[[log_loc(src)]].")
	else
		logTheThing(LOG_COMBAT, user || usr, "set turrets to STUN from control \[[log_loc(src)]].")
		message_admins("[key_name(user || usr)] set turrets to STUN from control \[[log_loc(src)]].")
	src.updateTurrets()

/obj/machinery/turretid/proc/updateTurrets()
	for_by_tcl(turret, /obj/machinery/turret)
		var/area/A = get_area(turret)
		if (A.type == src.turretArea)
			turret.setState(enabled, lethal)
			src.UpdateIcon()

/obj/machinery/turretid/update_icon()
	if (src.enabled)
		if (src.lethal)
			icon_state = "ai1"
		else
			icon_state = "ai3"
	else
		icon_state = "ai0"

/obj/machinery/turretid/emag_act(var/mob/user)
	if(!emagged)
		if(user)
			user.show_text("You short out the control circuit on [src]!", "blue")
			logTheThing(LOG_COMBAT, user, "emagged the turret control in [loc.name] \[[log_loc(src)]]")
			logTheThing(LOG_ADMIN, user, "emagged the turret control in [loc.name] \[[log_loc(src)]]")
		emagged = 1
		enabled = 0
		updateTurrets()
		SPAWN(100 + (rand(0,20)*10))
			process_emag()

		return 1

	else
		if(user) user.show_text("This thing is already fried!", "red")
		return 0

/obj/machinery/turretid/demag(var/mob/user)
	if (!emagged)
		return 0
	if (user)
		user.show_text("You repair the control circuit on [src]!", "blue")
	emagged = 0
	updateTurrets()
	return 1

/obj/machinery/turretid/proc/process_emag()
	do
		src.enabled = prob(90)
		src.lethal = prob(60)
		updateTurrets()

		sleep(rand(1, 10) * 10)
	while(emagged)
