datum/controller/microbe

	var/list/path_to_effect = list()
	var/list/path_to_suppressant = list()

	var/list/pathogen_affected_reagents = list("blood", "pathogen", "bloodc")

	var/list/used = list() 							//list to ensure nomenclature uniquenes

	var/uid = null
	var/creation_time = null
	var/next_uid = 1
	var/next_puid = 1

	New(var/microbio_uid)
		..()
		creation_time = world.time / 600
		src.uid = microbio_uid

	//The functions below might be refactored from patho:

	//Mark who got infected on the CDC panel
	//Mark Patient Zero on the CDC panel
	//Mark who is cured on the CDC panel

	//TOPIC: ADMIN ONLY
		//Cure one person
		//Cure every microbe infection
		//Microbe Creator
			//Reset
			//Name
			//Infection Count
			//Total Duration
			//Suppressant/Cure
			//Add effect
			//Remove effect
			//Create
		//Microbe Data (Manipulate existing microbes)
			//Name ("Rename to?")
			//Infection Count ("")
			//"Cure all who have this specific microbial culture"
			//"Infect a selected player with this culture"
			//"Spawn a vial containing this microbial culture"
		//Effect Data
			//Input to locate effect, output effect.desc
		////////////////////////////////////
		//Ckey checking procs to handle stratae of admins and patho panel access
		////
		//CDC HTML Infrastructure
			//All of it will be TGUI

	New()
		..()

		for (var/E in concrete_typesof(/datum/microbioeffects))
			path_to_effect[E] = new E()

		//Define all paths to suppressants
		for (var/T in childrentypesof(/datum/suppressant))
			path_to_suppressant[T] = new T()

var/global/datum/controller/microbe/microbe_controller = new()	//Callable everywhere.

// todo: remove this, port. (To where?)
// A wrapper record returned by the onshocked event of a pathogen symptom.
datum/shockparam
	var/amt
	var/wattage
	var/skipsupp

// A microbe. How surprising.
datum/microbe
	var/name										// The name of the microbial culture.
	var/desc										// What a scientist might see when he looks at this pathogen through a microscope (eg. blue stringy viruses)

	var/mob/infected								// The mob that is infected with this pathogen.
	var/infectioncount								// Int variable, used to limit transmissible spread for singular cultures

	var/duration									// Counter for durationtotal
	var/durationtotal								// How long a pathogen stays in an infected mob before being naturally immunized.

	var/datum/suppressant/suppressant				// Handles curing

	var/list/effects = list()						// A list of symptoms exhibited by those infected with this pathogen.
	var/list/effectdata = list()					// used for custom var calls
	//var/list/mutex = list()						// These symptoms are explicitly disallowed by a mutex.

	var/microbio_uid								// UID for a microbe.
	var/microbio_playerid							// sub-UID for multiple players with different infection times
	var/ticked										// Stops runtimes.
	var/probability									// Used in the effect probability function.

// PROCS AND FUNCTIONS FOR GENERATION

	disposing()
		clear()
		..()

	proc/clear()
		name = ""
		desc = ""
		infected = null
		infectioncount = null
		duration = 1
		durationtotal = 1
		suppressant = null
		effects = list()
		microbio_uid = 0
		microbio_playerid = 0
		//mutex = list()
		ticked = 0
		probability = 0

	proc/do_prefab(tier)							// for ailments with defined symptoms
		clear()
		generate_name()
		generate_cure(src)
		generate_attributes()

	New()
		..()
		setup(0, null)

	proc/generate_name()
		src.microbio_uid = "[microbe_controller.next_uid]"
		microbe_controller.next_uid++
		src.microbio_playerid = "[microbe_controller.next_puid]"
		microbe_controller.next_puid++
		src.name = "Custom Culture UID [src.microbio_uid]"
		return

	proc/generate_effects() //WIP
		var/random = rand(2,5)
		for (var/i = 0, i <= random, i++)
			add_new_symptom(microbe_controller.path_to_effect)


	proc/generate_cure(var/datum/microbe/P) //WIP
		var/S = pick(microbe_controller.path_to_suppressant)
		P.suppressant = microbe_controller.path_to_suppressant[S]


	proc/generate_attributes() //WIP
		var/shape = pick("stringy", "snake", "blob", "spherical", "tetrahedral", "star shaped", "tesselated")
		src.desc = "[suppressant.color] [shape] microbes" //color determined by average of cure reagent and assigned-effect colors
		src.durationtotal = 2*rand(60,120)					//4 to 8 minute lifespan
		src.duration = src.durationtotal - 1
		src.probability = 0
		src.infectioncount = 3								// See below for explanation.

		//Infection count should be dependent on active player count, balanced at ~5-10% of living serverpop
		//For Goon1 at high pop (90-110), ~10 people per microbial culture
		//INFECTIONCOUNT IS CURRENTLY NOT A GLOBAL COUNT! IT IS A BRANCHING COUNTER!
		///////////////////////////////////////////////////////////////
		/** An infection count of 4 creates a propogation tree, because the count decreases on transmission and is not global.
		 * 4
		 * | \
		 * 3   3
		 * | \ | \
		 * 2 2 2 2
		 * |\|\|\|\
		 * 111111111
		 * ................
		 * 0000000000000000
		 *
		 * At the end, 16 different people could have been infected, assuming all potential transmissions occured.
		 *
		 * The maximum number of infections for a given infectioncount var is 2^(infectioncount).
		 *
		 * I am starting with (3), or 8 maximum infections, because I believe that 8 is a
		 * reasonable value for both highpop and lowpop (20-40) servers.
		 *
		 * I have no idea if this is an adequate implementation in the dev/admin/mentor's opinions.
		*/
		//Taken from the podwars code...
		//for (var/datum/mind/m in pw_team.members)
			//if (m.current?.ckey)
				//active_players ++

	proc/randomize()
		generate_name()
		generate_effects()
		generate_cure(src)
		generate_attributes()
		logTheThing("pathology", null, null, "Microbe culture [name] created by randomization.")
		return

	proc/setup(status, var/datum/microbe/origin)
		if (status == 0 && !origin)
			return
		if (origin)
			src.name = origin.name
			src.desc = origin.desc
			src.infectioncount = origin.infectioncount
			src.durationtotal = origin.durationtotal
			src.duration = origin.duration						// Start from the top for new infections/generation
			src.effects = origin.effects.Copy()
			for (var/datum/microbioeffects/E in src.effects)
				E.onadd(src)
			src.suppressant = origin.suppressant
			src.microbio_uid = origin.microbio_uid
			src.microbio_playerid = origin.microbio_playerid			// REMEMBER TO INCREMENT THE PUID EVERY INFECTION!
			src.ticked = 0
			src.probability = 0
		else if (status == 1)
			randomize()
		else if (!origin && status == 2)
			src.do_prefab(1)
		processing_items.Add(src)

	proc/process()
		if (ticked)
			ticked = 0

	// Handles pathogen duration and natural immunization.
	// It is critical that microbial infections are inherently transient (non-chronic).
	// All old pathology diseases were practically chronic (permanent), which isn't true for
	// most human-contagious diseases at all.
	// Pathology also used stages to divide effect severity, which caused code bloating.
	/////////////////////////////////////////////////////////////////////////////////
	// progress_pathogen uses a continuous downward parabola function to determine the
	// probability for effects to act. The functionn zeroed at the
	// initial time of infection and at natural immunization.
	// The probability factors manipulate the function to move the apex of the parabola to (5),
	// representing a 5% base effect chance.
	// ceil() wraps the entire function to round probability to the higher integer.
	/////////////////////////////////////////////////////////////////////////////////
	// P(t) = -a*t^2 + b*t
	// Where a = 20/durationtotal**2 and b = 20/durationtotal
	proc/progress_pathogen(var/datum/microbe/P)
		if (P.duration <= 0)
			infected.cured(src)
			return
		var/B = 20/P.durationtotal
		var/A = B/P.durationtotal
		src.probability = ceil(-A*P.duration**2+B*P.duration)
		var/iscured = P.suppressant.suppress_act(src)
		if (iscured)
			P.duration = ceil(P.duration/2) - 1
			return
		else
			P.duration--							//  Wrap into process

//Generalize for objects and turfs WIP

	proc/turf_act(var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:turf_act(null, src)
		progress_pathogen(P)

	proc/object_act(var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:object_act(null, src)
		progress_pathogen(P)

	proc/reagent_act(var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:reagent_act(null, src)
		progress_pathogen(P)

	proc/mob_act(var/mob/M as mob, var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:mob_act(infected,src)
		progress_pathogen(P)

	// it's like mob_act, but for dead people!
	proc/mob_act_dead(var/mob/M as mob, var/datum/microbe/P)
		for (var/datum/effect in src.effects)
			effect:mob_act_dead(infected,src)
		progress_pathogen(P)

	//=============================================================================
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
		var/datum/microbioeffects/E = microbe_controller.path_to_effect[T]
		if (add_symptom(E, allow_duplicates))
			return 1
		else
			return 0

	proc/add_symptom(var/datum/microbioeffects/E, var/allow_duplicates = 0)
		if (allow_duplicates || !(E in effects))
			/*for (var/mutex in E.mutex)
				for (var/T in typesof(mutex))
					if (!(T in mutex))
						mutex += T*/
			effects += E
			E.onadd(src)
			return 1
		else return 0
/*
	proc/remove_symptom(var/datum/microbioeffects/E, var/all = 0)
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
				*/
/*
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
