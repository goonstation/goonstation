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
	_max_health = 100
	///If this component is melted, you can't take it out of the reactor and it might do some weird stuff
	var/melted = FALSE
	var/static/list/ui_image_base64_cache = list()

	//this should probably be a global, but it isn't afaik
	var/list/cardinals = list(NORTH, NORTHEAST, NORTHWEST, \
		                    SOUTH, SOUTHEAST, SOUTHWEST, \
		                    WEST, NORTHWEST, SOUTHWEST,  \
		                    EAST, NORTHEAST, SOUTHEAST)

	New()
		..()
		src.setMaterial(getMaterial("steel"))
		_health = _max_health
		var/img_check = ui_image_base64_cache[src.type]
		if (img_check)
			src.ui_image = img_check
		else
			var/icon/dummy_icon = icon(initial(src.icon), initial(src.icon_state_inserted))
			src.ui_image = icon2base64(dummy_icon)
			ui_image_base64_cache[src.type] = src.ui_image

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
			var/hTC = max(RC.material.getProperty("density"),1)/max(src.material.getProperty("density"),1)
			if(RC.material.hasProperty("thermal"))
				hTC = hTC*(RC.material.getProperty("thermal")/100)
			if(RC.material.hasProperty("thermal"))
				hTC = hTC*(RC.material.getProperty("thermal")/100)
			RC.temperature += thermal_cross_section*-deltaT*hTC
			src.temperature += thermal_cross_section*deltaT*(1/hTC)

			RC.material.triggerTemp(RC,RC.temperature)
			src.material.triggerTemp(src,src.temperature)
		//heat transfer with reactor vessel
		var/obj/machinery/atmospherics/binary/nuclear_reactor/holder = src.loc
		if(istype(holder))
			var/deltaT = holder.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = max(holder.material.getProperty("density"),1)/max(src.material.getProperty("density"),1)
			holder.temperature += thermal_cross_section*-deltaT*hTC
			src.temperature += thermal_cross_section*deltaT*(1/hTC)

			holder.material.triggerTemp(holder,holder.temperature)
			src.material.triggerTemp(src,src.temperature)


	proc/processNeutrons(var/list/datum/neutron/inNeutrons)
		if(prob(src.material.getProperty("n_radioactive"))) //fast spontaneous emission
			inNeutrons += new /datum/neutron(pick(cardinals), pick(2,3)) //neutron radiation gets you fast neutrons
			src.material.adjustProperty("n_radioactive", -0.1)
			src.material.adjustProperty("radioactive", 0.1)
			src.temperature += 100 //TODO make this less arbitrary
		if(prob(src.material.getProperty("radioactive"))) //spontaneous emission
			inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2))
			src.material.adjustProperty("radioactive", -0.1)
			src.temperature += 100 //TODO make this less arbitrary
		for(var/datum/neutron/N in inNeutrons)
			if(prob(src.material.getProperty("density")*src.neutron_cross_section)) //dense materials capture neutrons, configuration influences that
				//if a neutron is captured, we either do fission or we slow it down
				if(N.velocity == 1 & prob(src.material.getProperty("n_radioactive"))) //neutron stimulated emission
					inNeutrons += new /datum/neutron(pick(cardinals), pick(2,3))
					inNeutrons += new /datum/neutron(pick(cardinals), pick(2,3))
					inNeutrons -= N
					qdel(N)
					src.temperature += 100 //TODO make this less arbitrary
				else if(N.velocity == 1 & prob(src.material.getProperty("radioactive"))) //stimulated emission
					inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2))
					inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2))
					inNeutrons -= N
					qdel(N)
					src.temperature += 100 //TODO make this less arbitrary
				else
					if(prob(src.material.getProperty("hardness"))) //reflection is based on hardness
						N.dir = turn(N.dir,pick(180,225,135)) //either complete 180 or  180+/-45
					N.velocity--
					src.temperature += 1
					if(N.velocity < 0)
						inNeutrons -= N
						qdel(N)
		return inNeutrons

////////////////////////////////////////////////////////////////
//Fuel rod
/obj/item/reactor_component/fuel_rod
	name = "fuel rod"
	desc = "A fuel rod for a nuclear reactor"
	icon_state_inserted = "fuel"
	neutron_cross_section = 1.0
	thermal_cross_section = 0.02

////////////////////////////////////////////////////////////////
//Control rod
/obj/item/reactor_component/control_rod
	name = "control rod"
	desc = "A control rod assembly for a nuclear reactor"
	icon_state_inserted = "control"
	neutron_cross_section = 1.0 //essentially *actual* insertion level
	var/configured_insertion_level = 1.0 //target insertion level

	processNeutrons(list/datum/neutron/inNeutrons)
		. = ..()
		if((!src.melted) & (src.neutron_cross_section != src.configured_insertion_level))
		//step towards configured insertion level
		if(src.configured_insertion_level > src.neutron_cross_section)
			src.neutron_cross_section -= 0.1 //TODO balance - this is 10% per tick, which is like every 3 seconds or something
		else
			src.neutron_cross_section += 0.1

////////////////////////////////////////////////////////////////
//Heat exchanger
/obj/item/reactor_component/heat_exchanger
	name = "heat exchanger"
	desc = "A heat exchanger component for a nuclear reactor"
	icon_state_inserted = "heat"
	thermal_cross_section = 0.2
	neutron_cross_section = 0.1

////////////////////////////////////////////////////////////////
//Gas channel
/obj/item/reactor_component/gas_channel
	name = "gas channel"
	desc = "A gas coolant channel component for a nuclear reactor"
	icon_state_inserted = "gas"
	thermal_cross_section = 0.05
	var/datum/gas_mixture/current_gas

	processGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = src.current_gas.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = TOTAL_MOLES(src.current_gas)/src.material.getProperty("density")
			if(hTC>0)
				src.current_gas.temperature += thermal_cross_section*-deltaT*hTC
				src.temperature += thermal_cross_section*deltaT*(1/hTC)
			. = src.current_gas
		src.current_gas = inGas.remove(R_IDEAL_GAS_EQUATION * inGas.temperature)


