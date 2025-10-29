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
	/// Percentage of max value to apply on various actions. A radStrength of 100 is very radioactive, killing most humans quickly
	var/radStrength = 0
	/// Does this radiation source slowly decay over time? If so, it will take ~ 6 * radStrength seconds to decay completely.
	var/decays = FALSE
	/// Is this radiation source a neutron source? If it is, it does more damage per dose. Associated with n_radiation mat property.
	var/neutron = FALSE
	/// Internal, do not touch - keeps a record of whether or not we had to add this to the item processing list
	var/_added_to_items_processing = FALSE
	/// How wide a range this radiation source affects. Greater than one should be very rarely used, since all atoms in this range will be exposed per tick
	var/effect_range = 1
	/// Internal, do not touch - keeps a record of atom.color since we override it with filters.
	var/_backup_color = null //so hacky
	/// Internal, store of turf glow overlay
	var/static/image/_turf_glow = null
	/// Internal, reference to light component
	var/datum/component/loctargeting/simple_light/our_light

	Initialize(radStrength=100, decays=FALSE, neutron=FALSE, effectRange=1)
		if(!istype(parent,/atom) || parent.type == /turf/space) //exact type check to exclude ocean floors
			return COMPONENT_INCOMPATIBLE
		. = ..()
		src.radStrength = radStrength
		src.decays = decays
		src.neutron = neutron
		src.effect_range = effectRange
		if(parent.GetComponent(src.type)) //don't redo the filters and stuff if we're a duplicate
			return

		RegisterSignal(parent, COMSIG_ATOM_RADIOACTIVITY, PROC_REF(get_radioactivity))
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examined))
		RegisterSignals(parent, list(COMSIG_ATOM_CROSSED,
			COMSIG_ATOM_ENTERED,
			COMSIG_ATTACKHAND,
			COMSIG_ITEM_EQUIPPED,
			COMSIG_ITEM_PICKUP,
			COMSIG_MOB_GRABBED,
			COMSIG_ITEM_ATTACK_POST,
		), PROC_REF(touched))
		RegisterSignals(parent, list(COMSIG_ITEM_CONSUMED, COMSIG_ITEM_CONSUMED_PARTIAL), PROC_REF(eaten))

		if(isitem(parent))
			RegisterSignal(parent, COMSIG_ITEM_PROCESS, PROC_REF(ticked))
			if(!(parent in global.processing_items))
				global.processing_items.Add(parent)
				src._added_to_items_processing = TRUE
		else
			global.processing_items.Add(src) //gross - in the event that this component is put on something that isn't an item, use the item processing loop anyway
		src.do_filters()

	proc/do_filters()
		var/atom/PA = parent
		var/color = (neutron ? "#2e3ae4" : "#18e022") + num2hex(round(128 * radStrength/100) + 16, 2) //base color + alpha
		if(PA.color && isnull(src._backup_color))
			src._backup_color = PA.color
			PA.add_filter("radiation_color_\ref[src]", 99, color_matrix_filter(normalize_color_to_matrix(PA.color ? PA.color : "#FFF")))
			PA.color = null
		if (isturf(PA))
			PA.add_simple_light("radiation_light_\ref[src]", rgb2num(color))
		else
			var/list/color_composition = rgb2num(color)
			our_light = PA.AddComponent(/datum/component/loctargeting/simple_light, color_composition[1], color_composition[2], color_composition[3], color_composition[4], TRUE)
		if(istype(PA, /turf))
			if(isnull(src._turf_glow))
				src._turf_glow = image('icons/effects/effects.dmi', "greyglow")
			src._turf_glow.color = color //we can do this because overlays take a copy of the image and do not preserve the link between them
			src._turf_glow.alpha = 50
			PA.AddOverlays(src._turf_glow, "radiation_overlay_\ref[src]")
		else
			var/outline_color = (neutron ? "#2e3ae4" : "#18e022")
			var/outline_size = (0.85 * radStrength/100) + 0.2
			PA.add_filter("radiation_outline_\ref[src]", 100, outline_filter(size=outline_size, color=outline_color, flags=OUTLINE_SQUARE))

	proc/process()
		if(QDELETED(parent) || !parent.datum_components)
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
		QDEL_NULL(src.our_light)
		PA.remove_filter("radiation_outline_\ref[src]")
		PA.remove_filter("radiation_color_\ref[src]")
		PA.ClearSpecificOverlays("radiation_overlay_\ref[src]")
		PA.color = src._backup_color
		UnregisterSignal(parent, list(COMSIG_ATOM_RADIOACTIVITY))
		UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE))
		UnregisterSignal(parent, list(COMSIG_ATOM_CROSSED,
			COMSIG_ATOM_ENTERED,
			COMSIG_ATTACKHAND,
			COMSIG_ITEM_EQUIPPED,
			COMSIG_ITEM_PICKUP,
			COMSIG_MOB_GRABBED,
			COMSIG_ITEM_ATTACK_POST,
		))
		UnregisterSignal(parent, list(COMSIG_ITEM_CONSUMED, COMSIG_ITEM_CONSUMED_PARTIAL))
		if(isitem(parent))
			UnregisterSignal(parent, list(COMSIG_ITEM_PROCESS))

	InheritComponent(datum/component/radioactive/R, i_am_original)
		if (i_am_original)
			if((R.neutron && !src.neutron) || (!R.decays && src.decays)) //neutron overrides non-neutron, permanent overrides temporary
				src.radStrength = R.radStrength
				src.neutron = R.neutron
				src.decays = R.decays
			else if (R.neutron == src.neutron && R.decays == src.decays) //if compatible, stack
				src.radStrength = max(src.radStrength, R.radStrength)
			src.do_filters()
			//else
				//either you tried to apply a decay to a permanent, or a non-neutron to a neutron
				//in which case, do nothing

	/// Called every item process tick, handles applying radiation effect to nearby atoms and also decay.
	proc/ticked(atom/owner, mult=1)
		var/atom/PA = parent
		if(ismob(PA.loc)) //if you're holding it in your hand, you're not a viewer, so special handling
			var/mob/M = PA.loc
			if(!ON_COOLDOWN(M, "radiation_exposure", 0.5 SECONDS))
				M.take_radiation_dose(mult * (neutron ? 0.8 SIEVERTS: 0.4 SIEVERTS) * (radStrength/100))
		for(var/mob/living/M in hearers(effect_range, parent)) //hearers is basically line-of-sight
			if(!ON_COOLDOWN(M,"radiation_exposure", 0.5 SECONDS) && !isintangible(M)) //shorter than item tick time, so you can get multiple doses but there's a limit
				M.take_radiation_dose(mult * (neutron ? 0.8 SIEVERTS: 0.4 SIEVERTS) * (radStrength/100) * (src.effect_range - GET_DIST(M, PA) + 1) / (max(src.effect_range, 1)) * 0.8) //lnear, not inverse square because it plays nicer in game
		if(src.decays && prob(33))
			src.radStrength = max(0, src.radStrength - (1 * mult))
			src.do_filters()
		if(!src.radStrength)
			src.RemoveComponent()

	/// Called when an item is picked up or hand attacked.
	proc/touched(atom/owner, mob/toucher)
		if(istype(toucher))
			if(!ON_COOLDOWN(toucher, "radiation_exposure", 0.5 SECONDS))
				toucher.take_radiation_dose((neutron ? 0.9 SIEVERTS: 0.3 SIEVERTS) * (radStrength/100))

	/// Called when a radioactive thing is eaten. High dose to account for radioactive things continuing to irradiate you from the stomach.
	proc/eaten(atom/owner, mob/eater)
		if(istype(eater))
			eater.take_radiation_dose((neutron ? 4 SIEVERTS: 2 SIEVERTS) * (radStrength/100), internal=TRUE) //don't eat radioactive stuff, ya dingus!

	/// Adds a line to examine text to indicate level of radiation produced
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

		lines += "[ismob(owner) ? capitalize(he_or_she(owner)) : "It"] is [rad_word] with a [pick("fuzzy","sickening","nauseating","worrying")] [neutron ? "blue" : "green"] light.[examiner.job == "Clown" ? " You should touch [ismob(owner) ? him_or_her(owner) : "it"]!" : ""]"

	/// Returns level of radioactivity (0 to 100) - note that SEND_SIGNAL returns 0 if the signal is not registered
	proc/get_radioactivity(atom/owner, list/return_val)
		if(isnull(return_val))
			return_val = list()
		return_val += src.radStrength
		return TRUE
