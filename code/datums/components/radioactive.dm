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
	var/radStrength_neutron = 0
	/// How much radStrength will decay over time. It will take ~ 6 * radStrength seconds to decay completely.
	var/decay_target = 0
	var/decay_target_neutron = 0
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
		var/atom/A = parent
		if(A.material?.hasTrigger(TRIGGERS_ON_ADD, /datum/materialProc/radiation_immune_add))
			// This material is immune to radiation. Don't register for anything.
			src.radStrength = 0
			src.radStrength_neutron = 0
			src.effect_range = 0
			return
		if(neutron)
			src.radStrength_neutron = radStrength
			if(!decays)
				src.decay_target_neutron = radStrength
		else
			src.radStrength = radStrength
			if(!decays)
				src.decay_target = radStrength
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
		if(!src.radStrength && !src.radStrength_neutron)
			return
		var/atom/PA = parent
		var/perc_neutron = src.radStrength_neutron / (src.radStrength + src.radStrength_neutron)
		var/perc_rads = 1 - perc_neutron

		var/list/rgb_rads = rgb2num("#18e022")
		var/list/rgb_neutron = rgb2num("#2e3ae4")
		var/list/rgb_comb = list(
			(rgb_rads[1] * perc_rads) + (rgb_neutron[1] * perc_neutron),
			(rgb_rads[2] * perc_rads) + (rgb_neutron[2] * perc_neutron),
			(rgb_rads[3] * perc_rads) + (rgb_neutron[3] * perc_neutron))
		var/rad_color = rgb(rgb_comb[1], rgb_comb[2], rgb_comb[3], 255)
		if(PA.color)
			src._backup_color = PA.color
			PA.add_filter("radiation_color_\ref[src]", 98, color_matrix_filter(normalize_color_to_matrix(PA.color ? PA.color : "#FFF")))
			PA.color = null
		if (isturf(PA))
			PA.add_simple_light("radiation_light_\ref[src]", rgb2num(rad_color))
		else if(src.our_light)
			src.our_light.set_color(rgb_comb[1], rgb_comb[2], rgb_comb[3])
			src.our_light.enable()
		else
			src.our_light = PA.AddComponent(/datum/component/loctargeting/simple_light, rgb_comb[1], rgb_comb[2], rgb_comb[3], 255, TRUE)
		if(istype(PA, /turf))
			if(isnull(src._turf_glow))
				src._turf_glow = image('icons/effects/effects.dmi', "greyglow")
			src._turf_glow.color = rad_color //we can do this because overlays take a copy of the image and do not preserve the link between them
			src._turf_glow.alpha = 50
			PA.AddOverlays(src._turf_glow, "radiation_overlay_\ref[src]")
		else
			var/outline_size = (0.85 * (radStrength/100)) + 0.15
			var/outline_size_n = (0.85 * (radStrength_neutron/100)) + 0.15
			if(src.radStrength_neutron)
				PA.add_filter("n_radiation_outline_\ref[src]", 99, outline_filter(size=outline_size_n, color="#2e3ae4", flags=OUTLINE_SQUARE))
			if(src.radStrength)
				PA.add_filter("radiation_outline_\ref[src]", 100, outline_filter(size=outline_size, color="#18e022", flags=OUTLINE_SQUARE))

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
		PA.remove_filter("n_radiation_outline_\ref[src]")
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
		if (!i_am_original)
			return
		var/atom/PA = parent
		if(PA.material?.hasTrigger(TRIGGERS_ON_ADD, /datum/materialProc/radiation_immune_add))
			return

		src.radStrength = min(100, src.radStrength + R.radStrength)
		src.radStrength_neutron = min(100, src.radStrength_neutron + R.radStrength_neutron)
		src.decay_target = min(100, src.decay_target + R.decay_target)
		src.decay_target_neutron = min(100, src.decay_target_neutron + R.decay_target_neutron)
		src.do_filters()

	/// Called every item process tick, handles applying radiation effect to nearby atoms and also decay.
	proc/ticked(atom/owner, mult=1)
		var/atom/PA = parent
		var/rad_dose = mult * ((radStrength * 0.4 SIEVERTS) / 100) + ((radStrength_neutron * 0.8 SIEVERTS) / 100)
		if(ismob(PA.loc)) //if you're holding it in your hand, you're not a viewer, so special handling
			var/mob/M = PA.loc
			if(!ON_COOLDOWN(M, "radiation_exposure", 0.5 SECONDS))
				M.take_radiation_dose(rad_dose)
		for(var/mob/living/M in hearers(effect_range, parent)) //hearers is basically line-of-sight
			if(!ON_COOLDOWN(M,"radiation_exposure", 0.5 SECONDS) && !isintangible(M)) //shorter than item tick time, so you can get multiple doses but there's a limit
				M.take_radiation_dose(rad_dose * (src.effect_range - GET_DIST(M, PA) + 1) / (max(src.effect_range, 1)) * 0.8) //lnear, not inverse square because it plays nicer in game

		var/update_filters = FALSE
		if(src.radStrength > src.decay_target && prob(33))
			src.radStrength = max(src.decay_target, src.radStrength - (1 * mult))
			update_filters = TRUE
		if(src.radStrength_neutron > src.decay_target_neutron && prob(33))
			src.radStrength_neutron = max(src.decay_target_neutron, src.radStrength_neutron - (1 * mult))
			update_filters = TRUE
		if(update_filters)
			src.do_filters()
		if(!src.radStrength && !src.radStrength_neutron)
			src.RemoveComponent()

	/// Called when an item is picked up or hand attacked.
	proc/touched(atom/owner, mob/toucher)
		if(istype(toucher))
			if(!ON_COOLDOWN(toucher, "radiation_exposure", 0.5 SECONDS))
				var/rad_dose = ((radStrength * 0.3 SIEVERTS) / 100) + ((radStrength_neutron * 0.9 SIEVERTS) / 100)
				toucher.take_radiation_dose(rad_dose)

	/// Called when a radioactive thing is eaten. High dose to account for radioactive things continuing to irradiate you from the stomach.
	proc/eaten(atom/owner, mob/eater)
		if(istype(eater))
			var/rad_dose = ((radStrength * 2 SIEVERTS) / 100) + ((radStrength_neutron * 4 SIEVERTS) / 100)
			eater.take_radiation_dose(rad_dose, internal=TRUE) //don't eat radioactive stuff, ya dingus!

	/// Adds a line to examine text to indicate level of radiation produced
	proc/examined(atom/owner, mob/examiner, list/lines)
		if(!src.radStrength && !src.radStrength_neutron)
			return
		var/rad_word = ""
		switch(src.radStrength + src.radStrength_neutron)
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
		var/line_mob = ismob(owner) ? capitalize(he_or_she(owner)) : "It"
		var/line_light = "is [rad_word] with a [pick("fuzzy","sickening","nauseating","worrying")]"
		var/line_light_color = (src.radStrength > 0) ? ((src.radStrength_neutron > 0) ? "blue and green" : "green") : "blue"
		var/line_clown = "[examiner.traitHolder?.hasTrait("training_clown") ? " You should touch [ismob(owner) ? him_or_her(owner) : "it"]!" : ""]"
		lines += "[line_mob] [line_light] [line_light_color] light.[line_clown]"

	/// Returns level of normal radioactivity (0 to 100) - note that SEND_SIGNAL returns 0 if the signal is not registered
	proc/get_radioactivity(atom/owner, list/return_val)
		if(isnull(return_val))
			return_val = list()
		return_val += src.radStrength
		return TRUE
