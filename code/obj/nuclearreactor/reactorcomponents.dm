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
	var/temperature = 293 //room temp kelvin as default
	_max_health = 100


	New()
		..()
		src.setMaterial(getMaterial("steel"))
		_health = _max_health

	proc/processGas(var/inGas)
		return inGas //most components won't touch gas

	proc/processHeat(var/list/adjacentComponents)
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
