// Powersink - used to drain station power

/obj/item/device/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = 4.0
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	m_amt = 750
	w_amt = 750
	var/drain_rate = 400000		// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 2e8		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating
	is_syndicate = 1
	mats = 16
	rand_pos = 0

	var/obj/cable/attached		// the attached cable
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(2)
		light.set_height(0.5)
		light.attach(src)

	attackby(var/obj/item/I, var/mob/user)
		if (isscrewingtool(I))
			if(mode == 0)
				var/turf/T = loc
				if(isturf(T) && !T.intact)
					attached = locate() in T
					if(!attached)
						boutput(user, "No exposed cable here to attach to.")
						return
					else
						anchored = 1
						mode = 1
						boutput(user, "You attach the device to the cable.")
						for(var/mob/M in AIviewers(user))
							if(M == user) continue
							boutput(M, "[user] attaches the power sink to the cable.")
						return
				else
					boutput(user, "Device must be placed over an exposed cable to attach to it.")
					return
			else
				anchored = 0
				mode = 0
				boutput(user, "You detach	the device from the cable.")
				for(var/mob/M in AIviewers(user))
					if(M == user) continue
					boutput(M, "[user] detaches the power sink from the cable.")
				light.disable()
				icon_state = "powersink0"
				processing_items.Remove(src)
				logTheThing("combat", user, src, "deactivated [src] at [log_loc(src)].")
				return
		else
			..()

	attack_ai()
		return

	attack_hand(var/mob/user)
		switch(mode)
			if(0)
				..()

			if(1)
				boutput(user, "You activate the device!")
				for(var/mob/M in AIviewers(user))
					if(M == user) continue
					boutput(M, "[user] activates the power sink!")
				mode = 2
				icon_state = "powersink1"
				processing_items |= src
				logTheThing("combat", user, src, "activated [src] at [log_loc(src)].")
				message_admins("[key_name(user)] activated [src] at [log_loc(src)].")

	process()
		if(attached)
			var/datum/powernet/PN = attached.get_powernet()
			if(PN)
				light.enable()


				// found a powernet, so drain up to max power from it

				var/drained = min ( drain_rate, PN.avail )
				PN.newload += drained
				power_drained += drained

				// if tried to drain more than available on powernet
				// now look for APCs and drain their cells
				if(drained < drain_rate)
					for(var/obj/machinery/power/terminal/T in PN.nodes)
						if(istype(T.master, /obj/machinery/power/apc))
							var/obj/machinery/power/apc/A = T.master
							if(A.operating && A.cell)
								A.cell.charge = max(0, A.cell.charge - 50)
								power_drained += 50


			if(power_drained > max_power * 0.95)
				playsound(src, "sound/effects/screech.ogg", 100, 1, 1)
			if(power_drained >= max_power)
				processing_items.Remove(src)
				explosion(src, src.loc, 3,6,9,12)
				qdel(src)
