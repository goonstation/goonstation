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


	proc/onValueChanged(var/datum/material/M, var/new_value)
		return

	proc/onAdded(var/datum/material/M, var/new_value)
		return

	proc/onRemoved(var/datum/material/M)
		return

	proc/getBriefStatString(var/datum/material/M)
		return "[src.name]: [round(M.getProperty(id) / M.getPropertyMax(id), 0.1)]%"

/datum/material_property/electrical_conductivity
	name = "Electrical conductivity"
	id = "electrical"

/datum/material_property/thermal_conductivity
	name = "Thermal conductivity"
	id = "thermal"

/datum/material_property/hardness
	name = "Hardness"
	id = "hard"
	default_value = 27

/datum/material_property/density
	name = "Density"
	id = "density"
	default_value = 27

/datum/material_property/chemical
	name = "Chemical resistance"
	id = "chemical"
	default_value = 27

/datum/material_property/radioactivity
	name = "Radioactivity"
	id = "radioactive"
	default_value = 0

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
	default_value = 0

	onAdded(var/datum/material/M, var/new_value)
		M.addTrigger(TRIGGERS_ON_ADD, new /datum/materialProc/n_radioactive_add())
		M.addTrigger(TRIGGERS_ON_REMOVE, new /datum/materialProc/n_radioactive_remove())
		return

	onRemoved(var/datum/material/M)
		M.removeTrigger(TRIGGERS_ON_ADD, /datum/materialProc/n_radioactive_add)
		M.removeTrigger(TRIGGERS_ON_REMOVE, /datum/materialProc/n_radioactive_remove)
		return
