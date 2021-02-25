/* reactor statistics computer for nerds. by kremlin */

#define COGMAP1 /* XXX need to determine map */
#define FLOAT_HIGH 300000000000000000000000000000000000000 /* XXX */

/obj/machinery/power/reactor_stats
	name = "Reactor Statistics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "reactor_stats"
	desc = "A powerful supercomputer used to model the generator and provide corresponding statistical analysis"
	density = 1
	anchored = 1.0

	var/list/chamber_turfs[] = new/list()
	var/list/meters[] = new/list()
	var/obj/machinery/power/generatorTemp/teg = null
	var/obj/machinery/atmospherics/binary/circulatorTemp/teg_hot = null
	var/obj/machinery/atmospherics/binary/circulatorTemp/right/teg_cold = null

	var/list/master_chamber_datapoints[][] = new/list()
	var/list/master_meter_datapoints[][][] = new/list()
	var/list/master_generator_datapoints[][] = new/list()

	var/list/chamber_metrics[][] = new/list()
	var/list/meter_metrics[][][] = new/list()
	var/list/generator_metrics[][] = new/list()

	var/list/avg_chamber_words = list("o2", "toxins", "co2", "n2", "pressure", "temp", "heat_capacity", "thermal_energy", "burnt", "moles", "n20", "o2_b", "fuel", "rad", "o2_sum", "toxins_sum", "co2_sum", "n2_sum", "pressure_sum", "temp_sum", "heat_capacity_sum", "burnt_sum", "thermal_energy_sum", "moles_sum", "n20_sum", "o2_b_sum", "fuel_sum", "rad_sum")
	var/list/avg_meter_words = list("o2", "toxins", "co2", "n2", "pressure", "temp", "heat_capacity", "thermal_energy", "burnt", "moles", "n20", "o2_b", "fuel", "rad")
	var/list/avg_teg_words = list("output", "hot_temp_in", "hot_temp_out", "hot_pressure_in", "hot_pressure_out", "cold_temp_in", "cold_temp_out", "cold_pressure_in", "cold_pressure_out")
	var/list/avg_chamber[] = new/list()
	var/list/avg_meter[][] = new/list()
	var/list/avg_teg[] = new/list()

	/* XXX only for debug */
	var/list/chamber_samples[][] = new/list()
	var/list/chamber_samples_avg[] = new/list()
	var/list/meter_samples[] = new/list()
	var/list/teg_sample[] = new/list()
	var/hold = 1
	var/refresh = 1
	var/power = 0
	var/luser

	var/curpage = 1 /*1: reactor 2: combustion chamber 3: gas loops */
	var/avg_cum = 0 /* 0 if cumulative (max width), otherwise sample width */
	var/A_test_html_out = ""
	var/A_header

	initialize()
		src.first()
		return

	process()
		if(!power) return
		if(hold)
			if(teg.lastgen) hold = 0
			return

		if(..()) return

		//var/list/chamber_samples = new/list()
		//var/list/chamber_samples_avg = new/list()
		//var/list/meter_samples = new/list()
		//var/list/teg_sample = new/list()

		chamber_samples = new/list()
		chamber_samples_avg = new/list()
		meter_samples = new/list()
		teg_sample = new/list()

		/* rebuilt combustion room tile list */
		chamber_turfs = get_chamber_turfs()

		/* sample generator data */
		teg_sample = sample_teg()

		/* sample combustion chamber gasses */
		for(var/turf/simulated/S in chamber_turfs)
			chamber_samples[++chamber_samples.len] = sample_air(S.air, 0)

		/* sample loop gasses from sensors */
		for(var/obj/machinery/power/stats_meter/M in meters)
			if (!M.target)
				continue
			var/list/T[] = sample_air(M.target.return_air(), 1)
			M.set_bars(T["thermal_energy"])
			T["tag"] = M.tag
			meter_samples[++meter_samples.len] = T

		/* average combustion chamber samples */
		chamber_samples_avg = avg_samples(chamber_samples)

		/* process generator data */
		process_generator(teg_sample)

		/* process combustion chamber samples */
		process_chamber(chamber_samples_avg)

		/* process meter samples */
		for(var/M in meter_samples)
			process_meter(M["tag"], M)

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

			/* initialize average lists */
			avg_chamber["cnt"] = 0
			for(var/X in avg_chamber_words)
				avg_chamber["[X]"] = 0
				avg_chamber["[X]_dx"] = 0
				avg_chamber["[X]_d2x"] = 0

			avg_teg["cnt"] = 0
			for(var/Y in avg_teg_words)
				avg_teg["[Y]"] = 0
				avg_teg["[Y]_dx"] = 0
				avg_teg["[Y]_d2x"] = 0

			for(var/obj/machinery/power/stats_meter/T in meters)
				var/N = T.tag
				avg_meter["[N]"] = new/list()
				avg_meter["[N]"]["cnt"] = 0
				for(var/Z in avg_meter_words)
					avg_meter["[N]"]["[Z]"] = 0
					avg_meter["[N]"]["[Z]_dx"] = 0
					avg_meter["[N]"]["[Z]_d2x"] = 0

		process_generator(var/list/L)
			master_generator_datapoints[++master_generator_datapoints.len] = L
			if(master_generator_datapoints.len == 1) return

			var/list/g_metric = new/list()
			var/last = master_generator_datapoints.len - 1

			g_metric["index"] = last + 1

			g_metric["output_dx"] = L["output"] - master_generator_datapoints[last]["output"]

			g_metric["hot_temp_in_dx"] = L["hot_temp_in"] - master_generator_datapoints[last]["hot_temp_in"]
			g_metric["hot_temp_out_dx"] = L["hot_temp_out"] - master_generator_datapoints[last]["hot_temp_out"]
			g_metric["hot_pressure_in_dx"] = L["hot_pressure_in"] - master_generator_datapoints[last]["hot_pressure_in"]
			g_metric["hot_pressure_out_dx"] = L["hot_pressure_out"] - master_generator_datapoints[last]["hot_pressure_out"]

			g_metric["cold_temp_in_dx"] = L["cold_temp_in"] - master_generator_datapoints[last]["cold_temp_in"]
			g_metric["cold_temp_out_dx"] = L["cold_temp_out"] - master_generator_datapoints[last]["cold_temp_out"]
			g_metric["cold_pressure_in_dx"] = L["cold_pressure_in"] - master_generator_datapoints[last]["cold_pressure_in"]
			g_metric["cold_pressure_out_dx"] = L["cold_pressure_out"] - master_generator_datapoints[last]["cold_pressure_out"]

			avg_teg["cnt"] += 1
			avg_teg["output"] += L["output"]
			avg_teg["output_dx"] += g_metric["output_dx"]

			avg_teg["hot_temp_in"] += L["hot_temp_in"]
			avg_teg["hot_temp_in_dx"] += g_metric["hot_temp_in_dx"]
			avg_teg["hot_temp_out"] += L["hot_temp_out"]
			avg_teg["hot_temp_out_dx"] += g_metric["hot_temp_out_dx"]
			avg_teg["hot_pressure_in"] += L["hot_pressure_in"]
			avg_teg["hot_pressure_in_dx"] += g_metric["hot_pressure_in_dx"]
			avg_teg["hot_pressure_out"] += L["hot_pressure_out"]
			avg_teg["hot_pressure_out_dx"] += g_metric["hot_pressure_out_dx"]

			avg_teg["cold_temp_in"] += L["cold_temp_in"]
			avg_teg["cold_temp_in_dx"] += g_metric["cold_temp_in_dx"]
			avg_teg["cold_temp_out"] += L["cold_temp_out"]
			avg_teg["cold_temp_out_dx"] += g_metric["cold_temp_out_dx"]
			avg_teg["cold_pressure_in"] += L["cold_pressure_in"]
			avg_teg["cold_pressure_in_dx"] += g_metric["cold_pressure_in_dx"]
			avg_teg["cold_pressure_out"] += L["cold_pressure_out"]
			avg_teg["cold_pressure_out_dx"] += g_metric["cold_pressure_out_dx"]

			if(generator_metrics.len == 0)
				generator_metrics[++generator_metrics.len] = g_metric
				return

			last = generator_metrics.len

			g_metric["output_d2x"] = g_metric["output_dx"] - generator_metrics[last]["output_dx"]

			g_metric["hot_temp_in_d2x"] = g_metric["hot_temp_in_dx"] - generator_metrics[last]["hot_temp_in_dx"]
			g_metric["hot_temp_out_d2x"] = g_metric["hot_temp_out_dx"] - generator_metrics[last]["hot_temp_out_dx"]
			g_metric["hot_pressure_in_d2x"] = g_metric["hot_pressure_in_dx"] - generator_metrics[last]["hot_pressure_in_dx"]
			g_metric["hot_pressure_out_d2x"] = g_metric["hot_pressure_out_dx"] - generator_metrics[last]["hot_pressure_out_dx"]

			g_metric["cold_temp_in_d2x"] = g_metric["cold_temp_in_dx"] - generator_metrics[last]["cold_temp_in_dx"]
			g_metric["cold_temp_out_d2x"] = g_metric["cold_temp_out_dx"] - generator_metrics[last]["cold_temp_out_dx"]
			g_metric["cold_pressure_in_d2x"] = g_metric["cold_pressure_in_dx"] - generator_metrics[last]["cold_pressure_in_dx"]
			g_metric["cold_pressure_out_d2x"] = g_metric["cold_pressure_out_dx"] - generator_metrics[last]["cold_pressure_out_dx"]

			avg_teg["output_d2x"] += g_metric["output_d2x"]

			avg_teg["hot_temp_in_d2x"] += g_metric["hot_temp_in_d2x"]
			avg_teg["hot_temp_out_d2x"] += g_metric["hot_temp_out_d2x"]
			avg_teg["hot_pressure_in_d2x"] += g_metric["hot_pressure_in_d2x"]
			avg_teg["hot_pressure_out_d2x"] += g_metric["hot_pressure_out_d2x"]

			avg_teg["cold_temp_in_d2x"] += g_metric["cold_temp_in_d2x"]
			avg_teg["cold_temp_out_d2x"] += g_metric["cold_temp_out_d2x"]
			avg_teg["cold_pressure_in_d2x"] += g_metric["cold_pressure_in_d2x"]
			avg_teg["cold_pressure_out_d2x"] += g_metric["cold_pressure_out_d2x"]

			generator_metrics[++generator_metrics.len] = g_metric

		process_chamber(var/list/L)
			master_chamber_datapoints[++master_chamber_datapoints.len] = L
			if(master_chamber_datapoints.len == 1) return

			var/list/c_metric = new/list()
			var/last = master_chamber_datapoints.len - 1

			c_metric["index"] = last + 1

			/* averaged values */
			c_metric["o2_dx"] = L["o2"] - master_chamber_datapoints[last]["o2"]
			c_metric["toxins_dx"] = L["toxins"] - master_chamber_datapoints[last]["toxins"]
			c_metric["co2_dx"] = L["co2"] - master_chamber_datapoints[last]["co2"]
			c_metric["n2_dx"] = L["n2"] - master_chamber_datapoints[last]["n2"]
			c_metric["pressure_dx"] = L["pressure"] - master_chamber_datapoints[last]["pressure"]
			c_metric["temp_dx"] = L["temp"] - master_chamber_datapoints[last]["temp"]
			c_metric["burnt_dx"] = L["burnt"] - master_chamber_datapoints[last]["burnt"]
			c_metric["heat_capacity_dx"] = L["heat_capacity"] - master_chamber_datapoints[last]["heat_capacity"]
			c_metric["thermal_energy_dx"] = L["thermal_energy"] - master_chamber_datapoints[last]["thermal_energy"]
			c_metric["moles_dx"] = L["moles"] - master_chamber_datapoints[last]["moles"]
			c_metric["n20_dx"] = L["n20"] - master_chamber_datapoints[last]["n20"]
			c_metric["o2_b_dx"] = L["o2_b"] - master_chamber_datapoints[last]["o2_b"]
			c_metric["fuel_dx"] = L["fuel"] - master_chamber_datapoints[last]["fuel"]
			c_metric["rad_dx"] = L["rad"] - master_chamber_datapoints[last]["rad"]

			/* total values */
			c_metric["o2_sum_dx"] = L["o2_sum"] - master_chamber_datapoints[last]["o2_sum"]
			c_metric["toxins_sum_dx"] = L["toxins_sum"] - master_chamber_datapoints[last]["toxins_sum"]
			c_metric["co2_sum_dx"] = L["co2_sum"] - master_chamber_datapoints[last]["co2_sum"]
			c_metric["n2_sum_dx"] = L["n2_sum"] - master_chamber_datapoints[last]["n2_sum"]
			c_metric["pressure_sum_dx"] = L["pressure_sum"] - master_chamber_datapoints[last]["pressure_sum"]
			c_metric["temp_sum_dx"] = L["temp_sum"] - master_chamber_datapoints[last]["temp_sum"]
			c_metric["burnt_sum_dx"] = L["burnt_sum"] - master_chamber_datapoints[last]["burnt_sum"]
			c_metric["heat_capacity_sum_dx"] = L["heat_capacity_sum"] - master_chamber_datapoints[last]["heat_capacity_sum"]
			c_metric["thermal_energy_sum_dx"] = L["thermal_energy_sum"] - master_chamber_datapoints[last]["thermal_energy_sum"]
			c_metric["moles_sum_dx"] = L["moles_sum"] - master_chamber_datapoints[last]["moles_sum"]
			c_metric["n20_sum_dx"] = L["n20_sum"] - master_chamber_datapoints[last]["n20_sum"]
			c_metric["o2_b_sum_dx"] = L["o2_b_sum"] - master_chamber_datapoints[last]["o2_b_sum"]
			c_metric["fuel_sum_dx"] = L["fuel_sum"] - master_chamber_datapoints[last]["fuel_sum"]
			c_metric["rad_sum_dx"] = L["rad_sum"] - master_chamber_datapoints[last]["rad_sum"]

			/* include counts */
			c_metric["o2_c"] = L["o2_c"]
			c_metric["toxins_c"] = L["toxins_c"]
			c_metric["co2_c"] = L["co2_c"]
			c_metric["n2_c"] = L["n2_c"]
			c_metric["pressure_c"] = L["pressure_c"]
			c_metric["temp_c"] = L["temp_c"]
			c_metric["burnt_c"] = L["burnt_c"]
			c_metric["heat_capacity_c"] = L["heat_capacity_c"]
			c_metric["thermal_energy_c"] = L["thermal_energy_c"]
			c_metric["moles_c"] = L["moles_c"]
			c_metric["n20_c"] = L["n20_c"]
			c_metric["o2_b_c"] = L["o2_b_c"]
			c_metric["fuel_c"] = L["fuel_c"]
			c_metric["rad_c"] = L["rad_c"]

			avg_chamber["cnt"] += 1

			avg_chamber["o2"] += L["o2"]
			avg_chamber["toxins"] += L["toxins"]
			avg_chamber["co2"] += L["co2"]
			avg_chamber["n2"] += L["n2"]
			avg_chamber["pressure"] += L["pressure"]
			avg_chamber["temp"] += L["temp"]
			avg_chamber["burnt"] += L["burnt"]
			avg_chamber["heat_capacity"] += L["heat_capacity"]
			avg_chamber["thermal_energy"] += L["thermal_energy"]
			avg_chamber["moles"] += L["moles"]
			avg_chamber["n20"] += L["n20"]
			avg_chamber["o2_b"] += L["o2_b"]
			avg_chamber["fuel"] += L["fuel"]
			avg_chamber["rad"] += L["rad"]

			avg_chamber["o2_sum"] += L["o2_sum"]
			avg_chamber["toxins_sum"] += L["toxins_sum"]
			avg_chamber["co2_sum"] += L["co2_sum"]
			avg_chamber["n2_sum"] += L["n2_sum"]
			avg_chamber["pressure_sum"] += L["pressure_sum"]
			avg_chamber["temp_sum"] += L["temp_sum"]
			avg_chamber["burnt_sum"] += L["burnt_sum"]
			avg_chamber["heat_capacity_sum"] += L["heat_capacity_sum"]
			avg_chamber["thermal_energy_sum"] += L["thermal_energy_sum"]
			avg_chamber["moles_sum"] += L["moles_sum"]
			avg_chamber["n20_sum"] += L["n20_sum"]
			avg_chamber["o2_b_sum"] += L["o2_b_sum"]
			avg_chamber["fuel_sum"] += L["fuel_sum"]
			avg_chamber["rad_sum"] += L["rad_sum"]

			avg_chamber["o2_dx"] += c_metric["o2_dx"]
			avg_chamber["toxins_dx"] += c_metric["toxins_dx"]
			avg_chamber["co2_dx"] += c_metric["co2_dx"]
			avg_chamber["n2_dx"] += c_metric["n2_dx"]
			avg_chamber["pressure_dx"] += c_metric["pressure_dx"]
			avg_chamber["temp_dx"] += c_metric["temp_dx"]
			avg_chamber["burnt_dx"] += c_metric["burnt_dx"]
			avg_chamber["heat_capacity_dx"] += c_metric["heat_capacity_dx"]
			avg_chamber["thermal_energy_dx"] += c_metric["thermal_energy_dx"]
			avg_chamber["moles_dx"] += c_metric["moles_dx"]
			avg_chamber["n20_dx"] += c_metric["n20_dx"]
			avg_chamber["o2_b_dx"] += c_metric["o2_b_dx"]
			avg_chamber["fuel_dx"] += c_metric["fuel_dx"]
			avg_chamber["rad_dx"] += c_metric["rad_dx"]

			avg_chamber["o2_sum_dx"] += c_metric["o2_sum_dx"]
			avg_chamber["toxins_sum_dx"] += c_metric["toxins_sum_dx"]
			avg_chamber["co2_sum_dx"] += c_metric["co2_sum_dx"]
			avg_chamber["n2_sum_dx"] += c_metric["n2_sum_dx"]
			avg_chamber["pressure_sum_dx"] += c_metric["pressure_sum_dx"]
			avg_chamber["temp_sum_dx"] += c_metric["temp_sum_dx"]
			avg_chamber["burnt_sum_dx"] += c_metric["burnt_sum_dx"]
			avg_chamber["heat_capacity_sum_dx"] += c_metric["heat_capacity_sum_dx"]
			avg_chamber["thermal_energy_sum_dx"] += c_metric["thermal_energy_sum_dx"]
			avg_chamber["moles_sum_dx"] += c_metric["moles_sum_dx"]
			avg_chamber["n20_sum_dx"] += c_metric["n20_sum_dx"]
			avg_chamber["o2_b_sum_dx"] += c_metric["o2_b_sum_dx"]
			avg_chamber["fuel_sum_dx"] += c_metric["fuel_sum_dx"]
			avg_chamber["rad_sum_dx"] += c_metric["rad_sum_dx"]

			if(chamber_metrics.len == 0)
				chamber_metrics[++chamber_metrics.len] = c_metric
				return

			last = chamber_metrics.len

			/* averaged values */
			c_metric["o2_d2x"] = c_metric["o2_dx"] - chamber_metrics[last]["o2_dx"]
			c_metric["toxins_d2x"] = c_metric["toxins_dx"] - chamber_metrics[last]["toxins_dx"]
			c_metric["co2_d2x"] = c_metric["co2_dx"] - chamber_metrics[last]["co2_dx"]
			c_metric["n2_d2x"] = c_metric["n2_dx"] - chamber_metrics[last]["n2_dx"]
			c_metric["pressure_d2x"] = c_metric["pressure_dx"]  - chamber_metrics[last]["pressure_dx"]
			c_metric["temp_d2x"] = c_metric["temp_dx"] - chamber_metrics[last]["temp_dx"]
			c_metric["burnt_d2x"] = c_metric["burnt_dx"] - chamber_metrics[last]["burnt_dx"]
			c_metric["heat_capacity_d2x"] = c_metric["heat_capacity_dx"] - chamber_metrics[last]["heat_capacity_dx"]
			c_metric["thermal_energy_d2x"] = c_metric["thermal_energy_dx"] - chamber_metrics[last]["thermal_energy_dx"]
			c_metric["moles_d2x"] = c_metric["moles_dx"] - chamber_metrics[last]["moles_dx"]
			c_metric["n20_d2x"] = c_metric["n20_dx"] - chamber_metrics[last]["n20_dx"]
			c_metric["o2_b_d2x"] = c_metric["o2_b_dx"] - chamber_metrics[last]["o2_b_dx"]
			c_metric["fuel_d2x"] = c_metric["fuel_dx"] - chamber_metrics[last]["fuel_dx"]
			c_metric["rad_d2x"] = c_metric["rad_dx"] - chamber_metrics[last]["rad_dx"]

			/* total values */
			c_metric["o2_sum_d2x"] = L["o2_sum_dx"] - chamber_metrics[last]["o2_sum_dx"]
			c_metric["toxins_sum_d2x"] = L["toxins_sum_dx"] - chamber_metrics[last]["toxins_sum_dx"]
			c_metric["co2_sum_d2x"] = L["co2_sum_dx"] - chamber_metrics[last]["co2_sum_dx"]
			c_metric["n2_sum_d2x"] = L["n2_sum_dx"] - chamber_metrics[last]["n2_sum_dx"]
			c_metric["pressure_sum_d2x"] = L["pressure_sum_dx"] - chamber_metrics[last]["pressure_sum_dx"]
			c_metric["temp_sum_d2x"] = L["temp_sum_dx"] - chamber_metrics[last]["temp_sum_dx"]
			c_metric["burnt_sum_d2x"] = L["burnt_sum_dx"] - chamber_metrics[last]["burnt_sum_dx"]
			c_metric["heat_capacity_sum_d2x"] = L["heat_capacity_sum_dx"] - chamber_metrics[last]["heat_capacity_sum_dx"]
			c_metric["thermal_energy_sum_d2x"] = L["thermal_energy_sum_dx"] - chamber_metrics[last]["thermal_energy_sum_dx"]
			c_metric["moles_sum_d2x"] = L["moles_sum_dx"] - chamber_metrics[last]["moles_sum_dx"]
			c_metric["n20_sum_d2x"] = L["n20_sum_dx"] - chamber_metrics[last]["n20_sum_dx"]
			c_metric["o2_b_sum_d2x"] = L["o2_b_sum_dx"] - chamber_metrics[last]["o2_b_sum_dx"]
			c_metric["fuel_sum_d2x"] = L["fuel_sum_dx"] - chamber_metrics[last]["fuel_sum_dx"]
			c_metric["rad_sum_d2x"] = L["rad_sum_dx"] - chamber_metrics[last]["rad_sum_dx"]

			avg_chamber["o2_d2x"] += c_metric["o2_d2x"]
			avg_chamber["toxins_d2x"] += c_metric["toxins_d2x"]
			avg_chamber["co2_d2x"] += c_metric["co2_d2x"]
			avg_chamber["n2_d2x"] += c_metric["n2_d2x"]
			avg_chamber["pressure_d2x"] += c_metric["pressure_d2x"]
			avg_chamber["temp_d2x"] += c_metric["temp_d2x"]
			avg_chamber["burnt_d2x"] += c_metric["burnt_d2x"]
			avg_chamber["heat_capacity_d2x"] += c_metric["heat_capacity_d2x"]
			avg_chamber["thermal_energy_d2x"] += c_metric["thermal_energy_d2x"]
			avg_chamber["moles_d2x"] += c_metric["moles_d2x"]
			avg_chamber["n20_d2x"] += c_metric["n20_d2x"]
			avg_chamber["o2_b_d2x"] += c_metric["o2_b_d2x"]
			avg_chamber["fuel_d2x"] += c_metric["fuel_d2x"]
			avg_chamber["rad_d2x"] += c_metric["rad_d2x"]

			avg_chamber["o2_sum_d2x"] += c_metric["o2_sum_d2x"]
			avg_chamber["toxins_sum_d2x"] += c_metric["toxins_sum_d2x"]
			avg_chamber["co2_sum_d2x"] += c_metric["co2_sum_d2x"]
			avg_chamber["n2_sum_d2x"] += c_metric["n2_sum_d2x"]
			avg_chamber["pressure_sum_d2x"] += c_metric["pressure_sum_d2x"]
			avg_chamber["temp_sum_d2x"] += c_metric["temp_sum_d2x"]
			avg_chamber["burnt_sum_d2x"] += c_metric["burnt_sum_d2x"]
			avg_chamber["heat_capacity_sum_d2x"] += c_metric["heat_capacity_sum_d2x"]
			avg_chamber["thermal_energy_sum_d2x"] += c_metric["thermal_energy_sum_d2x"]
			avg_chamber["moles_sum_d2x"] += c_metric["moles_sum_d2x"]
			avg_chamber["n20_sum_d2x"] += c_metric["n20_sum_d2x"]
			avg_chamber["o2_b_sum_d2x"] += c_metric["o2_b_sum_d2x"]
			avg_chamber["fuel_sum_d2x"] += c_metric["fuel_sum_d2x"]
			avg_chamber["rad_sum_d2x"] += c_metric["rad_sum_d2x"]

			chamber_metrics[++chamber_metrics.len] = c_metric

		process_meter(var/p_tag, var/list/L)
			master_meter_datapoints["[p_tag]"][++master_meter_datapoints["[p_tag]"].len] = L
			if(master_meter_datapoints["[p_tag]"].len == 1) return

			var/list/m_metric = new/list()
			var/last = master_meter_datapoints["[p_tag]"].len - 1

			m_metric["index"] = last + 1
			m_metric["tag"] = p_tag

			m_metric["o2_dx"] = L["o2"] - master_meter_datapoints["[p_tag]"][last]["o2"]
			m_metric["toxins_dx"] = L["toxins"] - master_meter_datapoints["[p_tag]"][last]["toxins"]
			m_metric["co2_dx"] = L["co2"] - master_meter_datapoints["[p_tag]"][last]["co2"]
			m_metric["n2_dx"] = L["n2"] - master_meter_datapoints["[p_tag]"][last]["n2"]
			m_metric["pressure_dx"] = L["pressure"] - master_meter_datapoints["[p_tag]"][last]["pressure"]
			m_metric["temp_dx"] = L["temp"] - master_meter_datapoints["[p_tag]"][last]["temp"]
			m_metric["burnt_dx"] = L["burnt"] - master_meter_datapoints["[p_tag]"][last]["burnt"]
			m_metric["heat_capacity_dx"] = L["heat_capacity"] - master_meter_datapoints["[p_tag]"][last]["heat_capacity"]
			m_metric["thermal_energy_dx"] = L["thermal_energy"] - master_meter_datapoints["[p_tag]"][last]["thermal_energy"]
			m_metric["moles_dx"] = L["moles"] - master_meter_datapoints["[p_tag]"][last]["moles"]
			m_metric["n20_dx"] = L["n20"] - master_meter_datapoints["[p_tag]"][last]["n20"]
			m_metric["o2_b_dx"] = L["o2_b"] - master_meter_datapoints["[p_tag]"][last]["o2_b"]
			m_metric["fuel_dx"] = L["fuel"] - master_meter_datapoints["[p_tag]"][last]["fuel"]
			m_metric["rad_dx"] = L["rad"] - master_meter_datapoints["[p_tag]"][last]["rad"]

			avg_meter["[p_tag]"]["cnt"] += 1

			avg_meter["[p_tag]"]["o2"] += L["o2"]
			avg_meter["[p_tag]"]["toxins"] += L["toxins"]
			avg_meter["[p_tag]"]["co2"] += L["co2"]
			avg_meter["[p_tag]"]["n2"] += L["n2"]
			avg_meter["[p_tag]"]["pressure"] += L["pressure"]
			avg_meter["[p_tag]"]["temp"] += L["temp"]
			avg_meter["[p_tag]"]["burnt"] += L["burnt"]
			avg_meter["[p_tag]"]["heat_capacity"] += L["heat_capacity"]
			avg_meter["[p_tag]"]["thermal_energy"] += L["thermal_energy"]
			avg_meter["[p_tag]"]["moles"] += L["moles"]
			avg_meter["[p_tag]"]["n20"] += L["n20"]
			avg_meter["[p_tag]"]["o2_b"] += L["o2_b"]
			avg_meter["[p_tag]"]["fuel"] += L["fuel"]
			avg_meter["[p_tag]"]["rad"] += L["rad"]

			avg_meter["[p_tag]"]["o2_dx"] += m_metric["o2_dx"]
			avg_meter["[p_tag]"]["toxins_dx"] += m_metric["toxins_dx"]
			avg_meter["[p_tag]"]["co2_dx"] += m_metric["co2_dx"]
			avg_meter["[p_tag]"]["n2_dx"] += m_metric["n2_dx"]
			avg_meter["[p_tag]"]["pressure_dx"] += m_metric["pressure_dx"]
			avg_meter["[p_tag]"]["temp_dx"] += m_metric["temp_dx"]
			avg_meter["[p_tag]"]["burnt_dx"] += m_metric["burnt_dx"]
			avg_meter["[p_tag]"]["heat_capacity_dx"] += m_metric["heat_capacity_dx"]
			avg_meter["[p_tag]"]["thermal_energy_dx"] += m_metric["thermal_energy_dx"]
			avg_meter["[p_tag]"]["moles_dx"] += m_metric["moles_dx"]
			avg_meter["[p_tag]"]["n20_dx"] += m_metric["n20_dx"]
			avg_meter["[p_tag]"]["o2_b_dx"] += m_metric["o2_b_dx"]
			avg_meter["[p_tag]"]["fuel_dx"] += m_metric["fuel_dx"]
			avg_meter["[p_tag]"]["rad_dx"] += m_metric["rad_dx"]

			if(meter_metrics["[p_tag]"].len == 0)
				meter_metrics["[p_tag]"][++meter_metrics["[p_tag]"].len] = m_metric
				return

			last = meter_metrics["[p_tag]"].len

			m_metric["o2_d2x"] = m_metric["o2_dx"] - meter_metrics["[p_tag]"][last]["o2_dx"]
			m_metric["toxins_d2x"] = m_metric["toxins_dx"] - meter_metrics["[p_tag]"][last]["toxins_dx"]
			m_metric["co2_d2x"] = m_metric["co2_dx"] - meter_metrics["[p_tag]"][last]["co2_dx"]
			m_metric["n2_d2x"] = m_metric["n2_dx"] - meter_metrics["[p_tag]"][last]["n2_dx"]
			m_metric["pressure_d2x"] = m_metric["pressure_dx"]  - meter_metrics["[p_tag]"][last]["pressure_dx"]
			m_metric["temp_d2x"] = m_metric["temp_dx"] - meter_metrics["[p_tag]"][last]["temp_dx"]
			m_metric["burnt_d2x"] = m_metric["burnt_dx"] - meter_metrics["[p_tag]"][last]["burnt_dx"]
			m_metric["heat_capacity_d2x"] = m_metric["heat_capacity_dx"] - meter_metrics["[p_tag]"][last]["heat_capacity_dx"]
			m_metric["thermal_energy_d2x"] = m_metric["thermal_energy_dx"] - meter_metrics["[p_tag]"][last]["thermal_energy_dx"]
			m_metric["moles_d2x"] = m_metric["moles_dx"] - meter_metrics["[p_tag]"][last]["moles_dx"]
			m_metric["n20_d2x"] = m_metric["n20_dx"] - meter_metrics["[p_tag]"][last]["n20_dx"]
			m_metric["o2_b_d2x"] = m_metric["o2_b_dx"] - meter_metrics["[p_tag]"][last]["o2_b_dx"]
			m_metric["fuel_d2x"] = m_metric["fuel_dx"] - meter_metrics["[p_tag]"][last]["fuel_dx"]
			m_metric["rad_d2x"] = m_metric["rad_dx"] - meter_metrics["[p_tag]"][last]["rad_dx"]

			avg_meter["[p_tag]"]["o2_d2x"] = m_metric["o2_d2x"]
			avg_meter["[p_tag]"]["toxins_d2x"] = m_metric["toxins_d2x"]
			avg_meter["[p_tag]"]["co2_d2x"] = m_metric["co2_d2x"]
			avg_meter["[p_tag]"]["n2_d2x"] = m_metric["n2_d2x"]
			avg_meter["[p_tag]"]["pressure_d2x"] = m_metric["pressure_d2x"]
			avg_meter["[p_tag]"]["temp_d2x"] = m_metric["temp_d2x"]
			avg_meter["[p_tag]"]["burnt_d2x"] = m_metric["burnt_d2x"]
			avg_meter["[p_tag]"]["heat_capacity_d2x"] = m_metric["heat_capacity_d2x"]
			avg_meter["[p_tag]"]["thermal_energy_d2x"] = m_metric["thermal_energy_d2x"]
			avg_meter["[p_tag]"]["moles_d2x"] = m_metric["moles_d2x"]
			avg_meter["[p_tag]"]["n20_d2x"] = m_metric["n20_d2x"]
			avg_meter["[p_tag]"]["o2_b_d2x"] = m_metric["o2_b_d2x"]
			avg_meter["[p_tag]"]["fuel_d2x"] = m_metric["fuel_d2x"]
			avg_meter["[p_tag]"]["rad_d2x"] = m_metric["rad_d2x"]

			meter_metrics["[p_tag]"][++meter_metrics["[p_tag]"].len] = m_metric

		sample_air(var/datum/gas_mixture/G, var/ARCHIVED(no))
			var/list/ret = new/list()

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
					for(var/datum/gas/T in G.trace_gases)
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
					for(var/datum/gas/T in G.trace_gases)
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
			var/list/ret = new/list()

			ret["output"] = teg.lastgen
			ret["hot_temp_in"] = teg_hot.air1.temperature
			ret["hot_temp_out"] = teg_hot.air2.temperature
			ret["hot_pressure_in"] = MIXTURE_PRESSURE(teg_hot.air1)
			ret["hot_pressure_out"] = MIXTURE_PRESSURE(teg_hot.air2)
			ret["cold_temp_in"] = teg_cold.air1.temperature
			ret["cold_temp_out"] = teg_cold.air2.temperature
			ret["cold_pressure_in"] = MIXTURE_PRESSURE(teg_cold.air1)
			ret["cold_pressure_out"] = MIXTURE_PRESSURE(teg_cold.air2)

			return ret

		avg_samples(var/list/L)
			var/list/ret = new/list()

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
			var/list/ret = new/list()

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
			var/list/area_contents = new/list()
			var/list/ret = new/list()

			#ifdef COGMAP1
			area_path = "/area/station/engine"
			#endif

			area_contents = get_area_all_atoms(area_path)
			for(var/obj/O in area_contents)
				if(istype(O, /obj/machinery/power/stats_meter))
					ret.Add(O)
					O.overlays += ("red_overlay")
					master_meter_datapoints["[O.tag]"] = new/list()
					meter_metrics["[O.tag]"] = new/list()

			#ifdef DEBUG_COMP
			for(var/obj/machinery/atmospherics/pipe/simple/O in area_contents)
				O.can_rupture = 0

			for(var/obj/machinery/atmospherics/valve/O in area_contents)
				if(!findtext(O.name, "purge") && !findtext(O.name, "release"))
					O.open()

			for(var/obj/machinery/portable_atmospherics/canister/toxins/O in area_contents)
				O.air_contents.volume = 1000000
				O.air_contents.toxins = (O.maximum_pressure*O.filled)*O.air_contents.volume/(R_IDEAL_GAS_EQUATION*O.air_contents.temperature)
				O.pressure_resistance = FLOAT_HIGH
				O.temperature_resistance = FLOAT_HIGH
				O.update_icon()

			for(var/obj/machinery/portable_atmospherics/canister/oxygen/O in area_contents)
				O.air_contents.volume = 1000000
				O.air_contents.oxygen = (O.maximum_pressure*O.filled)*O.air_contents.volume/(R_IDEAL_GAS_EQUATION*O.air_contents.temperature)
				O.pressure_resistance = FLOAT_HIGH
				O.temperature_resistance = FLOAT_HIGH
				O.update_icon()

			#endif

			return ret

		avg_reset()
			hold = 1

			avg_chamber["cnt"] = 0
			for(var/X in avg_chamber_words)
				avg_chamber["[X]"] = 0
				avg_chamber["[X]_dx"] = 0
				avg_chamber["[X]_d2x"] = 0

			avg_teg["cnt"] = 0
			for(var/Y in avg_teg_words)
				avg_teg["[Y]"] = 0
				avg_teg["[Y]_dx"] = 0
				avg_teg["[Y]_d2x"] = 0

			for(var/obj/machinery/power/stats_meter/T in meters)
				var/N = T.tag
				avg_meter["[N]"] = new/list()
				avg_meter["[N]"]["cnt"] = 0
				for(var/Z in avg_meter_words)
					avg_meter["[N]"]["[Z]"] = 0
					avg_meter["[N]"]["[Z]_dx"] = 0
					avg_meter["[N]"]["[Z]_d2x"] = 0

		nav()
			//var/ret = "<div id=\"stats_header\"> { "
			var/datum/tag/div/ret = new
			ret.setAttribute("id", "stats_header")

			var/datum/tag/span/left = new
			var/datum/tag/span/right = new

			var/datum/tag/span/m1 = new
			var/datum/tag/span/m2 = new

			var/datum/tag/anchor/a1 = new
			var/datum/tag/anchor/a2 = new
			var/datum/tag/anchor/a3 = new

			left.setText("{ ")
			right.setText(" }")
			m1.setText(" | ")
			m2.setText(" | ")

			a1.setText("reactor")
			a1.setHref("?src=\ref[src];nav_h=1'")
			a2.setText("combustion chamber")
			a2.setHref("?src=\ref[src];nav_h=2'")
			a3.setText("gas loops")
			a3.setHref("?src=\ref[src];nav_h=3'")

			switch(curpage)
				if(1) a1.setAttribute("class", "nav_active")
				if(2) a2.setAttribute("class", "nav_active")
				if(3) a3.setAttribute("class", "nav_active")

			ret.addChildElement(left)
			ret.addChildElement(a1)
			ret.addChildElement(m1)
			ret.addChildElement(a2)
			ret.addChildElement(m2)
			ret.addChildElement(a3)
			ret.addChildElement(right)

			return ret

		ctl()
			var/status = null

			if(hold)
				status = {"<span class="offline">OFFLINE</span>"}
			else
				status = {"<span class="online">ONLINE</span>"}

			var/ret = {"<div style="margin:30px auto 70px auto;clear:both;width:45%;">

            	<div style="display:inline-block;float:left">[status]</div>
            	<div style="display:inline-block;float:right">
            	<a href="?src=\ref[src];avg_reset=1">RESET AVG    </a>"}

			if(refresh)
				ret += {"<a href="?src=\ref[src];refresh_toggle=1"><span class="online">REFRESH ON</span></a>"}
			else
				ret += {"<a href="?src=\ref[src];refresh_toggle=1"><span class="offline">REFRESH OFF</span></a>"}


			if(power)
				ret += {" - <a href="?src=\ref[src];power_toggle=1"><span class="online">POWER ON</span></a>"}
			else
				ret += {" - <a href="?src=\ref[src];power_toggle=1"><span class="offline">POWER OFF</span></a>"}

			ret += {"</div></div>"}

			return ret
		gen_reactor_page()
			var/ret = ""
			var/list/cur_metric = generator_metrics[generator_metrics.len]
			var/list/disc_sample = master_generator_datapoints[cur_metric["index"]]
			var/list/avg = new/list()

			if(avg_cum)
				// XXX
			else
				for(var/N in avg_teg_words)
					/*for(var/X in master_generator_datapoints)
						avg["[N]"] += X["[N]"]
					for(var/Y in generator_metrics)
						avg["[N]_dx"] += Y["[N]_dx"]
					for(var/Z in generator_metrics)
						avg["[N]_d2x"] += Z["[N]_d2x"] */

					avg["[N]"] = (avg_teg["[N]"] ? avg_teg["[N]"] / avg_teg["cnt"] : 0)
					avg["[N]_dx"] = (avg_teg["[N]_dx"] ? avg_teg["[N]_dx"] / avg_teg["cnt"] : 0)
					avg["[N]_d2x"] = (avg_teg["[N]_d2x"] ? avg_teg["[N]_d2x"] / (avg_teg["cnt"] - 1) : 0)

			ret += {"<div class="center">"}
			ret += {"<table class="rs_table"><caption>instantaneous</caption><tr><th>data id</th><th>now</th><th>dy/dx</th><th>d<sup>2</sup>y/dx<sup>2</sup></th></tr>"}
			ret += {"
				<tr><td class="y_label">engine output</td>
				<td>[disc_sample["output"]]</td>
				<td>[cur_metric["output_dx"]]</td>
				<td>[cur_metric["output_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">hot loop temperature (in)</td>
				<td>[disc_sample["hot_temp_in"]]</td>
				<td>[cur_metric["hot_temp_in_dx"]]</td>
				<td>[cur_metric["hot_temp_in_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">hot loop temperature (out)</td>
				<td>[disc_sample["hot_temp_out"]]</td>
				<td>[cur_metric["hot_temp_out_dx"]]</td>
				<td>[cur_metric["hot_temp_out_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">hot loop pressure (in)</td>
				<td>[disc_sample["hot_pressure_in"]]</td>
				<td>[cur_metric["hot_pressure_in_dx"]]</td>
				<td>[cur_metric["hot_pressure_in_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">hot loop pressure (out)</td>
				<td>[disc_sample["hot_pressure_out"]]</td>
				<td>[cur_metric["hot_pressure_out_dx"]]</td>
				<td>[cur_metric["hot_pressure_out_d2x"]]</td>
				</tr>
			"}

			ret += {"
				<tr><td class="y_label">cold loop temperature (in)</td>
				<td>[disc_sample["cold_temp_in"]]</td>
				<td>[cur_metric["cold_temp_in_dx"]]</td>
				<td>[cur_metric["cold_temp_in_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">cold loop temperature (out)</td>
				<td>[disc_sample["cold_temp_out"]]</td>
				<td>[cur_metric["cold_temp_out_dx"]]</td>
				<td>[cur_metric["cold_temp_out_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">cold loop pressure (in)</td>
				<td>[disc_sample["cold_pressure_in"]]</td>
				<td>[cur_metric["cold_pressure_in_dx"]]</td>
				<td>[cur_metric["cold_pressure_in_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">cold loop pressure (out)</td>
				<td>[disc_sample["cold_pressure_out"]]</td>
				<td>[cur_metric["cold_pressure_out_dx"]]</td>
				<td>[cur_metric["cold_pressure_out_d2x"]]</td>
				</tr>
			"}
			ret += {"</table>"}

			ret += {"<table class="rs_table"><caption>average</caption><tr><th>data id</th><th>now</th><th>dy/dx</th><th>d<sup>2</sup>y/dx<sup>2</sup></th></tr>"}
			ret += {"
				<tr><td class="y_label">engine output</td>
				<td>[avg["output"]]</td>
				<td>[avg["output_dx"]]</td>
				<td>[avg["output_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">hot loop temperature (in)</td>
				<td>[avg["hot_temp_in"]]</td>
				<td>[avg["hot_temp_in_dx"]]</td>
				<td>[avg["hot_temp_in_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">hot loop temperature (out)</td>
				<td>[avg["hot_temp_out"]]</td>
				<td>[avg["hot_temp_out_dx"]]</td>
				<td>[avg["hot_temp_out_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">hot loop pressure (in)</td>
				<td>[avg["hot_pressure_in"]]</td>
				<td>[avg["hot_pressure_in_dx"]]</td>
				<td>[avg["hot_pressure_in_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">hot loop pressure (out)</td>
				<td>[avg["hot_pressure_out"]]</td>
				<td>[avg["hot_pressure_out_dx"]]</td>
				<td>[avg["hot_pressure_out_d2x"]]</td>
				</tr>
			"}

			ret += {"
				<tr><td class="y_label">cold loop temperature (in)</td>
				<td>[avg["cold_temp_in"]]</td>
				<td>[avg["cold_temp_in_dx"]]</td>
				<td>[avg["cold_temp_in_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">cold loop temperature (out)</td>
				<td>[avg["cold_temp_out"]]</td>
				<td>[avg["cold_temp_out_dx"]]</td>
				<td>[avg["cold_temp_out_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">cold loop pressure (in)</td>
				<td>[avg["cold_pressure_in"]]</td>
				<td>[avg["cold_pressure_in_dx"]]</td>
				<td>[avg["cold_pressure_in_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">cold loop pressure (out)</td>
				<td>[avg["cold_pressure_out"]]</td>
				<td>[avg["cold_pressure_out_dx"]]</td>
				<td>[avg["cold_pressure_out_d2x"]]</td>
				</tr>
			"}
			ret += {"</table></div>"}

			return ret

		gen_chamber_page()
			var/ret = ""
			var/list/cur_metric = chamber_metrics[chamber_metrics.len]
			var/list/disc_sample = master_chamber_datapoints[cur_metric["index"]]
			var/list/avg = new/list()

			if(avg_cum)
				// XXX
			else
				for(var/N in avg_chamber_words)
					avg["[N]"] = (avg_chamber["[N]"] ? (avg_chamber["[N]"] / avg_chamber["cnt"]) : 0)
					avg["[N]_dx"] = (avg_chamber["[N]_dx"] ? (avg_chamber["[N]_dx"] / avg_chamber["cnt"]) : 0)
					avg["[N]_d2x"] = (avg_chamber["[N]_d2x"] ? (avg_chamber["[N]_d2x"] / (avg_chamber["cnt"] - 1)) : 0)

			ret += {"<div class="center">"}
			ret += {"<table class="rs_table"><caption>instantaneous (per tile)</caption><tr><th>data id</th><th>now</th><th>dy/dx</th><th>d<sup>2</sup>y/dx<sup>2</sup></th></tr>"}
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

			ret += {"<table class="rs_table"><caption>average (per tile)</caption><tr><th>data id</th><th>now</th><th>dy/dx</th><th>d<sup>2</sup>y/dx<sup>2</sup></th></tr>"}
			ret += {"
				<tr><td class="y_label">oxygen</td>
				<td>[avg["o2"]]</td>
				<td>[avg["o2_dx"]]</td>
				<td>[avg["o2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">plasma</td>
				<td>[avg["toxins"]]</td>
				<td>[avg["toxins_dx"]]</td>
				<td>[avg["toxins_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">carbon dioxide</td>
				<td>[avg["co2"]]</td>
				<td>[avg["co2_dx"]]</td>
				<td>[avg["co2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">nitrogen</td>
				<td>[avg["n2"]]</td>
				<td>[avg["n2_dx"]]</td>
				<td>[avg["n2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">temperature</td>
				<td>[avg["temp"]]</td>
				<td>[avg["temp_dx"]]</td>
				<td>[avg["temp_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">fuel burnt</td>
				<td>[avg["burnt"]]</td>
				<td>[avg["burnt_dx"]]</td>
				<td>[avg["burnt_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">pressure</td>
				<td>[avg["pressure"]]</td>
				<td>[avg["pressure_dx"]]</td>
				<td>[avg["pressure_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">thermal energy</td>
				<td>[avg["thermal_energy"]]</td>
				<td>[avg["thermal_energy_dx"]]</td>
				<td>[avg["thermal_energy_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">heat capacity</td>
				<td>[avg["heat_capacity"]]</td>
				<td>[avg["heat_capacity_dx"]]</td>
				<td>[avg["heat_capacity_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">molarity</td>
				<td>[avg["moles"]]</td>
				<td>[avg["moles_dx"]]</td>
				<td>[avg["moles_d2x"]]</td>
				</tr>
			"}
			ret += {"</table></div>"}

			ret += {"<div class="center">"}
			ret += {"<table class="rs_table"><caption>instantaneous (total)</caption><tr><th>data id</th><th>now</th><th>dy/dx</th><th>d<sup>2</sup>y/dx<sup>2</sup></th></tr>"}
			ret += {"
				<tr><td class="y_label">oxygen</td>
				<td>[disc_sample["o2_sum"]]</td>
				<td>[cur_metric["o2_sum_dx"]]</td>
				<td>[cur_metric["o2_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">plasma</td>
				<td>[disc_sample["toxins_sum"]]</td>
				<td>[cur_metric["toxins_sum_dx"]]</td>
				<td>[cur_metric["toxins_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">carbon dioxide</td>
				<td>[disc_sample["co2_sum"]]</td>
				<td>[cur_metric["co2_sum_dx"]]</td>
				<td>[cur_metric["co2_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">nitrogen</td>
				<td>[disc_sample["n2_sum"]]</td>
				<td>[cur_metric["n2_sum_dx"]]</td>
				<td>[cur_metric["n2_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">temperature</td>
				<td>[disc_sample["temp_sum"]]</td>
				<td>[cur_metric["temp_sum_dx"]]</td>
				<td>[cur_metric["temp_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">fuel burnt</td>
				<td>[disc_sample["burnt_sum"]]</td>
				<td>[cur_metric["burnt_sum_dx"]]</td>
				<td>[cur_metric["burnt_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">pressure</td>
				<td>[disc_sample["pressure_sum"]]</td>
				<td>[cur_metric["pressure_sum_dx"]]</td>
				<td>[cur_metric["pressure_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">thermal energy</td>
				<td>[disc_sample["thermal_energy_sum"]]</td>
				<td>[cur_metric["thermal_energy_sum_dx"]]</td>
				<td>[cur_metric["thermal_energy_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">heat capacity</td>
				<td>[disc_sample["heat_capacity_sum"]]</td>
				<td>[cur_metric["heat_capacity_sum_dx"]]</td>
				<td>[cur_metric["heat_capacity_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">molarity</td>
				<td>[disc_sample["moles_sum"]]</td>
				<td>[cur_metric["moles_sum_dx"]]</td>
				<td>[cur_metric["moles_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"</table>"}

			ret += {"<table class="rs_table"><caption>average (total)</caption><tr><th>data id</th><th>now</th><th>dy/dx</th><th>d<sup>2</sup>y/dx<sup>2</sup></th></tr>"}
			ret += {"
				<tr><td class="y_label">oxygen</td>
				<td>[avg["o2_sum"]]</td>
				<td>[avg["o2_sum_dx"]]</td>
				<td>[avg["o2_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">plasma</td>
				<td>[avg["toxins_sum"]]</td>
				<td>[avg["toxins_sum_dx"]]</td>
				<td>[avg["toxins_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">carbon dioxide</td>
				<td>[avg["co2_sum"]]</td>
				<td>[avg["co2_sum_dx"]]</td>
				<td>[avg["co2_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">nitrogen</td>
				<td>[avg["n2_sum"]]</td>
				<td>[avg["n2_sum_dx"]]</td>
				<td>[avg["n2_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">temperature</td>
				<td>[avg["temp_sum"]]</td>
				<td>[avg["temp_sum_dx"]]</td>
				<td>[avg["temp_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">fuel burnt</td>
				<td>[avg["burnt_sum"]]</td>
				<td>[avg["burnt_sum_dx"]]</td>
				<td>[avg["burnt_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">pressure</td>
				<td>[avg["pressure_sum"]]</td>
				<td>[avg["pressure_sum_dx"]]</td>
				<td>[avg["pressure_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">thermal energy</td>
				<td>[avg["thermal_energy_sum"]]</td>
				<td>[avg["thermal_energy_sum_dx"]]</td>
				<td>[avg["thermal_energy_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">heat capacity</td>
				<td>[avg["heat_capacity_sum"]]</td>
				<td>[avg["heat_capacity_sum_dx"]]</td>
				<td>[avg["heat_capacity_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">molarity</td>
				<td>[avg["moles_sum"]]</td>
				<td>[avg["moles_sum_dx"]]</td>
				<td>[avg["moles_sum_d2x"]]</td>
				</tr>
			"}
			ret += {"</table></div>"}

			return ret

		gen_loops_page(var/p_tag as text)
			var/ret = ""
			var/list/cur_metric = meter_metrics["[p_tag]"][meter_metrics["[p_tag]"].len]
			var/list/disc_sample = master_meter_datapoints["[p_tag]"][cur_metric["index"]]
			var/list/avg = new/list()

			if(avg_cum)
				// XXX
			else
				for(var/N in avg_meter_words)
					avg["[N]"] = (avg_meter["[p_tag]"]["[N]"] ? avg_meter["[p_tag]"]["[N]"] / avg_meter["[p_tag]"]["cnt"] : 0)
					avg["[N]_dx"] = (avg_meter["[p_tag]"]["[N]_dx"] ? avg_meter["[p_tag]"]["[N]_dx"] / avg_meter["[p_tag]"]["cnt"] : 0)
					avg["[N]_d2x"] = (avg_meter["[p_tag]"]["[N]_d2x"] ? avg_meter["[p_tag]"]["[N]_d2x"] / (avg_meter["[p_tag]"]["cnt"] - 1) : 0)

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

			ret += {"<table class="rs_table"><caption>[p_tag] - average</caption><tr><th>data id</th><th>now</th><th>dy/dx</th><th>d<sup>2</sup>y/dx<sup>2</sup></th></tr>"}
			ret += {"
				<tr><td class="y_label">oxygen</td>
				<td>[avg["o2"]]</td>
				<td>[avg["o2_dx"]]</td>
				<td>[avg["o2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">plasma</td>
				<td>[avg["toxins"]]</td>
				<td>[avg["toxins_dx"]]</td>
				<td>[avg["toxins_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">carbon dioxide</td>
				<td>[avg["co2"]]</td>
				<td>[avg["co2_dx"]]</td>
				<td>[avg["co2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">nitrogen</td>
				<td>[avg["n2"]]</td>
				<td>[avg["n2_dx"]]</td>
				<td>[avg["n2_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">temperature</td>
				<td>[avg["temp"]]</td>
				<td>[avg["temp_dx"]]</td>
				<td>[avg["temp_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">fuel burnt</td>
				<td>[avg["burnt"]]</td>
				<td>[avg["burnt_dx"]]</td>
				<td>[avg["burnt_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">pressure</td>
				<td>[avg["pressure"]]</td>
				<td>[avg["pressure_dx"]]</td>
				<td>[avg["pressure_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">thermal energy</td>
				<td>[avg["thermal_energy"]]</td>
				<td>[avg["thermal_energy_dx"]]</td>
				<td>[avg["thermal_energy_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">heat capacity</td>
				<td>[avg["heat_capacity"]]</td>
				<td>[avg["heat_capacity_dx"]]</td>
				<td>[avg["heat_capacity_d2x"]]</td>
				</tr>
			"}
			ret += {"
				<tr><td class="y_label">molarity</td>
				<td>[avg["moles"]]</td>
				<td>[avg["moles_dx"]]</td>
				<td>[avg["moles_d2x"]]</td>
				</tr>
			"}

			ret += {"</table></div>"}

			return ret

		callJsFunc(var/funcName, var/params)
			if(!luser) return
			luser << output(params,"reactorstats.browser:[funcName]")


/obj/machinery/power/reactor_stats/attack_hand(mob/user as mob)
	var/datum/tag/page/html = new
	var/datum/tag/title/title = new
	var/datum/tag/css/kstyle = new
	var/datum/tag/meta = new("meta")

	meta.setAttribute("http-equiv", "X-UA-Compatible")
	meta.setAttribute("content", "IE=edge")
	meta.selfCloses = 1
	html.addToHead(meta)

	title.setText("Reactor Statistics and Statistical Analyzer")
	html.addToHead(title)

	var/datum/tag/cssinclude/bootstrap = new
	bootstrap.setHref(resource("css/bootstrap.min.css"))
	html.addToHead(bootstrap)

	var/datum/tag/cssinclude/bootstrapResponsive = new
	bootstrapResponsive.setHref(resource("css/bootstrap-responsive.min.css"))
	html.addToHead(bootstrapResponsive)

	var/datum/tag/scriptinclude/jquery = new
	jquery.setSrc(resource("js/jquery.min.js"))
	html.addToHead(jquery)

	var/datum/tag/scriptinclude/jqueryMigrate = new
	jqueryMigrate.setSrc(resource("js/jquery.migrate.js"))
	html.addToHead(jqueryMigrate)

	var/datum/tag/scriptinclude/bootstrapJs = new
	bootstrapJs.setSrc(resource("js/bootstrap.min.js"))
	html.addToBody(bootstrapJs)

	var/datum/tag/scriptinclude/jsviews = new
	jsviews.setSrc(resource("js/jsviews.min.js"))
	html.addToBody(jsviews)

	kstyle.setContent({"
	body {
		background-color: #170F0D;
		color: #746C48;
	}
	a:link { color: #98724C; }
	a:visited { color: #98724C; }
	a:hover { color: #AF652F; }

	.rs_table {
		margin: 20px;
		display: inline-block;
	}

	.rs_table th, .rs_table tr td {
		border: 1px solid #544B2E;
		border-collapse: collapse;
	}
	caption { text-transform: lowercase; }
	.rs_table th {
		color: #70A16C;
		font-weight:bold;
		text-transform: lowercase;
		text-align: left;
		padding-left: 5px;
	}
	.rs_table th: {
		color: #70A16C;
		font-weight:bold;
		text-transform: lowercase;
		text-align: left;
		padding-left: 5px;
	}
	.rs_table tbody tr th:first-child {
		padding-left: 0px;
		padding-right: 5px;
		text-align: right;
	}
	#stats_header {
		margin: 20px auto 20px auto;
		font-size: 20px;
		text-align:center;
	}

	#stats_header a {
		font-size: 16px;
	}

	.nav_active {
		text-transform: uppercase;
		font-size: 20px !important;
		color: #AF652F !important;
		letter-spacing: 4px;
		font-weight: bold;
	}
	.table_title {
		text-align:center;
		font-size: 20px;
	}
	.center {
		text-align:center;
	}
	.online {
		font-size: 2em;
		background-color: #7B854E;
		color:#E4DC8C;
	}
	.offline {
        font-size: 2em;
        background-color: #98724C;
        color:#E4DC8C;
    }
	.stats_tables {
		margin-top: 100px;
	}
	.y_label {
		text-align: right;
		font-weight: bold;
		font-family: monospace;
		padding-right: 5px;
	}
	td {
		text-align: left;
		font-family: monospace;
		padding-left: 5px;
		min-width: 90px;
	}
	"})
	html.addToHead(kstyle)

	src.add_dialog(user)
	if(user.client)
		luser = user.client

	html.addToBody(src.nav())

	var/datum/tag/div/tab = new
	var/datum/tag/div/control = new

	control.innerHtml = src.ctl()
	html.addToBody(control)

	if(!hold && avg_teg["cnt"] > 2)
		switch(src.curpage)
			if(1) tab.innerHtml = src.gen_reactor_page()
			if(2) tab.innerHtml = src.gen_chamber_page()
			if(3)
				for(var/obj/machinery/power/stats_meter/T in meters)
					tab.innerHtml += src.gen_loops_page("[T.tag]")

		tab.addClass("stats_tables")
		html.addToBody(tab)

	A_test_html_out = html.toHtml()

	user << browse(A_test_html_out, "window=reactorstats;size=1400x750;can_resize=1;can_minimize=1;allow-html=1;show-url=1;statusbar=1;enable-http-images=1;can-scroll=1")
	onclose(user, "reactorstats")

/obj/machinery/power/reactor_stats/attackby(obj/item/W as obj, mob/user as mob)
	src.attack_hand(user)

/obj/machinery/power/reactor_stats/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/power/reactor_stats/Topic(href, href_list)
	if(href_list["nav_h"])
		src.curpage = text2num(href_list["nav_h"])
	else if(href_list["avg_reset"])
		avg_reset()
	else if(href_list["refresh_toggle"])
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
