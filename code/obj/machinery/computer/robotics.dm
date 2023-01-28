/obj/machinery/computer/robotics
	name = "Robotics Control"
	icon = 'icons/obj/computer.dmi'
	icon_state = "robotics"
	req_access = list(access_robotics)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	desc = "A computer that allows an authorized user to have an overview of the cyborgs on the station."
	power_usage = 500
	circuit_type = /obj/item/circuitboard/robotics
	id = 0
	var/perma = 0

	light_r =0.85
	light_g = 0.86
	light_b = 1


/obj/machinery/computer/robotics/attackby(obj/item/I, user)
	if (perma && isscrewingtool(I))
		boutput(user, "<span class='alert'>The screws are all weird safety-bit types! You can't turn them!</span>")
		return
	..()
	return

/obj/machinery/computer/robotics/special_deconstruct(obj/computerframe/frame as obj)
	frame.circuit.id = src.id

/obj/machinery/computer/robotics/process()
	..()
	if(status & (NOPOWER|BROKEN))
		return
	src.updateDialog()
	return


/obj/machinery/computer/robotics/attack_hand(var/mob/user)
	if(..())
		return
	src.add_dialog(user)
	var/list/dat = list("Located AI Units<BR><BR>")
	for_by_tcl(A, /mob/living/silicon/ai)
		dat += "[A.name] |"
		if(A.stat)
			dat += "ERROR: Not Responding!<BR>"
		else
			dat += "Operating Normally<BR>"

		if(!isrobot(user)&&!ishivebot(user))
			//if(!A.weapon_lock)
				//dat += "<A href='?src=\ref[src];lock=1;ai=\ref[A]'>Emergency Lockout AI *Swipe ID*</A><BR>"
			//else
				//dat += "Time left:[A.weaponlock_time] | "
				//dat += "<A href='?src=\ref[src];lock=2;ai=\ref[A]'>Cancel Lockout</A><BR>"

			if(!A.killswitch)
				dat += "<A href='?src=\ref[src];gib=1;ai=\ref[A]'>Kill Switch AI *Swipe ID*</A><BR>"
			else
				var/timeleft = round((A.killswitch_at - TIME)/10, 1)
				timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
				dat += "Time left:[timeleft]"
				if (!isAI(user))
					dat += " | <A href='?src=\ref[src];gib=2;ai=\ref[A]'>Cancel</A>"
				dat += "<BR>"

		dat += "<BR> Connected Cyborgs<BR>"
		dat += " *------------------------------------------------*<BR>"

		for(var/mob/living/silicon/robot/R in A.connected_robots)
			dat += "[R.name] |"
			if(R.disposed)
				dat += " Missing |"
			else if(isnull(R.part_head?.brain))
				dat += " Intelligence Cortex Missing |"
			else if(R.stat)
				dat += " Not Responding |"
			else
				dat += " Operating Normally |"
			if(R.cell)
				dat += " Battery Installed ([R.cell.charge]/[R.cell.maxcharge]) |"
			else
				dat += " No Cell Installed |"
			if(R.module)
				dat += " Module Installed ([R.module.name]) |"
			else
				dat += " No Module Installed |"
			dat += "<BR>"
			if(isAI(user))
				if(user == A || user == A.eyecam)
					if(!R.weapon_lock)
						dat += "<A href='?src=\ref[src];lock=1;bot=\ref[R]'>Lockdown Bot</A><BR>"
					else
						dat += "Time left:[R.weaponlock_time] | "
						dat += "<A href='?src=\ref[src];lock=2;bot=\ref[R]'>Cancel Lockdown</A><BR>"
			else if(!isrobot(user)&&!ishivebot(user))
				if(!R.killswitch)
					dat += "<A href='?src=\ref[src];gib=1;bot=\ref[R]'>Kill Switch *Swipe ID*</A><BR>"
				else
					var/timeleft = round((R.killswitch_at - TIME)/10, 1)
					timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
					dat += "Time left:[timeleft] | "
					dat += "<A href='?src=\ref[src];gib=2;bot=\ref[R]'>Cancel</A><BR>"
			dat += "*----------*<BR>"

	var/found_drones = FALSE
	for_by_tcl(drone, /mob/living/silicon/ghostdrone)
		if(!drone.last_ckey || isdead(drone))
			continue
		if(!found_drones)
			dat += "*----------*<BR><BR>"
			dat += "Ghostdrones:<BR>"
			found_drones = TRUE
		dat += "[drone] <A href='?src=\ref[src];gib=drone;bot=\ref[drone]'>Kill Switch *Swipe ID*</A><BR>"

	user.Browse(dat.Join(), "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/robotics/Topic(href, href_list)
	if(..())
		return
	if(isghostdrone(usr))
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

	var/mob/living/silicon/robot/R = locate(href_list["bot"])
	var/mob/living/silicon/ai/A = locate(href_list["ai"])

	if (href_list["gib"])
		switch(href_list["gib"])
			if("drone")
				var/obj/item/card/id/I = usr.equipped()
				var/mob/living/silicon/ghostdrone/drone = locate(href_list["bot"])
				if (istype(drone))
					if(src.check_access(I))
						message_admins("<span class='alert'>[key_name(usr)] killswitched drone [key_name(drone)].</span>")
						logTheThing(LOG_COMBAT, usr, "killswitched drone [constructTarget(drone,"combat")]")
						if(drone.client)
							boutput(drone, "<span class='alert'><b>Killswitch activated.</b></span>")
						drone.gib()
					else
						boutput(usr, "<span class='alert'>Access Denied.</span>")

			if("1")
				var/obj/item/card/id/I = usr.equipped()
				if (istype(I))
					if(src.check_access(I))
						if(istype(R))
							message_admins("<span class='alert'>[key_name(usr)] has activated the robot self destruct on [key_name(R)].</span>")
							logTheThing(LOG_COMBAT, usr, "has activated the robot killswitch process on [constructTarget(R,"combat")]")
							if(R.client)
								boutput(R, "<span class='alert'><b>Killswitch process activated.</b></span>")
								boutput(R, "<span class='alert'><b>Killswitch will engage in 1 minute.</b></span>")
							R.killswitch = TRUE
							R.killswitch_at = TIME + 1 MINUTE
						else if(istype(A))
							var/mob/message = A.get_message_mob()
							message_admins("<span class='alert'>[key_name(usr)] has activated the AI self destruct on [key_name(message)].</span>")
							logTheThing(LOG_COMBAT, usr, "has activated the AI killswitch process on [constructTarget(message,"combat")]")
							if(message.client)
								boutput(message, "<span class='alert'><b>AI Killswitch process activated.</b></span>")
								boutput(message, "<span class='alert'><b>Killswitch will engage in 3 minutes.</b></span>")
							A.killswitch = TRUE
							A.killswitch_at = TIME + 3 MINUTES
					else
						boutput(usr, "<span class='alert'>Access Denied.</span>")

			if("2")
				if(istype(R))
					R.killswitch_at = 0
					R.killswitch = 0
					message_admins("<span class='alert'>[key_name(usr)] has stopped the robot self destruct on [key_name(R, 1, 1)].</span>")
					logTheThing(LOG_COMBAT, usr, "has stopped the robot killswitch process on [constructTarget(R,"combat")].")
					if(R.client)
						boutput(R, "<span class='notice'><b>Killswitch process deactivated.</b></span>")
				else if(istype(A))
					A.killswitch_at = 0
					A.killswitch = 0
					var/mob/message = A.get_message_mob()
					message_admins("<span class='alert'>[key_name(usr)] has stopped the AI self destruct on [key_name(message, 1, 1)].</span>")
					logTheThing(LOG_COMBAT, usr, "has stopped the AI killswitch process on [constructTarget(message,"combat")].")
					if(message.client)
						boutput(message, "<span class='notice'><b>Killswitch process deactivated.</b></span>")


	if (href_list["lock"])
		switch(href_list["lock"])
			if("1")
				if(istype(R))
					if(R.client)
						if (R.emagged)
							boutput(R, "<span class='notice'><b>Weapon Lock signal blocked!</b></span>")
							return
						boutput(R, "<span class='alert'><b>Weapon Lock activated!</b></span>")
					R.weapon_lock = 1
					R.weaponlock_time = 120
					R.uneq_active()
					logTheThing(LOG_COMBAT, usr, "has activated [constructTarget(R,"combat")]'s weapon lock (120 seconds).")
					for (var/obj/item/roboupgrade/X in R.contents)
						if (X.activated)
							X.activated = 0
							boutput(R, "<b><span class='alert'>[X] was shut down by the Weapon Lock!</span></b>")
						if (istype(X, /obj/item/roboupgrade/jetpack))
							R.jetpack = 0
				else if(istype(A))
					var/obj/item/card/id/I = usr.equipped()
					if (istype(I))
						if(src.check_access(I))
							var/mob/message = A.get_message_mob()
							if(message.client)
								boutput(message, "<span class='alert'><b>Emergency lockout activated!</b></span>")
								A.weapon_lock = 1
								A.weaponlock_time = 120
								logTheThing(LOG_COMBAT, usr, "has activated [constructTarget(message,"combat")]'s weapon lock (120 seconds).")
					else
						boutput(usr, "<span class='alert'>Access Denied.</span>")

			if("2")
				if(istype(R))
					if(R.emagged) return
					if(R.client)
						boutput(R, "Weapon Lock deactivated.")
					R.weapon_lock = 0
					R.weaponlock_time = 120
					logTheThing(LOG_COMBAT, usr, "has deactivated [constructTarget(R,"combat")]'s weapon lock.")

				else if(istype(A))
					var/mob/message = A.get_message_mob()
					if(message.client)
						boutput(message, "Emergency lockout deactivated.")
					A.weapon_lock = 0
					A.weaponlock_time = 120
					logTheThing(LOG_COMBAT, usr, "has deactivated [constructTarget(message,"combat")]'s weapon lock.")

	src.updateUsrDialog()
	return
