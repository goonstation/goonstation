/proc/generate_cold_pathogen()
	var/datum/pathogen/P = new /datum/pathogen
	P.forced_microbody = /datum/microbody/virus
	P.curable_by_suppression = 7
	P.setup(2, null, 0)
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/coughing])
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/indigestion])
	return P

/proc/generate_flu_pathogen()
	var/datum/pathogen/P = new /datum/pathogen
	P.forced_microbody = /datum/microbody/virus
	P.curable_by_suppression = 4
	P.setup(2, null, 0)
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/coughing])
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/sneezing])
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/muscleache])
	return P

/proc/generate_indigestion_pathogen()
	var/datum/pathogen/P = new /datum/pathogen
	P.curable_by_suppression = 18
	P.setup(2, null, 0)
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/indigestion])
	return P
