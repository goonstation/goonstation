/obj/machinery/portable_atmospherics/chem_mixer
	name = "chemical mixer"
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "chem_mixer-off"
	volume = 100
	allows_tank = FALSE
	density = FALSE
	var/current_heat_capacity = 50000
	var/min_operating_temp = 1000 KELVIN
	var/speed = 1
	var/on = FALSE

/obj/machinery/portable_atmospherics/chem_mixer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMixer", src.name)
		ui.open()

/obj/machinery/portable_atmospherics/chem_mixer/ui_data()
	return list(
		"on" = src.on,
		"speed" = src.speed,
		"connected" = !!src.connected_port,
	)

//so that we can control when the pressure is sampled to avoid weird rubber banding
/obj/machinery/portable_atmospherics/chem_mixer/ui_static_data()
	return list(
		"pressure" = MIXTURE_PRESSURE(src.air_contents),
		"maxPressure" = src.maximum_pressure,
	)

/obj/machinery/portable_atmospherics/chem_mixer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (action == "toggle-power")
		if (src.air_contents.temperature < src.min_operating_temp)
			return
		src.on = !src.on
		src.icon_state = src.on ? "chem_mixer-on" : "chem_mixer-off"
		return TRUE

/obj/machinery/portable_atmospherics/chem_mixer/process()
	..()
	for (var/datum/tgui/ui as anything in tgui_process.get_uis(src))
		src.update_static_data(null, ui)

	if (!src.on)
		return
	if (src.air_contents.temperature < src.min_operating_temp)
		return

	var/energy = THERMAL_ENERGY(src.air_contents)
	energy /= 1e6
	//stupid asymptotic curve (im bad at maths): https://www.desmos.com/calculator/knc4pbcbie
	src.speed = -13/(energy * energy/20 + energy + 4) + 3
	src.speed = max(1, speed)
	var/sound_played = FALSE
	for (var/obj/reagent_dispensers/chemicalbarrel/barrel in get_turf(src))
		barrel.reagents.reaction_speed = src.speed
		if (!sound_played && barrel.reagents.total_volume > 50)
			playsound(src, 'sound/impact_sounds/Liquid_Slosh_2.ogg', 40, 1)
			sound_played = TRUE
	//maths adapted from freezer code
	var/combined_heat_capacity = current_heat_capacity + HEAT_CAPACITY(src.air_contents)
	var/combined_energy = THERMAL_ENERGY(src.air_contents) + src.min_operating_temp * src.current_heat_capacity
	src.air_contents.temperature = combined_energy/combined_heat_capacity

	if (src.connected_port?.network)
		src.connected_port.network.update = TRUE

//I wonder if Crossed/Uncrossed is reliable, let's find out!
/obj/machinery/portable_atmospherics/chem_mixer/Crossed(obj/reagent_dispensers/chemicalbarrel/barrel)
	. = ..()
	if (istype(barrel))
		barrel.reagents.reaction_speed = src.speed

/obj/machinery/portable_atmospherics/chem_mixer/Uncrossed(obj/reagent_dispensers/chemicalbarrel/barrel)
	. = ..()
	if (istype(barrel))
		barrel.reagents.reaction_speed = 1
