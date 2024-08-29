/// Base material property. Stuff like conductivity. See: [/datum/material/var/properties]
ABSTRACT_TYPE(/datum/material_property)
/datum/material_property
	/// External name of this property.
	var/name = ""
	/// Internal ID of this property.
	var/id = ""
	/// Min value of this property. Please NOTHING BELOW `1`. It breaks everything.
	var/min_value = 1
	/// Max value of this property.
	var/max_value = 81
	/// What should be considered the "default" value of this property?
	var/default_value = 41

	/// Min value for high-prefix. Minimum for the prefix to show up on the object names.
	var/prefix_high_min = 27
	/// Max value for low-prefix. Maximum for the prefix to show up on the object names.
	var/prefix_low_max = 63


	proc/onValueChanged(var/datum/material/M, var/new_value)
		return

	proc/onAdded(var/datum/material/M, var/new_value)
		return

	proc/onRemoved(var/datum/material/M)
		return

/datum/material_property/electrical_conductivity
	name = "Electrical conductivity"
	id = "electrical"

/datum/material_property/thermal_conductivity
	name = "Thermal conductivity"
	id = "thermal"

/datum/material_property/hardness
	name = "Hardness"
	id = "hard"

	default_value = 3
	prefix_low_max = 2
	prefix_high_min = 6

/datum/material_property/density
	name = "Density"
	id = "density"

	default_value = 3
	prefix_low_max = 2
	prefix_high_min = 6

/datum/material_property/reflectivity
	name = "Reflectivity"
	id = "reflective"


	default_value = 0
	prefix_low_max = 1
	prefix_high_min = 5

	onValueChanged(var/datum/material/M, var/new_value)
		if(new_value >= 7)
			M.addTrigger(TRIGGERS_ON_BULLET, new /datum/materialProc/reflective_onbullet())
		else
			M.removeTrigger(TRIGGERS_ON_BULLET, /datum/materialProc/reflective_onbullet)
		return

/datum/material_property/flammability
	name = "Flammability"
	id = "flammable"
	default_value = 1

/datum/material_property/chemical
	name = "Chemical resistance"
	id = "chemical"
	default_value = 3

	prefix_high_min = 5
	prefix_low_max = 0

/datum/material_property/radioactivity
	name = "Radioactivity"
	id = "radioactive"

	prefix_high_min = 1
	prefix_low_max = 9
	default_value = 0
	min_value = 0

	onAdded(var/datum/material/M, var/new_value)
		M.addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/radioactive_add())
		M.addTrigger(TRIGGERS_ON_REMOVE, new /datum/materialProc/radioactive_remove())
		M.addTrigger(TRIGGERS_ON_TEMP, new /datum/materialProc/radioactive_temp())
		return

	onRemoved(var/datum/material/M)
		M.removeTrigger(TRIGGERS_ON_ADD, /datum/materialProc/radioactive_add)
		M.removeTrigger(TRIGGERS_ON_REMOVE, /datum/materialProc/radioactive_remove)
		M.removeTrigger(TRIGGERS_ON_TEMP, new /datum/materialProc/radioactive_temp())
		return

/datum/material_property/neutron_radioactivity
	name = "Neutron Radioactivity"
	id = "n_radioactive"

	prefix_high_min = 1
	prefix_low_max = 9
	default_value = 0
	min_value = 0

	onAdded(var/datum/material/M, var/new_value)
		M.addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/n_radioactive_add())
		M.addTrigger(TRIGGERS_ON_REMOVE, new /datum/materialProc/n_radioactive_remove())
		return

	onRemoved(var/datum/material/M)
		M.removeTrigger(TRIGGERS_ON_ADD, /datum/materialProc/n_radioactive_add)
		M.removeTrigger(TRIGGERS_ON_REMOVE, /datum/materialProc/n_radioactive_remove)
		return

/// Literally just indicating that it can be refined into good nuclear fuel in the centrifuge
/datum/material_property/spent_fuel
	name = "Fissile Isotopes"
	id = "spent_fuel"

	min_value = 0
	prefix_high_min = 0.1
	prefix_low_max = 9
	default_value = 0

/datum/material_property/molitz_bubbles
	name = "Gas Pockets"
	id = "molitz_bubbles"

	min_value = 0
	prefix_high_min = 0.1
	prefix_low_max = 9
	default_value = 0

/datum/material_property/plasma_offgas
	name = "Active Plasma"
	id = "plasma_offgas"

	min_value = 0
	prefix_high_min = 0.1
	prefix_low_max = 9
	default_value = 0
