/// If a thing is to be radioactive, slap this component on it. Only call mob.take_radiation_dose directly as a last resort.
TYPEINFO(/datum/component/radioactive)
	initialization_args = list(
		ARG_INFO("radStrength", DATA_INPUT_NUM, "Value of radiation strength \[0-100\]", 100),
		ARG_INFO("decays", DATA_INPUT_BOOL, "Whether this radiation will decay over time (bool)", FALSE),
		ARG_INFO("neutron", DATA_INPUT_BOOL, "Whether this radiation is neutron, and therefor penetrates more (bool)", FALSE)
	)

/datum/component/radioactive
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/radStrength = 0
	var/decays = FALSE
	var/neutron = FALSE
	var/glow_color = "#18e022"

	Initialize(radStrength=100, decays=FALSE, neutron=FALSE)
		if(!istype(parent,/atom))
			return COMPONENT_INCOMPATIBLE
		. = ..()
		src.radStrength = radStrength
		src.decays = decays
		src.neutron = neutron
		RegisterSignal(parent, list(COMSIG_ATOM_EXAMINE), .proc/examined)
		RegisterSignal(parent, list(COMSIG_ATOM_CROSSED,
			COMSIG_ATOM_ENTERED,
			COMSIG_ATTACKHAND,
			COMSIG_ITEM_EQUIPPED,
			COMSIG_ITEM_PICKUP,
			COMSIG_MOB_GRABBED,
			COMSIG_ITEM_ATTACK_POST,
		), .proc/touched)
		RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL), .proc/eaten)

		if(isitem(parent))
			RegisterSignal(parent, list(COMSIG_ITEM_PROCESS), .proc/ticked)
		else if(ismob(parent))
			RegisterSignal(parent, list(COMSIG_LIVING_LIFE_TICK), .proc/ticked)
		var/atom/PA = parent
		PA.add_simple_light("radiation_light", rgb2num(neutron ? "#2e3ae4d2" : "#18e022d2"))

	UnregisterFromParent()
		. = ..()
		var/atom/PA = parent
		PA.remove_simple_light("radiation_light")

	proc/ticked(atom/owner, mult=1)
		for(var/mob/M in viewers(1,src))
			M.take_radiation_dose((neutron ? 3 : 1) * (radStrength/1000))

	proc/touched(atom/owner, mob/toucher)
		toucher.take_radiation_dose((neutron ? 3 : 1) * (radStrength/1000))

	proc/eaten(atom/owner, mob/eater)
		eater.take_radiation_dose((neutron ? 3 : 1) * (radStrength/100)) //don't eat radioactive stuff, ya dingus!

	proc/examined(atom/owner, mob/examiner, list/lines)
		var/rad_word = ""
		switch(radStrength)
			if(0 to 10)
				rad_word = "barely glowing"
			if(10 to 30)
				rad_word = "glowing softly"
			if(30 to 70)
				rad_word = "glowing brightly"
			if(70 to 90)
				rad_word = "shining"
			if(90 to INFINITY)
				rad_word = "radiating blindingly"

		lines += "It is [rad_word] with a [neutron ? "blue" : "green"] light.[examiner.job == "Clown" ? " You should touch it!" : ""]"
