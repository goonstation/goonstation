/// If a thing is to be radioactive, slap this component on it. Only call mob.take_radiation_dose directly as a last resort.
TYPEINFO(/datum/component/radioactive)
	initialization_args = list(
		ARG_INFO("radStrength", DATA_INPUT_NUM, "Value of radiation strength \[0-100\]", 100),
		ARG_INFO("decays", DATA_INPUT_BOOL, "Whether this radiation will decay over time (bool)", FALSE),
		ARG_INFO("neutron", DATA_INPUT_BOOL, "Whether this radiation is neutron, and therefor penetrates more (bool)", FALSE),
		ARG_INFO("effectRange", DATA_INPUT_NUM, "How far this effect goes. Do not set too high, it's expensive. \[0-10\]", 1)
	)

/datum/component/radioactive
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/radStrength = 0
	var/decays = FALSE
	var/neutron = FALSE
	var/_added_to_items_processing = FALSE
	var/effect_range = 1
	var/backup_color = null //so hacky

	Initialize(radStrength=100, decays=FALSE, neutron=FALSE, effectRange=1)
		if(!istype(parent,/atom))
			return COMPONENT_INCOMPATIBLE
		. = ..()
		src.radStrength = radStrength
		src.decays = decays
		src.neutron = neutron
		src.effect_range = effectRange
		if(parent.GetComponent(src.type)) //don't redo the filters and stuff if we're a duplicate
			return
		RegisterSignal(parent, list(COMSIG_ATOM_EXAMINE), .proc/examined)
		RegisterSignal(parent, list(COMSIG_ATOM_CROSSED,
			COMSIG_ATOM_ENTERED,
			COMSIG_ATTACKHAND,
			COMSIG_ITEM_EQUIPPED,
			COMSIG_ITEM_PICKUP,
			COMSIG_MOB_GRABBED,
			COMSIG_ITEM_ATTACK_POST,
		), .proc/touched)
		RegisterSignal(parent, list(COMSIG_ITEM_CONSUMED), .proc/eaten)

		if(isitem(parent))
			RegisterSignal(parent, list(COMSIG_ITEM_PROCESS), .proc/ticked)
			if(!(parent in global.processing_items))
				global.processing_items.Add(parent)
				src._added_to_items_processing = TRUE
		else
			global.processing_items.Add(src) //gross - in the event that this component is put on something that isn't an item, use the item processing loop anyway
		var/atom/PA = parent
		var/color = neutron ? "#2e3ae4FF" : "#18e022FF"
		PA.add_filter("radiation_color_\ref[src]", 1, color_matrix_filter(normalize_color_to_matrix(PA.color ? PA.color : "#FFF")))
		src.backup_color = PA.color
		PA.color = null
		PA.add_simple_light("radiation_light_\ref[src]", rgb2num(color)+list(min(128,round(255*radStrength/100))))
		PA.add_filter("radiation_outline_\ref[src]", 2, outline_filter(size=1.3, color=color))

	proc/process()
		if(QDELETED(parent))
			global.processing_items.Remove(src)
			return
		ticked(parent)

	UnregisterFromParent()
		. = ..()
		var/atom/PA = parent
		if(src._added_to_items_processing)
			global.processing_items.Remove(parent)
		global.processing_items.Remove(src)
		PA.remove_simple_light("radiation_light_\ref[src]")
		PA.remove_filter("radiation_outline_\ref[src]")
		PA.remove_filter("radiation_color_\ref[src]")
		PA.color = backup_color
		UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE))
		UnregisterSignal(parent, list(COMSIG_ATOM_CROSSED,
			COMSIG_ATOM_ENTERED,
			COMSIG_ATTACKHAND,
			COMSIG_ITEM_EQUIPPED,
			COMSIG_ITEM_PICKUP,
			COMSIG_MOB_GRABBED,
			COMSIG_ITEM_ATTACK_POST,
		))
		UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED_PARTIAL, COMSIG_ITEM_CONSUMED_ALL))
		if(isitem(parent))
			UnregisterSignal(parent, list(COMSIG_ITEM_PROCESS))
		else if(ismob(parent))
			UnregisterSignal(parent, list(COMSIG_LIVING_LIFE_TICK))

	InheritComponent(datum/component/radioactive/R, i_am_original)
		if (i_am_original)
			if((R.neutron && !src.neutron) || (!R.decays && src.decays)) //neutron overrides non-neutron, permanent overrides temporary
				src.radStrength = R.radStrength
				src.neutron = R.neutron
				src.decays = R.decays
			else if (R.neutron == src.neutron && R.decays == src.decays) //if compatible, stack
				src.radStrength = min(src.radStrength+R.radStrength, 100)
			//else
				//either you tried to apply a decay to a permanent, or a non-neutron to a neutron
				//in which case, do nothing

	proc/ticked(atom/owner, mult=1)
		var/atom/PA = parent
		if(ismob(PA.loc)) //if you're holding it in your hand, you're not a viewer, so special handling
			var/mob/M = PA.loc
			M.take_radiation_dose(mult * (neutron ? 0.8 : 0.2) * (radStrength/100))
		for(var/mob/M in hearers(effect_range,parent)) //hearers is basically line-of-sight
			if(!ON_COOLDOWN(M,"radiation_exposure", 0.5 SECONDS)) //shorter than item tick time, so you can get multiple doses but there's a limit
				M.take_radiation_dose(mult * (neutron ? 0.8 : 0.2) * (radStrength/100))
		if(src.decays && prob(33))
			src.radStrength = max(0, src.radStrength - (1 * mult))
		if(!src.radStrength)
			src.RemoveComponent()

	proc/touched(atom/owner, mob/toucher)
		if(istype(toucher))
			if(!ON_COOLDOWN(toucher,"radiation_exposure", 0.5 SECONDS))
				toucher.take_radiation_dose((neutron ? 1.0 : 0.25) * (radStrength/100))

	proc/eaten(atom/owner, mob/eater)
		if(istype(eater))
			eater.take_radiation_dose((neutron ? 1.6 : 0.8) * (radStrength/100), internal=TRUE) //don't eat radioactive stuff, ya dingus!

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

		lines += "It is [rad_word] with a [pick("fuzzy","sickening","nauseating","worrying")] [neutron ? "blue" : "green"] light.[examiner.job == "Clown" ? " You should touch it!" : ""]"

