/* reactor statistics computer for nerds. by kremlin */

/obj/machinery/power/reactor_stats
	name = "Reactor Statistics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "reactor_stats"
	desc = "A powerful supercomputer used to model the generator and provide corresponding statistical analysis"
	density = 1
	anchored = 1.0
	flags = TGUI_INTERACTIVE

	var/list/chamber_turfs[] = list()
	var/list/meters[] = list()
	var/obj/machinery/power/generatorTemp/teg = null
	var/obj/machinery/atmospherics/binary/circulatorTemp/teg_hot = null
	var/obj/machinery/atmospherics/binary/circulatorTemp/right/teg_cold = null

	var/list/chamber_data[][] = list()
	var/list/meter_data[] = list()
	var/list/teg_data[][] = list()

	var/hold = 1
	var/refresh = 1
	var/power = 0

	var/const/history_max = 50

/obj/machinery/power/reactor_stats/initialize()
	/* get all turfs in combustion chamber */
	chamber_turfs = get_chamber_turfs()

	/* get out of machine's scheduler, get in atmos_machines */
	UnsubscribeProcess()
	START_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

	/* get all of the loop meters */
	meters = get_meters()

	/* get the generator and loop circulators */
	teg = get_teg()
	teg_hot = teg.circ1
	teg_cold = teg.circ2


/obj/machinery/power/reactor_stats/process()
	if(!power) return
	if(hold)
		if(teg.lastgen) hold = 0
		return

	if(..()) return

	/* rebuilt combustion room tile list */
	chamber_turfs = get_chamber_turfs()

	/* get generator data */
	src.teg_data += list(sample_teg())
	if (length(src.teg_data) > src.history_max)
		src.teg_data.Cut(1, 2) //drop the oldest entry

	/* get combustion chamber gasses */
	var/list/chamber_raw_data = list()
	for(var/turf/simulated/S in chamber_turfs)
		chamber_raw_data += list(sample_air(S.air, FALSE))

	/* process combustion chamber samples */
	chamber_data = sample_chamber(chamber_raw_data)

	/* get meter data */
	for(var/obj/machinery/power/stats_meter/M in meters)
		if (!M.target || !M.tag)
			continue

		var/list/sample = sample_air(M.target.return_air(), TRUE)
		M.set_bars(sample["Thermal Energy"])
		sample["tag"] = M.tag
		meter_data += sample

/obj/machinery/power/reactor_stats/proc/sample_chamber(list/L)
	. = list()

	for (var/sample in L)
		var/list/to_add = list()
		to_add["Oxygen"] += sample["Oxygen"]
		to_add["Plasma"] += sample["Plasma"]
		to_add["Carbon Dioxide"] += sample["Carbon Dioxide"]
		to_add["Nitrogen"] += sample["Nitrogen"]
		to_add["Pressure"] += sample["Pressure"]
		to_add["Temperature"] += sample["Temperature"]
		to_add["Fuel Burnt"] += sample["Fuel Burnt"]
		to_add["Heat Capacity"] += sample["Heat Capacity"]
		to_add["Thermal Energy"] += sample["Thermal Energy"]
		to_add["Molarity"] += sample["Molarity"]
		to_add["Nitrous Oxide"] += sample["Nitrous Oxide"]
		to_add["Oxygen Agent B"] += sample["Oxygen Agent B"]
		to_add["Volatile Fuel"] += sample["Volatile Fuel"]
		to_add["Other Gasses"] += sample["Other Gasses"]
		. += list(to_add)

/obj/machinery/power/reactor_stats/proc/sample_air(var/datum/gas_mixture/G, var/not_archived)
	. = list()

	if(not_archived)
		if(G.oxygen) .["Oxygen"] = G.oxygen
		if(G.toxins) .["Plasma"] = G.toxins
		if(G.carbon_dioxide) .["Carbon Dioxide"] = G.carbon_dioxide
		if(G.nitrogen) .["Nitrogen"] = G.nitrogen

		.["Pressure"] = MIXTURE_PRESSURE(G)
		.["Temperature"] = G.temperature
		.["Fuel Burnt"] = G.fuel_burnt
		.["Heat Capacity"] = HEAT_CAPACITY(G)
		.["Thermal Energy"] = THERMAL_ENERGY(G)
		.["Molarity"] = TOTAL_MOLES(G)

		if(length(G.trace_gases))
			for(var/datum/gas/T as anything in G.trace_gases)
				if(istype(T, /datum/gas/sleeping_agent))
					.["Nitrous Oxide"] = T.moles
				else if(istype(T, /datum/gas/oxygen_agent_b))
					.["Oxygen Agent B"] = T.moles
				else if(istype(T, /datum/gas/volatile_fuel))
					.["Volatile Fuel"] = T.moles
				else
					.["Other Gasses"] = T.moles

	else
		if(G?.ARCHIVED(oxygen)) .["Oxygen"] = G.ARCHIVED(oxygen)
		if(G?.ARCHIVED(toxins)) .["Plasma"] = G.ARCHIVED(toxins)
		if(G?.ARCHIVED(carbon_dioxide)) .["Carbon Dioxide"] = G.ARCHIVED(carbon_dioxide)
		if(G?.ARCHIVED(nitrogen)) .["Nitrogen"] = G.ARCHIVED(nitrogen)

		if (G) //sorry, this was still somehow causing runtimes????
			.["Pressure"] = MIXTURE_PRESSURE(G)
			.["Temperature"] = G.ARCHIVED(temperature)
			.["Fuel Burnt"] = G.fuel_burnt
			.["Heat Capacity"] = HEAT_CAPACITY_ARCHIVED(G)
			.["Thermal Energy"] = THERMAL_ENERGY(G)
			.["Molarity"] = TOTAL_MOLES(G)

		if(G && length(G.trace_gases))
			for(var/datum/gas/T as anything in G.trace_gases)
				if(istype(T, /datum/gas/sleeping_agent))
					.["Nitrous Oxide"] = T.ARCHIVED(moles)
				else if(istype(T, /datum/gas/oxygen_agent_b))
					.["Oxygen Agent B"] = T.ARCHIVED(moles)
				else if(istype(T, /datum/gas/volatile_fuel))
					.["Volatile Fuel"] = T.ARCHIVED(moles)
				else
					.["Other Gasses"] = T.ARCHIVED(moles)


/obj/machinery/power/reactor_stats/proc/sample_teg()
	. = list()

	.["Output"] = teg.lastgen
	.["Temperature In (Hot)"] = teg_hot.air1?.temperature
	.["Temperature Out (Hot)"] = teg_hot.air2?.temperature
	.["Pressure In (Hot)"] = teg_hot.air1 ? MIXTURE_PRESSURE(teg_hot.air1) : 0
	.["Pressure Out (Hot)"] = teg_hot.air2 ? MIXTURE_PRESSURE(teg_hot.air2) : 0
	.["Temperature In (Cold)"] = teg_cold.air1?.temperature
	.["Temperature Out (Cold)"] = teg_cold.air2?.temperature
	.["Pressure In (Cold)"] = teg_cold.air1 ? MIXTURE_PRESSURE(teg_cold.air1) : 0
	.["Pressure Out (Cold)"] = teg_cold.air2 ? MIXTURE_PRESSURE(teg_cold.air2) : 0

/obj/machinery/power/reactor_stats/proc/get_chamber_turfs()
	. = list()

	for(var/turf/simulated/T in get_area_turfs("/area/station/engine/combustion_chamber"))
		if(!istype(T, /turf/space))
			. += T

/obj/machinery/power/reactor_stats/proc/get_teg()
	for(var/T in get_area_all_atoms("/area/station/engine/core"))
		if(istype(T, /obj/machinery/power/generatorTemp))
			return T

/obj/machinery/power/reactor_stats/proc/get_meters()
	var/area_path = null
	var/list/area_contents = list()
	. = list()

	area_path = "/area/station/engine"

	area_contents = get_area_all_atoms(area_path)
	for(var/obj/O in area_contents)
		if(istype(O, /obj/machinery/power/stats_meter))
			. += O
			O.overlays += ("red_overlay")

/obj/machinery/power/reactor_stats/attackby(obj/item/W as obj, mob/user as mob)
	src.Attackhand(user)

/obj/machinery/power/reactor_stats/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/power/reactor_stats/Topic(href, href_list)
	if(href_list["refresh_toggle"])
		if(refresh)
			refresh = 0
		else
			refresh = 1
	else if(href_list["power_toggle"])
		if(power)
			power = 0
			for(var/obj/machinery/power/stats_meter/M in meters)
				M.overlays -= ("green_overlay")
				M.overlays += ("red_overlay")
		else
			power = 1
			for(var/obj/machinery/power/stats_meter/M in meters)
				M.overlays -= ("red_overlay")
				M.overlays += ("green_overlay")

	src.updateUsrDialog()


/obj/machinery/power/reactor_stats/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReactorStats")
		ui.open()

/obj/machinery/power/reactor_stats/ui_data(mob/user)
	. = list(
		"turnedOn" = power,
		"tegData" = teg_data,
		"chamberData" = chamber_data,
		"meterData" = meter_data,
	)

/obj/machinery/power/reactor_stats/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch(action)

		if("set-file")
			boutput(world, "cat")
