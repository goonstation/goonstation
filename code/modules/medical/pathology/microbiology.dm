// A microbe. How surprising.
datum/microbe
	var/name										// The name of the microbial culture.
	var/desc										// What a scientist might see when he looks at this pathogen through a microscope (eg. blue stringy viruses)

	var/mob/infected								// The mob that is infected with this pathogen.

	var/duration									// How long a pathogen stays in an infected mob before being naturally immunized.

	var/cure										// the chemical reagent that sets duration to ~5 when 10u reagents found

	var/list/effects = list()						// A list of symptoms exhibited by those infected with this pathogen.
	//var/list/mutex = list()							// These symptoms are explicitly disallowed by a mutex.

// PROCS AND FUNCTIONS FOR GENERATION

	disposing()
		clear()
		..()

	proc/clear()
		name = ""
		desc = ""
		infected = null
		duration = 1
		cure = ""
		effects = list()
		//mutex = list()

	proc/clone()
		var/datum/microbe/P = new /datum/microbe
		P.setup(0, src)
		return P

	proc/do_prefab(tier)							// for ailments with defined symptoms
		clear()
		var/cdc = generate_name()
		generate_cure(cdc)
		generate_attributes(tier)

	New()
		..()
		setup(0, null)

	proc/generate_name()
		src.name = "CustomCulture"
		return

	proc/generate_effects() //WIP
		//Work on effects first.
		return

	proc/generate_cure() //WIP
		var/list/L = list()
		for(var/R in concrete_typesof(/datum/reagent/medical))
			L += R
		L = sortList(L)
		cure = pick(L)
		cure.onadd(src)
		return

	proc/generate_attributes() //WIP
		var/shape = pick("stringy", "snake", "blob", "spherical", "tetrahedral", "star shaped", "tesselated")
		src.desc = "[red] [shape] [microbes]" //color determined by average of cure reagent and assigned-effect colors
		src.duration = 100
		return

	proc/randomize()
		generate_name()
		generate_effects()
		generate_cure()
		generate_attributes()
		logTheThing("pathology", null, null, "Microbe culture [name] created by randomization.")
		return

	proc/setup(status, var/datum/microbe/origin)
		if (status == 0 && !origin)
			return
		if (origin)
			src.name = origin.name
			src.desc = origin.desc
			src.duration = 100
			src.effects = origin.effects.Copy()
			for (var/datum/pathogeneffects/E in src.effects)
				E.onadd(src)
		else if (status == 1)
			src.randomize()
		else if (!origin && status == 2)
			src.do_prefab(1)
		processing_items.Add(src)

	// handles pathogen duration and natural immunization
	proc/progress_pathogen()
		if (duration)
			duration--
		if (!duration)
			infected.cured(src)

//Generalize for objects and turfs WIP

	proc/turf_act()
		for (var/datum/effect in src.effects)
			effect:turf_act(target, src)
		progress_pathogen()

	proc/object_act()
		for (var/datum/effect in src.effects)
			effect:object_act(target, src)
		progress_pathogen()

	proc/reagent_act()
		for (var/datum/effect in src.effects)
			effect:reagent_act(target, src)
		progress_pathogen()

	proc/mob_act()
		for (var/datum/effect in src.effects)
			effect:mob_act(infected,src)
		progress_pathogen()

	// it's like mob_act, but for dead people!
	proc/mob_act_dead()
		for (var/datum/effect in src.effects)
			effect:mob_act_dead(infected,src)
		progress_pathogen()

	/*//=============================================================================
	//	Events
	//=============================================================================
	// In the following chapter you will encounter the definition for event handlers.
	// Event handlers are available for both pathogens and symptoms.
	//
	//  Defining new events
	// ---------------------
	// 1) Add your event handler here. The event handler should call the event handlers of all symptoms.
	// 2) Define a default event handler in /datum/pathogeneffects. This is necessary so that all symptoms continue working, even if they don't respond to that event.
	// 3) Define a default event handler in /datum/suppressant. This is necessary so that all suppression methods continue working, even if they don't respond to that event.
	// 4) Override the event handler in the symptoms where you want it to react.
	// 5) Call each affecting pathogen's event handler when the event is triggered.
	//
	//  Defining existing events for symptoms
	// ---------------------------------------
	// All events are structured, so that if they take X arguments in the pathogen, they take X+2 arguments in the pathogen effect, so the first argument is always the
	// affected mob, while the last argument is always the affecting pathogen. The equivalent event of the pathogen symptoms has the same name as the pathogen's wrapper
	// event.
	// A good practice is to follow these standards.
	// To define an event for an effect, simply override the appropriate event handler. The pathogen code automatically handles calling these events at the appropriate time.
	//

	// Act when grabbing a mob. Does not return anything, the grab always happens.
	// This event is only fired when the PASSIVE grab comes into play.
	// @TODO: Extend this event to all grab levels. Add the possibility of vetoing.
	proc/ongrab(var/mob/target as mob)
		for (var/effect in src.effects)
			effect:ongrab(infected, target, src)
		suppressant.ongrab(target, src)

	// Act when punched by a mob. Returns a multiplier for the damage done by the punch.
	// A hardened skin symptom might make good use of it one day (AT THE TIME OF WRITING THIS COMMENT THAT DID NOT EXIST OKAY)
	proc/onpunched(var/mob/origin as mob, zone)
		var/ret = 1
		for (var/effect in src.effects)
			ret *= effect:onpunched(infected, origin, zone, src)
		suppressant.onpunched(origin, zone, src)
		return ret

	// Act when punching a mob. Returns a multipier for the damage done by the punch.
	// This opens up the availability for both hulk (quad-damage anyone?) and muscle deficiency diseases.
	// Returning 0 from any symptom vetoes the punch.
	proc/onpunch(var/mob/target as mob, zone)
		var/ret = 1
		for (var/effect in src.effects)
			ret *= effect:onpunch(infected, target, zone, src)
		suppressant.onpunch(target, zone, src)
		return ret

	// Act when successfully disarming or pushing down a mob. Returns whether this may happen.
	// This indicates that ondisarm is a veto event - any of the symptoms has a right to veto the occurrence of the disarm or pushdown.
	// Think of it this way. Suppose you have a muscle disease that makes you weak. When your puny body finally hits the target...
	// ...nothing actually happens because you're a weak mess and failed to even scratch him.
	// Returning 0 from ANY of the symptoms' disarm events will make disarming fail.
	proc/ondisarm(var/mob/target as mob, isPushDown)
		var/ret = 1
		for (var/effect in src.effects)
			ret = min(effect:ondisarm(infected, target, isPushDown, src), ret)
		suppressant.ondisarm(target, isPushDown, src)
		return ret

	// Act when shocked. Returns the amount of damage the shocked mob should actually take (which leaves place for both amplification and suppression)
	// The return system here is more complex than for most other events. The symptoms' onshocked may not only modify the amount of shock damage, but
	// also decide that the presence of the symptom makes the a muscle-event vulnerable pathogen resistant to suppression through shocking.
	proc/onshocked(var/amt, var/wattage)
		var/datum/shockparam/ret = new
		ret.amt = amt
		ret.wattage = wattage
		ret.skipsupp = 0
		for (var/effect in src.effects)
			ret = effect:onshocked(infected, ret, src)
		suppressant.onshocked(ret, src)
		return ret.amt

	// Act when saying something. Returns the message that should be said after the diseases make the appropriate modifications.
	proc/onsay(message)
		for (var/effect in src.effects)
			message = effect:onsay(infected, message, src)
		suppressant.onsay(message, src)
		return message

	// Act on emoting. Vetoing available by returning 0.
	proc/onemote(act, voluntary, param)
		suppressant.onemote(infected, act, voluntary, param, src)
		for (var/effect in src.effects)
			. *= effect:onemote(infected, act, voluntary, param, src)

	// Act when dying. Returns nothing.
	proc/ondeath()
		for (var/effect in src.effects)
			effect:ondeath(infected, src)
		suppressant.ondeath(src)
		return

	// Act when pathogen is cured. Returns nothing.
	proc/oncured()
		for (var/effect in src.effects)
			effect:oncured(infected, src)
		suppressant.oncured(src)
		return

	proc/add_new_symptom(var/list/allowed, var/allow_duplicates = 0)
		var/T = pick(allowed)
		var/datum/pathogeneffects/E = pathogen_controller.path_to_symptom[T]
		if (add_symptom(E, allow_duplicates))
			return 1
		else
			return 0

	proc/add_symptom(var/datum/pathogeneffects/E, var/allow_duplicates = 0)
		if (allow_duplicates || !(E in effects))
			for (var/mutex in E.mutex)
				for (var/T in typesof(mutex))
					if (!(T in mutex))
						mutex += T
			effects += E
			E.onadd(src)
			return 1
		return 0

	proc/remove_symptom(var/datum/pathogeneffects/E, var/all = 0)
		if (all)
			var/rem = 0
			while (E in src.effects)
				src.effects -= E
				rem = 1
			if (rem)
				rebuild_mutex()
		else
			if (E in src.effects)
				src.effects -= E
				rebuild_mutex()

	proc/rebuild_mutex()
		src.mutex = list()
		for (var/datum/pathogeneffects/E in src.effects)
			for (var/mutex in E.mutex)
				for (var/T in typesof(mutex))
					if (!(T in mutex))
						mutex += T

	proc/getHighestTier()
		. = 0
		for(var/datum/pathogeneffects/E in src.effects)
			. = max(., E.rarity)
*/
