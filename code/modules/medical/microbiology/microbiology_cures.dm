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
	ABSTRACT_TYPE(/datum/suppressant)
	// A list of reagent IDs which can be designated as the suppressant.
	var/list/cure_synthesis = list()

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
	proc/react_to(var/R)
		return ""

	proc/may_react_to()
		return ""

/datum/suppressant/heat
	color = "blue"
	name = "Heat"
	desc = "The pathogen is suppressed by a high body temperature."
	therapy = "thermal"

	cure_synthesis = MB_HOT_REAGENTS

	suppress_act(var/datum/microbe/P)
		if (!(P.infected.bodytemperature > 320 + P.duration))	//Base temp is 273 + 37 = 310. Add 10 to avoid natural variance.
			return 0
		else
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1

	onadd(var/datum/microbe/P)
		P.suppressant = "Heat"
		return

	may_react_to()
		return "A peculiar gland on the pathogen suggests it may be <b style='font-size:20px;color:red'>suppressed</b> by affecting its temperature."

	react_to(var/R)
		if (R in MB_HOT_REAGENTS)
			return MICROBIO_INSPECT_DISLIKES + "[R]."
		else if (R in cure_synthesis)
			return MICROBIO_INSPECT_LIKES + "[R]."
		else return null

/datum/suppressant/cold
	color = "red"
	name = "Cold"
	desc = "The pathogen is suppressed by a low body temperature."
	therapy = "thermal"

	cure_synthesis = MB_COLD_REAGENTS

	suppress_act(var/datum/microbe/P)
		if (!(P.infected.bodytemperature < 300 - P.duration)) // Same idea as for heat, but inverse.
			return 0
		else
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1

	may_react_to()
		return "A peculiar gland on the pathogen suggests it may be <b style='font-size:20px;color:red'>suppressed</b> by affecting its temperature."

	react_to(var/R)
		if (R == "phlogiston" || R == "infernite")
			return MICROBIO_INSPECT_LIKES + "[R]."
		else if (R in cure_synthesis)
			return MICROBIO_INSPECT_DISLIKES + "[R]."
		else return null
/*
/datum/suppressant/sleeping
	color = "green"
	name = "Sedative"
	desc = "The pathogen is suppressed by sleeping."
	therapy = "sedative"

	suppress_act(var/datum/pathogen/P)
		if (P.infected.sleeping)
			P.effectdata["suppressant"]++
			var/slept = P.effectdata["suppressant"]
			if (slept > P.suppression_threshold)
				if (P.stage > 3 && prob(P.advance_speed * 4))
					P.infected.show_message("<span class='notice'>You feel better.</span>")
					P.stage--
					P.effectdata["suppressant"] = 0
			return 1
		else
			P.effectdata["suppressant"] = 0
		return 0

	cure_synthesis = list("morphine", "ketamine")

	onadd(var/datum/pathogen/P)
		P.effectdata["suppressant"] = 0

	may_react_to()
		return "Membrane patterns of the pathogen indicate it might be <b style='font-size:20px;color:red'>suppressed</b> by a reagent affecting neural activity."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the sedative appear to be in stasis."
		else return null
*/

/datum/suppressant/brutemeds
	color = "black"
	name = "Brute Medicine"
	desc = "The pathogen is suppressed by brute medicine."
	therapy = "drugs"

	cure_synthesis = MB_BRUTE_MEDS_CATAGORY				//Make a define for BRUTE_MEDS

	suppress_act(var/datum/microbe/P)
		for (var/R in cure_synthesis)
			if (!(P.infected.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0
	may_react_to()
		return "The DNA repair processes of the pathogen indicate that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of medicine."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the [R] appear to be weakened by the brute medicine's presence."
		else return null

/datum/suppressant/burnmeds
	color = "cyan"
	name = "Burn Medicine"
	desc = "The pathogen is suppressed by burn medicine."
	therapy = "drugs"
	cure_synthesis = MB_BURN_MEDS_CATAGORY //Make a define for BURN_MEDS

	suppress_act(var/datum/microbe/P)
		for (var/R in cure_synthesis)
			if (!(P.infected.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

	may_react_to()
		return "The DNA repair processes of the pathogen indicate that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of medicine."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the [R] appear to be weakened by the burn medicine's presence."
		else return null

/datum/suppressant/antitox
	color = "lime"
	name = "Anti-Toxins"
	desc = "The pathogen is suppressed by anti-toxins."
	therapy = "drugs"
	cure_synthesis = MB_TOX_MEDS_CATAGORY //Make a define for BURN_MEDS

	suppress_act(var/datum/microbe/P)
		for (var/R in cure_synthesis)
			if (!(P.infected.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0
	may_react_to()
		return "The DNA repair processes of the pathogen indicate that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of medicine."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the [R] appear to be weakened by the anti-toxin medicine's presence."
		else return null

/datum/suppressant/burnmeds
	color = "blue"
	name = "Oxygen Medicine"
	desc = "The pathogen is suppressed by oxygen medicine."
	therapy = "drugs"
	cure_synthesis = MB_OXY_MEDS_CATAGORY //Make a define for BURN_MEDS

	suppress_act(var/datum/microbe/P)
		for (var/R in cure_synthesis)
			if (!(P.infected.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0
	may_react_to()
		return "The DNA repair processes of the pathogen indicate that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of medicine."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the [R] appear to be weakened by the oxygen medicine's presence."
		else return null

/datum/suppressant/sedatives
	color = "white"
	name = "Sedative"
	desc = "The pathogen is suppressed by disrupting muscle function."
	therapy = "sedatives"

	cure_synthesis = MB_SEDATIVES_CATAGORY

	suppress_act(var/datum/microbe/P)
		for (var/R in cure_synthesis)
			if (!(P.infected.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

	onshocked(var/datum/shockparam/param, var/datum/microbe/P)
		if (param.skipsupp)
			return
		if (param.amt > 30)
			P.infected.show_message("<span class='notice'>You feel better.</span>")
			return

	may_react_to()
		return "Membrane patterns of the pathogen indicate it might be <b style='font-size:20px;color:red'>suppressed</b> by a reagent affecting neural activity."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the [R] appear to move at a slower pace."
		else return null

/datum/suppressant/stimulants
	color = "grey"
	name = "Stimulants"
	desc = "The pathogen is suppressed by facilitating muscle function."
	therapy = "stimulants"

	cure_synthesis = MB_STIMULANTS_CATAGORY

	suppress_act(var/datum/microbe/P)
		for (var/R in cure_synthesis)
			if (!(P.infected.reagents.has_reagent(R, REAGENT_CURE_THRESHOLD)))
				continue
			if (prob(5))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
			return 1
		return 0

	may_react_to()
		return "Membrane patterns of the pathogen indicate it might be <b style='font-size:20px;color:red'>suppressed</b> by a reagent affecting neural activity."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the [R] appear to move at a faster pace."
		else return null

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
