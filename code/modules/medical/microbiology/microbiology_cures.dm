/**
 * Pathogen suppressants
 *
 * A well identifiable trait of each pathogen which inhibits its growth. The method of identification is through colour.
 * Suppression cannot completely cure a pathogen, however, its destructive potential may be severely limited by suppression.
 *
 * Suppressants may react to events the same way symptoms can - as suppressants are instantiated per pathogen, they may have their
 * own internal state without breaking anything.
 *
 * Suppressants also play a large role in the synthesis of cure for all default microbodies - each suppressant indicates a
 * list of reagents which may be used for cure synthesis. Curing therefore requires at least some analysis of the pathogen.
 */
ABSTRACT_TYPE(/datum/suppressant)
/datum/suppressant
	var/name = "Suppressant"
	var/color = "transparent"
	var/desc = "The pathogen is not suppressed by any external effects."
	var/therapy = "unknown"
	var/exactcure = "unknown"
	// A list of reagent IDs which can be designated as the cure.
	var/list/cure_synthesis = list()
	var/reactionlist = list()
	var/reactionmessage = MICROBIO_INSPECT_HIT_CURE

	// Override this to define when your suppression method should act.
	// Returns the new value for suppressed which is ONLY considered if suppressed is 0.
	// Is not called if suppressed is -1. A secondary resistance may overpower a primary weakness.
	proc/suppress_act(var/datum/microbe/P)
		return

	proc/ongrab(var/mob/target as mob, var/datum/microbe/P)
	proc/onpunched(var/mob/origin as mob, zone, var/datum/microbe/P)
	proc/onpunch(var/mob/target as mob, zone, var/datum/microbe/P)
	proc/ondisarm(var/mob/target as mob, isPushDown, var/datum/microbe/P)

	proc/onshocked(var/datum/shockparam/param, var/datum/microbe/P)
		return

	proc/onsay(message, var/datum/microbe/P)

	proc/onadd(var/datum/microbe/P)
		return
	proc/onemote(var/mob/M as mob, message, voluntary, param, var/datum/microbe/P)

	proc/ondeath(var/datum/microbe/P)

	proc/oncured(var/datum/microbe/P)

	// While doing pathogen research, the suppression method may define how the pathogen reacts to certain reagents.
	// Returns null if the pathogen does not react to the reagent.
	// Returns a string describing what happened if it does react to the reagent.
	// NOTE: Conforming with the new chemistry system, R is now a reagent ID, not a reagent instance.

	New()
		..()
		color = pick(named_colors)

/datum/suppressant/heat
	name = "Heat"
	desc = "The pathogen is suppressed by a high body temperature."
	therapy = "Thermal"
	exactcure = "Controlled hyperthermia therapy"
	cure_synthesis = MB_HOT_REAGENTS
	reactionlist = MB_COLD_REAGENTS

	suppress_act(var/datum/microbesubdata/P)
		if (!(P.affected_mob.bodytemperature > 320 + P.duration))	//Base temp is 273 + 37 = 310. Add 10 to avoid natural variance.
			return 0
		else
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1

	onadd(var/datum/microbe/P)
		P.suppressant = "Heat"
		return

/datum/suppressant/cold
	name = "Cold"
	desc = "The pathogen is suppressed by a low body temperature."
	therapy = "Thermal"
	exactcure = "Cryogenic therapy"
	cure_synthesis = MB_COLD_REAGENTS
	reactionlist = MB_HOT_REAGENTS

	suppress_act(var/datum/microbesubdata/P)
		if (!(P.affected_mob.bodytemperature < 300 - P.duration)) // Same idea as for heat, but inverse.
			return 0
		else
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1

/datum/suppressant/brutemeds
	name = "Brute Medicine"
	desc = "The pathogen is suppressed by brute medicine."
	therapy = "Medications"
	exactcure = "Brute Medications"
	cure_synthesis = MB_BRUTE_MEDS_CATAGORY
	reactionlist = MB_BRUTE_MEDS_CATAGORY

	suppress_act(var/datum/microbesubdata/P)
		for (var/R in cure_synthesis)
			if (!(P.affected_mob.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

/datum/suppressant/burnmeds
	name = "Burn Medicine"
	desc = "The pathogen is suppressed by burn medicine."
	therapy = "Medications"
	exactcure = "Burn Medications"
	cure_synthesis = MB_BURN_MEDS_CATAGORY
	reactionlist = MB_BURN_MEDS_CATAGORY

	suppress_act(var/datum/microbesubdata/P)
		for (var/R in cure_synthesis)
			if (!(P.affected_mob.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

/datum/suppressant/antitox
	name = "Anti-Toxins"
	desc = "The pathogen is suppressed by anti-toxins."
	therapy = "Medications"
	exactcure = "Anti-Toxin Medications"
	cure_synthesis = MB_TOX_MEDS_CATAGORY
	reactionlist = MB_TOX_MEDS_CATAGORY


	suppress_act(var/datum/microbesubdata/P)
		for (var/R in cure_synthesis)
			if (!(P.affected_mob.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

/datum/suppressant/oxymeds
	name = "Oxygen Medicine"
	desc = "The pathogen is suppressed by oxygen medicine."
	therapy = "Medications"
	exactcure = "Oxygen Medications"
	cure_synthesis = MB_OXY_MEDS_CATAGORY
	reactionlist = MB_OXY_MEDS_CATAGORY

	suppress_act(var/datum/microbesubdata/P)
		for (var/R in cure_synthesis)
			if (!(P.affected_mob.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

/datum/suppressant/sedatives
	name = "Sedative"
	desc = "The pathogen is suppressed by disrupting muscle function."
	therapy = "Drugs"
	exactcure = "Sedatives"
	cure_synthesis = MB_SEDATIVES_CATAGORY
	reactionlist = MB_SEDATIVES_CATAGORY

	suppress_act(var/datum/microbesubdata/P)
		for (var/R in cure_synthesis)
			if (!(P.affected_mob.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

	onshocked(var/datum/shockparam/param, var/datum/microbesubdata/P)
		if (param.skipsupp)
			return
		if (param.amt > 30)
			P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return

/datum/suppressant/stimulants
	name = "Stimulants"
	desc = "The pathogen is suppressed by facilitating muscle function."
	therapy = "Drugs"
	exactcure = "Stimulants"
	cure_synthesis = MB_STIMULANTS_CATAGORY
	reactionlist = MB_STIMULANTS_CATAGORY

	suppress_act(var/datum/microbesubdata/P)
		for (var/R in cure_synthesis)
			if (!(P.affected_mob.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

/datum/suppressant/spaceacillin
	name = "Spaceacillin"
	desc = "The pathogen is suppressed by spaceacillin."
	therapy = "Drugs"
	exactcure = "Spaceacillin"
	cure_synthesis = "spaceacillin"
	reactionlist = "spaceacillin"

	suppress_act(var/datum/microbesubdata/P)
		for (var/R in cure_synthesis)
			if (!(P.affected_mob.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.affected_mob.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

/*
/datum/suppressant/chickensoup
	color = "pink"
	name = "Chicken Soup"
	desc = "The pathogen is suppressed by a nice bowl of old fashioned chicken soup."
	therapy = "gastronomical"

	cure_synthesis = list("chickensoup")

	suppress_act(var/datum/microbe/P)
		if (!(P.infected.reagents.has_reagent("chickensoup", REAGENT_CURE_THRESHOLD)))
			return 0
		else
			if(prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1


	may_react_to()
		return "An observation of the metabolizing processes of the pathogen shows that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of foodstuffs."

	react_to(var/datum/reagent/R)
		if (R == "chickensoup")
			return "The pathogens near the chicken soup appear to be having a great meal and are ignorant of their surroundings."
*/
/*
/datum/suppressant/fat
	color = "orange"
	name = "Fat"
	desc = "The pathogen is suppressed by fats."
	therapy = "gastronomical"

	cure_synthesis = MB_FATS_CATAGORY	// Definitely make a define with a bigger list

	suppress_act(var/datum/microbe/P)
		for (var/R in cure_synthesis)
			if (!(P.infected.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

	may_react_to()
		return "An observation of the metabolizing processes of the pathogen shows that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of foodstuffs."

	react_to(var/datum/reagent/R)
		if (R in cure_synthesis)
			return "The pathogens near the fatty substance appear to be significantly heavier and slower than their unaffected counterparts."
		else return null
*/

// Below are old Pathology suppressants. I hesitate to use these because they strictly rely on harmful cure substances.
/*
/datum/suppressant/radiation
	color = "viridian"
	name = "Radiation"
	desc = "The pathogen is suppressed by radiation."
	therapy = "radioactive"

	cure_synthesis = list("radium", "mutagen", "uranium", "polonium")	//I don't know about this one...

	suppress_act(var/datum/pathogen/P)
		if ((P.infected.getStatusDuration("radiation")/10) > P.suppression_threshold * 0.1 || (P.infected.getStatusDuration("n_radiation")/10) > P.suppression_threshold * 0.05)
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	may_react_to()
		return "The chemical structure of the pathogen's membrane indicates it may be <b style='font-size:20px;color:red'>suppressed</b> by either gamma rays or mutagenic substances."

	react_to(var/datum/reagent/R)
		if (R in cure_synthesis)
			return "The radiation emitted by the [R] is severely damaging the inner elements of the pathogen."
*/
/*
/datum/suppressant/mutagen
	color = "olive drab"
	name = "Mutagen"
	desc = "The pathogen is suppressed by mutagenic substances."
	therapy = "radioactive"

	cure_synthesis = list("mutagen", "dna_mutagen")

	suppress_act(var/datum/pathogen/P)
		if (P.infected.reagents.has_reagent("mutagen", P.suppression_threshold) || P.infected.reagents.has_reagent("dna_mutagen", P.suppression_threshold))
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	may_react_to()
		return "The chemical structure of the pathogen's membrane indicates it may be <b style='font-size:20px;color:red'>suppressed</b> by mutagenic substances."

	react_to(var/datum/reagent/R)
		if (R in cure_synthesis)
			return "The mutagenic substance is severely damaging the inner elements of the pathogen."
*/

/*
/datum/suppressant/sleeping
	color = "green"
	name = "Sedative"
	desc = "The pathogen is suppressed by sleeping."
	therapy = "sedative"

	suppress_act(var/datum/pathogen/P)
		if (P.infected.sleeping)
			P.master.effectdata["suppressant"]++
			var/slept = P.master.effectdata["suppressant"]
			if (slept > P.suppression_threshold)
				if (P.stage > 3 && prob(P.advance_speed * 4))
					P.infected.show_message("<span class='notice'>You feel better.</span>")
					P.stage--
					P.master.effectdata["suppressant"] = 0
			return 1
		else
			P.master.effectdata["suppressant"] = 0
		return 0

	cure_synthesis = list("morphine", "ketamine")

	onadd(var/datum/pathogen/P)
		P.master.effectdata["suppressant"] = 0

	may_react_to()
		return "Membrane patterns of the pathogen indicate it might be <b style='font-size:20px;color:red'>suppressed</b> by a reagent affecting neural activity."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the sedative appear to be in stasis."
		else return null
*/
