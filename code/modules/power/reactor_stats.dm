/* reactor statistics computer for nerds. by kremlin */
/obj/machinery/power/reactor_stats
	name = "Engine Statistics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "reactor_stats"
	desc = "A powerful supercomputer used to model the generator and provide corresponding statistical analysis"
	density = TRUE
	anchored = ANCHORED
	flags = TGUI_INTERACTIVE

	var/list/chamber_turfs[] = list()
	var/list/meters[] = list()
	var/obj/machinery/power/generatorTemp/teg = null
	var/obj/machinery/atmospherics/binary/circulatorTemp/teg_hot = null
	var/obj/machinery/atmospherics/binary/circulatorTemp/right/teg_cold = null

	var/list/chamber_data[][] = list()
	//var/list/meter_data[][] = list()
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
	if (length(src.chamber_data) > src.history_max)
		src.chamber_data.Cut(1, 2) //drop the oldest entry

	/* get meter data */
	// Too much of a pain to format this data for the graphs.
	// Feel free to do it yourself.

	// for(var/obj/machinery/power/stats_meter/M in meters)
	// 	if (!M.target || !M.tag)
	// 		continue

	// 	var/list/sample = sample_air(M.target.return_air(), TRUE)
	// 	M.set_bars(sample["Thermal Energy|J"])
	// 	sample["tag"] = M.tag
	// 	meter_data += list(sample)


// I apologise for the terrible crimes i have comitted in this file by appending the SI units to the literal stats string
// It'd've been extremely messy otherwise on the UI end.

/obj/machinery/power/reactor_stats/proc/sample_chamber(list/L)
	. = list()

	for (var/sample in L)
		var/list/to_add = list()
		to_add["Oxygen|mols"] += sample["Oxygen|mols"]
		to_add["Plasma|mols"] += sample["Plasma|mols"]
		to_add["Carbon Dioxide|mols"] += sample["Carbon Dioxide|mols"]
		to_add["Nitrogen|mols"] += sample["Nitrogen|mols"]
		to_add["Pressure|Pa"] += sample["Pressure|Pa"]
		to_add["Temperature|K"] += sample["Temperature|K"]
		to_add["Fuel Burnt|units"] += sample["Fuel Burnt|units"]
		to_add["Heat Capacity|J/K"] += sample["Heat Capacity|J/K"]
		to_add["Thermal Energy|J"] += sample["Thermal Energy|J"]
		to_add["Total Moles|moles"] += sample["Total Moles|moles"]
		to_add["Nitrous Oxide|mols"] += sample["Nitrous Oxide|mols"]
		to_add["Oxygen Agent B|mols"] += sample["Oxygen Agent B|mols"]
		. += list(to_add)

/obj/machinery/power/reactor_stats/proc/sample_air(var/datum/gas_mixture/G, var/not_archived)
	. = list()

	if(not_archived)
		if(G.oxygen) .["Oxygen|mols"] = G.oxygen
		if(G.toxins) .["Plasma|mols"] = G.toxins
		if(G.carbon_dioxide) .["Carbon Dioxide|mols"] = G.carbon_dioxide
		if(G.nitrogen) .["Nitrogen|mols"] = G.nitrogen

		.["Pressure|Pa"] = MIXTURE_PRESSURE(G) KILO PASCALS
		.["Temperature|K"] = G.temperature
		.["Fuel Burnt|units"] = G.fuel_burnt
		.["Heat Capacity|J/K"] = HEAT_CAPACITY(G)
		.["Thermal Energy|J"] = THERMAL_ENERGY(G)
		.["Total Moles|moles"] = TOTAL_MOLES(G)

		if(length(G.trace_gases))
			for(var/datum/gas/T as anything in G.trace_gases)
				if(istype(T, /datum/gas/sleeping_agent))
					.["Nitrous Oxide|mols"] = T.moles
				else if(istype(T, /datum/gas/oxygen_agent_b))
					.["Oxygen Agent B|mols"] = T.moles
				// else
				// 	.["Other Gasses|mols"] = T.moles

	else
		if(G?.ARCHIVED(oxygen)) .["Oxygen|mols"] = G.ARCHIVED(oxygen)
		if(G?.ARCHIVED(toxins)) .["Plasma|mols"] = G.ARCHIVED(toxins)
		if(G?.ARCHIVED(carbon_dioxide)) .["Carbon Dioxide|mols"] = G.ARCHIVED(carbon_dioxide)
		if(G?.ARCHIVED(nitrogen)) .["Nitrogen|mols"] = G.ARCHIVED(nitrogen)

		if (G) //sorry, this was still somehow causing runtimes????
			.["Pressure|Pa"] = MIXTURE_PRESSURE(G) KILO PASCALS
			.["Temperature|K"] = G.ARCHIVED(temperature)
			.["Fuel Burnt|units"] = G.fuel_burnt
			.["Heat Capacity|J/K"] = HEAT_CAPACITY_ARCHIVED(G)
			.["Thermal Energy|J"] = THERMAL_ENERGY(G)
			.["Total Moles|moles"] = TOTAL_MOLES(G)

		if(G && length(G.trace_gases))
			for(var/datum/gas/T as anything in G.trace_gases)
				if(istype(T, /datum/gas/sleeping_agent))
					.["Nitrous Oxide|mols"] = T.ARCHIVED(moles)
				else if(istype(T, /datum/gas/oxygen_agent_b))
					.["Oxygen Agent B|mols"] = T.ARCHIVED(moles)
				// else
				// 	.["Other Gasses|mols"] = T.ARCHIVED(moles)


/obj/machinery/power/reactor_stats/proc/sample_teg()
	. = list()

	.["Output|W"] = teg.lastgen
	.["Temperature In (Hot)|K"] = teg_hot.air1?.temperature
	.["Temperature Out (Hot)|K"] = teg_hot.air2?.temperature
	.["Pressure In (Hot)|Pa"] = teg_hot.air1 ? MIXTURE_PRESSURE(teg_hot.air1) KILO PASCALS : 0
	.["Pressure Out (Hot)|Pa"] = teg_hot.air2 ? MIXTURE_PRESSURE(teg_hot.air2) KILO PASCALS : 0
	.["Temperature In (Cold)|K"] = teg_cold.air1?.temperature
	.["Temperature Out (Cold)|K"] = teg_cold.air2?.temperature
	.["Pressure In (Cold)|Pa"] = teg_cold.air1 ? MIXTURE_PRESSURE(teg_cold.air1) KILO PASCALS : 0
	.["Pressure Out (Cold)|Pa"] = teg_cold.air2 ? MIXTURE_PRESSURE(teg_cold.air2) KILO PASCALS : 0

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

/obj/machinery/power/reactor_stats/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/power/reactor_stats/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EngineStats")
		ui.open()

/obj/machinery/power/reactor_stats/ui_data(mob/user)
	. = list(
		"turnedOn" = power,
		"tegData" = teg_data,
		"chamberData" = chamber_data,
		// "meterData" = meter_data,
	)

/obj/machinery/power/reactor_stats/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch(action)
		if("toggle-power")
			power = !power
			if(power)
				for(var/obj/machinery/power/stats_meter/M in meters)
					M.overlays -= ("red_overlay")
					M.overlays += ("green_overlay")

			else
				for(var/obj/machinery/power/stats_meter/M in meters)
					M.overlays -= ("green_overlay")
					M.overlays += ("red_overlay")
			return TRUE
