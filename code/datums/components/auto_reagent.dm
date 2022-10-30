/// Automatically fills something with reagents... and possible leaks it
TYPEINFO(/datum/component/auto_reagent)
	initialization_args = list(
		ARG_INFO("reagent_id", DATA_INPUT_TEXT, "Reagent to overflow/produce"),
		ARG_INFO("units", DATA_INPUT_NUM, "Units to produce per cycle", 10),
		ARG_INFO("overflowing", DATA_INPUT_BOOL, "Should overflow?", FALSE),
	)
/datum/component/auto_reagent
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Reagent ID to produce
	var/reagent_id = null
	/// Number of reagents to produce per item process
	var/units = 10
	var/overflowing = FALSE

	Initialize(reagent_id=null, units=10, overflowing=FALSE)
		if(!istype(parent,/atom))
			return COMPONENT_INCOMPATIBLE
		. = ..()
		src.reagent_id = reagent_id
		src.units = units
		src.overflowing = overflowing

		if(!istext(src.reagent_id) || isnull(reagents_cache[src.reagent_id]))
			return COMPONENT_INCOMPATIBLE
		if(src.units <= 0)
			return COMPONENT_INCOMPATIBLE

		if(src.overflowing)
			RegisterSignal(parent, list(COMSIG_ATOM_EXAMINE), .proc/examined)
		global.processing_items.Add(src)

	UnregisterFromParent()
		. = ..()
		global.processing_items.Remove(src)
		UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE))

	/// Called every item process tick, handles adding additional reagent units and overflowing when applicable.
	proc/process()
		if(QDELETED(parent))
			global.processing_items.Remove(src)
			return

		var/atom/PA = parent
		var/datum/reagents/R = new()
		R.maximum_volume = src.units
		R.add_reagent(src.reagent_id, src.units)
		R.trans_to(PA, R.total_volume)

		if(src.overflowing && R.total_volume)
			var/turf/T = get_turf(parent)
			if(ismob(PA.loc))
				var/mob/M = PA.loc
				if(prob(50))
					M.visible_message("Something from [M] spills onto [PA.loc].","Your [PA] overflows and spills onto the ground.")
				R.trans_to(T, R.total_volume)
			else if(ismob(parent))
				var/mob/M = parent
				if(prob(33))
					M.visible_message("Something leaks from [PA] onto [T].","You leak onto the ground...")
				R.trans_to(T, R.total_volume)
			else if(isturf(PA.loc))
				if(prob(10))
					PA.visible_message("[PA] spills onto [PA.loc].","You hear the sound of liquid hitting the ground.")
				R.trans_to(T, R.total_volume)

	/// Adds a line to examine text to indicate level of radiation produced
	proc/examined(atom/owner, mob/examiner, list/lines)
		lines += "[ismob(owner) ? capitalize(he_or_she(owner)) : "It"] is dripping."

