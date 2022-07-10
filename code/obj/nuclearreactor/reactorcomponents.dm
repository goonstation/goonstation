/////////////////////////////////////////////////////////////////
// Defintion for the nuclear reactor engine internal components
/////////////////////////////////////////////////////////////////

ABSTRACT_TYPE(/obj/reactor_component)
/obj/item/reactor_component //base component
	name = "base reactor component"
	desc = "You really shouldn't be seeing this - call a coder"
	icon = 'icons/misc/reactorcomponents.dmi'
	icon_state = "fuel_rod"
	w_class = W_CLASS_BULKY

	var/icon_state_inserted = "base"
	var/ui_image = null
	var/temperature = T20C //room temp kelvin as default
	///How much does this component share heat with surrounding components? Basically surface area in contact (m2)
	var/thermal_cross_section = 0.01
	///How adept is this component at interacting with neutrons - fuel rods are set up to capture them, heat exchangers are set up not to
	var/neutron_cross_section = 0.5
	///Control rods don't moderate neutrons, they absorb them.
	var/is_control_rod = FALSE
	_max_health = 100
	var/melt_health = 100
	///If this component is melted, you can't take it out of the reactor and it might do some weird stuff
	var/melted = FALSE
	var/melting_point = 2500
	var/static/list/ui_image_base64_cache = list()
	var/gas_volume = 0

	//this should probably be a global, but it isn't afaik
	var/list/cardinals = list(NORTH, NORTHEAST, NORTHWEST, \
		                    SOUTH, SOUTHEAST, SOUTHWEST, \
		                    WEST, NORTHWEST, SOUTHWEST,  \
		                    EAST, NORTHEAST, SOUTHEAST)

	New(material_name="steel")
		..()
		src.setMaterial(getMaterial(material_name))
		melt_health = _max_health
		var/img_check = ui_image_base64_cache[src.type]
		if (img_check)
			src.ui_image = img_check
		else
			var/icon/dummy_icon = icon(initial(src.icon), initial(src.icon_state_inserted))
			src.ui_image = icon2base64(dummy_icon)
			ui_image_base64_cache[src.type] = src.ui_image

	proc/melt()
		if(melted)
			return
		src.melted = TRUE
		src.name = "melted "+src.name
		src.neutron_cross_section = 5.0
		src.thermal_cross_section = 1.0
		src.is_control_rod = FALSE

	proc/extra_info()
		. = ""

	proc/processGas(var/datum/gas_mixture/inGas)
		return null //most components won't touch gas

	proc/processHeat(var/list/obj/item/reactor_component/adjacentComponents)
		for(var/obj/item/reactor_component/RC in adjacentComponents)
			if(isnull(RC))
				continue
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = RC.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = calculateHeatTransferCoefficient(RC.material,src.material)
			RC.temperature += thermal_cross_section*-deltaT*hTC
			src.temperature += thermal_cross_section*deltaT*hTC
			if(RC.temperature < 0 || src.temperature < 0)
				CRASH("TEMP WENT NEGATIVE")
			RC.material.triggerTemp(RC,RC.temperature)
			src.material.triggerTemp(src,src.temperature)
		//heat transfer with reactor vessel
		var/obj/machinery/atmospherics/binary/nuclear_reactor/holder = src.loc
		if(istype(holder))
			var/deltaT = holder.temperature - src.temperature
			var/hTC = calculateHeatTransferCoefficient(holder.material,src.material)

			holder.temperature += thermal_cross_section*-deltaT*hTC
			src.temperature += thermal_cross_section*deltaT*hTC
			if(holder.temperature < 0 || src.temperature < 0)
				CRASH("TEMP WENT NEGATIVE")

			holder.material.triggerTemp(holder,holder.temperature)
			src.material.triggerTemp(src,src.temperature)
		if((src.temperature > src.melting_point) && (src.melt_health > 0))
			src.melt_health -= 10
		if(src.melt_health <= 0)
			src.melt() //oh no


	proc/processNeutrons(var/list/datum/neutron/inNeutrons)
		if(prob(src.material.getProperty("n_radioactive")*10*src.neutron_cross_section)) //fast spontaneous emission
			inNeutrons += new /datum/neutron(pick(cardinals), pick(2,3)) //neutron radiation gets you fast neutrons
			src.material.adjustProperty("n_radioactive", -0.01)
			src.material.setProperty("radioactive", src.material.getProperty("radioactive") + 0.005)
			src.temperature += 20
		if(prob(src.material.getProperty("radioactive")*10*src.neutron_cross_section)) //spontaneous emission
			inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2))
			src.material.adjustProperty("radioactive", -0.01)
			src.material.setProperty("spent_fuel", src.material.getProperty("spent_fuel") + 0.005)
			src.temperature += 10
		for(var/datum/neutron/N in inNeutrons)
			if(prob(src.material.getProperty("density")*10*src.neutron_cross_section)) //dense materials capture neutrons, configuration influences that
				//if a neutron is captured, we either do fission or we slow it down
				if(N.velocity <= (1 + src.melted) & prob(src.material.getProperty("n_radioactive")*10)) //neutron stimulated emission
					inNeutrons += new /datum/neutron(pick(cardinals), pick(2,3))
					inNeutrons += new /datum/neutron(pick(cardinals), pick(2,3))
					inNeutrons -= N
					qdel(N)
					src.temperature += 20
				else if(N.velocity <= (1 + src.melted) & prob(src.material.getProperty("radioactive")*10)) //stimulated emission
					inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2))
					inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2))
					inNeutrons -= N
					qdel(N)
					src.temperature += 10
				else
					if(prob(src.material.getProperty("hardness")*10)) //reflection is based on hardness
						N.dir = turn(N.dir,pick(180,225,135)) //either complete 180 or  180+/-45
					else if(is_control_rod) //control rods absorb neutrons
						N.velocity = 0
					else //everything else moderates them
						N.velocity--
					if(N.velocity <= 0)
						inNeutrons -= N
						qdel(N)
					src.temperature += 1

		return inNeutrons



////////////////////////////////////////////////////////////////
//Fuel rod
/obj/item/reactor_component/fuel_rod
	name = "fuel rod"
	desc = "A fuel rod for a nuclear reactor"
	icon_state_inserted = "fuel"
	neutron_cross_section = 1.0
	thermal_cross_section = 0.02

	extra_info()
		. = ..()
		. += "Radioactivity: [max(src.material.getProperty("n_radioactive")*10,src.material.getProperty("radioactive")*10)]%"
////////////////////////////////////////////////////////////////
//Control rod
/obj/item/reactor_component/control_rod
	name = "control rod"
	desc = "A control rod assembly for a nuclear reactor"
	icon_state_inserted = "control"
	neutron_cross_section = 1.0 //essentially *actual* insertion level
	var/configured_insertion_level = 1.0 //target insertion level
	is_control_rod = TRUE

	extra_info()
		. = ..()
		if(!melted)
			. += "Insertion: [neutron_cross_section*100]%"

	processNeutrons(list/datum/neutron/inNeutrons)
		. = ..()
		if((!src.melted) & (src.neutron_cross_section != src.configured_insertion_level))
			//step towards configured insertion level
			if(src.configured_insertion_level < src.neutron_cross_section)
				src.neutron_cross_section -= min(0.1, src.neutron_cross_section - src.configured_insertion_level)//TODO balance - this is 10% per tick, which is like every 3 seconds or something
			else
				src.neutron_cross_section += min(0.1, src.configured_insertion_level - src.neutron_cross_section)

////////////////////////////////////////////////////////////////
//Heat exchanger
/obj/item/reactor_component/heat_exchanger
	name = "heat exchanger"
	desc = "A heat exchanger component for a nuclear reactor"
	icon_state_inserted = "heat"
	thermal_cross_section = 0.4
	neutron_cross_section = 0.1

////////////////////////////////////////////////////////////////
//Gas channel
/obj/item/reactor_component/gas_channel
	name = "gas channel"
	desc = "A gas coolant channel component for a nuclear reactor"
	icon_state_inserted = "gas"
	thermal_cross_section = 0.05
	var/gas_thermal_cross_section = 0.95
	var/datum/gas_mixture/current_gas
	gas_volume = 100

	melt()
		..()
		gas_thermal_cross_section = 0.1 //oh no, all the fins and stuff are melted

	processNeutrons(list/datum/neutron/inNeutrons)
		. = ..()
		if(current_gas && current_gas.toxins > 0)
			for(var/datum/neutron/N in .)
				if(N.velocity > 0 && prob(current_gas.toxins/10))
					N.velocity++
					current_gas.toxins--
					current_gas.radgas++

	processGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = src.current_gas.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = calculateHeatTransferCoefficient(null, src.material)
			if(hTC>0)
				//gas density << metal density, so energy to heat gas to T is much small than energy to heat metal to T
				//basically, we just need a specific heat capactiy factor in here
				//fortunately, atmos has macros for that - for everything else, let's just assume steel's heat capacity and density
				//shc * moles/(shc of steel * density of steel * volume / molar mass of steel)
				var/gas_thermal_e = THERMAL_ENERGY(current_gas)
				src.current_gas.temperature += gas_thermal_cross_section*-deltaT*hTC
				//Q = mcT
				//dQ = mc(dT)
				//dQ/mc = dT
				src.temperature += (gas_thermal_e - THERMAL_ENERGY(current_gas))/(420*7700*0.2)
				if(src.current_gas.temperature < 0 || src.temperature < 0)
					CRASH("TEMP WENT NEGATIVE")
			. = src.current_gas
			if(src.melted)
				var/turf/T = get_turf(src.loc)
				if(T)
					T.assume_air(current_gas)
		if(inGas)
			src.current_gas = inGas.remove((src.gas_volume*MIXTURE_PRESSURE(inGas))/(R_IDEAL_GAS_EQUATION*inGas.temperature))


