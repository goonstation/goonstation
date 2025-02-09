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

	var/list/ai_names = list()
	var/list/ai_statuses = list()
	var/list/ai_killswitch_times = list()

	var/list/cyborg_names = list()
	var/list/cyborg_statuses = list()
	var/list/cyborg_cell_charges = list()
	var/list/cyborg_modules = list()
	var/list/cyborg_lock_times = list()
	var/list/cyborg_killswitch_times = list()

	var/list/ghostdrone_names = list()

	var/list/tracked_cyborgs = list()

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
		src.update_silicon_statuses()
		src.update_ghostdrone_statuses()
		. = list(
			"user_is_ai" = isAI(user),
			"user_is_cyborg" = isrobot(user),
			"ai_names" = src.ai_names,
			"ai_statuses" = src.ai_statuses,
			"ai_killswitch_times" = src.ai_killswitch_times,
			"cyborg_names" = src.cyborg_names,
			"cyborg_statuses" = src.cyborg_statuses,
			"cyborg_cell_charges" = src.cyborg_cell_charges,
			"cyborg_modules" = src.cyborg_modules,
			"cyborg_lock_times" = src.cyborg_lock_times,
			"cyborg_killswitch_times" = src.cyborg_killswitch_times,
			"ghostdrone_names" = src.ghostdrone_names
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		. = TRUE
		switch (action)
			if ("start_ai_killswitch")
				var/obj/item/card/id/I = usr.equipped()
				if (istype(I))
					if(src.check_access(I))
						var/mob/living/silicon/ai/ai_player = by_type[/mob/living/silicon/ai][params["index"]]
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
			if ("stop_ai_killswitch")
				var/mob/living/silicon/ai/ai_player = by_type[/mob/living/silicon/ai][params["index"]]
				ai_player.killswitch_at = 0
				ai_player.killswitch = FALSE
				var/mob/message = ai_player.get_message_mob()
				message_admins(SPAN_ALERT("[key_name(usr)] has stopped the AI self destruct on [key_name(message, 1, 1)]."))
				logTheThing(LOG_COMBAT, usr, "has stopped the AI killswitch process on [constructTarget(message,"combat")].")
				if(message.client)
					boutput(message, SPAN_NOTICE("<b>Killswitch process deactivated.</b>"))

			if ("start_silicon_killswitch")
				var/obj/item/card/id/I = usr.equipped()
				if (istype(I))
					if(src.check_access(I))
						var/mob/living/silicon/robot/robot = src.tracked_cyborgs[params["index"]]
						message_admins(SPAN_ALERT("[key_name(usr)] has activated the robot self destruct on [key_name(robot)]."))
						logTheThing(LOG_COMBAT, usr, "has activated the robot killswitch process on [constructTarget(robot,"combat")]")
						if(robot.client)
							boutput(robot, SPAN_ALERT("<b>Killswitch process activated.</b>"))
							boutput(robot, SPAN_ALERT("<b>Killswitch will engage in 1 minute.</b>"))
						robot.killswitch = TRUE
						robot.killswitch_at = TIME + 1 MINUTE
					else
						boutput(usr, SPAN_ALERT("Access Denied."))
			if ("stop_silicon_killswitch")
				var/mob/living/silicon/robot/robot = src.tracked_cyborgs[params["index"]]
				robot.killswitch_at = 0
				robot.killswitch = FALSE
				message_admins(SPAN_ALERT("[key_name(usr)] has stopped the robot self destruct on [key_name(robot, 1, 1)]."))
				logTheThing(LOG_COMBAT, usr, "has stopped the robot killswitch process on [constructTarget(robot,"combat")].")
				if(robot.client)
					boutput(robot, SPAN_NOTICE("<b>Killswitch process deactivated.</b>"))
			if ("start_silicon_lock")
				var/mob/living/silicon/robot/robot = src.tracked_cyborgs[params["index"]]
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
			if ("stop_silicon_lock")
				var/mob/living/silicon/robot/robot = src.tracked_cyborgs[params["index"]]
				if(robot.emagged)
					return
				if(robot.client)
					boutput(robot, "Weapon Lock deactivated.")
				robot.weapon_lock = FALSE
				robot.weaponlock_time = 120
				logTheThing(LOG_COMBAT, usr, "has deactivated [constructTarget(robot, "combat")]'s weapon lock.")
			if ("killswitch_ghostdrone")
				var/obj/item/card/id/I = usr.equipped()
				var/mob/living/silicon/ghostdrone/drone = by_type[/mob/living/silicon/ghostdrone][params["index"]]
				if (istype(drone))
					if(src.check_access(I))
						message_admins(SPAN_ALERT("[key_name(usr)] killswitched drone [key_name(drone)]."))
						logTheThing(LOG_COMBAT, usr, "killswitched drone [constructTarget(drone,"combat")]")
						if(drone.client)
							boutput(drone, SPAN_ALERT("<b>Killswitch activated.</b>"))
						drone.gib()
					else
						boutput(usr, SPAN_ALERT("Access Denied."))

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
	src.ai_names = list()
	src.ai_statuses = list()
	src.ai_killswitch_times = list()

	src.cyborg_names = list()
	src.cyborg_statuses = list()
	src.cyborg_cell_charges = list()
	src.cyborg_modules = list()
	src.cyborg_lock_times = list()
	src.cyborg_killswitch_times = list()

	src.tracked_cyborgs = list()

	for_by_tcl(A, /mob/living/silicon/ai)
		src.ai_names += A.name
		if (A.stat)
			src.ai_statuses += "ERROR: Not Responding!"
		else
			src.ai_statuses += "Operating Normally"

		if (A.killswitch)
			var/timeleft = round((A.killswitch_at - TIME)/10, 1)
			timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
			src.ai_killswitch_times += timeleft
		else
			src.ai_killswitch_times += null

		for(var/mob/living/silicon/robot/R in A.connected_robots)
			if(QDELETED(R))
				continue
			src.tracked_cyborgs += R
			src.cyborg_names += R.name

			if(isnull(R.part_head?.brain))
				src.cyborg_statuses += "Intelligence Cortex Missing"
			else if(R.stat)
				src.cyborg_statuses += "Not Responding"
			else
				src.cyborg_statuses += "Operating Normally"

			if(R.cell)
				src.cyborg_cell_charges += "Battery Installed ([R.cell.charge]/[R.cell.maxcharge])"
			else
				src.cyborg_cell_charges += "No Cell Installed"

			if(R.module)
				src.cyborg_modules += "Module Installed ([R.module.name])"
			else
				src.cyborg_modules += "No Module Installed"

			if(!R.weapon_lock)
				src.cyborg_lock_times += null
			else
				var/timeleft = round(R.weaponlock_time, 1)
				timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
				src.cyborg_lock_times += timeleft

			if (!R.killswitch)
				src.cyborg_killswitch_times += null
			else
				var/timeleft = round((R.killswitch_at - TIME)/10, 1)
				timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
				src.cyborg_killswitch_times += timeleft

/obj/machinery/computer/robotics/proc/update_ghostdrone_statuses()
	src.ghostdrone_names = list()
	for_by_tcl(drone, /mob/living/silicon/ghostdrone)
		if(!drone.last_ckey || isdead(drone))
			continue
		src.ghostdrone_names += drone.name
