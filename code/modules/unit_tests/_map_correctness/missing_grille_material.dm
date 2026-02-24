/datum/map_correctness_check/missing_grille_material
	check_name = "Missing Grille Materials"

/datum/map_correctness_check/missing_grille_material/run_check()
	. = list()

	for_by_tcl(grille, /obj/mesh/grille)
		if (!isnull(grille.material))
			continue

		. += src.format_position(grille)


SET_UP_CI_TRACKING(/obj/mesh/grille)
