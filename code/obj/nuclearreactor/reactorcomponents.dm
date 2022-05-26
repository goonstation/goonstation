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
	_max_health = 100

	var/static/list/ui_image_base64_cache = list()

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
			var/hTC = RC.material.getProperty("density")/src.material.getProperty("density")
			RC.temperature += 0.1*-deltaT*hTC
			src.temperature += 0.1*deltaT*(1/hTC)

			RC.material.triggerTemp(RC,RC.temperature)
			src.material.triggerTemp(src,src.temperature)
		return 0

	proc/processNeutrons(var/list/inNeutrons)
		return list()

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

////////////////////////////////////////////////////////////////
//Gas channel
/obj/item/reactor_component/gas_channel
	name = "gas channel"
	desc = "A gas channel component for a nuclear reactor"
	var/datum/gas_mixture/current_gas

	processGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			src.current_gas.temperature = src.temperature //TODO temp exchange + pressure handling
			. = src.current_gas
		src.current_gas = inGas.remove(R_IDEAL_GAS_EQUATION * inGas.temperature)


