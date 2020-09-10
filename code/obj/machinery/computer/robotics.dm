/obj/machinery/computer/robotics
	name = "Robotics Control"
	icon = 'icons/obj/computer.dmi'
	icon_state = "robotics"
	req_access = list(access_robotics)
	object_flags = CAN_REPROGRAM_ACCESS
	desc = "A computer that allows an authorized user to have an overview of the cyborgs on the station."
	power_usage = 500

	var/id = 0.0
	var/perma = 0

	lr = 0.85
	lg = 0.86
	lb = 1


/obj/machinery/computer/robotics/attackby(obj/item/I as obj, user as mob)
	if (isscrewingtool(I))
		if (perma)
			boutput(user, "<span class='alert'>The screws are all weird safety-bit types! You can't turn them!</span>")
			return
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user, 20))
			if (src.status & BROKEN)
				boutput(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(src.loc)
				var/obj/item/circuitboard/robotics/M = new /obj/item/circuitboard/robotics( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/circuitboard/robotics/M = new /obj/item/circuitboard/robotics( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)

	else
		src.attack_hand(user)
	return

/obj/machinery/computer/robotics/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/robotics/process()
	..()
	if(status & (NOPOWER|BROKEN))
		return
	use_power(250)
	src.updateDialog()
	return


/obj/machinery/computer/robotics/attack_hand(var/mob/user as mob)
	if(..())
		return
	src.add_dialog(user)
	var/dat = "Located AI Units<BR><BR>"
	for(var/mob/living/silicon/ai/A in by_type[/mob/living/silicon/ai])
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
				dat += "Time left:[A.killswitch_time]"
				if (!isAI(user))
					dat += " | <A href='?src=\ref[src];gib=2;ai=\ref[A]'>Cancel</A>"
				dat += "<BR>"

		dat += "<BR> Connected Cyborgs<BR>"
		dat += " *------------------------------------------------*<BR>"

		for(var/mob/living/silicon/robot/R in A:connected_robots)
			dat += "[R.name] |"
			if(R.stat)
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
					dat += "Time left:[R.killswitch_time] | "
					dat += "<A href='?src=\ref[src];gib=2;bot=\ref[R]'>Cancel</A><BR>"
			dat += "*----------*<BR>"

	user.Browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/robotics/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

	var/mob/living/silicon/robot/R = locate(href_list["bot"])
	var/mob/living/silicon/ai/A = locate(href_list["ai"])

	if (href_list["gib"])
		switch(href_list["gib"])
			if("1")
				var/obj/item/card/id/I = usr.equipped()
				if (istype(I))
					if(src.check_access(I))
						if(istype(R))
							message_admins("<span class='alert'>[key_name(usr)] has activated the robot self destruct on [key_name(R)].</span>")
							logTheThing("combat", usr, R, "has activated the robot killswitch process on [constructTarget(R,"combat")]")
							if(R.client)
								boutput(R, "<span class='alert'><b>Killswitch process activated.</b></span>")
							R.killswitch = 1
							R.killswitch_time = 60
						else if(istype(A))
							var/mob/message = A.get_message_mob()
							message_admins("<span class='alert'>[key_name(usr)] has activated the AI self destruct on [key_name(message)].</span>")
							logTheThing("combat", usr, message, "has activated the AI killswitch process on [constructTarget(message,"combat")]")
							if(message.client)
								boutput(message, "<span class='alert'><b>AI Killswitch process activated.</b></span>")
								boutput(message, "<span class='alert'><b>Killswitch will engage in 60 seconds.</b></span>") // more like 180 really but whatever
							A.killswitch = 1
							A.killswitch_time = 60
					else
						boutput(usr, "<span class='alert'>Access Denied.</span>")

			if("2")
				if(istype(R))
					R.killswitch_time = 60
					R.killswitch = 0
					message_admins("<span class='alert'>[key_name(usr)] has stopped the robot self destruct on [key_name(R, 1, 1)].</span>")
					logTheThing("combat", usr, R, "has stopped the robot killswitch process on [constructTarget(R,"combat")].")
					if(R.client)
						boutput(R, "<span class='notice'><b>Killswitch process deactivated.</b></span>")
				else if(istype(A))
					A.killswitch_time = 60
					A.killswitch = 0
					var/mob/message = A.get_message_mob()
					message_admins("<span class='alert'>[key_name(usr)] has stopped the AI self destruct on [key_name(message, 1, 1)].</span>")
					logTheThing("combat", usr, message, "has stopped the AI killswitch process on [constructTarget(message,"combat")].")
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
					logTheThing("combat", usr, R, "has activated [constructTarget(R,"combat")]'s weapon lock (120 seconds).")
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
								logTheThing("combat", usr, message, "has activated [constructTarget(message,"combat")]'s weapon lock (120 seconds).")
					else
						boutput(usr, "<span class='alert'>Access Denied.</span>")

			if("2")
				if(istype(R))
					if(R.emagged) return
					if(R.client)
						boutput(R, "Weapon Lock deactivated.")
					R.weapon_lock = 0
					R.weaponlock_time = 120
					logTheThing("combat", usr, R, "has deactivated [constructTarget(R,"combat")]'s weapon lock.")

				else if(istype(A))
					var/mob/message = A.get_message_mob()
					if(message.client)
						boutput(message, "Emergency lockout deactivated.")
					A.weapon_lock = 0
					A.weaponlock_time = 120
					logTheThing("combat", usr, message, "has deactivated [constructTarget(message,"combat")]'s weapon lock.")

	src.updateUsrDialog()
	return
