datum/pathogeneffects
	var/name
	var/desc
	var/infect_type = 0

	var/spread = SPREAD_FACE | SPREAD_BODY | SPREAD_HANDS | SPREAD_AIR

	var/rarity = RARITY_ABSTRACT
	var/infect_message = null
	var/infect_attempt_message = null // shown to person when an attempt to directly infect them is made

	var/beneficial = 0

	// This is a list of mutual exclusive symptom TYPES.
	// If this contains any symptoms, none of these symptoms will be picked upon mutation or initial raffle.
	// Mutexes cut the ENTIRE object tree - for example, if symptoms a/b, a/c and a/d all exist, then mutexing
	// symptom a will also mutex b, c and d.
	var/list/mutex = list()

	// A symptom might not always infect everyone around. This is a flat probability: 0 means never infect to 1 means always infect. This is checked PER MOB, not per infect call.
	var/infection_coefficient = 1

	// disease_act(mob, datum/pathogen) : void
	// This is the center of pathogen symptoms.
	// On every Life() tick, this will be called for every symptom attached to the pathogen. Most pathogens should express their malevolence here, unless they are specifically tailored
	// to only work on events like human interaction or external effects. A symptom therefore should override this proc.
	// disease_act is also responsible for handling the symptom's ability to suppress the pathogen. Check the documentation on suppression in pathogen.dm.
	// OVERRIDE: A subclass (direct or otherwise) is expected to override this.
	proc/disease_act(var/mob/M as mob, var/datum/pathogen/origin)

	// disease_act_dead(mob, datum/pathogen) : void
	// This functions identically to disease_act, except it is only called when the mob is dead. (disease_act is not called if that is the case.)
	// OVERRIDE: Only override this if if it needed for the symptom.
	proc/disease_act_dead(var/mob/M as mob, var/datum/pathogen/origin)

	// does an infectious snap
	// makes others snap, should possibly infect you in the future if you are made to snap a certain amount of times
	proc/infect_snap(var/mob/M as mob, var/datum/pathogen/origin, var/range = 5)
		for (var/mob/I in view(range, M.loc))
			if (I != M && ((isturf(I.loc) && isturf(M.loc) && can_line_airborne(get_turf(M), I, 5)) || I.loc == M.loc))
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = I
					if(prob(100-H.get_disease_protection()))
						SPAWN(rand(0.5,2) SECONDS)
							H.show_message("Pretty catchy tune...")
							H.emote("snap") // consider yourself lucky I haven't implemented snap infection yet, human

	// creates an infective cloud
	// this should give people better feedback about how be infected and how to avoid it
	proc/infect_cloud(var/mob/M as mob, var/datum/pathogen/origin, var/amount = 5)
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

	// creates an infective puddle
	// this should give people better feedback about how be infected and how to avoid it
	proc/infect_puddle(var/mob/M as mob, var/datum/pathogen/origin, var/amount = 5)
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

	// infect_direct(mob, datum/pathogen) : void
	// This is the proc that handles direct transmission of the pathogen from one mob to another. This should be called in particular infection scenarios. For example, a sweating person
	// gets his bodily fluids onto another when they directly disarm, punch, or grab a person.
	// For INFECT_TOUCH diseases this is automatically called on a successful disarm, punch or grab. When overriding any of these events, use ..() to keep this behaviour.
	// OVERRIDE: Generally, you do not need to override this.
	proc/infect_direct(var/mob/target as mob, var/datum/pathogen/origin, contact_type = "touch")
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

	proc/onadd(var/datum/pathogen/origin)
		return

	// ====
	// Events from this point on. Their exact behaviour is documented in pathogen.dm. Please do not add any event definitions outside this block.
	// ondisarm(mob, mob, boolean, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/ondisarm(var/mob/M as mob, var/mob/V as mob, isPushDown, var/datum/pathogen/origin)
		if (infect_type == INFECT_TOUCH && prob(origin.spread*2))
			infect_direct(V, origin, "disarm")
		return 1

	// ongrab(mob, mob, datum/pathogen) : void
	// TODO: Make this a veto event.
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/ongrab(var/mob/M as mob, var/mob/V as mob, var/datum/pathogen/origin)
		if (infect_type == INFECT_TOUCH && prob(origin.spread*2))
			infect_direct(V, origin, "grab")
		return

	// onpunch(mob, mob, string, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/onpunch(var/mob/M as mob, var/mob/V as mob, zone, var/datum/pathogen/origin)
		if (infect_type == INFECT_TOUCH && prob(origin.spread*2))
			infect_direct(V, origin, "punching")
		return 1

	// onpunched(mob, mob, string, datum/pathogen) : float
	// OVERRIDE: Overriding this is situational. ..() is expected to be called.
	proc/onpunched(var/mob/M as mob, var/mob/A as mob, zone, var/datum/pathogen/origin)
		if (infect_type == INFECT_TOUCH && prob(origin.spread*2))
			infect_direct(A, origin, "being punched")
		return 1

	// onshocked(mob, mob, datum/shockparam, datum/pathogen) : datum/shockparam
	// OVERRIDE: Overriding this is situational.
	proc/onshocked(var/mob/M as mob, var/datum/shockparam/ret, var/datum/pathogen/origin)
		return ret

	// onsay(mob, string, datum/pathogen) : string
	// OVERRIDE: Overriding this is situational.
	proc/onsay(var/mob/M as mob, message, var/datum/pathogen/origin)
		return message

	// onemote(mob, string, number, string, datum/pathogen) : string
	// OVERRIDE: Overriding this is situational.
	proc/onemote(var/mob/M as mob, act, voluntary, param, var/datum/pathogen/P)
		return 1

	// ondeath(mob, datum/pathogen) : void
	// OVERRIDE: Overriding this is situational.
	proc/ondeath(var/mob/M as mob, var/datum/pathogen/origin)
		return

	// oncured(mob, datum/pathogen) : void
	// OVERRIDE: Overriding this is situational.
	proc/oncured(var/mob/M as mob, var/datum/pathogen/origin)
		return


	// End of events: please do not add any event definitions outside this block.
	// ====
