/// Base material property. Stuff like conductivity. See: [/datum/material/var/properties]
ABSTRACT_TYPE(/datum/material_property)
/datum/material_property
	/// External name of this property.
	var/name = ""
	/// Internal ID of this property.
	var/id = ""
	/// Min value of this property. Please NOTHING BELOW `1`. It breaks everything.
	var/min_value = 1
	/// Max value of this property. May be modified by quality.
	var/max_value = 9
	/// What should be considered the "default" value of this property?
	var/default_value = 5

	/// Min value for high-prefix. Minimum for the prefix to show up on the object names.
	var/prefix_high_min = 7
	/// Max value for low-prefix. Maximum for the prefix to show up on the object names.
	var/prefix_low_max = 3

	proc/changeValue(var/datum/material/M, var/newValue)
		for(var/X in M.properties)
			if(X == src)
				M.properties[X] = clamp(newValue, min_value, max_value)
				onValueChanged(M, M.properties[X])
				return
		return

	proc/onValueChanged(var/datum/material/M, var/new_value)
		return

	proc/onAdded(var/datum/material/M, var/new_value)
		return

	proc/onRemoved(var/datum/material/M)
		return

	proc/getAdjective(var/datum/material/M)
		return "odd"

/datum/material_property/electrical_conductivity
	name = "Electrical conductivity"
	id = "electrical"

	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "highly insulating"
			if(1 to 2)
				return "insulating"
			if(2 to 4)
				return "slightly insulating"
			if(4 to 6)
				return "slightly conductive"
			if(6 to 8)
				return "conductive"
			if(8 to INFINITY)
				return "highly conductive"

/datum/material_property/thermal_conductivity
	name = "Thermal conductivity"
	id = "thermal"

	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "very temperature-resistant"
			if(1 to 2)
				return "temperature-resistant"
			if(2 to 4)
				return "slightly temperature-resistant"
			if(4 to 6)
				return "slightly thermally-conductive"
			if(6 to 8)
				return "thermally-conductive"
			if(8 to INFINITY)
				return "highly thermally-conductive"

/datum/material_property/hardness
	name = "Hardness"
	id = "hard"

	default_value = 3
	prefix_low_max = 2
	prefix_high_min = 6

	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "very soft"
			if(1 to 2)
				return "soft"
			if(2 to 4)
				return "slightly hard"
			if(4 to 6)
				return "hard"
			if(6 to 8)
				return "very hard"
			if(8 to INFINITY)
				return "extremely hard"

/datum/material_property/density
	name = "Density"
	id = "density"

	default_value = 3
	prefix_low_max = 2
	prefix_high_min = 6

	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "very light"
			if(1 to 2)
				return "light"
			if(2 to 4)
				return "somewhat dense"
			if(4 to 6)
				return "dense"
			if(6 to 8)
				return "very dense"
			if(8 to INFINITY)
				return "extremely dense"

/datum/material_property/reflectivity
	name = "Reflectivity"
	id = "reflective"


	default_value = 0
	prefix_low_max = 1
	prefix_high_min = 5

	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "very dull"
			if(1 to 2)
				return "dull"
			if(2 to 4)
				return "slightly dull"
			if(4 to 6)
				return "slightly reflective"
			if(6 to 8)
				return "reflective"
			if(8 to INFINITY)
				return "very reflective"

	onValueChanged(var/datum/material/M, var/new_value)
		if(new_value >= 7)
			M.addTrigger(M.triggersOnBullet, new /datum/materialProc/reflective_onbullet())
		else
			M.removeTrigger(M.triggersOnBullet, /datum/materialProc/reflective_onbullet)
		return

/datum/material_property/flammability
	name = "Flammability"
	id = "flammable"
	default_value = 1

	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "nonflammable"
			if(1 to 3)
				return "slightly flammable"
			if(3 to 5)
				return "flammable"
			if(5 to 8)
				return "extremely flammable"
			if(8 to INFINITY)
				return "insanely flammable"

/datum/material_property/chemical
	name = "Chemical resistance"
	id = "chemical"
	default_value = 3

	prefix_high_min = 5
	prefix_low_max = 0

	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "very corroded"
			if(1 to 2)
				return "corroded"
			if(2 to 4)
				return "slightly corroded"
			if(4 to 6)
				return "slightly chemical-resistant"
			if(6 to 8)
				return "chemical-resistant"
			if(8 to INFINITY)
				return "highly chemical-resistant"

/datum/material_property/radioactivity
	name = "Radioactivity"
	id = "radioactive"

	prefix_high_min = 1
	prefix_low_max = 9
	default_value = 0

	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "slightly radioactive"
			if(1 to 2)
				return "somewhat radioactive"
			if(2 to 4)
				return "radioactive"
			if(4 to 6)
				return "very radioactive"
			if(6 to 8)
				return "extremely radioactive"
			if(8 to INFINITY)
				return "impossibly radioactive"

	onAdded(var/datum/material/M, var/new_value)
		M.addTrigger(M.triggersOnAdd, new /datum/materialProc/radioactive_add())
		M.addTrigger(M.triggersOnRemove, new /datum/materialProc/radioactive_remove())
		return

	onRemoved(var/datum/material/M)
		M.removeTrigger(M.triggersOnAdd, /datum/materialProc/radioactive_add)
		M.removeTrigger(M.triggersOnRemove, /datum/materialProc/radioactive_remove)
		return

/datum/material_property/neutron_radioactivity
	name = "Neutron Radioactivity"
	id = "n_radioactive"

	prefix_high_min = 1
	prefix_low_max = 9
	default_value = 0


	getAdjective(var/datum/material/M)
		switch(M.getProperty(id))
			if(0 to 1)
				return "glowing slightly blue"
			if(1 to 2)
				return "glowing somewhat blue"
			if(2 to 4)
				return "glowing blue"
			if(4 to 6)
				return "brightly glowing blue"
			if(6 to 8)
				return "brilliantly glowing blue"
			if(8 to INFINITY)
				return "blindingly glowing blue"

	onAdded(var/datum/material/M, var/new_value)
		M.addTrigger(M.triggersOnAdd, new /datum/materialProc/n_radioactive_add())
		M.addTrigger(M.triggersOnRemove, new /datum/materialProc/n_radioactive_remove())
		return

	onRemoved(var/datum/material/M)
		M.removeTrigger(M.triggersOnAdd, /datum/materialProc/n_radioactive_add)
		M.removeTrigger(M.triggersOnRemove, /datum/materialProc/n_radioactive_remove)
		return
/datum/material_property/resonance // Just for molitz, not used for anything else and doubt it will be. Could tie instance boosts to resonance and give other mats resonance for purposes of being good to alloy with molitz.
	name = "Resonance"
	id = "resonance"
	min_value = 1
	max_value = 1
	default_value = 0

	prefix_high_min = 1
	prefix_low_max = 1

	getAdjective(var/datum/material/M)
		return "harmonic"
