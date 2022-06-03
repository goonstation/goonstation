/proc/generate_cold_pathogen()
	var/datum/microbe/P = new /datum/microbe
	P.setup(2, null, 0)
	P.add_symptom(microbe_controller.path_to_effect[/datum/microbioeffects/malevolent/coughing])
	P.add_symptom(microbe_controller.path_to_effect[/datum/microbioeffects/malevolent/indigestion])
	return P

/proc/generate_flu_pathogen()
	var/datum/microbe/P = new /datum/microbe
	P.setup(2, null)
	P.add_symptom(microbe_controller.path_to_effect[/datum/microbioeffects/malevolent/coughing])
	P.add_symptom(microbe_controller.path_to_effect[/datum/microbioeffects/malevolent/sneezing])
	P.add_symptom(microbe_controller.path_to_effect[/datum/microbioeffects/malevolent/muscleache])
	return P

/proc/generate_indigestion_pathogen()
	var/datum/microbe/P = new /datum/microbe
	P.setup(2, null)
	P.add_symptom(microbe_controller.path_to_effect[/datum/microbioeffects/malevolent/indigestion])
	return P

