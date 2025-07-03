// Powersink - used to drain station power
#define POWERSINK_OFF 0
#define POWERSINK_CLAMPED 1
#define POWERSINK_OPERATING 2

TYPEINFO(/obj/item/device/powersink)
	mats = list("metal_dense" = 20,
				"conductive_high" = 20,
				"crystal" = 10)
/obj/item/device/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = W_CLASS_BULKY
	flags = TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	m_amt = 750
	w_amt = 750
	deconstruct_flags = DECON_DESTRUCT
	var/drain_rate = 400000		// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 2e8		// maximum power that can be drained before exploding
	var/mode = POWERSINK_OFF		// 0 = off, 1=clamped (off), 2=operating
	is_syndicate = 1
	rand_pos = 0
	HELP_MESSAGE_OVERRIDE({"To anchor the powersink, use a <b>screwdriver</b> on it while it is on exposed wiring. To turn the powersink on/off click it with an empty hand."})

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
			src.add_fingerprint(user)
			if(mode == POWERSINK_OFF)
				var/turf/T = loc
				if(isturf(T) && !T.intact)
					attached = locate() in T
					if(!attached)
						boutput(user, "No exposed cable here to attach to.")
						return
					else
						anchored = ANCHORED
						mode = POWERSINK_CLAMPED
						boutput(user, "You attach the device to the cable.")
						message_ghosts("<b>[src]</b> has been activated at [log_loc(src, ghostjump=TRUE)].")
						for(var/mob/M in AIviewers(user))
							if(M == user) continue
							boutput(M, "[user] attaches the power sink to the cable.")
						return
				else
					boutput(user, "Device must be placed over an exposed cable to attach to it.")
					return
			else
				if(attached && mode == POWERSINK_OPERATING) //give back some charge when disconnected
					var/datum/powernet/PN = attached.get_powernet()
					if(PN)
						for(var/obj/machinery/power/terminal/T in PN.nodes)
							if(istype(T.master, /obj/machinery/power/apc))
								var/obj/machinery/power/apc/A = T.master
								if(A.operating && A.cell)
									var/charge_amt = max(0, A.cell.maxcharge/5 - A.cell.charge)
									if(power_drained > charge_amt * 5)
										power_drained -= charge_amt * 5
										A.cell.charge += charge_amt

				anchored = UNANCHORED
				mode = POWERSINK_OFF
				boutput(user, "You detach the device from the cable.")
				for(var/mob/M in AIviewers(user))
					if(M == user) continue
					boutput(M, "[user] detaches the power sink from the cable.")
				light.disable()
				icon_state = "powersink0"
				processing_items.Remove(src)
				logTheThing(LOG_STATION, user, "deactivated [src] at [log_loc(src)].")
				return
		else
			..()

	attack_ai()
		return

	attack_hand(var/mob/user)
		switch(mode)
			if(POWERSINK_OFF)
				..()

			if(POWERSINK_CLAMPED)
				boutput(user, "You activate the device!")
				for(var/mob/M in AIviewers(user))
					if(M == user) continue
					boutput(M, "[user] activates the power sink!")
				mode = POWERSINK_OPERATING
				icon_state = "powersink1"
				processing_items |= src
				logTheThing(LOG_STATION, user, "activated [src] at [log_loc(src)].")
				message_admins("[key_name(user)] activated [src] at [log_loc(src)].")

	process()
		if(attached)
			var/datum/powernet/PN = attached.get_powernet()
			if(PN)
				light.enable()


				// found a powernet, so drain up to max power from it

				var/drained = min ( drain_rate, (PN.avail - PN.newload) )
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
				playsound(src, 'sound/effects/screech.ogg', 50, TRUE, 1)
			if(power_drained >= max_power)
				processing_items.Remove(src)
				explosion(src, src.loc, 3,6,9,12)
				qdel(src)

#undef POWERSINK_OFF
#undef POWERSINK_CLAMPED
#undef POWERSINK_OPERATING
