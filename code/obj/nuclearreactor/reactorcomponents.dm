/////////////////////////////////////////////////////////////////
// Defintion for the nuclear reactor engine internal components
/////////////////////////////////////////////////////////////////

ABSTRACT_TYPE(/obj/reactor_component)
/obj/reactor_component //base component
	name = "base reactor component"
	desc = "You really shouldn't be seeing this - call a coder"
	icon = 'icons/misc/reactorcomponents.dmi'
	icon_state = "fuel_rod"
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
/obj/reactor_component/fuel_rod


////////////////////////////////////////////////////////////////
//Control rod
/obj/reactor_component/control_rod


////////////////////////////////////////////////////////////////
//Heat exchanger
/obj/reactor_component/heat_exchanger


////////////////////////////////////////////////////////////////
//Gas channel
/obj/reactor_component/gas_channel

