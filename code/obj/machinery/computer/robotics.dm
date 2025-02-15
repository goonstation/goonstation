/obj/machinery/computer/robotics
	name = "robotics control"
	icon = 'icons/obj/computer.dmi'
	icon_state = "robotics"
	req_access = list(access_ai_upload)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	desc = "A computer that allows an authorized user to have an overview of the cyborgs on the station."
	power_usage = 500
	circuit_type = /obj/item/circuitboard/robotics
	id = 0
	var/perma = 0

	light_r =0.85
	light_g = 0.86
	light_b = 1

	New()
		..()
		START_TRACKING

	disposing()
		..()
		STOP_TRACKING

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
			"ais" = silicons[1],
			"cyborgs" = silicons[2],
			"ghostdrones" = src.update_ghostdrone_statuses()
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("start_ai_killswitch")
				var/obj/item/card/id/I = usr.equipped()
				if (istype(I))
					if(src.check_access(I))
						var/mob/living/silicon/ai/ai_player = locate(params["mob_ref"])
						if (QDELETED(ai_player))
							return
						var/mob/message = ai_player.get_message_mob()
						message_admins(SPAN_ALERT("[key_name(usr)] has activated the AI self destruct on [key_name(message)]."))
						logTheThing(LOG_COMBAT, usr, "has activated the AI killswitch process on [constructTarget(message,"combat")]")
						if(message.client)
							boutput(message, SPAN_ALERT("<b>AI Killswitch process activated.</b>"))
							boutput(message, SPAN_ALERT("<b>Killswitch will engage in 3 minutes.</b>"))
						ai_player.killswitch = TRUE
						ai_player.killswitch_at = TIME + 3 MINUTES
					else
						boutput(usr, SPAN_ALERT("Access Denied."))
				return TRUE
			if ("stop_ai_killswitch")
				var/mob/living/silicon/ai/ai_player = locate(params["mob_ref"])
				if (QDELETED(ai_player))
					return
				ai_player.killswitch_at = 0
				ai_player.killswitch = FALSE
				var/mob/message = ai_player.get_message_mob()
				message_admins(SPAN_ALERT("[key_name(usr)] has stopped the AI self destruct on [key_name(message, 1, 1)]."))
				logTheThing(LOG_COMBAT, usr, "has stopped the AI killswitch process on [constructTarget(message,"combat")].")
				if(message.client)
					boutput(message, SPAN_NOTICE("<b>Killswitch process deactivated.</b>"))
				return TRUE
			if ("start_silicon_killswitch")
				var/obj/item/card/id/I = usr.equipped()
				if (istype(I))
					if(src.check_access(I))
						var/mob/living/silicon/robot/robot = locate(params["mob_ref"])
						if (QDELETED(robot))
							return
						message_admins(SPAN_ALERT("[key_name(usr)] has activated the robot self destruct on [key_name(robot)]."))
						logTheThing(LOG_COMBAT, usr, "has activated the robot killswitch process on [constructTarget(robot,"combat")]")
						if(robot.client)
							boutput(robot, SPAN_ALERT("<b>Killswitch process activated.</b>"))
							boutput(robot, SPAN_ALERT("<b>Killswitch will engage in 1 minute.</b>"))
						robot.killswitch = TRUE
						robot.killswitch_at = TIME + 1 MINUTE
					else
						boutput(usr, SPAN_ALERT("Access Denied."))
				return TRUE
			if ("stop_silicon_killswitch")
				var/mob/living/silicon/robot/robot = locate(params["mob_ref"])
				if (QDELETED(robot))
					return
				robot.killswitch_at = 0
				robot.killswitch = FALSE
				message_admins(SPAN_ALERT("[key_name(usr)] has stopped the robot self destruct on [key_name(robot, 1, 1)]."))
				logTheThing(LOG_COMBAT, usr, "has stopped the robot killswitch process on [constructTarget(robot,"combat")].")
				if(robot.client)
					boutput(robot, SPAN_NOTICE("<b>Killswitch process deactivated.</b>"))
				return TRUE
			if ("start_silicon_lock")
				var/mob/living/silicon/robot/robot = locate(params["mob_ref"])
				if (QDELETED(robot))
					return
				if(robot.client)
					if (robot.emagged)
						boutput(robot, SPAN_NOTICE("<b>Weapon Lock signal blocked!</b>"))
						return
					boutput(robot, SPAN_ALERT("<b>Weapon Lock activated!</b>"))
				robot.weapon_lock = TRUE
				robot.weaponlock_time = 120
				robot.uneq_active()
				logTheThing(LOG_COMBAT, usr, "has activated [constructTarget(robot,"combat")]'s weapon lock (120 seconds).")
				for (var/obj/item/roboupgrade/upgrade in robot.contents)
					if (upgrade.activated)
						upgrade.activated = FALSE
						boutput(robot, SPAN_ALERT("<b>[upgrade] was shut down by the Weapon Lock!</b>"))
					if (istype(upgrade, /obj/item/roboupgrade/jetpack))
						robot.jetpack = FALSE
				return TRUE
			if ("stop_silicon_lock")
				var/mob/living/silicon/robot/robot = locate(params["mob_ref"])
				if (QDELETED(robot))
					return
				if(robot.emagged)
					return
				if(robot.client)
					boutput(robot, "Weapon Lock deactivated.")
				robot.weapon_lock = FALSE
				robot.weaponlock_time = 120
				logTheThing(LOG_COMBAT, usr, "has deactivated [constructTarget(robot, "combat")]'s weapon lock.")
				return TRUE
			if ("killswitch_ghostdrone")
				var/obj/item/card/id/I = usr.equipped()
				var/mob/living/silicon/ghostdrone/drone = locate(params["mob_ref"])
				if (QDELETED(drone))
					return
				if(src.check_access(I))
					message_admins(SPAN_ALERT("[key_name(usr)] killswitched drone [key_name(drone)]."))
					logTheThing(LOG_COMBAT, usr, "killswitched drone [constructTarget(drone,"combat")]")
					if(drone.client)
						boutput(drone, SPAN_ALERT("<b>Killswitch activated.</b>"))
					drone.gib()
				else
					boutput(usr, SPAN_ALERT("Access Denied."))
				return TRUE

/obj/machinery/computer/robotics/attackby(obj/item/I, user)
	if (perma && isscrewingtool(I))
		boutput(user, SPAN_ALERT("The screws are all weird safety-bit types! You can't turn them!"))
		return
	..()
	return

/obj/machinery/computer/robotics/special_deconstruct(obj/computerframe/frame as obj, mob/user)
	logTheThing(LOG_STATION, src, "is deconstructed by [key_name(user)] at [log_loc(src)]")
	frame.circuit.id = src.id

/obj/machinery/computer/robotics/proc/update_silicon_statuses()
	var/list/ais = list()
	var/list/cyborgs = list()

	for_by_tcl(A, /mob/living/silicon/ai)
		ais += list("name" = A.name,
					"mob_ref" = "\ref[A]",
					"status" = A.stat ? "ERROR: Not Responding!" : "Operating Normally",
					"killswitch_time" = A.killswitch ? round((A.killswitch_at - TIME) / 10, 1) : null
					)

		var/robot_status
		for(var/mob/living/silicon/robot/R in A.connected_robots)
			if(QDELETED(R))
				continue

			if(isnull(R.part_head?.brain))
				robot_status = "Intelligence Cortex Missing"
			else if(R.stat)
				robot_status = "Not Responding"
			else
				robot_status = "Operating Normally"

			cyborgs += list("name" = R.name,
							"mob_ref" = "\ref[R]",
							"status" = robot_status,
							"cell_charge" = R.cell?.charge,
							"cell_maxcharge" = R.cell?.maxcharge,
							"module" = R.module?.name,
							"lock_time" = R.weapon_lock ? round(R.weaponlock_time, 1) : null,
							"killswitch_time" = R.killswitch ? round((R.killswitch_at - TIME) / 10, 1) : null
							)

	return list(ais, cyborgs)

/obj/machinery/computer/robotics/proc/update_ghostdrone_statuses()
	var/list/ghostdrones = list()
	for_by_tcl(drone, /mob/living/silicon/ghostdrone)
		if(!drone.last_ckey || isdead(drone))
			continue
		ghostdrones += list("name" = drone.name, "mob_ref" = "\ref[drone]")
	return ghostdrones
