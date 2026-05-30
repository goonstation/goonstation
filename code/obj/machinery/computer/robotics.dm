#define BRAIN_STATUS_PRESENT "present"
#define BRAIN_STATUS_DISCONNECTED "disconnected"
#define BRAIN_STATUS_MISSING "missing"

/obj/machinery/computer/robotics
	name = "robotics control"
	icon = 'icons/obj/computer.dmi'
	icon_state = "robotics"
	req_access = list(access_ai_upload)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	desc = "A computer that allows an authorized user to have an overview and control of the cyborgs on the station."
	power_usage = 500
	circuit_type = /obj/item/circuitboard/robotics
	var/perma = 0
	var/can_lockdown = TRUE
	var/can_killswitch = TRUE

	light_r =0.85
	light_g = 0.86
	light_b = 1

	New()
		..()
		START_TRACKING

	disposing()
		..()
		STOP_TRACKING

	attackby(obj/item/I, user)
		if (issilicon(I) && isscrewingtool(I))
			boutput(user, SPAN_ALERT("The screws on [src] can only be reached by nimble human hands!"))
			return
		. = ..()

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		if (!src.emagged)
			src.emagged = TRUE
			if(user)
				boutput(user, SPAN_ALERT("The access and control restictors on [src] have been disabled."))
			src.visible_message("Emits a brief spark and reboots.")
			src.req_access = list()
			src.can_lockdown = TRUE
			src.can_killswitch = TRUE

	demag(mob/user)
		. = ..()
		if (src.emagged)
			src.emagged = FALSE
			src.req_access = initial(src.req_access)
			src.can_lockdown = initial(src.can_lockdown)
			src.can_killswitch = initial(src.can_killswitch)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "RoboticsControl")
			ui.open()

	ui_data(mob/user)
		var/list/silicons = src.update_silicon_statuses()
		. = list(
			"user_is_ai" = isAI(user),
			"user_is_cyborg" = isrobot(user),
			"can_killswitch" = src.can_killswitch,
			"can_lockdown" = src.can_lockdown,
			"ais" = silicons[1],
			"cyborgs" = silicons[2],
			"ghostdrones" = src.update_ghostdrone_statuses()
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		var/obj/item/card/id/I = usr.equipped()
		if (!isAI(usr))
			if (!istype(I) || !src.check_access(I))
				boutput(usr, SPAN_ALERT("Access Denied."))
				return TRUE
		if (issilicon(usr) && !isAI(usr))
			boutput(usr, SPAN_ALERT("Access Denied."))
			return TRUE
		switch (action)
			if ("start_ai_killswitch")
				if (!src.can_killswitch)
					return
				if (isAI(usr))
					boutput(usr, SPAN_ALERT("AI units are unable to access killswitch functionality."))
					return
				var/mob/living/silicon/ai/ai_player = locate(params["mob_ref"])
				if (QDELETED(ai_player))
					return
				message_admins(SPAN_ALERT("[key_name(usr)] has activated the AI self destruct on [key_name(ai_player)]."))
				logTheThing(LOG_COMBAT, usr, "has activated the AI killswitch process on [constructTarget(ai_player,"combat")]")
				ai_player.setStatus("killswitch_ai", AI_KILLSWITCH_DURATION)
				return TRUE
			if ("stop_ai_killswitch")
				if (!src.can_killswitch)
					return
				if (isAI(usr))
					boutput(usr, SPAN_ALERT("AI units are unable to access killswitch functionality."))
					return
				var/mob/living/silicon/ai/ai_player = locate(params["mob_ref"])
				if (QDELETED(ai_player))
					return
				ai_player.delStatus("killswitch_ai")
				message_admins(SPAN_ALERT("[key_name(usr)] has stopped the AI self destruct on [key_name(ai_player, 1, 1)]."))
				logTheThing(LOG_COMBAT, usr, "has stopped the AI killswitch process on [constructTarget(ai_player,"combat")].")
				return TRUE
			if ("start_silicon_killswitch")
				if (!src.can_killswitch)
					return
				if (isAI(usr))
					boutput(usr, SPAN_ALERT("AI units are unable to access killswitch functionality."))
					return
				var/mob/living/silicon/robot/robot = locate(params["mob_ref"])
				if (QDELETED(robot))
					return
				var/datum/statusEffect/killswitch/killswitch_status = robot.setStatus("killswitch_robot", ROBOT_KILLSWITCH_DURATION)
				var/immune = killswitch_status.owner_is_immune()
				message_admins(SPAN_ALERT("[key_name(usr)] has activated the [immune ? "fake " : ""]robot self destruct on [key_name(robot)]."))
				logTheThing(LOG_COMBAT, usr, "has activated the [immune ? "fake " : ""]robot killswitch process on [constructTarget(robot,"combat")]")
				return TRUE
			if ("stop_silicon_killswitch")
				if (!src.can_killswitch)
					return
				if (isAI(usr))
					boutput(usr, SPAN_ALERT("AI units are unable to access killswitch functionality."))
					return
				var/mob/living/silicon/robot/robot = locate(params["mob_ref"])
				if (QDELETED(robot))
					return
				robot.delStatus("killswitch_robot")
				message_admins(SPAN_ALERT("[key_name(usr)] has stopped the robot self destruct on [key_name(robot, 1, 1)]."))
				logTheThing(LOG_COMBAT, usr, "has stopped the robot killswitch process on [constructTarget(robot,"combat")].")
				return TRUE
			if ("start_silicon_lock")
				if (!src.can_lockdown)
					return
				var/mob/living/silicon/robot/robot = locate(params["mob_ref"])
				if (QDELETED(robot))
					return
				if (robot.emagged || robot.syndicate)
					if (robot.client)
						boutput(robot, SPAN_NOTICE("<b>Equipment lockdown signal blocked!</b>"))
						return
				robot.setStatus("lockdown_robot", ROBOT_LOCKDOWN_DURATION)
				logTheThing(LOG_COMBAT, usr, "has activated [constructTarget(robot,"combat")]'s equipment lockdown.")
				return TRUE
			if ("stop_silicon_lock")
				if (!src.can_lockdown)
					return
				var/mob/living/silicon/robot/robot = locate(params["mob_ref"])
				if (QDELETED(robot))
					return
				robot.delStatus("lockdown_robot")
				logTheThing(LOG_COMBAT, usr, "has deactivated [constructTarget(robot, "combat")]'s equipment lock.")
				return TRUE
			if ("killswitch_ghostdrone")
				var/mob/living/silicon/ghostdrone/drone = locate(params["mob_ref"])
				if (QDELETED(drone))
					return
				message_admins(SPAN_ALERT("[key_name(usr)] killswitched drone [key_name(drone)]."))
				logTheThing(LOG_COMBAT, usr, "killswitched drone [constructTarget(drone,"combat")]")
				if(drone.client)
					boutput(drone, SPAN_ALERT("<b>Killswitch activated.</b>"))
				drone.gib()
				return TRUE

/obj/machinery/computer/robotics/attackby(obj/item/I, user)
	if (perma && isscrewingtool(I))
		boutput(user, SPAN_ALERT("The screws are all weird safety-bit types! You can't turn them!"))
		return
	..()
	return

/obj/machinery/computer/robotics/special_deconstruct(obj/computerframe/frame as obj, mob/user)
	logTheThing(LOG_STATION, src, "is deconstructed by [key_name(user)] at [log_loc(src)]")

/obj/machinery/computer/robotics/save_board_data(obj/item/circuitboard/circuitboard)
	. = ..()
	circuitboard.saved_data = src.id

/obj/machinery/computer/robotics/load_board_data(obj/item/circuitboard/circuitboard)
	if(..())
		return
	src.id = circuitboard.saved_data

/obj/machinery/computer/robotics/proc/update_silicon_statuses()
	var/list/ais = list()
	var/list/cyborgs = list()

	for_by_tcl(A, /mob/living/silicon/ai)
		var/datum/statusEffect/killswitch/killswitch_ai_status = A.hasStatus("killswitch_ai")
		var/brain_status = BRAIN_STATUS_MISSING
		if (A.brain)
			if (A.deployed_shell)
				if (A.deployed_shell.client)
					brain_status = BRAIN_STATUS_PRESENT
			else if (A.deployed_to_eyecam)
				if (A.eyecam?.client)
					brain_status = BRAIN_STATUS_PRESENT
			else if (A.client)
				brain_status = BRAIN_STATUS_PRESENT
			else
				brain_status = BRAIN_STATUS_DISCONNECTED
		ais += list(list(
			"name" = A.name,
			"mob_ref" = "\ref[A]",
			"status" = A.stat,
			"cell_charge" = A.cell?.charge,
			"cell_maxcharge" = A.cell?.maxcharge,
			"brain_status" = brain_status,
			"missing_brain" = isnull(A.brain),
			"killswitch_time" = killswitch_ai_status ? round((killswitch_ai_status.duration) / 10, 1) : null
		))

	for_by_tcl(R, /mob/living/silicon/robot)
		if(QDELETED(R) || R.shell || R.dependent)
			continue
		var/datum/statusEffect/killswitch/killswitch_robot_status = R.hasStatus("killswitch_robot")
		var/datum/statusEffect/lockdown/lockdown_robot_status = R.hasStatus("lockdown_robot")
		var/brain_status = BRAIN_STATUS_MISSING
		if (R.part_head?.brain)
			if (R.client)
				brain_status = BRAIN_STATUS_PRESENT
			else
				brain_status = BRAIN_STATUS_DISCONNECTED
		cyborgs += list(list(
			"name" = R.name,
			"mob_ref" = "\ref[R]",
			"brain_status" = brain_status,
			"status" = R.stat,
			"cell_charge" = R.cell?.charge,
			"cell_maxcharge" = R.cell?.maxcharge,
			"module" = R.module ? capitalize(R.module.name) : null,
			"lock_time" = lockdown_robot_status ? round(lockdown_robot_status.duration/10, 1) : null,
			"killswitch_time" = killswitch_robot_status ? round((killswitch_robot_status.duration) / 10, 1) : null
		))

	return list(ais, cyborgs)

/obj/machinery/computer/robotics/proc/update_ghostdrone_statuses()
	var/list/ghostdrones = list()
	for_by_tcl(drone, /mob/living/silicon/ghostdrone)
		if (!drone.last_ckey || isdead(drone))
			continue
		ghostdrones += list(list(
			"name" = drone.name,
			"mob_ref" = "\ref[drone]"
		))
	return ghostdrones

/obj/machinery/computer/robotics/lab
	name = "robotics monitoring"
	desc = "A computer that allows users to have an overview of the cyborgs on the station."
	circuit_type = /obj/item/circuitboard/robotics_lab
	can_killswitch = FALSE
	can_lockdown = FALSE

#undef BRAIN_STATUS_PRESENT
#undef BRAIN_STATUS_DISCONNECTED
#undef BRAIN_STATUS_MISSING
