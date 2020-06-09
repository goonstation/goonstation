/obj/machinery/portable_atmospherics/scrubber
	name = "Portable Air Scrubber"

	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "pscrubber:0"
	density = 1

	var/on = 0
	var/volume_rate = 800
	mats = 12
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER
	volume = 750
	desc = "A device which filters out harmful air from an area."
	p_class = 1.5


	//for smoke
	var/drain_min = 5
	var/drain_max = 12

/obj/machinery/portable_atmospherics/scrubber/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

	return

/obj/machinery/portable_atmospherics/scrubber/process()
	..()
	if (!loc) return
	if (src.contained) return

	var/datum/gas_mixture/environment
	if(holding)
		environment = holding.air_contents
	else
		environment = loc.return_air()


	if(on)

		//smoke/fluid :
		var/turf/my_turf = get_turf(src)
		if (my_turf)
			var/obj/fluid/F = my_turf.active_airborne_liquid
			if (F && F.group) //ZeWaka: Fix for null.group
				F.group.queued_drains += rand(drain_min,drain_max)
				F.group.last_drain = my_turf
				if (!F.group.draining)
					F.group.add_drain_process()



		//atmos

		var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles()

		//Take a gas sample
		var/datum/gas_mixture/removed
		if(holding)
			removed = environment.remove(transfer_moles)
		else
			removed = loc.remove_air(transfer_moles)

		//Filter it
		var/datum/gas_mixture/filtered_out = unpool(/datum/gas_mixture)
		// drsingh attempted fix for Cannot read null.temperature
		if (filtered_out && removed)
			filtered_out.temperature = removed.temperature
			filtered_out.toxins = removed.toxins
			removed.toxins = 0

			filtered_out.carbon_dioxide = removed.carbon_dioxide
			removed.carbon_dioxide = 0

			if(removed.trace_gases && removed.trace_gases.len)
				for(var/datum/gas/trace_gas in removed.trace_gases)
//					if(istype(trace_gas, /datum/gas/oxygen_agent_b))
					removed.trace_gases -= trace_gas
					if(!removed.trace_gases.len)
						removed.trace_gases = null
					if(!filtered_out.trace_gases)
						filtered_out.trace_gases = list()
					filtered_out.trace_gases += trace_gas

			//Remix the resulting gases
			air_contents.merge(filtered_out)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)

		src.updateDialog()
	src.update_icon()
	return

/obj/machinery/portable_atmospherics/scrubber/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/atmosporter))
		var/canamt = W.contents.len
		if (canamt >= W:capacity) boutput(user, "<span style=\"color:red\">Your [W] is full!</span>")
		else if (src.anchored) boutput(user, "<span style=\"color:red\">\The [src] is attached!</span>")
		else
			user.visible_message("<span style=\"color:blue\">[user] collects the [src].</span>", "<span style=\"color:blue\">You collect the [src].</span>")
			src.contained = 1
			src.set_loc(W)
			var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
			s.set_up(5, 1, user)
			s.start()
	..()


/obj/machinery/portable_atmospherics/scrubber/attack_ai(var/mob/user as mob)
	if(!src.connected_port && get_dist(src, user) > 7)
		return
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_hand(var/mob/user as mob)

	user.machine = src
	var/holding_text

	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [holding.air_contents.return_pressure()] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B><BR>
Pressure: [air_contents.return_pressure()] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Power Switch: <A href='?src=\ref[src];power=1'>[on?("On"):("Off")]</A><BR>
Target Pressure: <A href='?src=\ref[src];volume_adj=-100'>-</A> <A href='?src=\ref[src];volume_adj=-10'>-</A> <A href='?src=\ref[src];volume_set=1'>[volume_rate]</A> <A href='?src=\ref[src];volume_adj=10'>+</A> <A href='?src=\ref[src];volume_adj=100'>+</A><BR>
<HR>
<A href='?action=mach_close&window=scrubber'>Close</A><BR>
"}

	user.Browse(output_text, "window=scrubber;size=600x300")
	onclose(user, "scrubber")
	return

/obj/machinery/portable_atmospherics/scrubber/Topic(href, href_list)
	if(..())
		return
	if (usr.stat || usr.restrained())
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.machine = src

		if(href_list["power"])
			on = !on

		if (href_list["remove_tank"])
			if(holding)
				holding.set_loc(loc)
				usr.put_in_hand_or_eject(holding) // try to eject it into the users hand, if we can
				holding = null

		if (href_list["volume_adj"])
			var/diff = text2num(href_list["volume_adj"])
			volume_rate = min(10*ONE_ATMOSPHERE, max(0, volume_rate+diff))

		else if (href_list["volume_set"])
			var/change = input(usr,"Target Pressure (0-[10*ONE_ATMOSPHERE]):","Enter target pressure",volume_rate) as num
			if(!isnum(change)) return
			volume_rate = min(10*ONE_ATMOSPHERE, max(0, change))

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr.Browse(null, "window=scrubber")
		return
	return
