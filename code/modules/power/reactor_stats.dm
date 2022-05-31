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

	var/list/master_meter_datapoints[][][] = list()

	var/list/meter_metrics[][][] = list()

	var/list/chamber_data[][] = list()
	var/list/meter_samples[] = list()
	var/list/teg_data[][] = list()
	var/hold = 1
	var/refresh = 1
	var/power = 0

	var/const/history_max = 50

	initialize()
		src.first()
		return

	process()
		if(!power) return
		if(hold)
			if(teg.lastgen) hold = 0
			return

		if(..()) return

		chamber_data = list()
		meter_samples = list()

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

		/* sample loop gasses from sensors */
		for(var/obj/machinery/power/stats_meter/M in meters)
			if (!M.target || !M.tag)
				continue
			var/list/T[] = sample_air(M.target.return_air(), 1)
			M.set_bars(T["thermal_energy"])
			T["tag"] = M.tag
			meter_samples[++meter_samples.len] = T




		/* process meter samples */
		for(var/M in src.meter_samples)
			if (M) process_meter(M["tag"], M)

		if(refresh)
			src.updateUsrDialog()

	proc
		first()
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


		sample_chamber(list/L)
			var/list/chamber_sums = list()

			for (var/sample in L)
				chamber_sums["o2_sum"] += sample["o2"]
				chamber_sums["toxins_sum"] += sample["toxins"]
				chamber_sums["co2_sum"] += sample["co2"]
				chamber_sums["n2_sum"] += sample["n2"]
				chamber_sums["pressure_sum"] += sample["pressure"]
				chamber_sums["temp_sum"] += sample["temp"]
				chamber_sums["burnt_sum"] += sample["burnt"]
				chamber_sums["heat_capacity_sum"] += sample["heat_capacity"]
				chamber_sums["thermal_energy_sum"] += sample["thermal_energy"]
				chamber_sums["moles_sum"] += sample["moles"]
				chamber_sums["n20_sum"] += sample["n20"]
				chamber_sums["o2_b_sum"] += sample["o2_b"]
				chamber_sums["fuel_sum"] += sample["fuel"]
				chamber_sums["rad_sum"] += sample["rad"]

			return chamber_sums

		process_meter(var/p_tag, var/list/L)
			master_meter_datapoints["[p_tag]"][++master_meter_datapoints["[p_tag]"].len] = L
			if(master_meter_datapoints["[p_tag]"].len == 1) return

			var/list/m_metric = list()
			var/last = master_meter_datapoints["[p_tag]"].len - 1

			m_metric["index"] = last + 1
			m_metric["tag"] = p_tag


			if(meter_metrics["[p_tag]"].len == 0)
				meter_metrics["[p_tag]"][++meter_metrics["[p_tag]"].len] = m_metric
				return

			last = length(meter_metrics["[p_tag]"])

			meter_metrics["[p_tag]"][++meter_metrics["[p_tag]"].len] = m_metric

		sample_air(var/datum/gas_mixture/G, var/ARCHIVED(no))
			var/list/ret = list()

			if(ARCHIVED(no))
				if(G.oxygen) ret["o2"] = G.oxygen
				if(G.toxins) ret["toxins"] = G.toxins
				if(G.carbon_dioxide) ret["co2"] = G.carbon_dioxide
				if(G.nitrogen) ret["n2"] = G.nitrogen

				ret["pressure"] = MIXTURE_PRESSURE(G)
				ret["temp"] = G.temperature
				ret["burnt"] = G.fuel_burnt
				ret["heat_capacity"] = HEAT_CAPACITY(G)
				ret["thermal_energy"] = THERMAL_ENERGY(G)
				ret["moles"] = TOTAL_MOLES(G)

				if(length(G.trace_gases))
					for(var/datum/gas/T as anything in G.trace_gases)
						if(istype(T, /datum/gas/sleeping_agent))
							ret["n2o"] = T.moles
						else if(istype(T, /datum/gas/oxygen_agent_b))
							ret["o2_b"] = T.moles
						else if(istype(T, /datum/gas/volatile_fuel))
							ret["fuel"] = T.moles
						else
							ret["rad"] = T.moles

			else
				if(G?.ARCHIVED(oxygen)) ret["o2"] = G.ARCHIVED(oxygen)
				if(G?.ARCHIVED(toxins)) ret["toxins"] = G.ARCHIVED(toxins)
				if(G?.ARCHIVED(carbon_dioxide)) ret["co2"] = G.ARCHIVED(carbon_dioxide)
				if(G?.ARCHIVED(nitrogen)) ret["n2"] = G.ARCHIVED(nitrogen)

				if (G) //sorry, this was still somehow causing runtimes????
					ret["pressure"] = MIXTURE_PRESSURE(G)
					ret["temp"] = G.ARCHIVED(temperature)
					ret["burnt"] = G.fuel_burnt
					ret["heat_capacity"] = HEAT_CAPACITY_ARCHIVED(G)
					ret["thermal_energy"] = THERMAL_ENERGY(G)
					ret["moles"] = TOTAL_MOLES(G)

				if(G && length(G.trace_gases))
					for(var/datum/gas/T as anything in G.trace_gases)
						if(istype(T, /datum/gas/sleeping_agent))
							ret["n2o"] = T.ARCHIVED(moles)
						else if(istype(T, /datum/gas/oxygen_agent_b))
							ret["o2_b"] = T.ARCHIVED(moles)
						else if(istype(T, /datum/gas/volatile_fuel))
							ret["fuel"] = T.ARCHIVED(moles)
						else
							ret["rad"] = T.ARCHIVED(moles)

			return ret

		sample_teg()
			var/list/ret = list()

			ret["output"] = teg.lastgen
			ret["hot_temp_in"] = teg_hot.air1?.temperature
			ret["hot_temp_out"] = teg_hot.air2?.temperature
			ret["hot_pressure_in"] = teg_hot.air1 ? MIXTURE_PRESSURE(teg_hot.air1) : 0
			ret["hot_pressure_out"] = teg_hot.air2 ? MIXTURE_PRESSURE(teg_hot.air2) : 0
			ret["cold_temp_in"] = teg_cold.air1?.temperature
			ret["cold_temp_out"] = teg_cold.air2?.temperature
			ret["cold_pressure_in"] = teg_cold.air1 ? MIXTURE_PRESSURE(teg_cold.air1) : 0
			ret["cold_pressure_out"] = teg_cold.air2 ? MIXTURE_PRESSURE(teg_cold.air2) : 0

			return ret

		avg_samples(var/list/L)
			var/list/ret = list()

			/* boy howdy this is ugly */
			ret["o2"] = 0
			ret["toxins"] = 0
			ret["co2"] = 0
			ret["n2"] = 0
			ret["pressure"] = 0
			ret["temp"] = 0
			ret["burnt"] = 0
			ret["heat_capacity"] = 0
			ret["thermal_energy"] = 0
			ret["moles"] = 0
			ret["n20"] = 0
			ret["o2_b"] = 0
			ret["fuel"] = 0
			ret["rad"] = 0

			ret["o2_c"] = 0
			ret["toxins_c"] = 0
			ret["co2_c"] = 0
			ret["n2_c"] = 0
			ret["pressure_c"] = 0
			ret["temp_c"] = 0
			ret["burnt_c"] = 0
			ret["heat_capacity_c"] = 0
			ret["thermal_energy_c"] = 0
			ret["moles_c"] = 0
			ret["n20_c"] = 0
			ret["o2_b_c"] = 0
			ret["fuel_c"] = 0
			ret["rad_c"] = 0

			ret["o2_sum"] = 0
			ret["toxins_sum"] = 0
			ret["co2_sum"] = 0
			ret["n2_sum"] = 0
			ret["pressure_sum"] = 0
			ret["temp_sum"] = 0
			ret["burnt_sum"] = 0
			ret["heat_capacity_sum"] = 0
			ret["thermal_energy_sum"] = 0
			ret["moles_sum"] = 0
			ret["n20_sum"] = 0
			ret["o2_b_sum"] = 0
			ret["fuel_sum"] = 0
			ret["rad_sum"] = 0

			for(var/M in L)
				if(M["o2"])
					ret["o2"] += M["o2"]
					ret["o2_sum"] += M["o2"]
					ret["o2_c"]++
				if(M["toxins"])
					ret["toxins"] += M["toxins"]
					ret["toxins_sum"] += M["toxins"]
					ret["toxins_c"]++
				if(M["co2"])
					ret["co2"] += M["co2"]
					ret["co2_sum"] += M["co2"]
					ret["co2_c"]++
				if(M["n2"])
					ret["n2"] += M["n2"]
					ret["n2_sum"] += M["n2"]
					ret["n2_c"]++
				if(M["pressure"])
					ret["pressure"] += M["pressure"]
					ret["pressure_sum"] += M["pressure"]
					ret["pressure_c"]++
				if(M["temp"])
					ret["temp"] += M["temp"]
					ret["temp_sum"] += M["temp"]
					ret["temp_c"]++
				if(M["burnt"])
					ret["burnt"] += M["burnt"]
					ret["burnt_sum"] += M["burnt"]
					ret["burnt_c"]++
				if(M["heat_capacity"])
					ret["heat_capacity"] += M["heat_capacity"]
					ret["heat_capacity_sum"] += M["heat_capacity"]
					ret["heat_capacity_c"]++
				if(M["thermal_energy"])
					ret["thermal_energy"] += M["thermal_energy"]
					ret["thermal_energy_sum"] += M["thermal_energy"]
					ret["thermal_energy_c"]++
				if(M["moles"])
					ret["moles"] += M["moles"]
					ret["moles_sum"] += M["moles"]
					ret["moles_c"]++
				if(M["n20"])
					ret["n20"] += M["n20"]
					ret["n20_sum"] += M["n20"]
					ret["n20_c"]++
				if(M["o2_b"])
					ret["o2_b"] += M["o2_b"]
					ret["o2_b_sum"] += M["o2_b"]
					ret["o2_b_c"]++
				if(M["fuel"])
					ret["fuel"] += M["fuel"]
					ret["fuel_sum"] += M["fuel"]
					ret["fuel_c"]++
				if(M["rad"])
					ret["rad"] += M["rad"]
					ret["rad_sum"] += M["rad"]
					ret["rad_c"]++

			if(ret["o2_c"]) ret["o2"] /= ret["o2_c"]
			if(ret["toxins_c"]) ret["toxins"] /= ret["toxins_c"]
			if(ret["co2_c"]) ret["co2"] /= ret["co2_c"]
			if(ret["n2_c"]) ret["n2"] /= ret["n2_c"]
			if(ret["pressure_c"]) ret["pressure"] /= ret["pressure_c"]
			if(ret["temp_c"]) ret["temp"] /= ret["temp_c"]
			if(ret["burnt_c"]) ret["burnt"] /= ret["burnt_c"]
			if(ret["heat_capacity_c"]) ret["heat_capacity"] /= ret["heat_capacity_c"]
			if(ret["thermal_energy_c"]) ret["thermal_energy"] /= ret["thermal_energy_c"]
			if(ret["moles_c"]) ret["moles"] /= ret["moles_c"]
			if(ret["n20_c"]) ret["n20"] /= ret["n20_c"]
			if(ret["o2_b_c"]) ret["o2_b"] /= ret["o2_b_c"]
			if(ret["fuel_c"]) ret["fuel"] /= ret["fuel_c"]
			if(ret["rad_c"]) ret["rad"] /= ret["rad_c"]

			return ret

		get_chamber_turfs()
			var/list/ret = list()

			for(var/turf/simulated/T in get_area_turfs("/area/station/engine/combustion_chamber"))
				if(!istype(T, /turf/space))
					ret.Add(T)

			return ret

		get_teg()
			for(var/T in get_area_all_atoms("/area/station/engine/core"))
				if(istype(T, /obj/machinery/power/generatorTemp))
					return T

		get_meters()
			var/area_path = null
			var/list/area_contents = list()
			var/list/ret = list()

			area_path = "/area/station/engine"

			area_contents = get_area_all_atoms(area_path)
			for(var/obj/O in area_contents)
				if(istype(O, /obj/machinery/power/stats_meter))
					ret.Add(O)
					O.overlays += ("red_overlay")
					master_meter_datapoints["[O.tag]"] = list()
					meter_metrics["[O.tag]"] = list()

			#ifdef DEBUG_COMP
			for(var/obj/machinery/atmospherics/pipe/simple/O in area_contents)
				O.can_rupture = 0

			for(var/obj/machinery/atmospherics/valve/O in area_contents)
				if(!findtext(O.name, "purge") && !findtext(O.name, "release"))
					O.open()

			for(var/obj/machinery/portable_atmospherics/canister/toxins/O in area_contents)
				O.air_contents.volume = 1000000
				O.air_contents.toxins = (O.maximum_pressure*O.filled)*O.air_contents.volume/(R_IDEAL_GAS_EQUATION*O.air_contents.temperature)
				O.pressure_resistance = INFINITY
				O.temperature_resistance = INFINITY
				O.UpdateIcon()

			for(var/obj/machinery/portable_atmospherics/canister/oxygen/O in area_contents)
				O.air_contents.volume = 1000000
				O.air_contents.oxygen = (O.maximum_pressure*O.filled)*O.air_contents.volume/(R_IDEAL_GAS_EQUATION*O.air_contents.temperature)
				O.pressure_resistance = INFINITY
				O.temperature_resistance = INFINITY
				O.UpdateIcon()

			#endif

			return ret


		gen_loops_page(var/p_tag as text)
			var/ret = ""
			if(p_tag == "") return

			var/list/cur_metric = meter_metrics["[p_tag]"][meter_metrics["[p_tag]"].len]
			var/list/disc_sample = master_meter_datapoints["[p_tag]"][cur_metric["index"]]

			ret += {"<div class="center">"}
			ret += {"<table class="rs_table"><caption>[p_tag] - instantaneous</caption><tr><th>data id</th><th>now</th><th>dy/dx</th><th>d<sup>2</sup>y/dx<sup>2</sup></th></tr>"}
			ret += {"
				<tr><td class="y_label">oxygen</td>
				<td>[disc_sample["o2"]]</td>
				<td>[cur_metric["o2_dx"]]</td>
				<td>[cur_metric["o2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">plasma</td>
				<td>[disc_sample["toxins"]]</td>
				<td>[cur_metric["toxins_dx"]]</td>
				<td>[cur_metric["toxins_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">carbon dioxide</td>
				<td>[disc_sample["co2"]]</td>
				<td>[cur_metric["co2_dx"]]</td>
				<td>[cur_metric["co2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">nitrogen</td>
				<td>[disc_sample["n2"]]</td>
				<td>[cur_metric["n2_dx"]]</td>
				<td>[cur_metric["n2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">temperature</td>
				<td>[disc_sample["temp"]]</td>
				<td>[cur_metric["temp_dx"]]</td>
				<td>[cur_metric["temp_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">fuel burnt</td>
				<td>[disc_sample["burnt"]]</td>
				<td>[cur_metric["burnt_dx"]]</td>
				<td>[cur_metric["burnt_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">pressure</td>
				<td>[disc_sample["pressure"]]</td>
				<td>[cur_metric["pressure_dx"]]</td>
				<td>[cur_metric["pressure_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">thermal energy</td>
				<td>[disc_sample["thermal_energy"]]</td>
				<td>[cur_metric["thermal_energy_dx"]]</td>
				<td>[cur_metric["thermal_energy_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">heat capacity</td>
				<td>[disc_sample["heat_capacity"]]</td>
				<td>[cur_metric["heat_capacity_dx"]]</td>
				<td>[cur_metric["heat_capacity_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">molarity</td>
				<td>[disc_sample["moles"]]</td>
				<td>[cur_metric["moles_dx"]]</td>
				<td>[cur_metric["moles_d2x"]]</td>
				</tr>
			"}
			ret += {"</table>"}

			ret += {"</table></div>"}

			return ret


/obj/machinery/power/reactor_stats/attack_hand(mob/user as mob)

	if(!hold)
		// switch(src.curpage)
		// 	if(1) tab.innerHtml = src.gen_reactor_page()
		// 	if(2) tab.innerHtml = src.gen_chamber_page()
		// 	if(3)
		// 		for(var/obj/machinery/power/stats_meter/T in meters)
		// 			tab.innerHtml += src.gen_loops_page("[T.tag]")


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
	)

/obj/machinery/power/reactor_stats/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch(action)

		if("set-file")
			boutput(world, "cat")
