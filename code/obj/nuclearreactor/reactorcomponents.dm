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

	var/icon_state_inserted = "component_cap"
	var/ui_image = null
	var/temperature = T20C //room temp kelvin as default
	var/heat_transfer_mult = 0.01
	_max_health = 100

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
			RC.temperature += heat_transfer_mult*-deltaT*hTC
			src.temperature += heat_transfer_mult*deltaT*(1/hTC)

			RC.material.triggerTemp(RC,RC.temperature)
			src.material.triggerTemp(src,src.temperature)
		//heat transfer with reactor vessel
		var/obj/machinery/atmospherics/binary/nuclear_reactor/holder = src.loc
		if(istype(holder))
			var/deltaT = holder.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = max(holder.material.getProperty("density"),1)/max(src.material.getProperty("density"),1)
			holder.temperature += heat_transfer_mult*-deltaT*hTC
			src.temperature += heat_transfer_mult*deltaT*(1/hTC)

			holder.material.triggerTemp(holder,holder.temperature)
			src.material.triggerTemp(src,src.temperature)


	proc/processNeutrons(var/list/datum/neutron/inNeutrons)
		if(prob(src.material.getProperty("n_radioactive"))) //spontaneous emission
			inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2,3))
			src.temperature += 100 //TODO make this less arbitrary
		for(var/datum/neutron/N in inNeutrons)
			if(N.velocity == 2 & prob(src.material.getProperty("n_radioactive"))) //stimulated emission
				inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2,3))
				inNeutrons += new /datum/neutron(pick(cardinals), pick(1,2,3))
				inNeutrons -= N
				qdel(N)
				src.temperature += 100 //TODO make this less arbitrary
			else if(prob(src.material.getProperty("density")))
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

////////////////////////////////////////////////////////////////
//Control rod
/obj/item/reactor_component/control_rod
	name = "control rod"
	desc = "A control rod assembly for a nuclear reactor"

////////////////////////////////////////////////////////////////
//Heat exchanger
/obj/item/reactor_component/heat_exchanger
	name = "heat exchanger"
	desc = "A heat exchanger component for a nuclear reactor"
	heat_transfer_mult = 0.2

////////////////////////////////////////////////////////////////
//Gas channel
/obj/item/reactor_component/gas_channel
	name = "gas channel"
	desc = "A gas coolant channel component for a nuclear reactor"
	heat_transfer_mult = 0.05
	var/datum/gas_mixture/current_gas

	processGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = src.current_gas.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = TOTAL_MOLES(src.current_gas)/src.material.getProperty("density")
			src.current_gas.temperature += heat_transfer_mult*-deltaT*hTC
			src.temperature += heat_transfer_mult*deltaT*(1/hTC)
			. = src.current_gas
		src.current_gas = inGas.remove(R_IDEAL_GAS_EQUATION * inGas.temperature)


