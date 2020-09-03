/obj/machinery/portable_atmospherics/pump
	name = "Portable Air Pump"

	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "psiphon:0"
	density = 1
	mats = 12
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER
	var/on = 0
	var/direction_out = 0 //0 = siphoning, 1 = releasing
	var/target_pressure = 100
	desc = "A device which can siphon or release gasses."

	volume = 750

/obj/machinery/portable_atmospherics/pump/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "psiphon:1"
	else
		icon_state = "psiphon:0"

	return

/obj/machinery/portable_atmospherics/pump/process()
	..()
	if (!loc) return
	if (src.contained) return

	var/datum/gas_mixture/environment
	if(holding)
		environment = holding.air_contents
	else
		environment = loc.return_air()


	if(on)
		if(direction_out)
			var/pressure_delta = target_pressure - MIXTURE_PRESSURE(environment)
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(air_contents.temperature > 0)
				transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				if(holding)
					environment.merge(removed)
				else
					loc.assume_air(removed)
		else
			var/pressure_delta = target_pressure - MIXTURE_PRESSURE(air_contents)
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(environment.temperature > 0)
				transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed
				if(holding)
					removed = environment.remove(transfer_moles)
				else
					removed = loc.remove_air(transfer_moles)

				air_contents.merge(removed)

		src.updateDialog()
	src.update_icon()
	return

/obj/machinery/portable_atmospherics/pump/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/pump/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/atmosporter))
		var/obj/item/atmosporter/porter = W
		if (porter.contents.len >= porter.capacity) boutput(user, "<span class='alert'>Your [W] is full!</span>")
		else if (src.anchored) boutput(user, "<span class='alert'>\The [src] is attached!</span>")
		else
			user.visible_message("<span class='notice'>[user] collects the [src].</span>", "<span class='notice'>You collect the [src].</span>")
			src.contained = 1
			src.set_loc(W)
			elecflash(user)
	..()

/obj/machinery/portable_atmospherics/pump/attack_ai(var/mob/user as mob)
	if(!src.connected_port && get_dist(src, user) > 7)
		return
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/pump/attack_hand(var/mob/user as mob)

	src.add_dialog(user)
	var/holding_text

	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [MIXTURE_PRESSURE(holding.air_contents)] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B><BR>
Pressure: [MIXTURE_PRESSURE(air_contents)] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Power Switch: <A href='?src=\ref[src];power=1'>[on?("On"):("Off")]</A><BR>
Pump Direction: <A href='?src=\ref[src];direction=1'>[direction_out?("Out"):("In")]</A><BR>
Target Pressure: <A href='?src=\ref[src];pressure_adj=-100'>-</A> <A href='?src=\ref[src];pressure_adj=-10'>-</A> <A href='?src=\ref[src];pressure_set=1'>[target_pressure]</A> <A href='?src=\ref[src];pressure_adj=10'>+</A> <A href='?src=\ref[src];pressure_adj=100'>+</A><BR>
<HR>
<A href='?action=mach_close&window=pump'>Close</A><BR>
"}

	user.Browse(output_text, "window=pump;size=600x300")
	onclose(user, "pump")

	return

/obj/machinery/portable_atmospherics/pump/Topic(href, href_list)
	if(..())
		return
	if (usr.stat || usr.restrained())
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		src.add_dialog(usr)

		if(href_list["power"])
			on = !on
			if (src.direction_out)
				if (src.on)
					message_admins("[key_name(usr)] turns on [src], pumping its contents into the air at [log_loc(src)]. See station logs for atmos readout.")
					logTheThing("station", usr, null, "turns on [src] [log_atmos(src)], pumping its contents into the air at [log_loc(src)].")
				else
					logTheThing("station", usr, null, "turns off [src] [log_atmos(src)], stopping it from pumping its contents into the air at [log_loc(src)].")

		if(href_list["direction"])
			direction_out = !direction_out

		if (href_list["remove_tank"])
			if(holding)
				holding.set_loc(loc)
				usr.put_in_hand_or_eject(holding) // try to eject it into the users hand, if we can
				holding = null
			if (src.on && src.direction_out)
				message_admins("[key_name(usr)] removed a tank from [src], pumping its contents into the air at [log_loc(src)]. See station logs for atmos readout.")
				logTheThing("station", usr, null, "removed a tank from [src] [log_atmos(src)], pumping its contents into the air at [log_loc(src)].")

		if (href_list["pressure_adj"])
			var/diff = text2num(href_list["pressure_adj"])
			target_pressure = min(10*ONE_ATMOSPHERE, max(0, target_pressure+diff))

		else if (href_list["pressure_set"])
			var/change = input(usr,"Target Pressure (0-[10*ONE_ATMOSPHERE]):","Enter target pressure",target_pressure) as num
			if(!isnum(change)) return
			target_pressure = min(10*ONE_ATMOSPHERE, max(0, change))

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr.Browse(null, "window=pump")
		return
	return
