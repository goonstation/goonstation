/obj/machinery/power/generator
	name = "generator"
	desc = "A high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 1
	density = 1

	var/obj/machinery/atmospherics/binary/circulator/circ1
	var/obj/machinery/atmospherics/binary/circulator/circ2

	var/lastgen = 0
	var/lastgenlev = -1

/obj/machinery/power/generator/New()
	..()

	SPAWN_DBG(0.5 SECONDS)
		circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,WEST)
		circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,EAST)
		if(!circ1 || !circ2)
			status |= BROKEN

		updateicon()

/obj/machinery/power/generator/proc/updateicon()
	if(status & (NOPOWER|BROKEN))
		src.UpdateOverlays(null, "power-screen")
	else
		if(lastgenlev != 0)
			src.UpdateOverlays(image('icons/obj/power.dmi', "teg-op[lastgenlev]"), "power-screen")
		else
			src.UpdateOverlays(null, "power-screen")

#define GENRATE 800		// generator output coefficient from Q

/obj/machinery/power/generator/process()

	if(!circ1 || !circ2)
		return

	var/datum/gas_mixture/hot_air = circ1.return_transfer_air()
	var/datum/gas_mixture/cold_air = circ2.return_transfer_air()

	lastgen = 0

	if(cold_air && hot_air)
		var/cold_air_heat_capacity = HEAT_CAPACITY(cold_air)
		var/hot_air_heat_capacity = HEAT_CAPACITY(hot_air)

		var/delta_temperature = hot_air.temperature - cold_air.temperature

		if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
			var/efficiency = (1 - cold_air.temperature/hot_air.temperature)*0.65 //65% of Carnot efficiency

			var/energy_transfer = delta_temperature*hot_air_heat_capacity*cold_air_heat_capacity/(hot_air_heat_capacity+cold_air_heat_capacity)

			var/heat = energy_transfer*(1-efficiency)
			lastgen = energy_transfer*efficiency

			hot_air.temperature = hot_air.temperature - energy_transfer/hot_air_heat_capacity
			cold_air.temperature = cold_air.temperature + heat/cold_air_heat_capacity


			// uncomment to debug
			// logTheThing("debug", null, null, "POWER: [lastgen] W generated at [efficiency*100]% efficiency and sinks sizes [cold_air_heat_capacity], [hot_air_heat_capacity]")

			add_avail(lastgen)
	// update icon overlays only if displayed level has changed

	if(hot_air)
		circ1.air2.merge(hot_air)

	if(cold_air)
		circ2.air2.merge(cold_air)

	var/genlev = max(0, min( round(11*lastgen / 100000), 11))
	if(genlev != lastgenlev)
		lastgenlev = genlev
		updateicon()

	src.updateDialog()

/obj/machinery/power/generator/attack_ai(mob/user)
	if(status & (BROKEN|NOPOWER)) return

	interact(user)

/obj/machinery/power/generator/attack_hand(mob/user)

	add_fingerprint(user)

	if(status & (BROKEN|NOPOWER)) return

	interact(user)

/obj/machinery/power/generator/proc/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) && (!isAI(user)))
		user.machine = null
		user << browse(null, "window=teg")
		return

	src.add_dialog(user)

	var/t = "<PRE><B>Thermo-Electric Generator</B><HR>"

	t += "Output : [round(lastgen)] W<BR><BR>"

	t += "<B>Cold loop</B><BR>"
	t += "Temperature Inlet: [round(circ1.air1.temperature, 0.1)] K  Outlet: [round(circ1.air2.temperature, 0.1)] K<BR>"
	t += "Pressure Inlet: [round(MIXTURE_PRESSURE(circ1.air1), 0.1)] kPa  Outlet: [round(MIXTURE_PRESSURE(circ1.air2), 0.1)] kPa<BR>"

	t += "<B>Hot loop</B><BR>"
	t += "Temperature Inlet: [round(circ2.air1.temperature, 0.1)] K  Outlet: [round(circ2.air2.temperature, 0.1)] K<BR>"
	t += "Pressure Inlet: [round(MIXTURE_PRESSURE(circ2.air1), 0.1)] kPa  Outlet: [round(MIXTURE_PRESSURE(circ2.air2), 0.1)] kPa<BR>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</PRE>"
	user << browse(t, "window=teg;size=460x300")
	onclose(user, "teg")
	return 1

/obj/machinery/power/generator/Topic(href, href_list)
	..()

	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.machine = null
		return 0

	return 1

/obj/machinery/power/generator/power_change()
	..()
	updateicon()

