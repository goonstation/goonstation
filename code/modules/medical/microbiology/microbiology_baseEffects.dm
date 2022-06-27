ABSTRACT_TYPE(/datum/microbioeffects)
/datum/microbioeffects
	var/name
	var/desc
	var/infect_message = null
	var/infect_attempt_message = null // shown to person when an attempt to directly infect them is made
	var/reactionlist = list()
	var/reactionmessage

	// This is a list of mutual exclusive symptom TYPES.
	// If this contains any symptoms, none of these symptoms will be picked upon mutation or initial raffle.
	// Mutexes cut the ENTIRE object tree - for example, if symptoms a/b, a/c and a/d all exist, then mutexing
	// symptom a will also mutex b, c and d.
	//var/list/mutex = list()

	// A symptom might not always infect everyone around. This is a flat probability: 0 means never infect to 1 means always infect. This is checked PER MOB, not per infect call.
	//var/infection_coefficient = 1


	// mob_act(mob, datum/pathogen) : void
	// This is the center of pathogen symptoms.
	// On every Life() tick, this will be called for every symptom attached to the pathogen. Most pathogens should express their malevolence here, unless they are specifically tailored
	// to only work on events like human interaction or external effects. A symptom therefore should override this proc.
	// mob_act is also responsible for handling the symptom's ability to suppress the pathogen. Check the documentation on suppression in pathogen.dm.
	// OVERRIDE: A subclass (direct or otherwise) is expected to override this.
	proc/mob_act(var/mob/M, var/datum/microbesubdata/origin)

	// mob_act_dead(mob, datum/pathogen) : void
	// This functions identically to mob_act, except it is only called when the mob is dead. (mob_act is not called if that is the case.)
	// OVERRIDE: Only override this if if it needed for the symptom.
	proc/mob_act_dead(var/mob/M, var/datum/microbesubdata/origin)

	// does an infectious snap
	// makes others snap, should possibly infect you in the future if you are made to snap a certain amount of times
	/*proc/infect_snap(var/mob/M as mob, var/datum/pathogen/origin, var/range = 5)
		for (var/mob/I in view(range, M.loc))
			if (I != M && ((isturf(I.loc) && isturf(M.loc) && can_line_airborne(get_turf(M), I, 5)) || I.loc == M.loc))
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = I
					if(prob(100-H.get_disease_protection()))
						SPAWN(rand(0.5,2) SECONDS)
							H.show_message("Pretty catchy tune...")
							H.emote("snap") // consider yourself lucky I haven't implemented snap infection yet, human
*/
	// creates an infective cloud
	// this should give people better feedback about how be infected and how to avoid it
	//proc/infect_cloud(var/mob/M as mob, var/datum/pathogen/origin, var/amount = 5)
	//	return
		/*
		var/turf/T = get_turf(M)
		var/obj/decal/cleanable/pathogen_cloud/D = make_cleanable(/obj/decal/cleanable/pathogen_cloud,T)

		var/datum/reagent/blood/pathogen/Q = new /datum/reagent/blood/pathogen()
		D.reagents = new /datum/reagents(amount)
		Q.volume = amount
		Q.pathogens += origin.pathogen_uid
		Q.pathogens[origin.pathogen_uid] = origin
		D.reagents.reagent_list += "pathogen"
		D.reagents.reagent_list["pathogen"] = Q
		Q.holder = D.reagents
		D.reagents.update_total()
	*/
	// creates an infective puddle
	// this should give people better feedback about how be infected and how to avoid it
	//proc/infect_puddle(var/mob/M as mob, var/datum/pathogen/origin, var/amount = 5)
		//return
		/*
		var/turf/T = get_turf(M)
		var/obj/decal/cleanable/pathogen_sweat/D = make_cleanable(/obj/decal/cleanable/pathogen_sweat,T)

		var/datum/reagent/blood/pathogen/Q = new /datum/reagent/blood/pathogen()
		D.reagents = new /datum/reagents(amount)
		Q.volume = amount
		Q.pathogens += origin.pathogen_uid
		Q.pathogens[origin.pathogen_uid] = origin
		D.reagents.reagent_list += "pathogen"
		D.reagents.reagent_list["pathogen"] = Q
		Q.holder = D.reagents
		D.reagents.update_total()
		*/
	// infect_direct(mob, datum/pathogen) : void
	// This is the proc that handles direct transmission of the pathogen from one mob to another. This should be called in particular infection scenarios. For example, a sweating person
	// gets his bodily fluids onto another when they directly disarm, punch, or grab a person.
	// For INFECT_TOUCH diseases this is automatically called on a successful disarm, punch or grab. When overriding any of these events, use ..() to keep this behaviour.
	// OVERRIDE: Generally, you do not need to override this.
	proc/infect_direct(var/mob/target, var/datum/microbesubdata/S, contact_type = "touch")
		var/datum/microbe/origin = microbio_controls.get_microbe_from_name(S.master.name)
		if (infect_attempt_message)
			target.show_message("<span class='alert'><B>[infect_attempt_message]</B></span>")
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			if(prob(100-H.get_disease_protection()))
				if (target.infected(origin))
					if (infect_message)
						target.show_message(infect_message)
				logTheThing("pathology", origin.infected, target, "infects [constructTarget(target,"pathology")] with [origin.name] due to symptom [name] through direct contact ([contact_type]).")
				return 1

	proc/onadd(var/datum/microbe/P)
		return

	// ====
	// Events from this point on. Their exact behaviour is documented in pathogen.dm. Please do not add any event definitions outside this block.
	// ondisarm(mob, mob, boolean, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/ondisarm(var/mob/M, var/mob/V, isPushDown, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			var/datum/microbe/P = microbio_controls.get_microbe_from_name(origin.master.name)
			infect_direct(V, P, "disarm")
		return 1

	// ongrab(mob, mob, datum/pathogen) : void
	// TODO: Make this a veto event.
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/ongrab(var/mob/M, var/mob/V, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			var/datum/microbe/P = microbio_controls.get_microbe_from_name(origin.master.name)
			infect_direct(V, P, "grab")
		return

	// onpunch(mob, mob, string, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/onpunch(var/mob/M, var/mob/V, zone, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			var/datum/microbe/P = microbio_controls.get_microbe_from_name(origin.master.name)
			infect_direct(V, P, "punching")
		return 1

	// onpunched(mob, mob, string, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/onpunched(var/mob/M, var/mob/A, zone, var/datum/microbesubdata/origin)
		if (prob(origin.probability))
			var/datum/microbe/P = microbio_controls.get_microbe_from_name(origin.master.name)
			infect_direct(A, P, "being punched")
		return 1

	// onshocked(mob, mob, datum/shockparam, datum/pathogen) : datum/shockparam
	// OVERRIDE: Overriding this is situational.
	proc/onshocked(var/mob/M, var/datum/shockparam/ret, var/datum/microbesubdata/origin)
		return //ret

	// onsay(mob, string, datum/pathogen) : string
	// OVERRIDE: Overriding this is situational.
	proc/onsay(var/mob/M, message, var/datum/microbesubdata/origin)
		return message

	// onemote(mob, string, number, string, datum/pathogen) : string
	// OVERRIDE: Overriding this is situational.
	proc/onemote(var/mob/M, act, voluntary, param, var/datum/microbesubdata/origin)
		return 1

	// ondeath(mob, datum/pathogen) : void
	// OVERRIDE: Overriding this is situational.
	proc/ondeath(var/mob/M, var/datum/microbesubdata/origin)
		return

	// oncured(mob, datum/pathogen) : void
	// OVERRIDE: Overriding this is situational.
	proc/oncured(var/mob/M, var/datum/microbesubdata/origin)
		return


	// End of events: please do not add any event definitions outside this block.
	// ====

	// Below is deprecated code and documentation.
	// may_react_to() is replaced with vars on the microbe datum telling the player how many of each effect type there are.
	//
	// may_react_to() : string | null
	// A set of features that you can observe through a microscope and what it might suggest.
	// This will be used to NARROW DOWN what chemicals the pathogen might react to, so that you only need to try a finite set of reagents to determine exactly what symptoms the pathogen has.
	// As this is for narrowing down only, it is encouraged to include false positives.
	// Omitting some reagents from this is also okay - if, say, a family of similar symptoms react to a single reagent in a similar way but each one of them also reacts to (an)other reagent(s)
	// in fundamentally different ways, the latter reagent(s) may be omitted. In the end, this all is up to you though.
	// If the symptom provides no hints, null should be returned.
	//
	// DO RECYCLING!
	// Hints SHOULD be reused moderately often, in order to keep experienced pathologists from immediately identifying the pathogen without testing.
	//
	// Examples of a return value:
	// Non-hint: "There is a fever-inducing gland on the pathogen."
	// Trivial, common symptoms should have this for easy identifiability. Preferrably matching on a few of them, so it takes some work to figure out which it is.
	// Outright tells: "The pathogen appears to collect toxin molecules."
	// - this is very particular, no false positives. Only do this if the hinted reagent does not exactly reveal what the symptom is.
	// Concrete hints: "The pathogen appears to have glands which indicate that they might be receptive to phlogiston, infernite and cryostylane."
	// - this is fairly particular. It is fine but to make it more interesting, most of the symptoms should have a bit more obscure hints.
	// Slightly obscure hints: "The pathogen's behaviour patterns appear to heavily depend on external temperature."
	// - meaning anything that might be hot or cold. This hints at about 3 or 4 different reagents without particularly naming them. This is what we should be mostly aiming for.
	//   Note that this does not necessarily have to mean multiple different reagents. Anything in fits in this category as long as it's not general enough to point at multiple
	//   chemicals, but requires a good knowledge of chemistry to work out. For example, "The pathogen's structure indicates that it may react to chemicals known to induce heart disease."
	//   is clearly initro for someone with chems knowledge, but still is an excellent hint as it's not an outright tell and it does not even name the chemical that should be used.
	// More obscure hints: "The pathogen appears to be receptive to compounds with a single hydroxyl group."
	// - meaning anything that contains or derives from alcohol. This hints at a large family of reagents (all booze and cocktails). This is also fine as long as it's not a riddle
	//   and it is particularly scientific.
	// Very obscure "hint": "The pathogen reacts with chemicals."
	// - well fuck you too, that's very useful, microscope. Do not do this.
	// OVERRIDE: A subclass is expected to override this.
	//proc/may_react_to()
		//return null

	// react_to is replaced by vars on the effects and cures.
	// var/reactionlist = list() containing reagent ids.
	// var/reactionmessage = "" containing the message to output.
	// the zoom var is handled on the microscope code.
	//
	// react_to(string, int) : string | null
	// How a pathogen with this symptom reacts to a reagent being introduced to it.
	// This is:
	// (1) Not continuous - it is only called once.
	// (2) Not active - it is not called when the pathogen is acting in a mob, only when research is being done on a pathogen culture.
	// It must return null if it does not react to the reagent, or text event of an event that is happening (eg. "The pathogens are attempting to escape the space yeti!") if it reacts.
	// The zoom parameter determines the zoom level at which the pathogen is being viewed. The possible values are 0 and 1.
	// Ideally what is visible at zoom level 0: a behaviour pattern for the pathogen.
	//                         at zoom level 1: the reagent's effect on arbitrary imaginary scientific sounding (hexamelone gland, vascular protomembrane) appendage of a pathogen.
	// At least one of the zoom levels should be a good enough hint at what the symptom might do.
	// NOTE: Conforming with the new reagent system, R is now a reagent ID, not a reagent instance.
	// OVERRIDE: A subclass is expected to override this.
	//proc/react_to(var/R, var/zoom)
		//return null
