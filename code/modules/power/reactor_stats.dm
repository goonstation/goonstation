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

	/* generator data */
	src.teg_data += sample_teg()
	if (length(src.teg_data) > src.history_max)
		src.teg_data.Cut(1, 2) //drop the oldest entry

	/* sample combustion chamber gasses */
	var/list/chamber_raw_data = list()
	for(var/turf/simulated/S in chamber_turfs)
		chamber_raw_data += sample_air(S.air, 0)

	/* process combustion chamber samples */
	chamber_data = sample_chamber(chamber_raw_data)

	/* get meter data */
	for(var/obj/machinery/power/stats_meter/M in meters)
		if (!M.target || !M.tag)
			continue

		var/list/T = sample_air(M.target.return_air(), 1)
		M.set_bars(T["thermal_energy"])
		T["tag"] = M.tag
		meter_data += T

/obj/machinery/power/reactor_stats/proc/sample_chamber(list/L)
	. = list()

	for (var/sample in L)
		.["o2_sum"] += sample["o2"]
		.["toxins_sum"] += sample["toxins"]
		.["co2_sum"] += sample["co2"]
		.["n2_sum"] += sample["n2"]
		.["pressure_sum"] += sample["pressure"]
		.["temp_sum"] += sample["temp"]
		.["burnt_sum"] += sample["burnt"]
		.["heat_capacity_sum"] += sample["heat_capacity"]
		.["thermal_energy_sum"] += sample["thermal_energy"]
		.["moles_sum"] += sample["moles"]
		.["n20_sum"] += sample["n20"]
		.["o2_b_sum"] += sample["o2_b"]
		.["fuel_sum"] += sample["fuel"]
		.["rad_sum"] += sample["rad"]

/obj/machinery/power/reactor_stats/proc/sample_air(var/datum/gas_mixture/G, var/ARCHIVED(no))
	. = list()

	if(ARCHIVED(no))
		if(G.oxygen) .["o2"] = G.oxygen
		if(G.toxins) .["toxins"] = G.toxins
		if(G.carbon_dioxide) .["co2"] = G.carbon_dioxide
		if(G.nitrogen) .["n2"] = G.nitrogen

		.["pressure"] = MIXTURE_PRESSURE(G)
		.["temp"] = G.temperature
		.["burnt"] = G.fuel_burnt
		.["heat_capacity"] = HEAT_CAPACITY(G)
		.["thermal_energy"] = THERMAL_ENERGY(G)
		.["moles"] = TOTAL_MOLES(G)

		if(length(G.trace_gases))
			for(var/datum/gas/T as anything in G.trace_gases)
				if(istype(T, /datum/gas/sleeping_agent))
					.["n2o"] = T.moles
				else if(istype(T, /datum/gas/oxygen_agent_b))
					.["o2_b"] = T.moles
				else if(istype(T, /datum/gas/volatile_fuel))
					.["fuel"] = T.moles
				else
					.["rad"] = T.moles

	else
		if(G?.ARCHIVED(oxygen)) .["o2"] = G.ARCHIVED(oxygen)
		if(G?.ARCHIVED(toxins)) .["toxins"] = G.ARCHIVED(toxins)
		if(G?.ARCHIVED(carbon_dioxide)) .["co2"] = G.ARCHIVED(carbon_dioxide)
		if(G?.ARCHIVED(nitrogen)) .["n2"] = G.ARCHIVED(nitrogen)

		if (G) //sorry, this was still somehow causing runtimes????
			.["pressure"] = MIXTURE_PRESSURE(G)
			.["temp"] = G.ARCHIVED(temperature)
			.["burnt"] = G.fuel_burnt
			.["heat_capacity"] = HEAT_CAPACITY_ARCHIVED(G)
			.["thermal_energy"] = THERMAL_ENERGY(G)
			.["moles"] = TOTAL_MOLES(G)

		if(G && length(G.trace_gases))
			for(var/datum/gas/T as anything in G.trace_gases)
				if(istype(T, /datum/gas/sleeping_agent))
					.["n2o"] = T.ARCHIVED(moles)
				else if(istype(T, /datum/gas/oxygen_agent_b))
					.["o2_b"] = T.ARCHIVED(moles)
				else if(istype(T, /datum/gas/volatile_fuel))
					.["fuel"] = T.ARCHIVED(moles)
				else
					.["rad"] = T.ARCHIVED(moles)


/obj/machinery/power/reactor_stats/proc/sample_teg()
	. = list()

	.["output"] = teg.lastgen
	.["hot_temp_in"] = teg_hot.air1?.temperature
	.["hot_temp_out"] = teg_hot.air2?.temperature
	.["hot_pressure_in"] = teg_hot.air1 ? MIXTURE_PRESSURE(teg_hot.air1) : 0
	.["hot_pressure_out"] = teg_hot.air2 ? MIXTURE_PRESSURE(teg_hot.air2) : 0
	.["cold_temp_in"] = teg_cold.air1?.temperature
	.["cold_temp_out"] = teg_cold.air2?.temperature
	.["cold_pressure_in"] = teg_cold.air1 ? MIXTURE_PRESSURE(teg_cold.air1) : 0
	.["cold_pressure_out"] = teg_cold.air2 ? MIXTURE_PRESSURE(teg_cold.air2) : 0

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
