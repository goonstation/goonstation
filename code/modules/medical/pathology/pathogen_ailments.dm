/*/proc/generate_cold_pathogen()
	var/datum/pathogen/P = new /datum/pathogen
	P.forced_microbody = /datum/microbody/virus
	P.setup(2, null, 0)
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/coughing])
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/indigestion])
	return P

/proc/generate_flu_pathogen()
	var/datum/pathogen/P = new /datum/pathogen
	P.forced_microbody = /datum/microbody/virus
	P.setup(2, null, 0)
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/coughing])
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/sneezing])
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/muscleache])
	return P

/proc/generate_indigestion_pathogen()
	var/datum/pathogen/P = new /datum/pathogen
	P.setup(2, null, 0)
	P.add_symptom(pathogen_controller.path_to_symptom[/datum/pathogeneffects/malevolent/indigestion])
	return P
*/
