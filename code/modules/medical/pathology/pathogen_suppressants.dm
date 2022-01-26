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

/datum/suppressant
	var/name = "Suppressant"
	var/color = "transparent"
	var/desc = "The pathogen is not suppressed by any external effects."
	var/therapy = "unknown"

	// A list of reagent IDs which may be used for cure synthesis with this suppressant.
	var/list/cure_synthesis = list()

	// Override this to define when your suppression method should act.
	// Returns the new value for suppressed which is ONLY considered if suppressed is 0.
	// Is not called if suppressed is -1. A secondary resistance may overpower a primary weakness.
	proc/suppress_act(var/datum/pathogen/P)
		return

	proc/ongrab(var/mob/target as mob, var/datum/pathogen/P)
		return
	proc/onpunched(var/mob/origin as mob, zone, var/datum/pathogen/P)
	proc/onpunch(var/mob/target as mob, zone, var/datum/pathogen/P )
	proc/ondisarm(var/mob/target as mob, isPushDown, var/datum/pathogen/P)
	proc/onshocked(var/datum/shockparam/param, var/datum/pathogen/P)
	proc/onsay(message, var/datum/pathogen/P)
	proc/onadd(var/datum/pathogen/P)
	proc/onemote(var/mob/M as mob, message, voluntary, param, var/datum/pathogen/P)
	proc/ondeath(var/datum/pathogen/P)
	proc/oncured(var/datum/pathogen/P)

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

	cure_synthesis = list("phlogiston", "infernite")

	suppress_act(var/datum/pathogen/P)
		if (P.infected.bodytemperature > 310 + P.suppression_threshold)
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	may_react_to()
		return "A peculiar gland on the pathogen suggests it may be <b style='font-size:20px;color:red'>suppressed</b> by affecting its temperature."

	react_to(var/R)
		if (R == "phlogiston" || R == "infernite")
			return "The pathogens are attemping to escape from the area affected by the [R]."
		else if (R in cure_synthesis)
			return "The pathogens are moving towards the area affected by the [R]"
		else return null

/datum/suppressant/cold
	color = "red"
	name = "Cold"
	desc = "The pathogen is suppressed by a low body temperature."
	therapy = "thermal"

	cure_synthesis = list("cryostylane", "cryoxadone")

	suppress_act(var/datum/pathogen/P)
		if (P.infected.bodytemperature < 300 - P.suppression_threshold)
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	may_react_to()
		return "A peculiar gland on the pathogen suggests it may be <b style='font-size:20px;color:red'>suppressed</b> by affecting its temperature."

	react_to(var/R)
		if (R == "phlogiston" || R == "infernite")
			return "The pathogens are moving towards the area affected by the [R]"
		else if (R in cure_synthesis)
			return "The pathogens are attemping to escape from the area affected by the [R]."
		else return null

/datum/suppressant/sleeping
	color = "green"
	name = "Sedative"
	desc = "The pathogen is suppressed by sleeping."
	therapy = "sedative"

	suppress_act(var/datum/pathogen/P)
		if (P.infected.sleeping)
			P.symptom_data["suppressant"]++
			var/slept = P.symptom_data["suppressant"]
			if (slept > P.suppression_threshold)
				if (P.stage > 3 && prob(P.advance_speed * 4))
					P.infected.show_message("<span class='notice'>You feel better.</span>")
					P.stage--
					P.symptom_data["suppressant"] = 0
			return 1
		else
			P.symptom_data["suppressant"] = 0
		return 0

	cure_synthesis = list("morphine", "ketamine")

	onadd(var/datum/pathogen/P)
		P.symptom_data["suppressant"] = 0

	may_react_to()
		return "Membrane patterns of the pathogen indicate it might be <b style='font-size:20px;color:red'>suppressed</b> by a reagent affecting neural activity."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the sedative appear to be in stasis."
		else return null

/datum/suppressant/brutemeds
	color = "black"
	name = "Brute Medicine"
	desc = "The pathogen is suppressed by brute medicine."
	therapy = "medical"

	suppress_act(var/datum/pathogen/P)
		if (P.infected.reagents.has_reagent("styptic_powder", P.suppression_threshold) || P.infected.reagents.has_reagent("synthflesh", P.suppression_threshold))
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	cure_synthesis = list("styptic_powder", "synthflesh")

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
	therapy = "medical"

	suppress_act(var/datum/pathogen/P)
		if (P.infected.reagents.has_reagent("silver_sulfadiazine", P.suppression_threshold) || P.infected.reagents.has_reagent("synthflesh", P.suppression_threshold))
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	cure_synthesis = list("silver_sulfadiazine", "synthflesh")

	may_react_to()
		return "The DNA repair processes of the pathogen indicate that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of medicine."

	react_to(var/R)
		if (R in cure_synthesis)
			return "The pathogens near the [R] appear to be weakened by the burn medicine's presence."
		else return null

/datum/suppressant/muscle
	color = "white"
	name = "Muscle"
	desc = "The pathogen is suppressed by disrupting muscle function."
	therapy = "sedative"

	cure_synthesis = list("haloperidol", "neurotoxin")

	suppress_act(var/datum/pathogen/P)
		if (P.infected.reagents.has_reagent("haloperidol", P.suppression_threshold) || P.infected.reagents.has_reagent("neurotoxin", P.suppression_threshold))
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	onshocked(var/datum/shockparam/param, var/datum/pathogen/P)
		if (param.skipsupp)
			return
		if (P.stage > 3)
			var/better = 0
			if (param.amt > 50)
				P.stage = 3
			else if (param.amt > 30)
				if (prob(P.advance_speed * 2))
					P.stage = 3
				else
					P.stage--
			else if (param.amt > 15 && prob(P.advance_speed * 2))
				P.stage--
				better = 1
			if (param.amt > 30 || better)
				P.infected.show_message("<span class='notice'>You feel better.</span>")
		if (P.suppressed == 0)
			P.suppressed = 1
		if(P.curable_by_suppression && prob(param.amt>100?100:param.amt))      // just to make this a little more likely to actually cure, or else it's too hard
			P.remission()

	may_react_to()
		return "Membrane patterns of the pathogen indicate it might be <b style='font-size:20px;color:red'>suppressed</b> by a reagent affecting neural activity."

	react_to(var/R)
		if (R == "haloperidol")
			return "The pathogens near the [R] appear to move at a slower pace."
		if (R == "neurotoxin")
			return "The pathogens near the [R] appear to be confused."
		else return null

/datum/suppressant/fat
	color = "orange"
	name = "Fat"
	desc = "The pathogen is suppressed by fats."
	cure_synthesis = list("badgrease", "grease", "porktonium", "cholesterol")
	therapy = "gastronomical"

	suppress_act(var/datum/pathogen/P)
		if (P.infected.reagents.has_reagent("badgrease", P.suppression_threshold) || P.infected.reagents.has_reagent("grease", P.suppression_threshold) || P.infected.reagents.has_reagent("porktonium", P.suppression_threshold) || P.infected.reagents.has_reagent("cholesterol", P.suppression_threshold))
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	may_react_to()
		return "An observation of the metabolizing processes of the pathogen shows that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of foodstuffs."

	react_to(var/datum/reagent/R)
		if (R in cure_synthesis)
			return "The pathogens near the fatty substance appear to be significantly heavier and slower than their unaffected counterparts."
		else return null

/datum/suppressant/chickensoup
	color = "pink"
	name = "Chicken Soup"
	desc = "The pathogen is suppressed by a nice bowl of old fashioned chicken soup."
	therapy = "gastronomical"

	cure_synthesis = list("chickensoup")

	suppress_act(var/datum/pathogen/P)
		if (P.infected.reagents.has_reagent("chickensoup", P.suppression_threshold))
			if (P.stage > 3 && prob(P.advance_speed * 2))
				P.infected.show_message("<span class='notice'>You feel better.</span>")
				P.stage--
			return 1
		return 0

	may_react_to()
		return "An observation of the metabolizing processes of the pathogen shows that it might be <b style='font-size:20px;color:red'>suppressed</b> by certain kinds of foodstuffs."

	react_to(var/datum/reagent/R)
		if (R == "chickensoup")
			return "The pathogens near the chicken soup appear to be having a great meal and are ignorant of their surroundings."

/datum/suppressant/radiation
	color = "viridian"
	name = "Radiation"
	desc = "The pathogen is suppressed by radiation."
	therapy = "radioactive"

	cure_synthesis = list("radium", "mutagen", "uranium", "polonium")

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

